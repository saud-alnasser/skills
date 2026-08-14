'use strict';

// The knowledge store builder.
//
// Mints the ids the store's records are addressed by, refuses what it cannot
// address, and reports three figures it never fails on.
//
//   node .claude/scripts/build-knowledge-store.js
//   node .claude/scripts/build-knowledge-store.js --root <dir>
//
// Three arguments, each taking a value, and nothing else is accepted:
//
//   --root <dir>         the repository root. Everything else is computed from
//                        it, so a run never depends on the working directory.
//                        Defaults to the working directory.
//   --store <dir>        the store to build. Defaults to `.claude/knowledge`
//                        under the root.
//   --store-name <name>  which store this is -- `knowledge` or `framework`.
//                        Precedence is computed from a record's type, its store,
//                        and its firing condition, so the store is an input
//                        rather than something a record could declare about
//                        itself. Defaults to `knowledge`.
//
// An unrecognised argument, and one given no value, are both refused by name.
// Guessing what was meant is how a misspelt flag becomes a run against the
// default store that looks like it did what was asked.
//
// Exit 0 the store built, 1 it was refused. A refusal is written to standard
// error and nothing is written to disk on that run: a store that cannot be
// addressed is not half-minted, because a half-mint is a binding somebody would
// then have to unpick by hand.
//
// Everything this script emits, on either stream, is ASCII. Emitted output is
// captured through whatever console encoding the shell happens to have, and a
// non-ASCII character does not survive one that is not UTF-8 -- it arrives as a
// question mark, in output that still looks well-formed. Refusal lines are held
// to this exactly as report lines are: the transcoding this rule exists for
// happened on a refusal.

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

/** The types this store admits. `ticket` and `map` belong to the tracker store. */
const TYPES = ['norm', 'context', 'decision', 'evidence', 'reference', 'spec'];

/**
 * The shape a subject takes: lowercase words joined by hyphens.
 *
 * Constrained rather than free text because the subject is what a caller types
 * into a filter and what the router's column names, and those two have to be the
 * same token. A subject carrying a space or a capital would be one a filter
 * matched only if the caller reproduced it exactly, which is the loose match
 * this store's query refuses everywhere else.
 */
const SUBJECT = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;

/**
 * Who a record answers to, read off the field and never inferred.
 *
 * Absence is refused rather than defaulted. A record that is the repository's by
 * design and one written before the field existed are otherwise indistinguishable
 * forever, and no later run can tell them apart either -- which is the whole
 * reason the declaration was made mandatory rather than assumed.
 */
const OWNERS = ['framework', 'repository'];

/**
 * The firing conditions the vocabulary names.
 *
 * There is deliberately no judged value: a firing condition the model decides is
 * judged selection wearing a field's clothes.
 *
 * `every-turn` is named here and refused below, and the two are not in tension.
 * It stays so the refusal can be specific: somebody who moved a boot-tier rule
 * into the store needs to learn that the tier is where it belongs, and a generic
 * "outside the closed set" would tell them only that a word was not on a list —
 * which reads as a typo and invites them to pick a different word.
 */
const FIRES_WHEN = ['every-turn', 'posture', 'stage', 'path'];

/**
 * The sub-order precedence puts norms in among themselves, broadest first.
 *
 * `every-turn` is absent because no record in this store can hold one, and
 * ranking it would order a set that has no members while telling a reader the
 * shape is reachable. The boot tier is files the harness loads, and it is
 * ordered by nothing here.
 */
const BREADTH = ['posture', 'stage', 'path'];

/**
 * The firing conditions that name what they fire on, and the field naming it.
 *
 * A condition bounds the *kind* of condition and says nothing about which stages
 * or which postures, so the two are separate fields rather than a qualifier
 * inside one. A list rather than a joined value because the store is reached by
 * filters on declared fields: a list matches exactly, where a joined value would
 * have to be searched inside -- the loose match that turns a miss into a guess.
 *
 * The three differ in where the vocabulary comes from, and that is a fact about
 * each vocabulary rather than an inconsistency. The router's stage table names
 * every stage, so a stage outside it is a stage no row carries and the value is
 * refused. It does *not* name every posture -- a skill outside the table
 * declares one too -- so the posture a mode record names **is** the definition,
 * and what would be a refusal here becomes the report below, from the router's
 * side. A path pattern is checked against nothing at all: a glob covering
 * nothing today is a glob covering something tomorrow, and refusing it would
 * refuse a norm written before the code it governs.
 *
 * `path` is here rather than absent because a path-scoped norm in this store is
 * reached by the query when a covered file is opened -- no preprocessing runs at
 * that moment -- so the patterns have to be a declared field the query can match
 * a path against. A norm that named none would arrive nowhere, which is the same
 * fault the other two are refused for.
 */
const NAMES_WHAT_IT_FIRES_ON = {
  stage: { field: 'stages', verb: 'runs', vocabulary: 'router' },
  posture: { field: 'postures', verb: 'holds', vocabulary: 'store' },
  path: { field: 'paths', verb: 'covers', vocabulary: 'filesystem' },
};

