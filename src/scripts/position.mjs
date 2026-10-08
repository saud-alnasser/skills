// Reads and stamps `.aep/position/marker.json`, per-working-tree operational
// state. Gitignored, so two linked worktrees of one clone hold two markers and
// two agents sharing one checkout hold one between them. Describing it as
// clone-wide reads as a guarantee in both directions that it does not give.
//
// The marker records two facts and compares both: the commit a stage last read
// the repository against, and a fingerprint of the working tree it read. What a
// match licenses is narrow and the narrowness is the point. It means some
// earlier run already looked at this exact tree, nothing more. It never means
// any knowledge is correct, and it is never a reason to skip checking a
// statement you are about to rely on.
//
// The fingerprint covers content, not just filenames: two different edits to one
// file must not produce the same value, or the marker reports "unchanged" across
// a change. Its separator is written `'\0'` rather than as a literal NUL: the
// byte hashed is the same either way, and the escape is what keeps this file
// text. With a raw NUL in it, grep called the whole file binary and skipped it,
// so every guard that greps the shipped tree passed here by not looking.
//
// `sessions` records who stamped, and is a diagnostic that nothing acts on. A
// session identifier carries no liveness: it cannot be told apart from one left
// by a process that was killed, so a run gating on it would block on the
// leavings of every abnormal exit. Exclusion is git's, and needs no liveness
// because it is not a lease.
//
//   node position.mjs read | stamp | check [--root <path-to-.aep>] [--session <id>]

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { resolveAepRoot } from './contract.mjs';

/** Runs git, returning null rather than throwing. Every caller treats absence as "unknown". */
function git(repo, args) {
  try {
    return execFileSync('git', args, {
      cwd: repo,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
      maxBuffer: 64 * 1024 * 1024,
    });
  } catch {
    return null;
  }
}

function head(repo) {
  const value = git(repo, ['rev-parse', 'HEAD']);
  return value === null ? null : value.trim();
}

/**
 * A content fingerprint of the working tree relative to HEAD: the full diff of
 * tracked changes, plus the list of untracked files. A clean tree hashes to a
 * stable value; any content change moves it.
 */
function treeFingerprint(repo) {
  const diff = git(repo, ['diff', 'HEAD']);
  const untracked = git(repo, ['ls-files', '--others', '--exclude-standard']);
  if (diff === null && untracked === null) return null;
  return crypto
    .createHash('sha256')
    .update(diff ?? '')
    .update('\0')
    .update(untracked ?? '')
    .digest('hex');
}

/**
 * The session list with this identifier recorded against now.
 *
 * Deduplicated by id, because a run stamps once per ticket and an appending
 * list would report one session as a dozen. What the field exists to make
 * visible is a second *identifier* against one marker, which says two agents
 * are sharing a checkout, and that signal is destroyed by counting one agent
 * repeatedly.
 *
 * Nothing prunes an entry. Pruning would mean deciding a session is dead, and
 * an identifier carries nothing that would say so.
 */
function recordSession(previous, id) {
  const at = new Date().toISOString();
  const others = previous.filter((entry) => entry?.id !== id);
  return [...others, { id, at }];
}

function markerPath(root) {
  return path.join(root, 'position', 'marker.json');
}

function readMarker(root) {
  try {
    return JSON.parse(fs.readFileSync(markerPath(root), 'utf8'));
  } catch {
    return null;
  }
}

function writeMarker(root, marker) {
  const file = markerPath(root);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, `${JSON.stringify(marker, null, 2)}\n`, 'utf8');
}

/**
 * Stamps the marker for the tree at `root` (a `.aep/` directory) and returns it.
 * Stamping preserves what it was not told about. With a session the caller's
 * identity is recorded; without one the field is untouched, so a runtime that
 * supplies no identifier stamps exactly as before.
 */
export function stampMarker(root, session = null) {
  const repo = path.dirname(root);
  const existing = readMarker(root);
  const previous = Array.isArray(existing?.sessions) ? existing.sessions : [];
  const marker = {
    tree: treeFingerprint(repo),
    head: head(repo),
    sessions: session ? recordSession(previous, session) : previous,
  };
  writeMarker(root, marker);
  return marker;
}

/**
 * Compares the marker with the tree at `root`. `matches` licenses skipping the
 * drift read, and nothing else.
 */
export function checkMarker(root) {
  const repo = path.dirname(root);
  const marker = readMarker(root);
  if (!marker || (!marker.head && !marker.tree)) {
    return { matches: false, unset: true, message: 'marker: unset. Read drift live; nothing has been established about this tree' };
  }
  const currentHead = head(repo);
  const headMoved = marker.head !== currentHead;
  const treeMoved = marker.tree !== treeFingerprint(repo);
  if (!headMoved && !treeMoved) {
    return {
      matches: true,
      message: 'marker: matches. An earlier run already read this exact tree\nthis licenses skipping the drift read, and nothing else',
    };
  }
  const lines = [];
  if (headMoved) lines.push(`head moved: ${marker.head ?? 'unknown'} -> ${currentHead ?? 'unknown'}`);
  if (treeMoved) lines.push('working tree changed since the marker was written');
  return { matches: false, headMoved, treeMoved, message: lines.join('\n') };
}

function main() {
  const args = process.argv.slice(2);
  const flag = (name) => {
    const at = args.indexOf(name);
    return at === -1 ? null : args[at + 1] ?? null;
  };
  const rootArg = flag('--root');
  const session = flag('--session');

  // A flag's value is a bare word too, so the command is the first bare word
  // that is not one. Without this, `--session abc stamp` reads `abc` as the
  // command and fails on an argument order nobody would think twice about.
  const taken = new Set([rootArg, session].filter(Boolean));
  const command = args.find((arg) => !arg.startsWith('--') && !taken.has(arg)) ?? 'read';

  const root = resolveAepRoot(rootArg, import.meta.url);
  if (!root) {
    process.stderr.write('no .aep/ found. Pass --root, or run from a repository that has one\n');
    process.exit(2);
  }
  const repo = path.dirname(root);

  if (command === 'read') {
    const marker = readMarker(root);
    process.stdout.write(`${JSON.stringify(marker ?? { tree: null, head: null, sessions: [] }, null, 2)}\n`);
    return;
  }

  if (command === 'stamp') {
    const marker = stampMarker(root, session);
    process.stdout.write(`stamped head=${marker.head ?? 'unknown'} tree=${marker.tree?.slice(0, 12) ?? 'unknown'}
`);
    return;
  }

  if (command === 'check') {
    const result = checkMarker(root);
    process.stdout.write(`${result.message}
`);
    if (!result.matches) process.exit(1);
    return;
  }

  process.stderr.write(`unknown command "${command}". Expected read, stamp, or check\n`);
  process.exit(2);
}

if (process.argv[1] && fileURLToPath(import.meta.url) === path.resolve(process.argv[1])) main();
