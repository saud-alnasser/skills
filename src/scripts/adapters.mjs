// Generates runtime adapters from the canonical payload.
//
// An adapter is a pointer, never a copy. The whole risk an adapter introduces is
// a second copy of a skill that drifts from the canonical one, so nothing here
// writes skill content: a wrapper carries the runtime's own frontmatter and a
// line telling the agent which canonical file to read.
//
// Descriptions are derived from the canonical artifact, its heading and its
// `use-when`, so the text a runtime matches on cannot disagree with the text
// the protocol declares. Hand-written wrapper descriptions were the obvious
// alternative and would have been exactly that second home.
//
// A runtime is a row in `TARGETS`, never a function of its own. One renderer
// walks the payload and asks the target where each wrapper lands, what
// frontmatter that runtime's schema admits, and how absence is handled. The
// alternative, a render function per runtime, reads better per runtime and
// loses on the thing that matters: the pointer contract would be stated three
// times, and a stale adapter is caught by the suite while three wordings of one
// rule drifting apart is not.
//
// Shapes exist because the fallback differs:
//
//   plugin        distributed with the protocol; falls back to the plugin's own
//                 copy, so /install works in a repository that has no .aep/ yet
//   distribution  registered from a clone of the distribution; falls back by a
//                 path relative to the wrapper itself, for the same reason
//   repository    written into a repository by /install; no fallback, because a
//                 missing .aep/skills file there means AEP was removed

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { readArtifact, topLevel, walk } from './contract.mjs';

/**
 * From an adapter's own root back to the payload it wraps.
 *
 * For Claude that root is the plugin root, `<distribution>/adapters/claude`,
 * because that is what the marketplace entry publishes, and it has to be: Claude
 * Code scans `<plugin root>/agents/` for a plugin's agents and a manifest
 * `agents` path does not redirect that scan. Naming a directory there fails
 * manifest validation outright, and naming the files loads none of them.
 * Publishing the adapter itself is what puts every wrapper, skills and agents
 * alike, where the runtime already looks, with no manifest paths at all.
 *
 * The payload is two levels up from any adapter root, which is what this prefix
 * spells. Every relative fallback is derived from it rather than written out, so
 * moving a wrapper moves its fallback with it.
 */
const PAYLOAD_FROM_ADAPTER_ROOT = '../..';

/**
 * What a wrapper says when the canonical file is not there.
 *
 * Identical for every runtime, because the situation is: AEP was installed and
 * then removed. Only the shapes that ship *outside* a repository have anywhere
 * further to fall back to, and each of those spells its own reach.
 */
function absent(canonical) {
  return [
    `If \`${canonical}\` does not exist, AEP is not installed in this repository.`,
    'Say so and stop; do not improvise the skill.',
  ];
}

/**
 * A skill wrapper's frontmatter, which no runtime so far spells differently.
 *
 * Every reader takes the same three: a `name` that has to equal the directory,
 * the `description` it matches on, and a free-form `metadata` map, the only
 * place AEP's own fields may ride without colliding with a runtime's schema.
 */
function skillFrontmatter(wrapped, description, canonical) {
  return [
    `name: ${wrapped}`,
    `description: ${description}`,
    'metadata:',
    '  aep: adapter',
    `  canonical: ${canonical}`,
  ];
}

/** How many directories a wrapper sits below its adapter's root. */
function depth(relativePath) {
  return relativePath.split('/').length - 1;
}

