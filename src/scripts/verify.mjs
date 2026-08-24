// Asserts the shipped public surfaces against specs.md.
//
// AEP ships as Markdown and JavaScript, so there is no compiler to catch a
// broken build. This is the substitute, and its scope is deliberate: it checks
// what the protocol *distributes*, everything under `src/` plus the plugin
// manifest that points at it, against the specification that defines them. It
// does not audit this repository's own installed `.aep/`; that tree is an
// installation, checked by `validate.mjs` exactly as any other repository's is.
//
// Every mechanically checkable requirement in specs.md gets an assertion here,
// named after the section that demands it. A requirement that cannot be checked
// mechanically, whether a `use-when` states a trigger rather than a topic or
// whether a mode really gives something up, is reported as unchecked at the
// end rather than quietly omitted.
//
// Where this file has to match an em dash a shipped surface legitimately carries,
// it is written as `\u2014`: the shipped scripts are scanned flat for the
// character, and a literal here would be indistinguishable from a stray one.
//
//   node src/scripts/verify.mjs [--section <name>] [--verbose]

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { execFileSync, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import {
  MODES,
  OWNERS,
  SKILLS,
  PROTOCOL_FILES,
  useWhenProblems,
  USE_WHEN_MAX_WORDS,
  USE_WHEN_MIN_WORDS,
  isIsoDate,
  isNonEmptyString,
  readArtifact,
  toPosix,
  topLevel,
  walk,
  wikiLinks,
} from './contract.mjs';
import { render as renderManifest, shippedPaths } from './manifest.mjs';
import { renderAdapter, TARGETS } from './adapters.mjs';
import { contentHash, readStamps, shippedArtifacts } from './release.mjs';
import {
  BUILD_ONLY_SCRIPTS,
  GITIGNORE_SOURCE,
  MOVES,
  NOTICES,
  PAYLOAD_DIRS,
  STAMPS_SOURCE,
  PAYLOAD_FILES,
  PAYLOAD_SCRIPTS,
  REPOSITORY_DIRS,
  SEEDS,
} from './payload.mjs';

/** `src/`, the distribution. */
const SRC = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
/** The repository that builds it. */
const REPO = path.dirname(SRC);

const PROTOCOL_BUDGET_BYTES = 8192;

/**
 * The em dash, as an escape.
 *
 * The scan in the `governed text` section looks for this character across the
 * shipped scripts, so a literal here would be the first thing it found.
 */
const EM_DASH = '\u2014';

/**
 * The documentation this repository writes for a human, and the documentation
 * it writes for the agent building the protocol.
 *
 * Pinned rather than derived from a glob over the root. A glob would sweep the
 * second list into the first the moment either grew, and the exemption is the
 * half that cannot defend itself: an over-broad sweep reads as thoroughness.
 */
const GOVERNED_DOCS = ['README.md', 'CHANGELOG.md'];
const EXEMPT_DOCS = ['specs.md', 'AGENTS.md'];

/**
 * The release the upgrade fixture pretends to be coming from.
 *
 * It is a literal on purpose and must stay behind the release being built: it
 * names a tree that predates the declared moves, which is the only kind of tree
 * those moves apply to. Bumping it with the release would quietly turn the
 * upgrade fixture into a no-op that still reads as a pass.
 */
const PRE_MOVE_RELEASE = '2.1.1';

const args = process.argv.slice(2);
const only = args.includes('--section') ? args[args.indexOf('--section') + 1] : null;
const verbose = args.includes('--verbose');

const failures = [];
let passes = 0;
let current = '';

function section(name, body) {
  if (only && only !== name) return;
  current = name;
  process.stdout.write(`\n${name}\n`);
  try {
    body();
  } catch (error) {
    failures.push(`[${name}] section aborted: ${error.message}`);
    process.stdout.write(`  ABORT ${error.message}\n`);
  }
}

function assert(because, condition, { silent = false } = {}) {
  let ok = false;
  let detail = '';
  try {
    ok = Boolean(typeof condition === 'function' ? condition() : condition);
  } catch (error) {
    ok = false;
    detail = error.message;
  }
  if (ok) {
    passes += 1;
    if (verbose && !silent) process.stdout.write(`  PASS  ${because}\n`);
  } else {
    failures.push(`[${current}] ${because}${detail ? `: ${detail}` : ''}`);
    // `silent` exists for the self-test below, whose assertion is *meant* to
    // fail. Printing it would put the word FAIL in the output of a passing run,
    // which is the one thing a reader scans for.
    if (!silent) process.stdout.write(`  FAIL  ${because}${detail ? `: ${detail}` : ''}\n`);
  }
}

const readSrc = (...parts) => fs.readFileSync(path.join(SRC, ...parts), 'utf8');

/**
 * Prose with line wrapping and blockquote markers flattened.
 *
 * A guard should pin the meaning, not where a line happened to break: a phrase
 * that a reflow would split makes the suite fail on a change that altered
 * nothing, which teaches the next author to weaken the guard.
 *
 * Declared up here with the other helpers rather than beside its first caller.
 * Section bodies run as they are declared, so a helper defined below a section
 * that uses it is a temporal-dead-zone abort, and an aborted section skips
 * every assertion after the throw, which reads as a smaller failure than it is.
 */
const flat = (text) => text.replace(/^\s*>\s?/gm, '').replace(/\s+/g, ' ');
const inSrc = (...parts) => fs.existsSync(path.join(SRC, ...parts));
const listMarkdown = (dir) =>
  inSrc(dir) ? walk(path.join(SRC, dir)).filter((f) => f.endsWith('.md')) : [];

/** Every Markdown artifact the release installs as protocol-owned. */
function payloadArtifacts() {
  const files = PAYLOAD_FILES.map((file) => path.join(SRC, file));
  for (const dir of PAYLOAD_DIRS) files.push(...listMarkdown(dir));
  return files;
}

const specText = fs.readFileSync(path.join(REPO, 'specs.md'), 'utf8');
const specVersion = /^\*\*Version:\*\*\s*(\S+)/m.exec(specText)?.[1] ?? null;

/** A release, as three numbers, or null if the string is not one. */
const release = (value) => {
  const parsed = /^(\d+)\.(\d+)\.(\d+)$/.exec(String(value ?? ''));
  return parsed ? parsed.slice(1, 4).map(Number) : null;
};

/** Whether `a` precedes `b`, the installer's notice and move gate, mirrored. */
const precedesRelease = (a, b) => {
  const left = release(a);
  const right = release(b);
  if (!left || !right) return false;
  for (let i = 0; i < 3; i += 1) {
    if (left[i] !== right[i]) return left[i] < right[i];
  }
  return false;
};

/**
 * Whether `value` is a real release no later than the one being built.
 *
 * `aep:` is the release an artifact's content last changed in, so most shipped
 * artifacts legitimately declare an *older* release than this one, which is the
 * field carrying information rather than repeating `protocol.md`. What is never
 * legitimate is a stamp ahead of the release being built, which names a release
 * that does not exist yet.
 *
 * Whether the stamp is *correct* is not this check's job: `stamps` compares
 * content against the manifest, which is what catches an edit that never got
 * restamped.
 */
const atOrBeforeRelease = (value) => {
  const parsed = release(value);
  if (parsed === null || release(specVersion) === null) return false;
  return !precedesRelease(specVersion, value);
};

// --- the install fixture ----------------------------------------------------
// Declared before any section, because two of them use it and a section body
// runs the moment it is declared.

let fixtureCache = null;

/** Installs into a temporary repository once, and reuses it across sections. */
function installFixture() {
  if (fixtureCache) return fixtureCache;

  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'aep-fixture-'));
  execFileSync('git', ['init', '--quiet'], { cwd: dir, stdio: 'ignore' });
  execFileSync(process.execPath, [path.join(SRC, 'scripts', 'install.mjs'), '--into', dir], {
    stdio: 'ignore',
  });
  const aep = path.join(dir, '.aep');
  execFileSync(process.execPath, [path.join(aep, 'scripts', 'index.mjs'), '--root', aep], {
    stdio: 'ignore',
  });

  fixtureCache = { dir, aep };
  return fixtureCache;
}

// --- §32 the manifest is complete ------------------------------------------

