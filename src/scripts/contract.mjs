// The AEP artifact contract: the values it allows, how an artifact is parsed,
// and how a tree of them is located and walked. Shared by every AEP script.
//
// A deliberately small YAML subset rather than a dependency: AEP artifacts use
// scalars, inline arrays, and block arrays, and nothing else. A parser that
// accepts more than the contract allows would silently pass frontmatter that
// `[[policies/artifacts]]` forbids, which is the opposite of what these scripts are
// for. Anything outside the subset is reported as a parse error, not guessed at.

import fs from 'node:fs';
import path from 'node:path';

/** Values the `owner` field may take. */
export const OWNERS = ['protocol', 'repository'];

/**
 * Ownership, as a fact about location.
 *
 * A file under `policies/` is AEP's law and a file under `rules/` is the
 * repository's, and the same holds for every other row: an upgrade replaces what
 * the protocol ships and preserves everything else. Stating it once, here and in
 * the bootstrap, is what lets sixty-nine artifacts stop declaring it.
 *
 * The two root files are named because no directory rule reaches them:
 * `protocol.md` is the protocol's, and `index.md` is derived and regenerated in
 * place.
 */
export const PROTOCOL_DIRS = ['policies', 'modes', 'skills', 'agents', 'templates', 'scripts'];
export const REPOSITORY_DIRS = ['rules', 'contexts', 'references', 'efforts'];
export const PROTOCOL_ROOT_FILES = ['protocol.md'];
export const REPOSITORY_ROOT_FILES = ['index.md'];

// generated:protocol-files. Run `node src/scripts/manifest.mjs`
export const PROTOCOL_FILES = [
  '.gitignore',
  'agents/implementer.md',
  'agents/researcher.md',
  'agents/reviewer-correctness.md',
  'agents/reviewer-standards.md',
  'modes/implement.md',
  'modes/plan.md',
  'modes/prototype.md',
  'modes/refine.md',
  'modes/research.md',
  'modes/review.md',
  'modes/specify.md',
  'modes/test.md',
  'policies/artifacts.md',
  'policies/authority.md',
  'policies/engineering.md',
  'policies/execution.md',
  'policies/reporting.md',
  'protocol.md',
  'scripts/contract.mjs',
  'scripts/index.mjs',
  'scripts/position.mjs',
  'scripts/validate.mjs',
  'skills/commit.md',
  'skills/commit/conflicts.md',
  'skills/domain.md',
  'skills/handoff.md',
  'skills/help.md',
  'skills/implement.md',
  'skills/implement/diagnosing.md',
  'skills/implement/dispatch.md',
  'skills/install.md',
  'skills/plan.md',
  'skills/plan/depth.md',
  'skills/plan/design-it-twice.md',
  'skills/prose.md',
  'skills/prototype.md',
  'skills/prototype/logic.md',
  'skills/prototype/ui.md',
  'skills/prune.md',
  'skills/refine.md',
  'skills/research.md',
  'skills/review.md',
  'skills/review/smells.md',
  'skills/specify.md',
  'skills/specify/out-of-scope.md',
  'skills/survey.md',
  'skills/survey/report.md',
  'skills/tasks.md',
  'skills/tasks/labels.md',
  'skills/tdd.md',
  'skills/tdd/mocking.md',
  'skills/tdd/tests.md',
  'skills/update.md',
  'skills/update/migration.md',
  'templates/agent.template.md',
  'templates/agents.template.md',
  'templates/context.template.md',
  'templates/mode.template.md',
  'templates/protocol.template.md',
  'templates/prototype.template.md',
  'templates/reference.template.md',
  'templates/research.template.md',
  'templates/rule.template.md',
  'templates/skill.template.md',
  'templates/spec.template.md',
  'templates/ticket.template.md',
];
// end generated:protocol-files

/**
 * True when a path under `.aep/` is one the protocol ships.
 *
 * The exact list rather than the directory, because the directory answers *this
 * is a protocol area* and this answers *this is the protocol's file*. An
 * installer needs the second before it overwrites anything, and a validator
 * needs the difference between them to name a stray.
 */
export function isProtocolPath(relative) {
  return PROTOCOL_FILES.includes(relative);
}

/** The top-level directory of a path under `.aep/`, or null for a root file. */
export function topDirOf(relative) {
  const parts = relative.split('/');
  return parts.length > 1 ? parts[0] : null;
}