/** The sentence a runtime matches on, derived from the canonical artifact. */
function describe(artifact, { isAgent }) {
  const useWhen = typeof artifact.fields['use-when'] === 'string'
    ? artifact.fields['use-when'].trim().replace(/^"|"$/g, '')
    : '';

  let what = '';
  if (isAgent) {
    // The purpose is a paragraph, not a line. Capturing only the first line
    // truncated it mid-sentence, which is invisible in the source and obvious
    // in the runtime's skill listing.
    const purpose = /\*\*Purpose\.\*\*\s*([\s\S]*?)(?:\r?\n\r?\n|$)/.exec(artifact.body);
    if (purpose) what = purpose[1].trim();
  } else {
    const heading = /^#\s+(.+)$/m.exec(artifact.body);
    // A skill heading is `# /<name>`, an em dash, then what the skill does, and
    // the half after the dash is what a runtime matches on. The dash is written
    // as an escape because the shipped scripts are scanned for the character;
    // the headings themselves keep it.
    if (heading) {
      const parts = heading[1].split(/\s+\u2014\s+/);
      what = (parts[1] ?? parts[0]).trim();
    }
  }

  // Markdown emphasis is meaningless in a runtime's description field and reads
  // as stray punctuation in a skill listing, so it is stripped rather than
  // carried through.
  what = what.replace(/\*\*?/g, '').replace(/`/g, '').replace(/\s+/g, ' ').trim();
  if (what && !/[.!?]$/.test(what)) what += '.';
  if (what) what = what.charAt(0).toUpperCase() + what.slice(1);

  const when = useWhen ? `${isAgent ? 'Dispatch' : 'Use'} when ${useWhen.replace(/\.$/, '')}.` : '';
  return [what, when].filter(Boolean).join(' ');
}

/**
 * The runtimes AEP renders for.
 *
 * Each row answers only what differs. `path` returning `null` is how a target
 * declines a kind. It is the single place the skills-only rules live, for the
 * distribution shape and for the neutral location alike.
 *
 * `committed` names the shape kept under `src/adapters/<name>/`, or `null` where
 * nothing is committed: a tree is committed exactly when that directory is
 * itself what a user registers. Claude's is the published plugin. Anything that
 * only ever renders into a repository at install time has no such consumer, and
 * committing it would add wrappers with no reader that churn on every
 * `use-when` edit.
 *
 * `name` is the canonical artifact's name; `wrapped` is what the runtime knows
 * it by. They differ wherever a target prefixes, and the pointer always names
 * the canonical one.
 */
export const TARGETS = {
  claude: {
    dir: '.claude',
    prefix: '',
    committed: 'plugin',
    shapes: ['plugin', 'repository'],
    path: (kind, wrapped) =>
      (kind === 'skill' ? `skills/${wrapped}/SKILL.md` : `agents/${wrapped}.md`),
    frontmatter: (kind, wrapped, description, canonical) => (kind === 'skill'
      ? skillFrontmatter(wrapped, description, canonical)
      : [
        `name: ${wrapped}`,
        `description: ${description}`,
      ]),
    fallback: (kind, name, shape, canonical) => {
      if (kind !== 'skill') return null;
      if (shape !== 'plugin') return absent(canonical);
      // `CLAUDE_PLUGIN_ROOT` is the adapter's own directory, so the payload is
      // reached by climbing out of it. A wrong fallback here breaks the single
      // path that has to work before AEP exists anywhere: `/aep:install` in a
      // repository that has no `.aep/` yet.
      return [
        `If \`${canonical}\` does not exist, this repository has not installed AEP.`,
        'For `/aep:install` and `/aep:help`, fall back to',
        '`${CLAUDE_PLUGIN_ROOT}/' + PAYLOAD_FROM_ADAPTER_ROOT + '/skills/' + name + '.md` and continue.',
        'For anything else, say AEP is not installed here and offer `/aep:install`.',
        'Do not improvise the skill.',
      ];
    },
  },

  // OpenCode reads skills from `.opencode/skill(s)/` and agents from
  // `.opencode/agent(s)/`, and nothing else reaches its agents at all. The
  // `.claude` compatibility that finds a Claude adapter's skills covers skills
  // only. Both spellings load; the plural is what OpenCode's own repository and
  // its documentation use.
  //
  // Names are prefixed because OpenCode registers `init` and `review` as
  // built-in commands before skills, and a skill whose name is already taken
  // never becomes a command. Unprefixed, `/review` would silently not be AEP's.
  opencode: {
    dir: '.opencode',
    prefix: 'aep-',
    committed: 'distribution',
    shapes: ['distribution', 'repository'],
    // The distribution shape is what a user points `skills.paths` at, and
    // OpenCode reads those where they sit rather than copying them. An agent
    // cannot be reached that way, since agents load from a config directory only,
    // and a wrapper copied there is a generated file going stale in a home
    // directory no suite can see. So agents ship in the repository shape alone.
    path: (kind, wrapped, shape) => {
      if (kind === 'skill') return `skills/${wrapped}/SKILL.md`;
      return shape === 'repository' ? `agents/${wrapped}.md` : null;
    },
    // An unknown key in an agent's frontmatter is not rejected: OpenCode routes
    // it silently into that agent's options. So an agent wrapper carries the two
    // keys the schema names and nothing else, and AEP's own fields ride in
    // `metadata`, which exists on a skill and has no counterpart on an agent.
    frontmatter: (kind, wrapped, description, canonical) => (kind === 'skill'
      ? skillFrontmatter(wrapped, description, canonical)
      : [
        `description: ${description}`,
        'mode: subagent',
      ]),
    fallback: (kind, name, shape, canonical, relativePath) => {
      if (kind !== 'skill') return null;
      if (shape !== 'distribution') return absent(canonical);
      // Derived rather than written out, so moving a wrapper moves its reach
      // with it. OpenCode announces the skill's own directory to the agent as
      // the base for relative paths, which is what makes this resolvable at all.
      const reach = `${'../'.repeat(depth(relativePath))}${PAYLOAD_FROM_ADAPTER_ROOT}`;
      return [
        `If \`${canonical}\` does not exist, this repository has not installed AEP.`,
        'For `/aep-install` and `/aep-help`, fall back to',
        `\`${reach}/skills/${name}.md\`, resolved from this skill's own directory,`,
        'and continue.',
        'For anything else, say AEP is not installed here and offer `/aep-install`.',
        'Do not improvise the skill.',
      ];
    },
  },

  // `.agents/skills/` is the one location read by more than one runtime:
  // OpenCode scans it, and T3 Code's picker scans it for whichever provider it
  // is driving. It carries skills because that is all anything reads it for.
  //
  // Nothing commits it. A wrapper here is only ever written into a repository by
  // an install, so a checked-in copy would have no reader, and no fallback is
  // expressible either, because nothing that reads this location takes a
  // configured path, so a wrapper can only arrive by being copied and a copy
  // severs any reach relative to itself.
  agents: {
    dir: '.agents',
    prefix: 'aep-',
    committed: null,
    shapes: ['repository'],
    path: (kind, wrapped) => (kind === 'skill' ? `skills/${wrapped}/SKILL.md` : null),
    // Gated on the kind even though `path` already declines an agent: a hook
    // that ignores its discriminant would emit skill frontmatter for an agent
    // the day this row grows an agent path, and that is a silent wrong file
    // rather than a loud one.
    frontmatter: (kind, wrapped, description, canonical) =>
      (kind === 'skill' ? skillFrontmatter(wrapped, description, canonical) : null),
    fallback: (kind, name, shape, canonical) => (kind === 'skill' ? absent(canonical) : null),
  },
};

