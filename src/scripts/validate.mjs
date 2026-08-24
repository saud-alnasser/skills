// Validates a `.aep/` tree against the artifact contract.
//
// Everything checked here is mechanically checkable by construction; the one
// thing that is not, whether a `use-when` states a trigger rather than a topic,
// is called out in the summary rather than silently passed, because a check
// that cannot fire reads exactly like a check that passed.
//
//   node validate.mjs [--root <path-to-.aep>] [--quiet]

import fs from 'node:fs';
import path from 'node:path';
import {
  PROTOCOL_DIRS,
  FORBIDDEN_DIRS,
  SPEC_STATUSES,
  TICKET_STATUSES,
  USE_WHEN_REQUIRED_DIRS,
  isNonEmptyString,
  readArtifact,
  resolveAepRoot,
  toPosix,
  walk,
  wikiLinks,
  isProtocolPath,
  RETIRED_FIELDS,
  useWhenProblems,
} from './contract.mjs';

const PROTOCOL_BUDGET_BYTES = 8192;

const failures = [];
const skippedEfforts = [];
let checked = 0;

function fail(where, message) {
  failures.push(`${where}: ${message}`);
}

/** Resolves a `[[link]]` against the tree: a `.md` file, or a directory. */
function linkResolves(root, target) {
  const base = path.join(root, ...target.split('/'));
  return fs.existsSync(`${base}.md`) || fs.statSync(base, { throwIfNoEntry: false })?.isDirectory();
}