section('manifest', () => {
  assert('specs.md declares a version', isNonEmptyString(specVersion));

  // Ownership is a fact about location, and the exact list is what tells a
  // shipped file from a stray standing beside it. It is generated, so the only
  // way it can be wrong is by being stale, and stale is what this catches.
  assert('the protocol-files manifest matches the payload. Run scripts/manifest.mjs', () => {
    const contract = path.join(SRC, 'scripts', 'contract.mjs');
    const current = fs.readFileSync(contract, 'utf8');
    if (renderManifest(current, shippedPaths(SRC)) !== current) {
      throw new Error('scripts/contract.mjs names a different set of paths than the payload ships');
    }
    return true;
  });

  // Every path in it must exist, which a stale-check alone does not prove: a
  // generator run against a tree missing a file writes a manifest that agrees
  // with itself and names nothing.
  assert('every path the manifest names exists in the distribution', () => {
    const missing = PROTOCOL_FILES
      .filter((rel) => rel !== '.gitignore')
      .filter((rel) => !fs.existsSync(path.join(SRC, ...rel.split('/'))));
    if (missing.length > 0) throw new Error(missing.join(', '));
    return true;
  });

  // The specification and the payload cannot disagree about which primitives
  // exist, so the one that was added last is read back out of the table rather
  // than assumed to have been written there.
  assert('specs.md lists Policies among the primitives', () =>
    /\|\s*\*\*Policies\*\*\s*\|/.test(specText));

  // The specification and the generator cannot disagree about how many
  // runtimes there are. Each claim below is one the implementation now relies
  // on, so a specification that loses it leaves a shipped surface conforming to
  // nothing written down.
  assert('specs.md defines a target as a declaration, not a renderer per runtime', () =>
    /###\s*29\.1\s+Targets and shapes/.test(specText) &&
    /a \*\*target\*\* is a declaration rather than a program/.test(specText));

  assert('specs.md requires a prefix where a runtime would shadow a skill', () =>
    /MUST where the runtime's own built-in commands would otherwise shadow a skill/.test(specText));

  assert('specs.md says a rendered tree is committed only where it has a reader', () =>
    /committed to the protocol repository exactly when that directory is itself what a user registers/
      .test(specText));

  assert('specs.md requires a distribution reach to be derived from where the wrapper sits', () =>
    /MUST be \*\*derived from where the wrapper sits\*\*, never written out/.test(specText));

  assert('specs.md requires every path a wrapper names to exist in an installed tree', () =>
    /Every path a wrapper names MUST exist in an installed tree/.test(specText));

  assert('specs.md omits AEP fields where a runtime reserves no map for them', () =>
    /omitted rather than smuggled in/.test(specText));

  assert('specs.md asserts the adapters over every target and shape', () =>
    /\*\*for every target and every shape it renders\*\*, and not for one runtime/.test(specText));

  assert('specs.md requires the install to refuse an unknown runtime before writing', () =>
    /refuses an unknown runtime \*\*before writing anything\*\*/.test(specText) &&
    /warns where two requested targets are read by one runtime/.test(specText));

  assert('the distribution layout shows one directory per committed target', () =>
    /adapters\/<runtime>\/\s+runtime adapters, one directory per committed target/.test(specText));

  const scriptFiles = fs
    .readdirSync(path.join(SRC, 'scripts'))
    .filter((name) => name.endsWith('.mjs'))
    .sort();
  const declared = [...PAYLOAD_SCRIPTS, ...BUILD_ONLY_SCRIPTS].sort();
  assert('every script is declared either payload or build-only', () =>
    JSON.stringify(scriptFiles) === JSON.stringify(declared));
  if (JSON.stringify(scriptFiles) !== JSON.stringify(declared)) {
    process.stdout.write(`        on disk:   ${scriptFiles.join(', ')}\n`);
    process.stdout.write(`        declared:  ${declared.join(', ')}\n`);
  }

  assert('no script is both payload and build-only', () =>
    PAYLOAD_SCRIPTS.every((name) => !BUILD_ONLY_SCRIPTS.includes(name)));

  for (const file of PAYLOAD_FILES) assert(`payload file ${file} exists`, inSrc(file));
  for (const dir of PAYLOAD_DIRS) assert(`payload directory ${dir}/ exists`, inSrc(dir));
  assert(`the .aep/.gitignore source (${GITIGNORE_SOURCE}) ships`, inSrc(GITIGNORE_SOURCE));

  assert('scripts are .mjs, so a consuming package.json cannot change how they parse', () =>
    fs.readdirSync(path.join(SRC, 'scripts')).every((name) => name.endsWith('.mjs')));

  // Every shipped .mjs, not only the ones under scripts/. The adapter's hook is
  // just as much a thing a user runs, and a dependency there fails at the worst
  // possible moment, on somebody else's machine at session start.
  assert('no shipped script declares a third-party dependency', () => {
    for (const file of walk(SRC).filter((f) => f.endsWith('.mjs'))) {
      const text = fs.readFileSync(file, 'utf8');
      const imports = [...text.matchAll(/^import[^'"]*['"]([^'"]+)['"]/gm)].map((m) => m[1]);
      for (const target of imports) {
        if (!target.startsWith('node:') && !target.startsWith('./') && !target.startsWith('../')) {
          throw new Error(`${toPosix(SRC, file)} imports "${target}"`);
        }
      }
    }
    return true;
  });

  assert('the distribution needs no package manifest to run', () =>
    !fs.existsSync(path.join(REPO, 'package.json')));

  // A move is only meaningful in both directions: the destination has to be
  // something this release ships, and the source has to be something it no
  // longer does. An entry failing either is a rename nobody finished.
  for (const move of MOVES) {
    assert(`MOVES: ${move.to} is shipped`, inSrc(...move.to.split('/')));
    assert(`MOVES: ${move.from} is no longer shipped`, !inSrc(...move.from.split('/')));
    assert(`MOVES: ${move.from} declares the release that moved it`,
      Boolean(release(move.since)));
  }

  // A payload directory at the repository root is a real hazard: a second
  // `skills/`, `agents/`, or `policies/` there reads as canonical and drifts
  // from the one that ships. Nothing needs to sit there, since the plugin is
  // published from the adapter's own directory, so the runtime's scans land
  // inside `src/`.
  assert('every shipped surface lives under src/', () => {
    const stray = ['skills', 'agents', 'modes', 'policies', 'scripts', 'templates', 'protocol.md']
      .filter((name) => fs.existsSync(path.join(REPO, name)));
    if (stray.length > 0) throw new Error(`at the repository root: ${stray.join(', ')}`);
    return true;
  });
});

// --- §8 the stamps are current ----------------------------------------------
// The check the old sweep could not perform. When every artifact was restamped
// every release regardless of whether it moved, an artifact edited without being
// restamped was indistinguishable from one that had not been touched. Comparing
// content against the committed baseline is what makes the field mean something.

section('stamps', () => {
  const stamps = readStamps();
  const shipped = shippedArtifacts();

  assert('the release baseline exists. Run scripts/release.mjs to create it', () =>
    Object.keys(stamps).length > 0);

  for (const file of payloadArtifacts()) {
    const rel = toPosix(SRC, file);
    const hash = contentHash(fs.readFileSync(file, 'utf8'));
    assert(`${rel} is stamped for its current content. Run scripts/release.mjs <version>`, () => {
      if (!(rel in stamps)) throw new Error('not in the baseline: it has never been released');
      if (stamps[rel] !== hash) throw new Error('content changed since it was last stamped');
      return true;
    });
  }

  // An entry for a file that is gone means the baseline outlived what it
  // described, and a later release would compare against nothing.
  assert('the baseline names nothing the distribution no longer ships', () => {
    const live = new Set(shipped.map((file) => toPosix(SRC, file)));
    const orphans = Object.keys(stamps).filter((rel) => !live.has(rel));
    if (orphans.length > 0) throw new Error(orphans.join(', '));
    return true;
  });

  assert('the baseline is build-time only and never ships', () =>
    !PAYLOAD_FILES.includes(STAMPS_SOURCE) &&
    !fs.existsSync(path.join(installFixture().aep, STAMPS_SOURCE)));

  // The two computed lines are excluded from the hash on purpose: stamping a
  // file must not change what it hashes to, or a release would never converge
  // and every run would restamp everything again.
  assert('stamping an artifact does not change its own hash', () => {
    const sample = fs.readFileSync(path.join(SRC, 'protocol.md'), 'utf8');
    const restamped = sample
      .replace(/^aep:.*$/m, 'aep: 9.9.9')
      .replace(/^date:.*$/m, 'date: 1999-01-01');
    if (contentHash(sample) !== contentHash(restamped)) {
      throw new Error('the hash covers the stamp, so a release would never settle');
    }
    return true;
  });
});

// --- §8 the frontmatter contract -------------------------------------------

section('frontmatter', () => {
  for (const file of payloadArtifacts()) {
    const rel = toPosix(SRC, file);
    const artifact = readArtifact(file);

    assert(`${rel} has frontmatter`, artifact.hasFrontmatter);
    if (!artifact.hasFrontmatter) continue;

    assert(`${rel} frontmatter parses`, artifact.errors.length === 0);
    assert(`${rel} declares the release its content last changed in, not a later one`,
      atOrBeforeRelease(artifact.fields.aep));
    assert(`${rel} declares owner: protocol`, artifact.fields.owner === 'protocol');
    assert(`${rel} declares a real YYYY-MM-DD date`, isIsoDate(artifact.fields.date));

    if (artifact.fields.mode !== undefined) {
      assert(`${rel} mode is an array of legal modes`, () =>
        Array.isArray(artifact.fields.mode) &&
        artifact.fields.mode.every((mode) => MODES.includes(mode)));
    }
    assert(`${rel} declares no status (payload artifacts are not specs or tickets)`,
      artifact.fields.status === undefined);
  }

  // `use-when` is the whole of applicability-first loading, so every shipped
  // trigger is put through the same checks a consuming repository's will be.
  for (const file of payloadArtifacts()) {
    const rel = toPosix(SRC, file);
    const artifact = readArtifact(file);
    if (artifact.fields['use-when'] === undefined) continue;
    assert(`${rel} use-when reads as a trigger`, () => {
      const heading = (artifact.body.match(/^#\s+(.+)$/m) ?? [])[1] ?? '';
      const problems = useWhenProblems(artifact.fields['use-when'], {
        heading,
        name: path.basename(rel, '.md'),
        directory: rel.split('/')[0],
      });
      if (problems.length > 0) throw new Error(problems.join('; '));
      return true;
    });
  }

  // The two cases the specification names, pinned by name. A checker that
  // accepts the topic or rejects the trigger has stopped doing its job, and
  // neither shows up as a failure anywhere else.
  assert('use-when rejects a topic: "Database documentation"', () =>
    useWhenProblems('Database documentation', {}).length > 0);
  assert('use-when accepts a trigger: "changing anything under src/"', () =>
    useWhenProblems('changing anything under src/', {}).length === 0);
  assert('use-when rejects a one-word noun that ends like a verb', () =>
    useWhenProblems('policies', {}).length > 0);
  assert('use-when rejects one that restates its own heading', () =>
    useWhenProblems('the effort is in progress', { heading: 'The effort is in progress' }).length > 0);
  assert('use-when accepts the same words when they are not the heading', () =>
    useWhenProblems('the effort is in progress', {}).length === 0);

  // The bounds came from the corpus rather than from taste, so they are asserted
  // against it: a bound tightened past the longest real trigger fails good work.
  assert('the use-when bounds admit every trigger the payload ships', () => {
    const lengths = payloadArtifacts()
      .map((file) => readArtifact(file).fields['use-when'])
      .filter((value) => typeof value === 'string')
      .map((value) => value.trim().split(/\s+/).length);
    const longest = Math.max(...lengths);
    const shortest = Math.min(...lengths);
    if (longest > USE_WHEN_MAX_WORDS) throw new Error(`longest is ${longest}, over the bound`);
    if (shortest < USE_WHEN_MIN_WORDS) throw new Error(`shortest is ${shortest}, under the floor`);
    return true;
  });

  // The release no longer writes itself into every artifact. The bootstrap is
  // the one file that names it, so the pass that stamped the rest is gone.
  assert('release.mjs stamps no artifact but the bootstrap', () => {
    const text = fs.readFileSync(path.join(SRC, 'scripts', 'release.mjs'), 'utf8');
    if (/setField\(text, 'aep', version\)/.test(text)) {
      throw new Error('the per-artifact stamping pass is still there');
    }
    return true;
  });

  assert('owner has exactly two legal values', () =>
    OWNERS.length === 2 && OWNERS.includes('protocol') && OWNERS.includes('repository'));
});

// --- §6 the bootstrap -------------------------------------------------------

section('protocol.md', () => {
  assert('protocol.md exists', inSrc('protocol.md'));
  const size = fs.statSync(path.join(SRC, 'protocol.md')).size;
  assert(`protocol.md is within the ${PROTOCOL_BUDGET_BYTES}-byte budget (is ${size})`,
    size <= PROTOCOL_BUDGET_BYTES);

  const artifact = readArtifact(path.join(SRC, 'protocol.md'));
  assert('protocol.md declares kind: protocol', artifact.fields.kind === 'protocol');

  // Asserted separately from the blanket stamp above, because this one carries
  // more weight: protocol.md is what an installed tree declares its release
  // *as*. `index.mjs` reads the version from here, and `update` decides whether
  // a repository is behind by comparing it, so a stale stamp here makes a
  // current installation report itself as an old one.
  assert(`protocol.md declares the release being built (${specVersion})`,
    artifact.fields.aep === specVersion);

  const body = artifact.body;
  for (const heading of [
    'What AEP is',
    'The primitives',
    'Where state is',
    'How to discover what matters',
    'The workflow',
    'The invariants',
    'Governance that loads when it applies',
  ]) {
    assert(`protocol.md answers "${heading}"`, body.includes(`## ${heading}`));
  }

  assert('protocol.md routes to both governance layers', () =>
    /\[\[policies\/\w/.test(body) && /`?\[\[rules/.test(body));
  assert('protocol.md does not become a second governance layer', () =>
    !/^##\s+(Rules|Policies)\s*$/m.test(body));
});

// --- §16 the skill set ------------------------------------------------------

section('skills', () => {
  // Top-level only: `skills/<skill>/<note>.md` is depth, not a skill (§16.1).
  const onDisk = topLevel(path.join(SRC, 'skills')).map((f) => path.basename(f, '.md')).sort();
  assert('the skill set is exactly the eighteen specs.md names', () =>
    JSON.stringify(onDisk) === JSON.stringify([...SKILLS].sort()));
  if (JSON.stringify(onDisk) !== JSON.stringify([...SKILLS].sort())) {
    process.stdout.write(`        on disk: ${onDisk.join(', ')}\n`);
    process.stdout.write(`        spec:    ${[...SKILLS].sort().join(', ')}\n`);
  }

  for (const name of SKILLS) {
    const file = path.join(SRC, 'skills', `${name}.md`);
    if (!fs.existsSync(file)) {
      assert(`skills/${name}.md exists`, false);
      continue;
    }
    const artifact = readArtifact(file);
    assert(`skills/${name} declares use-when`, isNonEmptyString(artifact.fields['use-when']));

  }

  // The discovery surface. `protocol.md` gives `help` one job, answering *what do
  // I reach for*, so a skill it does not name is unreachable through the only
  // artifact whose purpose is reaching them. Derived from `SKILLS`, never from a
  // second hand-written list: that list is the same failure one level up, and
  // nothing would catch it drifting either. `help` is excluded from its own
  // table because a reader already holding it does not need telling where it is.
  const helpSkill = readSrc('skills', 'help.md');
  const unrouted = SKILLS
    .filter((name) => name !== 'help')
    .filter((name) => !helpSkill.includes(`[[skills/${name}]]`));
  assert('skills/help routes to every shipped skill but itself', () => unrouted.length === 0);
  if (unrouted.length > 0) {
    process.stdout.write(`        not reachable from help: ${unrouted.join(', ')}\n`);
  }

  assert('skills/plan forbids plan.md', /NEVER create `plan\.md`/.test(readSrc('skills', 'plan.md')));

  const reviewSkill = readSrc('skills', 'review.md');
  assert('skills/review runs two independent axes', /two sub-agents|two independent/i.test(reviewSkill));
  assert('skills/review names both reviewer agents', () =>
    reviewSkill.includes('agents/reviewer-correctness') &&
    reviewSkill.includes('agents/reviewer-standards'));
  assert('skills/review requires an outcome per finding', /outcome/i.test(reviewSkill));

  assert('skills/commit forbids pushing and publishing', () =>
    /never runs `git push`/.test(readSrc('skills', 'commit.md')));

  assert('skills/implement forbids splitting a task across sub-agents', () =>
    /never split across sub-agents/i.test(readSrc('skills', 'implement.md')));

  assert('skills/update branches to the 1.x migration rather than upgrading in place', () =>
    readSrc('skills', 'update.md').includes('skills/update/migration'));

  assert('skills/implement reads an external frontier from the recorded query', () =>
    /frontier comes from the recorded query/.test(readSrc('skills', 'implement.md')));
  assert('skills/tasks routes to the tracker note before writing external tasks', () =>
    readSrc('skills', 'tasks.md').includes('skills/tasks/labels'));

  // §31.1, the migration's five rules, each pinned by the thing that goes wrong
  // when it is dropped. A migration that quietly loses knowledge still reports
  // success, so nothing downstream notices.
  const migration = readSrc('skills', 'update', 'migration.md');
  assert('the migration resolves every 1.x file to one of the three outcomes', () =>
    ['converted', 'superseded', 'unrepresented'].every((word) => migration.includes(word)));
  assert('the migration does not treat owner: framework as grounds to drop a file', () =>
    /`owner: framework` does not mean superseded/.test(migration));
  assert('the migration derives date from history rather than stamping today', () =>
    /git log -1 --format=%ad/.test(migration) && /Never today's date/.test(migration));
  assert('the migration proposes use-when rather than inventing it', () =>
    /proposed from the content and marked unconfirmed/i.test(migration));
  assert('the migration converts every 1.x ticket state', () =>
    ['blocked', 'superseded', 'obsolete', 'resolved'].every((state) => migration.includes(state)));
  assert('the migration deletes nothing', () => /Nothing is deleted here/.test(migration));
  assert('the migration requires the converted tree to validate', () =>
    /validate\.mjs` must pass with no exemption/.test(migration));
});

// --- §16.1 skill notes ------------------------------------------------------
// Depth reached from a skill, never an entry point. Three ways a note goes
// wrong, and all three read as working: it sits under a directory no skill
// owns, nothing links to it, or an adapter publishes it as a command.

section('skill notes', () => {
  const skillsDir = path.join(SRC, 'skills');
  const notes = walk(skillsDir)
    .filter((file) => file.endsWith('.md'))
    .filter((file) => path.dirname(file) !== skillsDir);

  assert('the release ships skill notes', notes.length > 0);

  // The link index is built once from the skills themselves, so "linked from its
  // own skill" is checked against the owning skill rather than the whole corpus.
  const linkedBy = new Map();
  for (const file of topLevel(skillsDir)) {
    const name = path.basename(file, '.md');
    linkedBy.set(name, new Set(wikiLinks(readArtifact(file).body)));
  }

  for (const file of notes) {
    const rel = toPosix(SRC, file);
    const owner = path.basename(path.dirname(file));
    const target = `skills/${owner}/${path.basename(file, '.md')}`;
    const artifact = readArtifact(file);

    assert(`${rel} sits under a real skill`, SKILLS.includes(owner));
    assert(`${rel} is one level deep, beside its skill`, () =>
      path.dirname(path.dirname(file)) === skillsDir);
    assert(`${rel} declares kind: skill`, artifact.fields.kind === 'skill');
    assert(`${rel} declares a use-when naming the branch it is for`,
      isNonEmptyString(artifact.fields['use-when']));
    assert(`${rel} is linked from skills/${owner}.md. An unlinked note is unreachable`, () =>
      linkedBy.get(owner)?.has(target) === true);
  }

  // The tracker note carries the whole external-task procedure, and each of these
  // is a step that reads as optional the moment its sentence goes missing.
  const labels = readSrc('skills', 'tasks', 'labels.md');

  assert('the tracker note orders the ladder: native, then existing, then new', () => {
    const native = labels.indexOf('a first-class feature of this tracker');
    const existing = labels.indexOf('an existing label that already serves it');
    const created = labels.indexOf('a new label');
    if (native < 0 || existing < 0 || created < 0) throw new Error('a rung is missing');
    if (!(native < existing && existing < created)) {
      throw new Error('the rungs are present but out of order');
    }
    return true;
  });
  assert('the tracker note forbids a label for what the tracker models natively', () =>
    /A label is never created for a fact the tracker models natively/.test(labels));
  assert('the tracker note requires a native feature to be queryable, not merely adjacent', () =>
    /A native feature counts only if it answers the same question/.test(labels));
  assert('the tracker note shows one fact naming differently in two trackers', () =>
    /effort\/<slug>/.test(labels) && /Effort: <slug>/.test(labels));
  assert('the tracker note allows for creating no label at all', () =>
    /\*\*no label is created\*\*/.test(labels));
  assert('the tracker note requires the resolution to be recorded, then read', () =>
    /Later sessions read it\. They do not rederive it\./.test(labels));
  assert('the tracker note writes the section where the reference has none', () =>
    /Where the reference has no such section, write it/.test(labels));
  assert('the tracker note gates creating a label or a milestone', () =>
    /Creating a label or a milestone publishes/.test(labels) &&
    /exact strings, never a summary/i.test(labels));
  assert('the tracker note stops on a refused permission rather than sliding down the ladder', () =>
    /Approval is not permission/.test(labels));
  assert('the tracker note separates resolving the mechanism from applying it per effort', () =>
    /Resolve once per tracker; apply every effort/.test(labels));

  // Asked of each target rather than spelled here: a target is free to prefix
  // the names it publishes, and a hand-built `skills/<name>/SKILL.md` would
  // then match nothing and pass while a note was published under `aep-<name>`.
  assert('no adapter publishes a note as a command', () => {
    const published = [];
    for (const [runtime, target] of Object.entries(TARGETS)) {
      for (const shape of target.shapes) {
        const rendered = new Set(renderAdapter(SRC, target, shape).map((f) => f.relativePath));
        for (const file of notes) {
          const name = path.basename(file, '.md');
          if (SKILLS.includes(name)) continue;
          const where = target.path('skill', `${target.prefix}${name}`, shape);
          if (where && rendered.has(where)) published.push(`${runtime}/${shape}: ${where}`);
        }
      }
    }
    if (published.length > 0) throw new Error(published.join(', '));
    return true;
  });
});

// --- §14 the mode set -------------------------------------------------------

section('modes', () => {
  const onDisk = listMarkdown('modes').map((file) => path.basename(file, '.md')).sort();
  assert('the mode set is exactly the eight specs.md names', () =>
    JSON.stringify(onDisk) === JSON.stringify([...MODES].sort()));

  for (const name of MODES) {
    const file = path.join(SRC, 'modes', `${name}.md`);
    if (!fs.existsSync(file)) continue;
    const artifact = readArtifact(file);
    assert(`modes/${name} declares kind: mode`, artifact.fields.kind === 'mode');
    assert(`modes/${name} states what it gives up`, /What this gives up/.test(artifact.body));
  }
});

// --- §18 agents -------------------------------------------------------------

section('agents', () => {
  const agents = listMarkdown('agents').map((file) => path.basename(file, '.md'));
  assert('at least one agent role ships', agents.length > 0);

  const skillText = listMarkdown('skills').map((f) => fs.readFileSync(f, 'utf8')).join('\n');
  for (const name of agents) {
    const artifact = readArtifact(path.join(SRC, 'agents', `${name}.md`));
    assert(`agents/${name} declares kind: agent`, artifact.fields.kind === 'agent');
    assert(`agents/${name} declares use-when`, isNonEmptyString(artifact.fields['use-when']));
    assert(`agents/${name} states a purpose the adapter can derive`,
      /\*\*Purpose\.\*\*/.test(artifact.body));
    assert(`agents/${name} is bound by the sub-agent policy`,
      /policies\/execution/.test(artifact.body));
    assert(`agents/${name} is dispatched by some skill`, skillText.includes(`agents/${name}`));
  }
});

// --- §10 policies -----------------------------------------------------------
// Governance ships as policies; `rules/` is the repository's own and ships
// nothing but the version-control seed. So this section asserts the shipped
// governance layer, and the fixture asserts that the other one arrives empty.

section('policies', () => {
  const policies = listMarkdown('policies');
  assert('at least one policy ships', policies.length > 0);
  for (const file of policies) {
    const rel = toPosix(SRC, file);
    const artifact = readArtifact(file);
    assert(`${rel} declares kind: policy`, artifact.fields.kind === 'policy');
    assert(`${rel} declares owner: protocol`, artifact.fields.owner === 'protocol');
    assert(`${rel} declares use-when. Without it, it cannot be selected`,
      isNonEmptyString(artifact.fields['use-when']));
  }

  for (const expected of ['authority', 'engineering', 'execution', 'artifacts']) {
    assert(`policies/${expected}.md ships`, inSrc('policies', `${expected}.md`));
  }

  // The consolidation is the point: a governance layer that grows a file per
  // concern is the sprawl this shape replaced, so the count is asserted rather
  // than left to drift back.
  assert('the shipped governance layer stays small', () => {
    if (policies.length > 5) throw new Error(`${policies.length} policies ship`);
    return true;
  });

  assert('the distribution ships no rules/. That directory is the repository\'s', () =>
    !inSrc('rules'));
  assert('version-control is a repository-owned seed, not protocol governance', () =>
    inSrc('seed', 'rules', 'version-control.md'));

  // What `aep:` answers. The policy said the opposite until 2.5.1, that every
  // release stamps every protocol-owned artifact, which contradicted §6, §8,
  // release.mjs, and the stale-stamp guard above, and described an upgrade check
  // nothing implements. Pinned so it cannot drift back, in both directions:
  // saying the field records the last content change, and not saying the sweep.
  const artifacts = flat(readSrc('policies', 'artifacts.md'));
  assert('policies/artifacts says aep records when content last changed', () =>
    /the release its content last changed in/.test(artifacts));
  assert('policies/artifacts stamps only what changed, protocol.md excepted', () =>
    /stamps only the artifacts that actually changed/.test(artifacts) &&
    /`protocol\.md` is the one exception/.test(artifacts));
  assert('policies/artifacts does not claim a release sweeps every artifact', () =>
    !/every release stamps every/.test(artifacts));
  assert('policies/artifacts establishes provenance by comparing content', () =>
    /establishes provenance by comparing content/.test(artifacts));

  // Two statements from the absorbed rules that carry the most weight, pinned by
  // name so a rewrite of the surrounding prose cannot quietly drop them.
  const execution = readSrc('policies', 'execution.md');
  assert('policies/execution forbids splitting one task across children', () =>
    /never split across sub-agents/i.test(execution));
  assert('policies/execution requires independence to be read, not inferred', () =>
    /never infer independence/i.test(execution));

  // §15.4, the external half of the same rule. Without these, a repository whose
  // work lives in a tracker is governed by the frontier rule and given no way to
  // satisfy it, which reads exactly like being governed.
  // Pinned with `\s+` between words rather than literal spaces: the payload is
  // wrapped at 80 columns, so any phrase long enough to be worth pinning is long
  // enough to have a newline land in the middle of it.
  assert('policies/execution requires an external task to be findable in its tracker', () =>
    /attributable to its effort by a query the\s+tracker\s+answers natively/.test(execution));
  assert('policies/execution requires exactly one fact of an external task', () =>
    /Exactly one fact is required/.test(execution));
  assert('policies/execution keeps status out of it, and says why', () =>
    /`status`\s+is not carried separately/.test(execution) &&
    /closes\s+an issue from the tracker's own interface/.test(execution));
  assert('policies/execution keeps a dependency edge out of it, and says why', () =>
    /dependency edge is not carried as set membership/.test(execution) &&
    /nothing in the tracker knows to\s+do it/.test(execution));
  assert('policies/execution prefers what the tracker already models', () =>
    /What the tracker already models, the tracker carries/.test(execution));
  assert('policies/execution separates carrying the fact from mirroring', () =>
    /None of this is mirroring/.test(execution));

  const reconciliation = flat(execution);

  // §20 the three things a child structurally could not do. Each is asserted on
  // its own, because a reconciliation section that states two of them reads as
  // complete: the missing one is invisible from inside the file.
  for (const [name, pattern] of [
    ['the seams between children\'s diffs', /\*\*The seams\*\*/],
    ['the decisions a child stopped on', /\*\*Every decision a child recorded and stopped on\.\*\*/],
    ['one account of the work', /\*\*One account of the work\*\*/],
  ]) {
    assert(`policies/execution makes the orchestrator own ${name}`, () =>
      pattern.test(reconciliation));
  }

  // The bound, and its reason. An unbounded seam pass and a bounded one read
  // identically until a parent uses the difference, so the words that draw the
  // line are the whole assertion.
  assert('policies/execution bounds the seam pass at the shared surfaces', () =>
    /The seam is the bound\./.test(reconciliation) &&
    /raised, not taken/.test(reconciliation));
  assert('policies/execution says why the bound is the diffs and not the effort', () =>
    /cannot distinguish reconciling a seam from rebuilding a task/.test(reconciliation));

  // Both halves of the account clause. The first half alone reads as permission
  // to hide a lost task, which is the version this pins against.
  assert('policies/execution says the account describes the work, not the workers', () =>
    /describes the work rather than the workers/.test(reconciliation));
  assert('policies/execution surfaces sub-agent structure where it changed the outcome', () =>
    /Sub-agent structure surfaces where it changed the outcome/.test(reconciliation) &&
    /not permission to suppress a failure/.test(reconciliation));

  // The presentation clause needs its substance half for the same reason: on its
  // own it licenses a rewritten question wearing the child's name.
  assert('policies/execution has the orchestrator present the child\'s question', () =>
    /The child writes the question plainly and the orchestrator presents it\./.test(reconciliation));
  assert('policies/execution keeps substance out of what may be reshaped', () =>
    /Wording may be reshaped\. Substance never is\./.test(reconciliation) &&
    /which options are offered, survive unchanged/.test(reconciliation));
  assert('policies/execution attributes the question to its source, not its author', () =>
    /Attribution names the source, not the author of the words/.test(reconciliation));

  // Reachable from the skill that dispatches, not only from the policy that
  // states it.
  const implementSkill = readSrc('skills', 'implement.md');
  assert('skills/implement routes its close-out to the reconciliation section', () =>
    /What the orchestrator owns once the last child returns/.test(implementSkill) &&
    /\[\[policies\/execution\]\]/.test(implementSkill));

  // The obligation is the orchestrator's. A child brief that named the catalogue
  // would be the version where it drifted downward, which is the shape the human
  // rejected rather than one nobody thought of.
  const agentBriefs = topLevel(path.join(SRC, 'agents'))
    .filter((f) => /skills\/prose|catalogue of tells/.test(fs.readFileSync(f, 'utf8')))
    .map((f) => toPosix(SRC, f));
  assert('no agent brief carries the catalogue down to a child', () =>
    agentBriefs.length === 0);
  if (agentBriefs.length > 0) {
    process.stdout.write(`        carried by: ${agentBriefs.join(', ')}\n`);
  }

  const authority = readSrc('policies', 'authority.md');
  assert('policies/authority places policies above rules', () =>
    /policies\s+→\s+rules/.test(authority));
  assert('policies/authority forbids a rule softening a policy', () =>
    /never soften it/i.test(authority));
});

// --- §16.2 what a turn tells the human --------------------------------------

/** The opening slots, in the order the contract fixes, then the closing ones. */
const OPENING_SLOTS = ['Standing', 'Request', 'Assuming', 'Stages'];
const CLOSING_SLOTS = ['State', 'Next', 'Unsettled'];

/**
 * Skills whose report is the short form.
 *
 * Pinned here rather than derived. The test that assigns a form, does this
 * skill write to the repository, dispatch, or decide on the human's behalf, is
 * applied by an author and not by a script. Pinning it is what turns the
 * declaration in each skill from a value nobody checks into one that has to
 * agree with a second, independent statement.
 */
const SHORT_FORM_SKILLS = ['help', 'survey', 'domain'];

/**
 * The stage names a skill declares, read from its own procedure.
 *
 * Two shapes, because both are in the corpus for good reasons: the long skills
 * carry prose under numbered headings, the compact ones a numbered list under
 * `## Procedure`. Returns `total` alongside so a caller can tell "no stages",
 * a shape this does not know, from "a step with no name", which is the defect
 * that would otherwise pass as a shorter list.
 */
function stageNames(text) {
  const headings = [...text.matchAll(/^## (\d+) \u2014 (.+)$/gm)].map((m) => m[2].trim());
  if (headings.length > 0) return { stages: headings, total: headings.length, shape: 'headings' };

  const procedure = /^## Procedure\s*$([\s\S]*?)(?=^## |\Z)/m.exec(text);
  if (!procedure) return { stages: [], total: 0, shape: 'none' };

  const body = procedure[1];
  const total = [...body.matchAll(/^(\d+)\. /gm)].length;
  const stages = [...body.matchAll(/^(\d+)\. \*\*(.+?)[.:]?\*\*/gm)].map((m) => m[2].trim());
  return { stages, total, shape: 'procedure' };
}

section('reporting', () => {
  const policy = readSrc('policies', 'reporting.md');
  const prose = flat(policy);

  // The policy governs every text a human reads, and the turn report is one of
  // them rather than all of them. Each half below fails on its own, because the
  // version that keeps the shape and loses the scope reads identically to a
  // reader who only ever opens the second half.
  const trigger = readArtifact(path.join(SRC, 'policies', 'reporting.md')).fields['use-when'];
  assert('the policy triggers on more than the turn report', () =>
    /commit message/i.test(trigger) && /code comment/i.test(trigger));

  assert('the policy states the reader test in one sentence', () =>
    /A human reads it, it is governed\.\s+A protocol agent reads it, it is\s+exempt/.test(prose));
  assert('the reader test says exempt means written for that reader', () =>
    /exempt means written for that reader instead, never written\s+carelessly/.test(prose));
  assert('the policy carries both worked lists', () =>
    /\|\s*Governed\s*\|\s*Exempt\s*\|/.test(policy) &&
    /a commit message, a pull request title or body/.test(prose) &&
    /prose inside `\.aep\/` artifacts/.test(prose));
  assert('the policy says the lists are examples rather than the definition', () =>
    /worked examples of that test rather than the definition/.test(prose));
  assert('the policy exempts normative protocol text wherever it lives', () =>
    /normative protocol text, wherever it lives/.test(prose) &&
    /exempt even at a repository root/.test(prose));

  // The four the policy owns, each named separately: a single assertion over all
  // four passes while three of them are missing.
  for (const [name, pattern] of [
    ['em dashes', /No em dashes/],
    ['curly quotes', /No curly quotes/],
    ['decorative emoji', /No decorative emoji/],
    ['title-case headings', /No title-case headings/],
  ]) {
    assert(`the policy prohibits ${name} by name`, () => pattern.test(prose));
  }
  assert('the em dash prohibition rules out the three substitutes for one', () =>
    /Parentheses, an en dash, and a hyphen standing in for one do\s+not\s+satisfy this/.test(prose));

  // The split between law and craft. Without the link the catalogue is
  // unreachable from the only artifact that requires it.
  assert('the policy sends the craft to skills/prose', () =>
    /\[\[skills\/prose\]\]/.test(policy));
  assert('the policy says the prohibitions are its own rather than the catalogue\'s', () =>
    /they are here rather than in the catalogue/.test(prose));

  for (const slot of OPENING_SLOTS) {
    assert(`the contract names the opening slot ${slot}`, () => policy.includes(`**${slot}**`));
  }
  for (const slot of CLOSING_SLOTS) {
    assert(`the contract names the closing slot ${slot}`, () => policy.includes(`**${slot}**`));
  }
  assert('the contract fixes the opening slots in order', () => {
    const at = OPENING_SLOTS.map((slot) => policy.indexOf(`**${slot}**`));
    return at.every((position, i) => position > -1 && (i === 0 || position > at[i - 1]));
  });
  assert('the contract fixes the closing slots in order', () => {
    const at = CLOSING_SLOTS.map((slot) => policy.indexOf(`**${slot}**`));
    return at.every((position, i) => position > -1 && (i === 0 || position > at[i - 1]));
  });

  assert('the contract forbids omitting a slot that has nothing in it', () =>
    /A slot with nothing to put in it says so/.test(prose) && /never dropped/i.test(prose));
  assert('the contract makes the turn the unit, not the skill entry', () =>
    /The unit is the turn/i.test(prose));
  assert('the contract makes a nested skill a stage rather than a second report', () =>
    /opens no report of its own/.test(prose));
  assert('the contract requires a turn that stops early to close', () =>
    /stops early closes with the same three slots/.test(prose));
  assert('the contract fills Standing with what a skill already verifies', () =>
    /Never with a new check/i.test(prose));
  assert('the contract separates the two forms by their stage markers', () =>
    /the difference is the markers/.test(prose));
  assert('the contract states the test that assigns a form', () =>
    /write to the repository, dispatch a sub-agent, or decide on the human's behalf/.test(prose));
  assert('the contract forbids selecting a form during a run', () =>
    /never selected during a run/i.test(prose));
  assert('the contract reads stage names off the skill rather than a second list', () =>
    /never declared a second time/.test(prose));

  // One home. A second copy of the slot set is the drift this whole effort is
  // against, so the check is over every shipped artifact rather than the ones
  // that seemed likely.
  const wholeSet = [...OPENING_SLOTS, ...CLOSING_SLOTS];
  const carriers = payloadArtifacts().filter((file) => {
    const text = fs.readFileSync(file, 'utf8');
    return wholeSet.every((slot) => text.includes(`**${slot}**`));
  }).map((file) => toPosix(SRC, file));
  assert('exactly one shipped artifact states the whole slot set', () => carriers.length === 1);
  if (carriers.length !== 1) {
    process.stdout.write(`        carriers: ${carriers.join(', ') || '(none)'}\n`);
  }
  assert('the one that does is the policy', () => carriers[0] === 'policies/reporting.md');

  // The bootstrap links rather than lists: it is loaded on every session, and a
  // copy of the slots there would be the second home the check above forbids.
  const bootstrap = readSrc('protocol.md');
  // The invariant itself, not the file: protocol.md also lists the policy in
  // its governance table, and a check satisfied by that link would pass with
  // the invariant's own pointer deleted, a guard matching something
  // travelling with the thing it checks.
  const invariant = /\*\*Every turn reports\.\*\*[\s\S]*?(?=\n\n)/.exec(bootstrap);
  assert('protocol.md carries the invariant', () => invariant !== null);
  assert('the invariant points at the contract rather than restating it', () =>
    invariant !== null && flat(invariant[0]).includes('[[policies/reporting]]'));
  assert('the bootstrap does not become a second home for the slots', () =>
    !wholeSet.every((slot) => bootstrap.includes(slot)));

  // Rendering is the runtime's business. A contract that implies one puts every
  // non-terminal consumer out of conformance for reasons unrelated to what it
  // says, so the surfaces stating it may not name one.
  const rendering = /\b(terminal|colou?r|ANSI|pixels?|columns wide|Claude|Cursor|Codex|Gemini)\b/i;
  for (const [name, text] of [['policies/reporting.md', policy], ['protocol.md', bootstrap]]) {
    assert(`${name} states the contract without naming a rendering`, () => !rendering.test(text));
  }

  // Every skill declares a form, and the declaration agrees with the pin above.
  for (const name of SKILLS) {
    const artifact = readArtifact(path.join(SRC, 'skills', `${name}.md`));
    const expected = SHORT_FORM_SKILLS.includes(name) ? 'short' : 'full';
    assert(`skills/${name} declares report: ${expected}`, artifact.fields.report === expected);
  }

  // A note is reached from inside a run rather than invoked, so it opens no
  // report and declaring a form would claim otherwise.
  for (const file of walk(path.join(SRC, 'skills')).filter((f) => f.endsWith('.md'))) {
    const rel = toPosix(SRC, file);
    if (!/^skills\/[^/]+\/.+\.md$/.test(rel)) continue;
    assert(`${rel} declares no report. A note opens none`,
      readArtifact(file).fields.report === undefined);
  }

  // Stage names, mechanically, for every full-form skill. `total` is what makes
  // this a real check: a skill whose steps are half-named would otherwise pass
  // with a shorter list, and the run would cross a stage the report never named.
  for (const name of SKILLS) {
    if (SHORT_FORM_SKILLS.includes(name)) continue;
    const { stages, total, shape } = stageNames(readSrc('skills', `${name}.md`));
    assert(`skills/${name} declares its stages in a shape this can read`, shape !== 'none');
    assert(`skills/${name} yields at least one stage name`, stages.length > 0);
    assert(`skills/${name} names every one of its ${total} steps`, stages.length === total);
  }

  // Nothing acquired a position read. The set is pinned by name so a fourth is
  // a failure; `specify` reads position/marker.json directly and runs no
  // script, which is why it is not here.
  const readsPosition = SKILLS
    .filter((name) => /position\.mjs/.test(readSrc('skills', `${name}.md`)))
    .sort();
  assert('exactly commit, implement, and install invoke position.mjs', () =>
    JSON.stringify(readsPosition) === JSON.stringify(['commit', 'implement', 'install']));
  if (JSON.stringify(readsPosition) !== JSON.stringify(['commit', 'implement', 'install'])) {
    process.stdout.write(`        on disk: ${readsPosition.join(', ')}\n`);
  }

  // The absorbed surfaces: each conforms, and the reasoning that justified the
  // shape it had before survives the absorption.
  const implement = readSrc('skills', 'implement.md');
  assert('skills/implement fills Standing from the position script', () =>
    /fills `Standing`/.test(implement) && /position\.mjs check/.test(implement));
  assert('skills/implement keeps the reason its position report existed', () =>
    /Nothing to report is still reported/.test(implement));
  assert('skills/implement makes review and commit stages of its own turn', () =>
    /as stages of this turn/.test(implement));
  for (const name of ['tdd', 'domain']) {
    assert(`skills/${name} says a nested entry opens no report`, () =>
      /opening no report of its own/.test(readSrc('skills', `${name}.md`)));
  }
  const specify = readSrc('skills', 'specify.md');
  assert('skills/specify routes its unverified half to Assuming', () =>
    /fills `Assuming`/.test(specify));
  assert('skills/specify routes its sizing floor to Next', () =>
    /`Next` names/.test(specify));
});

// --- §12.1 where a context lives --------------------------------------------

section('contexts', () => {
  const template = readSrc('templates', 'context.template.md');
  const prose = flat(template);

  assert('the template gives the flat shape', () => prose.includes('contexts/<area>.md'));
  assert('the template gives the namespaced shape', () =>
    prose.includes('contexts/<project>/<area>.md'));
  assert('the template bounds the depth', () =>
    /one project directory deep, no more/i.test(prose));
  assert('the template says when to nest rather than only that you may', () =>
    /fight over the same area name/.test(prose));
  assert('the template keeps naming and scoping apart', () =>
    /The directory names; `paths:` scopes/.test(prose));
  assert('the template says a nested context still declares paths', () =>
    /still\s*declares `paths:`/.test(prose));

  // The nested form works today only because nobody passed `flat: true` to the
  // Contexts section. Pinned on that row rather than on the file, so adding the
  // flag fails here instead of silently dropping every nested context from
  // discovery. The skills row is checked too: a guard that cannot tell the two
  // apart is not reading the flag at all.
  const index = readSrc('scripts', 'index.mjs');
  const row = (dir) => new RegExp(`\\{[^}]*dir: '${dir}'[^}]*\\}`).exec(index)?.[0] ?? '';
  assert('index.mjs walks contexts/ rather than flat-listing it', () =>
    row('contexts') !== '' && !/flat/.test(row('contexts')));
  assert('index.mjs does flat-list skills/, so the check reads the flag', () =>
    /flat/.test(row('skills')));

  const { dir, aep } = installFixture();
  const contextsDir = path.join(aep, 'contexts');
  const probe = (rel, extra = '') => {
    const file = path.join(contextsDir, ...rel.split('/'));
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, '---\naep: 0.0.0\nowner: repository\n' +
      'date: 2026-01-01\nkind: context\nuse-when: "a fixture is being probed and validate must accept it"\n---\n\n# Probe\n' + extra);
    return file;
  };
  /** Runs the fixture's own validate.mjs. Returns null on success, stderr on failure. */
  const validateFixture = () => {
    try {
      execFileSync(process.execPath, [path.join(aep, 'scripts', 'validate.mjs'), '--root', aep],
        { stdio: 'pipe' });
      return null;
    } catch (error) {
      return String(error.stderr ?? '');
    }
  };

  // All three depths, not just the rejection: a guard proven only on the failing
  // case can still be rejecting what it should accept.
  for (const [depth, rel] of [['flat', 'probe.md'], ['namespaced', 'web/auth.md']]) {
    const file = probe(rel);
    const output = validateFixture();
    fs.rmSync(file);
    assert(`validate accepts a ${depth} context`, () => output === null, { });
    if (output !== null) process.stdout.write(`        ${output.trim().split('\n').pop()}\n`);
  }
  const tooDeep = probe('web/admin/auth.md');
  const rejection = validateFixture();
  fs.rmSync(tooDeep);
  fs.rmSync(path.join(contextsDir, 'web', 'admin'), { recursive: true, force: true });
  assert('validate rejects a context nested deeper than one project directory', () =>
    rejection !== null);
  assert('the rejection names the file and both legal forms', () =>
    rejection !== null &&
    /contexts\/web\/admin\/auth\.md/.test(rejection) &&
    /contexts\/<area>\.md/.test(rejection) &&
    /contexts\/<project>\/<area>\.md/.test(rejection));

  // Behavioural, not textual: if anything derived applicability from the
  // directory, a nested context declaring no `paths:` would acquire one, and the
  // index would print it. This is the only shape of this check that can fail.
  const bare = probe('web/auth.md');
  execFileSync(process.execPath, [path.join(aep, 'scripts', 'index.mjs'), '--root', aep],
    { stdio: 'ignore' });
  const indexed = fs.readFileSync(path.join(aep, 'index.md'), 'utf8');
  fs.rmSync(bare);
  fs.rmSync(path.join(contextsDir, 'web'), { recursive: true, force: true });
  const listed = indexed.split('\n').find((line) => line.includes('[[contexts/web/auth]]')) ?? '';
  assert('the index lists a nested context by its full wiki-link', () => listed !== '');
  assert('a nested context declaring no paths acquires none from its directory', () =>
    listed !== '' && /\|\s*\u2014\s*\|\s*repository\s*\|/.test(listed));

  // Leave the fixture as it was found: a file left behind changes what every
  // later section sees in this tree.
  execFileSync(process.execPath, [path.join(aep, 'scripts', 'index.mjs'), '--root', aep],
    { stdio: 'ignore' });
  assert('the fixture is left as it was found', () =>
    !fs.existsSync(path.join(contextsDir, 'web')) && fs.existsSync(path.join(dir, '.aep')));
});

// --- §7, §30 the seeds ------------------------------------------------------

section('seeds', () => {
  for (const seed of SEEDS) {
    const file = path.join(SRC, ...seed.source.split('/'));
    assert(`${seed.source} ships`, fs.existsSync(file));
    if (!fs.existsSync(file)) continue;

    const artifact = readArtifact(file);

    if (seed.root) {
      // A root seed lands outside `.aep/`, so it is not an AEP artifact and must
      // carry no frontmatter. Otherwise the repository's own entrypoint would
      // arrive claiming to be governed by a contract that does not reach it.
      assert(`${seed.source} carries no AEP frontmatter, it lands outside .aep/`,
        !artifact.hasFrontmatter);
      assert(`${seed.source} points at the protocol rather than restating it`, () =>
        artifact.body.includes('.aep/protocol.md'));
      assert(`${seed.source} says it belongs to the repository now`, () =>
        /It is yours/.test(artifact.body));
      continue;
    }

    assert(`${seed.source} declares owner: repository`, artifact.fields.owner === 'repository');
    assert(`${seed.source} declares the release its content last changed in, not a later one`,
      atOrBeforeRelease(artifact.fields.aep));
    assert(`${seed.source} declares use-when`, isNonEmptyString(artifact.fields['use-when']));
    assert(`${seed.source} says it is a starting point rather than a description`, () =>
      /This file is yours/.test(artifact.body));
    assert(`${seed.source} targets a repository-owned directory`, () =>
      /^(contexts|references|rules)\//.test(seed.target));
  }

  // The resolution has to land somewhere the next session reads, and for the two
  // forges that ship a reference, that section is seeded rather than left to be
  // invented per repository.
  for (const forge of ['github', 'gitlab']) {
    assert(`seed/references/${forge}.md carries the section a resolution is recorded in`, () =>
      readSrc('seed', 'references', `${forge}.md`).includes('## AEP tasks in this tracker'));
  }

  // A seed file nothing declares ships in the distribution and installs
  // nowhere. Nothing else notices: the tree looks complete, the file reads as
  // authoritative, and no repository ever receives it. Across a catalogue this
  // size that is one forgotten line in the manifest.
  assert('every file under seed/ is declared in SEEDS', () => {
    const declared = new Set(SEEDS.map((seed) => seed.source));
    const orphans = walk(path.join(SRC, 'seed'))
      .map((file) => toPosix(SRC, file))
      .filter((source) => !declared.has(source));
    if (orphans.length > 0) throw new Error(`declared by nothing: ${orphans.join(', ')}`);
    return true;
  });

  // `detect: { paths: [] }` is truthy and matches nothing, so it reads as a
  // gated seed and behaves as a retired one.
  assert('every reference seed is gated on evidence that can actually match', () => {
    const dead = SEEDS.filter((seed) => seed.target.startsWith('references/')).filter(
      (seed) => !(seed.detect?.paths?.length > 0 || isNonEmptyString(seed.detect?.remote)));
    if (dead.length > 0) {
      throw new Error(`cannot ever install: ${dead.map((seed) => seed.target).join(', ')}`);
    }
    return true;
  });

  const targets = SEEDS.map((seed) => seed.target);
  assert('no seed target is declared twice', () => new Set(targets).size === targets.length);
  assert('exactly one seed targets the repository root, and it is the entrypoint', () => {
    const roots = SEEDS.filter((seed) => seed.root);
    return roots.length === 1 && roots[0].target === 'AGENTS.md';
  });
  assert('the always-seeded set is the entrypoint, version control, and a repository context', () => {
    const always = SEEDS.filter((seed) => !seed.detect).map((seed) => seed.target).sort();
    return JSON.stringify(always) ===
      JSON.stringify(['AGENTS.md', 'contexts/repository.md', 'rules/version-control.md']);
  });
});

// --- templates --------------------------------------------------------------

section('templates', () => {
  const templates = listMarkdown('templates').map((file) => path.basename(file, '.md'));
  for (const expected of ['protocol', 'agents', 'agent', 'rule', 'reference', 'context', 'skill',
    'mode', 'spec', 'ticket', 'research', 'prototype']) {
    assert(`templates/${expected}.template.md ships`, templates.includes(`${expected}.template`));
  }
  for (const file of listMarkdown('templates')) {
    const rel = toPosix(SRC, file);
    const artifact = readArtifact(file);
    assert(`${rel} declares use-when`, isNonEmptyString(artifact.fields['use-when']));
    assert(`${rel} shows its shape in a fenced block rather than as live frontmatter`, () =>
      /```/.test(artifact.body));
  }
});

// --- §9 links ---------------------------------------------------------------
// Resolved against the fixture install, because a distribution has no
// repository-owned directories: `[[contexts]]` and `[[index]]` exist only once a
// repository has been installed, and a checker that ignored them would be blind
// to exactly the links most likely to rot.

section('links', () => {
  const fixture = installFixture();
  let count = 0;
  for (const file of walk(fixture.aep, { skip: ['position', 'worktrees'] })) {
    if (!file.endsWith('.md')) continue;
    for (const target of wikiLinks(readArtifact(file).body)) {
      count += 1;
      const base = path.join(fixture.aep, ...target.split('/'));
      const resolves =
        fs.existsSync(`${base}.md`) ||
        fs.statSync(base, { throwIfNoEntry: false })?.isDirectory();
      assert(`${toPosix(fixture.aep, file)} → [[${target}]] resolves`, Boolean(resolves));
    }
  }
  assert('the payload actually contains links to check', count > 0);
  process.stdout.write(`        ${count} links checked\n`);
});

// --- §5, §15.2, §17 structures that must not exist --------------------------

section('forbidden', () => {
  for (const dir of ['decisions', 'tools', 'grill']) {
    assert(`no ${dir}/ in the distribution`, !inSrc(dir));
  }
  assert('no plan.md ships', !inSrc('plan.md'));

  const all = [...payloadArtifacts(), ...SEEDS.map((s) => path.join(SRC, ...s.source.split('/')))]
    .filter((file) => fs.existsSync(file))
    .map((file) => fs.readFileSync(file, 'utf8'))
    .join('\n');

  // Both layers, because the newer one is the likelier place to slip: a policy
  // is rigid in authority, and the tempting mistake is to make it rigid in
  // loading too.
  assert('nothing instructs an agent to load every policy or rule', () =>
    !/load all (the )?(policies|rules)/i.test(all));
  assert('the payload never treats a runtime directory as canonical state', () =>
    !/canonical[^.\n]{0,40}\.(claude|cursor|codex)\//i.test(all));
  assert('shipped text cites no record that exists only in this repository', () =>
    !/\bADR \d{4}\b/.test(all) && !/\bspecs\.md\b/.test(all));
});

// --- §16.2 the prohibitions a script can check ------------------------------
// The policy's four are one scan away from being checked, and the first of them
// is the one this repository had most of. Scoped to what the reader test calls
// governed: the shipped scripts, whose comments and messages a person reads, and
// this repository's own documentation. Everything the test calls exempt is
// asserted to be absent from the list, because an over-broad sweep is the
// failure that reads as thoroughness.

section('governed text', () => {
  const scripts = walk(SRC).filter((f) => f.endsWith('.mjs'));
  assert('there are shipped scripts to scan', () => scripts.length > 0);

  const holding = scripts
    .filter((f) => fs.readFileSync(f, 'utf8').includes(EM_DASH))
    .map((f) => toPosix(SRC, f));
  assert('no shipped script carries an em dash', () => holding.length === 0);
  if (holding.length > 0) process.stdout.write(`        holding one: ${holding.join(', ')}\n`);

  // Read inside the callback, so a file that has gone missing fails this
  // assertion rather than throwing and aborting the section, which would take
  // the scan above down with it and read as a smaller failure than it is.
  for (const name of GOVERNED_DOCS) {
    assert(`${name} carries no em dash`, () =>
      !fs.readFileSync(path.join(REPO, name), 'utf8').includes(EM_DASH));
  }

  // The exemption, proven two ways. That the exempt files are not in the swept
  // list is the claim; that each of them actually holds em dashes is what makes
  // the claim load-bearing. Without the second, a day when specs.md happens to
  // have none would leave this passing on nothing.
  for (const name of EXEMPT_DOCS) {
    assert(`${name} is exempt: it is not in the swept list`, () =>
      !GOVERNED_DOCS.includes(name));
    assert(`${name} exercises its exemption`, () =>
      fs.readFileSync(path.join(REPO, name), 'utf8').includes(EM_DASH));
  }
});

// --- §29 the adapter is a pointer, and it is current ------------------------

section('adapter', () => {
  const shippedSkills = topLevel(path.join(SRC, 'skills')).length;
  const shippedAgents = topLevel(path.join(SRC, 'agents')).length;

  // Stated here rather than read off the target, because a target asserted
  // against its own declaration asserts nothing. A new runtime has to be
  // written down twice, once as a target and once as what it is expected to
  // publish, and the two disagreeing is the whole point.
  const EXPECTED = {
    claude: {
      prefix: '',
      keys: { skill: ['name', 'description', 'metadata'], agent: ['name', 'description'] },
      // Resolved from the adapter's own root, because that is what
      // `CLAUDE_PLUGIN_ROOT` expands to once the marketplace publishes it.
      reaches: { plugin: 'adapter' },
      committed: 'plugin',
    },
    opencode: {
      prefix: 'aep-',
      keys: { skill: ['name', 'description', 'metadata'], agent: ['description', 'mode'] },
      // Resolved from the wrapper's own directory, which is the base OpenCode
      // announces to the agent when it loads a skill.
      reaches: { distribution: 'wrapper' },
      committed: 'distribution',
    },
    agents: {
      prefix: 'aep-',
      keys: { skill: ['name', 'description', 'metadata'] },
      reaches: {},
      committed: null,
    },
  };

  assert('every target is declared in the suite as well as in the generator', () => {
    const undeclared = Object.keys(TARGETS).filter((runtime) => !(runtime in EXPECTED));
    if (undeclared.length > 0) throw new Error(undeclared.join(', '));
    return true;
  });

  for (const [runtime, target] of Object.entries(TARGETS)) {
    const expected = EXPECTED[runtime];
    if (!expected) continue;

    assert(`${runtime} commits the shape the suite expects`, () =>
      target.committed === expected.committed);

    // Read from the suite rather than from the target: a guard that takes the
    // prefix off the row it is checking passes whatever that row says, so a
    // target that quietly dropped its prefix would publish `review` and be
    // told it published exactly what it declared.
    assert(`${runtime} publishes under the prefix the suite expects`, () => {
      if (target.prefix !== expected.prefix) {
        throw new Error(`declares "${target.prefix}", expected "${expected.prefix}"`);
      }
      return true;
    });

    for (const shape of target.shapes) {
      const rendered = renderAdapter(SRC, target, shape);
      const skills = rendered.filter((file) => file.kind === 'skill');
      const agents = rendered.filter((file) => file.kind === 'agent');
      const wrapsAgents = Boolean(target.path('agent', `${target.prefix}anything`, shape));

      // A target that renders nothing passes every per-file assertion below by
      // having no files to fail them. This is the one check that cannot.
      assert(`${runtime}/${shape} renders one wrapper per shipped skill`, () => {
        if (skills.length !== shippedSkills) {
          throw new Error(`${skills.length} skill wrappers for ${shippedSkills} skills`);
        }
        return true;
      });

      assert(`${runtime}/${shape} wraps every shipped agent, or none at all`, () => {
        const want = wrapsAgents ? shippedAgents : 0;
        if (agents.length !== want) throw new Error(`${agents.length} agent wrappers, expected ${want}`);
        return true;
      });

      assert(`${runtime}/${shape} publishes the names its prefix declares`, () => {
        const shape_ = target.prefix ? /^aep-[a-z0-9]+(-[a-z0-9]+)*$/ : /^[a-z0-9]+(-[a-z0-9]+)*$/;
        const wrong = rendered.filter((file) => !shape_.test(file.wrapped));
        if (wrong.length > 0) throw new Error(wrong.map((file) => file.wrapped).join(', '));
        return true;
      });

      assert(`${runtime}/${shape} names each skill wrapper for the directory holding it`, () => {
        const wrong = [];
        for (const file of skills) {
          const dir = file.relativePath.split('/').at(-2);
          const declared = /^name: (.+)$/m.exec(file.contents);
          if (!declared || declared[1] !== dir) wrong.push(file.relativePath);
        }
        if (wrong.length > 0) throw new Error(wrong.join(', '));
        return true;
      });

      for (const kind of ['skill', 'agent']) {
        const group = kind === 'skill' ? skills : agents;
        if (group.length === 0) continue;
        assert(`${runtime}/${shape} gives a ${kind} wrapper exactly the keys that runtime admits`, () => {
          const want = expected.keys[kind];
          if (!want) throw new Error(`the suite declares no ${kind} keys for ${runtime}`);
          const wrong = [];
          for (const file of group) {
            const block = /^---\n([\s\S]*?)\n---/.exec(file.contents);
            const keys = block
              ? block[1].split('\n').filter((line) => /^\S/.test(line)).map((line) => line.split(':')[0])
              : [];
            if (keys.join(',') !== want.join(',')) wrong.push(`${file.relativePath} [${keys.join(', ')}]`);
          }
          if (wrong.length > 0) throw new Error(wrong.join('; '));
          return true;
        });
      }

      assert(`${runtime}/${shape} points at the canonical artifact rather than restating it`, () => {
        const wrong = rendered.filter((file) => {
          const canonical = `.aep/${file.kind === 'skill' ? 'skills' : 'agents'}/${file.name}.md`;
          return !file.contents.includes(canonical) || file.contents.length >= 1200;
        });
        if (wrong.length > 0) throw new Error(wrong.map((file) => file.relativePath).join(', '));
        return true;
      });

      // A shape that ships outside a repository has to reach the payload it
      // travelled with, the only path that works before `.aep/` exists
      // anywhere. A shape that ships inside one must carry no reach at all: it
      // would resolve to a place nothing put a payload.
      const reach = /(?:\$\{CLAUDE_PLUGIN_ROOT\}\/|`)((?:\.\.\/)+[^`\s]+\.md)/;
      if (expected.reaches[shape]) {
        assert(`${runtime}/${shape} reaches the payload it ships beside`, () => {
          const wrong = [];
          for (const file of skills) {
            const found = reach.exec(file.contents);
            if (!found) {
              wrong.push(`${file.relativePath} declares none`);
              continue;
            }
            const adapterRoot = path.join(SRC, 'adapters', runtime);
            const root = expected.reaches[shape] === 'adapter'
              ? adapterRoot
              : path.join(adapterRoot, path.dirname(file.relativePath));
            if (!fs.existsSync(path.resolve(root, found[1]))) {
              wrong.push(`${file.relativePath} reaches ${found[1]}, which does not exist`);
            }
          }
          if (wrong.length > 0) throw new Error(wrong.join('; '));
          return true;
        });
      } else {
        assert(`${runtime}/${shape} carries no reach, having nowhere to reach`, () => {
          const wrong = rendered.filter((file) => reach.test(file.contents));
          if (wrong.length > 0) throw new Error(wrong.map((file) => file.relativePath).join(', '));
          return true;
        });
      }
    }

    const adapterDir = path.join(SRC, 'adapters', runtime);

    if (!expected.committed) {
      assert(`${runtime} commits no tree, because nothing would read one`, () =>
        !fs.existsSync(adapterDir));
      continue;
    }

    const committedRender = renderAdapter(SRC, target, expected.committed);
    for (const { relativePath, contents } of committedRender) {
      const committed = path.join(adapterDir, ...relativePath.split('/'));
      assert(`adapters/${runtime}/${relativePath} is committed`, fs.existsSync(committed));
      if (!fs.existsSync(committed)) continue;
      assert(`adapters/${runtime}/${relativePath} is current. Regenerate with scripts/adapters.mjs`,
        fs.readFileSync(committed, 'utf8') === contents);
    }

    // Only the generated subdirectories are swept. An adapter may also carry
    // hand-written runtime glue, a hook or its configuration or a manifest, which
    // the generator does not produce and must not be reported as stale.
    const generatedDirs = [...new Set(committedRender.map((file) => file.relativePath.split('/')[0]))];
    const committedFiles = generatedDirs
      .map((sub) => path.join(adapterDir, sub))
      .filter((dir) => fs.existsSync(dir))
      .flatMap((dir) => walk(dir).map((f) => toPosix(adapterDir, f)));
    assert(`the committed ${runtime} adapter has no generated file the generator does not produce`, () =>
      committedFiles.every((file) => committedRender.some((r) => r.relativePath === file)));
  }

  // Everything below is Claude's alone: how a plugin is packaged is one
  // runtime's business, and generalizing it into the loop above would assert a
  // manifest against runtimes that have none.
  const adapterDir = path.join(SRC, 'adapters', 'claude');

  // Every `.aep/…` path a wrapper names has to exist in an installed tree.
  // Nothing compared the two until now, and the cost was silent: the artifact
  // binding a sub-agent moved to `policies/execution` in 2.2.0 (`MOVES`), and
  // every agent wrapper went on naming `rules/sub-agents.md` for four releases,
  // sending each dispatched agent to read a file no release ships.
  const installedTree = installFixture().dir;
  for (const [runtime, target] of Object.entries(TARGETS)) {
    for (const shape of target.shapes) {
      assert(`every path a ${runtime}/${shape} wrapper names exists in an installed tree`, () => {
        const missing = new Set();
        for (const { relativePath, contents } of renderAdapter(SRC, target, shape)) {
          // Anchored on the extension rather than on backticks: a wrapper
          // names a path in its prose *and* in `metadata.canonical`, where
          // there are none, and a guard that saw only the quoted half would
          // pass while the field a runtime reads pointed nowhere.
          for (const [named] of contents.matchAll(/\.aep\/[\w./-]+\.md/g)) {
            if (!fs.existsSync(path.join(installedTree, ...named.split('/')))) {
              missing.add(`${relativePath} names ${named}`);
            }
          }
        }
        if (missing.size > 0) throw new Error([...missing].join('; '));
        return true;
      });
    }
  }

  // The manifest sits inside the adapter, not at the repository root, and that
  // placement is the whole mechanism: Claude Code reads a plugin's agents from
  // `<plugin root>/agents/` and a manifest `agents` path does not redirect that
  // scan. A directory there fails validation outright, and naming the files
  // loads none of them. Publishing the adapter as the plugin puts both kinds of
  // wrapper where the runtime already looks, which is why neither key is set.
  const pluginRoot = adapterDir;
  const manifest = JSON.parse(
    fs.readFileSync(path.join(pluginRoot, '.claude-plugin', 'plugin.json'), 'utf8'),
  );
  assert('plugin.json version matches specs.md', manifest.version === specVersion);
  assert('the plugin manifest sits in the adapter, which is the plugin root', () =>
    !fs.existsSync(path.join(REPO, '.claude-plugin', 'plugin.json')));

  // Every standard directory at the plugin root loads on its own, and naming
  // one in the manifest is never a no-op: `agents` and `skills` replace the
  // scan, and `hooks` registers the same file twice, which the runtime rejects
  // as a duplicate, taking the plugin's hooks down with it. Each key reads like
  // configuration and behaves like a deletion, so each absence is asserted.
  const standard = { skills: 'skills', agents: 'agents', hooks: path.join('hooks', 'hooks.json') };
  for (const [key, location] of Object.entries(standard)) {
    assert(`plugin.json declares no ${key} path. The standard location loads itself`, () =>
      !(key in manifest));
    assert(`the runtime's standard ${key} location exists to be found`, () =>
      fs.existsSync(path.join(pluginRoot, location)));
  }

  assert('every command the hooks file runs exists', () => {
    const hooks = JSON.parse(fs.readFileSync(path.join(pluginRoot, standard.hooks), 'utf8'));
    const args = JSON.stringify(hooks).match(/\$\{CLAUDE_PLUGIN_ROOT\}\/([^"]+)/g) ?? [];
    if (args.length === 0) return false;
    return args.every((arg) =>
      fs.existsSync(path.join(pluginRoot, arg.replace('${CLAUDE_PLUGIN_ROOT}/', ''))));
  });

  assert('the marketplace advertises the plugin this repository builds', () => {
    const market = JSON.parse(
      fs.readFileSync(path.join(REPO, '.claude-plugin', 'marketplace.json'), 'utf8'),
    );
    return market.plugins?.some((entry) => entry.name === manifest.name);
  });
  assert('the marketplace publishes the adapter, so the plugin root is the adapter', () => {
    const market = JSON.parse(
      fs.readFileSync(path.join(REPO, '.claude-plugin', 'marketplace.json'), 'utf8'),
    );
    const entry = market.plugins?.find((plugin) => plugin.name === manifest.name);
    const source = typeof entry?.source === 'string' ? entry.source : '';
    const published = path.resolve(REPO, source.replace(/^\.\//, ''));
    if (published !== pluginRoot) throw new Error(`publishes ${source || '(nothing)'}`);
    return true;
  });
});

// --- release readiness ------------------------------------------------------

section('release', () => {
  assert('the changelog records this version', () =>
    fs.readFileSync(path.join(REPO, 'CHANGELOG.md'), 'utf8').includes(`## ${specVersion}`));

  assert('a licence ships', () => fs.existsSync(path.join(REPO, 'LICENSE')));

  // Two-directional, because both failures misstate a licence. Nothing shipped
  // is vendored today; if that changes, the notice must come back with it.
  const vendored = [...payloadArtifacts(), ...SEEDS.map((s) => path.join(SRC, ...s.source.split('/')))]
    .filter((file) => fs.existsSync(file))
    .filter((file) => /vendored from|Copyright \(c\)/i.test(fs.readFileSync(file, 'utf8')));
  const hasNotice = fs.existsSync(path.join(REPO, 'NOTICE'));
  assert('vendored text and a third-party NOTICE travel together, or neither ships', () =>
    (vendored.length > 0) === hasNotice);
  if (vendored.length > 0) {
    process.stdout.write(`        vendored: ${vendored.map((f) => toPosix(SRC, f)).join(', ')}\n`);
  }

  assert('every mode is entered by at least one skill', () => {
    const skillText = topLevel(path.join(SRC, 'skills'))
      .map((f) => fs.readFileSync(f, 'utf8'))
      .join('\n');
    const orphans = MODES.filter((mode) => !skillText.includes(`modes/${mode}`));
    if (orphans.length > 0) throw new Error(`never entered: ${orphans.join(', ')}`);
    return true;
  });

  assert('every template is reachable from the index the bootstrap points at', () =>
    listMarkdown('templates').length > 0);

  assert('the entrypoint at the repository root points at the bootstrap', () =>
    fs.readFileSync(path.join(REPO, 'AGENTS.md'), 'utf8').includes('.aep/protocol.md'));

  assert('this repository has installed the release it ships', () => {
    const installed = readArtifact(path.join(REPO, '.aep', 'protocol.md'));
    return installed.fields.aep === specVersion;
  });

  assert("the building repository's own tree carries no stale 1.x layout", () =>
    !fs.existsSync(path.join(REPO, '.claude', 'protocol.md')) &&
    !fs.existsSync(path.join(REPO, 'scripts')));
});

// --- §30 the install writes the adapters it was asked for ------------------

section('install adapters', () => {
  /** Runs a real install into a throwaway repository. Never throws on exit. */
  const install = (args) => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'aep-adapters-'));
    execFileSync('git', ['init', '--quiet'], { cwd: dir, stdio: 'ignore' });
    const run = spawnSync(
      process.execPath,
      [path.join(SRC, 'scripts', 'install.mjs'), '--into', dir, ...args],
      { encoding: 'utf8' },
    );
    return { dir, status: run.status, out: `${run.stdout ?? ''}${run.stderr ?? ''}` };
  };

  const all = install(['--adapters', 'claude,opencode,agents']);
  assert('an install writes every adapter it was asked for', () => {
    const missing = Object.values(TARGETS)
      .map((target) => target.dir)
      .filter((dir) => !fs.existsSync(path.join(all.dir, dir)));
    if (missing.length > 0) throw new Error(`never written: ${missing.join(', ')}`);
    return true;
  });

  assert('the install report names each adapter rather than folding it into a total', () => {
    const unnamed = Object.values(TARGETS)
      .map((target) => `${target.dir}/`)
      .filter((dir) => !all.out.includes(dir));
    if (unnamed.length > 0) throw new Error(`not in the report: ${unnamed.join(', ')}`);
    return true;
  });

  // Each adapter lands in the shape written into a repository, which is the one
  // with nowhere further to fall back to.
  assert('an installed adapter is the repository shape, wrapper for wrapper', () => {
    const wrong = [];
    for (const [runtime, target] of Object.entries(TARGETS)) {
      for (const { relativePath, contents } of renderAdapter(SRC, target, 'repository')) {
        const written = path.join(all.dir, target.dir, ...relativePath.split('/'));
        if (!fs.existsSync(written)) wrong.push(`${runtime}: ${relativePath} missing`);
        else if (fs.readFileSync(written, 'utf8') !== contents) wrong.push(`${runtime}: ${relativePath} differs`);
      }
    }
    if (wrong.length > 0) throw new Error(wrong.join('; '));
    return true;
  });

  // A run that installs one adapter and then dies on a typo in the third has
  // left a repository in a state nobody asked for, so the name is resolved
  // before the first write rather than at it.
  const unknown = install(['--adapters', 'claude,nope']);
  assert('an unknown runtime stops the install', () => unknown.status !== 0);
  assert('the unknown runtime is named, along with the ones that exist', () =>
    unknown.out.includes('nope') && Object.keys(TARGETS).every((name) => unknown.out.includes(name)));
  assert('an unknown runtime is refused before anything is written', () =>
    !fs.existsSync(path.join(unknown.dir, '.aep')));

  // OpenCode reads both locations, so asking for both loads every skill twice
  // under one name. It is warned rather than refused, because a repository
  // driven through a harness with another provider can genuinely want both.
  const pair = install(['--adapters', 'opencode,agents']);
  assert('asking for both locations OpenCode reads warns, and says why', () =>
    /^warning:/m.test(pair.out) && /twice under one name/.test(pair.out));
  assert('the warning is not a refusal', () =>
    pair.status === 0 &&
    fs.existsSync(path.join(pair.dir, '.opencode')) &&
    fs.existsSync(path.join(pair.dir, '.agents')));

  const alone = install(['--adapters', 'opencode']);
  assert('one adapter alone warns about nothing', () => !/^warning:/m.test(alone.out));

  const none = install([]);
  assert('an install asked for no adapter writes none', () =>
    Object.values(TARGETS).every((target) => !fs.existsSync(path.join(none.dir, target.dir))));

  // A seed installs on the evidence a human wrote, never on a directory an
  // adapter creates: `.opencode/` is AEP's own output, and detecting on it would
  // make this installation the evidence that the repository uses OpenCode.
  const seeded = (files) => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'aep-detect-'));
    execFileSync('git', ['init', '--quiet'], { cwd: dir, stdio: 'ignore' });
    for (const [name, body] of Object.entries(files)) {
      fs.mkdirSync(path.dirname(path.join(dir, name)), { recursive: true });
      if (name.endsWith('/')) fs.mkdirSync(path.join(dir, name), { recursive: true });
      else fs.writeFileSync(path.join(dir, name), body, 'utf8');
    }
    execFileSync(process.execPath, [path.join(SRC, 'scripts', 'install.mjs'), '--into', dir], {
      stdio: 'ignore',
    });
    return (reference) => fs.existsSync(path.join(dir, '.aep', 'references', reference));
  };

  const withOpencode = seeded({ 'opencode.json': '{}' });
  assert('opencode.json seeds the OpenCode reference', () => withOpencode('opencode.md'));
  assert('opencode.json does not seed the T3 Code reference', () => !withOpencode('t3code.md'));

  const withT3 = seeded({ 't3.json': '{}' });
  assert('t3.json seeds the T3 Code reference', () => withT3('t3code.md'));
  assert('t3.json does not seed the OpenCode reference', () => !withT3('opencode.md'));

  const withDirOnly = seeded({ '.opencode/opencode-is-not-config.txt': '' });
  assert('a .opencode directory is not evidence. An adapter writes one', () =>
    !withDirOnly('opencode.md'));

  const bare = seeded({});
  assert('a repository running neither gets neither reference', () =>
    !bare('opencode.md') && !bare('t3code.md'));
});

// --- §32 the install fixture ------------------------------------------------

section('install fixture', () => {
  const { dir, aep } = installFixture();

  assert('installing creates .aep/protocol.md', fs.existsSync(path.join(aep, 'protocol.md')));
  assert('installing creates .aep/.gitignore', fs.existsSync(path.join(aep, '.gitignore')));
  for (const perClone of ['position', 'worktrees']) {
    assert(`.gitignore excludes ${perClone}/`, () =>
      fs.readFileSync(path.join(aep, '.gitignore'), 'utf8').includes(`${perClone}/`));
  }
  for (const owned of REPOSITORY_DIRS) {
    assert(`installing creates ${owned}/`, fs.existsSync(path.join(aep, owned)));
  }

  // `rules/` is the repository's half of the governance split, so a fresh
  // install must hand it over empty of anything the protocol owns.
  assert('installing puts nothing protocol-owned in rules/', () => {
    const intruders = walk(path.join(aep, 'rules'))
      .filter((file) => file.endsWith('.md'))
      .filter((file) => readArtifact(file).fields.owner !== 'repository')
      .map((file) => toPosix(aep, file));
    if (intruders.length > 0) throw new Error(intruders.join(', '));
    return true;
  });
  for (const script of PAYLOAD_SCRIPTS) {
    assert(`installing ships scripts/${script}`, fs.existsSync(path.join(aep, 'scripts', script)));
  }
  for (const script of BUILD_ONLY_SCRIPTS) {
    assert(`installing does not ship scripts/${script}`,
      !fs.existsSync(path.join(aep, 'scripts', script)));
  }

  // A bare `git init` directory has a .git and nothing else, so exactly the
  // always-seeds plus git should land. That the detected ones stay away is the
  // half worth asserting: a detector that fires on everything is no detector.
  assert('always-seeds install', () =>
    fs.existsSync(path.join(aep, 'rules', 'version-control.md')) &&
    fs.existsSync(path.join(aep, 'contexts', 'repository.md')));
  assert('git is detected in a git repository', () =>
    fs.existsSync(path.join(aep, 'references', 'git.md')));
  assert('no reference installs without its evidence', () => {
    const wrongly = SEEDS
      .filter((seed) => seed.target.startsWith('references/'))
      .filter((seed) => seed.target !== 'references/git.md')
      .filter((seed) => fs.existsSync(path.join(aep, ...seed.target.split('/'))));
    if (wrongly.length > 0) {
      throw new Error(`installed into a bare repository: ${
        wrongly.map((seed) => seed.target).join(', ')}`);
    }
    return true;
  });

  assert('installing writes the entrypoint at the repository root', () =>
    fs.existsSync(path.join(dir, 'AGENTS.md')));
  assert('the entrypoint points at the bootstrap rather than restating it', () => {
    const text = fs.readFileSync(path.join(dir, 'AGENTS.md'), 'utf8');
    return text.includes('.aep/protocol.md') && !text.includes('## The primitives');
  });
  assert('the entrypoint carries no AEP frontmatter', () =>
    !fs.readFileSync(path.join(dir, 'AGENTS.md'), 'utf8').startsWith('---'));

  assert('the tickets section is absent when a repository keeps no local tickets', () =>
    !fs.readFileSync(path.join(aep, 'index.md'), 'utf8').includes('## Tickets'));

  assert('the index lists every template, as protocol.md says it does', () => {
    const index = fs.readFileSync(path.join(aep, 'index.md'), 'utf8');
    if (!index.includes('## Templates')) return false;
    return listMarkdown('templates')
      .map((file) => path.basename(file, '.md'))
      .every((name) => index.includes(`[[templates/${name}]]`));
  });

  assert('installing carries the skill notes across', () => {
    const shipped = walk(path.join(SRC, 'skills'))
      .filter((f) => f.endsWith('.md') && path.dirname(f) !== path.join(SRC, 'skills'))
      .map((f) => toPosix(path.join(SRC, 'skills'), f));
    return shipped.every((rel) => fs.existsSync(path.join(aep, 'skills', ...rel.split('/'))));
  });

  // Installed and reachable, but not advertised: the index is the list of things
  // an agent can start, and a note is not one of them.
  assert('the index lists skills and no note among them', () => {
    const index = fs.readFileSync(path.join(aep, 'index.md'), 'utf8');
    for (const name of SKILLS) {
      if (!index.includes(`[[skills/${name}]]`)) throw new Error(`skills/${name} missing`);
    }
    const listed = [...index.matchAll(/\[\[skills\/([^\]]+)\]\]/g)].map((m) => m[1]);
    const notes = listed.filter((target) => target.includes('/'));
    if (notes.length > 0) throw new Error(`listed as skills: ${notes.join(', ')}`);
    return true;
  });

  // §31.1, the one failure that reports success. A 1.x repository has no
  // `.aep/`, so the "already installed?" check answers no and a fresh install
  // lands beside a live 1.x tree, orphaning everything in it.
  assert('a fresh install onto a 1.x layout is refused, and names the way forward', () => {
    const legacyDir = fs.mkdtempSync(path.join(os.tmpdir(), 'aep-legacy-'));
    fs.mkdirSync(path.join(legacyDir, '.claude', 'policies'), { recursive: true });
    fs.writeFileSync(path.join(legacyDir, '.claude', 'protocol.md'), '---\nowner: framework\n---\n');
    try {
      execFileSync(process.execPath, [path.join(SRC, 'scripts', 'install.mjs'), '--into', legacyDir], {
        stdio: 'pipe',
      });
    } catch (error) {
      const message = String(error.stderr ?? '');
      if (!message.includes('1.x')) throw new Error(`refused without naming 1.x: ${message}`);
      if (!message.includes('/update')) throw new Error('refused without naming /update');
      if (fs.existsSync(path.join(legacyDir, '.aep'))) throw new Error('refused but still wrote .aep/');
      return true;
    }
    throw new Error('installed over a 1.x repository without refusing');
  });

  assert('--migrate is the deliberate way through that refusal', () => {
    const legacyDir = fs.mkdtempSync(path.join(os.tmpdir(), 'aep-migrate-'));
    fs.mkdirSync(path.join(legacyDir, '.claude', 'decisions'), { recursive: true });
    execFileSync(
      process.execPath,
      [path.join(SRC, 'scripts', 'install.mjs'), '--into', legacyDir, '--migrate'],
      { stdio: 'pipe' },
    );
    return fs.existsSync(path.join(legacyDir, '.aep', 'protocol.md'));
  });

  assert('the installed tree passes validate.mjs', () => {
    execFileSync(process.execPath, [path.join(aep, 'scripts', 'validate.mjs'), '--root', aep], {
      stdio: 'pipe',
    });
    return true;
  });

  assert('regenerating the index is byte-identical', () => {
    const before = fs.readFileSync(path.join(aep, 'index.md'), 'utf8');
    execFileSync(process.execPath, [path.join(aep, 'scripts', 'index.mjs'), '--root', aep], {
      stdio: 'ignore',
    });
    return fs.readFileSync(path.join(aep, 'index.md'), 'utf8') === before;
  });

  assert('position stamps and then matches', () => {
    for (const command of ['stamp', 'check']) {
      execFileSync(
        process.execPath,
        [path.join(aep, 'scripts', 'position.mjs'), command, '--root', aep],
        { stdio: 'ignore' },
      );
    }
    return true;
  });

  // Returns what the installer printed, because two assertions below check that
  // a replacement was reported rather than only that it happened.
  const update = () =>
    String(execFileSync(
      process.execPath,
      [path.join(SRC, 'scripts', 'install.mjs'), '--into', dir, '--update'],
      { encoding: 'utf8' },
    ));

  // Ownership is a fact about location, so a file standing at a path the payload
  // ships is the protocol's whatever it declares. An upgrade replaces it, and
  // the protection the `owner:` field used to give is recovered from content:
  // the replacement is reported rather than made silently. Both halves are
  // asserted, because replacing without reporting is the silent loss the old
  // check existed to prevent.
  assert('an upgrade replaces a file standing at a shipped path, and says so', () => {
    const intruder = path.join(aep, 'policies', 'engineering.md');
    fs.writeFileSync(intruder, '# Local\n', 'utf8');
    const output = update();
    const replaced = fs.readFileSync(intruder, 'utf8') === readSrc('policies', 'engineering.md');
    if (!replaced) throw new Error('the shipped file was not restored');
    if (!/locally edited and replaced/.test(output)) {
      throw new Error('the replacement was not reported');
    }
    if (!/policies\/engineering\.md/.test(output)) {
      throw new Error(`the report did not name the file: ${output}`);
    }
    return true;
  });

  // The case the field never could catch: a repository file under a name the
  // protocol does not ship. The installer preserves it, because the manifest
  // does not name it, and the validator says it is in the wrong directory.
  assert('an upgrade preserves a repository file at a name the protocol does not ship', () => {
    const intruder = path.join(aep, 'policies', 'local-invention.md');
    fs.writeFileSync(intruder, '# Local\n', 'utf8');
    update();
    return fs.existsSync(intruder) && fs.readFileSync(intruder, 'utf8') === '# Local\n';
  });

  assert('validate then rejects it, rather than the upgrade correcting it', () => {
    const intruder = path.join(aep, 'policies', 'local-invention.md');
    let failed = false;
    let output = '';
    try {
      execFileSync(process.execPath, [path.join(aep, 'scripts', 'validate.mjs'), '--root', aep],
        { stdio: 'pipe' });
    } catch (error) {
      failed = true;
      output = String(error.stderr ?? '');
    }
    // Restore the tree before anything downstream reads it.
    fs.rmSync(intruder);
    if (!failed) throw new Error('validate passed on a repository file inside policies/');
    if (!/policies\/ holds only what the protocol ships/.test(output)) {
      throw new Error(`failed for some other reason: ${output}`);
    }
    return true;
  });

  assert('an upgrade replaces a protocol-owned file that was edited locally', () => {
    const modeFile = path.join(aep, 'modes', 'implement.md');
    fs.writeFileSync(modeFile, 'tampered\n', 'utf8');
    update();
    return fs.readFileSync(modeFile, 'utf8') === readSrc('modes', 'implement.md');
  });

  assert('an upgrade never re-seeds a corrected starting point', () => {
    const seeded = path.join(aep, 'references', 'git.md');
    fs.writeFileSync(seeded, `${fs.readFileSync(seeded, 'utf8')}\n<!-- corrected here -->\n`, 'utf8');
    update();
    return fs.readFileSync(seeded, 'utf8').includes('corrected here');
  });

  assert('an upgrade never overwrites an entrypoint the repository already has', () => {
    const entrypoint = path.join(dir, 'AGENTS.md');
    fs.writeFileSync(entrypoint, '# Ours\n\nRead `.aep/protocol.md`.\n', 'utf8');
    update();
    return fs.readFileSync(entrypoint, 'utf8').startsWith('# Ours');
  });

  // --- upgrading a tree that predates the moves ------------------------------
  //
  // Built from the nine real filenames rather than from a guess at what the
  // earlier layout looked like: a fixture that invents the shape it is testing
  // proves only that the invention is handled.
  //
  // One of the nine is deliberately repository-owned. It is the case the whole
  // design turns on, a repository that wrote its own rule under a name the
  // protocol has since vacated, and it is simultaneously the negative case for
  // the link rewriter, whose link must be left exactly as it is.

  const legacyTree = ({ dryRun = false } = {}) => {
    const old = fs.mkdtempSync(path.join(os.tmpdir(), 'aep-premove-'));
    execFileSync('git', ['init', '--quiet'], { cwd: old, stdio: 'ignore' });
    execFileSync(process.execPath, [path.join(SRC, 'scripts', 'install.mjs'), '--into', old],
      { stdio: 'ignore' });
    const tree = path.join(old, '.aep');

    // Wind the tree back: governance lived in rules/, policies/ did not exist,
    // and, the part that decides whether the moves apply at all, the tree
    // declared the earlier release.
    fs.rmSync(path.join(tree, 'policies'), { recursive: true, force: true });
    const bootstrap = path.join(tree, 'protocol.md');
    fs.writeFileSync(
      bootstrap,
      fs.readFileSync(bootstrap, 'utf8').replace(/^aep: .*$/m, `aep: ${PRE_MOVE_RELEASE}`),
      'utf8',
    );
    const frontmatter = (owner, kind) =>
      ['---', `aep: ${PRE_MOVE_RELEASE}`, `owner: ${owner}`, 'date: 2026-08-16', `kind: ${kind}`,
        'use-when: "a trigger that predates the move"', '---', ''];

    for (const move of MOVES) {
      const name = path.basename(move.from);
      const owner = name === 'evidence.md' ? 'repository' : 'protocol';
      fs.writeFileSync(
        path.join(tree, 'rules', name),
        [...frontmatter(owner, 'rule'), `# Rule \u2014 ${name.replace('.md', '')}`, ''].join('\n'),
        'utf8',
      );
    }

    fs.writeFileSync(
      path.join(tree, 'contexts', 'moved.md'),
      [...frontmatter('repository', 'context'), '# Context \u2014 links across the move', '',
        'Governed by `[[rules/engineering]]`, and by our own `[[rules/evidence]]`.', '',
        'The syntax, shown rather than used:', '',
        '```', '[[rules/change-control]]', '```', ''].join('\n'),
      'utf8',
    );

    const output = execFileSync(
      process.execPath,
      [path.join(SRC, 'scripts', 'install.mjs'), '--into', old, '--update',
        ...(dryRun ? ['--dry-run'] : [])],
      { encoding: 'utf8' },
    );
    return { old, tree, output };
  };

  const upgraded = legacyTree();

  assert('an upgrade removes every protocol-owned file the release moved', () => {
    const left = MOVES
      .map((move) => move.from)
      .filter((from) => path.basename(from) !== 'evidence.md')
      .filter((from) => fs.existsSync(path.join(upgraded.tree, ...from.split('/'))));
    if (left.length > 0) throw new Error(`still governing: ${left.join(', ')}`);
    return true;
  });

  assert('and reports each one it removed', () =>
    MOVES
      .filter((move) => path.basename(move.from) !== 'evidence.md')
      .every((move) => upgraded.output.includes(`${move.from} → ${move.to}`)));

  assert('the policies the moves point at are all present afterwards', () =>
    [...new Set(MOVES.map((move) => move.to))]
      .every((to) => fs.existsSync(path.join(upgraded.tree, ...to.split('/')))));

  assert('a repository-owned file at a vacated path survives, and is reported', () => {
    const kept = path.join(upgraded.tree, 'rules', 'evidence.md');
    if (!fs.existsSync(kept)) throw new Error('the upgrade removed a file the repository owns');
    if (readArtifact(kept).fields.owner !== 'repository') throw new Error('it was overwritten');
    if (!upgraded.output.includes('rules/evidence.md is the repository\'s')) {
      throw new Error('the collision was not reported');
    }
    return true;
  });

  assert('links into a vacated path are repaired, and the file is named', () => {
    const text = fs.readFileSync(path.join(upgraded.tree, 'contexts', 'moved.md'), 'utf8');
    if (!text.includes('[[policies/engineering]]')) throw new Error('the moved link was not repaired');
    if (!upgraded.output.includes('links repaired')) throw new Error('no repair was reported');
    return true;
  });

  assert('a link to a path the repository still occupies is left alone', () => {
    const text = fs.readFileSync(path.join(upgraded.tree, 'contexts', 'moved.md'), 'utf8');
    if (!text.includes('[[rules/evidence]]')) {
      throw new Error('redirected a live link to a file the repository owns');
    }
    return true;
  });

  assert('the upgraded tree validates', () => {
    execFileSync(process.execPath,
      [path.join(upgraded.tree, 'scripts', 'index.mjs'), '--root', upgraded.tree],
      { stdio: 'ignore' });
    execFileSync(process.execPath,
      [path.join(upgraded.tree, 'scripts', 'validate.mjs'), '--root', upgraded.tree],
      { stdio: 'pipe' });
    return true;
  });

  // The rewriter and the link checker have to agree about what a link is. The
  // checker strips fences because a link inside one is syntax being shown; a
  // rewriter that does not strip them edits the example instead of repairing a
  // reference.
  assert('a link inside a fenced block is left as the example it is', () => {
    const text = fs.readFileSync(path.join(upgraded.tree, 'contexts', 'moved.md'), 'utf8');
    if (!text.includes('[[rules/change-control]]')) {
      throw new Error('rewrote a link inside a fence, where nothing was resolving it anyway');
    }
    return true;
  });

  assert('a repaired file has its last-modified date moved with it', () => {
    const artifact = readArtifact(path.join(upgraded.tree, 'contexts', 'moved.md'));
    if (artifact.fields.date === '2026-08-16') {
      throw new Error('the link was repaired and the file still claims it was not touched');
    }
    return /^\d{4}-\d{2}-\d{2}$/.test(artifact.fields.date);
  });

  // The bound that keeps a vacated name usable. Without it, a repository that
  // later writes its own rule under one of these names is told it collides, on
  // every upgrade, forever.
  assert('the moves do not apply to a tree that already declares this release', () => {
    const current = fs.mkdtempSync(path.join(os.tmpdir(), 'aep-postmove-'));
    execFileSync(process.execPath, [path.join(SRC, 'scripts', 'install.mjs'), '--into', current],
      { stdio: 'ignore' });
    const tree = path.join(current, '.aep');
    const mine = path.join(tree, 'rules', 'precedence.md');
    fs.writeFileSync(
      mine,
      ['---', `aep: ${specVersion}`, 'owner: repository', 'date: 2026-08-17', 'kind: rule',
        'use-when: "a name the protocol vacated, and this repository then took"',
        '---', '', '# Rule \u2014 ours', ''].join('\n'),
      'utf8',
    );
    const output = execFileSync(
      process.execPath,
      [path.join(SRC, 'scripts', 'install.mjs'), '--into', current, '--update'],
      { encoding: 'utf8' },
    );
    if (/name collisions/.test(output)) {
      throw new Error('reported a collision against a name this release already vacated');
    }
    return fs.existsSync(mine);
  });

  // §31, notices. The negative case is the one that matters: a filter matching
  // every tree reads exactly like a filter that works, and every reader of a
  // current tree would be told to go and check something already true.
  assert('an upgrade reports the notices for the releases it crosses', () => {
    if (!/\d+ things? to check/.test(upgraded.output)) throw new Error('no notices reported');
    for (const notice of NOTICES) {
      if (!precedesRelease(PRE_MOVE_RELEASE, notice.since)) continue;
      const opening = notice.check.split(/\s+/).slice(0, 4).join(' ');
      if (!upgraded.output.includes(opening)) throw new Error(`${notice.since} not reported`);
    }
    return true;
  });

  assert('a tree already at this release is shown no notices', () => {
    const current = fs.mkdtempSync(path.join(os.tmpdir(), 'aep-nonotice-'));
    execFileSync(process.execPath, [path.join(SRC, 'scripts', 'install.mjs'), '--into', current],
      { stdio: 'ignore' });
    const output = execFileSync(
      process.execPath,
      [path.join(SRC, 'scripts', 'install.mjs'), '--into', current, '--update'],
      { encoding: 'utf8' },
    );
    if (/to check/.test(output)) throw new Error('told a current tree to go and check something');
    return true;
  });

  assert('every declared notice names a real release and says what to check', () =>
    NOTICES.every((notice) => release(notice.since) !== null && isNonEmptyString(notice.check)));

  // Pinned on the file it names and the reason it exists, not on the word
  // "tracker", which appears four times in this notice, so a looser test passes
  // on a notice that has lost its actual subject.
  // Pinned to 2.3.0, the release that actually changed those references, not to
  // whichever release is being built. Tied to specVersion it demanded that every
  // future release re-declare a notice about a change it did not make.
  assert('the release that changed the tracker references declares a notice for it', () =>
    NOTICES.some((notice) => notice.since === '2.3.0' &&
      /references\/github\.md/.test(notice.check) && /re-seed/.test(notice.check)));

  assert('skills/update acts on a notice rather than printing it', () => {
    const update = readSrc('skills', 'update.md');
    return /A notice is acted on, not read/.test(update) &&
      /report it as outstanding/.test(update);
  });

  assert('a dry run previews the notices as well as the repairs', () => {
    const preview = legacyTree({ dryRun: true });
    if (!/to check/.test(preview.output)) throw new Error('a dry run hid the notices');
    return true;
  });

  assert('a dry run previews the repairs a real run would make', () => {
    const preview = legacyTree({ dryRun: true });
    if (!/protocol files moved by this release/.test(preview.output)) {
      throw new Error('previewed no moves');
    }
    if (!/links repaired/.test(preview.output)) {
      throw new Error('previewed moves but no link repairs. The preview understates the upgrade');
    }
    return true;
  });

  assert('running the same upgrade again changes nothing', () => {
    const output = execFileSync(
      process.execPath,
      [path.join(SRC, 'scripts', 'install.mjs'), '--into', upgraded.old, '--update'],
      { encoding: 'utf8' },
    );
    if (/protocol files moved by this release/.test(output)) throw new Error('moved again');
    if (/links repaired/.test(output)) throw new Error('rewrote links again');
    return true;
  });

  // `.aep/policies/` is the current layout; `.claude/policies/` is 1.x. The word
  // is shared and the meanings are opposite, so the detector is asserted from
  // both sides rather than trusted to be path-scoped.
  assert('a tree with .aep/policies/ is not mistaken for 1.x', () => {
    const current = fs.mkdtempSync(path.join(os.tmpdir(), 'aep-current-'));
    execFileSync(process.execPath, [path.join(SRC, 'scripts', 'install.mjs'), '--into', current],
      { stdio: 'ignore' });
    if (!fs.existsSync(path.join(current, '.aep', 'policies'))) {
      throw new Error('the install produced no policies/ to test with');
    }
    execFileSync(process.execPath,
      [path.join(SRC, 'scripts', 'install.mjs'), '--into', current, '--update'], { stdio: 'ignore' });
    return true;
  });

  // Local tickets earn a section in the index only by existing. Built here
  // rather than shipped as a fixture directory, so the assertion exercises the
  // same path a real /tasks run would.
  assert('a local ticket produces a Tickets section in the index', () => {
    const effort = path.join(aep, 'efforts', 'sample-effort');
    fs.mkdirSync(path.join(effort, 'tickets'), { recursive: true });
    fs.writeFileSync(
      path.join(effort, 'spec.md'),
      ['---', `aep: ${specVersion}`, 'owner: repository', 'date: 2026-08-16', 'kind: spec',
        'status: accepted', '---', '', '# Problem', ''].join('\n'),
      'utf8',
    );
    fs.writeFileSync(
      path.join(effort, 'tickets', '01-first.md'),
      ['---', `aep: ${specVersion}`, 'owner: repository', 'date: 2026-08-16', 'kind: ticket',
        'status: open', 'part-of: sample-effort', 'blocked-by: [02]', '---', '',
        '# feat(sample): the first task', ''].join('\n'),
      'utf8',
    );
    execFileSync(process.execPath, [path.join(aep, 'scripts', 'index.mjs'), '--root', aep], {
      stdio: 'ignore',
    });
    const index = fs.readFileSync(path.join(aep, 'index.md'), 'utf8');
    return (
      index.includes('## Tickets') &&
      index.includes('[[efforts/sample-effort/tickets/01-first]]') &&
      index.includes('feat(sample): the first task') &&
      index.includes('sample-effort') &&
      index.includes('open') &&
      index.includes('02')
    );
  });

  assert('a tree carrying local tickets still validates, and its index is stable', () => {
    execFileSync(process.execPath, [path.join(aep, 'scripts', 'validate.mjs'), '--root', aep], {
      stdio: 'pipe',
    });
    const before = fs.readFileSync(path.join(aep, 'index.md'), 'utf8');
    execFileSync(process.execPath, [path.join(aep, 'scripts', 'index.mjs'), '--root', aep], {
      stdio: 'ignore',
    });
    return fs.readFileSync(path.join(aep, 'index.md'), 'utf8') === before;
  });

  assert('installing over an existing tree without --update refuses', () => {
    try {
      execFileSync(process.execPath, [path.join(SRC, 'scripts', 'install.mjs'), '--into', dir], {
        stdio: 'pipe',
      });
      return false;
    } catch {
      return true;
    }
  });

  assert('the Claude adapter installs as pointers into .aep/', () => {
    execFileSync(
      process.execPath,
      [path.join(SRC, 'scripts', 'install.mjs'), '--into', dir, '--update', '--adapters', 'claude'],
      { stdio: 'ignore' },
    );
    const wrapper = path.join(dir, '.claude', 'skills', 'specify', 'SKILL.md');
    if (!fs.existsSync(wrapper)) return false;
    const text = fs.readFileSync(wrapper, 'utf8');
    return text.includes('.aep/skills/specify.md') && !text.includes('# /specify');
  });
});

// --- the guard fires --------------------------------------------------------
// A verification suite is worth what its failure mode is worth, and a check that
// cannot fail reads exactly like a check that passed. This proves the harness
// distinguishes the two before any result above is trusted.

// --- the frontier is computed, not judged --------------------------------------
// Scheduling is a graph the tickets already declare. An orchestrator that reads
// them and decides independence for itself is inferring what was written down,
// so the answer is computed here and its shape is pinned.

section('frontier', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'aep-frontier-'));
  const aep = path.join(dir, '.aep');
  const tickets = path.join(aep, 'efforts', 'probe', 'tickets');
  fs.mkdirSync(tickets, { recursive: true });
  fs.copyFileSync(path.join(SRC, 'protocol.md'), path.join(aep, 'protocol.md'));

  const ticket = (name, status, blockedBy) => fs.writeFileSync(
    path.join(tickets, name),
    ['---', `status: ${status}`, ...(blockedBy ? [`blocked-by: [${blockedBy}]`] : []), '---', '', '# t', '']
      .join('\n'),
    'utf8',
  );

  const run = (...extra) => {
    const result = spawnSync(
      process.execPath,
      [path.join(SRC, 'scripts', 'frontier.mjs'), 'probe', '--root', aep, ...extra],
      { encoding: 'utf8' },
    );
    return { out: result.stdout, err: result.stderr, code: result.status };
  };

  ticket('01-first.md', 'resolved');
  ticket('02-second.md', 'open');
  ticket('03-third.md', 'open', '02');
  ticket('04-fourth.md', 'open', '02, 03');

  assert('an unblocked ticket is ready, and its blockers are named', () => {
    const { out, code } = run();
    if (code !== 0) throw new Error(`exit ${code}, expected 0 while work remains`);
    if (!/^ready {4}02 second$/m.test(out)) throw new Error(`no ready line for 02: ${out}`);
    if (!/^blocked {2}03 third by 02$/m.test(out)) throw new Error(`no blocked line for 03: ${out}`);
    if (!/^blocked {2}04 fourth by 02,03$/m.test(out)) throw new Error(`04 names the wrong gates: ${out}`);
    return true;
  });

  assert('a resolved ticket gates nothing and appears nowhere', () => !/01 first/.test(run().out));

  assert('parking belongs to the caller, echoed rather than decided', () => {
    const { out } = run('--parked', '02');
    if (!/^parked {3}02 second$/m.test(out)) throw new Error(`02 was not echoed as parked: ${out}`);
    if (/^ready/m.test(out)) throw new Error('parking 02 left something ready');
    return true;
  });

  assert('an obsolete ticket satisfies an edge, since nobody will do it', () => {
    ticket('02-second.md', 'obsolete');
    const ready = /^ready {4}03 third$/m.test(run().out);
    ticket('02-second.md', 'open');
    return ready;
  });

  assert('nothing unresolved exits 1, which is how a loop knows to stop', () => {
    for (const name of ['02-second.md', '03-third.md', '04-fourth.md']) ticket(name, 'resolved');
    const { out, code } = run();
    if (code !== 1) throw new Error(`exit ${code}, expected 1`);
    if (out.trim() !== '') throw new Error(`printed something: ${out}`);
    for (const name of ['02-second.md', '03-third.md', '04-fourth.md']) ticket(name, 'open');
    ticket('03-third.md', 'open', '02');
    ticket('04-fourth.md', 'open', '02, 03');
    return true;
  });

  assert('an edge naming no ticket is an error, never a satisfied gate', () => {
    ticket('05-dangling.md', 'open', '99');
    const { err, code } = run();
    fs.rmSync(path.join(tickets, '05-dangling.md'));
    if (code !== 2) throw new Error(`exit ${code}, expected 2`);
    if (!/no ticket has that id/.test(err)) throw new Error(`wrong diagnosis: ${err}`);
    return true;
  });

  assert('an unreadable effort exits 2 rather than reporting an empty frontier', () => {
    const result = spawnSync(
      process.execPath,
      [path.join(SRC, 'scripts', 'frontier.mjs'), 'nosuch', '--root', aep],
      { encoding: 'utf8' },
    );
    return result.status === 2 && /no tickets directory/.test(result.stderr);
  });

  fs.rmSync(dir, { recursive: true, force: true });
});

section('the guard fires', () => {
  const before = failures.length;
  assert('a deliberately false assertion is recorded as a failure', false, { silent: true });
  if (failures.length === before + 1) {
    failures.pop();
    passes += 1;
    process.stdout.write('  PASS  the failure path works. Seeded failure discarded\n');
  } else {
    failures.push('[the guard fires] the harness did not record a seeded failure');
    process.stdout.write('  FAIL  the harness did not record a seeded failure\n');
  }
});

// --- summary ----------------------------------------------------------------

if (fixtureCache) fs.rmSync(fixtureCache.dir, { recursive: true, force: true });

process.stdout.write(`\n${passes} passed, ${failures.length} failed\n`);

if (failures.length > 0) {
  process.stdout.write('\nfailures:\n');
  for (const failure of failures) process.stdout.write(`  ${failure}\n`);
  process.exit(1);
}

process.stdout.write('\nnot checked mechanically, and deliberately so:\n');
process.stdout.write('  - whether a use-when shaped like a trigger names the right occasion\n');
process.stdout.write('  - whether each mode genuinely gives something up\n');
process.stdout.write("  - whether a skill's procedure produces what it claims\n");