/**
 * The most the boot tier may cost, in characters.
 *
 * The tier is paid on every turn where a row is paid once, so it is the one
 * figure that multiplies -- and it is entirely authored prose that should not
 * grow, which is what makes a threshold meaningful here and not over the
 * instruction count or a row's total. Those mix content that must grow with
 * content that must not, and a bound over the sum cannot tell the regression it
 * exists to catch from ordinary accumulation.
 *
 * **The basis, so a later crossing can be told from a bound set too tight.** The
 * reference tier measured 9894 characters when this was set: an entrypoint of
 * 3694 and four unconditional rules between 1141 and 2450 each. 12000 leaves
 * room for roughly one more rule of average size, or substantial growth in the
 * entrypoint. A crossing therefore means something was added, which is the only
 * reading a bare number could not support.
 */
const BOOT_BUDGET = 12000;

/** The types whose whole file is one record, keyed on its title heading. */
const FROZEN_ACCOUNTS = ['decision', 'spec', 'evidence'];

/** Declared edges naming an id this store carries, which the build resolves. */
const EDGES = ['supersedes', 'superseded-by', 'part-of', 'blocked-by', 'falsifies', 'falsified-by'];

/**
 * The edge pairs that must be written at both ends, and each one's opposite.
 *
 * Resolution does not imply symmetry, which is why this is a second check
 * rather than a stricter first one: a `superseded-by` pointing at a record that
 * exists resolves perfectly well while that record says nothing in return, and
 * that half-written pair is exactly what the rule exists for. The end somebody
 * forgets is the one that was never the file being edited.
 *
 * **Falsification is the second pair for the same reason as the first.** A
 * record whose reasoning is frozen cannot be corrected in place, so a correction
 * lives in another record -- and a correction unreachable from what it corrects
 * reaches nobody, because the reader it exists for is the one who opened the
 * record rather than the index. The forward edge alone is the tempting half: it
 * sits in the file being written.
 *
 * No other edge belongs here. A blocker does not declare what it blocks and a
 * ticket's effort does not enumerate its tickets, so requiring a return edge on
 * those would refuse every correct store.
 */
const SYMMETRIC = {
  supersedes: 'superseded-by',
  'superseded-by': 'supersedes',
  falsifies: 'falsified-by',
  'falsified-by': 'falsifies',
};

/**
 * The edge the builder does not resolve locally, and reports on every run.
 *
 * Its target lives in the framework store, which this build cannot see. Reported
 * once and then silently is how a deviation becomes the rule.
 */
const DEVIATION_EDGE = 'deviates-from';

/**
 * The two fields an edge-depth record declares: which edge, and how far it
 * closes.
 *
 * Depth is a property of the edge type rather than a query parameter, and it is
 * declared by a record rather than carried in the query -- a second home would
 * be free to disagree with the one a reader would edit. This script does not
 * check the value: what a wrong one breaks is a closure, and the closure is
 * where a `closes` nobody can read is refused rather than quietly walked.
 */
const EDGE_DEPTH_FIELDS = ['edge', 'closes'];

/** Fields naming a path rather than an id. A pointer targets the Codebase. */
const POINTER_FIELD = 'sources';
const SPAN_POINTER_FIELD = 'span-sources';

/**
 * The two ranks a record can hold, and why they are these numbers.
 *
 * Three ranks order what binds: what the user said, then decisions, then norms.
 * The first is not a record and never will be -- it is what a human says in the
 * conversation -- so rank 1 is deliberately unoccupied rather than compacted
 * away. Compacting it would make a decision the highest thing in the store,
 * which is exactly the claim the first rank exists to deny.
 *
 * A decision outranks a norm, and that conflict is productive: the norm is
 * amended in the same change rather than quietly losing to a comparison nobody
 * saw.
 */
const RANK_DECISION = 2;
const RANK_NORM = 3;

const ID_PATTERN = /^[a-z0-9]{6}$/;
const ID_ALPHABET = 'abcdefghijklmnopqrstuvwxyz0123456789';
const ID_LENGTH = 6;

// ------------------------------------------------------------------- reading

/**
 * Split a document into its frontmatter lines and its body, preserving both the
 * line ending the checkout uses and whether the file ended with one.
 *
 * @param {string} text the whole file
 * @returns {{eol: string, lines: string[], frontStart: number, frontEnd: number}}
 *   `frontEnd` is the index of the closing delimiter, or -1 when there is no
 *   frontmatter at all -- a fact a caller acts on rather than an error.
 */
function splitDocument(text) {
  const eol = text.includes('\r\n') ? '\r\n' : '\n';
  const lines = text.split(/\r?\n/);
  if (lines[0] !== '---') return { eol, lines, frontStart: 1, frontEnd: -1 };
  for (let i = 1; i < lines.length; i += 1) {
    if (lines[i] === '---') return { eol, lines, frontStart: 1, frontEnd: i };
  }
  return { eol, lines, frontStart: 1, frontEnd: -1 };
}

