'use strict';

// The row assembler.
//
// Assembles a stage's row and emits it for inlining. It is the only script the
// *harness* runs rather than a stage: the row has to be in place before the
// stage's own content reaches the model.
//
//   node .claude/scripts/assemble-row.js --stage implement
//   node .claude/scripts/assemble-row.js --stage implement --chunk 0
//   node .claude/scripts/assemble-row.js --stage implement --framework <dir>
//
// Arguments, each taking a value:
//
//   --stage <name>     the stage the row is for. Required: a row assembled for
//                      no stage is a row nothing selected.
//   --root <dir>       the repository root. Defaults to the working directory.
//   --framework <dir>  the plugin's framework store, whose text this script
//                      needs and whose ledger sits beside it. **The harness
//                      exports the plugin's root to skill content, and skill
//                      content is what invokes this script** -- which is the one
//                      place in the system that path resolves, and the reason
//                      delivery can read the framework store where a stage's own
//                      shell cannot. Omitted, the row is the repository's norms
//                      alone and the header says so.
//   --chunk <n>        emit only chunk `n`, zero-based. Omitted, the whole row
//                      is emitted and the chunk plan goes to standard error.
//
// **This script fails unguarded, deliberately.** A non-zero exit from an inlined
// command aborts the whole skill and the stage receives nothing at all -- its own
// instructions included. The alternative is worse: guarded, the row arrives with
// the shell's error text inlined as prose and nothing reporting it, and a stage
// running on a row containing an error message will act, confidently, on norms it
// does not have. A stage that did not start is a fault somebody fixes; a stage
// that started wrong is one nobody sees. A repository choosing otherwise records
// it as a deviation.
//
// **There is a third outcome, and this script cannot reach it.** With
// `disableSkillShellExecution: true` set, the harness never runs the command: it
// replaces it with the literal text `[shell command execution disabled by policy]`
// and **renders the skill anyway**. So the stage starts, alive and confident, with
// that sentence where its norms should be -- which is precisely the guarded
// outcome the choice above rejected, arriving by policy rather than by choice and
// bypassing the choice entirely, because no exit code is ever produced to fail on.
// Nothing this script does can prevent it. What defends against it is the row's
// opening line: a stage whose row does not begin with the header below did not
// receive a row, and the check belongs to whatever inlines this, not to this.
//
// Exit 0 the row was assembled, 1 it was not. Everything emitted on standard
// error is ASCII; the row itself is the corpus's own bytes and is emitted
// unchanged, because a delivered norm that is not byte-identical to the record is
// a norm nobody can check against its store.

const fs = require('fs');
const path = require('path');

/**
 * The largest chunk this script emits, in characters.
 *
 * **The cap is per substitution rather than per assembled body**, which is what
 * makes inlining a whole row work at all: several commands each under it carry a
 * row far larger than any one of them could. A single substitution above the cap
 * is withheld -- the harness persists it and substitutes a preview and a path,
 * which is exactly the round trip inlining exists to remove, arriving disguised
 * as success.
 *
 * **The basis, so a later change can be told from a number somebody nudged.** The
 * ceiling is documented rather than bracketed: a valid result inlines up to
 * roughly 30,000 characters, and past that the harness returns a file path plus a
 * short preview. `BASH_MAX_OUTPUT_LENGTH` enlarges the read-back window and
 * **does not raise that ceiling**, so no environment variable buys a bigger
 * substitution. That confirms the upper end of the (20,036, 30,036] bracket this
 * figure was first measured against.
 *
 * **It stays at 20,000 anyway, and the gap is deliberate.** Four substitutions of
 * about 20,057 characters have been measured delivering whole, so this is the
 * proven floor; the documented ceiling is hedged with "roughly", and the two
 * outcomes are not comparable. Overshooting costs a row silently replaced by a
 * preview that reads like a row. Undershooting costs one more chunk boundary at
 * roughly 1.6 to 1.75 seconds. Seconds are the cheaper side of that trade, so the
 * documented ceiling is recorded here as a bound rather than spent.
 */
