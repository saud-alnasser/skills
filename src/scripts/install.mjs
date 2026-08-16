// Installs the protocol-owned payload into a repository's `.aep/`.
//
// The one rule that shapes every branch here: an upgrade may replace what the
// protocol owns and must never touch what the repository owns. So nothing is
// overwritten on the strength of its path — each existing target is read and its
// declared `owner` decides, because a repository is entitled to add a rule whose
// filename happens to match a shipped one, and losing it would be exactly the
// silent overwrite the ownership rule forbids.
//
// Seeds are the same principle from the other side: shipped as repository-owned
// starting points, written once, and never reconsidered by any later run.
//
//   node install.mjs --into <repo> [--update] [--adapters claude] [--dry-run]

import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { readArtifact, walk } from './contract.mjs';
import { writeClaudeAdapter } from './adapters.mjs';
import {
  GITIGNORE_SOURCE,
  PAYLOAD_DIRS,
  PAYLOAD_FILES,
  PAYLOAD_SCRIPTS,
  PER_CLONE_DIRS,
  REPOSITORY_DIRS,
  SEEDS,
} from './payload.mjs';

const report = { written: [], preserved: [], seeded: [], skipped: [], retired: [], created: [] };

/** The distribution root — `src/`, since this script lives in `src/scripts/`. */
function distributionRoot() {
  return path.dirname(path.dirname(fileURLToPath(import.meta.url)));
}

/**
 * True when an existing target must not be overwritten.
 * A file the repository declared as its own is protected; anything else —
 * including a file with no frontmatter at all — is the protocol's to replace.
 */
function repositoryOwned(target) {
  if (!fs.existsSync(target)) return false;
  if (!target.endsWith('.md')) return false;
  return readArtifact(target).fields.owner === 'repository';
}

function copyFile(source, target, dryRun) {
  if (repositoryOwned(target)) {
    report.preserved.push(target);
    return;
  }
  if (!dryRun) {
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.copyFileSync(source, target);
  }
  report.written.push(target);
}

function copyDir(sourceDir, targetDir, dryRun) {
  if (!fs.existsSync(sourceDir)) return;
  const shipped = new Set();
  for (const source of walk(sourceDir)) {
    const relative = path.relative(sourceDir, source);
    shipped.add(relative.split(path.sep).join('/'));
    copyFile(source, path.join(targetDir, relative), dryRun);
  }

  // A protocol-owned file present in the repository but no longer shipped was
  // retired by a release. It is reported, never deleted: deciding a file is
  // obsolete is /prune's job and the human's call.
  if (fs.existsSync(targetDir)) {
    for (const existing of walk(targetDir)) {
      const relative = path.relative(targetDir, existing).split(path.sep).join('/');
      if (shipped.has(relative)) continue;
      if (existing.endsWith('.md') && readArtifact(existing).fields.owner === 'protocol') {
        report.retired.push(existing);
      }
    }
  }
}

/**
 * Evidence that this repository is already running AEP 1.x.
 *
 * 1.x kept its state under the runtime's own directory, so `.aep/` is absent and
 * every "is AEP installed here?" check that looks only for `.aep/protocol.md`
 * answers *no*. Installing on that answer produces a fresh 2.0 tree beside a
 * live 1.x one, orphaning every context, spec, ticket, and decision the
 * repository had — reported as a successful install.
 *
 * Detection is by layout rather than by any version string, because the field
 * that would carry a version is itself one of the things that changed.
 */
function legacyLayout(repo) {
  const found = [];
  for (const runtime of ['.claude', '.cursor', '.codex']) {
    const base = path.join(repo, runtime);
    if (!fs.existsSync(base)) continue;
    for (const marker of ['protocol.md', 'policies', 'decisions', 'designs']) {
      if (fs.existsSync(path.join(base, marker))) found.push(`${runtime}/${marker}`);
    }
  }
  return found;
}

/** Whether a seed's evidence is present in the repository. */
function detected(repo, detect) {
  if (!detect) return true;
  if (detect.paths?.some((candidate) => fs.existsSync(path.join(repo, candidate)))) return true;
  if (detect.remote) {
    try {
      const remotes = execFileSync('git', ['remote', '-v'], {
        cwd: repo,
        encoding: 'utf8',
        stdio: ['ignore', 'pipe', 'ignore'],
      });
      if (remotes.includes(detect.remote)) return true;
    } catch {
      // No git, or no remotes. Absence of evidence, so the seed does not install.
    }
  }
  return false;
}

