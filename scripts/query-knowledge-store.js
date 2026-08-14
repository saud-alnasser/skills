'use strict';

// The store query.
//
// Answers filters over the store's declared fields, and nothing else.
//
//   node .claude/scripts/query-knowledge-store.js type=decision
//   node .claude/scripts/query-knowledge-store.js fires-when=stage stages=implement
//   node .claude/scripts/query-knowledge-store.js paths=src/db/schema.ts
//   node .claude/scripts/query-knowledge-store.js type=
//
// Three arguments take a value, and every other argument is a filter:
//
//   --root <dir>              the repository root. Everything else is computed
//                             from it, so a run never depends on the working
//                             directory. Defaults to the working directory.
//   --ledger <path>           the repository's index. Defaults to
//                             `.claude/position/ledger.json` under the root.
//   --framework-ledger <path> the framework store's index, copied out of the
//                             plugin when the repository was configured.
//                             Defaults to `framework-ledger.json` beside the
//                             other, and its absence is not an error -- an
//                             unconfigured repository has one store.
//
// A filter is `field=value`. A filter whose value is empty enumerates that
// field's distinct values instead, which is how the vocabulary is discoverable
// from the surface rather than remembered.
//
// **There is no free-text parameter, and that is the surface rather than a
// restriction on it.** A filter over declared fields that matches nothing has
// made a true statement about the store; a search that finds nothing has only
// failed to find something, and a caller can act on the first and can only
// guess at the second. So an argument that does not parse as `field=value` is
// refused rather than interpreted, and so is a field no record declares.
//
// Exit 0 the query was answered -- including when it matched nothing -- and 1 it
// was refused. **An empty answer and a refusal never share an exit code**: if
// they did they would be one answer from the caller's side, which is the
// collapse this whole design is against.
//
// Everything this script emits, on either stream, is ASCII. Emitted output is
// captured through whatever console encoding the shell happens to have, and a
// non-ASCII character does not survive one that is not UTF-8 -- it arrives as a
// question mark, in output that still looks well-formed. A record's heading is
// data rather than something this script chose, so the answer is escaped rather
// than assumed clean.

const fs = require('fs');
const path = require('path');

/**
 * The fields a reader looks for first, listed before the rest.
 *
 * Ordering only. Nothing here decides what may be filtered on: excluding a
 * declared field would be this script deciding what the store may be asked,
 * which is the list-in-the-script the design refuses.
 */
const FIELD_ORDER = ['type', 'owner', 'fires-when', 'stages', 'postures', 'paths', 'store'];

/**
 * The one field whose declared values are patterns rather than values.
 *
 * A path-scoped norm declares the globs it covers and a caller holds a path, so
 * equality cannot join them: the only filter that would match is one naming the
 * pattern the caller was trying to discover. **This is not a search.** A path is
 * a fact about the filesystem and coverage by a glob is exact set membership --
 * there is no ranking, no threshold, and no record that nearly matched. What
 * makes it safe is that the pattern comes from the record and the path comes
 * from the caller; neither side is phrasing.
 */
const PATTERN_FIELD = 'paths';

/** The field an edge-depth record declares its edge in, and its distance in. */
const EDGE_FIELD = 'edge';
const CLOSES_FIELD = 'closes';

/** The `closes` value meaning *while the chain continues*. */
const CLOSES_FULLY = 'fully';

/**
 * The two labels a returned conflict carries.
 *
 * A conflict is returned rather than resolved, so the label says what kind of
 * thing the caller is looking at rather than which record won. A departure from
 * framework law that was declared is legitimate and reported until it is
 * removed; the same contradiction inside one store is nobody's decision.
 */
const DECLARED_DEVIATION = 'declared-deviation';
const UNDECLARED_DEFECT = 'undeclared-defect';

/** The edge a repository declares when it departs from framework law. */
const DEVIATION_EDGE = 'deviates-from';

// ------------------------------------------------------------------- reading

