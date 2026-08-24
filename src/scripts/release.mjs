// Cuts a release: stamps what changed, and only what changed.
//
// `aep:` is the release in which an artifact's content last changed. Under the
// sweep this replaces, every protocol-owned artifact was restamped every release
// whether or not it had moved, so the field distinguished nothing, and an
// artifact edited without being restamped was undetectable, because everything
// was restamped regardless.
//
// The baseline is `stamps.json`: one hash per shipped artifact, committed. Not
// git tags. `verify.mjs` is the only thing that catches a broken build here, and
// making it depend on tags being present in whatever checkout runs it puts the
// suite at the mercy of how the repository was cloned.
//
// The hash covers content with the `aep:` and `date:` lines removed, which is
// what makes this converge: stamping a file changes those two lines and nothing
// else, so a stamped file hashes exactly as it did before, and a second run finds
// nothing to do.
//
//   node src/scripts/release.mjs <version> [--dry-run]

import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { toPosix, walk } from './contract.mjs';
import { PAYLOAD_DIRS, PAYLOAD_FILES, SEEDS } from './payload.mjs';

const SRC = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const REPO = path.dirname(SRC);

/** The committed baseline. Machine-written; nothing reads it at runtime. */
export const STAMPS = path.join(SRC, 'stamps.json');

/**
 * Every artifact the distribution ships and therefore stamps: the payload, plus
 * the seeds, which are stamped too even though a repository owns them once they
 * land.
 */
export function shippedArtifacts() {
  const files = PAYLOAD_FILES.map((file) => path.join(SRC, file));
  for (const dir of PAYLOAD_DIRS) {
    const full = path.join(SRC, dir);
    if (fs.existsSync(full)) files.push(...walk(full).filter((f) => f.endsWith('.md')));
  }
  for (const seed of SEEDS) files.push(path.join(SRC, ...seed.source.split('/')));
  return [...new Set(files)].filter((file) => fs.existsSync(file)).sort();
}

/**
 * The artifact's content with the two computed lines removed.
 *
 * Anything else moves the hash and earns the file a new stamp: a word of prose,
 * a frontmatter field, a line of a table.
 */
export function contentHash(text) {
  const stable = text
    .split('\n')
    .filter((line) => !/^aep:\s/.test(line) && !/^date:\s/.test(line))
    .join('\n');
  return createHash('sha256').update(stable).digest('hex');
}

export function readStamps() {
  if (!fs.existsSync(STAMPS)) return {};
  return JSON.parse(fs.readFileSync(STAMPS, 'utf8'));
}

function writeStamps(stamps, dryRun) {
  if (dryRun) return;
  const ordered = Object.fromEntries(Object.keys(stamps).sort().map((k) => [k, stamps[k]]));
  fs.writeFileSync(STAMPS, `${JSON.stringify(ordered, null, 2)}\n`, 'utf8');
}

/** Rewrites one frontmatter field in place, leaving everything else alone. */
function setField(text, field, value) {
  return text.replace(new RegExp(`^${field}:.*$`, 'm'), `${field}: ${value}`);
}

function main() {
  const args = process.argv.slice(2);
  const version = args.find((arg) => /^\d+\.\d+\.\d+$/.test(arg));
  const dryRun = args.includes('--dry-run');

  if (!version) {
    process.stderr.write('usage: node src/scripts/release.mjs <version> [--dry-run]\n');
    process.exit(2);
  }

  const today = new Date().toISOString().slice(0, 10);
  const stamps = readStamps();
  const bootstrap = path.join(SRC, 'protocol.md');
  const changed = [];
  const unchanged = [];
  const next = {};

  // The baseline still records what each artifact hashed to, because that is what
  // catches an edit that never shipped. What is gone is writing the release back
  // into every artifact: `aep:` and `date:` said on sixty-nine files what the
  // bootstrap says once, and the hash never covered them anyway, so removing the
  // lines moves no hash and loses no detection.
  for (const file of shippedArtifacts()) {
    const rel = toPosix(SRC, file);
    const hash = contentHash(fs.readFileSync(file, 'utf8'));
    next[rel] = hash;
    (stamps[rel] === hash ? unchanged : changed).push(rel);
  }

  // The bootstrap is the tree's version marker, read by install.mjs to decide
  // which moves and notices apply. It is the one write.
  const bootstrapText = fs.readFileSync(bootstrap, 'utf8');
  const stamped = setField(bootstrapText, 'version', version);
  if (!dryRun && stamped !== bootstrapText) fs.writeFileSync(bootstrap, stamped, 'utf8');

  const orphans = Object.keys(stamps).filter((rel) => !(rel in next));
  writeStamps(next, dryRun);

  // specs.md is the version of record; the plugin manifest and the adapter are
  // derived from it, so all three move here rather than in three places.
  const specsFile = path.join(REPO, 'specs.md');
  const specs = fs.readFileSync(specsFile, 'utf8')
    .replace(/^\*\*Version:\*\*\s*\S+/m, `**Version:** ${version}`);
  if (!dryRun) fs.writeFileSync(specsFile, specs, 'utf8');

  const manifestFile = path.join(SRC, 'adapters', 'claude', '.claude-plugin', 'plugin.json');
  const manifest = fs.readFileSync(manifestFile, 'utf8')
    .replace(/"version":\s*"[^"]*"/, `"version": "${version}"`);
  if (!dryRun) fs.writeFileSync(manifestFile, manifest, 'utf8');

  if (!dryRun) {
    execFileSync(process.execPath, [path.join(SRC, 'scripts', 'adapters.mjs')], { stdio: 'ignore' });
  }

  process.stdout.write(`${dryRun ? 'would release' : 'released'} ${version}\n`);
  process.stdout.write(`  ${changed.length} artifacts changed since the last release\n`);
  for (const rel of changed) process.stdout.write(`      ${rel}\n`);
  process.stdout.write(`  ${unchanged.length} unchanged\n`);
  if (orphans.length > 0) {
    process.stdout.write(`  ${orphans.length} dropped from the manifest, no longer shipped:\n`);
    for (const rel of orphans) process.stdout.write(`      ${rel}\n`);
  }
  if (!dryRun) {
    process.stdout.write('\nnext: node src/scripts/verify.mjs, then write the changelog\n');
  }
}

if (process.argv[1] && fileURLToPath(import.meta.url) === path.resolve(process.argv[1])) main();