/** Values the `kind` field may take. */
export const KINDS = [
  'agent',
  'context',
  'spec',
  'prototype',
  'research',
  'reference',
  'policy',
  'rule',
  'skill',
  'ticket',
  'protocol',
  'mode',
];

/** The eight canonical modes. `mode:` is an array drawn from these. */
export const MODES = [
  'specify',
  'plan',
  'refine',
  'implement',
  'research',
  'prototype',
  'review',
  'test',
];

/**
 * Values the `report` field may take, the form a skill's turn report is in.
 *
 * Declared per skill, once, when the skill is authored: `full` where it writes
 * to the repository, dispatches, or decides on the human's behalf. Never
 * selected during a run, so the human knows the shape before the run starts.
 */
export const REPORT_FORMS = ['full', 'short'];

/** Legal `status` values, by what declares them. */
export const SPEC_STATUSES = ['draft', 'accepted', 'implemented'];
export const TICKET_STATUSES = ['open', 'resolved', 'obsolete'];

/** Directories that must never exist under `.aep/`. */
export const FORBIDDEN_DIRS = ['decisions', 'tools', 'grill'];

/** The eighteen conforming skills. */
export const SKILLS = [
  'specify',
  'refine',
  'plan',
  'tasks',
  'implement',
  'review',
  'commit',
  'research',
  'prototype',
  'survey',
  'install',
  'update',
  'prune',
  'handoff',
  'help',
  'tdd',
  'domain',
  'prose',
];

/** The two skills that enter no mode and therefore declare none (specs.md §16). */
export const MODELESS_SKILLS = ['help', 'handoff'];

/** Files whose `kind` requires a `use-when`, by the directory they live in. */
export const USE_WHEN_REQUIRED_DIRS = ['policies', 'rules', 'references', 'contexts'];

const FRONTMATTER = /^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/;

/**
 * Strips one layer of YAML quoting from a scalar.
 * Unquoted values are returned trimmed, which is what every AEP scalar wants.
 */
function unquote(raw) {
  const value = raw.trim();
  if (value.length >= 2) {
    const first = value[0];
    const last = value[value.length - 1];
    if ((first === '"' && last === '"') || (first === "'" && last === "'")) {
      return value.slice(1, -1);
    }
  }
  return value;
}

/** Splits an inline `[a, b, c]` array, tolerating an empty one. */
function parseInlineArray(raw) {
  const inner = raw.slice(1, -1).trim();
  if (inner === '') return [];
  return inner.split(',').map(unquote);
}

/**
 * Parses a frontmatter block into a plain object.
 *
 * Returns `{ fields, errors }` rather than throwing: a malformed artifact is a
 * finding to report alongside the others, not a reason to abandon the sweep.
 */
export function parseFrontmatterBlock(block) {
  const fields = Object.create(null);
  const errors = [];
  const lines = block.split(/\r?\n/);

  let pendingKey = null;
  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];
    if (line.trim() === '' || line.trimStart().startsWith('#')) continue;

    const item = /^\s+-\s+(.*)$/.exec(line);
    if (item) {
      if (!pendingKey) {
        errors.push(`line ${i + 1}: list item with no key above it`);
        continue;
      }
      fields[pendingKey].push(unquote(item[1]));
      continue;
    }

    const pair = /^([A-Za-z][A-Za-z0-9_-]*):(.*)$/.exec(line);
    if (!pair) {
      errors.push(`line ${i + 1}: not a "key: value" pair, ${JSON.stringify(line)}`);
      continue;
    }

    const key = pair[1];
    const rest = pair[2].trim();
    if (rest === '') {
      // A key with nothing after it opens a block array. If no items follow it
      // stays an empty array, which the contract checks reject where the field
      // is required to have content.
      pendingKey = key;
      fields[key] = [];
      continue;
    }

    pendingKey = null;
    fields[key] = rest.startsWith('[') && rest.endsWith(']')
      ? parseInlineArray(rest)
      : unquote(rest);
  }

  return { fields, errors };
}

/**
 * Reads a Markdown file and returns `{ fields, errors, body, hasFrontmatter }`.
 * A file with no leading `---` block is reported rather than treated as empty,
 * because under `.aep/` the absence is itself a contract violation.
 */
