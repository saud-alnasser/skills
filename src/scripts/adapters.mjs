// Generates runtime adapters from the canonical payload.
//
// An adapter is a pointer, never a copy. The whole risk an adapter introduces is
// a second copy of a skill that drifts from the canonical one, so nothing here
// writes skill content: a wrapper carries the runtime's own frontmatter and a
// line telling the agent which canonical file to read.
//
// Descriptions are derived from the canonical artifact — its heading and its
// `use-when` — so the text a runtime matches on cannot disagree with the text
// the protocol declares. Hand-written wrapper descriptions were the obvious
// alternative and would have been exactly that second home.
//
// Two shapes, because the fallback differs:
//
//   plugin      distributed with the protocol; falls back to the plugin's own
//               copy, so /install works in a repository that has no .aep/ yet
//   repository  written into a repository by /install; no fallback, because a
//               missing .aep/skills file there means AEP was removed

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { readArtifact, topLevel, walk } from './contract.mjs';

/**
 * From the plugin's root back to the payload it wraps.
 *
 * The plugin root is this adapter's own directory — `<distribution>/adapters/
 * claude` — because that is what the marketplace entry publishes, and it has to
 * be: Claude Code scans `<plugin root>/agents/` for a plugin's agents and a
 * manifest `agents` path does not redirect that scan. Naming a directory there
 * fails manifest validation outright, and naming the files loads none of them.
 * Publishing the adapter itself is what puts every wrapper — skills and agents
 * alike — where the runtime already looks, with no manifest paths at all.
 *
 * The payload is two levels up from there, which is what this prefix spells.
 */
const PAYLOAD_FROM_PLUGIN_ROOT = '../..';

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
    // `# /specify — define WHAT is changing and WHY` → the half after the dash.
    if (heading) {
      const parts = heading[1].split(/\s+—\s+/);
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

function skillWrapper(name, description, shape) {
  const canonical = `.aep/skills/${name}.md`;
  const lines = [
    '---',
    `name: ${name}`,
    `description: ${description}`,
    'metadata:',
    '  aep: adapter',
    `  canonical: ${canonical}`,
    '---',
    '',
    `Read \`${canonical}\` and follow it exactly. That file is the skill; this one only routes to it.`,
    '',
  ];

  if (shape === 'plugin') {
    // `CLAUDE_PLUGIN_ROOT` is the adapter's own directory, so the payload is
    // reached by climbing out of it — see `PAYLOAD_FROM_PLUGIN_ROOT`. A wrong
    // fallback here breaks the single path that has to work before AEP exists
    // anywhere: `/aep:install` in a repository that has no `.aep/` yet.
    lines.push(
      `If \`${canonical}\` does not exist, this repository has not installed AEP.`,
      'For `/aep:install` and `/aep:help`, fall back to',
      '`${CLAUDE_PLUGIN_ROOT}/' + PAYLOAD_FROM_PLUGIN_ROOT + '/skills/' + name + '.md` and continue.',
      'For anything else, say AEP is not installed here and offer `/aep:install` —',
      'do not improvise the skill.',
      '',
    );
  } else {
    lines.push(
      `If \`${canonical}\` does not exist, AEP is not installed in this repository.`,
      'Say so and stop; do not improvise the skill.',
      '',
    );
  }

  return lines.join('\n');
}

function agentWrapper(name, description) {
  const canonical = `.aep/agents/${name}.md`;
  return [
    '---',
    `name: ${name}`,
    `description: ${description}`,
    '---',
    '',
    `Read \`${canonical}\` and adopt it as your role definition. It states your`,
    'purpose, responsibilities, constraints, and the shape of what you return.',
    '',
    'Then read `.aep/rules/sub-agents.md`, which binds you, and the mode named in',
    'your role definition.',
    '',
    'If those files do not exist, AEP is not installed here — report that and stop.',
    '',
  ].join('\n');
}

/**
 * Renders every adapter file as `{ relativePath, contents }`.
 * Pure: callers decide whether to write or compare, which is what lets the
 * verification suite assert the committed adapter is current.
 */
export function renderClaudeAdapter(distributionRoot, shape) {
  const files = [];

  // Top-level files only. `skills/<skill>/<note>.md` is depth reached by link
  // from its own skill, not an entry point — wrapping one would publish a
  // command the protocol does not have, under a name (`ui`, `tests`) that reads
  // like a skill in a runtime's listing.
  const skillsDir = path.join(distributionRoot, 'skills');
  for (const file of topLevel(skillsDir)) {
    const name = path.basename(file, '.md');
    const artifact = readArtifact(file);
    files.push({
      relativePath: `skills/${name}/SKILL.md`,
      contents: skillWrapper(name, describe(artifact, { isAgent: false }), shape),
    });
  }

  const agentsDir = path.join(distributionRoot, 'agents');
  for (const file of walk(agentsDir).filter((f) => f.endsWith('.md'))) {
    const name = path.basename(file, '.md');
    const artifact = readArtifact(file);
    files.push({
      relativePath: `agents/${name}.md`,
      contents: agentWrapper(name, describe(artifact, { isAgent: true })),
    });
  }

  return files.sort((a, b) => (a.relativePath < b.relativePath ? -1 : 1));
}

/** Writes the adapter under `targetDir`, returning the paths written. */
export function writeClaudeAdapter(distributionRoot, targetDir, shape) {
  const written = [];
  for (const { relativePath, contents } of renderClaudeAdapter(distributionRoot, shape)) {
    const target = path.join(targetDir, ...relativePath.split('/'));
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.writeFileSync(target, contents, 'utf8');
    written.push(relativePath);
  }
  return written;
}

/** The distribution root — `src/`, since this script lives in `src/scripts/`. */
export function distributionRoot() {
  return path.dirname(path.dirname(fileURLToPath(import.meta.url)));
}

// Regenerating the distribution's own committed adapter.
//   node src/scripts/adapters.mjs [--to <dir>] [--shape plugin|repository]
if (process.argv[1] && path.basename(process.argv[1]) === 'adapters.mjs') {
  const args = process.argv.slice(2);
  const value = (flag, fallback) =>
    args.includes(flag) ? args[args.indexOf(flag) + 1] : fallback;
  const root = distributionRoot();
  const to = path.resolve(value('--to', path.join(root, 'adapters', 'claude')));
  const written = writeClaudeAdapter(root, to, value('--shape', 'plugin'));
  process.stdout.write(`wrote ${written.length} adapter files to ${to}\n`);
}
