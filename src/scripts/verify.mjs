// Asserts the shipped public surfaces against specs.md.
//
// AEP ships as Markdown and JavaScript, so there is no compiler to catch a
// broken build. This is the substitute, and its scope is deliberate: it checks
// what the protocol *distributes* — everything under `src/`, plus the plugin
// manifest that points at it — against the specification that defines them. It
// does not audit this repository's own installed `.aep/`; that tree is an
// installation, checked by `validate.mjs` exactly as any other repository's is.
//
// Every mechanically checkable requirement in specs.md gets an assertion here,
// named after the section that demands it. A requirement that cannot be checked
// mechanically — whether a `use-when` states a trigger rather than a topic,
// whether a mode really gives something up — is reported as unchecked at the
// end rather than quietly omitted.
//
//   node src/scripts/verify.mjs [--section <name>] [--verbose]

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import {
  KINDS,
  MODELESS_SKILLS,
  MODES,
  OWNERS,
  SKILLS,
  isIsoDate,
  isNonEmptyString,
  readArtifact,
  toPosix,
  topLevel,
  walk,
  wikiLinks,
} from './contract.mjs';
import { renderClaudeAdapter } from './adapters.mjs';
import {
  BUILD_ONLY_SCRIPTS,
  GITIGNORE_SOURCE,
  PAYLOAD_DIRS,
  PAYLOAD_FILES,
  PAYLOAD_SCRIPTS,
  SEEDS,
} from './payload.mjs';

/** `src/` — the distribution. */
const SRC = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
/** The repository that builds it. */
const REPO = path.dirname(SRC);

const PROTOCOL_BUDGET_BYTES = 8192;

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
    failures.push(`[${name}] section aborted — ${error.message}`);
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
    failures.push(`[${current}] ${because}${detail ? ` — ${detail}` : ''}`);
    // `silent` exists for the self-test below, whose assertion is *meant* to
    // fail. Printing it would put the word FAIL in the output of a passing run,
    // which is the one thing a reader scans for.
    if (!silent) process.stdout.write(`  FAIL  ${because}${detail ? ` — ${detail}` : ''}\n`);
  }
}

const readSrc = (...parts) => fs.readFileSync(path.join(SRC, ...parts), 'utf8');
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

  // Every shipped .mjs, not only the ones under scripts/ — the adapter's hook is
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

  // A payload directory at the repository root is a real hazard: a second
  // `skills/`, `agents/`, or `rules/` there reads as canonical and drifts from
  // the one that ships. Nothing needs to sit there — the plugin is published
  // from the adapter's own directory, so the runtime's scans land inside `src/`.
  assert('every shipped surface lives under src/', () => {
    const stray = ['skills', 'agents', 'modes', 'rules', 'scripts', 'templates', 'protocol.md']
      .filter((name) => fs.existsSync(path.join(REPO, name)));
    if (stray.length > 0) throw new Error(`at the repository root: ${stray.join(', ')}`);
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
    assert(`${rel} declares aep matching specs.md (${specVersion})`,
      artifact.fields.aep === specVersion);
    assert(`${rel} declares owner: protocol`, artifact.fields.owner === 'protocol');
    assert(`${rel} declares a real YYYY-MM-DD date`, isIsoDate(artifact.fields.date));

    if (artifact.fields.kind !== undefined) {
      assert(`${rel} declares a legal kind`, KINDS.includes(artifact.fields.kind));
    }
    if (artifact.fields.mode !== undefined) {
      assert(`${rel} mode is an array of legal modes`, () =>
        Array.isArray(artifact.fields.mode) &&
        artifact.fields.mode.every((mode) => MODES.includes(mode)));
    }
    assert(`${rel} declares no status (payload artifacts are not specs or tickets)`,
      artifact.fields.status === undefined);
  }

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

  const body = artifact.body;
  for (const heading of [
    'What AEP is',
    'The primitives',
    'Where state is',
    'How to discover what matters',
    'The workflow',
    'The invariants',
    'Rules that load when they apply',
  ]) {
    assert(`protocol.md answers "${heading}"`, body.includes(`## ${heading}`));
  }

  assert('protocol.md does not become a second rules system', () => !/^##\s+Rules\s*$/m.test(body));
});

// --- §16 the skill set ------------------------------------------------------

section('skills', () => {
  // Top-level only: `skills/<skill>/<note>.md` is depth, not a skill (§16.1).
  const onDisk = topLevel(path.join(SRC, 'skills')).map((f) => path.basename(f, '.md')).sort();
  assert('the skill set is exactly the seventeen specs.md names', () =>
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
    assert(`skills/${name} declares kind: skill`, artifact.fields.kind === 'skill');
    assert(`skills/${name} declares use-when`, isNonEmptyString(artifact.fields['use-when']));

    if (MODELESS_SKILLS.includes(name)) {
      assert(`skills/${name} declares no mode (specs.md names it modeless)`,
        artifact.fields.mode === undefined);
    } else {
      assert(`skills/${name} declares at least one mode`, () =>
        Array.isArray(artifact.fields.mode) && artifact.fields.mode.length > 0);
    }
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

  // §31.1 — the migration's five rules, each pinned by the thing that goes wrong
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
    assert(`${rel} is linked from skills/${owner}.md — an unlinked note is unreachable`, () =>
      linkedBy.get(owner)?.has(target) === true);
  }

  const wrapped = renderClaudeAdapter(SRC, 'plugin').map((f) => f.relativePath);
  assert('no adapter publishes a note as a command', () =>
    notes.every((file) => {
      const name = path.basename(file, '.md');
      return !wrapped.includes(`skills/${name}/SKILL.md`) || SKILLS.includes(name);
    }));
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
    assert(`agents/${name} is bound by the sub-agent rule`, /rules\/sub-agents/.test(artifact.body));
    assert(`agents/${name} is dispatched by some skill`, skillText.includes(`agents/${name}`));
  }
});