/**
 * The frontmatter fields, in the order they were written.
 *
 * Deliberately not a YAML parser. It handles the three shapes a record uses --
 * a scalar, an inline list, and a block list whose entries are either bare or
 * `- key: value` -- and records each field's line extent so `spans` can be
 * rewritten in place rather than by re-emitting the whole block.
 *
 * @param {string[]} lines every line of the document
 * @param {number} start first frontmatter line
 * @param {number} end index of the closing delimiter
 * @returns {Array<{key: string, kind: string, raw: any, start: number, end: number}>}
 */
function parseFields(lines, start, end) {
  const fields = [];
  for (let i = start; i < end; i += 1) {
    const line = lines[i];
    if (/^\s*$/.test(line) || /^\s*#/.test(line)) continue;
    const match = line.match(/^([A-Za-z][\w-]*):\s*(.*)$/);
    if (!match) continue;
    const key = match[1];
    const rest = match[2].trim();
    if (rest === '') {
      const raw = [];
      let j = i + 1;
      for (; j < end; j += 1) {
        if (!/^\s+\S/.test(lines[j])) break;
        raw.push(lines[j].trim());
      }
      fields.push({ key, kind: 'block', raw, start: i, end: j });
      i = j - 1;
    } else if (rest.startsWith('[')) {
      fields.push({ key, kind: 'inline', raw: rest, start: i, end: i + 1 });
    } else {
      fields.push({ key, kind: 'scalar', raw: rest, start: i, end: i + 1 });
    }
  }
  return fields;
}

function unquote(value) {
  return value.replace(/^["']|["']$/g, '').trim();
}

/** An inline YAML array as a list of bare strings. */
function inlineList(value) {
  const inner = value.slice(1, value.lastIndexOf(']'));
  return inner
    .split(',')
    .map((item) => unquote(item.trim()))
    .filter(Boolean);
}

/** The scalar a field declares, or null where it declares none. */
function scalar(fields, key) {
  const field = fields.find((candidate) => candidate.key === key);
  if (!field || field.kind !== 'scalar') return null;
  return unquote(field.raw);
}

/** Every value a list-valued field declares, in either list shape. */
function list(fields, key) {
  const field = fields.find((candidate) => candidate.key === key);
  if (!field) return [];
  if (field.kind === 'inline') return inlineList(field.raw);
  if (field.kind === 'block') return field.raw.map((entry) => unquote(entry.replace(/^-\s*/, '')));
  return [unquote(field.raw)];
}

/** The `- anchor: value` entries of a block-shaped mapping field. */
function mapping(fields, key) {
  const field = fields.find((candidate) => candidate.key === key);
  if (!field) return null;
  if (field.kind === 'inline') return inlineList(field.raw).length === 0 ? [] : null;
  if (field.kind !== 'block') return null;
  const entries = [];
  for (const entry of field.raw) {
    const match = entry.replace(/^-\s*/, '').match(/^([^:]+):\s*(.*)$/);
    if (!match) continue;
    entries.push({ anchor: unquote(match[1].trim()), value: unquote(match[2].trim()) });
  }
  return entries;
}

/**
 * Every heading in a body, with its level and line, skipping fenced code.
 *
 * A frontmatter example inside a fence is not a heading, and counting one would
 * mint an id for a span that does not exist.
 */
function headingsOf(lines, from) {
  const headings = [];
  let fenced = false;
  for (let i = from; i < lines.length; i += 1) {
    if (/^\s*(```|~~~)/.test(lines[i])) {
      fenced = !fenced;
      continue;
    }
    if (fenced) continue;
    const match = lines[i].match(/^(#{1,6})\s+(.+?)\s*$/);
    if (match) headings.push({ level: match[1].length, text: match[2], line: i });
  }
  return headings;
}

/** A heading's anchor: lowercased, runs of non-alphanumerics collapsed to one hyphen. */
function anchorOf(text) {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

/**
 * The imperatives a span states.
 *
 * A norm-shaped imperative is a top-level bullet or a paragraph opening with a
 * bold clause -- the form the corpus already writes its rules in. Indented
 * bullets are elaboration of the one above them and are not counted.
 */
function countImperatives(lines, from, to) {
  let count = 0;
  let fenced = false;
  let previousBlank = true;
  for (let i = from; i < to && i < lines.length; i += 1) {
    const line = lines[i];
    if (/^\s*(```|~~~)/.test(line)) {
      fenced = !fenced;
      previousBlank = false;
      continue;
    }
    if (fenced) continue;
    if (/^\s*$/.test(line)) {
      previousBlank = true;
      continue;
    }
    if (/^- \*\*/.test(line)) count += 1;
    else if (previousBlank && /^\*\*/.test(line)) count += 1;
    previousBlank = false;
  }
  return count;
}

// ------------------------------------------------------------------- minting

/**
 * Six lowercase alphanumerics from a cryptographic source, unused in this store.
 *
 * Not derived from position -- inserting a span would shift every binding below
 * it. Not derived from content -- a cosmetic reformatting would read as a
 * deletion plus an addition, which is what a real loss reads as.
 *
 * @param {Set<string>} taken every id the store already carries
 * @returns {string} an id no record carries
 */
function mintId(taken) {
  for (;;) {
    const bytes = crypto.randomBytes(ID_LENGTH);
    let id = '';
    for (let i = 0; i < ID_LENGTH; i += 1) id += ID_ALPHABET[bytes[i] % ID_ALPHABET.length];
    if (!taken.has(id)) return id;
  }
}

// ------------------------------------------------------------ the store read

/**
 * Read one file into the records it carries.
 *
 * Which records a file decomposes into is computed from its type and never
 * declared: a frozen account is one record keyed on its title, because its `##`
 * headings are one record's sections rather than separate statements.
 */
function readFile(storeDirectory, name) {
  const text = fs.readFileSync(path.join(storeDirectory, name), 'utf8');
  const { eol, lines, frontStart, frontEnd } = splitDocument(text);
  const fields = frontEnd === -1 ? [] : parseFields(lines, frontStart, frontEnd);
  const bodyStart = frontEnd === -1 ? 0 : frontEnd + 1;
  const headings = headingsOf(lines, bodyStart);
  const type = scalar(fields, 'type');

  let heads;
  if (type && FROZEN_ACCOUNTS.includes(type)) {
    heads = headings.filter((heading) => heading.level === 1).slice(0, 1);
    if (heads.length === 0) heads = headings.slice(0, 1);
  } else {
    heads = headings.filter((heading) => heading.level === 2);
    if (heads.length === 0) heads = headings.filter((heading) => heading.level === 1).slice(0, 1);
    if (heads.length === 0) heads = headings.slice(0, 1);
  }
  if (heads.length === 0) {
    heads = [{ level: 0, text: name.replace(/\.md$/, ''), line: bodyStart - 1 }];
  }

  const records = heads.map((head) => {
    let end = lines.length;
    for (const heading of headings) {
      if (heading.line > head.line && heading.level <= head.level) {
        end = heading.line;
        break;
      }
    }
    const body = lines.slice(head.line + 1, end).join('\n');
    return {
      file: name,
      heading: head.text,
      anchor: anchorOf(head.text),
      imperatives: countImperatives(lines, head.line + 1, end),
      size: body.length,
      id: null,
    };
  });

  return { name, text, eol, lines, frontStart, frontEnd, fields, headings, type, records };
}

/** Every `*.md` directly in the store, in filename order. A missing store is empty. */
function listStore(storeDirectory) {
  if (!fs.existsSync(storeDirectory)) return [];
  return fs
    .readdirSync(storeDirectory, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith('.md'))
    .map((entry) => entry.name)
    .sort();
}

// ------------------------------------------------------------------ the row

/**
 * Every stage the router names a row for, and every posture those rows run under.
 *
 * Both come from the router's own stage table rather than from a list here, so a
 * stage or a posture the release adds needs no edit to this script. They are read
 * in one pass because they are one table: a posture with no row is a posture no
 * stage runs under, which is the same fact as a stage with no row.
 *
 * @returns {{stages: string[], postures: string[], found: boolean, at: string}}
 */
function readRouter(root) {
  const at = path.join('.claude', 'protocol.md');
  const absolute = path.join(root, at);
  if (!fs.existsSync(absolute)) return { stages: [], postures: [], found: false, at };
  const text = fs.readFileSync(absolute, 'utf8');
  const stages = [];
  const postures = [];
  // Which postures each stage runs under, kept alongside the flat lists because
  // a stage's row carries the mode it runs in: a mode is delivered when a stage
  // declaring it starts, so a figure counting only the stage norms understates
  // what that stage pays.
  const byStage = new Map();
  for (const match of text.matchAll(/^\|\s*`\/([a-z]+)`\s*\|\s*([a-z-]+)\s*\|/gm)) {
    if (!stages.includes(match[1])) stages.push(match[1]);
    if (!postures.includes(match[2])) postures.push(match[2]);
    if (!byStage.has(match[1])) byStage.set(match[1], []);
    if (!byStage.get(match[1]).includes(match[2])) byStage.get(match[1]).push(match[2]);
  }
  return { stages, postures, byStage, found: true, at };
}

/**
 * The size of the boot tier: the entrypoint, and the rules carrying no `paths:`.
 *
 * Reported as a figure of its own rather than folded into the rows, because the
 * tier is paid on every turn where a row is paid once.
 */
function bootTierSize(root) {
  let size = 0;
  const entry = path.join(root, 'CLAUDE.md');
  if (fs.existsSync(entry)) size += fs.readFileSync(entry, 'utf8').length;
  const rules = path.join(root, '.claude', 'rules');
  if (!fs.existsSync(rules)) return size;
  for (const entryName of fs.readdirSync(rules)) {
    if (!entryName.endsWith('.md')) continue;
    const text = fs.readFileSync(path.join(rules, entryName), 'utf8');
    const { lines, frontStart, frontEnd } = splitDocument(text);
    const fields = frontEnd === -1 ? [] : parseFields(lines, frontStart, frontEnd);
    if (fields.some((field) => field.key === 'paths')) continue;
    size += text.length;
  }
  return size;
}

// ------------------------------------------------------------------ writing

/** The `spans` block a file's records call for, as frontmatter lines. */
function renderSpans(records) {
  return ['spans:', ...records.map((record) => `  - ${record.anchor}: ${record.id}`)];
}

/**
 * Write a file's `spans` block, and only where it differs from what is there.
 *
 * A file whose block already says what this run computed is not rewritten at
 * all, which is what makes a second run change nothing.
 *
 * @returns {boolean} whether the file was written
 */
function writeSpans(storeDirectory, file) {
  const rendered = renderSpans(file.records);
  const existing = file.fields.find((field) => field.key === 'spans');
  const lines = file.lines.slice();

  if (existing) {
    const current = lines.slice(existing.start, existing.end);
    if (current.length === rendered.length && current.every((line, i) => line === rendered[i])) {
      return false;
    }
    lines.splice(existing.start, existing.end - existing.start, ...rendered);
  } else {
    lines.splice(file.frontEnd, 0, ...rendered);
  }

  fs.writeFileSync(path.join(storeDirectory, file.name), lines.join(file.eol));
  return true;
}

// ------------------------------------------------------------------ the build

/**
 * Build the store: mint, refuse, report.
 *
 * @param {{root: string, storeDirectory: string, storeName: string}} options
 * @returns {{refusals: string[], report: string[], ledger: object, written: string[]}}
 */
function build(options) {
  const { root, storeDirectory, storeName } = options;
  const refusals = [];
  const files = listStore(storeDirectory).map((name) => readFile(storeDirectory, name));
  const router = readRouter(root);

  // Reserve every id already on disk before minting one, so a fresh id cannot
  // collide with an id further down the store that has not been read yet.
  const taken = new Set();
  for (const file of files) {
    const spans = mapping(file.fields, 'spans');
    if (!spans) continue;
    for (const entry of spans) if (ID_PATTERN.test(entry.value)) taken.add(entry.value);
  }

  const declaredBy = new Map();
  for (const file of files) {
    const spans = mapping(file.fields, 'spans') || [];
    const byAnchor = new Map(spans.map((entry) => [entry.anchor, entry.value]));
    const produced = new Set(file.records.map((record) => record.anchor));

    // A `spans` anchor no heading produces is refused before anything is minted.
    // A heading rename therefore fails rather than silently unbinding, and the
    // id is not re-minted onto the new anchor: a rename is a human decision
    // about whether the norm survived it.
    for (const entry of spans) {
      if (!produced.has(entry.anchor)) {
        refusals.push(`${file.name}  spans anchor "${entry.anchor}" is produced by no heading`);
      }
    }

    for (const entry of mapping(file.fields, SPAN_POINTER_FIELD) || []) {
      if (!produced.has(entry.anchor)) {
        refusals.push(`${file.name}  ${SPAN_POINTER_FIELD} anchor "${entry.anchor}" is produced by no heading`);
      }
    }

    for (const record of file.records) {
      const existing = byAnchor.get(record.anchor);
      record.id = existing && ID_PATTERN.test(existing) ? existing : mintId(taken);
      taken.add(record.id);
      // Guarded on the id rather than on the pair of files: one file binding two
      // anchors to one token is the same fault as two files doing it, and the
      // citation it produces is ambiguous in exactly the same way.
      const seen = declaredBy.get(record.id);
      if (seen === file.name) {
        refusals.push(`${file.name}  declares the id ${record.id} twice`);
      } else if (seen) {
        refusals.push(`${seen} and ${file.name}  both declare the id ${record.id}`);
      }
      declaredBy.set(record.id, file.name);
    }

    if (!file.type || !TYPES.includes(file.type)) {
      refusals.push(`${file.name}  type "${file.type === null ? '(none declared)' : file.type}" is outside the closed set`);
    }

    const owner = scalar(file.fields, 'owner');
    if (owner === null || !OWNERS.includes(owner)) {
      refusals.push(`${file.name}  owner "${owner === null ? '(none declared)' : owner}" is outside the closed set`);
    }

    // What the record is about, declared rather than recovered from the name.
    // The id is what addresses a record, which is what lets a file keep a
    // readable name and makes a rename free -- so nothing may use the name as a
    // handle, and without this field nothing could name a record at all.
    const subject = scalar(file.fields, 'subject');
    if (subject === null) {
      refusals.push(`${file.name}  declares no subject, and a filename is not one`);
    } else if (!SUBJECT.test(subject)) {
      refusals.push(`${file.name}  subject "${subject}" is not lowercase words joined by hyphens`);
    }

    const firesWhen = scalar(file.fields, 'fires-when');
    const named = {};
    const declares = {};
    for (const { field } of Object.values(NAMES_WHAT_IT_FIRES_ON)) {
      named[field] = list(file.fields, field);
      declares[field] = file.fields.some((candidate) => candidate.key === field);
    }
    if (firesWhen !== null) {
      if (!FIRES_WHEN.includes(firesWhen)) {
        refusals.push(`${file.name}  fires-when "${firesWhen}" is outside the closed set`);
      } else if (file.type !== 'norm') {
        refusals.push(`${file.name}  fires-when is declared by a norm and this record's type is ${file.type === null ? '(none declared)' : file.type}`);
      } else if (firesWhen === 'every-turn') {
        // A norm firing every turn belongs to the boot tier, which stays files
        // the harness loads. Behind the store nothing would fire it: it has to
        // arrive on a turn the user did not start, and the store is reached by
        // a stage that has already begun. So it would simply stop arriving,
        // with nothing reporting that it had -- and refusing is what keeps the
        // tier boundary a fact rather than a convention somebody drifts across.
        for (const record of file.records) {
          refusals.push(`${file.name}  ${record.id}  declares every-turn, and the boot tier is files rather than records in this store`);
        }
      } else if (NAMES_WHAT_IT_FIRES_ON[firesWhen]) {
        // The firing condition says which *kind* of condition; the list says
        // which ones. A norm naming none arrives nowhere, and a row that should
        // have carried it is indistinguishable from a row that never had it --
        // so this is refused rather than counted, a count in a report being
        // nothing a build fails on. Declared-and-empty takes the same refusal as
        // not declared at all: they are one fault to a reader, and splitting
        // them lets the shape that looks deliberate through.
        const { field, verb, vocabulary } = NAMES_WHAT_IT_FIRES_ON[firesWhen];
        for (const record of file.records) {
          if (named[field].length === 0) {
            refusals.push(`${file.name}  ${record.id}  fires when a ${firesWhen} ${verb} and names no ${firesWhen}`);
          } else if (vocabulary !== 'router') {
            // Nothing here to check the value against. A posture's own record is
            // the definition, and what a typo in one breaks is caught from the
            // other side, in the report below: the router row that meant to
            // reach it then names a posture no record defines. A path pattern
            // answers to the filesystem, which is free to not hold the file yet.
          } else if (!router.found) {
            refusals.push(`${file.name}  ${record.id}  names ${field} and no router was found at ${router.at}`);
          } else {
            // Every entry, never the first that fails: a norm naming two values
            // the router does not carry would otherwise report one, and the
            // second surfaces only after somebody fixes the first.
            for (const value of named[field]) {
              if (!router[field].includes(value)) {
                refusals.push(`${file.name}  ${record.id}  names ${firesWhen} "${value}", which no router row names`);
              }
            }
          }
        }
      }
      file.firesWhen = firesWhen;
    }
    file.stages = named.stages;
    file.postures = named.postures;
    file.paths = named.paths;

    // A list answers *which ones*, so it is meaningless beside any other firing
    // condition and absent one entirely. Refused rather than ignored: a field
    // sitting in frontmatter is one the next author reads as load-bearing.
    for (const [condition, { field }] of Object.entries(NAMES_WHAT_IT_FIRES_ON)) {
      if (declares[field] && firesWhen !== condition) {
        const shown = firesWhen === null ? '(none declared)' : `"${firesWhen}"`;
        refusals.push(`${file.name}  declares ${field} and its firing condition is ${shown}`);
      }
    }

    // One instruction per record, and only what instructs is held to it: a
    // frozen account is one record by construction, so counting imperatives
    // across a whole decision would refuse every one of them.
    if (file.type === 'norm') {
      for (const record of file.records) {
        if (record.imperatives > 1) {
          refusals.push(`${file.name}  heading "${record.heading}" states ${record.imperatives} imperatives, and a record states one`);
        }
      }
    }
  }

  const ids = new Set();
  const carrier = new Map();
  for (const file of files) {
    for (const record of file.records) {
      ids.add(record.id);
      carrier.set(record.id, file);
    }
  }

  const deviations = [];
  const brokenPointers = [];
  const cited = new Set();
  for (const file of files) {
    for (const field of EDGES) {
      for (const value of list(file.fields, field)) {
        if (!ids.has(value)) {
          refusals.push(`${file.name}  ${field} cites ${value}, which no record carries`);
        } else {
          cited.add(value);
        }
      }
    }
    // Symmetry, over the edges that resolved. An unresolved one is already
    // refused above and takes its own message, so a reader can tell a citation
    // naming nothing from a pair written at one end only.
    for (const [field, opposite] of Object.entries(SYMMETRIC)) {
      for (const value of list(file.fields, field)) {
        const target = carrier.get(value);
        if (target === undefined) continue;
        const mine = file.records.map((record) => record.id);
        const back = list(target.fields, opposite);
        if (!back.some((id) => mine.includes(id))) {
          refusals.push(
            `${file.name}  ${mine.join(', ')}  ${field} names ${value}, and ${target.name} declares no ${opposite} naming it back`,
          );
        }
      }
    }
    // Declared and empty is the one deviation fault this build can catch. The
    // target sits in the framework store, so an id naming nothing there is
    // unresolvable from here -- but a field naming nothing at all is a
    // departure from law that says which law it departs from nowhere, and that
    // reads on every report as a deviation somebody is carrying.
    const departures = list(file.fields, DEVIATION_EDGE);
    if (file.fields.some((candidate) => candidate.key === DEVIATION_EDGE) && departures.length === 0) {
      refusals.push(`${file.name}  ${DEVIATION_EDGE} declares no record, and an edge naming nothing traces to nothing`);
    }
    for (const value of departures) {
      deviations.push(`${file.name}  ${DEVIATION_EDGE}  ${value}`);
    }
    const pointers = list(file.fields, POINTER_FIELD).map((value) => ({ field: POINTER_FIELD, value }));
    for (const entry of mapping(file.fields, SPAN_POINTER_FIELD) || []) {
      pointers.push({ field: SPAN_POINTER_FIELD, value: entry.value });
    }
    for (const pointer of pointers) {
      const target = pointer.value.split(/\s+/)[0];
      if (!fs.existsSync(path.join(root, target))) {
        brokenPointers.push(`${file.name}  ${pointer.field}  ${pointer.value}`);
      }
    }
  }

  if (refusals.length > 0) return { refusals, failures: [], report: [], ledger: null, written: [] };

  const written = [];
  for (const file of files) {
    if (writeSpans(storeDirectory, file)) written.push(file.name);
  }

  const ledgerRecords = [];
  let instructions = 0;
  for (const file of files) {
    for (const record of file.records) {
      const entry = {
        id: record.id,
        file: record.file,
        anchor: record.anchor,
        heading: record.heading,
        type: file.type,
        subject: scalar(file.fields, 'subject'),
        // Carried rather than left in the markdown, and not the same fact as
        // the store: a record's store says which index answers for it, and its
        // owner says whether it is law. Both are needed to tell a framework norm
        // a repository must follow from one it wrote itself, and the query reads
        // this index and nothing else.
        owner: scalar(file.fields, 'owner'),
        store: storeName,
        size: record.size,
        instructions: record.imperatives,
      };
      if (file.firesWhen) {
        entry['fires-when'] = file.firesWhen;
        // A list rather than a joined value, so asking which norms fire at a
        // stage -- or under a posture -- is an exact match on a declared field.
        // Matching inside a value is the loose match the query refuses, and the
        // refusal is what makes a miss a fact.
        if (file.stages && file.stages.length > 0) entry.stages = file.stages;
        if (file.postures && file.postures.length > 0) entry.postures = file.postures;
        // The patterns rather than a joined value, for the same reason and one
        // step further: the query matches a caller's path against each of them,
        // and a joined value would have to be split before it could be matched.
        if (file.paths && file.paths.length > 0) entry.paths = file.paths;
        entry.breadth = BREADTH.indexOf(file.firesWhen);
      }
      // Only what binds carries a rank, and asking for one is answered with
      // nothing rather than with a default: a description handed a number
      // invites a caller to weigh it against an instruction.
      if (file.type === 'decision') entry.rank = RANK_DECISION;
      if (file.type === 'norm') entry.rank = RANK_NORM;
      // The declared edges, carried into the index rather than left in the
      // markdown. The query computes a closure in one call and reads this index
      // and nothing else, so an edge that stayed in the file would be an edge
      // the closure could not follow -- and not following one is exactly what
      // the closure exists to make impossible to confuse with an absent one.
      const edges = {};
      for (const field of [...EDGES, DEVIATION_EDGE]) {
        const values = list(file.fields, field);
        if (values.length > 0) edges[field] = values;
      }
      if (Object.keys(edges).length > 0) entry.edges = edges;
      // How far each edge type closes is declared by a record rather than
      // carried in the query, and the query reads this index and nothing else --
      // so a fact stated in a record and absent from here is a fact the query
      // cannot reach. Carried by name for the same reason the fields above are:
      // copying whatever frontmatter happened to be present would put `spans`
      // and `sources` into the index as though they were content.
      for (const field of EDGE_DEPTH_FIELDS) {
        const value = scalar(file.fields, field);
        if (value !== null) entry[field] = value;
      }
      // The corpus's count, not the norms' count. What is reported is how much
      // instruction a reader of this store is carrying, and a description that
      // states an imperative is carried whether or not it was meant to.
      instructions += record.imperatives;
      ledgerRecords.push(entry);
    }
  }

  const unreferenced = ledgerRecords.filter((record) => !cited.has(record.id));

  // A posture a router row names that no record here defines: the row asks for a
  // posture and nothing would arrive. This is the other side of the check the
  // vocabulary rule above deliberately does not make -- a mode record's value is
  // the definition, so a typo in one is invisible there and shows up here as the
  // row that can no longer reach it.
  //
  // Reported rather than failed, and only where this store defines postures at
  // all: a store holding no mode record is not the store that defines them, and
  // has nothing to say about what the router names.
  const definedPostures = new Set();
  for (const file of files) {
    if (file.firesWhen !== 'posture') continue;
    for (const posture of file.postures) definedPostures.add(posture);
  }
  const undefinedPostures =
    definedPostures.size === 0 ? [] : router.postures.filter((posture) => !definedPostures.has(posture));

  const rows = router.stages.map((stage) => {
    const runsUnder = (router.byStage && router.byStage.get(stage)) || [];
    let authored = 0;
    let generated = 0;
    for (const entry of ledgerRecords) {
      // Two conditions reach a stage's row and they are not the same fact. A
      // stage norm names this stage; a mode names the posture this stage runs
      // under, and is delivered when a stage declaring it starts. A figure
      // counting only the first would report a row smaller than the one
      // delivered, which is the direction a size figure must never be wrong in.
      // A norm several stages read counts under each of their rows, because each
      // of those stages pays for it.
      const matches =
        (entry['fires-when'] === 'stage' && (entry.stages || []).includes(stage)) ||
        (entry['fires-when'] === 'posture' && (entry.postures || []).some((posture) => runsUnder.includes(posture)));
      if (!matches) continue;
      if (entry.file === 'map.md') generated += entry.size;
      else authored += entry.size;
    }
    return { stage, authored, generated };
  });

  const ledger = {
    store: storeName,
    figures: {
      instructions,
      'boot-tier': bootTierSize(root),
      rows,
    },
    records: ledgerRecords,
    reports: {
      deviations,
      'broken-pointers': brokenPointers,
      'postures-no-record-defines': undefinedPostures,
      unreferenced: unreferenced.map((record) => `${record.file}  ${record.id}`),
    },
  };

  const report = [];
  report.push(`store: ${storeName}`);
  report.push(`instructions: ${instructions}`);
  report.push(`boot tier: ${ledger.figures['boot-tier']} characters`);
  report.push(router.found ? 'rows:' : `rows: no router at ${router.at}`);
  for (const row of rows) {
    report.push(`  ${row.stage}  authored ${row.authored}  generated ${row.generated}`);
  }
  report.push(`deviations: ${deviations.length}`);
  for (const line of deviations) report.push(`  ${line}`);
  report.push(`broken pointers: ${brokenPointers.length}`);
  for (const line of brokenPointers) report.push(`  ${line}`);
  report.push(`postures no record defines: ${undefinedPostures.length}`);
  for (const posture of undefinedPostures) report.push(`  ${router.at}  ${posture}`);
  report.push(`unreferenced: ${unreferenced.length}`);
  for (const record of unreferenced) report.push(`  ${record.file}  ${record.id}`);

  // Separate from a refusal, and after the report rather than before it. A tier
  // over budget is not a defect in the store: every record is addressable and
  // the ledger is correct, so refusing the store would discard a good index and
  // report a true thing under a false heading. Failing here leaves the report
  // standing -- including the figure, which is the number whoever has to answer
  // for the crossing needs to see.
  const failures = [];
  const bootTier = ledger.figures['boot-tier'];
  if (bootTier > BOOT_BUDGET) {
    failures.push(`boot tier: ${bootTier} characters, over the budget of ${BOOT_BUDGET}`);
  }

  return { refusals, failures, report, ledger, written };
}

// ---------------------------------------------------------------------- entry

/** Every argument this script takes, and the option each one sets. */
const ARGUMENTS = {
  '--root': 'root',
  '--store': 'storeDirectory',
  '--store-name': 'storeName',
};

/**
 * Read the command line.
 *
 * @param {string[]} argv the arguments after the script's own name
 * @returns {{options: object, problems: string[]}} the options, and every
 *   argument that could not be used. A problem is a refusal rather than a
 *   warning: the run does not proceed on a command line nobody could read.
 */
function parseArguments(argv) {
  const options = { root: process.cwd(), storeDirectory: null, storeName: 'knowledge' };
  const problems = [];
  for (let i = 0; i < argv.length; i += 1) {
    const field = ARGUMENTS[argv[i]];
    if (field === undefined) {
      problems.push(`"${argv[i]}" is not an argument this script takes`);
      continue;
    }
    const value = argv[i + 1];
    // A flag standing where a value should be is a missing value rather than a
    // value that happens to look like a flag, and reading it as one would build
    // a store directory named `--store-name`.
    if (value === undefined || ARGUMENTS[value] !== undefined) {
      problems.push(`${argv[i]} was given no value`);
      continue;
    }
    options[field] = value;
    i += 1;
  }
  options.root = path.resolve(options.root);
  options.storeDirectory = options.storeDirectory
    ? path.resolve(options.storeDirectory)
    : path.join(options.root, '.claude', 'knowledge');
  return { options, problems };
}

function main(argv) {
  const { options, problems } = parseArguments(argv);
  if (problems.length > 0) {
    process.stderr.write(`the arguments were refused: ${problems.length} to answer for\n`);
    for (const problem of problems) process.stderr.write(`  ${problem}\n`);
    return 1;
  }

  const result = build(options);

  if (result.refusals.length > 0) {
    process.stderr.write(`the store was refused: ${result.refusals.length} to answer for\n`);
    for (const refusal of result.refusals) process.stderr.write(`  ${refusal}\n`);
    return 1;
  }

  const ledgerPath = path.join(options.root, '.claude', 'position', 'ledger.json');
  fs.mkdirSync(path.dirname(ledgerPath), { recursive: true });
  fs.writeFileSync(ledgerPath, `${JSON.stringify(result.ledger, null, 2)}\n`);

  process.stdout.write(`${result.report.join('\n')}\n`);

  if (result.failures.length > 0) {
    process.stderr.write(`the build failed: ${result.failures.length} to answer for\n`);
    for (const failure of result.failures) process.stderr.write(`  ${failure}\n`);
    return 1;
  }

  return 0;
}

process.exitCode = main(process.argv.slice(2));