/** The body every skill wrapper shares: the pointer, and nothing of the skill. */
function pointer(canonical) {
  return `Read \`${canonical}\` and follow it exactly. That file is the skill; this one only routes to it.`;
}

function skillWrapper(target, { name, wrapped, description, shape, relativePath }) {
  const canonical = `.aep/skills/${name}.md`;
  const lines = [
    '---',
    ...target.frontmatter('skill', wrapped, description, canonical),
    '---',
    '',
    pointer(canonical),
    '',
  ];

  const fallback = target.fallback('skill', name, shape, canonical, relativePath);
  if (fallback) lines.push(...fallback, '');

  return lines.join('\n');
}

/**
 * An agent wrapper names the role definition and nothing else.
 *
 * It used to name the artifact that binds a sub-agent as well. That artifact
 * moved when governance split, and the wrappers went on pointing at a file the
 * distribution no longer ships, and every dispatched agent was sent to read
 * nothing. A role definition already states what binds it, so naming that here
 * was a second home for the answer, and the copy is the one that went stale.
 */
function agentWrapper(target, { name, wrapped, description, shape }) {
  const canonical = `.aep/agents/${name}.md`;
  const lines = [
    '---',
    ...target.frontmatter('agent', wrapped, description, canonical),
    '---',
    '',
    `Read \`${canonical}\` and adopt it as your role definition. It states your`,
    'purpose, responsibilities, constraints, the governance that binds you, and',
    'the shape of what you return.',
    '',
    'If that file does not exist, AEP is not installed here. Report that and stop.',
    '',
  ];

  const fallback = target.fallback('agent', name, shape, canonical);
  if (fallback) lines.push(...fallback, '');

  return lines.join('\n');
}