export function readArtifact(file) {
  let text;
  try {
    text = fs.readFileSync(file, 'utf8');
  } catch (error) {
    return { fields: {}, errors: [`unreadable: ${error.message}`], body: '', hasFrontmatter: false };
  }

  const match = FRONTMATTER.exec(text);
  if (!match) {
    return { fields: {}, errors: [], body: text, hasFrontmatter: false };
  }

  const { fields, errors } = parseFrontmatterBlock(match[1]);
  return { fields, errors, body: text.slice(match[0].length), hasFrontmatter: true };
}

/**
 * Every `[[wiki-link]]` target in a body, in order of appearance.
 *
 * Only fenced blocks are stripped. A link inside a fence is the syntax being
 * *shown*, in a template or in an example, rather than a reference to a file
 * that must exist.
 *
 * Inline code spans are deliberately NOT stripped, even though they also hold
 * examples occasionally. The convention throughout the payload is to wrap real
 * links in backticks so they render as monospace, so stripping inline code
 * silently excused almost every link in the corpus from being checked, a
 * checker that passes by not looking. Generic placeholders are written without
 * bracket syntax instead, which costs a word and keeps the check honest.
 */
export function wikiLinks(body) {
  const prose = body.replace(/^```[\s\S]*?^```/gm, '');
  const links = [];
  const pattern = /\[\[([^\]|#]+?)(?:#[^\]|]*)?(?:\|[^\]]*)?\]\]/g;
  let match;
  while ((match = pattern.exec(prose)) !== null) {
    links.push(match[1].trim());
  }
  return links;
}

/** Recursively lists files under `dir`, as absolute paths, sorted. */
export function walk(dir, { skip = [] } = {}) {
  const found = [];
  const visit = (current) => {
    let entries;
    try {
      entries = fs.readdirSync(current, { withFileTypes: true });
    } catch {
      return;
    }
    for (const entry of entries.sort((a, b) => (a.name < b.name ? -1 : 1))) {
      if (skip.includes(entry.name)) continue;
      const full = path.join(current, entry.name);
      if (entry.isDirectory()) visit(full);
      else if (entry.isFile()) found.push(full);
    }
  };
  visit(dir);
  return found;
}

/**
 * The `.md` files directly inside `dir`, sorted, as absolute paths.
 *
 * `skills/` is the reason this exists: a skill is a top-level file, and
 * `skills/<skill>/<note>.md` is depth reached from it. Every caller that means
 * "the skills" rather than "every file under skills/" uses this, so a note can
 * never be counted as, listed as, or wrapped as a skill.
 */
export function topLevel(dir) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return [];
  }
  return entries
    .filter((entry) => entry.isFile() && entry.name.endsWith('.md'))
    .map((entry) => path.join(dir, entry.name))
    .sort();
}

/** A repo-relative path with forward slashes, so output is identical on every platform. */
export function toPosix(root, file) {
  return path.relative(root, file).split(path.sep).join('/');
}

/** True when `value` is a non-empty string. */
export function isNonEmptyString(value) {
  return typeof value === 'string' && value.trim() !== '';
}

/** True when `value` is `YYYY-MM-DD`, and a real calendar date. */
export function isIsoDate(value) {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const [year, month, day] = value.split('-').map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));
  return (
    date.getUTCFullYear() === year &&
    date.getUTCMonth() === month - 1 &&
    date.getUTCDate() === day
  );
}

/**
 * Locates the `.aep/` directory these scripts should act on.
 *
 * Resolution order, so the same script works from both places it legitimately
 * runs: an explicit argument; the installed position, where the script itself
 * sits at `.aep/scripts/`; then `<cwd>/.aep`. Returns null when there is none,
 * which callers report rather than treating as an empty tree, since "no AEP
 * here" and "AEP here with nothing in it" are different answers.
 */
export function resolveAepRoot(explicit, scriptUrl) {
  const candidates = [];
  if (explicit) candidates.push(path.resolve(explicit));
  if (scriptUrl) {
    const scriptDir = path.dirname(new URL(scriptUrl).pathname.replace(/^\/([A-Za-z]:)/, '$1'));
    if (path.basename(scriptDir) === 'scripts') candidates.push(path.dirname(scriptDir));
  }
  candidates.push(path.join(process.cwd(), '.aep'));

  for (const candidate of candidates) {
    if (fs.existsSync(path.join(candidate, 'protocol.md'))) return candidate;
  }
  return null;
}
