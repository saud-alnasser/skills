// The fixture every scenario starts from: a small Node project with AEP
// installed from a chosen `src/`, committed on `main`.
//
// Everything here writes under a directory the caller made with the temp API.

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

export function git(repo, ...args) {
  return execFileSync('git', args, { cwd: repo, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
}

export function tryGit(repo, ...args) {
  try {
    return git(repo, ...args);
  } catch {
    return null;
  }
}

export function write(root, rel, content) {
  const file = path.join(root, ...rel.split('/'));
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, content, 'utf8');
}

export function read(root, rel) {
  const file = path.join(root, ...rel.split('/'));
  return fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : null;
}

const PROJECT = {
  'package.json': `${JSON.stringify({
    name: 'textkit',
    version: '1.0.0',
    type: 'module',
    main: 'src/index.js',
    scripts: { test: 'node --test' },
  }, null, 2)}\n`,
  'README.md': '# textkit\n\nSmall text helpers. Call `slugify` to recieve a URL-safe slug.\n',
  'src/index.js': "export { slugify } from './slugify.js';\n",
  'src/slugify.js': [
    '/** Lowercases text and joins its words with hyphens. */',
    'export function slugify(text) {',
    "  return text.trim().toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');",
    '}',
    '',
  ].join('\n'),
  'src/internal/dates.js': [
    '/** Formats a date for display. Internal: report and cli both use it. */',
    'export function formatDate(date) {',
    '  return `${date.getUTCDate()}/${date.getUTCMonth() + 1}/${date.getUTCFullYear()}`;',
    '}',
    '',
  ].join('\n'),
  'src/report.js': [
    "import { formatDate } from './internal/dates.js';",
    '',
    'export function reportLine(title, date) {',
    '  return `${title} (${formatDate(date)})`;',
    '}',
    '',
  ].join('\n'),
  'src/cli.js': [
    "import { formatDate } from './internal/dates.js';",
    '',
    'export function cliStamp(date) {',
    '  return `[${formatDate(date)}]`;',
    '}',
    '',
  ].join('\n'),
  'test/slugify.test.js': [
    "import test from 'node:test';",
    "import assert from 'node:assert/strict';",
    "import { slugify } from '../src/slugify.js';",
    '',
    "test('slugify joins words with hyphens', () => {",
    "  assert.equal(slugify(' Hello World '), 'hello-world');",
    '});',
    '',
  ].join('\n'),
  'test/report.test.js': [
    "import test from 'node:test';",
    "import assert from 'node:assert/strict';",
    "import { reportLine } from '../src/report.js';",
    '',
    "test('a report line carries the date', () => {",
    "  assert.equal(reportLine('Q3', new Date(Date.UTC(2026, 0, 5))), 'Q3 (5/1/2026)');",
    '});',
    '',
  ].join('\n'),
  'test/cli.test.js': [
    "import test from 'node:test';",
    "import assert from 'node:assert/strict';",
    "import { cliStamp } from '../src/cli.js';",
    '',
    "test('the cli stamp brackets the date', () => {",
    "  assert.equal(cliStamp(new Date(Date.UTC(2026, 0, 5))), '[5/1/2026]');",
    '});',
    '',
  ].join('\n'),
  'public/settings.html': [
    '<!doctype html>',
    '<html lang="en">',
    '<head><meta charset="utf-8"><title>Settings</title></head>',
    '<body>',
    '  <h1>Settings</h1>',
    '  <section id="account"><label>Name <input name="name"></label></section>',
    '</body>',
    '</html>',
    '',
  ].join('\n'),
  '.gitignore': 'node_modules/\n',
};

/** The installed protocol's major version, read from the tree it installed. */
export function protocolMajor(repo) {
  const text = read(repo, '.aep/protocol.md') ?? '';
  const match = /^version:\s*(\d+)\./m.exec(text);
  return match ? Number(match[1]) : 0;
}

/**
 * Creates the fixture repository at `repo`, installs AEP from `src`, and
 * commits both on `main`. `remote` adds an origin that is never reachable.
 */
export function createFixture(repo, src, { remote = null } = {}) {
  fs.mkdirSync(repo, { recursive: true });
  git(repo, 'init', '--quiet', '-b', 'main');
  git(repo, 'config', 'user.name', 'Fixture');
  git(repo, 'config', 'user.email', 'fixture@example.invalid');
  git(repo, 'config', 'commit.gpgsign', 'false');
  if (remote) git(repo, 'remote', 'add', 'origin', remote);
  for (const [rel, content] of Object.entries(PROJECT)) write(repo, rel, content);
  git(repo, 'add', '-A');
  git(repo, 'commit', '--quiet', '-m', 'feat: textkit');

  execFileSync(process.execPath, [path.join(src, 'scripts', 'install.mjs'), '--into', repo], { stdio: 'ignore' });
  execFileSync(process.execPath, [path.join(repo, '.aep', 'scripts', 'index.mjs'), '--root', path.join(repo, '.aep')], {
    stdio: 'ignore',
  });
  git(repo, 'add', '-A');
  git(repo, 'commit', '--quiet', '-m', 'chore: install AEP');
  return { repo, major: protocolMajor(repo) };
}

function specText({ status, lane, major, problem, requirements, outOfScope }) {
  const front = ['---', `status: ${status}`];
  if (major >= 4) front.push(`lane: ${lane}`);
  front.push('---', '');
  return [
    ...front,
    '# Problem',
    problem,
    '',
    '# Goal',
    'textkit gains what the requirements below describe, tested.',
    '',
    '# Scope',
    'The functions named below, each with a test under test/.',
    '',
    '# Requirements',
    ...requirements.map((req, index) => `${index + 1}. ${req.requirement}`),
    '',
    '# Acceptance Criteria',
    ...requirements.map((req, index) => `${index + 1}. ${req.criterion}`),
    '',
    '# Out of Scope',
    outOfScope ?? '- Changing any existing export.',
    '',
  ].join('\n');
}

function ticketText({ status, blockedBy = [], title, outcome, criteria, areas, ticked = false }) {
  const front = ['---', `status: ${status}`];
  if (blockedBy.length > 0) front.push(`blocked-by: [${blockedBy.join(', ')}]`);
  front.push('---', '');
  const box = ticked ? '[x]' : '[ ]';
  return [
    ...front,
    `# ${title}`,
    '',
    '## Outcome',
    outcome,
    '',
    '## Acceptance Criteria',
    ...criteria.map((line) => `- ${box} ${line}${ticked ? ' (verified: `node --test` passed)' : ''}`),
    '',
    '## Relevant areas',
    areas,
    '',
  ].join('\n');
}

function reindex(repo) {
  execFileSync(process.execPath, [path.join(repo, '.aep', 'scripts', 'index.mjs'), '--root', path.join(repo, '.aep')], {
    stdio: 'ignore',
  });
}

/**
 * Seeds an effort the way an opened one stands: its branch carries a docs
 * commit with the spec and tickets, plus one commit per ticket in `landed`.
 * `worktree` adds the run surface; `dirty` leaves an edit uncommitted in it.
 */
export function seedEffort(repo, major, effort) {
  const { name, lane, status = 'accepted', problem, requirements, tickets = [], landed = [], worktree = false, dirty = null } = effort;
  const dir = `.aep/efforts/${name}`;
  git(repo, 'switch', '--quiet', '-c', name, 'main');
  write(repo, `${dir}/spec.md`, specText({ status, lane, major, problem, requirements, outOfScope: effort.outOfScope }));
  for (const ticket of tickets) {
    write(repo, `${dir}/tickets/${ticket.id}-${ticket.slug}.md`, ticketText({ ...ticket, status: 'open' }));
  }
  reindex(repo);
  git(repo, 'add', '-A');
  git(repo, 'commit', '--quiet', '-m', `docs(${name}): open the effort`);

  for (const id of landed) {
    const ticket = tickets.find((entry) => entry.id === id);
    for (const [rel, content] of Object.entries(ticket.code ?? {})) write(repo, rel, content);
    write(repo, `${dir}/tickets/${ticket.id}-${ticket.slug}.md`, ticketText({ ...ticket, status: 'resolved', ticked: true }));
    reindex(repo);
    git(repo, 'add', '-A');
    git(repo, 'commit', '--quiet', '-m', ticket.title);
  }
  git(repo, 'switch', '--quiet', 'main');

  if (worktree) {
    const surface = path.join(repo, '.aep', 'worktrees', name, '_run');
    git(repo, 'worktree', 'add', '--quiet', surface, name);
    if (dirty) write(surface, dirty.file, dirty.content);
  }
  return { name, dir };
}

/** Top-level names in the places nothing should ever be written. */
export function snapshotOutside() {
  const home = os.homedir();
  const places = [home, ...['Desktop', 'Documents', 'Downloads'].map((name) => path.join(home, name)), path.parse(process.cwd()).root];
  const listing = {};
  for (const place of places) {
    try {
      listing[place] = fs.readdirSync(place).sort();
    } catch {
      listing[place] = null;
    }
  }
  return listing;
}

export function diffOutside(before, after) {
  const added = [];
  for (const [place, names] of Object.entries(after)) {
    const was = new Set(before[place] ?? []);
    for (const name of names ?? []) if (!was.has(name)) added.push(path.join(place, name));
  }
  return added;
}