/**
 * Renders every adapter file as `{ relativePath, contents }`.
 * Pure: callers decide whether to write or compare, which is what lets the
 * verification suite assert the committed adapter is current.
 */
export function renderAdapter(distributionRoot, target, shape) {
  const files = [];

  const wrap = (kind, sources) => {
    const isAgent = kind === 'agent';
    for (const file of sources) {
      const name = path.basename(file, '.md');
      const wrapped = `${target.prefix}${name}`;
      const relativePath = target.path(kind, wrapped, shape);
      if (!relativePath) continue;
      const description = describe(readArtifact(file), { isAgent });
      const contents = (isAgent ? agentWrapper : skillWrapper)(
        target, { name, wrapped, description, shape, relativePath },
      );
      // `kind` and `name` ride along so a caller can judge the render without
      // inferring either from the path. The suite has to count skills against
      // agents, and a path is the one thing a target is free to change.
      files.push({ kind, name, wrapped, relativePath, contents });
    }
  };

  // Top-level files only. `skills/<skill>/<note>.md` is depth reached by link
  // from its own skill, not an entry point. Wrapping one would publish a
  // command the protocol does not have, under a name (`ui`, `tests`) that reads
  // like a skill in a runtime's listing.
  wrap('skill', topLevel(path.join(distributionRoot, 'skills')));
  wrap('agent', walk(path.join(distributionRoot, 'agents')).filter((f) => f.endsWith('.md')));

  return files.sort((a, b) => (a.relativePath < b.relativePath ? -1 : 1));
}

/** Writes the adapter under `targetDir`, returning the paths written. */
export function writeAdapter(distributionRoot, target, targetDir, shape) {
  const written = [];
  for (const { relativePath, contents } of renderAdapter(distributionRoot, target, shape)) {
    const file = path.join(targetDir, ...relativePath.split('/'));
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, contents, 'utf8');
    written.push(relativePath);
  }
  return written;
}

/** The distribution root, `src/`, since this script lives in `src/scripts/`. */
export function distributionRoot() {
  return path.dirname(path.dirname(fileURLToPath(import.meta.url)));
}

// Regenerating the distribution's own committed adapters.
//   node src/scripts/adapters.mjs [--target <name>] [--shape <shape>] [--to <dir>]
if (process.argv[1] && path.basename(process.argv[1]) === 'adapters.mjs') {
  const args = process.argv.slice(2);
  const value = (flag, fallback) =>
    args.includes(flag) ? args[args.indexOf(flag) + 1] : fallback;
  const root = distributionRoot();

  const only = value('--target', null);
  if (only && !(only in TARGETS)) {
    process.stderr.write(`unknown runtime: ${only}. Known: ${Object.keys(TARGETS).join(', ')}\n`);
    process.exit(2);
  }

  const names = only ? [only] : Object.keys(TARGETS).filter((name) => TARGETS[name].committed);
  for (const name of names) {
    const target = TARGETS[name];
    const shape = value('--shape', target.committed ?? target.shapes[0]);
    const to = path.resolve(value('--to', path.join(root, 'adapters', name)));
    const written = writeAdapter(root, target, to, shape);
    process.stdout.write(`wrote ${written.length} ${name} adapter files to ${to}\n`);
  }
}
