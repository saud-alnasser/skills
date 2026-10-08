// Tests for the AEP command line, against throwaway repositories made through
// the temp API. Run from the repository root:
//
//   node --test tests/aep.test.mjs
//
// Each test installs AEP from this checkout's src/ into a fresh repository, so
// what is tested is what ships.

import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { execFileSync, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const SRC = path.join(path.dirname(path.dirname(fileURLToPath(import.meta.url))), 'src');

function git(cwd, ...args) {
  return execFileSync('git', args, { cwd, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
}

function write(root, rel, content) {
  const file = path.join(root, ...rel.split('/'));
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, content, 'utf8');
}

function setFrontmatter(file, fields) {
  let text = fs.readFileSync(file, 'utf8');
  for (const [field, value] of Object.entries(fields)) {
    const line = new RegExp(`^${field}:.*$`, 'm');
    text = line.test(text.split(/^---$/m)[1] ?? '')
      ? text.replace(line, `${field}: ${value}`)
      : text.replace(/^---\r?\n/, `---\n${field}: ${value}\n`);
  }
  fs.writeFileSync(file, text, 'utf8');
}

/** A repository with AEP installed and committed on main. */
function fixture(t, settings = {}, parent = null) {
  const dir = parent
    ? fs.mkdtempSync(path.join(parent, 'repo-'))
    : fs.realpathSync.native(fs.mkdtempSync(path.join(os.tmpdir(), 'aep-cli-')));
  t.after(() => {
    for (const line of (spawnSync('git', ['worktree', 'list', '--porcelain'], { cwd: dir, encoding: 'utf8' }).stdout ?? '').split(/\r?\n/)) {
      if (line.startsWith('worktree ') && path.resolve(line.slice(9)) !== path.resolve(dir)) {
        spawnSync('git', ['worktree', 'remove', '--force', line.slice(9)], { cwd: dir });
      }
    }
    fs.rmSync(dir, { recursive: true, force: true, maxRetries: 5, retryDelay: 100 });
  });
  git(dir, 'init', '--quiet', '-b', 'main');
  git(dir, 'config', 'user.name', 'Test');
  git(dir, 'config', 'user.email', 'test@example.invalid');
  git(dir, 'config', 'commit.gpgsign', 'false');
  write(dir, 'README.md', '# project\n\nTo recieve help, ask.\n');
  write(dir, 'setup.js', "require('fs').appendFileSync('warmed.txt', 'x');\n");
  git(dir, 'add', '-A');
  git(dir, 'commit', '--quiet', '-m', 'init');
  execFileSync(process.execPath, [path.join(SRC, 'scripts', 'install.mjs'), '--into', dir], { stdio: 'ignore' });
  if (Object.keys(settings).length > 0) {
    setFrontmatter(path.join(dir, '.aep', 'rules', 'version-control.md'), settings);
  }
  execFileSync(process.execPath, [path.join(dir, '.aep', 'scripts', 'index.mjs')], { cwd: dir, stdio: 'ignore' });
  git(dir, 'add', '-A');
  git(dir, 'commit', '--quiet', '-m', 'chore: install AEP');
  return dir;
}

/** Runs the installed CLI in `cwd`, returning its exit code and parsed JSON. */
function aep(cwd, ...args) {
  const result = spawnSync(process.execPath, [path.join(cwd, '.aep', 'scripts', 'aep.mjs'), ...args], {
    cwd, encoding: 'utf8',
  });
  let json = null;
  try {
    json = JSON.parse(result.stdout);
  } catch {
    json = { raw: result.stdout, stderr: result.stderr };
  }
  return { code: result.status, json, stderr: result.stderr };
}

function draft(dir, slug, { lane = 'standard', check = null } = {}) {
  const body = lane === 'quick'
    ? `---\nstatus: accepted\nlane: quick\n---\n\n# Problem\nA typo.\n\n# Change\nFix it.\n\n# Check\n- [ ] ${check ?? 'README reads "receive"'}\n`
    : `---\nstatus: accepted\nlane: ${lane}\n---\n\n# Problem\nx\n\n# Goal\nx\n\n# Scope\nx\n\n# Requirements\n1. a\n2. b\n\n# Acceptance Criteria\n1. a works\n2. b works\n\n# Out of Scope\n- nothing\n`;
  write(dir, `.aep/scratch/${slug}/spec.md`, body);
}

function ticket(surface, effort, stem, { blockedBy = [] } = {}) {
  const front = ['---', 'status: open'];
  if (blockedBy.length) front.push(`blocked-by: [${blockedBy.join(', ')}]`);
  front.push('---', '');
  const n = Number(stem.split('-')[0]);
  write(surface, `.aep/efforts/${effort}/tickets/${stem}.md`, [
    ...front, `# feat: ${stem}`, '', '## Outcome', 'x', '', '## Acceptance Criteria',
    `- [ ] criterion ${n}: ${stem} exists`, '',
  ].join('\n'));
}

function tick(surface, effort, stem) {
  const file = path.join(surface, '.aep', 'efforts', effort, 'tickets', `${stem}.md`);
  fs.writeFileSync(file, fs.readFileSync(file, 'utf8').replace(/- \[ \]/g, '- [x]').replace(/exists$/m, 'exists (verified: file present)'), 'utf8');
}

/** Opens a standard or full effort with tickets committed on its branch. */
function openWithTickets(t, dir, lane, stems, settings) {
  draft(dir, 'feature', { lane });
  const opened = aep(dir, 'open', 'feature', '--lane', lane);
  assert.equal(opened.code, 0, JSON.stringify(opened.json));
  const { surface, effort } = opened.json;
  for (const stem of stems) ticket(surface, effort, stem);
  execFileSync(process.execPath, [path.join(surface, '.aep', 'scripts', 'index.mjs')], { cwd: surface, stdio: 'ignore' });
  git(surface, 'add', '-A');
  git(surface, 'commit', '--quiet', '-m', 'docs: tickets');
  return { surface, effort };
}

test('open makes the branch and the surface in one act, and moves the draft in', (t) => {
  const dir = fixture(t);
  draft(dir, 'csv-export');
  const { code, json } = aep(dir, 'open', 'csv-export', '--lane', 'standard');
  assert.equal(code, 0, JSON.stringify(json));
  assert.equal(json.effort, '1-csv-export');
  assert.equal(path.resolve(json.surface), path.join(dir, '.aep', 'worktrees', '1-csv-export', '_run'));
  assert.equal(git(json.surface, 'rev-parse', '--abbrev-ref', 'HEAD'), '1-csv-export');
  const spec = fs.readFileSync(path.join(json.surface, '.aep', 'efforts', '1-csv-export', 'spec.md'), 'utf8');
  assert.match(spec, /^lane: standard$/m);
  assert.ok(fs.existsSync(path.join(json.surface, '.aep', 'efforts', '1-csv-export', 'log.md')));
  assert.equal(git(json.surface, 'status', '--porcelain'), '');
  assert.ok(!fs.existsSync(path.join(dir, '.aep', 'scratch', 'csv-export')), 'the draft is moved, not copied');
  assert.equal(git(dir, 'status', '--porcelain'), '', 'the main checkout is untouched');

  const again = aep(dir, 'open', 'csv-export', '--lane', 'standard');
  assert.equal(again.code, 0);
  assert.equal(again.json.opened, 'already');
});

test('open in a surface the runtime supplied takes no second one', (t) => {
  const dir = fixture(t);
  const supplied = fs.mkdtempSync(path.join(path.dirname(dir), 'aep-runtime-'));
  fs.rmSync(supplied, { recursive: true });
  t.after(() => fs.rmSync(supplied, { recursive: true, force: true, maxRetries: 5, retryDelay: 100 }));
  git(dir, 'worktree', 'add', '--quiet', '--detach', supplied, 'main');
  draft(supplied, 'from-runtime');
  const { code, json } = aep(supplied, 'open', 'from-runtime', '--lane', 'standard');
  assert.equal(code, 0, JSON.stringify(json));
  assert.equal(path.resolve(json.surface), path.resolve(supplied));
  assert.equal(git(supplied, 'rev-parse', '--abbrev-ref', 'HEAD'), json.effort);
  assert.ok(!fs.existsSync(path.join(dir, '.aep', 'worktrees', json.effort)), 'no surface under .aep/worktrees');
  git(dir, 'worktree', 'remove', '--force', supplied);
});

test('open numbers past every effort a branch or a surface already holds', (t) => {
  const dir = fixture(t);
  draft(dir, 'one');
  aep(dir, 'open', 'one', '--lane', 'standard');
  draft(dir, 'two');
  const { json } = aep(dir, 'open', 'two', '--lane', 'standard');
  assert.equal(json.effort, '2-two');
});

test('start re-enters the surface an effort already has, and never makes a second', (t) => {
  const dir = fixture(t);
  const { surface, effort } = openWithTickets(t, dir, 'standard', ['01-a', '02-b']);
  const first = aep(dir, 'start', effort);
  assert.equal(first.code, 0, JSON.stringify(first.json));
  assert.equal(first.json.entered, 're-entered');
  assert.deepEqual(first.json.frontier, ['01-a', '02-b']);
  assert.equal(first.json.next, 'build');
  assert.equal(first.json.wave, 'here', 'a standard lane builds here, not in children');
  const second = aep(surface, 'start');
  assert.equal(second.json.entered, 'here');
  const holders = git(dir, 'worktree', 'list', '--porcelain').split(/\r?\n/).filter((line) => line === `branch refs/heads/${effort}`);
  assert.equal(holders.length, 1);
});

test('start recreates a removed surface from the effort branch', (t) => {
  const dir = fixture(t);
  const { surface, effort } = openWithTickets(t, dir, 'standard', ['01-a']);
  git(dir, 'worktree', 'remove', surface);
  const { json } = aep(dir, 'start', effort);
  assert.equal(json.entered, 'created');
  assert.ok(fs.existsSync(surface));
});

test('start stops on a dirty surface and names the paths', (t) => {
  const dir = fixture(t);
  const { surface, effort } = openWithTickets(t, dir, 'standard', ['01-a']);
  fs.appendFileSync(path.join(surface, 'README.md'), 'half an edit\n');
  const { code, json } = aep(dir, 'start', effort);
  assert.equal(code, 1);
  assert.equal(json.next, 'stop');
  assert.deepEqual(json.dirty, ['README.md']);
  assert.match(json.stop, /README\.md/);
});

test('start refuses a claim held by another surface', (t) => {
  const dir = fixture(t);
  const { surface, effort } = openWithTickets(t, dir, 'standard', ['01-a']);
  git(surface, 'switch', '--quiet', '--detach');
  const elsewhere = path.join(dir, '.aep', 'worktrees', 'elsewhere');
  git(dir, 'worktree', 'add', '--quiet', elsewhere, effort);
  const { code, json } = aep(dir, 'start', effort);
  assert.equal(code, 1);
  assert.match(json.stop, /held by another surface/);
});

test('a wave of two: dispatch makes both surfaces first, land integrates one at a time', (t) => {
  const dir = fixture(t);
  const { surface, effort } = openWithTickets(t, dir, 'full', ['01-a', '02-b']);
  const started = aep(dir, 'start', effort);
  assert.equal(started.json.wave, 'dispatch');

  const sent = aep(surface, 'dispatch', effort, '01', '02');
  assert.equal(sent.code, 0, JSON.stringify(sent.json));
  assert.equal(sent.json.children.length, 2);
  for (const child of sent.json.children) {
    assert.ok(child.created);
    assert.equal(path.dirname(path.resolve(child.surface)), path.join(dir, '.aep', 'worktrees', effort));
    write(child.surface, `${child.ticket}.txt`, child.ticket);
    git(child.surface, 'add', '-A');
    git(child.surface, 'commit', '--quiet', '-m', `wip ${child.ticket}`);
  }
  const again = aep(surface, 'dispatch', effort, '01');
  assert.equal(again.json.children[0].created, false, 'dispatch is idempotent');

  const before = Number(git(surface, 'rev-list', '--count', 'HEAD'));
  for (const stem of ['01-a', '02-b']) {
    tick(surface, effort, stem);
    const landed = aep(surface, 'land', effort, stem.split('-')[0], '--message', `feat: ${stem}`);
    assert.equal(landed.code, 0, JSON.stringify(landed.json));
    assert.ok(landed.json.released.branch, 'the ticket branch is released');
  }
  assert.equal(Number(git(surface, 'rev-list', '--count', 'HEAD')), before + 2, 'one commit per ticket');
  assert.ok(fs.existsSync(path.join(surface, '01-a.txt')) && fs.existsSync(path.join(surface, '02-b.txt')));
  assert.equal(git(dir, 'branch', '--list', `${effort}--*`), '');
  const log = fs.readFileSync(path.join(surface, '.aep', 'efforts', effort, 'log.md'), 'utf8');
  assert.match(log, /\[x\] 01 a 1\/1/);
  assert.match(log, /\[x\] 02 b 1\/1/);
  assert.equal(aep(dir, 'start', effort).json.next, 'converge');
});

test('land refuses a ticket whose criteria are not all ticked', (t) => {
  const dir = fixture(t);
  const { surface, effort } = openWithTickets(t, dir, 'standard', ['01-a']);
  const { code, json } = aep(surface, 'land', effort, '01', '--message', 'feat: a');
  assert.equal(code, 1);
  assert.match(json.stop, /not ticked/);
});

test('land after a crash between the commit and the release finishes the release', (t) => {
  const dir = fixture(t);
  const { surface, effort } = openWithTickets(t, dir, 'full', ['01-a', '02-b']);
  const sent = aep(surface, 'dispatch', effort, '01');
  const child = sent.json.children[0];
  write(child.surface, 'a.txt', 'a');
  git(child.surface, 'add', '-A');
  git(child.surface, 'commit', '--quiet', '-m', 'wip');
  // The crash: the work and the status reached the effort branch, the release never ran.
  git(surface, 'merge', '--squash', `${effort}--01-a`);
  tick(surface, effort, '01-a');
  const file = path.join(surface, '.aep', 'efforts', effort, 'tickets', '01-a.md');
  fs.writeFileSync(file, fs.readFileSync(file, 'utf8').replace('status: open', 'status: resolved'), 'utf8');
  git(surface, 'add', '-A');
  git(surface, 'commit', '--quiet', '-m', 'feat: a');
  const head = git(surface, 'rev-parse', 'HEAD');

  const { code, json } = aep(surface, 'land', effort, '01', '--message', 'feat: a');
  assert.equal(code, 0, JSON.stringify(json));
  assert.equal(json.already, true);
  assert.equal(git(surface, 'rev-parse', 'HEAD'), head, 'nothing is committed twice');
  assert.ok(!fs.existsSync(child.surface));
  assert.equal(git(dir, 'branch', '--list', `${effort}--01-a`), '');
});

test('close on a clean finish stamps implemented, releases the branch, and removes the surface', (t) => {
  const dir = fixture(t);
  const { surface, effort } = openWithTickets(t, dir, 'standard', ['01-a']);
  tick(surface, effort, '01-a');
  write(surface, 'a.txt', 'a');
  assert.equal(aep(surface, 'land', effort, '01', '--message', 'feat: a').code, 0);
  const premature = aep(dir, 'close', effort, '--stop', 'review found a gap nobody can fix here');
  assert.equal(premature.json.closed, 'stopped');
  assert.ok(fs.existsSync(surface), 'a stop keeps the surface');
  assert.match(git(dir, 'worktree', 'list', '--porcelain'), /detached/);
  const board = aep(dir, 'status', '--json');
  assert.match(JSON.stringify(board.json), /review found a gap/);

  const resumed = aep(dir, 'start', effort);
  assert.equal(resumed.json.entered, 're-entered');
  write(surface, '.aep/scratch/notes.md', 'exploration notes\n');
  const { code, json } = aep(dir, 'close', effort, '--friction', 'the review asked twice');
  assert.equal(code, 0, JSON.stringify(json));
  assert.equal(json.closed, 'clean');
  assert.ok(!fs.existsSync(surface));
  assert.match(git(dir, 'show', `${effort}:.aep/efforts/${effort}/spec.md`), /^status: implemented$/m);
  assert.match(git(dir, 'show', `${effort}:.aep/friction.md`), /the review asked twice/);
  assert.equal(git(dir, 'rev-parse', '--abbrev-ref', 'HEAD'), 'main');
});

test('close refuses while a ticket is unresolved', (t) => {
  const dir = fixture(t);
  const { effort } = openWithTickets(t, dir, 'standard', ['01-a']);
  const { code, json } = aep(dir, 'close', effort);
  assert.equal(code, 1);
  assert.match(json.stop, /unresolved tickets remain: 01-a/);
});

test('the quick lane lands as exactly one commit on its branch', (t) => {
  const dir = fixture(t);
  draft(dir, 'typo', { lane: 'quick' });
  const opened = aep(dir, 'open', 'typo', '--lane', 'quick');
  const { surface, effort } = opened.json;
  fs.writeFileSync(path.join(surface, 'README.md'), '# project\n\nTo receive help, ask.\n', 'utf8');
  const spec = path.join(surface, '.aep', 'efforts', effort, 'spec.md');
  const early = aep(surface, 'land', effort, '--message', 'docs: fix typo');
  assert.equal(early.code, 1, 'an unticked Check stops the land');
  // A revised Check item committed on its own, as specify says a revision is:
  // it is still folded into the one commit that lands.
  fs.writeFileSync(spec, fs.readFileSync(spec, 'utf8').replace('README reads', 'The README reads'), 'utf8');
  git(surface, 'commit', '--quiet', '-am', 'docs: sharpen the check');
  fs.writeFileSync(spec, fs.readFileSync(spec, 'utf8').replace('- [ ]', '- [x]'), 'utf8');
  const landed = aep(surface, 'land', effort, '--message', 'docs: fix typo');
  assert.equal(landed.code, 0, JSON.stringify(landed.json));
  assert.equal(git(dir, 'rev-list', '--count', `main..${effort}`), '1');
  assert.equal(git(dir, 'log', '-1', '--format=%s', effort), 'docs: fix typo');
  const closed = aep(dir, 'close', effort);
  assert.equal(closed.code, 0, JSON.stringify(closed.json));
  assert.equal(git(dir, 'rev-list', '--count', `main..${effort}`), '1', 'close adds no commit in the quick lane');
  assert.ok(!fs.existsSync(path.join(dir, '.aep', 'worktrees', effort)), 'no empty effort directory is left behind');
  assert.ok(!git(dir, 'ls-tree', '-r', '--name-only', effort).includes('tickets/'));
});

test('record numbers the rounds, keeps the surface clean, and refuses one past the lane\'s cap', (t) => {
  const dir = fixture(t);
  const { surface, effort } = openWithTickets(t, dir, 'standard', ['01-a']);
  tick(surface, effort, '01-a');
  assert.equal(aep(surface, 'land', effort, '01', '--message', 'feat: a').code, 0);
  assert.equal(aep(dir, 'start', effort).json.next, 'converge');
  const converged = aep(surface, 'record', effort, '--converge', 'no gap');
  assert.equal(converged.code, 0, JSON.stringify(converged.json));
  assert.equal(converged.json.line, 'converge 1: no gap');
  assert.equal(git(surface, 'status', '--porcelain'), '', 'the record is committed');
  assert.equal(aep(dir, 'start', effort).json.next, 'review');
  const again = aep(surface, 'record', effort, '--converge', 'gap, tickets 02');
  assert.equal(again.code, 1, 'a standard effort converges once');
  assert.match(again.json.stop, /at most 1 converge/);
  aep(surface, 'record', effort, '--review', '2 findings, 2 fixed');
  assert.equal(aep(dir, 'start', effort).json.next, 'close', 'a standard effort reviews once');
  aep(surface, 'record', effort, '--needs-you', 'decide the export');
  const board = aep(dir, 'status', '--json');
  assert.match(JSON.stringify(board.json), /decide the export/);
});

test('a full-lane review that fixed findings is reviewed again; one that found nothing ends review', (t) => {
  const dir = fixture(t);
  const { surface, effort } = openWithTickets(t, dir, 'full', ['01-a']);
  tick(surface, effort, '01-a');
  assert.equal(aep(surface, 'land', effort, '01', '--message', 'feat: a').code, 0);
  aep(surface, 'record', effort, '--converge', 'no gap');
  aep(surface, 'record', effort, '--review', '3 findings, 3 fixed');
  assert.equal(aep(dir, 'start', effort).json.next, 'review', 'the fixes are reviewed again');
  aep(surface, 'record', effort, '--review', 'no findings');
  assert.equal(aep(dir, 'start', effort).json.next, 'close');
});

test('lanes only go up', (t) => {
  const dir = fixture(t);
  draft(dir, 'typo', { lane: 'quick' });
  const { effort } = aep(dir, 'open', 'typo', '--lane', 'quick').json;
  const up = aep(dir, 'raise', effort, 'standard', '--reason', 'it crosses two modules');
  assert.equal(up.json.raised, true);
  const down = aep(dir, 'raise', effort, 'quick');
  assert.equal(down.code, 1);
  assert.match(down.json.stop, /lanes only go up/);
});

test('a new surface is warmed by the repository\'s setup command, and start reruns it only on a lockfile change', (t) => {
  const dir = fixture(t, { setup: 'node setup.js' });
  draft(dir, 'warm');
  const { json } = aep(dir, 'open', 'warm', '--lane', 'standard');
  assert.equal(json.setup.ran, true, JSON.stringify(json.setup));
  assert.equal(fs.readFileSync(path.join(json.surface, 'warmed.txt'), 'utf8'), 'x');
  fs.rmSync(path.join(json.surface, 'warmed.txt'));
  const again = aep(dir, 'start', json.effort);
  assert.equal(again.json.setup.ran, false);
  write(json.surface, 'package-lock.json', '{}');
  git(json.surface, 'add', '-A');
  git(json.surface, 'commit', '--quiet', '-m', 'chore: lock');
  const moved = aep(dir, 'start', json.effort);
  assert.equal(moved.json.setup.ran, true);
  fs.rmSync(path.join(json.surface, 'warmed.txt'), { force: true });
});

test('status reads every effort branch and says what waits on the human', (t) => {
  const dir = fixture(t);
  openWithTickets(t, dir, 'standard', ['01-a', '02-b']);
  const { code, json } = aep(dir, 'status', '--json');
  assert.equal(code, 0);
  const [board] = json.boards;
  assert.equal(board.efforts.length, 1);
  assert.equal(board.efforts[0].tickets.total, 2);
  assert.deepEqual(board.efforts[0].tickets.ready, ['01', '02']);
  const text = spawnSync(process.execPath, [path.join(dir, '.aep', 'scripts', 'aep.mjs'), 'status'], { cwd: dir, encoding: 'utf8' }).stdout;
  assert.match(text, /1-feature/);
  assert.match(text, /Nothing is waiting on you/);
  assert.equal(git(dir, 'status', '--porcelain'), '', 'status writes nothing');
});

test('status --repos reads several repositories and writes to none', (t) => {
  const parent = fs.realpathSync.native(fs.mkdtempSync(path.join(os.tmpdir(), 'aep-repos-')));
  t.after(() => fs.rmSync(parent, { recursive: true, force: true, maxRetries: 5, retryDelay: 100 }));
  const one = fixture(t, {}, parent);
  const two = fixture(t, {}, parent);
  fs.mkdirSync(path.join(parent, 'not-a-repo'));
  openWithTickets(t, one, 'standard', ['01-a']);
  const result = spawnSync(process.execPath, [path.join(one, '.aep', 'scripts', 'aep.mjs'), 'status', '--repos', parent, '--json'], {
    cwd: one, encoding: 'utf8',
  });
  const json = JSON.parse(result.stdout);
  const repos = json.boards.map((board) => path.resolve(board.repo));
  assert.ok(repos.includes(path.resolve(one)) && repos.includes(path.resolve(two)));
  assert.equal(git(two, 'status', '--porcelain'), '');
});