function checkArtifact(root, file) {
  const rel = toPosix(root, file);
  const segments = rel.split('/');
  const topDir = segments.length > 1 ? segments[0] : '';
  const artifact = readArtifact(file);
  checked += 1;

  // Ownership is a fact about location, so a protocol directory holds exactly
  // what the protocol ships. A file here the manifest does not name is either
  // something a release retired and nobody pruned, or something the repository
  // wrote where it may not, and both are defects that hide until an upgrade
  // walks past them.
  //
  // This is what the `owner:` field used to say per artifact. It says it once,
  // for every directory, and it catches the case the field never could: a file
  // that simply omits the declaration.
  if (PROTOCOL_DIRS.includes(topDir) && !isProtocolPath(rel)) {
    fail(rel, `${topDir}/ holds only what the protocol ships, and this release ships ` +
      'no such file. Repository-owned governance belongs under rules/, orientation ' +
      'under contexts/, and tool operation under references/');
  }

  if (!artifact.hasFrontmatter) {
    fail(rel, 'no frontmatter. Every Markdown artifact under .aep/ declares at least a use-when');
    return;
  }
  for (const error of artifact.errors) fail(rel, `frontmatter ${error}`);

  const { fields } = artifact;

  // The retired fields. Ownership is a fact about location, the release is named
  // once in the bootstrap, and the rest were read by nothing.
  //
  // Rejected on a path the protocol ships, and tolerated everywhere else. A
  // repository's own rules and contexts were written under the old contract and
  // an upgrade never edits them, so failing them would fail a tree for carrying
  // exactly what AEP handed it and then refused to touch.
  const retired = RETIRED_FIELDS.filter((field) => fields[field] !== undefined);
  if (retired.length > 0 && isProtocolPath(rel)) {
    fail(rel, `carries retired frontmatter: ${retired.join(', ')}. ` +
      'Ownership is decided by location, the release is named once in protocol.md, ' +
      'and the rest are read by nothing');
  }

  // Situational fields, when present.
  if (fields.paths !== undefined && !Array.isArray(fields.paths)) {
    fail(rel, 'paths must be a YAML array');
  }

  // A context sits at `contexts/<area>.md` or `contexts/<project>/<area>.md`,
  // where the project directory exists so that two projects of a monorepo can
  // both call an area `auth`. One level, because a monorepo of monorepos is a
  // shape AEP declines to model.
  //
  // Contexts alone: `rules/` and `references/` are repository-wide, so neither
  // has a namespace two projects can collide in. A limit keyed by directory
  // would advertise a nesting nothing wants.
  if (topDir === 'contexts' && segments.length > 3) {
    fail(rel, 'a context sits at contexts/<area>.md or contexts/<project>/<area>.md, ' +
      'one project directory deep, no more');
  }

  // `use-when` is required where discovery depends on it.
  if (USE_WHEN_REQUIRED_DIRS.includes(topDir) && !isNonEmptyString(fields['use-when'])) {
    fail(rel, `${topDir}/ requires use-when. Without it this artifact can never be selected`);
  }

  // And wherever one is present it must be a trigger. This is the whole of
  // applicability-first loading resting on one field, so the field is checked
  // rather than trusted.
  if (fields['use-when'] !== undefined) {
    const heading = (artifact.body.match(/^#\s+(.+)$/m) ?? [])[1] ?? '';
    const problems = useWhenProblems(fields['use-when'], {
      heading,
      name: path.basename(rel, '.md'),
      directory: topDir,
    });
    for (const problem of problems) fail(rel, `use-when ${problem}`);
  }

  // `status`, `blocked-by`, `part-of` are legal only where they mean something.
  const isSpec = /^efforts\/[^/]+\/spec\.md$/.test(rel);
  const isTicket = /^efforts\/[^/]+\/tickets\//.test(rel);
  if (fields.status !== undefined) {
    if (isSpec && !SPEC_STATUSES.includes(fields.status)) {
      fail(rel, `spec status is "${fields.status}", must be one of: ${SPEC_STATUSES.join(', ')}`);
    } else if (isTicket && !TICKET_STATUSES.includes(fields.status)) {
      fail(rel, `ticket status is "${fields.status}", must be one of: ${TICKET_STATUSES.join(', ')}`);
    } else if (!isSpec && !isTicket) {
      fail(rel, 'status is legal only on an effort spec.md or a local ticket');
    }
  } else if (isSpec) {
    fail(rel, 'an effort spec.md must declare status');
  }
  if (fields['blocked-by'] !== undefined && !isTicket) {
    fail(rel, 'blocked-by is legal only on a local ticket');
  }

  // Links.
  for (const target of wikiLinks(artifact.body)) {
    if (!linkResolves(root, target)) {
      fail(rel, `[[${target}]] resolves to nothing. Repair it or report it, never invent the target`);
    }
  }
}

/**
 * The numbers a spec actually defines, under one of its numbered headings.
 *
 * Requirements and acceptance criteria are top-level ordered lists whose
 * numbering runs on across subheadings, so the section is read from its heading
 * to the next one at the same level. Reading them is what makes a citation
 * checkable rather than merely present.
 */
function numbersUnder(specBody, heading) {
  const start = specBody.search(new RegExp(String.raw`^#\s+${heading}\s*$`, 'm'));
  if (start < 0) return new Set();
  const rest = specBody.slice(start);
  const end = rest.slice(1).search(/^#\s+/m);
  const section = end < 0 ? rest : rest.slice(0, end + 1);
  const numbers = new Set();
  for (const match of section.matchAll(/^(\d+)\.\s/gm)) numbers.add(Number(match[1]));
  return numbers;
}

/** Every `Requirement N` / `Criterion N` a ticket cites, in order of appearance. */
function citations(ticketBody) {
  const start = ticketBody.search(/^##\s+Acceptance Criteria\s*$/m);
  if (start < 0) return [];
  const rest = ticketBody.slice(start);
  const end = rest.slice(1).search(/^##\s+/m);
  const section = end < 0 ? rest : rest.slice(0, end + 1);
  return [...section.matchAll(/\b(requirement|criterion|criteria)\s+(\d+)/gi)].map((match) => ({
    kind: match[1].toLowerCase() === 'requirement' ? 'requirement' : 'criterion',
    number: Number(match[2]),
  }));
}

/**
 * A ticket whose criteria trace to no requirement in the spec is an error.
 *
 * This is what replaces the rule that kept the change and its architecture in
 * one file. Two files can drift apart; a citation that has to resolve cannot
 * drift quietly.
 *
 * A citation is checked against what the spec numbers rather than merely for
 * being present, because a renumbered spec leaves behind references that still
 * look like references. `obsolete` is skipped: the whole point of that status is
 * that the spec moved on without the ticket.
 */
function checkTraceability(root) {
  const effortsDir = path.join(root, 'efforts');
  if (!fs.existsSync(effortsDir)) return;

  for (const entry of fs.readdirSync(effortsDir, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const ticketsDir = path.join(effortsDir, entry.name, 'tickets');
    const specFile = path.join(effortsDir, entry.name, 'spec.md');
    if (!fs.existsSync(ticketsDir) || !fs.existsSync(specFile)) continue;

    const spec = readArtifact(specFile);

    // A landed effort is left exactly as it is. Its spec and its tickets are the
    // record of what was reviewed, and this check exists to stop a live effort's
    // two files from drifting apart, which is a risk only while it is being
    // built. Requirement 48 of aep-3 states the same principle for migration.
    if (spec.fields.status === 'implemented') {
      skippedEfforts.push(entry.name);
      continue;
    }

    const requirements = numbersUnder(spec.body, 'Requirements');
    const criteria = numbersUnder(spec.body, 'Acceptance Criteria');
    const tickets = walk(ticketsDir).filter((file) => file.endsWith('.md'));

    if (requirements.size === 0 && criteria.size === 0) {
      if (tickets.length > 0) {
        fail(`efforts/${entry.name}/spec.md`,
          `numbers no requirements and no acceptance criteria, so none of its ` +
          `${tickets.length} ticket(s) can trace to one. Number them, or the tickets ` +
          'are the only definition of the change');
      }
      continue;
    }

    for (const file of tickets) {
      const rel = toPosix(root, file);
      const ticket = readArtifact(file);
      if (ticket.fields.status === 'obsolete') continue;

      const cited = citations(ticket.body);
      if (cited.length === 0) {
        fail(rel, 'its acceptance criteria cite no requirement or criterion of ' +
          `efforts/${entry.name}/spec.md. A ticket that traces to nothing is either ` +
          'scope nobody asked for, or a requirement the spec is missing');
        continue;
      }

      const defined = (kind) => (kind === 'requirement' ? requirements : criteria);
      if (!cited.some(({ kind, number }) => defined(kind).has(number))) {
        const dangling = cited.map(({ kind, number }) => `${kind} ${number}`).join(', ');
        fail(rel, `cites ${dangling}, and the spec numbers none of them. Either the ` +
          'spec was renumbered under the ticket, or the ticket was written against a ' +
          'spec that no longer says this');
      }
    }
  }
}

function checkStructure(root) {
  for (const forbidden of FORBIDDEN_DIRS) {
    if (fs.existsSync(path.join(root, forbidden))) {
      fail(`${forbidden}/`, 'this directory was retired and must not exist. What it ' +
        'held has moved or was dropped, and the notices for the release that retired ' +
        'it say which. Move anything of yours out of it, then delete it');
    }
  }

  const protocolFile = path.join(root, 'protocol.md');
  if (!fs.existsSync(protocolFile)) {
    fail('protocol.md', 'missing. It is the bootstrap and everything starts there');
  } else {
    const size = fs.statSync(protocolFile).size;
    if (size > PROTOCOL_BUDGET_BYTES) {
      fail('protocol.md', `${size} bytes exceeds the ${PROTOCOL_BUDGET_BYTES}-byte bootstrap budget`);
    }
  }

  const ignoreFile = path.join(root, '.gitignore');
  if (!fs.existsSync(ignoreFile)) {
    fail('.gitignore', 'missing. position/ and worktrees/ must never be committed');
  } else {
    const ignored = fs.readFileSync(ignoreFile, 'utf8');
    for (const entry of ['position/', 'worktrees/']) {
      if (!ignored.split(/\r?\n/).some((line) => line.trim() === entry)) {
        fail('.gitignore', `does not exclude ${entry}`);
      }
    }
  }

  const effortsDir = path.join(root, 'efforts');
  if (fs.existsSync(effortsDir)) {
    for (const entry of fs.readdirSync(effortsDir, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      const effort = path.join(effortsDir, entry.name);
      if (!fs.existsSync(path.join(effort, 'spec.md'))) {
        fail(`efforts/${entry.name}/`, 'an effort must have a spec.md');
      }
      for (const sub of [path.join('evidence', 'research'), path.join('evidence', 'prototypes'), 'tickets']) {
        const target = path.join(effort, sub);
        if (fs.existsSync(target) && walk(target).length === 0) {
          fail(`efforts/${entry.name}/${sub.split(path.sep).join('/')}/`, 'exists but is empty. Create it when something goes in it');
        }
      }
    }
  }
}

function main() {
  const args = process.argv.slice(2);
  const rootArg = args.includes('--root') ? args[args.indexOf('--root') + 1] : null;
  const quiet = args.includes('--quiet');

  const root = resolveAepRoot(rootArg, import.meta.url);
  if (!root) {
    process.stderr.write('no .aep/ found. Pass --root, or run from a repository that has one\n');
    process.exit(2);
  }

  checkStructure(root);
  checkTraceability(root);

  const artifacts = walk(root, { skip: ['position', 'worktrees'] })
    .filter((file) => file.endsWith('.md') && path.basename(file) !== 'index.md');
  for (const file of artifacts) checkArtifact(root, file);

  // The index is derived, so staleness is a defect in the tree, not a warning.
  const indexFile = path.join(root, 'index.md');
  if (!fs.existsSync(indexFile)) {
    fail('index.md', 'missing. Run: node .aep/scripts/index.mjs');
  }

  if (failures.length === 0) {
    if (!quiet) {
      process.stdout.write(`${checked} artifacts checked, no failures\n`);
      if (skippedEfforts.length > 0) {
        process.stdout.write(
          `Traceability not checked for ${skippedEfforts.length} implemented effort(s): ` +
          `${skippedEfforts.join(', ')}. A landed effort is the record of what was reviewed.
`,
        );
      }
      process.stdout.write(
        'Not checked mechanically: whether a use-when shaped like a trigger names the right\n' +
        'occasion. The checks reject a topic; they cannot tell a correct trigger from a\n' +
        'plausible wrong one.\n',
      );
    }
    return;
  }

  process.stderr.write(`${checked} artifacts checked, ${failures.length} failure(s):\n\n`);
  for (const failure of failures) process.stderr.write(`  ${failure}\n`);
  process.stderr.write('\n');
  process.exit(1);
}

main();
