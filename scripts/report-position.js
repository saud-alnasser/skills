// Reports where this clone stands, and writes the receipt attesting that it did.
//
// Copied into `.claude/scripts/report-position.js` and run by every stage that
// opens with verification. It emits the *position* half of that report and never
// the judgement half: which contexts a request routes to, whether a Source
// Pointer still resolves, and whether a claim is contradicted by source cannot be
// computed from git, so the stage prints those beneath this output.
//
// A refusal is a result rather than an error. A clone with no marker still
// reports, still writes a receipt, and still exits zero — what it does not do is
// claim the position was verifiable.
//
// Usage:
//
//   node .claude/scripts/report-position.js            the repository holding this script
//   node .claude/scripts/report-position.js --repo <path>
//
// `--repo` exists so the file can be exercised against a repository other than
// the one it sits in; without it the root is this script's grandparent, which is
// the repository root when the script is where it is copied to, so the invocation
// does not depend on the working directory.

'use strict';

const { spawnSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

/**
 * What separates the report's lines on standard output.
 *
 * The platform's, and deliberately not the checkout's: this never reaches disk.
 * It is captured through whatever console the shell happens to have, so the
 * convention that applies is the console's. The receipt is the other case, and
 * takes the checkout's ending from `checkoutNewline` below.
 */
const EMITTED_NEWLINE = os.EOL;

/**
 * Padded as well as truncated, so an absent object name occupies the column
 * rather than closing it up and shifting everything to its right.
 */
const ABBREVIATED_LENGTH = 7;
const abbreviate = (objectName) => objectName.padEnd(ABBREVIATED_LENGTH).slice(0, ABBREVIATED_LENGTH);

/**
 * The repository root, from `--repo` or from where this script sits.
 *
 * @param {string[]} argv the arguments after the script name
 * @returns {string} an absolute path
 */
function repositoryRoot(argv) {
  const flag = argv.indexOf('--repo');
  if (flag !== -1 && argv[flag + 1]) return path.resolve(argv[flag + 1]);
  return path.resolve(__dirname, '..', '..');
}

/**
 * One git invocation, whose failure is an answer rather than an exception.
 *
 * Two of the five reads ask a question git answers with its exit code, so a
 * non-zero status is returned as `ok: false` and never thrown — a throw here
 * would turn "the marker's commit is gone" into a crash instead of a refusal.
 *
 * **The output comes back in two shapes, and they are not interchangeable.**
 * `out` is a scalar answer with the surrounding whitespace gone — an object
 * name, a count, a config value. `lines` removes the line terminators and
 * nothing else, because **a line's own leading whitespace can be data**:
 * `git status --porcelain` writes the index status in column 1, and for an
 * unstaged modification that column *is* a space. Trimming the whole output
 * eats that space from the first line and from no other, so exactly one path
 * loses its first character — which is why one field cannot serve both callers,
 * and why a caller reaching for `out` and splitting it is the bug rather than
 * the fix.
 *
 * @param {string} repo the repository root
 * @param {string[]} args the git arguments, without `-C`
 * @param {NodeJS.ProcessEnv} [env] the environment to run under
 * @returns {{ok: boolean, out: string, lines: string[]}} whether it succeeded,
 *   its output as a scalar, and its output as lines
 */
function git(repo, args, env) {
  const result = spawnSync('git', ['-C', repo, ...args], {
    encoding: 'utf8',
    env: env || process.env,
  });
  const emitted = result.stdout || '';
  return {
    ok: result.status === 0,
    out: emitted.trim(),
    lines: emitted.split(/\r?\n/).filter((line) => line !== ''),
  };
}

/**
 * The tree fingerprint: a git tree object built through a throwaway index seeded
 * from the repository's own.
 *
 * The seeding is not an optimisation. A fresh index carries no stat cache, so
 * `git add -A` would re-hash every file in the worktree on every stage and the
 * check would cost more than the reads it replaces. The repository's own index is
 * never written — the copy is what git is pointed at.
 *
 * @param {string} repo the repository root
 * @returns {string} the tree object's name
 */
function treeFingerprint(repo) {
  const index = git(repo, ['rev-parse', '--path-format=absolute', '--git-path', 'index']).out;
  const throwaway = path.join(
    os.tmpdir(),
    `aep-index-${process.pid}-${Date.now()}-${Math.random().toString(36).slice(2)}`,
  );
  // A repository that has staged nothing yet has no index to seed from; git
  // creates the throwaway one on the first `add`, which costs the stat cache
  // and nothing else.
  if (index && fs.existsSync(index)) fs.copyFileSync(index, throwaway);
  const scoped = { ...process.env, GIT_INDEX_FILE: throwaway };
  try {
    git(repo, ['add', '-A'], scoped);
    return git(repo, ['write-tree'], scoped).out;
  } finally {
    fs.rmSync(throwaway, { force: true });
  }
}

/**
 * The line ending git puts in this checkout's working tree.
 *
 * **Asked of git, never sampled from a file.** A detector that reads some
 * neighbouring file to guess produces a confident wrong ending whenever that
 * file happens to be absent or happens to have been written by something else —
 * and the receipt's own path is absent by definition on a first run.
 * `git check-attr` answers from the attributes actually in force and needs no
 * file to exist, which is what makes this detection rather than inference.
 *
 * Four steps. Each is a fact git states, and the order is git's own precedence,
 * so the answer is the one git would apply rather than a plausible one:
 *
 * 1. **the `eol` attribute in force for the path** — a pin in `.gitattributes`
 *    overrides every clone's own setting, so it is asked first.
 * 2. **`core.autocrlf`** — `true` converts to CRLF on checkout, `input` leaves
 *    LF. Git ignores `core.eol` whenever this is set to either, so it is asked
 *    before it rather than after.
 * 3. **`core.eol`** — `lf` or `crlf` where the clone states one.
 * 4. **the platform's**, which is what git's own default of `native` means.
 *
 * A step that git cannot answer falls to the next, and only the last has no
 * next. Nothing here throws, so a repository git will not talk to at all lands
 * on the platform's ending by the same path a plain checkout does.
 *
 * @param {string} repo the repository root
 * @param {string} forPath the repository-relative path whose ending is wanted
 * @returns {string} `'\n'` or `'\r\n'`
 */
function checkoutNewline(repo, forPath) {
  // `-z` because the record is `<path> NUL <attribute> NUL <value>`, and a path
  // containing a colon makes the human-readable form ambiguous.
  const record = git(repo, ['check-attr', '-z', 'eol', '--', forPath]).out.split('\0');
  const pinned = record[2];
  if (pinned === 'lf') return '\n';
  if (pinned === 'crlf') return '\r\n';

  const converting = git(repo, ['config', '--get', 'core.autocrlf']).out.toLowerCase();
  if (converting === 'true') return '\r\n';
  if (converting === 'input') return '\n';

  const configured = git(repo, ['config', '--get', 'core.eol']).out.toLowerCase();
  if (configured === 'lf') return '\n';
  if (configured === 'crlf') return '\r\n';

  return os.EOL;
}

/**
 * The layout is part of the contract rather than a formatting choice: a stage
 * quotes this output verbatim under its own judgement half, so a column that
 * moved would move in whatever the stage went on to say.
 */
function reportLine(label, columns) {
  const INDENT = '  ';
  const LABEL_FIELD = 6;
  const GUTTER = '  ';
  return INDENT + label.padEnd(LABEL_FIELD) + GUTTER + columns;
}

function main(argv) {
  const repo = repositoryRoot(argv);

  // Repository-relative and slash-separated, because git is asked about the
  // receipt's path as well as the filesystem, and git speaks only this form.
  const POSITION_DIRECTORY = '.claude/position';
  const MARKER = `${POSITION_DIRECTORY}/marker.json`;
  const RECEIPT = `${POSITION_DIRECTORY}/receipt.json`;
  const inRepository = (relative) => path.join(repo, ...relative.split('/'));

  const positionDirectory = inRepository(POSITION_DIRECTORY);
  const markerPath = inRepository(MARKER);
  const receiptPath = inRepository(RECEIPT);

  // The run identity is observed rather than documented: it carries the right
  // value in a tool call, but the reference names only the effort level as
  // reaching one. So it is never required — absent, the receipt attests on the
  // commit alone and the report says which mode it ran in. A downgrade nobody
  // states is a downgrade nobody can detect, which is why this is a field rather
  // than something a reader infers.
  const runIdentity = process.env.CLAUDE_CODE_SESSION_ID || null;
  const mode = runIdentity ? 'session' : 'commit-only';
  const modeLine = runIdentity ? `session ${runIdentity}` : 'commit-only (run identity unavailable)';

  /**
   * `head` and `tree` are what was **observed**, never what the marker said. The
   * commit stage asks whether a receipt attests the position that is live now,
   * and a receipt echoing the marker would answer a different question.
   */
  const writeReceipt = (head, tree) => {
    fs.mkdirSync(positionDirectory, { recursive: true });
    const receipt = { run: runIdentity, mode, head, tree };
    // The receipt reaches disk, so its ending is the one git puts there rather
    // than the one this platform prefers. `JSON.stringify` always separates with
    // a bare newline, whatever that turns out to be.
    const written = checkoutNewline(repo, RECEIPT);
    const body = JSON.stringify(receipt, null, 2).split('\n').join(written) + written;
    fs.writeFileSync(receiptPath, body, 'utf8');
  };

  const emit = (lines) => process.stdout.write(lines.join(EMITTED_NEWLINE) + EMITTED_NEWLINE);

  const refuse = (markerLine, consequence, head, tree) => {
    writeReceipt(head, tree);
    emit([
      'Position',
      reportLine('marker', markerLine),
      // ASCII, deliberately. Emitted output is captured through whatever console
      // encoding the shell happens to have, and a non-ASCII character does not
      // survive one that is not UTF-8 — it arrives as `?`, in a report that still
      // looks well-formed.
      `  -> ${consequence}`,
      reportLine('mode', modeLine),
    ]);
  };

  const head = git(repo, ['rev-parse', 'HEAD']).out;
  const live = treeFingerprint(repo);

  if (!fs.existsSync(markerPath)) {
    // A missing marker file is an answer, not a prompt to look elsewhere: nothing
    // was ever verified in this clone. No other path is tried.
    refuse(
      'absent',
      'nothing was verified in this clone; everything the request touches is unverified',
      head,
      live,
    );
    return 0;
  }

  // A byte-order mark is legal in front of JSON somebody's editor wrote and is
  // not something `JSON.parse` accepts, so it is removed rather than crashed on.
  const marker = JSON.parse(fs.readFileSync(markerPath, 'utf8').replace(/^\uFEFF/, ''));
  const markerCommit = typeof marker.commit === 'string' ? marker.commit : '';
  // A marker carrying no tree fact means the tree is unknown, which is not a
  // fourth refusal — it takes the differing branch, so the drift reads run.
  // Unknown resolving to "read it" is the safe direction; the reverse would skip
  // a read on the strength of a fact nobody recorded.
  const markerTree = typeof marker.tree === 'string' ? marker.tree : '';

  if (!git(repo, ['cat-file', '-e', `${markerCommit}^{commit}`]).ok) {
    refuse(
      `${abbreviate(markerCommit)}  gone from this clone`,
      'no diff is possible from it; everything the request touches is unverified',
      head,
      live,
    );
    return 0;
  }

  if (!git(repo, ['merge-base', '--is-ancestor', markerCommit, 'HEAD']).ok) {
    refuse(
      `${abbreviate(markerCommit)}  HEAD ${abbreviate(head)}   not an ancestor`,
      'the diff between them is meaningless; everything the request touches is unverified',
      head,
      live,
    );
    return 0;
  }

  const commitMatches = markerCommit === head;
  const treeMatches = markerTree === live;

  const commitVerdict = commitMatches
    ? 'commit match'
    : `${git(repo, ['rev-list', '--count', `${markerCommit}..HEAD`]).out} commits ahead`;
  const treeVerdict = treeMatches ? 'tree match' : 'tree differs';

  const lines = [
    'Position',
    reportLine(
      'marker',
      `${abbreviate(markerCommit)}  HEAD ${abbreviate(head)}   ${commitVerdict}`,
    ),
    reportLine(
      'tree',
      `${abbreviate(markerTree)}  live ${abbreviate(live)}   ${treeVerdict}`,
    ),
  ];

  if (commitMatches && treeMatches) {
    lines.push(reportLine('drift', 'reads skipped'));
  } else {
    // Read only when an identity differs. A match on both licenses skipping
    // these, and skipping them is the entire point of the marker.
    const committed = git(repo, [
      'diff',
      '--name-only',
      `${markerCommit}..HEAD`,
      '--',
      '.',
      ':(exclude).claude/',
    ]).lines;
    // Each porcelain line is `XY<space><path>`: status in columns 1 and 2, path
    // from column 4. Splitting on the first space instead mis-reads ` M` —
    // modified but unstaged — as a one-character status. Taken as `lines` and
    // not as a trimmed scalar for the same reason: column 1 is a space there,
    // and the path is what a trim would eat into.
    const uncommitted = git(repo, ['status', '--porcelain', '--untracked-files=all']).lines.map(
      (entry) => entry.slice(3),
    );

    lines.push(reportLine('drift', `${committed.length} committed, ${uncommitted.length} uncommitted`));
    // Never truncated: a capped list hides the one path that mattered and
    // reports the same shape as a complete one.
    for (const changed of [...committed, ...uncommitted]) lines.push('            ' + changed);
  }

  lines.push(reportLine('mode', modeLine));

  writeReceipt(head, live);
  emit(lines);
  return 0;
}

process.exitCode = main(process.argv.slice(2));
