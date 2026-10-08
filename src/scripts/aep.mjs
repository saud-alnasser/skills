#!/usr/bin/env node
// The AEP command line. Every git and worktree step a run takes goes through
// here, so the ordering rules live in one place: commit before release,
// detach before remove, every surface under the main checkout's worktrees.
//
//   node .aep/scripts/aep.mjs status [--repos <dir>] [--json]
//   node .aep/scripts/aep.mjs open <slug> --lane <quick|standard|full> [--number <n>]
//   node .aep/scripts/aep.mjs start [<effort>|<effort>/<ticket>]
//   node .aep/scripts/aep.mjs dispatch <effort> <ticket>...
//   node .aep/scripts/aep.mjs land <effort> [<ticket>] --message <text> [--session <id>]
//   node .aep/scripts/aep.mjs close <effort> [--stop <reason>] [--friction <line>]... [--session <id>]
//   node .aep/scripts/aep.mjs raise <effort> <lane> --reason <text>
//   node .aep/scripts/aep.mjs record <effort> --converge|--review|--note|--needs-you <line>
//   node .aep/scripts/aep.mjs check [--root <tree>]
//
// Every command but status and check prints one JSON object carrying a
// `summary`; status prints a board, or JSON with --json. Every command is safe
// to run twice: a step already taken is reported, not taken again.
//
// git is the only program it starts, apart from the repository's own `setup:`
// command, which it runs in a new surface because the repository asked for it.
// It never calls a forge. Where the tracker is on, it lists the forge steps for
// the run to take.

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import {
  LANES,
  LANE_RULES,
  parseFrontmatterBlock,
  readArtifact,
  resolveAepRoot,
  toPosix,
} from './contract.mjs';
import { frontier, readTickets } from './frontier.mjs';
import { writeIndex } from './index.mjs';
import { checkMarker, stampMarker } from './position.mjs';
import { resolveBase, resolveScope } from './scope.mjs';
import { runChecks } from './check.mjs';
import { validateTree } from './validate.mjs';

// --- git ----------------------------------------------------------------------

class Stop extends Error {
  constructor(reason, extra = {}) {
    super(reason);
    this.extra = extra;
  }
}

function git(cwd, args, { allowFail = false } = {}) {
  try {
    return execFileSync('git', args, {
      cwd,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'pipe'],
      maxBuffer: 64 * 1024 * 1024,
      env: { ...process.env, GIT_OPTIONAL_LOCKS: '0' },
    }).replace(/\s+$/, '');
  } catch (error) {
    if (allowFail) return null;
    const detail = String(error.stderr ?? error.message).trim().split(/\r?\n/).slice(-3).join(' ');
    throw new Stop(`git ${args.join(' ')} failed: ${detail}`);
  }
}

function same(a, b) {
  const norm = (value) => path.resolve(value).replace(/\\/g, '/').replace(/\/+$/, '').toLowerCase();
  return norm(a) === norm(b);
}