/**
 * Read one index, or nothing where it is not there.
 *
 * @param {string} at absolute path to a ledger
 * @returns {Array<object>|null} its records, or `null` when the file is absent
 */
function readIndex(at) {
  if (!fs.existsSync(at)) return null;
  const ledger = JSON.parse(fs.readFileSync(at, 'utf8').replace(/^\uFEFF/, ''));
  return Array.isArray(ledger.records) ? ledger.records : [];
}

/**
 * Every field any record in the index declares.
 *
 * **Taken from the records rather than from a list here.** A field the record
 * format gains becomes filterable with no edit to this script, and a field
 * nothing declares cannot be quietly accepted -- which is what makes a refusal
 * a statement about the store instead of a statement about this file.
 *
 * @param {Array<object>} records every record in the index
 * @returns {string[]} the field names, the ones a reader looks for first, then
 *   the rest alphabetically
 */
function declaredFields(records) {
  const found = new Set();
  for (const record of records) for (const key of Object.keys(record)) found.add(key);
  const known = FIELD_ORDER.filter((field) => found.has(field));
  const rest = [...found].filter((field) => !known.includes(field)).sort();
  return [...known, ...rest];
}

/**
 * Whether a glob covers a path.
 *
 * `**` spans directory separators, `*` and `?` do not. Anchored at both ends,
 * because an unanchored pattern matches at every depth and a rule scoped to
 * `src/db/` would then cover `vendor/src/db/`.
 *
 * @param {string} pattern a glob as a record declares it
 * @param {string} candidate a path as a caller holds it, with forward slashes
 * @returns {boolean} whether the pattern covers the path
 */
function covers(pattern, candidate) {
  let expression = '';
  for (let i = 0; i < pattern.length; i += 1) {
    const character = pattern[i];
    if (character === '*') {
      if (pattern[i + 1] === '*') {
        expression += '.*';
        i += 1;
        // A separator right after `**` is absorbed, so `src/**` covers `src/`
        // itself as well as everything under it -- a pattern naming a directory
        // that failed to cover the directory would be a surprise nobody could
        // see in the pattern.
        if (pattern[i + 1] === '/') i += 1;
      } else {
        expression += '[^/]*';
      }
      continue;
    }
    if (character === '?') {
      expression += '[^/]';
      continue;
    }
    expression += character.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }
  return new RegExp(`^${expression}$`).test(candidate);
}

/**
 * Whether a record carries this value in this field.
 *
 * A list field matches when it *contains* the value and a scalar when it equals
 * it. Both are exact. The pattern field is the one place a declared value is
 * also read as a glob over the given one -- and equality is still tried first,
 * so a caller who does know the pattern can still name it.
 *
 * @param {object} record one record
 * @param {string} field the field to read
 * @param {string} value the value to match
 * @returns {boolean} whether it matches
 */
function carries(record, field, value) {
  const held = record[field];
  if (held === undefined) return false;
  const entries = Array.isArray(held) ? held : [held];
  return entries.some((entry) => {
    if (String(entry) === value) return true;
    return field === PATTERN_FIELD && covers(String(entry), value);
  });
}

/**
 * Every distinct value a field takes across the store, with how many records
 * take each.
 *
 * The count is what separates a value one record carries by accident from a
 * value the store actually uses, and it costs nothing to compute here.
 *
 * @param {Array<object>} records every record in the index
 * @param {string} field the field to enumerate
 * @returns {Array<{value: string, records: number}>} sorted by value
 */
function distinctValues(records, field) {
  const counts = new Map();
  for (const record of records) {
    const held = record[field];
    if (held === undefined) continue;
    for (const entry of Array.isArray(held) ? held : [held]) {
      const value = String(entry);
      counts.set(value, (counts.get(value) || 0) + 1);
    }
  }
  return [...counts.entries()]
    .sort((a, b) => (a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0))
    .map(([value, count]) => ({ value, records: count }));
}

// ------------------------------------------------------------------- closure