/** Seeds install once. An existing target is left exactly as it is. */
function installSeeds(repo, from, aep, dryRun) {
  for (const seed of SEEDS) {
    // The entrypoint is the one seed that lands outside `.aep/`: the harness
    // loads it by name from the repository root, so it cannot live in the tree.
    const base = seed.root ? repo : aep;
    const target = path.join(base, ...seed.target.split('/'));
    if (fs.existsSync(target)) {
      report.skipped.push(`${seed.target} (already present)`);
      continue;
    }
    if (!detected(repo, seed.detect)) {
      report.skipped.push(`${seed.target} (not detected)`);
      continue;
    }
    if (!dryRun) {
      fs.mkdirSync(path.dirname(target), { recursive: true });
      fs.copyFileSync(path.join(from, ...seed.source.split('/')), target);
    }
    report.seeded.push(seed.target);
  }
}

function ensureDir(target, dryRun) {
  if (fs.existsSync(target)) return;
  if (!dryRun) fs.mkdirSync(target, { recursive: true });
  report.created.push(target);
}

function main() {
  const args = process.argv.slice(2);
  const value = (flag, fallback) =>
    args.includes(flag) ? args[args.indexOf(flag) + 1] : fallback;

  const repo = path.resolve(value('--into', process.cwd()));
  const from = path.resolve(value('--from', distributionRoot()));
  const dryRun = args.includes('--dry-run');
  const adapters = value('--adapters', null);
  const aep = path.join(repo, '.aep');

  if (!fs.existsSync(path.join(from, 'protocol.md'))) {
    process.stderr.write(`no AEP distribution at ${from} — expected protocol.md there\n`);
    process.exit(2);
  }
  if (!fs.existsSync(repo)) {
    process.stderr.write(`no such directory: ${repo}\n`);
    process.exit(2);
  }

  const existing = fs.existsSync(path.join(aep, 'protocol.md'));
  if (existing && !args.includes('--update')) {
    process.stderr.write(
      'this repository already has .aep/ — use --update, so repository-owned files are preserved deliberately\n',
    );
    process.exit(2);
  }

  // A fresh install onto a 1.x tree is the one failure that reports success, so
  // it is refused here rather than left to the caller to remember. `--migrate`
  // is the deliberate path, and it is what /update's migration passes.
  const legacy = legacyLayout(repo);
  if (legacy.length > 0 && !args.includes('--migrate') && !args.includes('--update')) {
    process.stderr.write(
      `this repository is running AEP 1.x (${legacy.join(', ')})\n` +
        'installing over it would orphan its contexts, specs, tickets, and decisions.\n' +
        'run /update, which converts what 2.0 has a representation for; or pass --migrate\n' +
        'if you are performing that conversion now.\n',
    );
    process.exit(2);
  }

  for (const file of PAYLOAD_FILES) {
    copyFile(path.join(from, file), path.join(aep, file), dryRun);
  }
  for (const dir of PAYLOAD_DIRS) {
    copyDir(path.join(from, dir), path.join(aep, dir), dryRun);
  }
  for (const script of PAYLOAD_SCRIPTS) {
    copyFile(path.join(from, 'scripts', script), path.join(aep, 'scripts', script), dryRun);
  }

  for (const dir of [...REPOSITORY_DIRS, ...PER_CLONE_DIRS]) {
    ensureDir(path.join(aep, dir), dryRun);
  }

  installSeeds(repo, from, aep, dryRun);

  const ignoreTarget = path.join(aep, '.gitignore');
  if (!dryRun) fs.copyFileSync(path.join(from, GITIGNORE_SOURCE), ignoreTarget);
  report.written.push(ignoreTarget);

  if (adapters === 'claude' && !dryRun) {
    for (const relative of writeClaudeAdapter(from, path.join(repo, '.claude'), 'repository')) {
      report.written.push(path.join(repo, '.claude', relative));
    }
  }

  const relative = (file) => path.relative(repo, file).split(path.sep).join('/');
  const list = (label, entries, format = relative) => {
    if (entries.length === 0) return;
    process.stdout.write(`  ${entries.length} ${label}:\n`);
    for (const entry of entries) process.stdout.write(`      ${format(entry)}\n`);
  };

  process.stdout.write(`${dryRun ? 'would install' : 'installed'} into ${repo}\n`);
  process.stdout.write(`  ${report.written.length} protocol files written\n`);
  process.stdout.write(`  ${report.created.length} directories created\n`);
  list('repository-owned starting points seeded — review each', report.seeded, (entry) => entry);
  list('seeds skipped', report.skipped, (entry) => entry);
  list('repository-owned files preserved', report.preserved);
  list('protocol files no longer shipped — review, then /prune', report.retired);

  if (!dryRun) {
    process.stdout.write('\nnext: node .aep/scripts/index.mjs && node .aep/scripts/validate.mjs\n');
  }
}

main();
