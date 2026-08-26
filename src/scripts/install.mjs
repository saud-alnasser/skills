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
//   node install.mjs --into <repo> [--update] [--adapters claude]
//                     [--automation github] [--dry-run]

import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import {
  CANONICAL_ENTRYPOINT, RETIRED_FIELDS, readArtifact, walk, toPosix, isProtocolPath,
  isRepositoryNote,
} from './contract.mjs';
import { contentHash } from './release.mjs';
import { renderAdapter, writeAdapter, TARGETS } from './adapters.mjs';
import {
  GITIGNORE_SOURCE,
  MOVES,
  NOTICES,
  PAYLOAD_DIRS,
  PAYLOAD_FILES,
  PAYLOAD_SCRIPTS,
  PER_CLONE_DIRS,
  RETIRED_DIRS,
  REPOSITORY_DIRS,
  SEEDS,
} from './payload.mjs';

const report = {
  written: [], preserved: [], seeded: [], skipped: [], retired: [], created: [], edited: [],
  moved: [], collided: [], relinked: [], notices: [], warnings: [], adapters: [],
  pointed: [], unconverted: [], retiredDirs: [], automation: [],
};

/**
 * Writes a paragraph wrapped, every line under the same indent.
 *
 * Wrapped here rather than in whatever declared the text, so each string stays
 * one string to write and one string to assert against.
 */
