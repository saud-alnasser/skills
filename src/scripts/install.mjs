// Installs the protocol-owned payload into a repository's `.aep/`.
//
// The one rule that shapes every branch here: an upgrade may replace what the
// protocol owns and must never touch what the repository owns. Ownership is a
// fact about location, so a target is overwritten exactly when the manifest in
// `contract.mjs` names it and preserved otherwise. That manifest is generated
// from the payload, so it cannot disagree with what is being copied.
//
// The consequence worth stating: a repository file cannot stand at a path the
// protocol ships. It is not silently overwritten so much as impossible to have,
// because `validate.mjs` fails on a file in a protocol directory that the
// manifest does not name.
//
// Seeds are the same principle from the other side: shipped as repository-owned
// starting points, written once, and never reconsidered by any later run.
//
//   node install.mjs --into <repo> [--update] [--adapters claude] [--dry-run]

import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { readArtifact, walk, toPosix, isProtocolPath } from './contract.mjs';
import { renderAdapter, writeAdapter, TARGETS } from './adapters.mjs';
import {
  GITIGNORE_SOURCE,
  MOVES,
  NOTICES,
  PAYLOAD_DIRS,
  PAYLOAD_FILES,
  PAYLOAD_SCRIPTS,
  PER_CLONE_DIRS,
  REPOSITORY_DIRS,
  SEEDS,
} from './payload.mjs';

const report = {
  written: [], preserved: [], seeded: [], skipped: [], retired: [], created: [], edited: [],
  moved: [], collided: [], relinked: [], notices: [], warnings: [], adapters: [],
};

/** The distribution root, `src/`, since this script lives in `src/scripts/`. */
function distributionRoot() {
  return path.dirname(path.dirname(fileURLToPath(import.meta.url)));
}

/**
 * True when an existing target must not be overwritten.
 * A path the manifest does not name belongs to the repository, whatever it
 * contains and whether or not it has frontmatter at all.
 */
function repositoryOwned(aep, target) {
  if (!fs.existsSync(target)) return false;
  return !isProtocolPath(toPosix(aep, target));
}

function copyFile(source, target, aep, dryRun) {
  if (repositoryOwned(aep, target)) {
    report.preserved.push(target);
    return;
  }
  // The protection the `owner:` field used to give, recovered from content.
  // A path the protocol ships is the protocol's whatever stands there, so this
  // does not refuse the write. It refuses to make it silently, which is the
  // half that mattered: somebody edited a shipped file, or wrote their own
  // where one lands, and either way they are told rather than finding out later.
  if (fs.existsSync(target) && fs.readFileSync(target, 'utf8') !== fs.readFileSync(source, 'utf8')) {
    report.edited.push(target);
  }
  if (!dryRun) {
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.copyFileSync(source, target);
  }
  report.written.push(target);
}

function copyDir(sourceDir, targetDir, aep, dryRun) {
  if (!fs.existsSync(sourceDir)) return;
  const shipped = new Set();
  for (const source of walk(sourceDir)) {
    const relative = path.relative(sourceDir, source);
    shipped.add(relative.split(path.sep).join('/'));
    copyFile(source, path.join(targetDir, relative), aep, dryRun);
  }

  // A file left in a protocol directory that this release does not ship is
  // either one a release retired or one the repository put somewhere it may not.
  // The manifest names what ships now and so cannot tell them apart, and neither
  // is deleted here: deciding a file is obsolete is /prune's job and the human's
  // call, and a misplaced repository file is /validate's to name.
  if (fs.existsSync(targetDir)) {
    for (const existing of walk(targetDir)) {
      const relative = path.relative(targetDir, existing).split(path.sep).join('/');
      if (shipped.has(relative)) continue;
      report.retired.push(existing);
    }
  }
}

/** A release as three numbers, or null when the string is not one. */
function release(value) {
  const parsed = /^(\d+)\.(\d+)\.(\d+)$/.exec(String(value ?? ''));
  return parsed ? parsed.slice(1, 4).map(Number) : null;
}

