// The position report's fixture: a throwaway git repository, and the shipped
// script's observations against each state the scripts page enumerates.
//
// This module builds and mutates a repository, which is why it is here rather
// than in `verify.js`. That file resolves every path it touches through a
// resolver that refuses the protocol directory and refuses anything outside the
// repository, and the fixture's whole subject is a repository outside this one.
// Keeping the two apart is what leaves that resolver with no exemption in it:
// the only shipped path this module receives is the script's, and `verify.js`
// resolves that before handing it over.
//
// Nothing here asserts. It reports what was observed and what the substitutions
// are, and `verify.js` states the expected output and compares.

'use strict';

const { spawnSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

/** A well-formed object name that names no object in a fresh repository. */
const NAMES_NO_OBJECT = 'deadbeef'.repeat(5);

/** The run identity case D exercises. */
const IDENTITY = 'test-run-id';

/**
 * git, against the fixture repository, with the author and signing pinned so
 * that whoever runs the build does not change what it observes.
 *
 * @param {string} root the fixture repository
 * @param {string[]} args the git arguments, without `-C`
 * @param {NodeJS.ProcessEnv} [env] the environment to run under
 * @returns {string} the trimmed standard output
 * @throws {Error} when git exits non-zero — a fixture that cannot be built is a
 *   broken fixture, not a failing assertion
 */
function git(root, args, env) {
  const pinned = [
    '-C', root,
    '-c', 'user.name=AEP fixture',
    '-c', 'user.email=fixture@example.invalid',
    '-c', 'commit.gpgsign=false',
  ];
  const result = spawnSync('git', [...pinned, ...args], { encoding: 'utf8', env });
  if (result.status !== 0) {
    throw new Error(`fixture setup failed: git ${args.join(' ')}\n${result.stderr || ''}`);
  }
  return (result.stdout || '').trim();
}

/**
 * The tree fingerprint of the repository as it stands, computed here rather than
 * asked of the script under test — an expected value the script produced would
 * agree with the script whatever it did.
 *
 * @param {string} root the fixture repository
 * @returns {string} the tree object's name
 */
function fingerprint(root) {
  const index = git(root, ['rev-parse', '--path-format=absolute', '--git-path', 'index']);
  const throwaway = path.join(os.tmpdir(), `aep-fixture-index-${process.pid}-${Date.now()}`);
  fs.copyFileSync(index, throwaway);
  const scoped = { ...process.env, GIT_INDEX_FILE: throwaway };
  try {
    git(root, ['add', '-A'], scoped);
    return git(root, ['write-tree'], scoped);
  } finally {
    fs.rmSync(throwaway, { force: true });
  }
}

/**
 * One commit holding a seed file and the ignore every configured repository has,
 * a second commit so a marker can sit behind `HEAD`, and a commit on a second
 * branch that `HEAD` is not descended from.
 *
 * **The ignore is a precondition rather than set dressing.** The script writes
 * its receipt into the position directory during the run, so a tree that counted
 * it would fingerprint differently after the run than the value just reported,
 * and no case could pass.
 *
 * @param {string} root an empty directory
 * @returns {{base: string, head: string, tree: string, other: string}}
 */
function build(root) {
  const write = (file, body) => fs.writeFileSync(path.join(root, file), body);

  git(root, ['init', '-q', '-b', 'main']);
  write('.gitignore', '.claude/position/\n');
  write('seed.txt', 'seed\n');
  git(root, ['add', '-A']);
  git(root, ['commit', '-q', '-m', 'seed']);
  const base = git(root, ['rev-parse', 'HEAD']);

  write('second.txt', 'second\n');
  git(root, ['add', '-A']);
  git(root, ['commit', '-q', '-m', 'second']);
  const head = git(root, ['rev-parse', 'HEAD']);

  git(root, ['switch', '-q', '-c', 'other']);
  write('other.txt', 'other\n');
  git(root, ['add', '-A']);
  git(root, ['commit', '-q', '-m', 'other']);
  const other = git(root, ['rev-parse', 'HEAD']);
  git(root, ['switch', '-q', 'main']);

  return { base, head, other, tree: fingerprint(root) };
}

/**
 * Runs the shipped script against the fixture and captures everything a case
 * could be asserted against.
 *
 * The run identity is removed from the environment unless a case asks for one:
 * the build itself runs inside a session that carries one, so a case meaning to
 * exercise its absence would otherwise exercise its presence.
 *
 * @param {string} root the fixture repository
 * @param {string} script the shipped script's absolute path
 * @param {string|null} identity the value of the run identity, or null for none
 * @returns {{status: number, stdout: string, stderr: string, receipt: Buffer|null}}
 */
function invoke(root, script, identity) {
  const env = { ...process.env };
  for (const leaked of ['CLAUDE_CODE_SESSION_ID', 'GIT_INDEX_FILE', 'GIT_DIR', 'GIT_WORK_TREE']) {
    delete env[leaked];
  }
  if (identity) env.CLAUDE_CODE_SESSION_ID = identity;

  const receiptPath = path.join(root, '.claude', 'position', 'receipt.json');
  fs.rmSync(receiptPath, { force: true });

  const result = spawnSync(process.execPath, [script, '--repo', root], { encoding: 'buffer', env });
  return {
    status: result.status,
    stdout: (result.stdout || Buffer.alloc(0)).toString('utf8'),
    stderr: (result.stderr || Buffer.alloc(0)).toString('utf8'),
    receipt: fs.existsSync(receiptPath) ? fs.readFileSync(receiptPath) : null,
  };
}

/**
 * The four repositories whose working-tree line ending is settled by something
 * other than the platform, and what git puts on disk in each.
 *
 * **`ending` is stated here, from git's own definition of the attribute and the
 * setting, so that the expectation comes from what this fixture configured.** An
 * expectation read from `os` would agree with a script that read `os` too,
 * whatever the checkout said — a guard that cannot see its own subject, which is
 * what the first version of this was.
 *
 * The pair of attributes and the pair of settings are both needed, and for the
 * same reason pointed two ways: on any one platform, one member of each pair
 * agrees with `os.EOL` by coincidence and cannot catch a script that consulted
 * it. The other member disagrees, and does. Which is which swaps between
 * Windows and everything else, so both are carried rather than the one that
 * happens to bite here.
 */
const CHECKOUTS = [
  { label: 'attribute eol=lf', attribute: 'lf', ending: '\n' },
  { label: 'attribute eol=crlf', attribute: 'crlf', ending: '\r\n' },
  { label: 'core.autocrlf=input', config: { 'core.autocrlf': 'input' }, ending: '\n' },
  { label: 'core.autocrlf=true', config: { 'core.autocrlf': 'true' }, ending: '\r\n' },
];

/**
 * A repository whose ending is settled by one of the above, and the receipt the
 * shipped script writes in it.
 *
 * Run with no marker, so it reaches a refusal — which writes a receipt like
 * every other run and needs no commit graph set up first.
 *
 * @param {string} script the shipped script's absolute path
 * @param {object} checkout one entry of `CHECKOUTS`
 * @param {string} root an empty directory
 * @returns {{label: string, expected: string, run: object}}
 */
function observeCheckout(script, checkout, root) {
  const write = (file, body) => fs.writeFileSync(path.join(root, file), body);

  git(root, ['init', '-q', '-b', 'main']);
  for (const [key, value] of Object.entries(checkout.config || {})) git(root, ['config', key, value]);
  if (checkout.attribute) write('.gitattributes', `* text=auto eol=${checkout.attribute}\n`);
  write('.gitignore', '.claude/position/\n');
  write('seed.txt', 'seed\n');
  git(root, ['add', '-A']);
  git(root, ['commit', '-q', '-m', 'seed']);

  return { label: checkout.label, expected: checkout.ending, run: invoke(root, script, null) };
}

/**
 * Build the fixture, run every case against the shipped script, and report what
 * was observed together with the substitutions the expected output is stated in.
 *
 * Cases run against a state set up in full beforehand rather than inherited from
 * the case before, so one failing case cannot cascade into the next.
 *
 * @param {string} script the shipped script's absolute path
 * @returns {object} the captured object names and one entry per case
 */
function observe(script) {
  const roots = [];
  const temporary = (suffix) => {
    const made = fs.mkdtempSync(path.join(os.tmpdir(), `aep-position-${suffix}`));
    roots.push(made);
    return made;
  };

  try {
    const root = temporary('cases-');
    const names = build(root);
    const markerPath = path.join(root, '.claude', 'position', 'marker.json');
    const untracked = path.join(root, 'a.txt');
    const alsoUntracked = path.join(root, 'zz.txt');
    const tracked = path.join(root, 'seed.txt');

    const setMarker = (value) => {
      fs.mkdirSync(path.dirname(markerPath), { recursive: true });
      if (value === null) fs.rmSync(markerPath, { force: true });
      else fs.writeFileSync(markerPath, JSON.stringify(value));
    };

    const matching = { commit: names.head, tree: names.tree };
    const cases = {};

    // Every scratch file a case can leave behind is removed and every tracked
    // file a case can edit is put back, so a case's state is what it asked for
    // and not what the case before it left.
    const settle = (marker, extra) => {
      fs.rmSync(untracked, { force: true });
      fs.rmSync(alsoUntracked, { force: true });
      fs.writeFileSync(tracked, 'seed\n');
      setMarker(marker);
      if (extra) extra();
    };

    settle(matching);
    cases.A = invoke(root, script, null);

    settle(matching, () => fs.writeFileSync(untracked, 'a\n'));
    const live = fingerprint(root);
    cases.B = invoke(root, script, null);

    settle(null);
    cases.C = invoke(root, script, null);

    settle(matching);
    cases.D = invoke(root, script, IDENTITY);

    settle({ commit: NAMES_NO_OBJECT, tree: names.tree });
    cases.E = invoke(root, script, null);

    settle({ commit: names.other, tree: names.tree });
    cases.F = invoke(root, script, null);

    // Not one of the page's lettered cases, and it is here because the report's
    // other commit verdict — the count of commits `HEAD` is ahead — and the
    // committed half of the drift list are reached by no case above.
    settle({ commit: names.base, tree: names.tree });
    cases.G = invoke(root, script, null);

    // **The first uncommitted entry is an unstaged modification of a tracked
    // file**, which is the one porcelain shape whose status column 1 is a space.
    // Every case above puts a non-space there — `??` for an untracked file — so
    // a reader that eats a leading space corrupts nothing they can see, and the
    // first line is the only line it can corrupt. `seed.txt` sorts before
    // `zz.txt`, which is what puts the fragile line first.
    settle(matching, () => {
      fs.writeFileSync(tracked, 'seed, edited and not staged\n');
      fs.writeFileSync(alsoUntracked, 'z\n');
    });
    const liveModified = fingerprint(root);
    cases.H = invoke(root, script, null);

    // A repository per checkout rather than more cases in the one above: the
    // subject is what settles the ending, and a repository settles it one way.
    const checkouts = CHECKOUTS.map((checkout, index) =>
      observeCheckout(script, checkout, temporary(`checkout-${index}-`)),
    );

    return { ...names, live, liveModified, identity: IDENTITY, gone: NAMES_NO_OBJECT, cases, checkouts };
  } finally {
    // A temporary directory that outlives the run costs nothing and is not worth
    // failing a build over; git leaves object files read-only on Windows.
    for (const spent of roots) {
      try {
        fs.rmSync(spent, { recursive: true, force: true, maxRetries: 3 });
      } catch {
        /* left behind */
      }
    }
  }
}

module.exports = { observe };