function wrapped(text, indent) {
  let line = indent;
  for (const word of text.split(/\s+/)) {
    if (line.length + word.length + 1 > 76) {
      process.stdout.write(`${line}\n`);
      line = indent;
    }
    line += ` ${word}`;
  }
  if (line.trim()) process.stdout.write(`${line}\n`);
}

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
  //
  // A note the repository wrote beside a shipped skill is neither, and it is
  // the one file here the manifest will never name. Reported, it would be
  // offered to the human as protocol residue to prune, so an upgrade would
  // advise deleting the extension point it is required to preserve.
  if (fs.existsSync(targetDir)) {
    for (const existing of walk(targetDir)) {
      const relative = path.relative(targetDir, existing).split(path.sep).join('/');
      if (shipped.has(relative)) continue;
      if (isRepositoryNote(path.relative(aep, existing).split(path.sep).join('/'))) continue;
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

    // Location cannot answer for a move source: the file left the payload, so
    // the manifest does not name it, and a repository may legitimately have
    // written its own under a name the protocol vacated. Content answers it.
    // Anything that is not the protocol's own text, byte for byte under the
    // release hash, is somebody's work and is left where it is.
    if (contentHash(fs.readFileSync(source, 'utf8')) !== move.was) {
      report.collided.push(
        `${move.from} is not the protocol's text; ${move.to} now ships that. Left in place`,
      );
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
    if (isProtocolPath(toPosix(aep, file))) continue;

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
    // `date:` is retired, so a repaired file carries no last-modified stamp to
    // move. Version control records when it changed, and it cannot go stale.
    const stamped = after;
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

/**
 * The merge-time job each forge seed brings with it, keyed by the forge.
 *
 * Read off `SEEDS` rather than listed a second time here. A tracker reference
 * cannot be declared without its automation, so the pairing is already
 * guaranteed one file up, and a list beside it would be somewhere for the two
 * to come apart.
 */
const AUTOMATIONS = Object.fromEntries(
  SEEDS
    .filter((seed) => seed.automation)
    .map((seed) => [path.basename(seed.target, '.md'), seed]),
);

/**
 * Workflow files a repository already has, as repository-relative paths.
 *
 * Relative to the repository rather than rebuilt from a basename: workflows sit
 * in subdirectories often enough, and a path rebuilt from the filename alone
 * names a file that does not exist. Every other traversal here uses `walk`'s
 * path against its root, and this is the same rule.
 */
function existingWorkflows(repo) {
  const dir = path.join(repo, '.github', 'workflows');
  if (!fs.existsSync(dir)) return [];
  return walk(dir)
    .filter((file) => /\.ya?ml$/.test(file))
    .map((file) => toPosix(repo, file));
}

/** A repository file, by the relative path these functions pass around. */
function readAt(repo, relative) {
  return fs.readFileSync(path.join(repo, ...relative.split('/')), 'utf8');
}

/**
 * The shapes an existing labeler is written in, matched against the file rather
 * than against its name: `labeler.yml` is a convention and not a rule, and a
 * repository that assigns labels from a differently named workflow has the same
 * file to add this job to.
 */
const ASSIGNS_LABELS = /actions\/labeler|assign-labels|add-labels|--add-label|add_labels|addLabels/;

/**
 * The sentence a repository writes into its own rule when it declines the job,
 * and the whole of what stops the offer being made again.
 *
 * `[[skills/install]]` quotes this exact sentence to whoever records the
 * decision, and the suite asserts the skill and this constant are the same
 * string. A recorded decision nobody reads is a decision that stops working the
 * day the wording drifts, and the drift is invisible because both halves still
 * read well.
 */
const DECLINED = 'The merge-time status job is declined';

/**
 * Where that decision lives: the repository's own version-control rule.
 *
 * A rule rather than a state file under `.aep/`, because it is a decision about
 * how this repository works and it carries a reason. It is also where the next
 * run is already reading, which is what makes it read rather than merely
 * written.
 */
const DECISION_RULE = 'rules/version-control.md';

/** Whether this repository has already recorded declining the job. */
function declinedHere(aep) {
  const rule = path.join(aep, ...DECISION_RULE.split('/'));
  if (!fs.existsSync(rule)) return false;
  return fs.readFileSync(rule, 'utf8').toLowerCase().includes(DECLINED.toLowerCase());
}

/**
 * The body of one top-level key, without the key itself.
 *
 * What goes under a map a file already has is what sits below that key, so the
 * key is dropped: pasting `on:` into a workflow that already has one is the
 * duplicate this exists to avoid.
 */
function under(text, key) {
  const lines = text.split('\n');
  const start = lines.indexOf(`${key}:`);
  if (start < 0) return '';
  let end = start + 1;
  while (end < lines.length && (lines[end] === '' || lines[end].startsWith(' '))) end += 1;
  return lines.slice(start + 1, end).join('\n').replace(/\s+$/, '');
}

/** The first mapping key in a block, with its colon and without its indentation. */
function firstKey(block) {
  const line = block
    .split('\n')
    .find((entry) => entry.trim() !== '' && !entry.trimStart().startsWith('#'));
  return line ? line.trim() : '';
}

/**
 * A workflow's top-level `on:`, as the line that declares it.
 *
 * Column zero only. An `on:` nested inside something else is not that file's
 * trigger, and reading one as though it were is how a proposal ends up
 * described against the wrong map.
 */
function triggerLine(text) {
  return text.split('\n').find((line) => /^(on|"on"|'on'):/.test(line)) ?? null;
}

/**
 * What stands in the way of pasting the addition into this file, or null where
 * nothing does.
 *
 * The addition is a block of YAML, so it goes in only where the file's own
 * shape can take it. Handing somebody a paste that does not parse breaks a
 * workflow AEP did not author, which is worse than making no offer at all, so
 * an obstacle is named and the offer stops there.
 */
function obstacleInWorkflow(text) {
  const line = triggerLine(text);
  if (line === null) return 'it declares no `on:` at the top level';
  const inline = line.slice(line.indexOf(':') + 1).trim();
  if (inline !== '' && !inline.startsWith('#')) {
    return `its trigger is written inline, as \`${line.trim()}\`, and what would go in `
      + 'is a block';
  }
  const block = under(text, line.slice(0, line.indexOf(':')));
  const indent = block.length - block.trimStart().length;
  const keys = block
    .split('\n')
    .filter((entry) => entry.trim() !== '' && (entry.length - entry.trimStart().length) === indent)
    .map((entry) => entry.trim().split(':')[0]);
  if (keys.includes('pull_request')) {
    return 'it already triggers on `pull_request`, so adding the trigger would declare '
      + 'that key twice';
  }
  return null;
}

/**
 * Where a forge's merge-time job goes, and what it joins where something is
 * already there.
 *
 * `hosts` is what keeps the offer from duplicating: a repository already
 * assigning labels gets the job added to that file rather than a second one
 * beside it, because two files racing over one label family is what a second
 * one would introduce. GitLab reaches the same answer for a different reason,
 * so the two are declared separately rather than sharing a predicate that would
 * read as one rule.
 */
const AUTOMATION_TARGETS = {
  github: {
    file: '.github/workflows/effort-status.yml',
    files: (repo) => existingWorkflows(repo),
    hosts: (repo) => existingWorkflows(repo)
      .filter((rel) => ASSIGNS_LABELS.test(readAt(repo, rel))),
    // A workflow has one `on:` map and one `jobs:` map, so a second copy of
    // either is not a file GitHub will run. The addition is therefore the
    // trigger and the job, each going into the map that is already there, and
    // both are cut from the shipped file rather than written out again: the
    // standalone copy and the addition cannot then say different things.
    addition: (text) => [
      { into: 'its `on:` map', text: under(text, 'on') },
      { into: 'its `jobs:` map', text: under(text, 'jobs') },
    ],
    job: (text) => firstKey(under(text, 'jobs')),
    obstacle: obstacleInWorkflow,
    joining: (host) => `${host} already assigns labels, so the job goes into `
      + 'that file rather than into a second one beside it.',
  },
  gitlab: {
    file: '.gitlab-ci.yml',
    files: (repo) => (fs.existsSync(path.join(repo, '.gitlab-ci.yml')) ? ['.gitlab-ci.yml'] : []),
    // GitLab has one pipeline file and this job is a top-level entry in it, so
    // an existing one is joined whatever it assigns. There is no second path to
    // write it to, which makes the addition the only shape available rather
    // than the shape a labeler earns.
    hosts: (repo) => (fs.existsSync(path.join(repo, '.gitlab-ci.yml')) ? ['.gitlab-ci.yml'] : []),
    // A GitLab job is a top-level key, so the file it joins takes it whole,
    // comments included. Nothing has to be cut apart, and the job carries its
    // own `rules:`, so it guards itself wherever it lands.
    addition: (text) => [{ into: 'it, at the top level', text: text.trimEnd() }],
    job: (text) => firstKey(text),
    // A top-level key sits beside whatever other top-level keys are there, so
    // the only collision is the job's own name, and the check for a job already
    // carried answers that one first.
    obstacle: () => null,
    // Not because it assigns labels. GitLab reads one pipeline file, so a
    // second one would not run at all, and saying otherwise would tell a
    // reader something false about their own repository.
    joining: (host) => `${host} is this project's one pipeline file, so the `
      + 'job goes into it rather than into a second file GitLab would never read.',
  },
};

/**
 * The first paragraph of the job's own leading comment, which is where each
 * forge says what it needs provisioned before it says anything else.
 *
 * Read out of the file rather than restated here, so the offer and the thing
 * offered cannot disagree about what a repository is being asked for. GitHub
 * needs nothing and GitLab needs a token a person creates, and that difference
 * is the first line a reader gets either way.
 */
function provisioning(automation) {
  const lead = [];
  for (const line of automation.split('\n')) {
    if (!line.startsWith('#')) break;
    const text = line.replace(/^#\s?/, '').trim();
    if (text === '') break;
    lead.push(text);
  }
  return lead.join(' ');
}

/**
 * Whether a file already carries this job, asked by the job's own key.
 *
 * The key rather than the job's lines, because the shipped file invites exactly
 * one edit: both automation files tell the reader to change the two label
 * values, so the job matches the vocabulary already in that tracker. A
 * line-by-line comparison calls the customised copy a different job, proposes
 * it again into the file that already has it, and hands somebody a duplicate
 * key. The key is the part that cannot be customised without renaming the job,
 * and it is read out of the shipped file rather than pinned here.
 */
function carries(text, key) {
  return key !== '' && text.split('\n').some((line) => line.trim() === key);
}

/**
 * The offer for one forge: what it needs provisioned, where the job would land,
 * and the exact text.
 *
 * Nothing here reads a tracker. The offer is text and a write, decided from the
 * distribution and from files already in the repository, so a run that reached
 * no tracker gains no call to one by making it.
 */
function offerAutomation(repo, aep, from, name, dryRun) {
  const seed = AUTOMATIONS[name];
  const spec = AUTOMATION_TARGETS[name];
  const automation = fs.readFileSync(path.join(from, ...seed.automation.split('/')), 'utf8');
  const offer = {
    name,
    provisioning: provisioning(automation),
    text: automation,
    addition: spec.addition(automation),
  };

  // A decision this repository already made, read where it recorded it. Asking
  // again is what the record exists to stop, and removing the record is how a
  // repository that changed its mind gets asked once more.
  if (declinedHere(aep)) {
    report.automation.push({ ...offer, declined: `.aep/${DECISION_RULE}` });
    return;
  }

  const already = spec.files(repo).find((rel) => carries(readAt(repo, rel), spec.job(automation)));
  if (already) {
    report.automation.push({ ...offer, standing: already });
    return;
  }

  // An existing labeler is proposed to and never written into. A workflow is
  // executable and the file is somebody else's, so the exact text goes to a
  // human and the edit is theirs to make.
  const hosts = spec.hosts(repo);
  if (hosts.length > 0) {
    const host = hosts[0];
    report.automation.push({
      ...offer,
      host,
      hosts,
      joining: spec.joining(host),
      obstacle: spec.obstacle(readAt(repo, host)),
    });
    return;
  }

  if (dryRun) {
    report.automation.push({ ...offer, would: spec.file });
    return;
  }

  const target = path.join(repo, ...spec.file.split('/'));
  fs.mkdirSync(path.dirname(target), { recursive: true });
  fs.writeFileSync(target, automation, 'utf8');
  report.automation.push({ ...offer, wrote: spec.file });
}

/**
 * The paragraph a runtime entrypoint carries, and the whole of what one says.
 *
 * It names the canonical entrypoint and nothing under `.aep/`. A pointer that
 * named the bootstrap directly would be a second thing to update the day the
 * canonical entry moves, and the two would disagree in the file a runtime
 * loads first.
 */
function pointerTo(canonical) {
  return [
    '## Start here',
    '',
    `Read **\`${canonical}\`** in this directory. It is this repository's entrypoint,`,
    'and it is not specific to any one runtime.',
  ].join('\n');
}

/**
 * One entrypoint per targeted runtime, pointing at the canonical one.
 *
 * Three cases, and the third is the one worth writing down:
 *
 *   the runtime reads the canonical entry   nothing to write. A pointer from a
 *                                           file to itself is a loop
 *   its entrypoint does not exist           write the pointer, and only that
 *   its entrypoint exists                   append the pointer and change
 *                                           nothing else
 *
 * The third case is what makes this safe to run on a repository that had a
 * `CLAUDE.md` years before AEP. That file is the repository's, it may say
 * anything, and an installer that rewrites it destroys instructions nobody
 * asked it to touch. Appending is the only operation available on a file whose
 * contents are none of AEP's business.
 */
function installEntrypoints(repo, requested, dryRun) {
  const pointer = pointerTo(CANONICAL_ENTRYPOINT);
  const written = new Set();

  for (const name of requested) {
    const entry = TARGETS[name].entry;
    if (!entry || entry === CANONICAL_ENTRYPOINT || written.has(entry)) continue;
    written.add(entry);

    const target = path.join(repo, entry);
    const exists = fs.existsSync(target);
    const before = exists ? fs.readFileSync(target, 'utf8') : '';

    // Idempotent by content rather than by a marker: a marker is a thing to
    // maintain, and an update that appends a second identical paragraph every
    // run is the failure this guards.
    if (before.includes(CANONICAL_ENTRYPOINT)) {
      report.skipped.push(`${entry} (already points at ${CANONICAL_ENTRYPOINT})`);
      continue;
    }

    const body = exists
      ? `${before.replace(/\s+$/, '')}\n\n${pointer}\n`
      : `${pointer}\n`;
    if (!dryRun) fs.writeFileSync(target, body);
    report.pointed.push(exists ? `${entry} (pointer added, rest untouched)` : entry);
  }
}

/**
 * Which contract a tree was written under, read from the tree itself.
 *
 * A tree carrying `owner:` on its artifacts is 2.x, classified by that field
 * because that is what the field was for. A tree without it is 3, classified by
 * the manifest. The version a tree declares is not consulted: a repository that
 * hand-edited its bootstrap, or one written before the field existed, declares
 * something that is not evidence of anything.
 *
 * **The removal condition is stated here rather than left to judgement: this
 * branch goes when no repository the maintainer knows of still declares a 2.x
 * layout.** A compatibility branch with no stated end is one nobody removes, and
 * it is read on every upgrade forever.
 */
function carriesRetiredFields(aep) {
  if (!fs.existsSync(aep)) return [];
  return walk(aep)
    .filter((file) => file.endsWith('.md'))
    .filter((file) => {
      const { fields } = readArtifact(file);
      return RETIRED_FIELDS.some((field) => fields[field] !== undefined);
    })
    .map((file) => toPosix(aep, file));
}

/**
 * An effort still in flight whose spec holds the architecture 3 keeps in
 * `plan.md`.
 *
 * A landed effort is skipped, for the reason a landed effort's tracker
 * artifacts are never reshaped: the spec is the record of what was built and
 * reviewed, and splitting it rewrites that record to match a layout the work
 * was never done under. It would also mean an upgraded tree reporting the same
 * finished efforts on every upgrade it ever runs, with no action available that
 * would make the report stop.
 */
function specsHoldingArchitecture(aep) {
  const efforts = path.join(aep, 'efforts');
  if (!fs.existsSync(efforts)) return [];
  return walk(efforts)
    .filter((file) => path.basename(file) === 'spec.md')
    .filter((file) => {
      const { fields, body } = readArtifact(file);
      return fields.status !== 'implemented' && /^#\s+Architecture\s*$/m.test(body);
    })
    .map((file) => toPosix(aep, file));
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
  const automation = value('--automation', null);
  const forges = automation ? automation.split(',').map((name) => name.trim()).filter(Boolean) : [];
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

  const unknownForges = forges.filter((name) => !(name in AUTOMATIONS));
  if (unknownForges.length > 0) {
    process.stderr.write(
      `no merge-time job ships for: ${unknownForges.join(', ')}. ` +
      `Known: ${Object.keys(AUTOMATIONS).join(', ')}
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
  //
  // `version:` is where a 3 tree names its release and `aep:` is where a 2.x one
  // did, so both are read. This is the same layout branch the migration needs,
  // arriving early because everything downstream of it depends on the answer:
  // a tree that declares nothing is treated as predating everything, so reading
  // the wrong field replays every move and every notice on every upgrade.
  const bootstrapFields = existing
    ? readArtifact(path.join(aep, 'protocol.md')).fields
    : {};
  const declared = bootstrapFields.version ?? bootstrapFields.aep ?? null;

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

    // A directory a past release owned and this one does not ship. Reported
    // rather than removed, and reported before the conversion list below,
    // because a reader who deletes it themselves has answered the next item too.
    for (const { dir, since, was } of RETIRED_DIRS) {
      if (fs.existsSync(path.join(aep, dir))) {
        report.retiredDirs.push(`.aep/${dir}/ (stopped being shipped in ${since}: ${was})`);
      }
    }

    // What this script can recognise and must not convert. Both lists are the
    // 2.x layout showing through, and both need a judgement -- a field carries
    // content the manifest cannot place, and splitting a spec decides what is
    // WHAT and what is HOW. `[[skills/update]]` does that with a human; the
    // installer's whole job here is to make sure neither goes unnoticed.
    for (const rel of carriesRetiredFields(aep)) {
      report.unconverted.push(`${rel} (frontmatter written under an older contract)`);
    }
    for (const rel of specsHoldingArchitecture(aep)) {
      report.unconverted.push(`${rel} (holds # Architecture, which 3 keeps in plan.md)`);
    }
  }

  installSeeds(repo, from, aep, dryRun);
  installEntrypoints(repo, requested, dryRun);

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

  // Asked for by name, never by default. A workflow is executable and lands
  // outside `.aep/`, which makes it a larger thing to put in somebody's
  // repository than a reference file, so it arrives the way an adapter does:
  // because the caller said so, having been shown the exact text first.
  for (const name of forges) offerAutomation(repo, aep, from, name, dryRun);

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
  list('runtime entrypoints pointing at the canonical one', report.pointed, (entry) => entry);
  list('repository-owned starting points seeded, review each', report.seeded, (entry) => entry);
  list('seeds skipped', report.skipped, (entry) => entry);
  list('repository-owned files preserved', report.preserved);
  list('protocol files moved by this release', report.moved, (entry) => entry);
  list('links repaired in repository-owned files', report.relinked);
  list('name collisions, a repository file stands where a moved one did', report.collided,
    (entry) => entry);
  list('protocol files no longer shipped, review then /prune', report.retired);
  list('directories no longer shipped, review then /prune', report.retiredDirs,
    (entry) => entry);
  list('written under an older contract, /update converts these with you',
    report.unconverted, (entry) => entry);

  // Each forge leads with what it needs provisioned, because a repository that
  // declines has to know what it declined, and on GitLab that is a credential a
  // person creates. Then where the job goes, and then the text itself, verbatim
  // and unindented: it is YAML somebody may have to paste, and a printed copy
  // that is not byte-exact is worse than none.
  if (report.automation.length > 0) {
    process.stdout.write(
      `\n${report.automation.length} merge-time ` +
      `job${report.automation.length === 1 ? '' : 's'}:\n`,
    );
    for (const offer of report.automation) {
      process.stdout.write(`\n  ${offer.name}\n`);

      // A decision already made gets neither the offer nor the text. Printing
      // what was declined is how an offer nobody wants comes back by being read
      // one more time, which is the thing the record exists to stop.
      if (offer.declined) {
        wrapped(
          `Declined here already, and recorded in ${offer.declined}. Nothing is ` +
          'offered and nothing was written. Remove that record to be asked again.',
          '   ',
        );
        continue;
      }

      wrapped(offer.provisioning, '   ');
      if (offer.standing) {
        wrapped(`Already carried by ${offer.standing}. Nothing to do.`, '   ');
        continue;
      }
      if (offer.host) {
        if (offer.hosts.length > 1) {
          wrapped(
            `${offer.hosts.length} files here assign labels: ${offer.hosts.join(', ')}. ` +
            `This reads ${offer.host}, the first of them.`,
            '   ',
          );
        }
        // A paste that does not parse breaks a workflow the repository owns and
        // AEP did not author, so where the file's own shape cannot take the
        // addition the obstacle is named and nothing is proposed. The offer is
        // still open; what it needs is a person who knows that file.
        if (offer.obstacle) {
          wrapped(
            `${offer.host} already assigns labels, but the job cannot be added to ` +
            `it as it stands: ${offer.obstacle}. Nothing was written and nothing ` +
            'is proposed, because a paste that does not parse would break a ' +
            'workflow this repository owns. Adding it is a judgement about that ' +
            "file, and it is a human's.",
            '   ',
          );
          continue;
        }
        wrapped(
          `${offer.joining} Nothing was written: the file is the repository's, ` +
          "and the edit is a human's to make. Add each of these as it stands, " +
          'and change nothing else in the file.',
          '   ',
        );
        for (const part of offer.addition) {
          wrapped(`Into ${part.into}:`, '   ');
          process.stdout.write(`\n${part.text}\n\n`);
        }
        continue;
      }
      if (offer.would) {
        wrapped(`Would be written whole to ${offer.would}:`, '   ');
      } else {
        wrapped(`Written whole to ${offer.wrote}. What it now runs:`, '   ');
      }
      process.stdout.write(`\n${offer.text}\n`);
    }
  }

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
      wrapped(notice.check, '   ');
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