/**
 * How far each edge type closes, read from the records that declare it.
 *
 * **Not carried in this script.** A number here would be a second home free to
 * disagree with the one a reader would edit, and the whole point of depth being
 * a property of the edge type is that each figure is a fact about what that
 * edge means rather than one somebody tuned.
 *
 * @param {Array<object>} records every record in the index
 * @returns {{depths: Map<string, number>, refusals: string[]}} a `closes`
 *   nobody can read is refused rather than defaulted: a default would walk some
 *   distance the store never declared and return the result as though it had
 */
function readDepths(records) {
  const depths = new Map();
  const refusals = [];
  for (const record of records) {
    const edge = record[EDGE_FIELD];
    if (edge === undefined) continue;
    const closes = record[CLOSES_FIELD];
    if (closes === CLOSES_FULLY) {
      depths.set(edge, Infinity);
      continue;
    }
    if (typeof closes === 'string' && /^\d+$/.test(closes)) {
      depths.set(edge, Number(closes));
      continue;
    }
    refusals.push(
      `${record.file}  ${CLOSES_FIELD} "${closes === undefined ? '(none declared)' : closes}" is neither ` +
        `"${CLOSES_FULLY}" nor a number of hops`,
    );
  }
  return { depths, refusals };
}

/**
 * What the matched records' declared edges reach.
 *
 * **Computed here rather than returned as ids for the caller to fetch.** Each
 * hop would otherwise be a model decision, and not following an edge would be
 * indistinguishable from there being nothing to follow.
 *
 * Distance is counted per edge type rather than over the walk as a whole, which
 * is what makes each declared number a statement about its own edge: raising one
 * reaches further along that edge and exactly as far as before along every
 * other.
 *
 * @param {Array<object>} matches the records the filters selected
 * @param {Map<string, object>} byId every record in the index, keyed by id
 * @param {Map<string, number>} depths how far each edge type closes
 * @returns {{closure: Array<object>, refusals: string[]}} an edge no record
 *   declares a depth for is refused rather than skipped, for the reason the
 *   closure exists at all: a walk that quietly stopped would be
 *   indistinguishable from one with nowhere to go
 */
function closureOf(matches, byId, depths) {
  const closure = [];
  const refusals = [];
  const seen = new Set(matches.map((record) => record.id));

  let frontier = matches.map((record) => ({ record, used: {} }));
  while (frontier.length > 0) {
    const next = [];
    for (const { record, used } of frontier) {
      for (const [edge, targets] of Object.entries(record.edges || {})) {
        if (!depths.has(edge)) {
          refusals.push(`${record.id} declares the edge "${edge}" and no record declares how far it closes`);
          continue;
        }
        const spent = used[edge] || 0;
        if (spent >= depths.get(edge)) continue;
        for (const target of targets) {
          // A target this index does not carry is not this script's to report.
          // The build resolves every edge it can see, and the one it cannot --
          // a deviation into the framework store of a repository that has not
          // copied its index -- is reported by that build on every run.
          // Refusing here would put a wall in front of a caller who cannot act
          // on it and did not ask about it.
          const reached = byId.get(target);
          if (reached === undefined || seen.has(target)) continue;
          seen.add(target);
          closure.push({ 'reached-by': edge, 'reached-from': record.id, record: reached });
          next.push({ record: reached, used: { ...used, [edge]: spent + 1 } });
        }
      }
    }
    frontier = next;
  }

  return { closure, refusals };
}

// ----------------------------------------------------------------- conflicts

/**
 * The binding records among the matches that could both apply.
 *
 * **Returned rather than resolved.** Applying the rank here and handing back one
 * record would suppress the obligation that a decision-versus-norm conflict is
 * productive -- the norm is amended in the same change rather than quietly
 * losing to a comparison nobody saw.
 *
 * Only records of *different* ranks are paired. Two norms at one rank are
 * ordered by firing breadth rather than in conflict, so pairing them would
 * report the corpus's ordinary shape as a defect.
 *
 * @param {Array<object>} matches the records the filters selected
 * @returns {Array<object>} each conflict, with both records, both ranks, and a
 *   label
 */