const CHUNK_CAP = 20000;

/**
 * Chunk boundaries are the only slow part, so there are as few as possible.
 *
 * A boundary costs roughly 1.6 to 1.75 seconds where the bytes inside a command
 * cost about 23 milliseconds at either size measured. So chunks are as large as
 * the cap allows and as few as the row needs: splitting finer is not free
 * caution, it is the whole cost.
 */
const SEPARATOR = '\n\n';

// ------------------------------------------------------------------- reading

/** Read a JSON index, or nothing where it is not there. */
function readIndex(at) {
  if (!fs.existsSync(at)) return null;
  const ledger = JSON.parse(fs.readFileSync(at, 'utf8').replace(/^\uFEFF/, ''));
  return Array.isArray(ledger.records) ? ledger.records : [];
}

/**
 * Every heading in a document, with its level and line, skipping fenced code.
 *
 * The same rule the builder minted ids under, because the span a record was given
 * an id for and the span delivered as that record have to be the same span. A
 * second reading of what a heading is would put the two quietly out of step.
 */
function headingsOf(lines) {
  const headings = [];
  let fenced = false;
  for (let i = 0; i < lines.length; i += 1) {
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
 * The text of one record: its heading and everything under it, verbatim.
 *
 * **The two ways this fails are reported apart.** A file that is not there and a
 * file whose heading moved are one symptom and two different repairs, and saying
 * "carries no heading" of a file that does not exist sends a reader to inspect
 * headings in nothing. The path is named either way, because the store a record
 * was looked for in is the fact a reader is missing when the index and the store
 * disagree about where something lives.
 *
 * @param {string} storeDirectory the directory holding the record's file
 * @param {{file: string, anchor: string}} record the ledger entry
 * @returns {{text: string}|{missing: 'file'|'anchor', at: string}} the span, or why not
 */
function textOf(storeDirectory, record) {
  const at = path.join(storeDirectory, record.file);
  if (!fs.existsSync(at)) return { missing: 'file', at };
  const lines = fs.readFileSync(at, 'utf8').replace(/^\uFEFF/, '').split(/\r?\n/);
  const headings = headingsOf(lines);
  const head = headings.find((heading) => anchorOf(heading.text) === record.anchor);
  if (!head) return { missing: 'anchor', at };

  let end = lines.length;
  for (const heading of headings) {
    if (heading.line > head.line && heading.level <= head.level) {
      end = heading.line;
      break;
    }
  }
  return { text: lines.slice(head.line, end).join('\n').replace(/\s+$/, '') };
}

// ------------------------------------------------------------------ the row

/**
 * Which postures a stage runs under, read from the router's own stage table.
 *
 * From the router rather than from a list here, for the reason the table exists:
 * it is the one statement of what a stage reads that the delivery path itself
 * depends on, so a skill's own declaration is a default and this is the fact.
 *
 * @returns {{postures: string[], found: boolean, at: string}}
 */
function posturesOfStage(root, stage) {
  const at = path.join('.claude', 'protocol.md');
  const absolute = path.join(root, at);
  if (!fs.existsSync(absolute)) return { postures: [], found: false, at };
  const text = fs.readFileSync(absolute, 'utf8');
  const postures = [];
  for (const match of text.matchAll(/^\|\s*`\/([a-z]+)`\s*\|\s*([a-z-]+)\s*\|/gm)) {
    if (match[1] === stage && !postures.includes(match[2])) postures.push(match[2]);
  }
  return { postures, found: true, at };
}

/**
 * The records a stage's row carries.
 *
 * **Every norm whose firing condition matches this stage, and nothing else.** Not
 * a selection -- no judgement enters anywhere, because judged selection is the
 * mis-loading this whole design removes, and a filter a model may override is
 * judged selection with extra steps.
 *
 * Two conditions match a stage and they are not the same fact. A `stage` norm
 * names this stage in `stages`. A `posture` norm names the posture this stage
 * runs under, because a mode is delivered when a stage declaring it starts -- so
 * a row names a posture, and the mode arrives with the row or nowhere. `path`
 * norms are the query's, and `every-turn` cannot be in this store at all.
 *
 * @param {Array<object>} records every record in both indexes
 * @param {string} stage the stage being entered
 * @param {string[]} postures the postures that stage runs under
 * @returns {Array<object>} the matching records, unordered
 */
function rowFor(records, stage, postures) {
  return records.filter((record) => {
    if (record['fires-when'] === 'stage') return (record.stages || []).includes(stage);
    if (record['fires-when'] === 'posture') return (record.postures || []).some((p) => postures.includes(p));
    return false;
  });
}

/**
 * The row in computed precedence order.
 *
 * Rank first, then firing breadth, then the record's own id. **The order is
 * computed, so the filesystem cannot vote**: a row ordered by what the store
 * happened to yield would put the binding records wherever a rename left them,
 * and reordering the store would silently reorder what a stage reads. The id is
 * the tiebreak because it is the one property of a record that is stable across
 * every edit that does not delete it.
 *
 * @param {Array<object>} records the row's records
 * @returns {Array<object>} the same records, ordered
 */
function inPrecedenceOrder(records) {
  const key = (record) => [
    record.rank === undefined ? Number.MAX_SAFE_INTEGER : record.rank,
    record.breadth === undefined ? Number.MAX_SAFE_INTEGER : record.breadth,
  ];
  return records.slice().sort((one, other) => {
    const [rankOne, breadthOne] = key(one);
    const [rankOther, breadthOther] = key(other);
    if (rankOne !== rankOther) return rankOne - rankOther;
    if (breadthOne !== breadthOther) return breadthOne - breadthOther;
    return one.id < other.id ? -1 : one.id > other.id ? 1 : 0;
  });
}

/**
 * Cut the row into the fewest chunks that each stay under the cap.
 *
 * @param {string[]} pieces each record's text, in order
 * @returns {string[]} the chunks, in order
 */
function intoChunks(pieces) {
  const chunks = [];
  let current = '';
  for (const piece of pieces) {
    if (current === '') {
      current = piece;
      continue;
    }
    if (current.length + SEPARATOR.length + piece.length > CHUNK_CAP) {
      chunks.push(current);
      current = piece;
      continue;
    }
    current += SEPARATOR + piece;
  }
  if (current !== '') chunks.push(current);
  return chunks;
}

// ------------------------------------------------------------------ assembly

/**
 * Assemble the row.
 *
 * @param {{root: string, stage: string, framework: string|null}} options
 * @returns {{problems: string[], chunks: string[], plan: string[]}}
 */
function assemble(options) {
  const { root, stage, framework } = options;
  const problems = [];

  const knowledgeStore = path.join(root, '.claude', 'knowledge');
  const own = readIndex(path.join(root, '.claude', 'position', 'ledger.json'));
  if (own === null) {
    return { problems: [`no index under ${path.join(root, '.claude', 'position')}`], chunks: [], plan: [] };
  }

  // The framework store's *text*, not just its index -- a row is the records
  // themselves, and a copied index carries their sizes rather than their words.
  const frameworkRecords = framework
    ? readIndex(path.join(root, '.claude', 'position', 'framework-ledger.json')) || []
    : [];

  const { postures, found, at } = posturesOfStage(root, stage);
  if (!found) problems.push(`no router at ${at}, and a stage's postures are read from its table`);
  else if (postures.length === 0) problems.push(`no router row names the stage "${stage}"`);

  const sources = [
    ...own.map((record) => ({ record, store: knowledgeStore })),
    ...frameworkRecords.map((record) => ({ record, store: framework })),
  ];
  const selected = rowFor(
    sources.map((entry) => entry.record),
    stage,
    postures,
  );
  const storeOf = new Map(sources.map((entry) => [entry.record.id, entry.store]));

  const pieces = [];
  for (const record of inPrecedenceOrder(selected)) {
    const found = textOf(storeOf.get(record.id), record);
    if (found.missing !== undefined) {
      // The ledger and the store disagreeing is the one fault that would deliver
      // a quietly shorter row, so it stops the assembly rather than skipping a
      // record. A stage cannot tell a norm that was dropped from one that never
      // fired for it.
      problems.push(
        found.missing === 'file'
          ? `${found.at} is not there, and ${record.id} is in the index`
          : `${found.at} carries no heading for the anchor "${record.anchor}", and ${record.id} is in the index`,
      );
      continue;
    }
    const text = found.text;
    // A record larger than one substitution cannot be delivered whole and cannot
    // be split without cutting a norm in half. Reported rather than truncated:
    // a shorter row reads as a shorter row, which is the silent failure the whole
    // chunking scheme exists to avoid.
    if (text.length > CHUNK_CAP) {
      problems.push(`${record.id} is ${text.length} characters, over the ${CHUNK_CAP} a single substitution carries`);
    }
    pieces.push(text);
  }

  if (problems.length > 0) return { problems, chunks: [], plan: [] };

  const header = framework
    ? `# The row for /${stage}`
    : `# The row for /${stage}, from this repository's records alone`;
  const chunks = intoChunks([header, ...pieces]);
  const plan = [
    `stage: ${stage}`,
    `records: ${pieces.length}`,
    `chunks: ${chunks.length}`,
    ...chunks.map((chunk, index) => `  ${index}  ${chunk.length} characters`),
  ];
  return { problems, chunks, plan };
}

// ---------------------------------------------------------------------- entry

/** Every argument this script takes, and the option each one sets. */
const ARGUMENTS = {
  '--stage': 'stage',
  '--root': 'root',
  '--framework': 'framework',
  '--chunk': 'chunk',
};

function parseArguments(argv) {
  const options = { stage: null, root: process.cwd(), framework: null, chunk: null };
  const problems = [];
  for (let i = 0; i < argv.length; i += 1) {
    const field = ARGUMENTS[argv[i]];
    if (field === undefined) {
      problems.push(`"${argv[i]}" is not an argument this script takes`);
      continue;
    }
    const value = argv[i + 1];
    if (value === undefined || ARGUMENTS[value] !== undefined) {
      problems.push(`${argv[i]} was given no value`);
      continue;
    }
    options[field] = value;
    i += 1;
  }
  if (options.stage === null) problems.push('--stage was not given, and a row is assembled for a stage');
  if (options.chunk !== null && !/^\d+$/.test(options.chunk)) {
    problems.push(`--chunk "${options.chunk}" is not a chunk number`);
  }
  options.root = path.resolve(options.root);
  if (options.framework) options.framework = path.resolve(options.framework);
  return { options, problems };
}

function main(argv) {
  const { options, problems } = parseArguments(argv);
  if (problems.length > 0) {
    process.stderr.write(`the row was not assembled: ${problems.length} to answer for\n`);
    for (const problem of problems) process.stderr.write(`  ${problem}\n`);
    return 1;
  }

  const result = assemble(options);
  if (result.problems.length > 0) {
    process.stderr.write(`the row was not assembled: ${result.problems.length} to answer for\n`);
    for (const problem of result.problems) process.stderr.write(`  ${problem}\n`);
    return 1;
  }

  if (options.chunk === null) {
    process.stdout.write(`${result.chunks.join(SEPARATOR)}\n`);
    process.stderr.write(`${result.plan.join('\n')}\n`);
    return 0;
  }

  // A chunk past the end is emitted as nothing rather than refused: a skill
  // carries a fixed number of substitution slots and a row does not, so the
  // slots beyond the row's end are the ordinary case rather than a fault.
  const index = Number(options.chunk);
  process.stdout.write(index < result.chunks.length ? `${result.chunks[index]}\n` : '');
  return 0;
}

process.exitCode = main(process.argv.slice(2));