function worktreeList(repo) {
  const out = git(repo, ['worktree', 'list', '--porcelain'], { allowFail: true }) ?? '';
  const list = [];
  let current = null;
  for (const line of out.split(/\r?\n/)) {
    if (line.startsWith('worktree ')) {
      current = { path: path.resolve(line.slice(9).trim()), branch: null, detached: false };
      list.push(current);
    } else if (current && line.startsWith('branch ')) {
      current.branch = line.slice(7).trim().replace(/^refs\/heads\//, '');
    } else if (current && line === 'detached') {
      current.detached = true;
    }
  }
  return list;
}

function branchExists(repo, branch) {
  return git(repo, ['rev-parse', '--verify', '--quiet', `refs/heads/${branch}`], { allowFail: true }) !== null;
}

function dirtyPaths(surface) {
  const out = git(surface, ['status', '--porcelain', '-z', '--untracked-files=all']) ?? '';
  const records = out.split('\0').filter(Boolean);
  const paths = [];
  for (let i = 0; i < records.length; i += 1) {
    const record = records[i];
    paths.push(record.slice(3));
    if (/[RC]/.test(record.slice(0, 2))) i += 1;
  }
  return paths.sort();
}

// --- where things are -----------------------------------------------------------

/** The repository this run stands in, its main checkout, and where `.aep/` sits in both. */
function locate(root) {
  const repo = git(path.dirname(root), ['rev-parse', '--show-toplevel']);
  const inner = git(path.dirname(root), ['rev-parse', '--show-prefix']);
  const aepRel = `${inner}${path.basename(root)}`.replace(/\/+$/, '');
  const main = worktreeList(repo)[0]?.path ?? repo;
  return { repo: path.resolve(repo), main, aepRel, root };
}

function aepIn(tree, where) {
  return path.join(tree, ...where.aepRel.split('/'));
}

function runSurface(where, effort) {
  return path.join(aepIn(where.main, where), 'worktrees', effort, '_run');
}

function ticketSurface(where, effort, stem) {
  return path.join(aepIn(where.main, where), 'worktrees', effort, stem);
}

/**
 * A ticket's branch. `--`, not `/`: git cannot create `<effort>/<ticket>`
 * while the effort branch `<effort>` exists.
 */
function ticketBranch(effort, stem) {
  return `${effort}--${stem}`;
}

function rel(where, absolute) {
  return path.relative(where.main, absolute).replace(/\\/g, '/');
}

// --- settings ---------------------------------------------------------------------

/** `tracker`, `setup`, and `stack`, read from the repository's version-control rule. */
export function readSettings(root) {
  const file = path.join(root, 'rules', 'version-control.md');
  const fields = fs.existsSync(file) ? readArtifact(file).fields : {};
  const tracker = ['github', 'gitlab'].includes(fields.tracker) ? fields.tracker : 'none';
  const setup = typeof fields.setup === 'string' ? fields.setup.trim() : '';
  const stack = fields.stack === true || fields.stack === 'true';
  return { tracker, setup, stack };
}

const LOCKFILES = [
  'package-lock.json', 'pnpm-lock.yaml', 'yarn.lock', 'bun.lockb', 'bun.lock', 'Cargo.lock',
  'poetry.lock', 'uv.lock', 'Pipfile.lock', 'go.sum', 'Gemfile.lock', 'composer.lock', 'deno.lock',
];

function lockfileHash(tree) {
  const hash = crypto.createHash('sha256');
  for (const name of LOCKFILES) {
    const file = path.join(tree, name);
    if (fs.existsSync(file)) hash.update(name).update('\0').update(fs.readFileSync(file));
  }
  return hash.digest('hex');
}

/**
 * Runs the repository's own `setup:` command in a surface, and records the
 * lockfile it ran against in that surface's scratch. With `whenChanged`, it
 * runs only where the lockfiles moved since the last run.
 */
function warm(where, settings, surface, { whenChanged = false } = {}) {
  if (!settings.setup) return { ran: false, reason: 'no setup command' };
  const record = path.join(aepIn(surface, where), 'scratch', 'setup.json');
  const hash = lockfileHash(surface);
  if (whenChanged && fs.existsSync(record)) {
    try {
      if (JSON.parse(fs.readFileSync(record, 'utf8')).lockfiles === hash) {
        return { ran: false, reason: 'lockfiles unchanged' };
      }
    } catch {
      // An unreadable record is the same as none: run it.
    }
  }
  const outcome = runSetup(settings.setup, surface);
  if (outcome.ok) {
    fs.mkdirSync(path.dirname(record), { recursive: true });
    fs.writeFileSync(record, `${JSON.stringify({ lockfiles: hash, command: settings.setup })}\n`, 'utf8');
  }
  return { ran: true, command: settings.setup, ...outcome };
}

/** The one process start that is not git: the command the repository wrote into `setup:`. */
function runSetup(command, cwd) {
  const result = spawnSync(command, { cwd, shell: true, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
  const tail = `${result.stdout ?? ''}${result.stderr ?? ''}`.trim().split(/\r?\n/).slice(-5).join('\n');
  return { ok: result.status === 0, status: result.status, tail };
}

// --- effort files -------------------------------------------------------------------

function setField(text, field, value) {
  const match = /^---\r?\n([\s\S]*?)\r?\n---/.exec(text);
  if (!match) return `---\n${field}: ${value}\n---\n\n${text}`;
  const block = match[1];
  const line = new RegExp(`^${field}:.*$`, 'm');
  const next = line.test(block) ? block.replace(line, `${field}: ${value}`) : `${block}\n${field}: ${value}`;
  return text.replace(block, next);
}

function readSpec(effortDir) {
  const file = path.join(effortDir, 'spec.md');
  if (!fs.existsSync(file)) throw new Stop(`no spec.md in ${effortDir}`);
  const artifact = readArtifact(file);
  const lane = LANES.includes(artifact.fields.lane) ? artifact.fields.lane : 'full';
  return { file, fields: artifact.fields, body: artifact.body, lane, status: artifact.fields.status };
}

const LOG_HEADER = (effort) => [
  '---',
  'use-when: "resuming this effort, or asking where it stands"',
  '---',
  '',
  `# Run log: ${effort}`,
  '',
  '## Ledger',
  '',
  '## Rounds',
  '',
  '## Recorded',
  '',
  '## Needs you',
  '',
].join('\n');

function logFile(effortDir) {
  return path.join(effortDir, 'log.md');
}

function ensureLog(effortDir, effort) {
  const file = logFile(effortDir);
  if (!fs.existsSync(file)) fs.writeFileSync(file, LOG_HEADER(effort), 'utf8');
  return file;
}

/** Appends a line at the end of one `## <heading>` section of the log. */
function appendToLog(effortDir, effort, heading, line) {
  const file = ensureLog(effortDir, effort);
  const text = fs.readFileSync(file, 'utf8').replace(/\r\n/g, '\n');
  const lines = text.split('\n');
  const start = lines.findIndex((entry) => entry.trim() === `## ${heading}`);
  if (start === -1) {
    fs.writeFileSync(file, `${text.replace(/\n*$/, '\n')}\n## ${heading}\n\n${line}\n`, 'utf8');
    return;
  }
  let end = lines.findIndex((entry, index) => index > start && entry.startsWith('## '));
  if (end === -1) end = lines.length;
  let insert = end;
  while (insert > start + 1 && lines[insert - 1].trim() === '') insert -= 1;
  if (lines.slice(start + 1, end).includes(line)) return;
  lines.splice(insert, 0, ...(insert === start + 1 ? ['', line] : [line]));
  fs.writeFileSync(file, lines.join('\n'), 'utf8');
}

/** One section of the log, as its non-empty lines. */
export function logSection(text, heading) {
  const lines = String(text ?? '').replace(/\r\n/g, '\n').split('\n');
  const start = lines.findIndex((entry) => entry.trim() === `## ${heading}`);
  if (start === -1) return [];
  const out = [];
  for (let i = start + 1; i < lines.length && !lines[i].startsWith('## '); i += 1) {
    if (lines[i].trim() !== '') out.push(lines[i].trim());
  }
  return out;
}

/**
 * The rounds the log records. A line reads `converge 1: no gap`,
 * `converge 1: gap, tickets 05 06`, `review 1: 3 findings, 3 fixed`,
 * `review 2: no findings`.
 */
export function readRounds(text) {
  const rounds = { converge: [], review: [] };
  for (const line of logSection(text, 'Rounds')) {
    const match = /^(converge|review)\s+(\d+):\s*(.*)$/i.exec(line.replace(/^[-*]\s*/, ''));
    if (!match) continue;
    const kind = match[1].toLowerCase();
    const result = match[3];
    rounds[kind].push({
      round: Number(match[2]),
      result,
      // A review round is clear only when it found nothing: fixes made in a
      // round are reviewed again, within the lane's cap.
      clear: kind === 'converge' ? /\bno gap\b/i.test(result) : /\b(?:0|no) findings\b/i.test(result),
    });
  }
  return rounds;
}

function criteriaOf(text) {
  const section = /^##?\s+(?:Acceptance Criteria|Check)\s*$([\s\S]*?)(?=^#{1,2}\s|(?![\s\S]))/im.exec(text);
  const body = section ? section[1] : '';
  const ticked = (body.match(/^\s*-\s*\[x\]/gim) ?? []).length;
  const open = (body.match(/^\s*-\s*\[ \]/gm) ?? []).length;
  return { ticked, open, total: ticked + open };
}

function ticketFile(effortDir, id) {
  const dir = path.join(effortDir, 'tickets');
  if (!fs.existsSync(dir)) return null;
  const want = String(id).replace(/\.md$/, '');
  const name = fs.readdirSync(dir).find((entry) =>
    entry.endsWith('.md') && (entry === `${want}.md` || entry.startsWith(`${want.split('-')[0]}-`)));
  return name ? path.join(dir, name) : null;
}

// --- finding the effort -------------------------------------------------------------

function effortBranches(where) {
  const out = git(where.repo, ['for-each-ref', '--format=%(refname:short)', 'refs/heads']) ?? '';
  return out.split(/\r?\n/).filter((name) => name && !name.includes('/')).filter((name) =>
    git(where.repo, ['cat-file', '-e', `${name}:${where.aepRel}/efforts/${name}/spec.md`], { allowFail: true }) !== null);
}

function resolveEffort(where, wanted) {
  const branches = effortBranches(where);
  if (branches.includes(wanted)) return wanted;
  const byNumber = branches.filter((name) => name.startsWith(`${wanted}-`));
  if (byNumber.length === 1) return byNumber[0];
  if (byNumber.length > 1) throw new Stop(`${wanted} names more than one effort: ${byNumber.join(', ')}`);
  throw new Stop(`no effort branch named ${wanted}. Open it first: aep open <slug> --lane <lane>`);
}

/** The run surface for an effort, entered or created; never a second one. */
function enterSurface(where, effort, scope) {
  if (scope && scope.surface.kind === 'run' && scope.surface.effort === effort) {
    return { surface: where.repo, entered: 'here' };
  }
  if (scope && scope.isolation.kind === 'worktree' && scope.surface.kind === 'runtime') {
    const branch = git(where.repo, ['rev-parse', '--abbrev-ref', 'HEAD'], { allowFail: true });
    if (branch === effort) return { surface: where.repo, entered: 'runtime' };
  }
  const surface = runSurface(where, effort);
  const trees = worktreeList(where.repo);
  const atSurface = trees.find((tree) => same(tree.path, surface));
  const holder = trees.find((tree) => tree.branch === effort && !same(tree.path, surface));
  if (holder) {
    throw new Stop(`the ${effort} branch is held by another surface at ${holder.path}. A claim held elsewhere is not taken`, {
      held: holder.path,
    });
  }
  if (atSurface) {
    if (atSurface.branch === effort) return { surface, entered: 're-entered' };
    if (atSurface.detached) {
      git(surface, ['switch', '--quiet', effort]);
      return { surface, entered: 're-entered' };
    }
    throw new Stop(`${rel(where, surface)} holds ${atSurface.branch}, not ${effort}`);
  }
  if (fs.existsSync(surface)) {
    throw new Stop(`${rel(where, surface)} exists but is not a worktree of this repository. Inspect it, then remove it`);
  }
  git(where.main, ['worktree', 'add', '--quiet', surface, effort]);
  return { surface, entered: 'created' };
}

// --- commands --------------------------------------------------------------------------

function nextNumber(where) {
  const numbers = [];
  const take = (name) => {
    const match = /^(\d+)-/.exec(name);
    if (match) numbers.push(Number(match[1]));
  };
  for (const tree of [where.main, where.repo]) {
    const dir = path.join(aepIn(tree, where), 'efforts');
    if (fs.existsSync(dir)) fs.readdirSync(dir).forEach(take);
  }
  (git(where.repo, ['for-each-ref', '--format=%(refname:short)', 'refs/heads']) ?? '').split(/\r?\n/).forEach(take);
  const worktrees = path.join(aepIn(where.main, where), 'worktrees');
  if (fs.existsSync(worktrees)) fs.readdirSync(worktrees).forEach(take);
  return numbers.length > 0 ? Math.max(...numbers) + 1 : 1;
}

function open(root, args) {
  const where = locate(root);
  const settings = readSettings(root);
  const slug = args.positional[0];
  const lane = args.flags.lane;
  if (!slug) throw new Stop('usage: aep open <slug> --lane <quick|standard|full>');
  if (!LANES.includes(lane)) throw new Stop(`--lane must be one of: ${LANES.join(', ')}`);

  const existing = effortBranches(where).find((name) => name.replace(/^\d+-/, '') === slug);
  if (existing) {
    const { surface, entered } = enterSurface(where, existing, null);
    const spec = readSpec(path.join(aepIn(surface, where), 'efforts', existing));
    return {
      effort: existing, lane: spec.lane, surface, opened: 'already', entered,
      summary: `${existing} (${spec.lane}) is already open; ${entered} its surface at ${rel(where, surface)}`,
    };
  }

  // The draft is written to scratch, because nothing may be written in the main
  // checkout before a surface is taken. A 3.x draft under efforts/ is still found.
  const candidates = [
    path.join(root, 'scratch', slug),
    path.join(root, 'efforts', `xxxx-${slug}`),
  ];
  const draft = candidates.find((dir) => fs.existsSync(path.join(dir, 'spec.md')));
  if (!draft) throw new Stop(`no draft spec at ${toPosix(path.dirname(root), path.join(candidates[0], 'spec.md'))}. Write it there first`);

  if (settings.tracker !== 'none'
    && git(where.repo, ['ls-remote', '--heads', 'origin', `${args.flags.number ?? ''}-${slug}`], { allowFail: true })) {
    throw new Stop(`a remote branch for ${slug} already exists. A claim held elsewhere is not taken`);
  }
  const number = args.flags.number ? Number(args.flags.number) : nextNumber(where);
  if (!Number.isInteger(number) || number < 1) throw new Stop('--number must be a positive integer');
  const effort = `${number}-${slug}`;
  if (branchExists(where.repo, effort)) throw new Stop(`a branch named ${effort} already exists. A claim held elsewhere is not taken`);

  const base = settings.stack
    ? git(where.repo, ['rev-parse', '--abbrev-ref', 'HEAD'])
    : resolveBase(where.repo);
  if (!base || base === 'HEAD') throw new Stop('no base to branch from: no default branch was found, and HEAD is detached');

  // A surface the runtime supplied is the run's already: the branch is created
  // in it, and no second surface is taken. Anywhere else, branch and surface
  // are created together, so the branch never exists unheld.
  const scope = resolveScope(root);
  const runtime = scope?.surface.kind === 'runtime';
  let surface;
  if (runtime) {
    surface = where.repo;
    const dirty = dirtyPaths(surface);
    if (dirty.length > 0) throw new Stop(`this surface has uncommitted changes: ${dirty.join(', ')}. Commit, move, or discard them, then open again`);
    git(surface, ['switch', '--quiet', '-c', effort, base]);
  } else {
    surface = runSurface(where, effort);
    if (fs.existsSync(surface)) throw new Stop(`${rel(where, surface)} already exists. Inspect it, then remove it`);
    git(where.main, ['worktree', 'add', '--quiet', '-b', effort, surface, base]);
  }

  const into = path.join(aepIn(surface, where), 'efforts', effort);
  fs.mkdirSync(path.dirname(into), { recursive: true });
  fs.cpSync(draft, into, { recursive: true });
  const specFile = path.join(into, 'spec.md');
  if (!fs.existsSync(specFile)) throw new Stop(`the draft has no spec.md: ${draft}`);
  fs.writeFileSync(specFile, setField(fs.readFileSync(specFile, 'utf8'), 'lane', lane), 'utf8');
  ensureLog(into, effort);
  const basis = settings.stack ? `${base}, the current branch, because rules/version-control sets stack: true` : base;
  appendToLog(into, effort, 'Recorded', `- opened in the ${lane} lane, from ${basis}`);
  writeIndex(aepIn(surface, where));
  git(surface, ['add', '-A']);
  git(surface, ['commit', '--quiet', '-m', `docs(${effort}): open the effort`]);
  fs.rmSync(draft, { recursive: true, force: true });
  if (draft === candidates[1]) writeIndex(root);

  const setup = warm(where, settings, surface);
  const tracker = settings.tracker === 'none' ? [] : [
    `create the issue from ${where.aepRel}/efforts/${effort}/spec.md, and rename the effort to the issue number if it differs`,
    `push ${effort} and open a draft pull request carrying the run log`,
  ];
  return {
    effort, lane, number, base, branch: effort, surface, opened: 'created', setup, tracker,
    summary: runtime
      ? `opened ${effort} (${lane}) in the surface the runtime supplied, from ${basis}; no second surface taken`
      : `opened ${effort} (${lane}) on a new surface at ${rel(where, surface)}, from ${basis}`,
  };
}

function laneRules(lane) {
  return LANE_RULES[lane] ?? LANE_RULES.full;
}

function plan(where, effortDir, spec) {
  const rules = laneRules(spec.lane);
  const logText = fs.existsSync(logFile(effortDir)) ? fs.readFileSync(logFile(effortDir), 'utf8') : '';
  const rounds = readRounds(logText);
  const roundState = {
    converge: { done: rounds.converge.length, cap: rules.converge, clear: rounds.converge.at(-1)?.clear ?? false },
    review: { done: rounds.review.length, cap: rules.review, clear: rounds.review.at(-1)?.clear ?? false },
  };

  let ready = [];
  let blocked = {};
  let parked = [];
  let unresolved = 0;
  if (rules.tickets && fs.existsSync(path.join(effortDir, 'tickets'))) {
    const tickets = readTickets(path.dirname(path.dirname(effortDir)), path.basename(effortDir));
    const result = frontier(tickets, []);
    ready = result.ready.map((ticket) => `${ticket.id}-${ticket.slug}`);
    blocked = Object.fromEntries(result.blocked.map((ticket) => [`${ticket.id}-${ticket.slug}`, ticket.waiting]));
    parked = result.parked.map((ticket) => `${ticket.id}-${ticket.slug}`);
    unresolved = result.ready.length + result.blocked.length + result.parked.length;
  }

  let next;
  if (spec.status === 'implemented') next = 'close';
  else if (!rules.tickets) next = 'build';
  else if (ready.length > 0) next = 'build';
  else if (unresolved > 0) next = 'blocked';
  else if (!roundState.converge.clear && roundState.converge.done < roundState.converge.cap) next = 'converge';
  else if (roundState.review.cap > 0 && !roundState.review.clear && roundState.review.done < roundState.review.cap) next = 'review';
  else next = 'close';

  const waveOf = rules.children && ready.length >= 2 ? 'dispatch' : 'here';
  return { ready, blocked, parked, rounds: roundState, next, build: waveOf, needsYou: logSection(logText, 'Needs you') };
}

function start(root, args) {
  const where = locate(root);
  const settings = readSettings(root);
  const scope = resolveScope(root);
  if (!scope) throw new Stop('git could not read this tree');

  if (scope.role === 'implementer') {
    const effortDir = path.join(root, 'efforts', scope.surface.effort);
    const file = ticketFile(effortDir, scope.surface.ticket);
    return {
      role: 'implementer', effort: scope.surface.effort, ticket: scope.surface.ticket, surface: where.repo,
      ticket_file: file ? toPosix(path.dirname(root), file) : null, dirty: dirtyPaths(where.repo),
      summary: `implementer for ${scope.surface.ticket} of ${scope.surface.effort}: build that ticket here, integrate nothing`,
    };
  }

  let wanted = args.positional[0] ?? null;
  let onlyTicket = null;
  if (wanted && wanted.includes('/')) [wanted, onlyTicket] = wanted.split('/');
  if (!wanted) {
    if (scope.claim.length === 1) [wanted] = scope.claim;
    else if (scope.claim.length > 1) throw new Stop(`this branch claims more than one effort: ${scope.claim.join(', ')}. Name one`, { claim: scope.claim });
    else throw new Stop('nothing to start: name an effort, or open one with aep open');
  }
  const effort = resolveEffort(where, wanted);
  const { surface, entered } = enterSurface(where, effort, scope);
  const effortDir = path.join(aepIn(surface, where), 'efforts', effort);
  const spec = readSpec(effortDir);
  const dirty = dirtyPaths(surface);
  const marker = checkMarker(aepIn(surface, where));
  const state = plan(where, effortDir, spec);
  if (onlyTicket) {
    const match = state.ready.find((stem) => stem === onlyTicket || stem.startsWith(`${onlyTicket}-`));
    state.ready = match ? [match] : [];
    state.build = 'here';
  }
  const setup = dirty.length === 0 ? warm(where, settings, surface, { whenChanged: true }) : { ran: false, reason: 'dirty' };
  const stop = dirty.length > 0
    ? `the surface has uncommitted changes nobody can attribute: ${dirty.join(', ')}. Commit, move, or discard them, then start again`
    : null;
  const claim = scope.claim.length ? scope.claim.join(' ') : 'unscoped';
  const isolation = `${scope.isolation.kind}, ${scope.isolation.enforcement}`;
  const parts = [`${effort} (${spec.lane}, ${spec.status})`, `claim ${claim}`, `isolation ${isolation}`, `${entered} ${dirty.length ? 'dirty' : 'clean'} surface`];
  if (state.ready.length) parts.push(`${state.ready.length} ready`);
  if (Object.keys(state.blocked).length) parts.push(`${Object.keys(state.blocked).length} blocked`);
  parts.push(`next: ${stop ? 'stop' : state.next}`);
  return {
    effort, lane: spec.lane, status: spec.status, surface, entered, role: 'orchestrator', claim: scope.claim, isolation,
    dirty, drift: !marker.matches, marker: marker.message,
    frontier: state.ready, blocked: state.blocked, parked: state.parked, wave: state.build,
    rounds: state.rounds, next: stop ? 'stop' : state.next, needs_you: state.needsYou,
    tracker: settings.tracker, setup, stop,
    summary: parts.join(', '),
  };
}

function dispatch(root, args) {
  const where = locate(root);
  const settings = readSettings(root);
  const [effortArg, ...ids] = args.positional;
  if (!effortArg || ids.length === 0) throw new Stop('usage: aep dispatch <effort> <ticket>...');
  const effort = resolveEffort(where, effortArg);
  const surface = runSurface(where, effort);
  const effortDir = path.join(aepIn(surface, where), 'efforts', effort);
  if (!fs.existsSync(effortDir)) throw new Stop(`${effort} has no run surface yet. Run aep start ${effort} first`);
  const tip = git(surface, ['rev-parse', 'HEAD']);
  const trees = worktreeList(where.repo);

  const children = [];
  for (const id of ids) {
    const file = ticketFile(effortDir, id);
    if (!file) throw new Stop(`${effort} has no ticket ${id}`);
    const stem = path.basename(file, '.md');
    const branch = ticketBranch(effort, stem);
    const at = ticketSurface(where, effort, stem);
    const existing = trees.find((tree) => tree.branch === branch);
    if (existing && same(existing.path, at)) {
      children.push({ ticket: stem, branch, surface: at, created: false });
      continue;
    }
    if (existing || branchExists(where.repo, branch)) {
      children.push({ ticket: stem, branch, surface: existing?.path ?? null, held: true });
      continue;
    }
    if (settings.tracker !== 'none'
      && git(where.repo, ['ls-remote', '--heads', 'origin', branch], { allowFail: true })) {
      children.push({ ticket: stem, branch, held: 'remote' });
      continue;
    }
    git(where.main, ['worktree', 'add', '--quiet', '-b', branch, at, tip]);
    children.push({ ticket: stem, branch, surface: at, created: true });
  }
  for (const child of children) {
    if (child.surface && !child.held) child.setup = warm(where, settings, child.surface);
  }
  const held = children.filter((child) => child.held);
  return {
    effort, base: tip, children,
    summary: `${children.length - held.length} surface(s) ready for ${effort}${held.length ? `; held elsewhere, not taken: ${held.map((c) => c.ticket).join(', ')}` : ''}`,
  };
}

function commitAll(surface, message, { amend = false } = {}) {
  git(surface, ['add', '-A']);
  const staged = git(surface, ['diff', '--cached', '--name-only']);
  if (!staged && !amend) return null;
  git(surface, ['commit', '--quiet', ...(amend ? ['--amend'] : []), '-m', message]);
  return git(surface, ['rev-parse', '--short', 'HEAD']);
}

function land(root, args) {
  const where = locate(root);
  const [effortArg, ticketArg] = args.positional;
  const message = args.flags.message;
  if (!effortArg) throw new Stop('usage: aep land <effort> [<ticket>] --message <text>');
  const effort = resolveEffort(where, effortArg);
  const surface = runSurface(where, effort);
  const scope = resolveScope(aepIn(fs.existsSync(surface) ? surface : where.repo, where));
  const here = scope && scope.surface.kind === 'runtime' ? where.repo : surface;
  const effortDir = path.join(aepIn(here, where), 'efforts', effort);
  const spec = readSpec(effortDir);
  const rules = laneRules(spec.lane);

  if (!ticketArg) {
    if (rules.tickets) throw new Stop(`${effort} is in the ${spec.lane} lane: land one ticket at a time`);
    const checks = criteriaOf(spec.body);
    if (checks.total === 0) throw new Stop('the spec\'s Check section lists nothing to verify');
    if (checks.open > 0) throw new Stop(`${checks.open} of ${checks.total} Check items are not ticked. Verify each and tick it with what verified it`);
    if (spec.status === 'implemented' && dirtyPaths(here).length === 0) {
      return { effort, landed: git(here, ['rev-parse', '--short', 'HEAD']), already: true, summary: `${effort} already landed` };
    }
    if (!message) throw new Stop('--message is required');
    fs.writeFileSync(spec.file, setField(fs.readFileSync(spec.file, 'utf8'), 'status', 'implemented'), 'utf8');
    appendToLog(effortDir, effort, 'Ledger', `[x] spec ${effort.replace(/^\d+-/, '')} ${checks.ticked}/${checks.total}`);
    writeIndex(aepIn(here, where));
    // The quick lane lands as one commit by construction: whatever the branch
    // gathered since it forked (the opening commit, a revised Check item) is
    // folded into the one commit that lands, never left beside it.
    const base = resolveBase(where.repo);
    const fork = base ? git(here, ['merge-base', base, 'HEAD'], { allowFail: true }) : '';
    const own = fork ? Number(git(here, ['rev-list', '--count', `${fork}..HEAD`])) : 0;
    if (own > 1) git(here, ['reset', '--quiet', '--soft', fork]);
    const sha = commitAll(here, message, { amend: own === 1 });
    stampMarker(aepIn(here, where), args.flags.session ?? null);
    return {
      effort, landed: sha, amended: own >= 1, ledger: `[x] spec ${checks.ticked}/${checks.total}`,
      summary: `landed ${effort} as one commit ${sha}`,
    };
  }

  const file = ticketFile(effortDir, ticketArg);
  if (!file) throw new Stop(`${effort} has no ticket ${ticketArg}`);
  const stem = path.basename(file, '.md');
  const branch = ticketBranch(effort, stem);
  const child = ticketSurface(where, effort, stem);
  const childTree = worktreeList(where.repo).find((tree) => tree.branch === branch);
  const ticket = readArtifact(file);

  const release = () => {
    const released = {};
    if (childTree) {
      if (dirtyPaths(childTree.path).length > 0) {
        throw new Stop(`the child surface for ${stem} has uncommitted work: ${dirtyPaths(childTree.path).join(', ')}. Releasing it would lose that work`);
      }
      git(where.main, ['worktree', 'remove', childTree.path]);
      released.surface = childTree.path;
    }
    if (branchExists(where.repo, branch)) {
      git(where.main, ['branch', '-D', branch]);
      released.branch = branch;
    }
    return released;
  };

  if (ticket.fields.status === 'resolved' && dirtyPaths(here).length === 0) {
    const released = release();
    stampMarker(aepIn(here, where), args.flags.session ?? null);
    return { effort, ticket: stem, already: true, released, summary: `${stem} was already landed; released what it still held` };
  }

  // Integrate the child's commits, squashed, unless a conflict is already resolved here.
  const squashing = fs.existsSync(path.join(git(here, ['rev-parse', '--absolute-git-dir']), 'SQUASH_MSG'));
  if (branchExists(where.repo, branch) && !squashing) {
    const ahead = Number(git(here, ['rev-list', '--count', `HEAD..${branch}`]));
    if (ahead > 0) {
      if (childTree && dirtyPaths(childTree.path).length > 0) {
        throw new Stop(`the child for ${stem} left uncommitted work: ${dirtyPaths(childTree.path).join(', ')}`);
      }
      const merged = git(here, ['merge', '--squash', '--no-commit', branch], { allowFail: true });
      if (merged === null) {
        const conflicts = (git(here, ['diff', '--name-only', '--diff-filter=U']) ?? '').split(/\r?\n/).filter(Boolean);
        throw new Stop(`integrating ${stem} conflicts in: ${conflicts.join(', ')}. Resolve them here, then run land again`, { conflicts });
      }
    }
  }
  const unmerged = (git(here, ['diff', '--name-only', '--diff-filter=U']) ?? '').split(/\r?\n/).filter(Boolean);
  if (unmerged.length > 0) throw new Stop(`unresolved conflicts: ${unmerged.join(', ')}`, { conflicts: unmerged });

  const current = fs.readFileSync(file, 'utf8');
  const checks = criteriaOf(readArtifact(file).body);
  if (checks.total === 0) throw new Stop(`${stem} lists no acceptance criteria`);
  if (checks.open > 0) {
    throw new Stop(`${checks.open} of ${checks.total} criteria of ${stem} are not ticked. Verify each and tick it with what verified it, or park the ticket`);
  }
  if (!message) throw new Stop('--message is required');
  fs.writeFileSync(file, setField(current, 'status', 'resolved'), 'utf8');
  const ledger = `[x] ${stem.replace(/^(\d+)-/, '$1 ')} ${checks.ticked}/${checks.total}`;
  appendToLog(effortDir, effort, 'Ledger', ledger);
  writeIndex(aepIn(here, where));
  const sha = commitAll(here, message);
  const released = release();
  stampMarker(aepIn(here, where), args.flags.session ?? null);
  return { effort, ticket: stem, landed: sha, ledger, released, summary: `landed ${stem} as ${sha}` };
}

function close(root, args) {
  const where = locate(root);
  const settings = readSettings(root);
  const [effortArg] = args.positional;
  if (!effortArg) throw new Stop('usage: aep close <effort> [--stop <reason>]');
  const effort = resolveEffort(where, effortArg);
  const surface = runSurface(where, effort);
  const runtime = !fs.existsSync(surface);
  const here = runtime ? where.repo : surface;
  const effortDir = path.join(aepIn(here, where), 'efforts', effort);
  const spec = readSpec(effortDir);
  const rules = laneRules(spec.lane);
  const stopReason = args.flags.stop ?? null;
  const friction = [].concat(args.flags.friction ?? []).slice(0, 3);

  if (!stopReason) {
    const state = plan(where, effortDir, spec);
    const open = [...state.ready, ...Object.keys(state.blocked), ...state.parked];
    if (open.length > 0) throw new Stop(`unresolved tickets remain: ${open.join(', ')}. Build them, or close with --stop`);
    if (!rules.tickets && spec.status !== 'implemented') throw new Stop(`${effort} has not landed. Run aep land ${effort} first`);
  }
  const dirty = dirtyPaths(here).filter((file) => !file.startsWith(`${where.aepRel}/efforts/${effort}/`)
    && file !== `${where.aepRel}/friction.md` && file !== `${where.aepRel}/index.md`);
  if (dirty.length > 0) throw new Stop(`uncommitted changes outside the effort's records: ${dirty.join(', ')}`);

  if (stopReason) appendToLog(effortDir, effort, 'Needs you', `- stopped: ${stopReason}`);
  else if (spec.status !== 'implemented') {
    fs.writeFileSync(spec.file, setField(fs.readFileSync(spec.file, 'utf8'), 'status', 'implemented'), 'utf8');
  }
  if (friction.length > 0) {
    const file = path.join(aepIn(here, where), 'friction.md');
    if (!fs.existsSync(file)) {
      fs.writeFileSync(file, '---\nuse-when: "deciding what to change in AEP, between projects"\n---\n\n# Friction\n\n', 'utf8');
    }
    const stamp = new Date().toISOString().slice(0, 10);
    fs.appendFileSync(file, friction.map((line) => `- ${stamp} ${effort}: ${line}\n`).join(''), 'utf8');
  }
  writeIndex(aepIn(here, where));
  const amend = !rules.tickets && !stopReason;
  const sha = commitAll(here, stopReason ? `docs(${effort}): stopped` : amend
    ? git(here, ['log', '-1', '--format=%B'])
    : `docs(${effort}): close`, { amend: amend && dirtyPaths(here).length > 0 });
  stampMarker(aepIn(here, where), args.flags.session ?? null);

  const outcome = { effort, closed: stopReason ? 'stopped' : 'clean', commit: sha };
  if (runtime) {
    outcome.surface = 'supplied by the runtime; nothing to release';
  } else {
    if (!worktreeList(where.repo).find((tree) => same(tree.path, surface))?.detached) {
      git(surface, ['switch', '--quiet', '--detach']);
    }
    outcome.detached = true;
    if (stopReason) {
      outcome.kept = surface;
    } else {
      const removed = git(where.main, ['worktree', 'remove', surface], { allowFail: true });
      outcome.removed = removed !== null;
      if (removed === null) outcome.remove_by_hand = `git worktree remove "${surface}"  (run from ${where.main})`;
      // The effort's directory under worktrees/ held only this surface and any
      // children, all released by now. Left empty, it is litter.
      const holder = path.dirname(surface);
      if (removed !== null && fs.existsSync(holder) && fs.readdirSync(holder).length === 0) fs.rmdirSync(holder);
    }
  }
  outcome.tracker = settings.tracker === 'none' ? [] : stopReason
    ? ['mirror the run log into the pull request; leave it a draft']
    : ['mirror the run log into the pull request', 'mark the pull request ready for review'];
  outcome.summary = stopReason
    ? `stopped ${effort}: branch released, surface kept at ${rel(where, surface)}`
    : `closed ${effort}: branch released${outcome.removed ? ', surface removed' : ''}`;
  return outcome;
}

function raise(root, args) {
  const where = locate(root);
  const [effortArg, lane] = args.positional;
  if (!effortArg || !LANES.includes(lane)) throw new Stop(`usage: aep raise <effort> <${LANES.join('|')}> --reason <text>`);
  const effort = resolveEffort(where, effortArg);
  const surface = runSurface(where, effort);
  const here = fs.existsSync(surface) ? surface : where.repo;
  const effortDir = path.join(aepIn(here, where), 'efforts', effort);
  const spec = readSpec(effortDir);
  const from = LANES.indexOf(spec.lane);
  const to = LANES.indexOf(lane);
  if (to < from) throw new Stop(`lanes only go up: ${effort} is ${spec.lane}, and ${lane} is lower`);
  if (to === from) return { effort, lane, raised: false, summary: `${effort} is already ${lane}` };
  fs.writeFileSync(spec.file, setField(fs.readFileSync(spec.file, 'utf8'), 'lane', lane), 'utf8');
  appendToLog(effortDir, effort, 'Recorded', `- lane raised ${spec.lane} -> ${lane}: ${args.flags.reason ?? 'no reason given'}`);
  return { effort, from: spec.lane, lane, raised: true, summary: `raised ${effort} from ${spec.lane} to ${lane}` };
}

const RECORDS = {
  converge: 'Rounds',
  review: 'Rounds',
  note: 'Recorded',
  'needs-you': 'Needs you',
};

/**
 * Writes one line to the effort's log and commits only that file, so the
 * surface stays clean for the next `start`. A round is numbered here, and a
 * round past the lane's cap is refused.
 */
function record(root, args) {
  const where = locate(root);
  const [effortArg] = args.positional;
  const kinds = Object.keys(RECORDS).filter((kind) => args.flags[kind] !== undefined);
  if (!effortArg || kinds.length !== 1) {
    throw new Stop('usage: aep record <effort> --converge|--review|--note|--needs-you "<line>"');
  }
  const [kind] = kinds;
  const text = String(args.flags[kind]).trim();
  if (!text) throw new Stop(`--${kind} needs a line`);
  const effort = resolveEffort(where, effortArg);
  const surface = runSurface(where, effort);
  const here = fs.existsSync(surface) ? surface : where.repo;
  const effortDir = path.join(aepIn(here, where), 'efforts', effort);
  const spec = readSpec(effortDir);
  const file = ensureLog(effortDir, effort);

  let line;
  if (kind === 'converge' || kind === 'review') {
    const cap = laneRules(spec.lane)[kind];
    const done = readRounds(fs.readFileSync(file, 'utf8'))[kind].length;
    if (done >= cap) {
      throw new Stop(`${effort} is ${spec.lane}: at most ${cap} ${kind} round(s), and ${done} ran. Close it, with --stop where anything is open`);
    }
    line = `${kind} ${done + 1}: ${text}`;
  } else {
    line = `- ${text}`;
  }
  appendToLog(effortDir, effort, RECORDS[kind], line);
  const relLog = path.relative(here, file).replace(/\\/g, '/');
  git(here, ['add', '--', relLog]);
  // A short summary, and the whole line in the body: a note can run long.
  const subject = kind === 'converge' || kind === 'review' ? line.slice(0, line.indexOf(':')) : `record ${kind}`;
  git(here, ['commit', '--quiet', '-m', `docs(${effort}): ${subject}`, '-m', line.replace(/^- /, ''), '--', relLog]);
  return { effort, section: RECORDS[kind], line, summary: `recorded in ${effort}: ${line}` };
}

// --- status ------------------------------------------------------------------------------

function showAt(repo, ref, file) {
  return git(repo, ['show', `${ref}:${file}`], { allowFail: true });
}

function frontmatterOf(text) {
  const match = /^---\r?\n([\s\S]*?)\r?\n---/.exec(text ?? '');
  return match ? parseFrontmatterBlock(match[1]).fields : {};
}

export function boardFor(repoDir) {
  const root = path.join(repoDir, '.aep');
  const where = locate(root);
  const base = resolveBase(where.repo);
  const trees = worktreeList(where.repo);
  const efforts = [];
  for (const branch of effortBranches(where)) {
    const dir = `${where.aepRel}/efforts/${branch}`;
    const specText = showAt(where.repo, branch, `${dir}/spec.md`);
    const fields = frontmatterOf(specText);
    const lane = LANES.includes(fields.lane) ? fields.lane : 'full';
    const files = (git(where.repo, ['ls-tree', '-r', '--name-only', branch, `${dir}/tickets/`], { allowFail: true }) ?? '')
      .split(/\r?\n/).filter((name) => name.endsWith('.md'));
    const tickets = files.map((file) => {
      const front = frontmatterOf(showAt(where.repo, branch, file));
      const stem = path.posix.basename(file, '.md');
      return { id: stem.split('-')[0], slug: stem.replace(/^\d+-/, ''), status: front.status, blockedBy: (front['blocked-by'] ?? []).map(String) };
    });
    let ready = [];
    let blocked = [];
    try {
      const result = frontier(tickets, []);
      ready = result.ready.map((ticket) => ticket.id);
      blocked = result.blocked.map((ticket) => ticket.id);
    } catch {
      // A broken edge is the validator's to report, not the board's.
    }
    const logText = showAt(where.repo, branch, `${dir}/log.md`) ?? '';
    const holder = trees.find((tree) => tree.branch === branch);
    const kept = path.join(aepIn(where.main, where), 'worktrees', branch, '_run');
    const merged = base ? git(where.repo, ['merge-base', '--is-ancestor', branch, base], { allowFail: true }) !== null : false;
    const waiting = [...logSection(logText, 'Needs you')];
    if (fields.status === 'implemented' && !merged) waiting.push('ready to merge');
    if (!holder && fs.existsSync(kept) && fields.status !== 'implemented') waiting.push(`stopped; surface kept at ${rel(where, kept)}`);
    efforts.push({
      effort: branch,
      lane,
      status: merged ? 'merged' : (fields.status ?? 'unknown'),
      tickets: { total: tickets.length, resolved: tickets.filter((t) => t.status !== 'open').length, ready, blocked },
      surface: holder ? rel(where, holder.path) : null,
      last: git(where.repo, ['log', '-1', '--format=%h %s (%cr)', branch]),
      waiting: merged ? [] : waiting,
    });
  }
  return { repo: where.main, efforts: efforts.filter((effort) => effort.status !== 'merged') };
}

function renderBoard(boards) {
  const out = [];
  const waiting = [];
  for (const board of boards) {
    out.push(`${board.repo}`);
    if (board.efforts.length === 0) out.push('  no open efforts');
    for (const effort of board.efforts) {
      const tickets = effort.tickets.total
        ? `${effort.tickets.resolved}/${effort.tickets.total} tickets${effort.tickets.ready.length ? `, ready ${effort.tickets.ready.join(' ')}` : ''}`
        : 'no tickets';
      out.push(`  ${effort.effort.padEnd(28)} ${effort.lane.padEnd(8)} ${effort.status.padEnd(11)} ${tickets}`);
      out.push(`  ${''.padEnd(28)} ${effort.surface ? `surface ${effort.surface}` : 'no surface'}; last ${effort.last}`);
      for (const item of effort.waiting) waiting.push(`${path.basename(board.repo)}/${effort.effort}: ${item.replace(/^-\s*/, '')}`);
    }
    out.push('');
  }
  out.push(waiting.length ? 'Waiting on you:' : 'Nothing is waiting on you.');
  for (const item of waiting) out.push(`  ${item}`);
  return `${out.join('\n')}\n`;
}

function status(root, args) {
  const boards = [];
  if (args.flags.repos) {
    const dir = path.resolve(args.flags.repos);
    for (const entry of fs.readdirSync(dir, { withFileTypes: true }).sort((a, b) => (a.name < b.name ? -1 : 1))) {
      const repo = path.join(dir, entry.name);
      if (!entry.isDirectory() || !fs.existsSync(path.join(repo, '.aep', 'protocol.md'))) continue;
      try {
        boards.push(boardFor(repo));
      } catch (error) {
        boards.push({ repo, error: error.message, efforts: [] });
      }
    }
  } else {
    boards.push(boardFor(locate(root).main));
  }
  return { boards, text: renderBoard(boards) };
}

function check(root) {
  const validation = validateTree(root);
  const result = runChecks(root);
  return {
    ok: validation.failures.length === 0 && result.ok,
    validate: validation.failures,
    budgets_over: result.budgets.over.map((entry) => `${entry.file} ${entry.words}/${entry.limit}`),
    hot_path: `${result.budgets.hotPath.words}/${result.budgets.hotPath.limit}`,
    why: result.why.map((hit) => `${hit.file}:${hit.line}`),
    outside: result.outside.map((hit) => `${hit.file}:${hit.line} ${hit.wording}`),
    summary: `validate ${validation.failures.length} failure(s); ${result.budgets.over.length} over budget; ${result.why.length} rationale; ${result.outside.length} outside-write wording`,
  };
}

// --- entry -----------------------------------------------------------------------------

export function parseArgs(argv) {
  const positional = [];
  const flags = {};
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (!arg.startsWith('--')) {
      positional.push(arg);
      continue;
    }
    const name = arg.slice(2);
    const boolean = ['json'].includes(name);
    const value = boolean ? true : argv[i + 1];
    if (!boolean) i += 1;
    if (name === 'friction') flags.friction = [...(flags.friction ?? []), value];
    else flags[name] = value;
  }
  return { positional, flags };
}

const COMMANDS = { status, open, start, dispatch, land, close, raise, record, check };

export function run(argv, { cwdRoot = null } = {}) {
  const [command, ...rest] = argv;
  const args = parseArgs(rest);
  if (!COMMANDS[command]) {
    return { code: 2, output: { stop: `unknown command "${command ?? ''}". Expected: ${Object.keys(COMMANDS).join(', ')}` } };
  }
  const root = cwdRoot ?? resolveAepRoot(args.flags.root ?? null, null);
  if (!root) return { code: 2, output: { stop: 'no .aep/ found here. Run from inside a repository that has one' } };
  try {
    const output = COMMANDS[command](root, args);
    return { code: output.stop ? 1 : 0, output };
  } catch (error) {
    if (error instanceof Stop) {
      return { code: 1, output: { stop: error.message, ...error.extra, summary: `stopped: ${error.message}` } };
    }
    throw error;
  }
}

function main() {
  const argv = process.argv.slice(2);
  const { code, output } = run(argv);
  if (argv[0] === 'status' && !argv.includes('--json') && output.text) process.stdout.write(output.text);
  else {
    const { text, ...rest } = output;
    process.stdout.write(`${JSON.stringify(argv[0] === 'status' ? rest : output, null, 2)}\n`);
  }
  process.exit(code);
}

if (process.argv[1] && fileURLToPath(import.meta.url) === path.resolve(process.argv[1])) main();