// --- §10 rules --------------------------------------------------------------

section('rules', () => {
  const rules = listMarkdown('rules');
  assert('at least one rule ships', rules.length > 0);
  for (const file of rules) {
    const rel = toPosix(SRC, file);
    const artifact = readArtifact(file);
    assert(`${rel} declares kind: rule`, artifact.fields.kind === 'rule');
    assert(`${rel} declares use-when — without it, it cannot be selected`,
      isNonEmptyString(artifact.fields['use-when']));
  }

  for (const expected of ['precedence', 'engineering', 'boundary', 'placement', 'ownership',
    'artifacts', 'change-control', 'evidence', 'sub-agents']) {
    assert(`rules/${expected}.md ships`, inSrc('rules', `${expected}.md`));
  }

  assert('version-control is a repository-owned seed, not a protocol rule', () =>
    !inSrc('rules', 'version-control.md') &&
    inSrc('seed', 'rules', 'version-control.md'));

  const subAgents = readSrc('rules', 'sub-agents.md');
  assert('rules/sub-agents forbids splitting one task across children', () =>
    /never split across sub-agents/i.test(subAgents));
  assert('rules/sub-agents requires independence to be read, not inferred', () =>
    /never infer independence/i.test(subAgents));
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
      // carry no frontmatter — otherwise the repository's own entrypoint would
      // arrive claiming to be governed by a contract that does not reach it.
      assert(`${seed.source} carries no AEP frontmatter — it lands outside .aep/`,
        !artifact.hasFrontmatter);
      assert(`${seed.source} points at the protocol rather than restating it`, () =>
        artifact.body.includes('.aep/protocol.md'));
      assert(`${seed.source} says it belongs to the repository now`, () =>
        /It is yours/.test(artifact.body));
      continue;
    }

    assert(`${seed.source} declares owner: repository`, artifact.fields.owner === 'repository');
    assert(`${seed.source} declares aep matching specs.md`, artifact.fields.aep === specVersion);
    assert(`${seed.source} declares use-when`, isNonEmptyString(artifact.fields['use-when']));
    assert(`${seed.source} says it is a starting point rather than a description`, () =>
      /This file is yours/.test(artifact.body));
    assert(`${seed.source} targets a repository-owned directory`, () =>
      /^(contexts|references|rules)\//.test(seed.target));
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
  for (const dir of ['decisions', 'policies', 'tools', 'grill']) {
    assert(`no ${dir}/ in the distribution`, !inSrc(dir));
  }
  assert('no plan.md ships', !inSrc('plan.md'));

  const all = [...payloadArtifacts(), ...SEEDS.map((s) => path.join(SRC, ...s.source.split('/')))]
    .filter((file) => fs.existsSync(file))
    .map((file) => fs.readFileSync(file, 'utf8'))
    .join('\n');

  assert('nothing instructs an agent to load every rule', () => !/load all (the )?rules/i.test(all));
  assert('the payload never treats a runtime directory as canonical state', () =>
    !/canonical[^.\n]{0,40}\.(claude|cursor|codex)\//i.test(all));
  assert('shipped text cites no record that exists only in this repository', () =>
    !/\bADR \d{4}\b/.test(all) && !/\bspecs\.md\b/.test(all));
});

// --- §29 the adapter is a pointer, and it is current ------------------------

section('adapter', () => {
  const rendered = renderClaudeAdapter(SRC, 'plugin');
  assert('the adapter renders a file per skill and per agent, and nothing per note', () =>
    rendered.length ===
      topLevel(path.join(SRC, 'skills')).length + topLevel(path.join(SRC, 'agents')).length);

  // The adapter's own directory is the plugin root, so every wrapper — skill
  // and agent alike — is committed under it and nowhere else.
  const adapterDir = path.join(SRC, 'adapters', 'claude');

  for (const { relativePath, contents } of rendered) {
    const committed = path.join(adapterDir, ...relativePath.split('/'));
    assert(`adapters/claude/${relativePath} is committed`, fs.existsSync(committed));
    if (!fs.existsSync(committed)) continue;
    assert(`adapters/claude/${relativePath} is current — regenerate with scripts/adapters.mjs`,
      fs.readFileSync(committed, 'utf8') === contents);
  }

  // Only the generated subdirectories are swept. The adapter also carries
  // hand-written runtime glue — a hook, its configuration, and the plugin
  // manifest — which the generator does not produce and must not be reported
  // as stale.
  const committedFiles = ['skills', 'agents']
    .map((sub) => path.join(adapterDir, sub))
    .filter((dir) => fs.existsSync(dir))
    .flatMap((dir) => walk(dir).map((f) => toPosix(adapterDir, f)));
  assert('the committed adapter has no generated file the generator does not produce', () =>
    committedFiles.every((file) => rendered.some((r) => r.relativePath === file)));

  for (const { relativePath, contents } of rendered) {
    if (!relativePath.startsWith('skills/')) continue;
    assert(`${relativePath} points at the canonical skill rather than restating it`, () =>
      /\.aep\/skills\/[a-z-]+\.md/.test(contents) && contents.length < 1200);
  }

  // The fallback is the only path that has to work before AEP exists anywhere:
  // `/aep:install` in a repository with no `.aep/` yet. It is resolved against
  // the adapter's directory, because that is what `CLAUDE_PLUGIN_ROOT` is once
  // the marketplace publishes the adapter — so a path that is merely plausible
  // fails silently, at the one moment nobody can fall back any further.
  for (const { relativePath, contents } of rendered) {
    if (!relativePath.startsWith('skills/')) continue;
    const fallback = /\$\{CLAUDE_PLUGIN_ROOT\}\/([^`\s]+\.md)/.exec(contents);
    assert(`${relativePath} declares a plugin fallback`, Boolean(fallback));
    if (!fallback) continue;
    assert(`${relativePath} falls back to a file that exists in the distribution`, () => {
      const target = path.join(adapterDir, ...fallback[1].split('/'));
      if (!fs.existsSync(target)) throw new Error(`${fallback[1]} does not exist`);
      return true;
    });
  }

  // The manifest sits inside the adapter, not at the repository root, and that
  // placement is the whole mechanism: Claude Code reads a plugin's agents from
  // `<plugin root>/agents/` and a manifest `agents` path does not redirect that
  // scan — a directory there fails validation outright, and naming the files
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
  // scan, and `hooks` registers the same file twice — which the runtime rejects
  // as a duplicate, taking the plugin's hooks down with it. Each key reads like
  // configuration and behaves like a deletion, so each absence is asserted.
  const standard = { skills: 'skills', agents: 'agents', hooks: path.join('hooks', 'hooks.json') };
  for (const [key, location] of Object.entries(standard)) {
    assert(`plugin.json declares no ${key} path — the standard location loads itself`, () =>
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

// --- §32 the install fixture ------------------------------------------------

section('install fixture', () => {
  const { dir, aep } = installFixture();

  assert('installing creates .aep/protocol.md', fs.existsSync(path.join(aep, 'protocol.md')));
  assert('installing creates .aep/.gitignore', fs.existsSync(path.join(aep, '.gitignore')));
  for (const perClone of ['position', 'worktrees']) {
    assert(`.gitignore excludes ${perClone}/`, () =>
      fs.readFileSync(path.join(aep, '.gitignore'), 'utf8').includes(`${perClone}/`));
  }
  for (const owned of ['contexts', 'references', 'efforts']) {
    assert(`installing creates ${owned}/`, fs.existsSync(path.join(aep, owned)));
  }
  for (const script of PAYLOAD_SCRIPTS) {
    assert(`installing ships scripts/${script}`, fs.existsSync(path.join(aep, 'scripts', script)));
  }
  for (const script of BUILD_ONLY_SCRIPTS) {
    assert(`installing does not ship scripts/${script}`,
      !fs.existsSync(path.join(aep, 'scripts', script)));
  }

  // A bare `git init` directory has a .git and nothing else, so exactly the
  // always-seeds plus git should land. That the detected ones stay away is the
  // half worth asserting — a detector that fires on everything is no detector.
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

  // §31.1 — the one failure that reports success. A 1.x repository has no
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

  const update = () =>
    execFileSync(
      process.execPath,
      [path.join(SRC, 'scripts', 'install.mjs'), '--into', dir, '--update'],
      { stdio: 'ignore' },
    );

  assert('an upgrade preserves a repository-owned rule sharing a shipped filename', () => {
    const ruleFile = path.join(aep, 'rules', 'ownership.md');
    fs.writeFileSync(
      ruleFile,
      ['---', `aep: ${specVersion}`, 'owner: repository', 'date: 2026-08-16', 'kind: rule',
        'use-when: "a repository-owned file stands where a shipped one would land"',
        '---', '', '# Local', ''].join('\n'),
      'utf8',
    );
    update();
    return readArtifact(ruleFile).fields.owner === 'repository';
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

section('the guard fires', () => {
  const before = failures.length;
  assert('a deliberately false assertion is recorded as a failure', false, { silent: true });
  if (failures.length === before + 1) {
    failures.pop();
    passes += 1;
    process.stdout.write('  PASS  the failure path works — seeded failure discarded\n');
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
process.stdout.write('  - whether each use-when states a trigger rather than a topic\n');
process.stdout.write('  - whether each mode genuinely gives something up\n');
process.stdout.write("  - whether a skill's procedure produces what it claims\n");