function conflictsAmong(matches) {
  const binders = matches.filter((record) => record.rank !== undefined);
  const conflicts = [];
  for (let i = 0; i < binders.length; i += 1) {
    for (let j = i + 1; j < binders.length; j += 1) {
      const one = binders[i];
      const other = binders[j];
      if (one.rank === other.rank) continue;
      const declared =
        one.store !== other.store &&
        [one, other].some((record) =>
          ((record.edges || {})[DEVIATION_EDGE] || []).some((target) => [one.id, other.id].includes(target)),
        );
      conflicts.push({
        label: declared ? DECLARED_DEVIATION : UNDECLARED_DEFECT,
        records: [one, other].map((record) => ({
          id: record.id,
          file: record.file,
          store: record.store,
          rank: record.rank,
        })),
      });
    }
  }
  return conflicts;
}

// ------------------------------------------------------------------- writing

/**
 * The answer as ASCII JSON.
 *
 * `JSON.stringify` leaves non-ASCII characters as themselves, and a record's
 * heading is data this script did not choose -- so the escape happens here
 * rather than being assumed away. The escaped form is what JSON already means,
 * so nothing is lost by it.
 *
 * @param {object} answer the answer object
 * @returns {string} its JSON, with every character above ASCII escaped
 */
function asAscii(answer) {
  return JSON.stringify(answer, null, 2).replace(/[^\x00-\x7f]/g, (character) =>
    `\\u${character.charCodeAt(0).toString(16).padStart(4, '0')}`,
  );
}

// ------------------------------------------------------------------ the query

/**
 * Answer the filters, or say why they were refused.
 *
 * @param {{ledgerPath: string, frameworkLedgerPath: string, filters: Array<{field: string, value: string}>}} options
 * @returns {{refusals: string[], answer: object|null}} a refusal names what it
 *   expected, because a caller who typed a phrase needs to learn that the
 *   surface takes none rather than that this phrase found nothing
 */
function query(options) {
  const { ledgerPath, frameworkLedgerPath, filters } = options;

  const own = readIndex(ledgerPath);
  if (own === null) {
    return { refusals: [`no index at ${ledgerPath}; build it with build-knowledge-store.js`], answer: null };
  }

  // The framework store's index is copied out of the plugin when a repository is
  // configured, because a stage's shell cannot resolve the plugin's root. Its
  // absence is a fact rather than a fault: an unconfigured repository has one
  // store, and every record carries which store it belongs to, so the two never
  // blur once both are here.
  const framework = readIndex(frameworkLedgerPath) || [];
  const records = [...own, ...framework];
  const fields = declaredFields(records);

  // Named before anything is matched, so a caller who misspelt one field and
  // got the other right learns about the misspelling rather than about an empty
  // result -- which would be a true statement about a query nobody meant.
  const undeclared = filters.filter((filter) => !fields.includes(filter.field));
  if (undeclared.length > 0) {
    return {
      refusals: undeclared.map(
        (filter) => `no record declares the field "${filter.field}"; declared: ${fields.join(', ')}`,
      ),
      answer: null,
    };
  }

  const stores = { knowledge: own.length, framework: framework.length };

  // A filter with no value asks what values the field takes. It is the same
  // grammar rather than a second one, which is what keeps the vocabulary
  // discoverable without adding a surface that could drift from the filters.
  const enumerations = filters.filter((filter) => filter.value === '');
  if (enumerations.length > 0) {
    return {
      refusals: [],
      answer: {
        stores,
        fields,
        enumerated: enumerations.map((filter) => ({
          field: filter.field,
          values: distinctValues(records, filter.field),
        })),
      },
    };
  }

  const { depths, refusals: unreadable } = readDepths(records);
  if (unreadable.length > 0) return { refusals: unreadable, answer: null };

  const matches = records.filter((record) =>
    filters.every((filter) => carries(record, filter.field, filter.value)),
  );

  const byId = new Map(records.map((record) => [record.id, record]));
  const { closure, refusals } = closureOf(matches, byId, depths);
  if (refusals.length > 0) return { refusals, answer: null };

  return {
    refusals: [],
    answer: {
      stores,
      fields,
      filters: filters.map((filter) => `${filter.field}=${filter.value}`),
      // Stated rather than left to be inferred from the length of a list: a
      // caller reading a preview of a large answer sees this before it sees the
      // records, and an empty result is the answer this surface exists to give.
      empty: matches.length === 0,
      matches,
      closure,
      conflicts: conflictsAmong(matches),
    },
  };
}