/** Whether `a` precedes `b`. Either being unparseable answers false. */
function precedes(a, b) {
  const left = release(a);
  const right = release(b);
  if (!left || !right) return false;
  for (let i = 0; i < 3; i += 1) {
    if (left[i] !== right[i]) return left[i] < right[i];
  }
  return false;
}

/**
 * Applies the release's declared moves. Only under `--update`.
 *
 * A protocol-owned source is removed, because its content now ships at the
 * target and two copies of one text is worse than none. A **repository-owned**
 * file standing at the same path is not the protocol's to remove. The
 * repository wrote its own rule under a name the protocol has since vacated,
 * which is legal, so it stays, and the collision is reported for a human.
 *
 * A move applies only to a tree that predates it. Without that bound, a
 * repository which later writes its own `rules/precedence.md`, which it is
 * entitled to do once the name is vacated, would be reported as colliding
 * on every upgrade it ever runs, forever. A tree declaring nothing is treated as
 * predating everything: unknown is not the same as current, and the move only
 * ever removes a protocol-owned file whose content still exists at the target.
 *
 * Returns the moves whose source path is now vacant, which is what the link
 * repair below acts on. Derived from what was decided rather than from what is
 * on disk, so a dry run previews the same repairs a real run would make.
 */
/**
 * Collects the notices for the releases this upgrade actually crosses.
 *
 * Gated by the same predicate as `applyMoves`, deliberately: a notice and a move
 * declared by one release must not disagree about whether that release is being
 * crossed. A tree declaring nothing predates everything, for the same reason it
 * does there: unknown is not the same as current.
 *
 * Nothing is decided here about whether a notice is *relevant*. Relevance is two
 * release numbers, and judgement at this point is what would make the output
 * untrustworthy.
 */
function collectNotices(declared) {
  for (const notice of NOTICES) {
    if (declared && !precedes(declared, notice.since)) continue;
    report.notices.push(notice);
  }
}

function applyMoves(aep, declared, dryRun) {
  const vacated = [];
  for (const move of MOVES) {
    if (declared && !precedes(declared, move.since)) continue;
    const source = path.join(aep, ...move.from.split('/'));
    if (!fs.existsSync(source)) continue;
    if (readArtifact(source).fields.owner === 'repository') {
      report.collided.push(`${move.from} is the repository's; ${move.to} now ships the protocol's`);
      continue;
    }
    if (!dryRun) fs.rmSync(source);
    report.moved.push(`${move.from} → ${move.to}`);
    vacated.push(move);
  }
  return vacated;
}

/**
 * Repairs links into files the moves vacated.
 *
 * The only thing in this program that writes into a file the repository owns,
 * so every condition here is a narrowing:
 *
 * - repository-owned Markdown only. Protocol-owned files are replaced wholesale
 *   by the copy above, and the generated index is regenerated straight after;
 * - only the nine declared targets, never a pattern;
 * - **outside fenced blocks only.** A link inside a fence is the syntax being
 *   shown rather than a reference being made, which is why the link checker
 *   strips fences before looking. Rewriting one edits somebody's example;
 *   leaving it costs nothing, because nothing was ever going to resolve it;
 * - **only where the source path is now vacant.** A repository that kept its own
 *   `rules/<name>.md` has a link that correctly points at *its* file, and
 *   redirecting that to a policy it never referenced would break a live link to
 *   fix an imaginary one;
 * - the target is replaced and nothing else. An alias or anchor the link
 *   carried survives verbatim, and no anchor is ever constructed.
 *
 * The file's `date` moves with it. `date` is the last-modified date and nothing
 * checks it, so a repair that leaves it alone leaves a false freshness claim in
 * a file the repository owns. It is one more field in a write that is happening
 * anyway, not a wider reach.
 */
function rewriteMovedLinks(aep, vacated, today, dryRun) {
  const moved = new Map(
    vacated.map((move) => [move.from.replace(/\.md$/, ''), move.to.replace(/\.md$/, '')]),
  );
  if (moved.size === 0) return;

  const derivedIndex = path.join(aep, 'index.md');
  for (const file of walk(aep, { skip: ['position', 'worktrees'] })) {
    // The index is derived and regenerated straight after, so repairing it is
    // work that is about to be thrown away. Matched by path rather than by
    // basename: a repository may legitimately own some other `index.md`.
    if (!file.endsWith('.md') || file === derivedIndex) continue;
    if (readArtifact(file).fields.owner !== 'repository') continue;

    const before = fs.readFileSync(file, 'utf8');
    let replaced = 0;
    // One pass over fences and links together, so a fence is consumed whole and
    // the links inside it are never offered up for rewriting.
    const after = before.replace(
      /(^```[\s\S]*?^```)|\[\[([^\]|#]+?)((?:#[^\]|]*)?(?:\|[^\]]*)?)\]\]/gm,
      (whole, fence, target, suffix) => {
        if (fence !== undefined) return fence;
        const destination = moved.get(target.trim());
        if (!destination) return whole;
        replaced += 1;
        return `[[${destination}${suffix}]]`;
      },
    );
    if (replaced === 0) continue;
    const stamped = after.replace(/^date:\s*\d{4}-\d{2}-\d{2}$/m, `date: ${today}`);
    if (!dryRun) fs.writeFileSync(file, stamped, 'utf8');
    report.relinked.push(`${file} (${replaced})`);
  }
}

/**
 * Evidence that this repository is already running AEP 1.x.
 *
 * 1.x kept its state under the runtime's own directory, so `.aep/` is absent and
 * every "is AEP installed here?" check that looks only for `.aep/protocol.md`
 * answers *no*. Installing on that answer produces a fresh 2.0 tree beside a
 * live 1.x one, orphaning every context, spec, ticket, and decision the
 * repository had, reported as a successful install.
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
  const requested = adapters ? adapters.split(',').map((name) => name.trim()).filter(Boolean) : [];
  const aep = path.join(repo, '.aep');

  if (!fs.existsSync(path.join(from, 'protocol.md'))) {
    process.stderr.write(`no AEP distribution at ${from}, expected protocol.md there\n`);
    process.exit(2);
  }
  if (!fs.existsSync(repo)) {
    process.stderr.write(`no such directory: ${repo}\n`);
    process.exit(2);
  }

  const unknown = requested.filter((name) => !(name in TARGETS));
  if (unknown.length > 0) {
    process.stderr.write(
      `unknown runtime${unknown.length === 1 ? '' : 's'}: ${unknown.join(', ')}. ` +
      `Known: ${Object.keys(TARGETS).join(', ')}
`,
    );
    process.exit(2);
  }

  // Both locations are read by OpenCode, so asking for both installs the same
  // eighteen skills twice under one name, and which file the loader keeps is
  // decided by whichever load finishes first. It is a warning rather than a
  // refusal: a repository driven through a harness that reads the neutral
  // location, with a provider that is not OpenCode, has a real use for both.
  if (requested.includes('opencode') && requested.includes('agents')) {
    report.warnings.push(
      'opencode and agents are alternatives inside OpenCode. It reads .opencode/skills ' +
      'and .agents/skills both, so every skill loads twice under one name and which ' +
      'file wins is decided by a race in the loader. Both were written; remove one ' +
      'unless this repository is driven through a harness with a non-OpenCode provider.',
    );
  }

  const existing = fs.existsSync(path.join(aep, 'protocol.md'));

  // Read before the payload overwrites it: what the tree declared on arrival is
  // what decides which moves still apply, and one line later it declares this
  // release instead.
  const declared = existing
    ? readArtifact(path.join(aep, 'protocol.md')).fields.aep
    : null;

  if (existing && !args.includes('--update')) {
    process.stderr.write(
      'this repository already has .aep/. Use --update, so repository-owned files are preserved deliberately\n',
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
    copyFile(path.join(from, file), path.join(aep, file), aep, dryRun);
  }
  for (const dir of PAYLOAD_DIRS) {
    copyDir(path.join(from, dir), path.join(aep, dir), aep, dryRun);
  }
  for (const script of PAYLOAD_SCRIPTS) {
    copyFile(path.join(from, 'scripts', script), path.join(aep, 'scripts', script), aep, dryRun);
  }

  for (const dir of [...REPOSITORY_DIRS, ...PER_CLONE_DIRS]) {
    ensureDir(path.join(aep, dir), dryRun);
  }

  // Moves apply to a tree that already exists, so they belong to an upgrade and
  // to nothing else. A fresh install has nothing at the source paths anyway;
  // the guard is here so that is a stated fact rather than a coincidence.
  if (args.includes('--update')) {
    const today = new Date().toISOString().slice(0, 10);
    rewriteMovedLinks(aep, applyMoves(aep, declared, dryRun), today, dryRun);
    collectNotices(declared);
  }

  installSeeds(repo, from, aep, dryRun);

  const ignoreTarget = path.join(aep, '.gitignore');
  if (!dryRun) fs.copyFileSync(path.join(from, GITIGNORE_SOURCE), ignoreTarget);
  report.written.push(ignoreTarget);

  // Every adapter installs in the repository shape: it is written into a tree
  // that has `.aep/`, so there is nowhere further to fall back to.
  for (const name of requested) {
    const target = TARGETS[name];
    const into = path.join(repo, target.dir);
    const files = dryRun
      ? renderAdapter(from, target, 'repository').map((file) => file.relativePath)
      : writeAdapter(from, target, into, 'repository');
    for (const relative of files) report.written.push(path.join(into, relative));
    // Named rather than folded into the written count: an adapter is a
    // directory outside `.aep/` that the repository now owns, and a reader
    // deciding whether that was what they asked for cannot see it in a total.
    report.adapters.push(`${target.dir}/, ${files.length} wrappers`);
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
  list(`runtime adapter${report.adapters.length === 1 ? '' : 's'} installed`,
    report.adapters, (entry) => entry);
  list('locally edited and replaced, recover from version control if wanted', report.edited);
  list('repository-owned starting points seeded, review each', report.seeded, (entry) => entry);
  list('seeds skipped', report.skipped, (entry) => entry);
  list('repository-owned files preserved', report.preserved);
  list('protocol files moved by this release', report.moved, (entry) => entry);
  list('links repaired in repository-owned files', report.relinked);
  list('name collisions, a repository file stands where a moved one did', report.collided,
    (entry) => entry);
  list('protocol files no longer shipped, review then /prune', report.retired);

  // Last, and not as a counted list. Everything above is what the upgrade did;
  // this is the part it could not do for you, so it is the thing still open when
  // the run ends, which is where a reader is actually looking.
  if (report.notices.length > 0) {
    process.stdout.write(
      `\n${report.notices.length} thing${report.notices.length === 1 ? '' : 's'} to check, ` +
      'crossing these releases:\n',
    );
    for (const notice of report.notices) {
      process.stdout.write(`\n  ${notice.since}\n`);
      // Wrapped here rather than in the declaration, so the text stays one
      // string to write and one string to assert against.
      let line = '   ';
      for (const word of notice.check.split(/\s+/)) {
        if (line.length + word.length + 1 > 76) {
          process.stdout.write(`${line}\n`);
          line = '   ';
        }
        line += ` ${word}`;
      }
      if (line.trim()) process.stdout.write(`${line}\n`);
    }
  }

  // Loudest thing in the run, and last: a warning is about what the caller
  // asked for rather than about what the install did, so it sits where a
  // reader is looking when the run ends.
  for (const warning of report.warnings) {
    process.stdout.write(`
warning: ${warning}
`);
  }

  if (!dryRun) {
    process.stdout.write('\nnext: node .aep/scripts/index.mjs && node .aep/scripts/validate.mjs\n');
  }
}

main();