// ---------------------------------------------------------------------- entry

/** The arguments that take a value, and the option each one sets. */
const ARGUMENTS = {
  '--root': 'root',
  '--ledger': 'ledgerPath',
  '--framework-ledger': 'frameworkLedgerPath',
};

/**
 * Read the command line.
 *
 * Everything that is not one of the arguments above must parse as
 * `field=value`. **A bare phrase is what a caller reaching for a search would
 * type**, so refusing it by name is what makes "no free text" a property of the
 * surface rather than a sentence about it.
 *
 * @param {string[]} argv the arguments after the script's own name
 * @returns {{options: object, filters: Array<{field: string, value: string}>, problems: string[]}}
 */
function parseArguments(argv) {
  const options = { root: process.cwd(), ledgerPath: null, frameworkLedgerPath: null };
  const filters = [];
  const problems = [];
  const loose = [];

  for (let i = 0; i < argv.length; i += 1) {
    const argument = argv[i];
    const field = ARGUMENTS[argument];
    if (field !== undefined) {
      const value = argv[i + 1];
      // A flag standing where a value should be is a missing value rather than
      // a value that happens to look like a flag.
      if (value === undefined || ARGUMENTS[value] !== undefined) {
        problems.push(`${argument} was given no value`);
        continue;
      }
      options[field] = value;
      i += 1;
      continue;
    }
    if (argument.startsWith('--')) {
      problems.push(`"${argument}" is not an argument this script takes`);
      continue;
    }
    const match = argument.match(/^([A-Za-z][\w-]*)=(.*)$/);
    if (!match) {
      loose.push(argument);
      continue;
    }
    filters.push({ field: match[1], value: match[2].trim() });
  }

  // Reported as one problem rather than one per word, because the words are one
  // phrase somebody typed and naming each of them reads as five faults.
  if (loose.length > 0) {
    problems.push(
      `this surface takes no free text, only field=value filters; it was given "${loose.join(' ')}"`,
    );
  }
  if (problems.length === 0 && filters.length === 0) {
    problems.push('no filter was given, and this surface answers filters');
  }

  options.root = path.resolve(options.root);
  const inPosition = (name) => path.join(options.root, '.claude', 'position', name);
  options.ledgerPath = options.ledgerPath ? path.resolve(options.ledgerPath) : inPosition('ledger.json');
  options.frameworkLedgerPath = options.frameworkLedgerPath
    ? path.resolve(options.frameworkLedgerPath)
    : inPosition('framework-ledger.json');
  return { options, filters, problems };
}

function main(argv) {
  const { options, filters, problems } = parseArguments(argv);
  if (problems.length > 0) {
    process.stderr.write(`the query was refused: ${problems.length} to answer for\n`);
    for (const problem of problems) process.stderr.write(`  ${problem}\n`);
    return 1;
  }

  const result = query({
    ledgerPath: options.ledgerPath,
    frameworkLedgerPath: options.frameworkLedgerPath,
    filters,
  });
  if (result.refusals.length > 0) {
    process.stderr.write(`the query was refused: ${result.refusals.length} to answer for\n`);
    for (const refusal of result.refusals) process.stderr.write(`  ${refusal}\n`);
    return 1;
  }

  process.stdout.write(`${asAscii(result.answer)}\n`);
  return 0;
}

process.exitCode = main(process.argv.slice(2));
