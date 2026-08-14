// The build. Asserts that what this repository ships adheres to `specs.md`.
//
// It reads `skills/`, `agents/`, `scripts/` and `specs.md`, and never the
// protocol directory of the repository it is running in. Why that boundary
// exists is a standard this repository documents; what is here is the
// mechanism, in `resolveShipped` below.
//
// A fixture that has to run a shipped script needs a tree to run it against,
// and the resolver refuses every path outside the repository — so those build a
// throwaway store under the operating system's temp directory, through the
// helpers in `build/fixtures/`. Each of those modules states its own bound.
//
// Coverage is partial and being rebuilt one ticket at a time — a ticket with no
// group is one nobody has written assertions for, not one with nothing to assert.
//
//   node build/verify.js                        every group
//   node build/verify.js --ticket conversion/01  one group
//
// Exit 0 all passed, 1 something failed, 2 the named group does not exist.

'use strict';

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const SKILLS = 'skills';
const AGENTS = 'agents';
const SCRIPTS = 'scripts';
const KNOWLEDGE = 'knowledge';

// ---------------------------------------------------------------- primitives

/** The protocol directory of whatever repository this build runs in. */
const PROTOCOL_DIRECTORY = '.claude';

/**
 * Resolve a repository-relative path, refusing anything outside the shipped tree.
 *
 * **Every path this build reads inside the repository goes through here**, which
 * is what makes the scope structural rather than asserted. A build that only
 * asserted its own scope would be checking a claim about itself, and the next
 * author steps over that and updates the claim; a resolver cannot be bypassed
 * without deleting it.
 *
 * One kind of thing sits outside it, and is named here rather than exempted
 * there: a fixture under `build/fixtures/` builds a throwaway repository in a
 * temporary directory and runs a shipped script inside it. Its subject is a
 * repository that is not this one, so a resolver refusing everything outside
 * this one has nothing to say about it — and the shipped path such a fixture
 * runs is resolved through here before it is handed over. What this refuses is
 * unchanged; the claim above is scoped to what it can speak for.
 *
 * The path is resolved before it is judged, so `./.claude/x` and
 * `skills/../.claude/x` are refused along with the literal form — a prefix test
 * on the raw string catches only the spelling somebody happened to try.
 *
 * @param {string} relative path from the repository root
 * @returns {string} the absolute path
 * @throws {Error} when it names the protocol directory, or escapes the repository
 */
function resolveShipped(relative) {
  const absolute = path.resolve(ROOT, relative);
  const inside = path.relative(ROOT, absolute).split(path.sep).join('/');
  // The empty string is the repository root itself, which is a legitimate
  // directory to list and is refused by `readFileSync` on its own if read.
  if (inside === '..' || inside.startsWith('../') || path.isAbsolute(inside)) {
    throw new Error(`this build does not read outside the repository: ${relative}`);
  }
  if (inside === PROTOCOL_DIRECTORY || inside.startsWith(`${PROTOCOL_DIRECTORY}/`)) {
    throw new Error(`this build does not read the protocol directory: ${inside}`);
  }
  return absolute;
}

function read(relative) {
  return fs.readFileSync(resolveShipped(relative), 'utf8');
}

function entries(relative) {
  return fs.readdirSync(resolveShipped(relative), { withFileTypes: true });
}

/** Every `*.md` under `dir`, recursively, as paths relative to the repository root. */
function markdownUnder(dir) {
  const out = [];
  const walk = (d) => {
    for (const entry of entries(d)) {
      const full = `${d}/${entry.name}`;
      if (entry.isDirectory()) walk(full);
      else if (entry.name.endsWith('.md')) out.push(full);
    }
  };
  walk(dir);
  return out.sort();
}

/**
 * The frontmatter fields this build reads, and no more.
 *
 * Deliberately not a YAML parser. It handles the shapes the shipped surfaces
 * actually use — top-level scalars, and a `metadata:` block carrying `mode:` and
 * an inline `policies:` array — and returns `null` for a file with no
 * frontmatter, which is a fact a caller acts on rather than an error.
 */
function frontmatter(relative) {
  const text = read(relative);
  if (!text.startsWith('---\n')) return null;
  const end = text.indexOf('\n---', 4);
  if (end === -1) return null;

  const fields = { metadata: {} };
  let inMetadata = false;

  for (const line of text.slice(4, end).split('\n')) {
    if (/^\s*$/.test(line) || /^\s*#/.test(line)) continue;
    const indented = /^\s/.test(line);
    const match = line.match(/^\s*([A-Za-z][\w-]*):\s*(.*)$/);
    if (!match) continue;
    const [, key, rawValue] = match;
    const value = rawValue.trim();

    if (!indented) {
      inMetadata = key === 'metadata';
      if (!inMetadata) fields[key] = value;
      continue;
    }
    if (inMetadata) fields.metadata[key] = value;
  }
  return fields;
}

/** An inline YAML array — `[a, b]` or `["*"]` — as a list of bare strings. */
function inlineList(value) {
  if (!value || !value.startsWith('[')) return [];
  return value
    .slice(1, value.lastIndexOf(']'))
    .split(',')
    .map((item) => item.trim().replace(/^["']|["']$/g, ''))
    .filter(Boolean);
}

// ------------------------------------------------------------- the assertions

const groups = new Map();

/** Register one group of assertions under the ticket that introduced them. */
function ticket(id, description, define) {
  const checks = [];
  define((name, run) => checks.push({ name, run }));
  groups.set(id, { description, checks });
}

const SHIPPED_MARKDOWN = () => [
  ...markdownUnder(SKILLS),
  ...markdownUnder(AGENTS),
  ...markdownUnder(KNOWLEDGE),
];

/**
 * Every shipped file a citation can be written into: the markdown, and the code.
 *
 * A shipped script is read in whatever repository AEP is running in exactly as
 * shipped markdown is, so the citation guards below bind both. Widened rather
 * than duplicated per surface — a standard with two homes drifts at one of them.
 */
/**
 * Every posture the framework store defines.
 *
 * The store is the definition rather than a copy of one: a posture is what a
 * mode record names in `postures`, and the router's Mode column names only the
 * postures some stage runs under — which is fewer, because a skill outside the
 * stage table declares one too.
 */
const SHIPPED_POSTURES = () => {
  const out = new Set();
  for (const file of markdownUnder(KNOWLEDGE)) {
    const fields = frontmatter(file);
    if (!fields || fields['fires-when'] !== 'posture') continue;
    for (const posture of inlineList(fields.postures)) out.add(posture);
  }
  return out;
};

/**
 * Every guide a stage can declare: a stage norm in the store, or a template.
 *
 * Both, because the conversion runs one ticket at a time — the copied guides are
 * records and the derived two are still templates, so a set taken from either
 * alone would report the other half as missing.
 */
/**
 * The directories 2.0 replaces with the store.
 *
 * `rules` is deliberately absent. The boot tier stays files because the harness
 * is the only channel that reaches a clone without the plugin, so a reference to
 * it resolves where it is read -- a guard catching it would press correct text
 * to change, which is how a guard gets rescoped by whoever hits it.
 */
const DEPARTED_AT_TWO = ['modes', 'policies', 'contexts', 'decisions', 'designs', 'evidence', 'tools'];

/**
 * The frontmatter a derived template writes into the record it installs, as lines.
 *
 * A template's own frontmatter describes the template; this is the block it emits,
 * which is the one a repository ends up holding. Null where the template shows no
 * such block, which is a defect its own assertion names rather than one to absorb
 * here by returning an empty list.
 */
const INSTALLED_FRONTMATTER = (file) => {
  const match = read(file).match(/```yaml\n---\n([\s\S]*?)\n---\n```/);
  return match === null ? null : match[1].split('\n');
};

const SHIPPED_GUIDES = () => {
  const out = new Set(
    entries(`${SKILLS}/configure/policies`).map((entry) => entry.name.replace(/\.template\.md$/, '')),
  );
  for (const file of markdownUnder(KNOWLEDGE)) {
    const fields = frontmatter(file);
    if (fields && fields['fires-when'] === 'stage') out.add(fields.subject);
  }
  return out;
};

const SHIPPED_TEXT = () => [
  ...SHIPPED_MARKDOWN(),
  ...entries(SCRIPTS)
    .filter((entry) => entry.isFile() && entry.name.endsWith('.js'))
    .map((entry) => `${SCRIPTS}/${entry.name}`),
];

/**
 * Every path this corpus states a file is written to.
 *
 * A destination is not any mention of a path — the skills cite the records they
 * read on nearly every page, and a guard counting those would fire on correct
 * text. It is the two idioms the configuration stage writes a destination in: a
 * leading bold clause that is the path and nothing else, and an install sentence
 * naming one. **The bound is the form** — a destination written some third way
 * is not seen — which is why the callers below assert over what this returns
 * rather than over a claim that it returns everything.
 *
 * @returns {Array<{at: string, target: string}>} each destination with its site
 */
const DESTINATIONS = () => {
  const leadingBold = /^(?:[-*]\s+|#{1,6}\s+)?\*\*(.+?)\*\*/;
  const install = /\b[Ii]nstall(?:ed)? (?:by \S+ )?(?:at |into )?`([^`]+)`/g;
  const barePath = /^`?(\.claude\/[A-Za-z0-9_*./-]+)`?$/;
  const out = [];
  for (const file of SHIPPED_MARKDOWN()) {
    read(file)
      .split('\n')
      .forEach((line, index) => {
        const targets = new Set();
        const bold = line.match(leadingBold);
        if (bold) {
          const bare = bold[1].trim().match(barePath);
          if (bare) targets.add(bare[1]);
        }
        for (const match of line.matchAll(install)) {
          if (match[1].startsWith('.claude/')) targets.add(match[1]);
        }
        for (const target of targets) out.push({ at: `${file}:${index + 1}`, target });
      });
  }
  return out;
};

ticket('conversion/01', 'the build asserts only what ships', (check) => {
  /** Every listed path is refused, and refused for the stated reason rather than by accident. */
  const refuses = (targets, because) => () => {
    const offending = [];
    for (const target of targets) {
      try {
        read(target);
        offending.push(`${target} — the read was permitted`);
      } catch (error) {
        if (!because.test(error.message)) {
          offending.push(`${target} — refused for the wrong reason: ${error.message}`);
        }
      }
    }
    return offending;
  };

  // The literal spelling is the least interesting case. The others are the ones a
  // prefix test on the raw string would have let through.
  check(
    'the resolver refuses the protocol directory, however it is spelled',
    refuses(
      [
        '.claude',
        '.claude/contexts/repository.md',
        './.claude/contexts/repository.md',
        'skills/../.claude/contexts/repository.md',
        path.join(ROOT, '.claude', 'contexts', 'repository.md'),
      ],
      /does not read the protocol directory/,
    ),
  );

  check(
    'the resolver refuses any path outside the repository',
    refuses(['..', '../elsewhere/x.md', path.resolve(ROOT, '..', 'elsewhere')], /does not read outside the repository/),
  );

  // A file under `skills/`, `agents/`, or `scripts/` is read inside whatever
  // repository AEP is running in — the last of the three is copied into one —
  // so it may name only what exists there. `ADR 0058` and `§21` name
  // this repository's own records; in somebody else's tree an ADR number is worse
  // than a dead link, because theirs are numbered on the same scheme.
  //
  // One assertion per claim. A guard covering two passes when either holds, so
  // deleting one leaves it green — which is how a guard survives the thing it
  // existed to catch.
  //
  // A bare `specs.md` is deliberately unguarded, and the gap is stated rather
  // than left to be discovered: the canonical specification and the shipped guide
  // `policies/specs.md` share a filename, so a guard on the bare name fires on the
  // guide table naming its own rows. A guard that fires on correct content is
  // rescoped by whoever hits it, which erodes faster than a known hole.
  check('shipped text cites no ADR number', () => {
    const offending = [];
    for (const file of SHIPPED_TEXT()) {
      read(file)
        .split('\n')
        .forEach((line, index) => {
          if (/\bADRs? \d{4}\b/.test(line)) offending.push(`${file}:${index + 1}`);
        });
    }
    return offending;
  });

  // The section belongs to whatever the line names, so a line naming no markdown
  // file at all is citing a section of something the reader has to already know —
  // which in practice is this repository's specification.
  check('shipped text carries no section mark with nothing to resolve against', () => {
    const offending = [];
    for (const file of SHIPPED_TEXT()) {
      read(file)
        .split('\n')
        .forEach((line, index) => {
          if (/§\d/.test(line) && !/[\w-]+\.md/.test(line)) offending.push(`${file}:${index + 1}`);
        });
    }
    return offending;
  });

  // The upstream licence binds copies and substantial portions, not shapes. So
  // this fails in both directions: attributing where nothing was copied asserts
  // an obligation that does not exist, exactly as omitting a required one denies
  // one that does.
  check('vendored files carry attribution, and only those', () => {
    const vendored = new Set([
      'skills/codebase-design/SKILL.md',
      'skills/domain-modeling/SKILL.md',
      'skills/grilling/SKILL.md',
      'skills/review/SMELLS.md',
      'skills/tdd/SKILL.md',
    ]);
    const offending = [];
    for (const file of SHIPPED_MARKDOWN()) {
      const attributed = /Vendored from \[mattpocock\/skills\]/.test(read(file));
      if (attributed && !vendored.has(file)) offending.push(`${file} — attributed but not vendored`);
      if (!attributed && vendored.has(file)) offending.push(`${file} — vendored but not attributed`);
    }
    return offending;
  });

  check('a user-invoked skill takes a one-word name', () => {
    const offending = [];
    for (const file of markdownUnder(SKILLS).filter((f) => f.endsWith('/SKILL.md'))) {
      const fields = frontmatter(file);
      if (!fields || fields['disable-model-invocation'] !== 'true') continue;
      if (/[\s-]/.test(fields.name)) offending.push(`${file} — ${fields.name}`);
    }
    return offending;
  });

  // A model-invoked skill's description is the entire basis on which it is
  // selected, so a description that says what the skill *is* and never when to
  // reach for it cannot be selected against.
  check('a model-invoked skill states when to use it', () => {
    const offending = [];
    for (const file of markdownUnder(SKILLS).filter((f) => f.endsWith('/SKILL.md'))) {
      const fields = frontmatter(file);
      if (!fields || fields['disable-model-invocation'] === 'true') continue;
      if (!/\bUse when\b/.test(fields.description || '')) offending.push(file);
    }
    return offending;
  });

  // These are the layouts AEP migrates away from. A shipped file naming one is
  // either a bug or a migration row, and only the two files whose job is
  // detecting and converting them may name one.
  check('nothing shipped names a pre-migration path', () => {
    const legacy = /CONTEXT\.md|CONTEXT-MAP\.md|docs\/adr\/|\.scratch\/|\.claude\/docs\//;
    const exempt = new Set(['skills/configure/SKILL.md', 'skills/configure/MIGRATION.md']);
    const offending = [];
    for (const file of SHIPPED_MARKDOWN()) {
      if (exempt.has(file)) continue;
      read(file)
        .split('\n')
        .forEach((line, index) => {
          if (legacy.test(line)) offending.push(`${file}:${index + 1}`);
        });
    }
    return offending;
  });

  check('every skill and agent declares a posture that ships', () => {
    const postures = SHIPPED_POSTURES();
    const offending = [];
    const declaring = [
      ...markdownUnder(SKILLS).filter((f) => f.endsWith('/SKILL.md')),
      ...markdownUnder(AGENTS),
    ];
    for (const file of declaring) {
      const fields = frontmatter(file);
      const mode = fields && fields.metadata.mode;
      if (!mode) offending.push(`${file} — declares no posture`);
      else if (!postures.has(mode)) offending.push(`${file} — ${mode}`);
    }
    return offending;
  });

  // The skill's line is the framework's default and the router's row is the
  // instance; the containment runs one way, so the row carries at least what the
  // skill declares. A guide a skill declares and its row omits is a defect in
  // the release rather than something a repository repairs locally.
  check("a skill's declared guides are contained in its router row", () => {
    const table = new Map();
    for (const line of read('skills/configure/protocol.template.md').split('\n')) {
      const match = line.match(/^\|\s*`\/([a-z]+)`\s*\|\s*[a-z]+\s*\|\s*(.*?)\s*\|\s*$/);
      if (match) table.set(match[1], match[2]);
    }
    const offending = [];
    for (const file of markdownUnder(SKILLS).filter((f) => f.endsWith('/SKILL.md'))) {
      const fields = frontmatter(file);
      if (!fields) continue;
      const declared = inlineList(fields.metadata.policies);
      if (declared.length === 0) continue;
      // Containment binds the stages the router names rows for. A Primitive is
      // reached from inside a running stage rather than routed to, so it has no
      // row to be contained by and declaring guides is not a defect in one.
      const row = table.get(fields.name);
      if (row === undefined || declared.includes('*')) continue;
      // The row names subjects rather than paths, so containment is set
      // membership rather than substring search. A substring test over the old
      // form would also have matched `context` inside `version-control`; the
      // token boundary is what the backticks buy.
      const named = new Set([...row.matchAll(/`([a-z-]+)`/g)].map((match) => match[1]));
      for (const guide of declared) {
        if (!named.has(guide)) offending.push(`${file} — ${guide} is absent from the row`);
      }
    }
    return offending;
  });

  // The two assertions below are the ones that read the specification itself.
  // Everything above transcribes a standard this repository documents; these
  // check the shipped tree against the document it claims to conform to, which
  // is what stops the two drifting while every other assertion stays green.
  check('the posture set the specification names is the posture set that ships', () => {
    const specification = read('specs.md');
    const section = specification.slice(specification.indexOf('\n## 9. Modes'), specification.indexOf('\n## 10.'));
    const named = new Set(
      [...section.matchAll(/^- \*\*([A-Za-z]+)\*\* —/gm)].map((match) => match[1].toLowerCase()),
    );
    const shipped = SHIPPED_POSTURES();
    const offending = [];
    for (const posture of named) if (!shipped.has(posture)) offending.push(`${posture} — named, never ships`);
    for (const posture of shipped) if (!named.has(posture)) offending.push(`${posture} — ships, never named`);
    return offending;
  });

  check('every stage the router names ships as a skill', () => {
    const stages = [...read('skills/configure/protocol.template.md').matchAll(/^\|\s*`\/([a-z]+)`\s*\|/gm)].map(
      (match) => match[1],
    );
    const shipped = new Set(
      markdownUnder(SKILLS)
        .filter((file) => file.endsWith('/SKILL.md'))
        .map((file) => (frontmatter(file) || {}).name),
    );
    const offending = stages.filter((stage) => !shipped.has(stage)).map((stage) => `/${stage}`);
    if (stages.length === 0) offending.push('the router template names no stage at all — the table was not parsed');
    return offending;
  });

  check('every declared guide ships as a record or a template', () => {
    const shipped = SHIPPED_GUIDES();
    const offending = [];
    for (const file of markdownUnder(SKILLS).filter((f) => f.endsWith('/SKILL.md'))) {
      const fields = frontmatter(file);
      if (!fields) continue;
      for (const guide of inlineList(fields.metadata.policies)) {
        if (guide !== '*' && !shipped.has(guide)) offending.push(`${file} — ${guide}`);
      }
    }
    return offending;
  });
});

ticket('conversion/02', 'a shipped script is copied code, and scripts/ is its home', (check) => {
  // Named rather than pattern-matched: a new top-level directory is an
  // architecture decision, and the assertion exists to make one visible rather
  // than to classify it. Dot-directories are the harness's and git's.
  const SHIPS = new Set(['agents', 'hooks', 'knowledge', 'scripts', 'skills']);
  const REPOSITORYS_OWN = new Set(['build']);

  check('every top-level directory ships, except this repository’s own build', () => {
    const offending = [];
    for (const entry of entries('.')) {
      if (!entry.isDirectory() || entry.name.startsWith('.')) continue;
      if (!SHIPS.has(entry.name) && !REPOSITORYS_OWN.has(entry.name)) {
        offending.push(`${entry.name}/ — neither shipped nor the build; decide which before it lands`);
      }
    }
    return offending;
  });

  // A path with a placeholder extension is the tell that the page is describing
  // a script for somebody to write rather than documenting one the plugin
  // carries. The extension is the whole difference the distribution change made.
  check('the scripts page names real files rather than a placeholder extension', () => {
    const offending = [];
    for (const file of markdownUnder(`${SKILLS}/configure`)) {
      read(file)
        .split('\n')
        .forEach((line, index) => {
          if (/\.claude\/scripts\/[\w-]+\.<ext>/.test(line)) offending.push(`${file}:${index + 1}`);
        });
    }
    return offending;
  });

  // A copy cannot be mis-implemented, so deriving one or proving one on arrival
  // are obligations with no subject. Guarded rather than merely deleted because
  // both read as diligence and get written back in.
  //
  // The subject is every page under the configuration skill except the scripts
  // page, which documents the code and speaks to whoever writes it — a fixture
  // is exactly the right obligation there. Scoping this to the stage's own
  // instructions was the first attempt and it missed two templates, which are
  // instructions too: one lands in every configured repository as framework law.
  check('no configuration instruction derives or fixture-proves a script', () => {
    const instructing = markdownUnder(`${SKILLS}/configure`).filter(
      (file) => file !== `${SKILLS}/configure/SCRIPTS.md`,
    );
    // Both directions, because the violation reads "a script derived into…" as
    // often as "derive the script". The lookahead is what keeps the reverse
    // direction usable: the two derived guides and the derived tool references
    // are still derived, so a list naming `scripts/` and "the derived tool
    // references" is correct prose, and a guard that flags correct prose gets
    // rescoped by whoever hits it. Matching only forwards was the first attempt
    // and it was silent against both real violations.
    const derived = String.raw`derive[ds]?|re-implemente?d?`;
    const stillDerived = String.raw`(?!\s+(?:tool|guide|polic))`;
    const near = new RegExp(
      `\\b(?:${derived})\\b[^.]{0,25}\\bscripts?\\b` +
        `|\\bscripts?\\b[^.]{0,60}\\b(?:${derived})\\b${stillDerived}` +
        `|\\bfixture\\b[^.]{0,60}\\bscript|\\bscript\\b[^.]{0,60}\\bfixture`,
      'i',
    );
    const offending = [];
    for (const file of instructing) {
      read(file)
        .split('\n')
        .forEach((line, index) => {
          if (near.test(line)) offending.push(`${file}:${index + 1}`);
        });
    }
    return offending;
  });
});

ticket('conversion/03', 'the store builder mints the ids a record is addressed by', (check) => {
  // The fixture harness lives in its own file because it is the one thing here
  // that touches a directory the resolver cannot vouch for: a throwaway store
  // under the operating system's temp directory. Nothing it does reads this
  // repository, and the one repository path it is given — the script under
  // test — is resolved here, through the resolver, before it is handed over.
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');

  const STORE = '.claude/knowledge/a.md';

  /** A store file's `spans` block, as anchor to id. */
  const spansOf = (text) => {
    const bound = {};
    if (text === null) return bound;
    let inside = false;
    for (const line of text.split(/\r?\n/)) {
      if (/^spans:\s*$/.test(line)) {
        inside = true;
        continue;
      }
      if (!inside) continue;
      const entry = line.match(/^\s+-\s*([^:]+):\s*(\S+)\s*$/);
      if (!entry) break;
      bound[entry[1].trim()] = entry[2].trim();
    }
    return bound;
  };

  const NORM = [
    '---',
    'owner: repository',
    'type: norm\nsubject: fixture',
    'fires-when: stage',
      'stages: [implement]',
    '---',
    '',
    '## First thing',
    '',
    '- **The first thing is stated once** and nothing restates it.',
    '',
    '## Second thing',
    '',
    '- **The second thing is stated once** and nothing restates it.',
    '',
  ].join('\n');

  // Only the shape the row figures are read from: the stage table's own rows.
  const ROUTER = [
    '---',
    'owner: framework',
    '---',
    '',
    '# Workflow protocol',
    '',
    '| Stage | Mode | Guides it reads |',
    '| --- | --- | --- |',
    '| `/implement` | implementation | the records its row selects |',
    '| `/commit` | maintenance | the records its row selects |',
    '',
  ].join('\n');

  /** A store holding one file of `body`, at `.claude/knowledge/<name>`. */
  const oneRecord = (frontmatter, body) => `---\n${frontmatter}\n---\n\n${body}\n`;

  /**
   * A fixture store that carries a router.
   *
   * A stage norm names a stage and the name is checked against the router's own
   * rows, so a fixture holding one and no router is testing the missing-router
   * refusal rather than whatever it meant to test.
   */
  const withRouter = (files, body) => fixture.withStore({ '.claude/protocol.md': ROUTER, ...files }, body);

  check('a first run mints an id for every heading and reports the instruction count', () =>
    withRouter({ [STORE]: NORM }, (root) => {
      const offending = [];
      const result = fixture.run(builder(), root);
      if (result.status !== 0) offending.push(`the run exited ${result.status}: ${result.output.trim()}`);
      const bound = spansOf(fixture.read(root, STORE));
      for (const anchor of ['first-thing', 'second-thing']) {
        if (!(anchor in bound)) offending.push(`${anchor} — no id was minted for it`);
        else if (!/^[a-z0-9]{6}$/.test(bound[anchor])) {
          offending.push(`${anchor} — "${bound[anchor]}" is not six lowercase alphanumerics`);
        }
      }
      if (bound['first-thing'] && bound['first-thing'] === bound['second-thing']) {
        offending.push('both headings were bound to one id');
      }
      if (!result.stdout.includes('instructions: 2')) {
        offending.push(`the instruction count was not reported: ${result.stdout.trim()}`);
      }
      return offending;
    }));

  // This is the specification rather than a repetition of the case above: a
  // builder that re-mints on every run passes the first case and destroys every
  // citation in the corpus, and only a second run can tell the two apart.
  check('a second run re-mints nothing', () =>
    withRouter({ [STORE]: NORM }, (root) => {
      const offending = [];
      fixture.run(builder(), root);
      const first = fixture.read(root, STORE);
      const second = fixture.run(builder(), root);
      const after = fixture.read(root, STORE);
      if (second.status !== 0) offending.push(`the second run exited ${second.status}: ${second.output.trim()}`);
      if (after !== first) offending.push('the second run rewrote the file');
      const before = spansOf(first);
      const now = spansOf(after);
      for (const anchor of Object.keys(before)) {
        if (before[anchor] !== now[anchor]) {
          offending.push(`${anchor} — ${before[anchor]} became ${now[anchor]}`);
        }
      }
      return offending;
    }));

  check('a renamed heading is refused, naming the file and the anchor', () =>
    withRouter({ [STORE]: NORM }, (root) => {
      const offending = [];
      fixture.run(builder(), root);
      const minted = fixture.read(root, STORE);
      fixture.write(root, STORE, minted.replace('## First thing', '## The first thing'));
      const renamed = fixture.read(root, STORE);
      const result = fixture.run(builder(), root);
      if (result.status === 0) offending.push('the rename was accepted');
      if (!result.output.includes('a.md')) offending.push('the refusal does not name the file');
      if (!result.output.includes('"first-thing"')) offending.push('the refusal does not name the anchor');
      // A rename is a human decision about whether the norm survived it, so the
      // id is not carried onto the new anchor and nothing is written at all.
      if (fixture.read(root, STORE) !== renamed) offending.push('the refused run wrote to the store');
      return offending;
    }));

  check('a record stating two imperatives is refused, naming the file, the heading, and the count', () =>
    withRouter({ [STORE]: NORM }, (root) => {
      const offending = [];
      fixture.run(builder(), root);
      const minted = fixture.read(root, STORE);
      fixture.write(
        root,
        STORE,
        `${minted}- **A second imperative under one heading** cannot be cited apart from the first.\n`,
      );
      const result = fixture.run(builder(), root);
      if (result.status === 0) offending.push('the second imperative was accepted');
      if (!result.output.includes('a.md')) offending.push('the refusal does not name the file');
      if (!result.output.includes('"Second thing"')) offending.push('the refusal does not name the heading');
      if (!/\b2 imperatives\b/.test(result.output)) offending.push('the refusal does not name the count');
      return offending;
    }));

  check('a type outside the closed set is refused, naming the file and the value', () =>
    fixture.withStore(
      { [STORE]: oneRecord('owner: repository\ntype: banana', '## First thing\n\n- **One thing** is stated.') },
      (root) => {
        const offending = [];
        const result = fixture.run(builder(), root);
        if (result.status === 0) offending.push('the type was accepted');
        if (!result.output.includes('a.md')) offending.push('the refusal does not name the file');
        if (!result.output.includes('"banana"')) offending.push('the refusal does not name the value');
        return offending;
      },
    ));

  check('a firing condition outside the closed set is refused, naming the file and the value', () =>
    fixture.withStore(
      {
        [STORE]: oneRecord(
          'owner: repository\ntype: norm\nsubject: fixture\nfires-when: sometimes',
          '## First thing\n\n- **One thing** is stated.',
        ),
      },
      (root) => {
        const offending = [];
        const result = fixture.run(builder(), root);
        if (result.status === 0) offending.push('the firing condition was accepted');
        if (!result.output.includes('a.md')) offending.push('the refusal does not name the file');
        if (!result.output.includes('"sometimes"')) offending.push('the refusal does not name the value');
        return offending;
      },
    ));

  check('a firing condition on something that is not a norm is refused, naming the file and its type', () =>
    fixture.withStore(
      {
        [STORE]: oneRecord(
          'owner: repository\ntype: context\nsubject: fixture\nfires-when: stage',
          '## First thing\n\nThe directory this domain lives in.',
        ),
      },
      (root) => {
        const offending = [];
        const result = fixture.run(builder(), root);
        if (result.status === 0) offending.push('the firing condition was accepted on a context');
        if (!result.output.includes('a.md')) offending.push('the refusal does not name the file');
        if (!/type is context/.test(result.output)) offending.push('the refusal does not name the type');
        return offending;
      },
    ));

  check('a declared edge citing an id no record carries is refused, naming the file, the field, and the id', () =>
    withRouter({ [STORE]: NORM.replace('type: norm\nsubject: fixture', 'type: norm\nsubject: fixture\nsupersedes: [zzz999]') }, (root) => {
      const offending = [];
      const result = fixture.run(builder(), root);
      if (result.status === 0) offending.push('the dangling citation was accepted');
      if (!result.output.includes('a.md')) offending.push('the refusal does not name the citing file');
      if (!result.output.includes('supersedes')) offending.push('the refusal does not name the field');
      if (!result.output.includes('zzz999')) offending.push('the refusal does not name the id');
      return offending;
    }));

  const boundTo = (headings, id) =>
    [
      '---',
      'owner: repository',
      'type: norm\nsubject: fixture',
      'fires-when: stage',
      'stages: [implement]',
      'spans:',
      ...headings.map((heading) => `  - ${heading.toLowerCase().replace(/ /g, '-')}: ${id}`),
      '---',
      '',
      ...headings.flatMap((heading) => [`## ${heading}`, '', '- **One thing** is stated.', '']),
    ].join('\n');

  check('one id declared in two files is refused, naming both files', () =>
    withRouter(
      {
        '.claude/knowledge/a.md': boundTo(['First thing'], 'ab12cd'),
        '.claude/knowledge/b.md': boundTo(['Second thing'], 'ab12cd'),
      },
      (root) => {
        const offending = [];
        const result = fixture.run(builder(), root);
        if (result.status === 0) offending.push('the duplicate id was accepted');
        if (!result.output.includes('a.md')) offending.push('the refusal does not name the first file');
        if (!result.output.includes('b.md')) offending.push('the refusal does not name the second file');
        if (!result.output.includes('ab12cd')) offending.push('the refusal does not name the id');
        return offending;
      },
    ));

  // The ticket says "one id declared twice" and does not say in how many files.
  // One file binding two anchors to one token produces exactly the ambiguous
  // citation the cross-file case does, so it is the same fault and not a
  // narrower one — asserted separately because a guard covering both passes
  // while either holds.
  check('one id declared twice inside one file is refused, naming the file', () =>
    withRouter({ [STORE]: boundTo(['First thing', 'Second thing'], 'ab12cd') }, (root) => {
      const offending = [];
      const result = fixture.run(builder(), root);
      if (result.status === 0) offending.push('the same id on two anchors of one file was accepted');
      if (!result.output.includes('a.md')) offending.push('the refusal does not name the file');
      if (!result.output.includes('ab12cd')) offending.push('the refusal does not name the id');
      return offending;
    }));

  // The silent failure this design is most exposed to: the stage name is legal,
  // the build is green, and the norm simply never arrives anywhere.
  check('a norm naming a stage no router row names is refused, naming the file, the id, and the stage', () =>
    fixture.withStore(
      {
        '.claude/protocol.md': ROUTER,
        [STORE]: [
          '---',
          'owner: repository',
          'type: norm\nsubject: fixture',
          'fires-when: stage',
          'stages: [frobnicate]',
          'spans:',
          '  - first-thing: ab12cd',
          '---',
          '',
          '## First thing',
          '',
          '- **One thing** is stated.',
          '',
        ].join('\n'),
      },
      (root) => {
        const offending = [];
        const result = fixture.run(builder(), root);
        if (result.status === 0) offending.push('the unknown stage was accepted');
        if (!result.output.includes('a.md')) offending.push('the refusal does not name the file');
        if (!result.output.includes('ab12cd')) offending.push('the refusal does not name the id');
        if (!result.output.includes('"frobnicate"')) offending.push('the refusal does not name the label');
        return offending;
      },
    ));

  // Naming no stage and naming one that does not exist are the same failure —
  // the norm arrives nowhere — so the second cannot be refused while the first
  // is merely counted in a report. Asserted apart from the case above because a
  // guard covering both passes while either holds.
  check('a norm that fires on a stage and names none is refused, naming the file and the id', () =>
    withRouter({ [STORE]: boundTo(['First thing'], 'ab12cd').replace('stages: [implement]\n', '') }, (root) => {
      const offending = [];
      const result = fixture.run(builder(), root);
      if (result.status === 0) offending.push('a stage norm naming no stage was accepted');
      if (!result.output.includes('a.md')) offending.push('the refusal does not name the file');
      if (!result.output.includes('ab12cd')) offending.push('the refusal does not name the id');
      return offending;
    }));

  // Unknown resolves to fail here as it does everywhere else in this corpus: a
  // label nothing was checked against is not a label that passed.
  check('a stage norm with no router to check it against is refused, naming where the router was looked for', () =>
    fixture.withStore({ [STORE]: NORM }, (root) => {
      const offending = [];
      const result = fixture.run(builder(), root);
      if (result.status === 0) offending.push('the label was accepted with nothing to check it against');
      if (!result.output.includes('a.md')) offending.push('the refusal does not name the file');
      if (!/protocol\.md/.test(result.output)) offending.push('the refusal does not name where the router was looked for');
      return offending;
    }));

  // The corpus's count, not the norms'. A description that states an imperative
  // is instruction a reader is carrying whether or not it was meant to be.
  check('the instruction count covers the corpus rather than the norms alone', () =>
    fixture.withStore(
      {
        '.claude/knowledge/context.md': oneRecord(
          'owner: repository\ntype: context\nsubject: fixture',
          '## The ordering domain\n\n- **Ordering lives under the ordering directory** and nothing else does.',
        ),
      },
      (root) => {
        const result = fixture.run(builder(), root);
        if (result.status !== 0) return [`the store was refused: ${result.output.trim()}`];
        return result.stdout.includes('instructions: 1')
          ? []
          : [`a non-norm record was not counted: ${result.stdout.trim()}`];
      },
    ));

  // An empty store is a true state of a repository that has not migrated yet,
  // not a misconfiguration: refusing it would make the expand half of a
  // migration impossible to land.
  check('an empty store exits zero, reports no instructions, and writes a ledger with no records', () =>
    withRouter({ [STORE]: NORM }, (root) => {
      const offending = [];
      fixture.remove(root, STORE);
      const result = fixture.run(builder(), root);
      if (result.status !== 0) offending.push(`an empty store exited ${result.status}: ${result.output.trim()}`);
      if (!result.stdout.includes('instructions: 0')) {
        offending.push(`the count was not reported as zero: ${result.stdout.trim()}`);
      }
      const ledger = fixture.read(root, '.claude/position/ledger.json');
      if (ledger === null) offending.push('no ledger was written');
      else if (JSON.parse(ledger).records.length !== 0) offending.push('the ledger holds records');
      return offending;
    }));

  check('a record nothing links to is reported and does not fail the build', () =>
    withRouter({ [STORE]: NORM }, (root) => {
      const offending = [];
      const result = fixture.run(builder(), root);
      if (result.status !== 0) offending.push(`an unreferenced record failed the build: ${result.output.trim()}`);
      if (!/^unreferenced: 2$/m.test(result.stdout)) {
        offending.push(`the orphans were not reported: ${result.stdout.trim()}`);
      }
      if (!result.stdout.includes('a.md')) offending.push('the report does not name the file');
      return offending;
    }));

  check('the ledger lands under the position directory and nowhere else', () =>
    withRouter({ [STORE]: NORM }, (root) => {
      const offending = [];
      fixture.run(builder(), root);
      if (!fixture.exists(root, '.claude/position/ledger.json')) {
        offending.push('.claude/position/ledger.json — not written');
      }
      if (fixture.exists(root, '.claude/knowledge/ledger.json')) {
        offending.push('.claude/knowledge/ledger.json — written beside the store');
      }
      return offending;
    }));

  // The two norms are `posture` and `path` rather than `every-turn` and `path`.
  // The subject is firing breadth ordering norms among themselves, which either
  // pair demonstrates; `every-turn` would additionally require a store holding
  // a norm that belongs to the pushed tier, and whether such a norm may sit in
  // the store at all is an open contradiction on the page this script is built
  // from. A fixture that requires the store to build has taken a side in it,
  // and whoever settles it the other way would find this assertion in the way,
  // reading as their bug.
  check('precedence is computed: decisions outrank norms, breadth orders norms, and a context has no rank', () =>
    fixture.withStore(
      {
        '.claude/knowledge/decision.md': oneRecord(
          'owner: repository\ntype: decision\nsubject: fixture',
          '# Events, not HTTP\n\n- **Two contexts communicate by event** and never by call.',
        ),
        '.claude/knowledge/posture.md': oneRecord(
          'owner: repository\ntype: norm\nsubject: fixture\nfires-when: posture\npostures: [discussion]',
          '## Exploration is delayed\n\n- **A conclusion is deferred while this posture holds** and alternatives are generated.',
        ),
        '.claude/knowledge/path.md': oneRecord(
          'owner: repository\ntype: norm\nsubject: fixture\nfires-when: path\npaths: [src/**]',
          '## Tests sit beside the code\n\n- **A test lives beside what it tests** where the tooling allows.',
        ),
        '.claude/knowledge/context.md': oneRecord(
          'owner: repository\ntype: context\nsubject: fixture',
          '## The ordering domain\n\nOrdering lives under the ordering directory.',
        ),
      },
      (root) => {
        const offending = [];
        const result = fixture.run(builder(), root);
        if (result.status !== 0) return [`the store was refused: ${result.output.trim()}`];
        const ledger = JSON.parse(fixture.read(root, '.claude/position/ledger.json'));
        const by = (file) => ledger.records.find((record) => record.file === file);
        const decision = by('decision.md');
        const broad = by('posture.md');
        const scoped = by('path.md');
        const context = by('context.md');
        if (!(decision.rank < broad.rank)) offending.push(`decision rank ${decision.rank} does not outrank norm rank ${broad.rank}`);
        if (broad.rank !== scoped.rank) offending.push('the two norms were given different ranks');
        if (!(broad.breadth < scoped.breadth)) {
          offending.push(`posture breadth ${broad.breadth} is not ordered ahead of path ${scoped.breadth}`);
        }
        // Answered with nothing rather than with a default: a description handed
        // a number invites a caller to weigh it against an instruction.
        if ('rank' in context) offending.push(`the context was given rank ${context.rank}`);
        return offending;
      },
    ));

  check('a declared deviation and a broken pointer are reported rather than failed', () =>
    withRouter(
      {
        [STORE]: oneRecord(
          'owner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [implement]\ndeviates-from: [fw0001]\nsources: [src/gone.ts]',
          '## First thing\n\n- **One thing** is stated.',
        ),
      },
      (root) => {
        const offending = [];
        const result = fixture.run(builder(), root);
        if (result.status !== 0) offending.push(`a report failed the build: ${result.output.trim()}`);
        if (!result.stdout.includes('deviations: 1')) offending.push('the deviation was not counted');
        if (!result.stdout.includes('fw0001')) offending.push('the deviation was not named');
        if (!result.stdout.includes('broken pointers: 1')) offending.push('the broken pointer was not counted');
        if (!result.stdout.includes('src/gone.ts')) offending.push('the broken pointer was not named');
        return offending;
      },
    ));

  // The tier is paid on every turn where a row is paid once, so a total mixing
  // them would hide the only number that multiplies; and a single row total
  // would mix prose that should not grow with indexes that must.
  check("the boot tier is its own figure, and each row's authored and generated sizes are separate", () =>
    fixture.withStore(
      {
        'CLAUDE.md': '# Entry\n\n- **The boot tier is loaded every turn** and is kept small.\n',
        '.claude/protocol.md': ROUTER,
        [STORE]: oneRecord(
          'owner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [implement]',
          '## First thing\n\n- **One thing** is stated, at some length so the figure is not zero.',
        ),
        '.claude/knowledge/map.md': oneRecord(
          'owner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [implement]',
          '## The generated row\n\n- **This record came from a generated file** and counts as generated.',
        ),
      },
      (root) => {
        const offending = [];
        const result = fixture.run(builder(), root);
        if (result.status !== 0) return [`the store was refused: ${result.output.trim()}`];
        const boot = result.stdout.match(/^boot tier: (\d+) characters$/m);
        if (!boot) offending.push('the boot tier is not reported as a figure of its own');
        else if (Number(boot[1]) === 0) offending.push('the boot tier was measured as nothing');
        const row = result.stdout.match(/^ {2}implement {2}authored (\d+) {2}generated (\d+)$/m);
        if (!row) offending.push("the implement row's two sizes are not reported separately");
        else {
          if (Number(row[1]) === 0) offending.push('the authored size was measured as nothing');
          if (Number(row[2]) === 0) offending.push('the generated size was measured as nothing');
        }
        return offending;
      },
    ));

  // Line endings are the checkout's. A fixed ending fails on every platform but
  // the author's, and fails as a stale output rather than as the line-ending
  // disagreement it is.
  check("minting preserves the file's line endings", () =>
    withRouter({ [STORE]: NORM.replace(/\n/g, '\r\n') }, (root) => {
      const result = fixture.run(builder(), root);
      if (result.status !== 0) return [`the run exited ${result.status}: ${result.output.trim()}`];
      const after = fixture.read(root, STORE);
      const offending = [];
      after.split('\n').forEach((line, index, all) => {
        if (index === all.length - 1) return;
        if (!line.endsWith('\r')) offending.push(`${STORE}:${index + 1} — a bare line feed in a CRLF file`);
      });
      return offending;
    }));

  // A copy is compared byte for byte against its source, and three bytes at the
  // front of a file nobody sees in a diff break that comparison.
  check('the shipped script carries no byte-order mark', () => {
    const source = read('scripts/build-knowledge-store.js');
    return source.charCodeAt(0) === 0xfeff ? ['scripts/build-knowledge-store.js — starts with a BOM'] : [];
  });

  // Emitted output is captured through whatever console encoding the shell
  // happens to have, and a non-ASCII character arrives as a question mark in
  // output that still looks well-formed. **Both streams**, because the
  // transcoding this rule exists for happened on a refusal line, and a guard
  // reading only a successful run cannot see the case that motivated it.
  check('everything the shipped script emits is ASCII, on either stream', () => {
    const nonAscii = (label, text) => {
      const offending = [];
      text.split('\n').forEach((line, index) => {
        if (/[^\x00-\x7F]/.test(line)) offending.push(`${label}:${index + 1} — ${line}`);
      });
      return offending;
    };
    const reported = withRouter({ [STORE]: NORM }, (root) => {
      const result = fixture.run(builder(), root);
      return [...nonAscii('report stdout', result.stdout), ...nonAscii('report stderr', result.stderr)];
    });
    const refused = withRouter({ [STORE]: NORM.replace('type: norm\nsubject: fixture', 'type: banana') }, (root) => {
      const result = fixture.run(builder(), root);
      if (result.status === 0) return ['the refusing fixture did not refuse'];
      return [...nonAscii('refusal stdout', result.stdout), ...nonAscii('refusal stderr', result.stderr)];
    });
    return [...reported, ...refused];
  });

  // Guessing what a misspelt flag meant is how a run against the default store
  // looks like it did what was asked.
  check('an unrecognised argument is refused, naming it', () =>
    withRouter({ [STORE]: NORM }, (root) => {
      const offending = [];
      const result = fixture.run(builder(), root, ['--stoor', 'somewhere']);
      if (result.status === 0) offending.push('the unrecognised argument was accepted');
      if (!result.output.includes('--stoor')) offending.push('the refusal does not name the argument');
      return offending;
    }));

  // The header promises a refusal on standard error; a raw stack trace is not
  // one, and it is what an argument left dangling used to produce.
  check('an argument given no value is refused rather than thrown', () =>
    withRouter({ [STORE]: NORM }, (root) => {
      const offending = [];
      const result = fixture.run(builder(), root, ['--store']);
      if (result.status === 0) offending.push('the dangling argument was accepted');
      if (/^\s+at /m.test(result.output)) offending.push('a stack trace was printed instead of a refusal');
      if (!result.output.includes('--store')) offending.push('the refusal does not name the argument');
      return offending;
    }));

  // The column is not bookkeeping: a page documenting code says *this exists*,
  // and a row still saying otherwise says the opposite of what the tree holds.
  check('the scripts page no longer reports the knowledge store builder as unwritten', () => {
    const row = read('skills/configure/SCRIPTS.md')
      .split('\n')
      .find((line) => /^\|\s*knowledge store builder\s*\|/.test(line));
    if (!row) return ['skills/configure/SCRIPTS.md — the knowledge store builder has no row'];
    const written = row.split('|').map((cell) => cell.trim())[6];
    return written === 'not yet' ? [`skills/configure/SCRIPTS.md — the row still reads "${written}"`] : [];
  });
});

ticket('conversion/08', 'the position report ships as code rather than as a description', (check) => {
  // The platform's, and used for the *emitted* report only. What the script
  // writes to disk takes the checkout's ending instead, and the two assertions
  // about that take their expected value from the fixture's own pin rather than
  // from here — a guard sharing a source with its subject cannot see it.
  const { EOL } = require('os');
  // The fixture builds and mutates a git repository in a temporary directory,
  // which is why it lives beside this file rather than in it: `resolveShipped`
  // refuses everything outside this repository, and it keeps no exemption for a
  // fixture. The one shipped path the fixture needs is resolved here, through it.
  const fixture = require('./fixtures/report-position.js');
  const SCRIPT = 'scripts/report-position.js';

  // Every case runs against one fixture repository, built once. Each case sets
  // its own state up in full first, so the sharing costs no independence.
  let observed;
  const observe = () => (observed = observed || fixture.observe(resolveShipped(SCRIPT)));

  const short = (name) => name.slice(0, 7);
  const report = (...lines) => lines.join(EOL) + EOL;
  const COMMIT_ONLY = '  mode    commit-only (run identity unavailable)';

  /**
   * One case's emitted bytes against the report it owes. Object names cannot be
   * literals — a commit's name depends on when and by whom it was made — so the
   * expected output is stated with the captured values substituted in. That is
   * still a byte comparison.
   */
  const emits = (name, expected) => () => {
    const observation = observe();
    const run = observation.cases[name];
    const offending = [];
    if (run.status !== 0) {
      offending.push(`case ${name} — exited ${run.status}: ${run.stderr.trim()}`);
    }
    const wanted = expected(observation);
    if (run.stdout !== wanted) {
      offending.push(`case ${name} — expected ${JSON.stringify(wanted)}`);
      offending.push(`case ${name} — emitted  ${JSON.stringify(run.stdout)}`);
    }
    return offending;
  };

  check(
    'case A — both identities match, and the drift reads are skipped',
    emits('A', (o) =>
      report(
        'Position',
        `  marker  ${short(o.head)}  HEAD ${short(o.head)}   commit match`,
        `  tree    ${short(o.tree)}  live ${short(o.tree)}   tree match`,
        '  drift   reads skipped',
        COMMIT_ONLY,
      ),
    ),
  );

  // A fingerprint blind to an untracked file is the defect this read exists to
  // catch, so the two fingerprints differing is asserted rather than assumed: a
  // script that ignored untracked files would satisfy the expected output below
  // only because the fixture had handed it two identical values.
  check('case B — the tree differs, and the drift list names the path', () => {
    const observation = observe();
    const offending = emits('B', (o) =>
      report(
        'Position',
        `  marker  ${short(o.head)}  HEAD ${short(o.head)}   commit match`,
        `  tree    ${short(o.tree)}  live ${short(o.live)}   tree differs`,
        '  drift   0 committed, 1 uncommitted',
        '            a.txt',
        COMMIT_ONLY,
      ),
    )();
    if (short(observation.live) === short(observation.tree)) {
      offending.push('case B — the fingerprint did not move when an untracked file appeared');
    }
    return offending;
  });

  check(
    'case C — no marker file, and nothing was ever verified in this clone',
    emits('C', () =>
      report(
        'Position',
        '  marker  absent',
        '  -> nothing was verified in this clone; everything the request touches is unverified',
        COMMIT_ONLY,
      ),
    ),
  );

  check(
    'case D — the run identity is present, and only the mode line changes',
    emits('D', (o) =>
      report(
        'Position',
        `  marker  ${short(o.head)}  HEAD ${short(o.head)}   commit match`,
        `  tree    ${short(o.tree)}  live ${short(o.tree)}   tree match`,
        '  drift   reads skipped',
        `  mode    session ${o.identity}`,
      ),
    ),
  );

  check(
    "case E — the marker's commit is gone from this clone",
    emits('E', (o) =>
      report(
        'Position',
        `  marker  ${short(o.gone)}  gone from this clone`,
        '  -> no diff is possible from it; everything the request touches is unverified',
        COMMIT_ONLY,
      ),
    ),
  );

  check(
    'case F — the marker is not an ancestor of HEAD',
    emits('F', (o) =>
      report(
        'Position',
        `  marker  ${short(o.other)}  HEAD ${short(o.head)}   not an ancestor`,
        '  -> the diff between them is meaningless; everything the request touches is unverified',
        COMMIT_ONLY,
      ),
    ),
  );

  // The commit verdict's other half, and the committed half of the drift list.
  // No lettered case above reaches either: A and D match on the commit, B moves
  // only the tree, and C, E and F never get past a refusal.
  check(
    'case G — the marker is behind HEAD, and the report counts and lists what moved',
    emits('G', (o) =>
      report(
        'Position',
        `  marker  ${short(o.base)}  HEAD ${short(o.head)}   1 commits ahead`,
        `  tree    ${short(o.tree)}  live ${short(o.tree)}   tree match`,
        '  drift   1 committed, 0 uncommitted',
        '            second.txt',
        COMMIT_ONLY,
      ),
    ),
  );

  // **The path arrives whole.** A porcelain line is `XY<space><path>`, and for
  // an unstaged modification column 1 is a space — so any reader that strips
  // leading whitespace from the output before splitting it consumes the first
  // path's first character, and only the first path's, and only when its status
  // takes that shape. Every other case here puts `??` or `M ` in those columns,
  // which is why the defect survived a fixture, a byte comparison against the
  // reference implementation, and two reviews: the reference has it too, so
  // parity preserved it rather than exposing it.
  check(
    'case H — an unstaged modification is listed under its whole path',
    emits('H', (o) =>
      report(
        'Position',
        `  marker  ${short(o.head)}  HEAD ${short(o.head)}   commit match`,
        `  tree    ${short(o.tree)}  live ${short(o.liveModified)}   tree differs`,
        '  drift   0 committed, 2 uncommitted',
        '            seed.txt',
        '            zz.txt',
        COMMIT_ONLY,
      ),
    ),
  );

  // An object that is absent and an object that is present but unrelated are
  // different questions with different consequences, and collapsing them into
  // one line is the failure this pair exists to catch. Asserted against each
  // other rather than only against their own expected output, so a collapse
  // fails here by name rather than only as two mismatched reports.
  check('cases E and F do not collapse into one refusal', () => {
    const observation = observe();
    const lineOf = (name, index) => observation.cases[name].stdout.split(/\r?\n/)[index] || '';
    const offending = [];
    if (lineOf('E', 1) === lineOf('F', 1)) offending.push('E and F emit the same marker line');
    if (lineOf('E', 2) === lineOf('F', 2)) offending.push('E and F emit the same consequence');
    if (!/ {2}gone from this clone$/.test(lineOf('E', 1))) offending.push(`E — ${lineOf('E', 1)}`);
    if (/ {3}not an ancestor$/.test(lineOf('E', 1))) offending.push('E — answered with F’s verdict');
    if (!/ {3}not an ancestor$/.test(lineOf('F', 1))) offending.push(`F — ${lineOf('F', 1)}`);
    if (/ {2}gone from this clone$/.test(lineOf('F', 1))) offending.push('F — answered with E’s verdict');
    return offending;
  });

  // A refusal is a computed position whose answer is *unverified*, and a clone
  // with no marker must still be able to commit — so the run that refuses writes
  // a receipt exactly as the run that reports does.
  check('every run writes a receipt, the three refusals included', () => {
    const observation = observe();
    return Object.entries(observation.cases)
      .filter(([, run]) => run.receipt === null)
      .map(([name]) => `case ${name} — no receipt`);
  });

  // The distinction is the whole usefulness of the file: the commit stage asks
  // whether a receipt attests *this* position. Case B is the only case where the
  // marker and the observation disagree, so it is the only one that can tell a
  // receipt echoing the marker from a receipt recording what was seen.
  check('the receipt records what was observed, never what the marker said', () => {
    const observation = observe();
    const run = observation.cases.B;
    if (!run.receipt) return ['case B — no receipt'];
    const receipt = JSON.parse(run.receipt.toString('utf8'));
    const offending = [];
    if (receipt.head !== observation.head) offending.push(`head — ${receipt.head}`);
    if (receipt.tree === observation.tree) offending.push('tree — the marker’s value, not the observed one');
    if (receipt.tree !== observation.live) offending.push(`tree — ${receipt.tree}`);
    return offending;
  });

  // A downgrade that is not stated is a downgrade nobody can detect, which is
  // why the weaker attestation is a field rather than something a reader infers.
  check('a receipt taken without a run identity is written as such', () => {
    const observation = observe();
    const run = observation.cases.A;
    if (!run.receipt) return ['case A — no receipt'];
    const receipt = JSON.parse(run.receipt.toString('utf8'));
    const offending = [];
    const fields = Object.keys(receipt).join(',');
    if (fields !== 'run,mode,head,tree') offending.push(`fields — ${fields}`);
    if (receipt.run !== null) offending.push(`run — ${JSON.stringify(receipt.run)}`);
    if (receipt.mode !== 'commit-only') offending.push(`mode — ${receipt.mode}`);
    return offending;
  });

  check('a receipt taken with a run identity names it, and says session', () => {
    const observation = observe();
    const run = observation.cases.D;
    if (!run.receipt) return ['case D — no receipt'];
    const receipt = JSON.parse(run.receipt.toString('utf8'));
    const offending = [];
    if (receipt.run !== observation.identity) offending.push(`run — ${JSON.stringify(receipt.run)}`);
    if (receipt.mode !== 'session') offending.push(`mode — ${receipt.mode}`);
    return offending;
  });

  // Emitted output is captured through whatever console encoding the shell
  // happens to have, and a non-ASCII character does not survive one that is not
  // UTF-8: it arrives as `?`, in a report that still looks well-formed. The
  // refusal lines carried an arrow once, and this comparison was what noticed.
  check('what the report emits is ASCII', () => {
    const observation = observe();
    const offending = [];
    for (const [name, run] of Object.entries(observation.cases)) {
      run.stdout.split(/\r?\n/).forEach((line, index) => {
        if (/[^\x00-\x7F]/.test(line)) offending.push(`case ${name}:${index + 1} — ${JSON.stringify(line)}`);
      });
    }
    return offending;
  });

  /** Which ending a receipt was written with, read from the bytes alone. */
  const endingOf = (receipt) => (/\r\n/.test(receipt.toString('utf8')) ? '\r\n' : '\n');
  const named = (ending) => (ending === '\r\n' ? 'crlf' : 'lf');

  // A byte-order mark is three bytes at the front of a file nobody sees in a
  // diff, and it breaks byte comparison. Nothing here consults the platform:
  // these are properties a receipt has or does not have whatever ending is
  // right, and which ending is right is the assertion below.
  check('the receipt is UTF-8 without a byte-order mark, and one ending throughout', () => {
    const observation = observe();
    const offending = [];
    const inspect = (label, receipt) => {
      if (!receipt) return;
      if (receipt.slice(0, 3).equals(Buffer.from([0xef, 0xbb, 0xbf]))) {
        offending.push(`${label} — a byte-order mark`);
      }
      const text = receipt.toString('utf8');
      const bare = (text.match(/(^|[^\r])\n/g) || []).length;
      const paired = (text.match(/\r\n/g) || []).length;
      if (bare > 0 && paired > 0) offending.push(`${label} — ${paired} CRLF and ${bare} bare LF in one file`);
      if (!text.endsWith('\n')) offending.push(`${label} — does not end in a newline`);
    };
    for (const [name, run] of Object.entries(observation.cases)) inspect(`case ${name}`, run.receipt);
    for (const checkout of observation.checkouts) inspect(checkout.label, checkout.run.receipt);
    return offending;
  });

  // **The expected ending comes from what the fixture configured, never from
  // `os`.** Taking it from `os` was the first version of this guard and it was
  // tautological: the script's ending and the expectation came from one source,
  // so the assertion held whatever the checkout said.
  //
  // Four repositories, because one alone cannot tell a script that read the
  // checkout from one that happened to emit that ending anyway — and because
  // the `eol` attribute and `core.autocrlf` are separate steps of the script's
  // fallback chain, each of which is unexercised if only the other is set.
  check('the receipt is written with the line ending the checkout settles on', () => {
    const observation = observe();
    const offending = [];
    for (const checkout of observation.checkouts) {
      const receipt = checkout.run.receipt;
      if (!receipt) {
        offending.push(`${checkout.label} — no receipt`);
        continue;
      }
      const produced = endingOf(receipt);
      if (produced !== checkout.expected) {
        offending.push(
          `${checkout.label} — git puts ${named(checkout.expected)} on disk, the receipt is ${named(produced)}`,
        );
      }
    }
    const produced = new Set(
      observation.checkouts.filter((c) => c.run.receipt).map((c) => endingOf(c.run.receipt)),
    );
    if (produced.size < 2) {
      offending.push('every checkout got the same ending — nothing about the checkout was read');
    }
    return offending;
  });

  // The `Written` column is the page's claim about which scripts exist, and a
  // claim nothing checks is how a row comes to say `not yet` about a file that
  // shipped two releases ago. Both directions, because either one alone is a
  // guard that stays green through the failure it was written for.
  check('the scripts page and the shipped scripts agree on which exist', () => {
    const shipped = new Set(entries('scripts').filter((entry) => entry.isFile()).map((entry) => entry.name));
    const rows = [];
    const offending = [];
    for (const line of read(`${SKILLS}/configure/SCRIPTS.md`).split('\n')) {
      const row = line.match(
        /^\|[^|]+\|\s*`\.claude\/scripts\/([\w.-]+)`\s*\|[^|]*\|[^|]*\|[^|]*\|\s*(.*?)\s*\|\s*$/,
      );
      if (!row) continue;
      const [, file, written] = row;
      rows.push(file);
      if (written !== 'not yet' && !shipped.has(file)) {
        offending.push(`${file} — the row no longer says "not yet", and nothing ships under that name`);
      }
      if (written === 'not yet' && shipped.has(file)) {
        offending.push(`${file} — ships, and the row still says "not yet"`);
      }
    }
    if (rows.length === 0) offending.push('the scripts page names no script at all — the table was not parsed');
    return offending;
  });
});

ticket('settlement/01', 'a stage norm declares its stages in a field of its own', (check) => {
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');

  const STORE = '.claude/knowledge/a.md';

  // The same two-stage router conversion/03 uses. Repeated rather than shared
  // because a fixture reaching into another ticket's group binds the two: a
  // later edit to that group's router would move these assertions' subject
  // without touching them.
  const ROUTER = [
    '---',
    'owner: framework',
    '---',
    '',
    '# Workflow protocol',
    '',
    '| Stage | Mode | Guides it reads |',
    '| --- | --- | --- |',
    '| `/implement` | implementation | the records its row selects |',
    '| `/commit` | maintenance | the records its row selects |',
    '',
  ].join('\n');

  /** A one-record store file, with whatever frontmatter the case is about. */
  const norm = (frontmatter) =>
    `---\n${frontmatter}\n---\n\n## First thing\n\n- **The first thing is stated once** and nothing restates it.\n`;

  const withRouter = (files, body) => fixture.withStore({ '.claude/protocol.md': ROUTER, ...files }, body);

  const ledgerOf = (root) => {
    const raw = fixture.read(root, '.claude/position/ledger.json');
    return raw === null ? null : JSON.parse(raw);
  };

  check('a norm declaring a stage firing condition and its stages builds, and the ledger holds them as a list', () =>
    withRouter(
      { [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [implement, commit]') },
      (root) => {
        const offending = [];
        const result = fixture.run(builder(), root);
        if (result.status !== 0) offending.push(`the run exited ${result.status}: ${result.output.trim()}`);
        const ledger = ledgerOf(root);
        if (ledger === null) return [...offending, 'no ledger was written'];
        const entry = ledger.records[0];
        if (!Array.isArray(entry.stages)) {
          offending.push(`stages is ${JSON.stringify(entry.stages)}, and a list is what a filter matches against`);
        } else if (entry.stages.join(',') !== 'implement,commit') {
          offending.push(`stages is ${JSON.stringify(entry.stages)}`);
        }
        if (entry['fires-when'] !== 'stage') offending.push(`fires-when is ${JSON.stringify(entry['fires-when'])}`);
        return offending;
      },
    ),
  );

  // The residue that ruled out one stage per record: a norm several stages read
  // is one record, and the ledger says so without anything parsing a value.
  check('a norm read by more than one stage is one record', () =>
    withRouter(
      { [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [implement, commit]') },
      (root) => {
        fixture.run(builder(), root);
        const ledger = ledgerOf(root);
        if (ledger === null) return ['no ledger was written'];
        return ledger.records.length === 1
          ? []
          : [`${ledger.records.length} records for one norm — the stages were expanded rather than listed`];
      },
    ),
  );

  // A stage norm naming no stage, and one naming a stage the router does not
  // carry, are both refused under `conversion/03` — that ticket introduced the
  // refusals and its group still owns them, expressed in this field. What is
  // new here is the field, so only what the field newly makes possible is
  // asserted below; a second assertion on either of those sites would go green
  // when its twin was deleted.
  //
  // Declared empty and not declared at all are the same fault to a reader and
  // must be the same refusal, or the shape that reads as deliberate is the one
  // that gets through.
  check('a norm firing on a stage and declaring an empty stages list is refused', () =>
    withRouter({ [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: []') }, (root) => {
      const result = fixture.run(builder(), root);
      return result.status === 0 ? ['an empty stages list was accepted'] : [];
    }),
  );

  // Two bad stages, and both must be named. One bad stage would not tell a loop
  // from a search that stops at the first it finds, which is the shape that
  // hides the second fault until somebody fixes the first.
  check('every stage in the list is reported, not the first bad one', () =>
    withRouter(
      { [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [frobnicate, nowhere]') },
      (root) => {
        fixture.run(builder(), root);
        const result = fixture.run(builder(), root);
        return ['frobnicate', 'nowhere'].filter((stage) => !result.output.includes(stage)).map(
          (stage) => `${stage} was not named — the check stopped early`,
        );
      },
    ),
  );

  check('stages declared where the firing condition is not a stage is refused, naming the file', () =>
    withRouter(
      { [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: path\nstages: [implement]') },
      (root) => {
        const offending = [];
        const result = fixture.run(builder(), root);
        if (result.status === 0) offending.push('stages beside a non-stage firing condition was accepted');
        if (!/a\.md/.test(result.output)) offending.push('the refusal does not name the file');
        return offending;
      },
    ),
  );

  // The colon qualifier is the form this ticket replaced, and it is the one
  // shape a reader of the old corpus will type. It has to fail as an
  // unrecognised firing condition rather than being parsed for its old meaning.
  check('the retired colon qualifier is refused as a firing condition outside the closed set', () =>
    withRouter({ [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: stage:implement') }, (root) => {
      const offending = [];
      const result = fixture.run(builder(), root);
      if (result.status === 0) offending.push('fires-when: stage:implement was accepted');
      if (!/closed set/.test(result.output)) {
        offending.push('the refusal does not report it as a value outside the closed set');
      }
      return offending;
    }),
  );

  // The row figures are read off the stage list, so a norm two stages read is
  // counted under both rows. Under the colon form this was one row's alone.
  check("a norm's size counts under every row its stages name", () =>
    withRouter(
      { [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [implement, commit]') },
      (root) => {
        fixture.run(builder(), root);
        const ledger = ledgerOf(root);
        if (ledger === null) return ['no ledger was written'];
        const rows = Object.fromEntries(ledger.figures.rows.map((row) => [row.stage, row.authored]));
        const offending = [];
        for (const stage of ['implement', 'commit']) {
          if (!(rows[stage] > 0)) offending.push(`the ${stage} row counted nothing`);
        }
        return offending;
      },
    ),
  );

  // Anchored to the example rather than to the prose around it. The first
  // version of this guard looked for the word `stages` anywhere on the page and
  // was silent when an example lost the field, because the paragraph explaining
  // the field still carried the word — a guard matching a phrase that travels
  // with the thing rather than the thing itself.
  //
  // The example is the site that can be wrong on its own: it is what an author
  // copies, and a page whose example the build would refuse teaches the shape
  // that fails.
  check('every record example a shipped page shows would itself build', () => {
    const offending = [];
    for (const file of [...markdownUnder(SKILLS), 'specs.md']) {
      const text = read(file);
      for (const block of text.match(/```markdown\n[\s\S]*?```/g) || []) {
        if (!/^fires-when:\s*stage\s*$/m.test(block)) continue;
        if (!/^stages:\s*\S/m.test(block)) {
          offending.push(`${file} — an example fires on a stage and declares no stages`);
        }
      }
    }
    return offending;
  });

  // A separate site, and a separate assertion: a page may keep a valid example
  // and still describe the retired form in its prose.
  check('no shipped page writes the retired colon qualifier', () => {
    const offending = [];
    for (const file of [...markdownUnder(SKILLS), 'specs.md']) {
      read(file)
        .split('\n')
        .forEach((line, index) => {
          if (/fires-when:\s*`?stage:/.test(line)) offending.push(`${file}:${index + 1}`);
        });
    }
    return offending;
  });
});

ticket('settlement/02', 'an every-turn norm is refused, and the pages stop ranking it', (check) => {
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');

  const STORE = '.claude/knowledge/a.md';

  const ROUTER = [
    '---',
    'owner: framework',
    '---',
    '',
    '# Workflow protocol',
    '',
    '| Stage | Mode | Guides it reads |',
    '| --- | --- | --- |',
    '| `/implement` | implementation | the records its row selects |',
    '',
  ].join('\n');

  const norm = (frontmatter) =>
    `---\n${frontmatter}\n---\n\n## First thing\n\n- **The first thing is stated once** and nothing restates it.\n`;

  const withRouter = (files, body) => fixture.withStore({ '.claude/protocol.md': ROUTER, ...files }, body);

  // The boot tier stays files the harness loads, so a norm that must fire on a
  // turn nobody started has nothing behind the store to fire it — it would stop
  // arriving, with nothing reporting that it had.
  // The id is seeded rather than minted. The builder validates before it writes
  // anything, so a store it refuses gets no ids at all — reading one back after
  // a refused run yields nothing, and a check guarded on having found one skips
  // itself silently. That is what the first version of this did.
  check('a norm firing every turn is refused, naming the file and the id', () =>
    withRouter(
      { [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: every-turn\nspans:\n  - first-thing: ab12cd') },
      (root) => {
        const offending = [];
        const result = fixture.run(builder(), root);
        if (result.status === 0) offending.push('an every-turn norm was accepted');
        if (!/a\.md/.test(result.output)) offending.push('the refusal does not name the file');
        if (!result.output.includes('ab12cd')) offending.push('the refusal does not name the id');
        return offending;
      },
    ),
  );

  // Two refusals a reader must be able to tell apart. Somebody who moved a
  // boot-tier rule into the store needs to learn why it cannot live there; the
  // generic message would tell them only that a word was not on a list, which
  // reads as a typo and invites them to pick a different word.
  check('the every-turn refusal is distinguishable from an unrecognised firing condition', () =>
    withRouter({ [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: every-turn') }, (root) => {
      const refused = fixture.run(builder(), root).output;
      const unknown = fixture.withStore(
        { '.claude/protocol.md': ROUTER, [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: sometimes') },
        (other) => [fixture.run(builder(), other).output],
      )[0];
      const offending = [];
      // Asserted before the wording, because "not the generic message" is also
      // true of no message at all — which is what an accepted every-turn norm
      // produces, and would read here as a pass.
      if (!/every-turn/.test(refused)) offending.push('the every-turn store produced no refusal naming it');
      if (/outside the closed set/.test(refused)) {
        offending.push('every-turn is reported as a value outside the closed set');
      }
      if (!/outside the closed set/.test(unknown)) {
        offending.push('an unrecognised firing condition is no longer reported as outside the closed set');
      }
      return offending;
    }),
  );

  // The value stays in the closed vocabulary. Removing it would make the two
  // refusals above one, which is the distinction the assertion before this
  // exists to keep — so this guards the vocabulary against being "tidied".
  check('every-turn is still a value the vocabulary names', () => {
    const source = read('scripts/build-knowledge-store.js');
    return /const FIRES_WHEN = \[[^\]]*'every-turn'/.test(source)
      ? []
      : ['the closed vocabulary no longer names every-turn, so its refusal cannot be specific'];
  });

  // Compared against the code rather than scanned for a forbidden word. The
  // first version flagged any line mentioning breadth and `every-turn`, which
  // fired on the paragraph explaining why every-turn is *not* ranked — a guard
  // that fires on correct prose is one whoever hits it will rescope.
  //
  // The subject is that the pages and the builder state one order. Comparing
  // the sequences catches every way they can disagree, including the one this
  // ticket is about, and cannot be satisfied by rewording.
  check('the pages and the builder state one firing-breadth order', () => {
    const source = read('scripts/build-knowledge-store.js');
    const declared = source.match(/const BREADTH = \[([^\]]*)\]/);
    if (!declared) return ['the builder declares no BREADTH order to compare against'];
    const code = [...declared[1].matchAll(/'([^']+)'/g)].map((match) => match[1]).join(' > ');

    const offending = [];
    for (const file of ['skills/configure/SCRIPTS.md', 'skills/configure/policies/records.template.md']) {
      const line = read(file)
        .split('\n')
        .find((candidate) => /\*\*Firing breadth orders norms among themselves\*\*/.test(candidate));
      if (line === undefined) {
        offending.push(`${file} — states no firing-breadth order`);
        continue;
      }
      const stated = [...line.matchAll(/`([a-z-]+)`/g)].map((match) => match[1]).join(' > ');
      if (stated !== code) offending.push(`${file} — states ${stated || '(nothing)'}, the builder computes ${code}`);
    }
    return offending;
  });

  // A fixture requiring the refused shape to build is what made the missing
  // refusal read as the next author's bug rather than as work outstanding.
  check('no page describes a fixture whose store holds an every-turn norm and builds', () => {
    const offending = [];
    for (const file of markdownUnder(SKILLS)) {
      read(file)
        .split('\n')
        .forEach((line, index) => {
          // Not `\`every-turn\`` — the pages write it inside a wider span,
          // `\`fires-when: every-turn\``, so a pattern demanding its own
          // backticks matches nothing a fixture case actually says.
          if (/every-turn/.test(line) && /\bbuilds?\b|\bledger\b/.test(line) && !/refus/.test(line)) {
            offending.push(`${file}:${index + 1}`);
          }
        });
    }
    return offending;
  });
});

ticket('settlement/03', 'the boot budget is asserted, and exceeding it fails the build', (check) => {
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');

  const STORE = '.claude/knowledge/a.md';

  const ROUTER = [
    '---',
    'owner: framework',
    '---',
    '',
    '# Workflow protocol',
    '',
    '| Stage | Mode | Guides it reads |',
    '| --- | --- | --- |',
    '| `/implement` | implementation | the records its row selects |',
    '',
  ].join('\n');

  const RECORD =
    '---\nowner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [implement]\n---\n\n' +
    '## First thing\n\n- **The first thing is stated once** and nothing restates it.\n';

  /** A rule file of roughly `size` characters, path-scoped or not. */
  const rule = (size, scoped) =>
    `---\nowner: repository\n${scoped ? 'paths:\n  - "src/**"\n' : ''}---\n\n# A rule\n\n${'x'.repeat(size)}\n`;

  const tier = (output) => {
    const found = output.match(/^boot tier: (\d+) characters$/m);
    return found ? Number(found[1]) : null;
  };

  const store = (files, body) =>
    fixture.withStore({ '.claude/protocol.md': ROUTER, [STORE]: RECORD, ...files }, body);

  check('a boot tier under the budget reports its figure and exits zero', () =>
    store({ 'CLAUDE.md': '# Entry\n\n- **Kept small** deliberately.\n' }, (root) => {
      const result = fixture.run(builder(), root);
      const offending = [];
      if (result.status !== 0) offending.push(`the run exited ${result.status}: ${result.output.trim()}`);
      if (tier(result.stdout) === null) offending.push('the boot tier figure was not reported');
      return offending;
    }),
  );

  check('a boot tier over the budget fails the build, naming the figure and the budget', () =>
    store({ 'CLAUDE.md': `# Entry\n\n${'x'.repeat(40000)}\n` }, (root) => {
      const result = fixture.run(builder(), root);
      const offending = [];
      if (result.status === 0) offending.push('a boot tier over the budget was accepted');
      // Read off the failure alone, not the joined streams. The report on
      // standard output already prints the figure, so a check over both is
      // satisfied by the report and cannot see whether the failure names it.
      if (!/\b40\d{3}\b/.test(result.stderr)) offending.push('the failure does not name the measured figure');
      if (!/\b12000\b|\b12,000\b/.test(result.stderr)) offending.push('the failure does not name the budget');
      return offending;
    }),
  );

  // Failing is not refusing. A tier over budget leaves every record addressable
  // and the ledger correct, so the report still prints and the ledger is still
  // written — whoever has to answer for the crossing needs the figure and the
  // rows, and refusing would discard a good index to report a true thing under
  // a false heading.
  check('a build failed by the budget still prints its report and writes its ledger', () =>
    store({ 'CLAUDE.md': `# Entry\n\n${'x'.repeat(40000)}\n` }, (root) => {
      const result = fixture.run(builder(), root);
      const offending = [];
      if (result.status === 0) offending.push('the over-budget store did not fail');
      if (tier(result.stdout) === null) offending.push('the report was discarded along with the failure');
      if (/^the store was refused/m.test(result.stderr)) {
        offending.push('an over-budget tier was reported as a refused store');
      }
      if (fixture.read(root, '.claude/position/ledger.json') === null) {
        offending.push('the ledger was not written');
      }
      return offending;
    }),
  );

  // Membership, which is what makes the figure mean anything: a scope announced
  // in prose but not in frontmatter is paid on every turn and enforced on none,
  // so the field is what counts rather than what the rule says about itself.
  check('a path-scoped rule is outside the tier, and an unconditional one is inside it', () => {
    const scoped = store({ 'CLAUDE.md': '# Entry\n', '.claude/rules/scoped.md': rule(5000, true) }, (root) =>
      [tier(fixture.run(builder(), root).stdout)],
    )[0];
    const unconditional = store({ 'CLAUDE.md': '# Entry\n', '.claude/rules/always.md': rule(5000, false) }, (root) =>
      [tier(fixture.run(builder(), root).stdout)],
    )[0];
    const bare = store({ 'CLAUDE.md': '# Entry\n' }, (root) => [tier(fixture.run(builder(), root).stdout)])[0];

    const offending = [];
    if (scoped === null || unconditional === null || bare === null) return ['a figure was not reported'];
    if (scoped !== bare) offending.push(`a path-scoped rule moved the figure by ${scoped - bare}`);
    if (unconditional <= bare) offending.push('an unconditional rule did not move the figure');
    return offending;
  });

  // The other two figures keep the opposite treatment, and the pages say why:
  // they mix content that must grow with content that must not, where the tier
  // is authored prose throughout.
  check('the instruction count and the row sizes still fail on nothing', () => {
    const many = Array.from(
      { length: 60 },
      (_, index) => `## Thing ${index}\n\n- **Thing ${index} is stated** and nothing restates it.\n`,
    ).join('\n');
    return store(
      {
        'CLAUDE.md': '# Entry\n',
        [STORE]: `---\nowner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [implement]\n---\n\n${many}`,
      },
      (root) => {
        const result = fixture.run(builder(), root);
        const offending = [];
        if (result.status !== 0) offending.push(`a large corpus failed the build: ${result.output.trim()}`);
        if (!/^instructions: 60$/m.test(result.stdout)) {
          offending.push(`the instruction count was not reported as 60: ${result.stdout.trim()}`);
        }
        return offending;
      },
    );
  });

  // A bare number is indistinguishable from one set too tight, and the cheapest
  // response to a crossing is to raise it. The basis is what lets a later reader
  // tell a real addition from a bound that never had headroom.
  check('the budget states its basis where it is declared', () => {
    const source = read('scripts/build-knowledge-store.js');
    const at = source.search(/^const BOOT_BUDGET = \d+;/m);
    if (at === -1) return ['the builder declares no BOOT_BUDGET'];
    // The comment block above the declaration, however long it runs. Bounded by
    // the previous block's end rather than by a character count, which the
    // first version guessed at and got wrong.
    const before = source.slice(0, at);
    const doc = before.slice(before.lastIndexOf('/**'));
    if (!/\*\//.test(doc)) return ['the budget carries no comment block'];
    return /\d{4,}/.test(doc)
      ? []
      : ['the budget carries no measured figure to justify it'];
  });

  // Single-home across the two documents that say which figures gate a build.
  check('the specification and the scripts page agree on which figures fail the build', () => {
    const offending = [];
    const spec = read('specs.md');
    const page = read('skills/configure/SCRIPTS.md');
    if (!/boot budget is asserted[\s\S]{0,200}?fails the build/.test(spec)) {
      offending.push('specs.md no longer says exceeding the boot budget fails the build');
    }
    // Bounded to the section itself. A character window ran past the heading
    // into the section that follows it, where the boot tier now correctly
    // lives, so the guard reported the fix as the fault.
    const section = page.match(/### What it reports, and never fails on\n([\s\S]*?)(?=\n### )/);
    if (!section) offending.push('the scripts page no longer has a reports-only section');
    else if (/boot tier/i.test(section[1])) {
      offending.push('the scripts page still files the boot tier under what it never fails on');
    }
    // Matched on the claim rather than on either page's phrasing: the
    // specification writes "the corpus's instruction count is reported and
    // never thresholded" and the page writes "Reported and never thresholded",
    // and a pattern fitted to one is silent against the other.
    for (const [name, text] of [['specs.md', spec], ['SCRIPTS.md', page]]) {
      if (!/never thresholded/.test(text)) {
        offending.push(`${name} no longer says the instruction count is never thresholded`);
      }
    }
    return offending;
  });
});

ticket('settlement/04', 'supersession is checked for symmetry, and a pointer leaves the edge list', (check) => {
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');

  /**
   * A decision file: one record for the whole file, keyed on its title heading,
   * with its id seeded rather than minted.
   *
   * Seeded because a refused run writes nothing — the builder validates before
   * it writes — so an assertion that read an id back after a refusal would find
   * none and skip itself.
   */
  const decision = (title, id, edges) =>
    `---\nowner: repository\ntype: decision\nsubject: fixture\n${edges}spans:\n  - ${title.toLowerCase().replace(/ /g, '-')}: ${id}\n---\n\n` +
    `# ${title}\n\n- **This decision is stated once** and nothing restates it.\n`;

  const pair = (first, second) =>
    fixture.withStore({ '.claude/knowledge/d1.md': first, '.claude/knowledge/d2.md': second }, (root) =>
      [fixture.run(builder(), root)],
    )[0];

  check('a correctly paired supersession builds', () => {
    const result = pair(
      decision('First decision', 'aaa111', 'supersedes: [bbb222]\n'),
      decision('Second decision', 'bbb222', 'superseded-by: [aaa111]\n'),
    );
    return result.status === 0 ? [] : [`a symmetric pair was refused: ${result.output.trim()}`];
  });

  check('a supersedes with no superseded-by in return fails, naming both records and the missing end', () => {
    const result = pair(
      decision('First decision', 'aaa111', 'supersedes: [bbb222]\n'),
      decision('Second decision', 'bbb222', ''),
    );
    const offending = [];
    if (result.status === 0) offending.push('a half-written supersession was accepted');
    for (const expected of ['d1.md', 'd2.md', 'aaa111', 'bbb222', 'superseded-by']) {
      if (!result.output.includes(expected)) offending.push(`the refusal does not name ${expected}`);
    }
    return offending;
  });

  // The mirror image, asserted apart: a guard covering both directions passes
  // while either holds, and the half somebody forgets is the half that was
  // never the file being edited.
  check('a superseded-by with no supersedes in return fails identically', () => {
    const result = pair(
      decision('First decision', 'aaa111', 'superseded-by: [bbb222]\n'),
      decision('Second decision', 'bbb222', ''),
    );
    const offending = [];
    if (result.status === 0) offending.push('a half-written supersession was accepted in the other direction');
    if (!result.output.includes('supersedes')) offending.push('the refusal does not name the missing end');
    return offending;
  });

  // Resolution and symmetry are two checks, and the specification says plainly
  // that the second is not implied by the first. They must be distinguishable
  // or a reader cannot tell a typo from a half-written pair.
  check('an unresolved supersession edge fails with its own message, distinct from an asymmetry', () => {
    const unresolved = pair(
      decision('First decision', 'aaa111', 'supersedes: [zzz999]\n'),
      decision('Second decision', 'bbb222', ''),
    );
    const asymmetric = pair(
      decision('First decision', 'aaa111', 'supersedes: [bbb222]\n'),
      decision('Second decision', 'bbb222', ''),
    );
    const offending = [];
    if (unresolved.status === 0) offending.push('an edge citing an id no record carries was accepted');
    if (!/no record carries/.test(unresolved.output)) {
      offending.push('an unresolved edge is not reported as citing an id no record carries');
    }
    if (/no record carries/.test(asymmetric.output)) {
      offending.push('an asymmetric pair is reported as though its target did not exist');
    }
    return offending;
  });

  // Symmetry is checked on supersession alone. The other edges are one-directional
  // by design — a ticket's blocker does not declare what it blocks — so requiring
  // a return edge there would refuse every correct store.
  // `blocked-by` rather than `falsifies`: falsification became the second
  // symmetric pair, and a store the build must refuse would make this assertion
  // and that refusal contradict each other. A blocker genuinely declares nothing
  // about what it blocks, so it is the edge this claim is actually about.
  check('a one-directional edge is not held to symmetry', () => {
    const result = pair(
      decision('First decision', 'aaa111', 'blocked-by: [bbb222]\n'),
      decision('Second decision', 'bbb222', ''),
    );
    return result.status === 0 ? [] : [`a one-directional edge was held to symmetry: ${result.output.trim()}`];
  });

  // A pointer names a path and an edge names an id, because a pointer targets
  // the Codebase and the Codebase has no ids. Two documents listed pointers
  // among the id-resolving edges, contradicting three others and the builder.
  // Compared against the builder's own list rather than scanned for a forbidden
  // word. A keyword scan cannot tell a line that *lists* `sources` among the
  // edges from one that says it is *not* one — and the corrected lines say
  // exactly that, so the first version reported the fix as the fault.
  //
  // The enumeration is a *contiguous* run of backticked names — `a`, `b`, and
  // `c` — compared whole. Comparing the leading run instead was the first
  // version, and it was silent when a pointer field was appended at the end:
  // the first five still matched, so the prefix said nothing about the sixth.
  //
  // A run counts as an edge enumeration only when every member is a field name
  // in this family — otherwise the type vocabulary, the triage labels, and a
  // list of git subcommands all read as edge lists, which is what happened when
  // length alone selected them. Three is the floor: it keeps an ordinary pair
  // like "`supersedes` and `superseded-by`" out, while still catching an
  // enumeration that dropped an edge rather than adding one.
  check('every document enumerating the resolved edges lists the ones the builder resolves', () => {
    const source = read('scripts/build-knowledge-store.js');
    const declared = source.match(/const EDGES = \[([^\]]*)\]/);
    if (!declared) return ['the builder declares no EDGES list'];
    const edges = [...declared[1].matchAll(/'([^']+)'/g)].map((match) => match[1]);
    const expected = edges.join(', ');

    const FAMILY = new Set([...edges, 'sources', 'span-sources', 'deviates-from']);
    const RUN = /`[a-z-]+`(?:(?:,\s*|\s+)(?:and\s+)?`[a-z-]+`)+/g;
    const offending = [];
    for (const file of [...markdownUnder(SKILLS), 'specs.md']) {
      read(file)
        .split('\n')
        .forEach((line, index) => {
          for (const run of line.match(RUN) || []) {
            const named = [...run.matchAll(/`([a-z-]+)`/g)].map((match) => match[1]);
            if (named.length < 3 || !named.every((name) => FAMILY.has(name))) continue;
            if (named.join(', ') !== expected) {
              offending.push(
                `${file}:${index + 1} — enumerates ${named.join(', ')}, the builder resolves ${expected}`,
              );
            }
          }
        });
    }
    return offending;
  });

  check('the builder resolves no pointer field as an edge', () => {
    const source = read('scripts/build-knowledge-store.js');
    const edges = source.match(/const EDGES = \[([^\]]*)\]/);
    if (!edges) return ['the builder declares no EDGES list'];
    return /'sources'|'span-sources'/.test(edges[1])
      ? ['the builder resolves a pointer field as an edge']
      : [];
  });

  check('a pointer naming a path that does not exist is counted and named, and the run exits zero', () =>
    fixture.withStore(
      { '.claude/knowledge/d1.md': decision('First decision', 'aaa111', 'sources: [src/gone.ts]\n') },
      (root) => {
        const result = fixture.run(builder(), root);
        const offending = [];
        if (result.status !== 0) offending.push(`a broken pointer failed the build: ${result.output.trim()}`);
        if (!/^broken pointers: 1$/m.test(result.stdout)) offending.push('the broken pointer was not counted');
        if (!result.stdout.includes('src/gone.ts')) offending.push('the broken pointer was not named');
        return offending;
      },
    ),
  );
});


ticket('conversion/04', 'the copied templates become framework-store records', (check) => {
  // The fifteen files that stopped being templates, and the record each became.
  // Named rather than derived from the store: a list read out of what it checks
  // goes green the moment a record is deleted, which is the loss it exists for.
  const DEPARTED = {
    'modes/design.template.md': 'mode-design.md',
    'modes/discussion.template.md': 'mode-discussion.md',
    'modes/implementation.template.md': 'mode-implementation.md',
    'modes/maintenance.template.md': 'mode-maintenance.md',
    'modes/prototype.template.md': 'mode-prototype.md',
    'modes/research.template.md': 'mode-research.md',
    'modes/review.template.md': 'mode-review.md',
    'policies/context.template.md': 'context.md',
    'policies/decisions.template.md': 'decisions.md',
    'policies/evidence.template.md': 'evidence.md',
    'policies/knowledge.template.md': 'knowledge.md',
    'policies/maps.template.md': 'maps.md',
    'policies/specs.template.md': 'specs.md',
    'policies/sub-agents.template.md': 'sub-agents.md',
    'policies/tickets.template.md': 'tickets.md',
  };

  // The inventory taken before the rewrite, and never from the store: a manifest
  // derived from what it checks cannot detect a loss in it.
  const INVENTORY_TOTAL = 168;
  // Four bullets naming the change record's parts. They elaborate the norm above
  // them and are indented for it, which is the corpus's own idiom for
  // elaboration and the one shape the imperative count deliberately skips.
  const ELABORATION = 4;
  const STORE_IMPERATIVES = 145;

  // 149 guarded, 19 retired, 168 in the pre-conversion inventory.
  const CONVERTED_NORMS = {
    'context.md': [
      "A term owned by a stage is defined in that stage's guide and nowhere else",
      "A term that fits two rows is being used in two senses: split it and name each",
      "Context is orientation, never documentation",
      "Never write in code, API shapes, function names, file inventories, or implementation walkthroughs",
      "Be opinionated: one term per concept, the rest under `_Avoid_`",
      "A definition is one or two sentences saying what the term IS",
      "Only terms specific to this repository",
      "Boundaries state ownership and the rules that cross it",
      "Constraints are the ones that outlive the current implementation",
      "A Source Pointer is a navigation coordinate, never a claim",
      "`load-when` states when to load the file, never what it is about",
      "A Domain Context exists only where a domain has its own vocabulary, principles, or ownership",
    ],
    'decisions.md': [
      "A single paragraph is enough",
      "Optional sections only where they earn it",
      "used unchanged and deliberately not repeated here",
      "Highest existing number plus one.",
      "Whenever decisions move — in from another layout, or across a change to AEP's own — preserve each ADR's existing number and slug",
      "A changed mind is a new file, and supersession is written at both ends, in the same change",
      "Writing only the new end is the tempting half, because that is the file being edited",
      "A convention is not a decision",
    ],
    'evidence.md': [
      "Evidence is the trail showing how a claim was earned.",
      "A kind earns its directory when it has a file",
      "Read the directory before producing more",
      "The account itself is frozen",
      "A finding records its own consumption, and the obligation is the `falsifies` field's",
      "Once the falsified knowledge is healed, the finding carries a `Consumed:` line naming where the healing landed",
      "Whoever heals writes the line, in the same change as the healing",
      "A finding whose consumption cannot be established stays unmarked and reads as waiting",
      "A discussion records the grill that ended without a decision: what was asked, what was assumed, what was weighed, and what stayed open",
      "A record, dated, never maintained",
      "A drift finding records what was checked, against which commit, and what it falsifies",
      "Written by whoever finds the drift, on whatever branch they stand on, without interrupting the work that surfaced it.",
      "Where a live design effort owns the area, the finding is indexed on that effort's map",
      "Throwaway prototype code is not evidence",
      "A gated evidence block stops the design; ungated evidence runs in the background",
      "Durable findings graduate out of evidence into knowledge, and `/design` owns graduation",
      "`/research` and `/prototype` never write Context directly",
      "A discussion graduates the same way: when its parked question later resolves, `/design` writes the Decision",
      "Graduation is a copy of what is durable, never a move",
    ],
    'knowledge.md': [
      "`/design` writes vocabulary and Decisions as they resolve, never batched at the end",
      "A Decision is offered only when it clears the bar in",
      "`/implement` writes only the concepts, boundaries, and Source Pointers its change moved",
      "`/commit` heals what its diff falsified and authors nothing new",
      "A falsified Decision is never healed inline: write a drift finding and carry on",
      "A change that moves no concept updates no knowledge",
      "Implementation detail never lands in Context",
    ],
    'maps.md': [
      "Read `What a ticket is` in",
      "Branch-bound",
      "Tracked intent",
      "A tracker policy with no such declaration predates it: a configuration gap",
      "Every ticket on a map resolves a decision, never a slice of a build",
      "Name the destination first",
      "The map lives inside the effort it charts",
      "An index, not a store",
      "Until the map exists, the design document holds the proposal and is the map",
      "Open tickets are not listed",
      "On a branch-bound tracker a decision ticket is a section of the design document",
      "Each ticket is sized to one fresh context window; the answer is written on resolution, never in the body.",
      "Where the tracker assigns ids, its id is the only number",
      "A decision ticket's `Blocked by:` is answer-gating, never a stacking instruction",
      "Every ticket is HITL — worked with a human who speaks for themselves — or AFK, driven alone.",
      "The map is deliberately incomplete: don't chart what you cannot see yet.",
      "Fog or ticket — the test is whether the question can be stated precisely now",
      "Fog gathers only toward the destination",
      "A drift finding in the effort's area gets one task-list line under `Drift found`",
      "On GitHub the line goes in the map's issue body, never a comment",
      "Expect other sessions on the map concurrently",
      "The map is done when every remaining decision is settled or declared as a scoped increment on the build ticket that can answer it",
      "Hand back to step 5 of `/design`",
    ],
    'specs.md': [
      "A spec is the reasoning behind the tickets",
      "`sources` is a list, one entry per line.",
      "A spec with nothing to point at declares `sources: []`",
      "No file paths outside the `sources` field, and no code.",
      "Use the repository's vocabulary.",
      "A section with nothing to say gets deleted, not padded.",
      "The spec is not the decision record.",
      "Only the status field ever moves.",
      "`implemented` is the one status set outside conversation",
      "It is a field rather than a line because a stage writes it",
      "It declares `reconstructed: true`, and says so in its opening lines",
      "Derive every statement from the effort's own resolved tickets, the Decisions it produced, and what is in the tree",
      "The frozen-reasoning rule holds from the moment it is written",
    ],
    'sub-agents.md': [
      "A sub-agent is a child that an orchestrating stage dispatches to work part of what that stage was doing.",
      "The part is either a portion of one ticket or a whole ticket",
      "A ticket child that finds a fan-out declared on its ticket declines it and records the decline, then builds the whole ticket itself.",
      "A dispatched child inherits the entrypoint hierarchy the parent loaded, including the always-on rules.",
      "Material reached by pointer is named in the brief, never quoted into it",
      "So this policy narrows what a child may do.",
      "It reads the Codebase, Context, and Decisions, and it verifies at use exactly as a session does.",
      "A knowledge statement it checks and finds false becomes a drift finding.",
      "A child writes no knowledge layer.",
      "A child claims nothing, commits nothing, pushes nothing, and integrates nothing.",
      "No agent's message is another agent's consent.",
      "A child dispatches nobody.",
      "A decision a child reaches is recorded and stopped on, never taken.",
      "A ticket child neither creates nor commits to the branch it works on.",
      "Exactly two things may be requested",
      "The menu is closed, and that is the whole safety property.",
      "A request spends the brief's cap.",
      "No child can send anything to anyone.",
      "Outward, the question travels attributed",
      "Inward, the answer travels verbatim.",
      "An answer that cannot be relayed faithfully — it changes what the whole run is doing rather than what one child is doing — stops the child",
      "The brief is the only channel from parent to child that opens unasked.",
      "Incomplete is a defect in the dispatch, not a matter of style.",
      "The child writes a change record and returns only its path and a compressed summary.",
      // The change record's four parts. Carried at their full width because the
      // bold clause alone — "why" above all — matches ordinary prose in every
      // other norm in this file, and a phrase that matches everywhere detects
      // nothing.
      "**what changed** — every path, and what was done to it",
      "**why** — the reasoning that cannot be recovered from the diff",
      "**what it could not do** — anything the brief asked for that is not finished",
      "**any decision it stopped on** — the question, and what answering it would have needed",
      "The record is a manifest, not a report.",
      "A change record is Position.",
    ],
    'tickets.md': [
      "and it is the only place that records it",
      "One ticket per file, or one per issue — never a single combined file",
      "Engineering knowledge lives in the Codebase, in Context, and in Decisions — never in a ticket body.",
      "No implementation diary",
      "The id is the filename",
      "`blocked-by` is a list of bare ids, and `[]` is a positive statement",
      "These fields are the local-markdown form, and only that.",
      "On GitHub the states ride the issue's native state — zero new labels.",
      "On a shared tracker the merge resolves the ticket, not AEP.",
      "Triage roles — `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix` — never appear on a build ticket: this is not the triage vocabulary.",
      "There is no `claimed` state, and a tracker never records one.",
      "Assignment — which human owns delivering a ticket — is a tracker fact, and it is theirs",
      "It is not the Claim and does not overlap it.",
      "A ticket must have an outcome someone can observe when it closes",
      "Deepen, don't widen.",
      "One design run, one root.",
      "A ticket this workflow creates on a shared tracker states an outcome outside the protocol directory.",
      "The test is the diff",
      "Where a protocol-only outcome needs a change outside `.claude/`, the diff decides and the work is not protocol-only",
      "Protocol-only work rides its consumer instead.",
      "The rule reads the diff, never the commit type",
      "A criterion is checkable by someone who did not write the code.",
      "The role is a shipped agent definition, named rather than described.",
      "The declaration names roles and ownership, and stops.",
      "A ticket with no `## Fan-out` section is a ticket built by one instance",
      "A fan-out and an increment needing a human do not run together.",
      "Vertical slices, not horizontal ones.",
      "Each slice is demoable or verifiable on its own",
      "Prefactoring goes first.",
      "Every ticket after the first declares at least one of these.",
      "`Blocked by: —` is a positive statement",
      "Read the tickets that already exist before writing the edges",
      "Only real gates.",
      "`/implement` picks from the frontier, and defines it",
      "Scan the set when the tickets are cut: any ticket that is neither the root nor carries an edge is a stray",
      "A ticket names no file paths and holds no code.",
      "Set `Status: obsolete` and add a one-line reason — never delete it.",
    ],
  };

  const RETIRED_NORMS = {
    "The routing table alone — nothing else goes in this file":
      "the routing table is a query, not a file",
    "The table is generated from the fields each context declares, never written by hand":
      "the routing table is a query, not a file",
    "A generated file is never hand-edited":
      "the routing table is a query, not a file",
    "Every file under `contexts/` has exactly one row, including `repository.md` itself":
      "the routing table is a query, not a file",
    "Rows group as: `repository.md` first, flat domains in filename order, then each Project Context as a labelled group":
      "the routing table is a query, not a file",
    "A group's label row carries the directory name and nothing else, its cells blank":
      "the routing table is a query, not a file",
    "A Project Context — a directory under `contexts/` — earns its directory on the same test":
      "the store is flat and grouping is a declared field",
    "Structure is carried by the filesystem; the routing table carries the load conditions":
      "the store is flat and grouping is a declared field",
    "The status column answers *is this live* without opening anything":
      "the generated index is a query now",
    "A stage routes through the index and opens only the ADRs it names":
      "the generated index is a query now",
    "One index at `.claude/evidence/map.md`, spanning all five kinds":
      "the generated index is a query now",
    "Rows sit in filename order — date order — with `kind` breaking ties":
      "the generated index is a query now",
    "The index is generated, never hand-edited":
      "the generated index is a query now",
    "The index carries `waiting` or `consumed` per finding, so a waiting one is seen without opening anything":
      "the generated index is a query now",
    "The index reports the line and decides nothing":
      "the generated index is a query now",
    "The status column answers *which of these is live* without opening one":
      "the generated index is a query now",
    "It is generated, never hand-edited":
      "the generated index is a query now",
    "The script that regenerates it is copied from the framework, and the directory it sits in takes nothing else.":
      "the regenerator retires, and the scripts-directory constraint is homed in SCRIPTS.md",
    "The index sits beside the specs it indexes":
      "the generated index is a query now",
  };

  /** Every heading a record file carries, outside fenced code. */
  const headingsOf = (text) => {
    const out = [];
    let fenced = false;
    for (const line of text.split('\n')) {
      if (/^\s*(```|~~~)/.test(line)) {
        fenced = !fenced;
        continue;
      }
      if (fenced) continue;
      const match = line.match(/^(#{1,2})\s+(.+?)\s*$/);
      if (match) out.push({ level: match[1].length, text: match[2] });
    }
    return out;
  };

  const anchorOf = (text) => text.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');

  /** The `spans` mapping a record file declares, anchor to id. */
  const spansOf = (text) => {
    const out = new Map();
    const block = text.match(/^spans:\n((?:\s+- .*\n)+)/m);
    if (!block) return out;
    for (const line of block[1].split('\n')) {
      const match = line.match(/^\s+-\s+(.+?):\s*(\S+)\s*$/);
      if (match) out.set(match[1], match[2]);
    }
    return out;
  };

  /**
   * A record file with its headings and fenced code removed.
   *
   * The guards below search this rather than the whole file, and the reason is
   * the failure this repository keeps producing: each heading here was written
   * from the words of the norm beneath it, so a heading travels *with* its norm
   * and a guard reading the whole file matches the heading after the norm is
   * gone. Twenty-two of these went silent against a deletion before the search
   * was narrowed to the lines that carry the statement.
   */
  const normText = (file) => {
    const out = [];
    let fenced = false;
    for (const line of read(file).split('\n')) {
      if (/^\s*(```|~~~)/.test(line)) {
        fenced = !fenced;
        continue;
      }
      if (fenced || /^#{1,6}\s/.test(line)) continue;
      out.push(line);
    }
    return out.join('\n');
  };

  /** Norm-shaped imperatives, by the rule the builder counts on. */
  const countImperatives = (text) => {
    let count = 0;
    let fenced = false;
    let previousBlank = true;
    for (const line of text.split('\n')) {
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
      if (/^- \*\*/.test(line) || (previousBlank && /^\*\*/.test(line))) count += 1;
      previousBlank = false;
    }
    return count;
  };

  // Matched on the subject rather than the filename: a guide whose records serve
  // different stages is several files now, each named for its audience, and
  // every one of them stands in for the template that departed. The subject is
  // recovered by stripping what the file's own `stages` field already states.
  check('every departed template is gone, and a record stands in its place', () => {
    const offending = [];
    const subjects = new Set();
    for (const file of markdownUnder(KNOWLEDGE)) {
      const fields = frontmatter(file);
      if (fields) subjects.add(fields.subject);
    }
    for (const [template, record] of Object.entries(DEPARTED)) {
      if (fs.existsSync(resolveShipped(`${SKILLS}/configure/${template}`))) {
        offending.push(`${template} is still a template`);
      }
      const subject = record.replace(/\.md$/, '');
      if (!subjects.has(subject)) offending.push(`no record in the framework store is the ${subject} guide`);
    }
    return offending;
  });

  check('every norm declares a firing condition from the closed set, and no other type declares one', () => {
    const CLOSED = new Set(['every-turn', 'posture', 'stage', 'path']);
    const offending = [];
    for (const file of markdownUnder(KNOWLEDGE)) {
      const fields = frontmatter(file);
      if (!fields) {
        offending.push(`${file} declares no frontmatter`);
        continue;
      }
      const condition = fields['fires-when'];
      if (fields.type === 'norm') {
        if (!condition) offending.push(`${file} is a norm and declares no firing condition`);
        else if (!CLOSED.has(condition)) offending.push(`${file} declares "${condition}", outside the closed set`);
      } else if (condition) {
        offending.push(`${file} is a ${fields.type} and declares a firing condition`);
      }
    }
    return offending;
  });

  check('every heading in the store carries a minted id', () => {
    const offending = [];
    for (const file of markdownUnder(KNOWLEDGE)) {
      const text = read(file);
      const spans = spansOf(text);
      const headings = headingsOf(text);
      const carried = headings.some((heading) => heading.level === 2)
        ? headings.filter((heading) => heading.level === 2)
        : headings.slice(0, 1);
      for (const heading of carried) {
        const id = spans.get(anchorOf(heading.text));
        if (id === undefined) offending.push(`${file} — "${heading.text}" carries no id`);
        else if (!/^[a-z0-9]{6}$/.test(id)) {
          offending.push(`${file} — "${heading.text}" carries "${id}", which is not a minted id`);
        }
      }
    }
    return offending;
  });

  check('the seven postures each ship as a record naming themselves', () => {
    const NAMED = ['design', 'discussion', 'implementation', 'maintenance', 'prototype', 'research', 'review'];
    const offending = [];
    for (const posture of NAMED) {
      const file = `${KNOWLEDGE}/mode-${posture}.md`;
      const fields = frontmatter(file);
      if (!fields) {
        offending.push(`${posture} — no record`);
        continue;
      }
      if (fields['fires-when'] !== 'posture') offending.push(`${posture} — fires on ${fields['fires-when']}`);
      if (!inlineList(fields.postures).includes(posture)) offending.push(`${posture} — its record does not name it`);
    }
    return offending;
  });

  // The apparatus existed only because framework files were copied, and under
  // 2.0 nothing is copied. A stamp left on a record is a comparison somebody
  // will eventually write against a copy that will never exist.
  check('no record carries a release stamp or an installed-copy comparison', () => {
    const offending = [];
    for (const file of markdownUnder(KNOWLEDGE)) {
      const text = read(file);
      const fields = frontmatter(file);
      if (fields && fields.version !== undefined) offending.push(`${file} declares version ${fields.version}`);
      if (/Installed by `?\/configure/.test(text)) offending.push(`${file} names its install path`);
      if (/copied as-is|copied verbatim/i.test(text)) offending.push(`${file} describes itself as copied`);
    }
    return offending;
  });

  check('the pre-conversion inventory is fully accounted', () => {
    const guarded = Object.values(CONVERTED_NORMS).reduce((sum, list) => sum + list.length, 0);
    const retired = Object.keys(RETIRED_NORMS).length;
    const offending = [];
    if (guarded + retired !== INVENTORY_TOTAL) {
      offending.push(
        `${guarded} guarded plus ${retired} retired is ${guarded + retired}, and the inventory held ${INVENTORY_TOTAL}`,
      );
    }
    for (const [clause, reason] of Object.entries(RETIRED_NORMS)) {
      if (!reason) offending.push(`a norm retired with no reason recorded: ${clause}`);
    }
    return offending;
  });

  // Norms added to the store after the conversion, one line per ticket that
  // added one. The inventory and the store count above stay frozen at what the
  // conversion produced -- moving them to absorb a later addition would let a
  // norm be lost and another added in the same change with nothing to show for
  // it. Named rather than counted, so the reconciliation says which growth it
  // was told about.
  const ADDED_SINCE = {
    'corrections/01': [
      'a contradicted ADR names what contradicted it',
      'a contradiction is not always a changed mind',
    ],
  };

  check("the store's imperative count reconciles with the inventory", () => {
    const counted = markdownUnder(KNOWLEDGE).reduce((sum, file) => sum + countImperatives(read(file)), 0);
    const retired = Object.keys(RETIRED_NORMS).length;
    const added = Object.values(ADDED_SINCE).reduce((sum, list) => sum + list.length, 0);
    const offending = [];
    if (counted !== STORE_IMPERATIVES + added) {
      offending.push(
        `the store states ${counted} imperatives, and the conversion produced ${STORE_IMPERATIVES} ` +
          `with ${added} declared as added since`,
      );
    }
    if (counted + retired + ELABORATION !== INVENTORY_TOTAL + added) {
      offending.push(
        `${counted} plus ${retired} retired plus ${ELABORATION} elaboration is ${counted + retired + ELABORATION}, ` +
          `and the inventory held ${INVENTORY_TOTAL} with ${added} added since`,
      );
    }
    return offending;
  });

  // The `postures` field is this ticket's own: seven records declare a firing
  // condition that named nothing it fires on, which is the hole `stages` closed
  // for the other half of the vocabulary.
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');
  const STORE = '.claude/knowledge/a.md';

  const ROUTER = [
    '---',
    'owner: framework',
    '---',
    '',
    '# Workflow protocol',
    '',
    '| Stage | Mode | Guides it reads |',
    '| --- | --- | --- |',
    '| `/implement` | implementation | the records its row selects |',
    '| `/commit` | maintenance | the records its row selects |',
    '',
  ].join('\n');

  const norm = (front) =>
    `---\n${front}\n---\n\n## First thing\n\n- **The first thing is stated once** and nothing restates it.\n`;

  const withRouter = (files, body) => fixture.withStore({ '.claude/protocol.md': ROUTER, ...files }, body);

  check('a posture norm naming its postures builds, and the ledger holds them as a list', () =>
    withRouter(
      { [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: posture\npostures: [implementation]') },
      (root) => {
        const offending = [];
        const result = fixture.run(builder(), root);
        if (result.status !== 0) return [`the run exited ${result.status}: ${result.output.trim()}`];
        const raw = fixture.read(root, '.claude/position/ledger.json');
        if (raw === null) return ['no ledger was written'];
        const entry = JSON.parse(raw).records[0];
        if (!Array.isArray(entry.postures)) offending.push(`postures came back as ${JSON.stringify(entry.postures)}`);
        else if (entry.postures.join() !== 'implementation') offending.push(`the ledger holds ${entry.postures.join()}`);
        return offending;
      },
    ));

  check('a posture norm naming no posture fails the build', () =>
    withRouter({ [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: posture') }, (root) => {
      const result = fixture.run(builder(), root);
      if (result.status === 0) return ['a posture norm naming no posture built'];
      return /fires when a posture holds and names no posture/.test(result.stderr)
        ? []
        : [`the refusal does not say what is missing: ${result.stderr.trim()}`];
    }));

  check('postures declared beside another firing condition fails the build', () =>
    withRouter(
      { [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [commit]\npostures: [maintenance]') },
      (root) => {
        const result = fixture.run(builder(), root);
        if (result.status === 0) return ['postures beside a stage condition built'];
        return /declares postures and its firing condition is "stage"/.test(result.stderr)
          ? []
          : [`the refusal does not name the condition it sat beside: ${result.stderr.trim()}`];
      },
    ));

  // Reported rather than refused, and one-directional: the record's own value is
  // the definition, so what a typo in one breaks shows up here as the router row
  // that can no longer reach it.
  check('a posture a router row names that no record defines is reported, and the run exits zero', () =>
    withRouter(
      { [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: posture\npostures: [discussion]') },
      (root) => {
        const offending = [];
        const result = fixture.run(builder(), root);
        if (result.status !== 0) offending.push(`an undefined posture failed the build: ${result.output.trim()}`);
        if (!/^postures no record defines: 2$/m.test(result.stdout)) {
          offending.push('the undefined postures were not counted');
        }
        if (!result.stdout.includes('implementation')) offending.push('the undefined posture was not named');
        return offending;
      },
    ));

  check('a store defining no posture reports none, having nothing to say about the router', () =>
    withRouter({ [STORE]: norm('owner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [commit]') }, (root) => {
      const result = fixture.run(builder(), root);
      if (result.status !== 0) return [`the run exited ${result.status}: ${result.output.trim()}`];
      return /^postures no record defines: 0$/m.test(result.stdout)
        ? []
        : ['a store holding no mode record reported on the router’s postures anyway'];
    }));

  /**
   * Every norm-shaped line of the guide a subject names, across the files it is
   * now cut into.
   *
   * The inventory's claim is that a norm survived the conversion, never which
   * file holds it — and a guide whose records serve different stages is several
   * files. Reading one filename would make the inventory fail on a split that
   * lost nothing, which is the guard being wrong rather than the store.
   */
  const subjectText = (subject) =>
    markdownUnder(KNOWLEDGE)
      .filter((file) => {
        const fields = frontmatter(file);
        if (!fields) return false;
        return fields.subject === subject;
      })
      .map((file) => normText(file))
      .join('\n');

  check('every norm the context inventory names survives in the store', () => {
    const text = subjectText('context');
    return CONVERTED_NORMS['context.md']
      .filter((phrase) => !text.includes(phrase))
      .map((phrase) => `lost: ${phrase}`);
  });

  check('every norm the decisions inventory names survives in the store', () => {
    const text = subjectText('decisions');
    return CONVERTED_NORMS['decisions.md']
      .filter((phrase) => !text.includes(phrase))
      .map((phrase) => `lost: ${phrase}`);
  });

  check('every norm the evidence inventory names survives in the store', () => {
    const text = subjectText('evidence');
    return CONVERTED_NORMS['evidence.md']
      .filter((phrase) => !text.includes(phrase))
      .map((phrase) => `lost: ${phrase}`);
  });

  check('every norm the knowledge inventory names survives in the store', () => {
    const text = subjectText('knowledge');
    return CONVERTED_NORMS['knowledge.md']
      .filter((phrase) => !text.includes(phrase))
      .map((phrase) => `lost: ${phrase}`);
  });

  check('every norm the maps inventory names survives in the store', () => {
    const text = subjectText('maps');
    return CONVERTED_NORMS['maps.md']
      .filter((phrase) => !text.includes(phrase))
      .map((phrase) => `lost: ${phrase}`);
  });

  check('every norm the specs inventory names survives in the store', () => {
    const text = subjectText('specs');
    return CONVERTED_NORMS['specs.md']
      .filter((phrase) => !text.includes(phrase))
      .map((phrase) => `lost: ${phrase}`);
  });

  check('every norm the sub-agents inventory names survives in the store', () => {
    const text = subjectText('sub-agents');
    return CONVERTED_NORMS['sub-agents.md']
      .filter((phrase) => !text.includes(phrase))
      .map((phrase) => `lost: ${phrase}`);
  });

  check('every norm the tickets inventory names survives in the store', () => {
    const text = subjectText('tickets');
    return CONVERTED_NORMS['tickets.md']
      .filter((phrase) => !text.includes(phrase))
      .map((phrase) => `lost: ${phrase}`);
  });
});

ticket('conversion/05', 'the derived guides and tool references become repository-owned records', (check) => {
  // What each template writes, and where the record it writes lands. Named
  // rather than read off the templates: a destination taken from the file it
  // checks agrees with that file however wrong the file is.
  const DERIVED = {
    'policies/tracker.template.md': '.claude/knowledge/tracker.md',
    'policies/version-control.template.md': '.claude/knowledge/version-control.md',
    'policies/records.template.md': '.claude/knowledge/records.md',
  };

  // The four tool references the plugin ships as sources to filter from. Each
  // is copied entry by entry into a `reference` record in the repository's
  // store, so each declares the format that record is held to.
  const TOOL_SOURCES = ['git.md', 'github.md', 'gitlab.md', 'graphite.md'];

  // The directories 2.0 removed. Read as a set here rather than as a regular
  // expression so the failure can name which one it found.
  const DEPARTED_DIRECTORIES = DEPARTED_AT_TWO;

  // The pre-conversion inventory, taken before the rewrite and never from the
  // templates: a manifest derived from what it checks cannot detect a loss in it.
  const INVENTORY_TOTAL = 45;

  const CONVERTED_NORMS = {
    'policies/tracker.template.md': [
      "**GitHub** and **local markdown** are both first-class; neither is a fallback. The `tracker` fi",
      "**Never guess the CLI** — a tracker operation with no entry in the tool references is a docs fe",
      "**Flat.** One spec per file, as a `spec` record in the store: `.claude/knowledge/<slug>.md`.",
      "**One per effort.** Each spec sits beside the tickets it governs: `.claude/tickets/<effort>/spe",
      "**Branch-bound.** One ticket becomes one branch, which lands as one unit of review. Work that p",
      "**Tracked intent.** A ticket is a unit of tracked work, branch or none. Decision tickets are ti",
      "**AEP reads Assignment and never writes it unasked.**",
      "**These are triage roles — an incoming issue's vocabulary, never the build lifecycle** — that v",
    ],
    'policies/version-control.template.md': [
      "**Confirm the declaration before relying on it** — one read: `ls .git/.graphite_repo_config` (e",
      "**Confirm by reading the filesystem, never by asking the stacking tool** — several of their com",
      "**A set may still be dispatched — dispatch is independent of landing.** The work is built in is",
      "**A spent worktree here is dirty by construction** — its work landed through integration and th",
      "**The name must encode the ticket id and be reproducible from the ticket alone** — the branch i",
      "**One pull request kind may change nothing outside `.claude/`: the design PR** — a single desig",
      "**A diff confined to `.claude/scripts/` is code, not scaffolding** — the workflow's own scripts",
    ],
    'policies/records.template.md': [
      "**`.claude/knowledge/`, flat — one directory, one rule, no placement judgement.** Grouping that",
      "**Nothing derived is committed.** The markdown is committed and diffed; the ledger the build pr",
      "**`type` is one of `norm`, `context`, `decision`, `evidence`, `reference`, `spec` in this store",
      "**`fires-when` is declared by a `norm` and by nothing else**, drawn from the closed vocabulary",
      "**A `stage` norm names its stages in `stages`, a list, and a stage no router row names fails th",
      "**`stages` is a list rather than a qualifier on `fires-when`, because the query filters on decl",
      "**A `posture` norm names its postures in `postures`, on the same terms, and the store defines t",
      "**`spans` maps a heading's anchor to that heading's id**, one entry per `##` heading in the fil",
      "**A `decision`, `spec`, or `evidence` record takes one id for the whole file**, and `spans` hol",
      "**An id is a short opaque token, written once by the build and never changed.** Six lowercase a",
      "**An author writes headings and no ids; the build mints what is missing.** That is what keeps a",
      "**No stage mints an id mid-session.** An id that appeared during a session is one nobody can ci",
      "**A heading carrying no id after the build has run fails the build**, and the failure names the",
      "**A `spans` entry naming an anchor no heading produces fails the build.** A heading rename ther",
      "**A record states one thing.** Two imperatives under one heading cannot be cited apart, so the",
      "**A norm-shaped imperative is a top-level bullet or paragraph opening with a bold clause** — th",
      "**The corpus's instruction count is reported and never thresholded.** A threshold is the confla",
      "**Authored size and generated size are separate figures.** A single total conflates prose that",
      "**Adding a decision moves the generated figure and leaves the authored one still.** That is the",
      "**Every declared edge is resolved by the build, and one that resolves to nothing fails it.** `s",
      "**Supersession is additionally checked for symmetry, which resolution does not imply.** A `supe",
      "**An unreferenced record is reported, never failed** — a norm nothing links to is legal, and on",
      "**Precedence is computed from a record's type, its store, and its firing condition, and never d",
      "**Only what binds carries a rank.** A `context`, `evidence`, `reference`, or `spec` record has",
      "**Firing breadth orders norms among themselves** — `posture`, then `stage`, then `path` — as th",
      "**A decision outranks a norm, and that conflict is productive**: the norm is amended in the sam",
      "**A cross-store contradiction is a declared deviation, never a rank.** A record declares `devia",
      "**A pointer names a path and an edge names an id, and the asymmetry is deliberate** — a pointer",
      "**`sources` declared on a file applies to every span in it; a `span-sources` entry overrides it",
      "**A pointer that no longer resolves is reported broken and never rewritten.** Recovery is a sea",
    ],
  };

  /**
   * A shipped file with its headings and fenced code removed.
   *
   * Repeated from the group above rather than shared: each group states the
   * inventory it converted and the reading that inventory is checked against,
   * and a helper reaching across groups makes one ticket's guard depend on
   * another ticket's text still being there.
   */
  const normText = (file) => {
    const out = [];
    let fenced = false;
    for (const line of read(file).split('\n')) {
      if (/^\s*(```|~~~)/.test(line)) {
        fenced = !fenced;
        continue;
      }
      if (fenced || /^#{1,6}\s/.test(line)) continue;
      out.push(line);
    }
    return out.join('\n');
  };

  /** Norm-shaped imperatives, by the rule the builder counts on. */
  const countImperatives = (text) => {
    let count = 0;
    let fenced = false;
    let previousBlank = true;
    for (const line of text.split('\n')) {
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
  };

  /** The frontmatter a template shows as the record it installs, as raw lines. */
  const installedFrontmatter = INSTALLED_FRONTMATTER;

  check('each derived template writes its record into the store', () => {
    const offending = [];
    for (const [template, destination] of Object.entries(DERIVED)) {
      const file = `${SKILLS}/configure/${template}`;
      if (!read(file).includes(destination)) offending.push(`${template} names no destination of ${destination}`);
    }
    return offending;
  });

  check('no shipped instruction names a departed directory as a destination', () => {
    const departed = new RegExp(`^\\.claude/(${DEPARTED_DIRECTORIES.join('|')})/`);
    return DESTINATIONS()
      .filter((entry) => departed.test(entry.target))
      .map((entry) => `${entry.at}  writes to ${entry.target}`);
  });

  check('each derived record declares repository ownership and no release stamp', () => {
    const offending = [];
    for (const template of Object.keys(DERIVED)) {
      const file = `${SKILLS}/configure/${template}`;
      const declared = installedFrontmatter(file);
      if (declared === null) {
        offending.push(`${template} shows no frontmatter for the record it installs`);
        continue;
      }
      if (!declared.includes('owner: repository')) offending.push(`${template} does not declare owner: repository`);
      const stamp = declared.find((line) => /^version:/.test(line));
      if (stamp !== undefined) offending.push(`${template} carries a release stamp: ${stamp}`);
    }
    return offending;
  });

  check('each derived record fires on stages the router carries', () => {
    const stages = new Set();
    for (const match of read(`${SKILLS}/configure/protocol.template.md`).matchAll(/^\|\s*`\/([a-z]+)`\s*\|/gm)) {
      stages.add(match[1]);
    }
    const offending = [];
    for (const template of Object.keys(DERIVED)) {
      const declared = installedFrontmatter(`${SKILLS}/configure/${template}`) || [];
      if (!declared.includes('type: norm')) offending.push(`${template} does not declare type: norm`);
      if (!declared.includes('fires-when: stage')) offending.push(`${template} does not fire on a stage`);
      const named = declared.find((line) => /^stages:/.test(line));
      if (named === undefined) {
        offending.push(`${template} names no stages`);
        continue;
      }
      for (const stage of inlineList(named.slice('stages:'.length).trim())) {
        if (!stages.has(stage)) offending.push(`${template} names the stage ${stage}, which no router row carries`);
      }
    }
    return offending;
  });

  check('the tool reference format declares a reference record', () => {
    const shown = read(`${SKILLS}/configure/TOOLS.md`).match(/```markdown\n---\n([\s\S]*?)\n---/);
    if (shown === null) return ['TOOLS.md shows no frontmatter for the record it derives'];
    const declared = shown[1].split('\n');
    const offending = [];
    if (!declared.includes('owner: repository')) offending.push('the format does not declare owner: repository');
    if (!declared.includes('type: reference')) offending.push('the format does not declare type: reference');
    return offending;
  });

  check('every shipped tool source declares what the record derived from it must', () => {
    const offending = [];
    for (const name of TOOL_SOURCES) {
      const file = `${SKILLS}/configure/tools/${name}`;
      const fields = frontmatter(file);
      if (fields === null) {
        offending.push(`${name} carries no frontmatter`);
        continue;
      }
      if (fields.owner !== 'repository') offending.push(`${name} declares owner ${fields.owner}`);
      if (fields.type !== 'reference') offending.push(`${name} declares type ${fields.type}`);
      if (fields.version !== undefined) offending.push(`${name} carries a release stamp`);
    }
    return offending;
  });

  check('the derivation reports a missing single-file test command as a configuration gap', () => {
    const text = read(`${SKILLS}/configure/TOOLS.md`);
    const offending = [];
    if (!/single-file test command/.test(text)) offending.push('TOOLS.md does not name the single-file test command');
    if (!/single-file test command is the one entry whose absence is reported/.test(text)) {
      offending.push('TOOLS.md does not say that its absence is reported');
    }
    if (!/configuration gap/.test(text)) offending.push('TOOLS.md does not call the absence a configuration gap');
    return offending;
  });

  check('the pre-conversion inventory is fully accounted', () => {
    const guarded = Object.values(CONVERTED_NORMS).reduce((sum, list) => sum + list.length, 0);
    return guarded === INVENTORY_TOTAL
      ? []
      : [`${guarded} norms are guarded and the inventory took ${INVENTORY_TOTAL}`];
  });

  // Norms added to a converted template after the conversion, one line per
  // ticket that added one. The inventory above stays frozen at what the 1.x
  // guides stated -- moving it to absorb a later addition would let a norm be
  // lost and another added in the same change with nothing to show for it.
  // Named rather than counted, so the reconciliation says which growth it was
  // told about.
  const ADDED_SINCE = {
    'conversion/09': ['a `path` norm names the globs it covers in `paths`'],
    'corrections/01': ['falsification is checked for symmetry too'],
    'addressing/07': [
      'every record declares what it is about',
      'two filename conventions, and which store each belongs to',
    ],
  };

  check("the converted templates' imperative count reconciles with the inventory", () => {
    const counted = Object.keys(DERIVED).reduce(
      (sum, template) => sum + countImperatives(read(`${SKILLS}/configure/${template}`)),
      0,
    );
    const added = Object.values(ADDED_SINCE).reduce((sum, list) => sum + list.length, 0);
    return counted === INVENTORY_TOTAL + added
      ? []
      : [
          `the templates state ${counted} imperatives, and the inventory took ${INVENTORY_TOTAL} ` +
            `with ${added} declared as added since`,
        ];
  });

  check('every norm the tracker inventory names survives the conversion', () => {
    const text = normText(`${SKILLS}/configure/policies/tracker.template.md`);
    return CONVERTED_NORMS['policies/tracker.template.md']
      .filter((phrase) => !text.includes(phrase))
      .map((phrase) => `lost: ${phrase}`);
  });

  check('every norm the version-control inventory names survives the conversion', () => {
    const text = normText(`${SKILLS}/configure/policies/version-control.template.md`);
    return CONVERTED_NORMS['policies/version-control.template.md']
      .filter((phrase) => !text.includes(phrase))
      .map((phrase) => `lost: ${phrase}`);
  });

  check('every norm the record-format inventory names survives the conversion', () => {
    const text = normText(`${SKILLS}/configure/policies/records.template.md`);
    return CONVERTED_NORMS['policies/records.template.md']
      .filter((phrase) => !text.includes(phrase))
      .map((phrase) => `lost: ${phrase}`);
  });

  // The deviation edge. Its target lives in the framework store, which a
  // repository's build cannot reach, so the two halves are asserted apart: what
  // is reported, and the one fault that needs nothing from the other store.
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');
  const STORE = '.claude/knowledge/a.md';

  const departing = (edge) =>
    `---\nowner: repository\ntype: norm\nsubject: fixture\nfires-when: path\npaths: [src/**]\n${edge}\n---\n\n` +
    '## First thing\n\n- **The first thing is stated once** and nothing restates it.\n';

  check('a deviation declaring no record fails the build', () =>
    fixture.withStore({ [STORE]: departing('deviates-from: []') }, (root) => {
      const result = fixture.run(builder(), root);
      if (result.status === 0) return ['an edge naming nothing built'];
      return /deviates-from declares no record/.test(result.stderr)
        ? []
        : [`the refusal does not say the edge names nothing: ${result.stderr.trim()}`];
    }));

  check('a deviation declared as an empty block fails the same way', () =>
    fixture.withStore({ [STORE]: departing('deviates-from:') }, (root) => {
      const result = fixture.run(builder(), root);
      if (result.status === 0) return ['an edge with nothing under it built'];
      return /deviates-from declares no record/.test(result.stderr)
        ? []
        : [`the refusal does not say the edge names nothing: ${result.stderr.trim()}`];
    }));

  check('removing the edge removes the report, and nothing else is edited', () => {
    const withEdge = departing('deviates-from: [fw0001]');
    // The same store with the edge line deleted and nothing else touched, which
    // is the claim: removing the edge is the whole edit.
    const withoutEdge = withEdge.replace('deviates-from: [fw0001]\n', '');
    const declared = fixture.withStore({ [STORE]: withEdge }, (root) => {
      const result = fixture.run(builder(), root);
      if (result.status !== 0) return [`the declared deviation failed the build: ${result.stderr.trim()}`];
      return result.stdout.includes('deviations: 1') ? [] : ['the deviation was not reported'];
    });
    const removed = fixture.withStore({ [STORE]: withoutEdge }, (root) => {
      const result = fixture.run(builder(), root);
      if (result.status !== 0) return [`the store without the edge failed: ${result.stderr.trim()}`];
      return result.stdout.includes('deviations: 0') ? [] : ['the report survived the edge it came from'];
    });
    return [...declared, ...removed];
  });

  check('every document stating the deviation rule agrees with the build', () => {
    const offending = [];
    const REPORTED = /reported on every run rather than resolved/;
    for (const file of ['skills/configure/policies/records.template.md', 'specs.md']) {
      if (!REPORTED.test(read(file))) offending.push(`${file} does not say the edge is reported rather than resolved`);
    }
    const scripts = read(`${SKILLS}/configure/SCRIPTS.md`);
    if (!/deviates-from` declared with no record in it/.test(scripts)) {
      offending.push('SCRIPTS.md does not name the empty edge among the refusals');
    }
    if (!/an edge declaring no record fails/.test(read('specs.md'))) {
      offending.push('specs.md does not say an edge declaring no record fails');
    }
    return offending;
  });
});

ticket('conversion/06', 'the configuration stage stops installing what is no longer copied', (check) => {
  const SKILL = `${SKILLS}/configure/SKILL.md`;

  // Every check the 1.x audit performed, read off that step before it was
  // rewritten. Named here rather than derived from the table it checks: a
  // manifest taken from the page cannot notice a row the page dropped, which is
  // the loss this ticket's third criterion exists to make impossible.
  const AUDIT_CHECKS_1X = [
    'Prune what nothing references',
    'Validate the routing table',
    'Check `map.md` carries routing and nothing else',
    'Re-check Source Pointers',
    'Re-check the tool references',
    'Re-check `What a ticket is`',
    'Re-check `Where a spec lives`',
    'Mark specs reality already satisfies',
    'Apply the repairs this repository has not had',
    'Re-check `.claude/scripts/` against [SCRIPTS.md](SCRIPTS.md)',
    'Re-check the regenerate-and-compare check',
    'Regenerate the routing tables',
    'Sweep every committed file and classify it',
    'Quote the enumeration and the counts',
    'A committed file fitting no category is a finding',
    'Exempt exactly the per-clone set',
    'A governed file declaring no owner is a finding',
    'Re-check every installed file against its owner’s contract'.replace('’', "'"),
    'The `version` stamp routes attention and settles nothing',
    'Surface every deviation',
    'The upgrade path replaces framework files verbatim',
  ];

  /** The closed set of dispositions a row may carry. */
  const DISPOSITIONS = ['build', 'generation', 'here', 'removed'];

  /** Every row of the disposition table, as check and disposition. */
  const dispositionRows = () => {
    const out = [];
    for (const line of read(SKILL).split('\n')) {
      const match = line.match(/^\|\s(.+?)\s\|\s\*\*([a-z]+)\*\*\s\|\s(.+?)\s\|\s*$/);
      if (match) out.push({ name: match[1], disposition: match[2], because: match[3] });
    }
    return out;
  };

  // What the configuration stage is allowed to write: what the harness finds by
  // name, a copied script, and a record. Prefixes rather than a file list --
  // the store's filenames are the repository's, and the scripts' are the
  // scripts page's.
  const HARNESS_SURFACES = ['.claude/protocol.md', '.claude/settings.json', '.claude/.gitignore'];
  const ALLOWED_PREFIXES = ['.claude/rules/', '.claude/scripts/', '.claude/knowledge/'];

  check('every check the 1.x audit performed has a row in the disposition table', () => {
    const rows = dispositionRows();
    const named = new Set(rows.map((row) => row.name));
    const offending = AUDIT_CHECKS_1X.filter((name) => !named.has(name)).map((name) => `no disposition: ${name}`);
    if (rows.length !== AUDIT_CHECKS_1X.length) {
      offending.push(`the table carries ${rows.length} rows and the 1.x audit performed ${AUDIT_CHECKS_1X.length} checks`);
    }
    return offending;
  });

  check('every disposition is one of the four the table declares', () => {
    const offending = [];
    for (const row of dispositionRows()) {
      if (!DISPOSITIONS.includes(row.disposition)) {
        offending.push(`${row.name} carries the disposition "${row.disposition}"`);
      }
      if (row.because.trim() === '') offending.push(`${row.name} carries no reason`);
    }
    // The legend is what makes the vocabulary closed for a reader, so it is
    // checked against the same list the rows are. Two columns rather than the
    // rows' three is what tells the two tables apart — searching the page for
    // the word instead would find it in a row, which is the guard matching
    // something that travels with its subject rather than the subject.
    const legend = [];
    for (const line of read(SKILL).split('\n')) {
      const match = line.match(/^\|\s\*\*([a-z]+)\*\*\s\|\s[^|]+\|\s*$/);
      if (match) legend.push(match[1]);
    }
    for (const disposition of DISPOSITIONS) {
      if (!legend.includes(disposition)) offending.push(`the legend does not define "${disposition}"`);
    }
    for (const word of legend) {
      if (!DISPOSITIONS.includes(word)) offending.push(`the legend defines "${word}", which no row may carry`);
    }
    return offending;
  });

  // The three checks the table sends to the build, demonstrated one at a time.
  // Each is its own assertion rather than one pass over the three, because the
  // claim being checked is per row: a batch that failed would say the table is
  // wrong without saying which row.
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');
  const STORE = '.claude/knowledge/a.md';

  const record = (front) =>
    `---\n${front}\n---\n\n## First thing\n\n- **The first thing is stated once** and nothing restates it.\n`;

  check('the check sent to the build for Source Pointers is one the build performs', () =>
    fixture.withStore(
      { [STORE]: record('owner: repository\ntype: context\nsubject: fixture\nsources: [src/gone.ts]') },
      (root) => {
        const result = fixture.run(builder(), root);
        if (result.status !== 0) return [`the run exited ${result.status}: ${result.output.trim()}`];
        return /broken pointers: 1/.test(result.stdout) && /src\/gone\.ts/.test(result.stdout)
          ? []
          : [`the pointer was not reported: ${result.stdout.trim()}`];
      },
    ));

  check('the check sent to the build for a missing owner is one the build performs', () =>
    fixture.withStore({ [STORE]: record('type: context\nsubject: fixture') }, (root) => {
      const result = fixture.run(builder(), root);
      if (result.status === 0) return ['a record declaring no owner built'];
      return /owner "\(none declared\)" is outside the closed set/.test(result.stderr)
        ? []
        : [`the refusal does not name the missing owner: ${result.stderr.trim()}`];
    }));

  check('the check sent to the build for deviations is one the build performs', () =>
    fixture.withStore(
      { [STORE]: record('owner: repository\ntype: context\nsubject: fixture\ndeviates-from: [fw0001]') },
      (root) => {
        const result = fixture.run(builder(), root);
        if (result.status !== 0) return [`the run exited ${result.status}: ${result.output.trim()}`];
        return /deviations: 1/.test(result.stdout) && /fw0001/.test(result.stdout)
          ? []
          : [`the deviation was not reported: ${result.stdout.trim()}`];
      },
    ));

  check('the stage writes only what the harness finds by name, a copied script, or a record', () =>
    DESTINATIONS()
      .filter((entry) => entry.at.startsWith(`${SKILLS}/configure/`))
      .filter(
        (entry) =>
          !HARNESS_SURFACES.includes(entry.target) &&
          !ALLOWED_PREFIXES.some((prefix) => entry.target.startsWith(prefix)),
      )
      .map((entry) => `${entry.at}  writes to ${entry.target}`));

  check('no step instructs the stage to derive a script', () => {
    const offending = [];
    read(SKILL)
      .split('\n')
      .forEach((line, index) => {
        if (/deriv\w*[^.\n]{0,60}script|script[^.\n]{0,60}deriv\w*/i.test(line)) {
          offending.push(`${SKILL}:${index + 1}  ${line.trim().slice(0, 90)}`);
        }
      });
    if (!read(SKILL).includes('taken from the plugin byte for byte')) {
      offending.push('the stage does not say the scripts are copied');
    }
    return offending;
  });

  check('no step instructs the stage to run a script against a fixture', () => {
    const offending = [];
    read(SKILL)
      .split('\n')
      .forEach((line, index) => {
        if (/against (a|its|each) fixture/i.test(line)) {
          offending.push(`${SKILL}:${index + 1}  ${line.trim().slice(0, 90)}`);
        }
      });
    if (!read(SKILL).includes('This stage runs none of them.')) {
      offending.push('the removal is not stated, so a reader cannot tell it from an omission');
    }
    return offending;
  });

  check('no step wires a regenerate-and-compare check', () => {
    const text = read(SKILL);
    const offending = [];
    if (/Wire it into/.test(text)) offending.push('the stage still wires the check');
    if (!text.includes('No regenerate-and-compare check is wired, and it is gone rather than forgotten.')) {
      offending.push('the removal is not stated, so a reader cannot tell it from an omission');
    }
    return offending;
  });

  check('running the stage twice changes nothing the second time', () => {
    const text = read(SKILL);
    const offending = [];
    if (!/is \*\*idempotent\*\*/.test(text)) offending.push('the stage does not claim idempotence');
    if (!/Recognition is by content, not by presence/.test(text)) {
      offending.push('the stage does not say how a second run recognises what is already there');
    }
    if (!/a file that exists is checked against the repository it claims to describe/.test(text)) {
      offending.push('the generate step does not say what it does with a file that exists');
    }
    return offending;
  });

  // Criterion five, mechanically: a step whose destination does not exist is a
  // link nothing resolves. Fenced blocks are skipped and placeholder targets
  // are excluded -- the shipped pages carry example indexes and `<slug>` forms
  // whose links are illustrations, and a guard firing on those fires on correct
  // content, which is the guard whoever hits it rescopes.
  check('every relative link in shipped text resolves where it is read', () => {
    const offending = [];
    for (const file of SHIPPED_MARKDOWN()) {
      let fenced = false;
      read(file)
        .split('\n')
        .forEach((line, index) => {
          if (/^\s*(```|~~~)/.test(line)) {
            fenced = !fenced;
            return;
          }
          if (fenced) return;
          for (const match of line.matchAll(/\[[^\]]*\]\(([^)]+)\)/g)) {
            const target = match[1].split('#')[0];
            if (target === '' || /^[a-z]+:/i.test(target) || /[<>]/.test(target)) continue;
            const resolved = path.join(path.dirname(file), target);
            if (!fs.existsSync(resolveShipped(resolved))) {
              offending.push(`${file}:${index + 1}  ${target}`);
            }
          }
        });
    }
    return offending;
  });
});

ticket('conversion/07', 'the upgrade path reaches every departed directory', (check) => {
  const CHANGELOG = `${SKILLS}/configure/migration-changelog.md`;

  // Every surface a 1.x `.claude/` holds, paired with the destination row that
  // covers it. Named here rather than read off the table: a coverage check
  // taken from the table it checks agrees with the table however short it is,
  // which is the failure this ticket exists for.
  const SURFACES_1X = [
    ['.claude/contexts/repository.md, and each domain file', 'one `context` record per file, one span per `##` heading'],
    ['a discovered standard under .claude/rules/', 'one `norm` record per file — `fires-when: every-turn`'],
    ['.claude/decisions/*.md', 'one `decision` record per file, **not decomposed**'],
    ['a landed spec, wherever the tracker policy declares one lives', 'one `spec` record per file, **not decomposed**'],
    ['.claude/evidence/**', 'one `evidence` record per finding, **not decomposed**'],
    ['.claude/tools/*.md', 'one `reference` record per file'],
    ['the generated map.md in each converted directory', 'deleted — the ledger the builder rebuilds replaces it'],
    ['the eight framework guides, and .claude/modes/*.md', '**deleted** — the framework store holds them and nothing is copied'],
    ['.claude/policies/tracker.md and version-control.md', 'one `norm` record each, `owner: repository`'],
    ['the four unconditional rules, and .claude/protocol.md', 'replaced verbatim by this release, never converted'],
    ['.claude/scripts/*', "replaced by this release's copies"],
    ['CLAUDE.md', "merged from this release's template as ever"],
    ['.claude/tickets/**', 'the tracker store — untouched'],
    ['.claude/position/, .claude/worktrees/, .claude/settings*.json, .claude/.gitignore', "per-clone, or the harness's — untouched"],
  ];

  // What each release removes, so a destination naming one is a destination
  // that release deletes. Only 2.0 removes a directory; the older entries
  // repair trees those directories were still in, and naming one there is
  // correct rather than stale.
  const RELEASE_REMOVES = {
    '2.0.0': ['modes', 'policies', 'contexts', 'decisions', 'designs', 'evidence', 'tools'],
  };

  /** The release heading each line of the changelog sits under. */
  const releaseAt = () => {
    const out = [];
    let current = null;
    read(CHANGELOG)
      .split('\n')
      .forEach((line) => {
        const match = line.match(/^## (\d+\.\d+\.\d+)\s*$/);
        if (match) current = match[1];
        out.push(current);
      });
    return out;
  };

  /** The 2.0.0 entry, from its heading to the next release heading. */
  const entry2 = () => {
    const lines = read(CHANGELOG).split('\n');
    const start = lines.findIndex((line) => /^## 2\.0\.0\s*$/.test(line));
    const end = lines.findIndex((line, index) => index > start && /^## \d+\.\d+\.\d+\s*$/.test(line));
    return lines.slice(start, end === -1 ? lines.length : end).join('\n');
  };

  check('every 1.x surface has a destination', () => {
    const text = entry2();
    const offending = SURFACES_1X.filter(([, row]) => !text.includes(row)).map(
      ([surface]) => `no destination: ${surface}`,
    );
    const rows = text.split('\n').filter((line) => /^\| .+ \| .+ \|\s*$/.test(line) && !/^\| ---/.test(line));
    // The heading row of the destination table is the one row that is not a
    // surface, so the inventory is one short of what the table carries.
    const destinations = rows.length - 1;
    if (destinations !== SURFACES_1X.length) {
      offending.push(`the table carries ${destinations} destinations and the inventory holds ${SURFACES_1X.length} surfaces`);
    }
    return offending;
  });

  check('a surface with no destination stops the conversion, naming it', () => {
    const text = entry2();
    const offending = [];
    if (!/A file under `\.claude\/` matching no row is named in the error, with its path, and nothing is written/.test(text)) {
      offending.push('the entry does not say that an unmatched surface is named and nothing is written');
    }
    if (!/Case A — the loose file/.test(text)) offending.push('no fixture case exercises an unmatched surface');
    return offending;
  });

  check('no changelog entry names a destination the release it is filed under deletes', () => {
    const sections = releaseAt();
    const offending = [];
    for (const entry of DESTINATIONS()) {
      const [file, line] = [entry.at.slice(0, entry.at.lastIndexOf(':')), Number(entry.at.slice(entry.at.lastIndexOf(':') + 1))];
      if (file !== CHANGELOG) continue;
      const release = sections[line - 1];
      const removed = RELEASE_REMOVES[release];
      if (!removed) continue;
      const match = entry.target.match(/^\.claude\/([^/]+)\//);
      if (match && removed.includes(match[1])) {
        offending.push(`${entry.at}  ${release} writes to ${entry.target}, which ${release} removes`);
      }
    }
    return offending;
  });

  check('an interrupted run completes rather than duplicating', () => {
    const text = entry2();
    const offending = [];
    if (!/The recognition is per file, not per repository/.test(text)) {
      offending.push('the entry does not say recognition is per file, which is what makes a partial run resumable');
    }
    if (!/Case D — interrupted/.test(text)) offending.push('no fixture case exercises an interruption');
    if (!/This case is the specification, not a repetition of B/.test(text)) {
      offending.push('the interrupted case is not stated as its own specification');
    }
    return offending;
  });

  check('every fixture case the conversion is proved by is stated', () => {
    const text = entry2();
    return ['A', 'B', 'C', 'D', 'E', 'F']
      .filter((letter) => !new RegExp(`Case ${letter} — `).test(text))
      .map((letter) => `no fixture case ${letter}`);
  });

  check('every repair recognises the shape it repairs by content before acting', () => {
    const text = read(CHANGELOG);
    const offending = [];
    if (!/Every repair below still recognises its shape by content before touching anything/.test(text)) {
      offending.push('the page does not state the standing rule');
    }
    if (!/Recognise it by content before writing anything/.test(entry2())) {
      offending.push('the 2.0.0 entry states no recognition of its own');
    }
    return offending;
  });

  // The frozen kinds, demonstrated against the builder rather than read off the
  // page: the entry claims a frozen account comes through with one id, and a
  // page agreeing with itself is not evidence about the script.
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');

  const frozen = (type) =>
    `---\nowner: repository\ntype: ${type}\nsubject: a-frozen-account\n---\n\n# A frozen account\n\n` +
    'Its opening prose.\n\n## Context\n\nOne.\n\n## Decision\n\nTwo.\n\n## Considered Options\n\nThree.\n';

  const FROZEN = { decision: 'an accepted decision', spec: 'a landed spec', evidence: 'an evidence finding' };
  for (const [type, named] of Object.entries(FROZEN)) {
    check(`${named} comes through the conversion with one id and its prose untouched`, () =>
      fixture.withStore({ [`.claude/knowledge/a.md`]: frozen(type) }, (root) => {
        const before = frozen(type);
        const result = fixture.run(builder(), root);
        if (result.status !== 0) return [`the run exited ${result.status}: ${result.output.trim()}`];
        const after = fixture.read(root, '.claude/knowledge/a.md');
        const spans = (after.match(/^ {2}- .+: [a-z0-9]{6}$/gm) || []).length;
        const offending = [];
        if (spans !== 1) offending.push(`${spans} spans were minted, and a frozen account takes one`);
        // Everything after the frontmatter must be what went in: the only diff
        // a frozen account may show is the added field.
        const body = after.slice(after.indexOf('\n---\n', 4) + 5);
        if (body !== before.slice(before.indexOf('\n---\n', 4) + 5)) offending.push('the body changed');
        return offending;
      }));
  }
});

ticket('conversion/09', 'the store query answers filters and nothing else', (check) => {
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');
  const query = () => resolveShipped('scripts/query-knowledge-store.js');
  const QUERY_SOURCE = `${SCRIPTS}/query-knowledge-store.js`;

  // The edges a closure can walk, read from the builder rather than listed
  // here. Listed here it would be a second home for the same fact, and the two
  // would disagree the moment somebody added an edge to one of them -- which is
  // the disagreement the depth records exist to prevent one layer up.
  const WALKABLE_EDGES = () => {
    const source = read(`${SCRIPTS}/build-knowledge-store.js`);
    const edges = inlineList((source.match(/^const EDGES = (\[[^\]]*\]);$/m) || [])[1] || '');
    const deviation = (source.match(/^const DEVIATION_EDGE = '([^']+)';$/m) || [])[1];
    return deviation ? [...edges, deviation] : edges;
  };

  // A stage norm is checked against the router's own table, so a fixture
  // holding one needs a router or it is refused for a reason it did not mean
  // to test.
  const ROUTER = {
    '.claude/protocol.md':
      '---\nowner: framework\n---\n\n# Workflow protocol\n\n' +
      '| Stage | Mode | Guides it reads |\n| --- | --- | --- |\n' +
      '| `/design` | design | the records its row selects |\n' +
      '| `/implement` | implementation | the records its row selects |\n',
  };

  const depthRecord = (edge, closes) =>
    `---\nowner: framework\ntype: reference\nsubject: fixture\nedge: ${edge}\ncloses: ${closes}\n---\n\n` +
    `## ${edge} closes ${closes}\n\nWhy it closes there.\n`;

  const decision = (anchor, id, edges) =>
    `---\nowner: repository\ntype: decision\nsubject: fixture\nspans:\n  - ${anchor}: ${id}\n${edges}---\n\n` +
    `# ${anchor}\n\nProse.\n`;

  // Two chains with disjoint targets, so raising one depth cannot be read as
  // the other having been walked first -- which is the confusion the
  // per-edge-type property would otherwise hide behind.
  const STORE = (supersedesCloses) => ({
    '.claude/knowledge/head.md': decision('head', 'hhh111', 'supersedes: [aaa111]\nblocked-by: [bbb111]\n'),
    '.claude/knowledge/s1.md': decision('s1', 'aaa111', 'supersedes: [aaa222]\nsuperseded-by: [hhh111]\n'),
    '.claude/knowledge/s2.md': decision('s2', 'aaa222', 'superseded-by: [aaa111]\n'),
    '.claude/knowledge/b1.md': decision('b1', 'bbb111', 'blocked-by: [bbb222]\n'),
    '.claude/knowledge/b2.md': decision('b2', 'bbb222', ''),
    '.claude/knowledge/scoped.md':
      '---\nowner: repository\ntype: norm\nsubject: fixture\nfires-when: path\npaths: [src/db/**]\n---\n\n' +
      '## Migrations are reviewed\n\n- **A migration is reviewed before it lands** because it cannot be undone.\n',
    '.claude/knowledge/edge-supersedes.md': depthRecord('supersedes', supersedesCloses),
    '.claude/knowledge/edge-superseded-by.md': depthRecord('superseded-by', 'fully'),
    '.claude/knowledge/edge-blocked-by.md': depthRecord('blocked-by', 1),
  });

  /** Build a store, then put one query to it. */
  const ask = (files, args, body) =>
    fixture.withStore(files, (root) => {
      const built = fixture.run(builder(), root);
      if (built.status !== 0) return [`the store was refused: ${built.output.trim()}`];
      return body(fixture.run(query(), root, args), root);
    });

  const answerOf = (result) => JSON.parse(result.stdout);

  check('a filter naming a field and a value returns every record carrying it, and nothing else', () =>
    ask(STORE(1), ['type=norm'], (result) => {
      if (result.status !== 0) return [`the query was refused: ${result.output.trim()}`];
      const answer = answerOf(result);
      const offending = [];
      if (answer.empty !== false) offending.push('a matching filter reported empty');
      const ids = answer.matches.map((record) => record.id).sort();
      if (answer.matches.some((record) => record.type !== 'norm')) {
        offending.push(`a record of another type came back: ${ids.join(', ')}`);
      }
      if (answer.matches.length !== 1) offending.push(`${answer.matches.length} records came back and one carries the value`);
      return offending;
    }));

  check('a filter for a value no record carries is empty rather than an error', () =>
    ask(STORE(1), ['type=spec'], (result) => {
      const offending = [];
      // The case the surface exists for. A non-zero exit here collapses "the
      // store says no" into "the query went wrong", which is the one distinction
      // a caller cannot recover afterwards.
      if (result.status !== 0) return [`a miss exited ${result.status}: ${result.output.trim()}`];
      const answer = answerOf(result);
      if (answer.empty !== true) offending.push('a miss did not report empty');
      if (answer.matches.length !== 0) offending.push(`${answer.matches.length} records came back on a miss`);
      return offending;
    }));

  check('a bare phrase is refused, naming what the surface takes instead', () =>
    ask(STORE(1), ['how', 'do', 'I', 'mint', 'an', 'id'], (result) => {
      const offending = [];
      if (result.status === 0) return ['free text was answered'];
      if (!/no free text/.test(result.output)) offending.push('the refusal does not say the surface takes no free text');
      if (!/field=value/.test(result.output)) offending.push('the refusal does not say what it takes instead');
      return offending;
    }));

  check('a field no record declares is refused, naming the field and the declared set', () =>
    ask(STORE(1), ['banana=x'], (result) => {
      const offending = [];
      if (result.status === 0) return ['an undeclared field was answered'];
      if (!/banana/.test(result.output)) offending.push('the refusal does not name the field');
      if (!/type/.test(result.output)) offending.push('the refusal does not list what is declared');
      return offending;
    }));

  check("enumerating a field's distinct values is answerable as a filter", () =>
    ask(STORE(1), ['type='], (result) => {
      if (result.status !== 0) return [`the enumeration was refused: ${result.output.trim()}`];
      const answer = answerOf(result);
      const enumerated = (answer.enumerated || [])[0];
      if (!enumerated) return ['nothing was enumerated'];
      const values = enumerated.values.map((entry) => entry.value).sort();
      const offending = [];
      if (values.join(',') !== 'decision,norm,reference') offending.push(`enumerated ${values.join(', ')}`);
      // A value the store does not hold is absent rather than present at zero:
      // the enumeration says what is there, which is the whole reason it is a
      // filter rather than a list of what a field could take.
      if (enumerated.values.some((entry) => entry.records === 0)) offending.push('a value with no records was listed');
      return offending;
    }));

  // The criterion the settlement spec left for this ticket: a stage norm is
  // reached by a filter on `stages` alone. The list is what makes it exact --
  // a joined value would have to be searched inside, and a substring match is
  // how a miss stops being a fact about the store.
  check('a stage norm is returned by a filter on its stages, with no substring matching', () => {
    const files = STORE(1);
    files['.claude/knowledge/staged.md'] =
      '---\nowner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [design, implement]\n---\n\n' +
      '## The plan is built rather than redesigned\n\n- **A deviation goes back to design** because a plan nobody saw is not one.\n';
    return fixture.withStore({ ...files, ...ROUTER }, (root) => {
      const built = fixture.run(builder(), root);
      if (built.status !== 0) return [`the store was refused: ${built.output.trim()}`];
      const offending = [];
      const exact = fixture.run(query(), root, ['stages=implement']);
      if (exact.status !== 0) return [`the query was refused: ${exact.output.trim()}`];
      const matched = JSON.parse(exact.stdout).matches;
      if (matched.length !== 1 || matched[0].file !== 'staged.md') {
        offending.push(`the stage norm did not come back alone: ${matched.map((r) => r.file).join(', ')}`);
      }
      const partial = fixture.run(query(), root, ['stages=impl']);
      if (partial.status !== 0) return [`the query was refused: ${partial.output.trim()}`];
      if (JSON.parse(partial.stdout).empty !== true) offending.push('a prefix of a stage matched inside the value');
      return offending;
    });
  });

  check('a path filter returns the norms whose declared globs cover it, and no others', () =>
    ask(STORE(1), ['paths=src/db/schema.ts'], (result) => {
      if (result.status !== 0) return [`the query was refused: ${result.output.trim()}`];
      const answer = answerOf(result);
      if (answer.matches.length !== 1 || answer.matches[0].file !== 'scoped.md') {
        return [`the covering norm did not come back alone: ${answer.matches.map((r) => r.file).join(', ')}`];
      }
      return [];
    }));

  // Both halves, because a matcher that covered everything would pass the first
  // one on its own -- and a glob that covers everything is the failure mode a
  // path filter has that an equality filter does not.
  check('a path no declared glob covers comes back empty', () =>
    ask(STORE(1), ['paths=src/api/handler.ts'], (result) => {
      if (result.status !== 0) return [`the query was refused: ${result.output.trim()}`];
      const answer = answerOf(result);
      return answer.empty === true && answer.matches.length === 0
        ? []
        : [`${answer.matches.length} records were covered by a glob that does not name them`];
    }));

  check('a match returns its closure, each record attributed to the edge that reached it', () =>
    ask(STORE(1), ['file=head.md'], (result) => {
      if (result.status !== 0) return [`the query was refused: ${result.output.trim()}`];
      const answer = answerOf(result);
      const reached = answer.closure.map((entry) => `${entry['reached-by']}:${entry.record.id}`).sort();
      return reached.join(' ') === 'blocked-by:bbb111 supersedes:aaa111'
        ? []
        : [`the closure reached ${reached.join(' ') || '(nothing)'}`];
    }));

  check('raising one edge type reaches further along it and exactly as far along every other', () =>
    ask(STORE(2), ['file=head.md'], (result) => {
      if (result.status !== 0) return [`the query was refused: ${result.output.trim()}`];
      const answer = answerOf(result);
      const byEdge = (edge) =>
        answer.closure.filter((entry) => entry['reached-by'] === edge).map((entry) => entry.record.id).sort();
      const offending = [];
      if (byEdge('supersedes').join(' ') !== 'aaa111 aaa222') {
        offending.push(`supersedes at 2 reached ${byEdge('supersedes').join(' ') || '(nothing)'}`);
      }
      // The half that is easy to lose: a depth applied to the walk rather than
      // to the edge would carry the other edge along with it, and the first
      // assertion alone would still pass.
      if (byEdge('blocked-by').join(' ') !== 'bbb111') {
        offending.push(`blocked-by moved when supersedes was raised: ${byEdge('blocked-by').join(' ') || '(nothing)'}`);
      }
      return offending;
    }));

  check('an edge no record declares a depth for is refused, naming the edge', () => {
    const files = STORE(1);
    delete files['.claude/knowledge/edge-blocked-by.md'];
    return ask(files, ['file=head.md'], (result) => {
      const offending = [];
      if (result.status === 0) return ['an edge with no declared depth was walked'];
      if (!/blocked-by/.test(result.output)) offending.push('the refusal does not name the edge');
      return offending;
    });
  });

  check('a decision and a norm matching together come back with both ranks and a label', () =>
    ask(STORE(1), ['owner=repository'], (result) => {
      if (result.status !== 0) return [`the query was refused: ${result.output.trim()}`];
      const answer = answerOf(result);
      const offending = [];
      if (answer.conflicts.length === 0) return ['a decision and a norm matched together and no conflict came back'];
      const conflict = answer.conflicts[0];
      if (conflict.records.length !== 2) offending.push('a conflict came back with something other than both records');
      if (conflict.records.some((record) => record.rank === undefined)) offending.push('a conflict record carries no rank');
      if (conflict.records[0].rank === conflict.records[1].rank) offending.push('two records of one rank were paired');
      if (!['declared-deviation', 'undeclared-defect'].includes(conflict.label)) {
        offending.push(`the conflict carries the label "${conflict.label}"`);
      }
      // Returned, never resolved: an answer that dropped one of them would be
      // the silent resolution the productive-conflict rule exists against.
      if (answer.matches.filter((record) => record.rank !== undefined).length < 2) {
        offending.push('the conflicting records did not both come back among the matches');
      }
      return offending;
    }));

  check('the framework index is read beside the repository, and an answer says what each store gave', () =>
    fixture.withStore(STORE(1), (root) => {
      const built = fixture.run(builder(), root);
      if (built.status !== 0) return [`the store was refused: ${built.output.trim()}`];
      const before = fixture.run(query(), root, ['id=fw0001']);
      if (before.status !== 0) return [`the query was refused: ${before.output.trim()}`];
      if (JSON.parse(before.stdout).empty !== true) return ['a framework id resolved with no framework index'];

      // Built apart and copied in, exactly as configuration copies it: a stage's
      // shell cannot resolve the plugin's root, so an index that is not copied
      // is an index that is not there.
      fixture.write(
        root,
        'plugin/knowledge/fw.md',
        '---\nowner: framework\ntype: norm\nsubject: fixture\nfires-when: path\npaths: [src/**]\n' +
          'spans:\n  - framework-law: fw0001\n---\n\n' +
          '## Framework law\n\n- **Law is followed as written** because a law nobody follows is a suggestion.\n',
      );
      const pluginRoot = path.join(root, 'plugin');
      const frameworkBuild = fixture.run(builder(), pluginRoot, [
        '--store',
        path.join(pluginRoot, 'knowledge'),
        '--store-name',
        'framework',
      ]);
      if (frameworkBuild.status !== 0) return [`the framework store was refused: ${frameworkBuild.output.trim()}`];
      fs.copyFileSync(
        path.join(pluginRoot, '.claude', 'position', 'ledger.json'),
        path.join(root, '.claude', 'position', 'framework-ledger.json'),
      );

      const after = fixture.run(query(), root, ['id=fw0001']);
      if (after.status !== 0) return [`the query was refused: ${after.output.trim()}`];
      const answer = JSON.parse(after.stdout);
      const offending = [];
      if (answer.empty !== false) offending.push('a framework id did not resolve with the framework index in place');
      if ((answer.matches[0] || {}).store !== 'framework') offending.push('the match does not say which store answered');
      if (!answer.stores || answer.stores.framework !== 1) offending.push('the answer does not report what each store gave');
      return offending;
    }));

  check('every edge the builder walks has one depth record in the shipped store, with a legal closes', () => {
    const declared = new Map();
    const offending = [];
    for (const file of markdownUnder(KNOWLEDGE)) {
      const fields = frontmatter(file);
      if (!fields || fields.edge === undefined) continue;
      if (declared.has(fields.edge)) offending.push(`${fields.edge} has a depth in two records`);
      declared.set(fields.edge, fields.closes);
      if (!(fields.closes === 'fully' || /^\d+$/.test(fields.closes || ''))) {
        offending.push(`${file} closes "${fields.closes}", which is neither fully nor a number of hops`);
      }
    }
    for (const edge of WALKABLE_EDGES()) {
      if (!declared.has(edge)) offending.push(`the builder walks ${edge} and no record declares how far it closes`);
    }
    return offending;
  });

  // The figure has to live in one place, and the record is the place a reader
  // would edit. A number in the script is a second home free to disagree with
  // it, and nothing would report the disagreement.
  check('the query carries no edge depth of its own', () => {
    const source = read(QUERY_SOURCE);
    const deviation = (read(`${SCRIPTS}/build-knowledge-store.js`).match(/^const DEVIATION_EDGE = '([^']+)';$/m) || [])[1];
    return WALKABLE_EDGES()
      .filter((edge) => edge !== deviation && source.includes(edge))
      .map((edge) => `the query names the edge ${edge}, and depth belongs to the record that declares it`);
  });

  check('the script page carries the query as written, and states what it copies beside it', () => {
    const page = read(`${SKILLS}/configure/SCRIPTS.md`);
    const offending = [];
    const row = page.split('\n').find((line) => line.includes('query-knowledge-store.js') && line.startsWith('|'));
    if (!row) offending.push('the page has no row for the store query');
    else if (/not yet/.test(row)) offending.push('the page still says the query is not written');
    if (!/framework-ledger\.json/.test(page)) offending.push('the page does not name the copied framework index');
    if (!/framework-ledger\.json/.test(read(`${SKILLS}/configure/SKILL.md`))) {
      offending.push('the configuration stage does not say it copies the framework index');
    }
    return offending;
  });
});

ticket('conversion/10', "a stage's row is assembled and delivered before its content", (check) => {
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');
  const assembler = () => resolveShipped('scripts/assemble-row.js');
  const ASSEMBLER_SOURCE = `${SCRIPTS}/assemble-row.js`;

  /**
   * The largest single substitution measured to deliver whole.
   *
   * Literal here rather than read from the script: the assertion is that the
   * script's cap sits at or below what was proven, and a bound taken from the
   * thing it bounds agrees with it at any value.
   */
  const PROVEN_FLOOR = 20036;

  const CAP = () => Number((read(ASSEMBLER_SOURCE).match(/^const CHUNK_CAP = (\d+);$/m) || [])[1]);

  const ROUTER =
    '---\nowner: framework\n---\n\n# Workflow protocol\n\n' +
    '| Stage | Mode | Guides it reads |\n| --- | --- | --- |\n' +
    '| `/design` | design | the records its row selects |\n' +
    '| `/implement` | implementation | the records its row selects |\n';

  const stageNorm = (heading, stages, body) =>
    `---\nowner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [${stages}]\n---\n\n` +
    `## ${heading}\n\n- **${body}** because otherwise it drifts.\n`;

  // One record of every condition that could reach a row and every one that
  // could not, so the two halves of the acceptance criterion are checked against
  // the same store rather than against two convenient ones.
  const STORE = {
    '.claude/protocol.md': ROUTER,
    '.claude/knowledge/a.md': stageNorm('Alpha', 'implement', 'The alpha is stated once'),
    '.claude/knowledge/b.md': stageNorm('Bravo', 'implement, design', 'The bravo is stated once'),
    '.claude/knowledge/c.md': stageNorm('Charlie', 'design', 'The charlie is stated once'),
    '.claude/knowledge/mode-implementation.md':
      '---\nowner: repository\ntype: norm\nsubject: fixture\nfires-when: posture\npostures: [implementation]\n---\n\n' +
      '## Correctness over exploration\n\n- **An approved design is followed** because exploring here is a different stage.\n',
    '.claude/knowledge/mode-design.md':
      '---\nowner: repository\ntype: norm\nsubject: fixture\nfires-when: posture\npostures: [design]\n---\n\n' +
      '## Architecture before code\n\n- **A design is settled before it is built** because a plan nobody saw is not one.\n',
    '.claude/knowledge/scoped.md':
      '---\nowner: repository\ntype: norm\nsubject: fixture\nfires-when: path\npaths: [src/**]\n---\n\n' +
      '## Scoped\n\n- **A scoped norm is reached by query** because no preprocessing runs when a file is opened.\n',
    '.claude/knowledge/d.md':
      '---\nowner: repository\ntype: decision\nsubject: fixture\nspans:\n  - a-decision: ddd111\n---\n\n# A decision\n\nProse.\n',
  };

  /** Build a store, then run the assembler against it. */
  const rowOf = (files, args, body) =>
    fixture.withStore(files, (root) => {
      const built = fixture.run(builder(), root);
      if (built.status !== 0) return [`the store was refused: ${built.output.trim()}`];
      return body(fixture.run(assembler(), root, args), root);
    });

  check('a stage receives every norm whose firing condition matches it', () =>
    rowOf(STORE, ['--stage', 'implement'], (result) => {
      if (result.status !== 0) return [`the row was not assembled: ${result.output.trim()}`];
      const offending = [];
      // The stage norms naming it, and the mode for the posture it runs under --
      // a mode is delivered when a stage declaring it starts, so a row missing
      // one is a stage running in no posture at all.
      for (const heading of ['## Alpha', '## Bravo', '## Correctness over exploration']) {
        if (!result.stdout.includes(heading)) offending.push(`the row does not carry ${heading}`);
      }
      return offending;
    }));

  check('a stage receives no norm whose firing condition does not match it', () =>
    rowOf(STORE, ['--stage', 'implement'], (result) => {
      if (result.status !== 0) return [`the row was not assembled: ${result.output.trim()}`];
      const offending = [];
      const shouldNotArrive = {
        '## Charlie': "another stage's norm",
        '## Architecture before code': "another posture's mode",
        '## Scoped': 'a path norm, which is the query\'s',
        '# A decision': 'a record that is not a norm',
      };
      for (const [heading, why] of Object.entries(shouldNotArrive)) {
        if (result.stdout.includes(heading)) offending.push(`the row carries ${heading} — ${why}`);
      }
      return offending;
    }));

  check('the delivered row names the stage it was assembled for', () =>
    rowOf(STORE, ['--stage', 'implement'], (result) => {
      if (result.status !== 0) return [`the row was not assembled: ${result.output.trim()}`];
      // Rows are otherwise indistinguishable, so one delivered to the wrong stage
      // reads as correct and the failure surfaces somewhere else entirely.
      const first = result.stdout.split('\n')[0];
      return /\bimplement\b/.test(first) ? [] : [`the opening line does not name the stage: ${first}`];
    }));

  check('the row arrives in computed precedence order', () =>
    rowOf(STORE, ['--stage', 'implement'], (result) => {
      if (result.status !== 0) return [`the row was not assembled: ${result.output.trim()}`];
      const at = (heading) => result.stdout.indexOf(heading);
      // Firing breadth orders norms among themselves, broadest first: a posture
      // norm precedes a stage norm.
      return at('## Correctness over exploration') < at('## Alpha')
        ? []
        : ['a stage norm was delivered ahead of the mode, and breadth orders norms broadest first'];
    }));

  check('reordering the store does not reorder the row', () =>
    fixture.withStore(STORE, (root) => {
      if (fixture.run(builder(), root).status !== 0) return ['the store was refused'];
      const before = fixture.run(assembler(), root, ['--stage', 'implement']).stdout;
      // A rename is what a filesystem-ordered row would follow, and the id the
      // order falls back on is the one property a rename leaves alone.
      fs.renameSync(
        path.join(root, '.claude', 'knowledge', 'a.md'),
        path.join(root, '.claude', 'knowledge', 'zzz.md'),
      );
      if (fixture.run(builder(), root).status !== 0) return ['the rebuilt store was refused'];
      const after = fixture.run(assembler(), root, ['--stage', 'implement']).stdout;
      return before === after ? [] : ['the row changed when a file was renamed'];
    }));

  /** A store whose implement row is comfortably larger than one substitution. */
  const largeStore = () => {
    const files = { ...STORE };
    const body = 'and the reason it holds is stated at length. '.repeat(40);
    for (let i = 0; i < 40; i += 1) {
      files[`.claude/knowledge/big-${i}.md`] = stageNorm(`Big ${i}`, 'implement', `The big ${i} is stated once ${body}`);
    }
    return files;
  };

  check('a row over one substitution is emitted as several, each under the cap', () =>
    rowOf(largeStore(), ['--stage', 'implement'], (result, root) => {
      if (result.status !== 0) return [`the row was not assembled: ${result.output.trim()}`];
      const planned = Number((result.stderr.match(/^chunks: (\d+)$/m) || [])[1]);
      const offending = [];
      if (!(planned > 1)) return [`a row of ${result.stdout.length} characters was emitted as ${planned} chunk(s)`];
      const chunks = [];
      for (let i = 0; i < planned; i += 1) {
        chunks.push(fixture.run(assembler(), root, ['--stage', 'implement', '--chunk', String(i)]).stdout.replace(/\n$/, ''));
      }
      for (const [index, chunk] of chunks.entries()) {
        if (chunk.length > CAP()) offending.push(`chunk ${index} is ${chunk.length} characters, over the cap`);
      }
      // Nothing withheld: the chunks concatenated are the row, so a caller
      // reading them in order has what the single emission would have given.
      if (chunks.join('\n\n') !== result.stdout.replace(/\n$/, '')) {
        offending.push('the chunks concatenated are not the row');
      }
      return offending;
    }));

  check('the number of commands is the smallest that keeps every one under the cap', () =>
    rowOf(largeStore(), ['--stage', 'implement'], (result, root) => {
      if (result.status !== 0) return [`the row was not assembled: ${result.output.trim()}`];
      const planned = Number((result.stderr.match(/^chunks: (\d+)$/m) || [])[1]);
      const chunks = [];
      for (let i = 0; i < planned; i += 1) {
        chunks.push(fixture.run(assembler(), root, ['--stage', 'implement', '--chunk', String(i)]).stdout.replace(/\n$/, ''));
      }
      // A boundary costs seconds where the bytes cost milliseconds, so a chunk
      // that could have absorbed the next one is a boundary nobody needed.
      const offending = [];
      for (let i = 0; i + 1 < chunks.length; i += 1) {
        if (chunks[i].length + 2 + chunks[i + 1].length <= CAP()) {
          offending.push(`chunks ${i} and ${i + 1} fit in one and were emitted as two`);
        }
      }
      return offending;
    }));

  check('the cap sits at or below the largest substitution proven to deliver whole', () => {
    const cap = CAP();
    return cap > 0 && cap <= PROVEN_FLOOR
      ? []
      : [`the cap is ${cap} against a proven floor of ${PROVEN_FLOOR}`];
  });

  check('a chunk past the end of the row is emitted as nothing, and exits zero', () =>
    rowOf(STORE, ['--stage', 'implement', '--chunk', '9'], (result) => {
      const offending = [];
      // A skill carries a fixed number of slots and a row does not, so an unused
      // slot is the ordinary case; refusing there would take the stage down for
      // a row that was simply short.
      if (result.status !== 0) offending.push(`an unused slot exited ${result.status}`);
      if (result.stdout !== '') offending.push(`an unused slot emitted ${result.stdout.length} characters`);
      return offending;
    }));

  check('an assembly that cannot complete emits no row rather than a shorter one', () => {
    const files = { ...STORE };
    return fixture.withStore(files, (root) => {
      if (fixture.run(builder(), root).status !== 0) return ['the store was refused'];
      // The index promises a record the store no longer holds. A stage cannot
      // tell a norm that was dropped from one that never fired for it, so this
      // is the fault that must never produce a row.
      fixture.write(
        root,
        '.claude/knowledge/a.md',
        '---\nowner: repository\ntype: norm\nsubject: fixture\nfires-when: stage\nstages: [implement]\n---\n\n## Renamed\n\n- **It moved** because somebody moved it.\n',
      );
      const result = fixture.run(assembler(), root, ['--stage', 'implement']);
      const offending = [];
      if (result.status === 0) offending.push('a row was assembled over an index the store no longer matches');
      if (result.stdout !== '') offending.push(`a partial row of ${result.stdout.length} characters was emitted`);
      return offending;
    });
  });

  check('a record larger than one substitution stops the assembly, naming it', () => {
    const files = { ...STORE };
    files['.claude/knowledge/huge.md'] = stageNorm('Huge', 'implement', `The huge one ${'x'.repeat(25000)}`);
    return rowOf(files, ['--stage', 'implement'], (result) => {
      const offending = [];
      if (result.status === 0) return ['a record over the cap was delivered'];
      if (!/over the/.test(result.output)) offending.push('the refusal does not say what was exceeded');
      if (!/\d{5}/.test(result.output)) offending.push('the refusal does not name the size');
      return offending;
    });
  });

  check('a stage no router row names is refused rather than answered with an empty row', () =>
    rowOf(STORE, ['--stage', 'triage'], (result) => {
      const offending = [];
      if (result.status === 0) return ['a stage the router does not carry was assembled a row'];
      if (!/triage/.test(result.output)) offending.push('the refusal does not name the stage');
      return offending;
    }));

  // A row short because nothing was passed to it must not read like a row short
  // because nothing matched -- the second is a true statement about the corpus
  // and the first is a configuration fault.
  check('a row assembled with no framework store says so in its opening line', () =>
    rowOf(STORE, ['--stage', 'implement'], (result) => {
      if (result.status !== 0) return [`the row was not assembled: ${result.output.trim()}`];
      const first = result.stdout.split('\n')[0];
      return /repository/.test(first) ? [] : [`the opening line does not say the framework store is absent: ${first}`];
    }));

  check('the assembler fails unguarded, and the page says what a stage then receives', () => {
    const source = read(ASSEMBLER_SOURCE);
    const page = read(`${SKILLS}/configure/SCRIPTS.md`);
    const offending = [];
    if (!/fails unguarded/.test(source)) offending.push('the script does not state that it fails unguarded');
    if (!/nothing at all/.test(page)) offending.push('the page does not say what an unguarded failure delivers');
    if (!/records it as a deviation/.test(page)) {
      offending.push('the page does not say how a repository chooses otherwise');
    }
    const row = page.split('\n').find((line) => line.includes('assemble-row.js') && line.startsWith('|'));
    if (!row) offending.push('the page has no row for the assembler');
    else if (/not yet/.test(row)) offending.push('the page still says the assembler is not written');
    return offending;
  });

  // The figure and the delivery have to agree about what a row is, or the one
  // number bounding growth is measuring something nobody receives.
  check("the builder's row figure counts the mode a stage runs in", () =>
    fixture.withStore(STORE, (root) => {
      const built = fixture.run(builder(), root);
      if (built.status !== 0) return [`the store was refused: ${built.output.trim()}`];
      const ledger = JSON.parse(fixture.read(root, '.claude/position/ledger.json'));
      const row = ledger.figures.rows.find((entry) => entry.stage === 'implement');
      const mode = ledger.records.find((record) => record.file === 'mode-implementation.md');
      const stageNorms = ledger.records
        .filter((record) => record['fires-when'] === 'stage' && (record.stages || []).includes('implement'))
        .reduce((sum, record) => sum + record.size, 0);
      return row.authored === stageNorms + mode.size
        ? []
        : [`the row figure is ${row.authored} and the stage norms plus the mode are ${stageNorms + mode.size}`];
    }));

  // The cap is a number somebody could nudge, so the reason it sits where it does
  // has to travel with it. The documented ceiling bounds it from above and the
  // proven floor from below; without both recorded, a later raise to the ceiling
  // reads as tightening rather than as spending the margin deliberately.
  check('the cap records the documented ceiling it stays under', () => {
    const source = read(ASSEMBLER_SOURCE);
    const offending = [];
    if (!/30,000/.test(source)) offending.push('the script does not record the documented inline ceiling');
    if (!/BASH_MAX_OUTPUT_LENGTH/.test(source)) {
      offending.push('the script does not record that no variable raises that ceiling');
    }
    if (CAP() >= 30000) offending.push(`the cap is ${CAP()}, at or above the documented ceiling`);
    return offending;
  });

  // The failure table had two branches and the choice between them cannot reach
  // this one: no command runs, so no exit code exists to fail on. A reader who
  // finds only the fork will conclude the stage cannot start wrong.
  check('the third outcome, which the unguarded choice cannot reach, is stated in both homes', () => {
    const source = read(ASSEMBLER_SOURCE);
    const page = read(`${SKILLS}/configure/SCRIPTS.md`);
    const offending = [];
    for (const [where, text] of [['script', source], ['page', page]]) {
      if (!/disableSkillShellExecution/.test(text)) {
        offending.push(`the ${where} does not name the setting that suppresses the command`);
      }
      if (!/shell command execution disabled by policy/.test(text)) {
        offending.push(`the ${where} does not say what arrives in the row's place`);
      }
    }
    // The load-bearing half: suppressed, the stage still starts. A page saying
    // only that the setting exists leaves the reader with the fork above.
    if (!/renders the skill anyway/.test(page)) {
      offending.push('the page does not say the stage starts anyway');
    }
    return offending;
  });

  check('a store missing a file and a store missing a heading are reported apart', () =>
    fixture.withStore(STORE, (root) => {
      if (fixture.run(builder(), root).status !== 0) return ['the store was refused'];
      fs.unlinkSync(path.join(root, '.claude', 'knowledge', 'a.md'));
      const gone = fixture.run(assembler(), root, ['--stage', 'implement']);
      const offending = [];
      if (gone.status === 0) return ['a row was assembled over a file the store no longer holds'];
      // Saying "carries no heading" of a file that is not there sends a reader to
      // inspect headings in nothing: one symptom, two different repairs.
      if (/carries no heading/.test(gone.output)) {
        offending.push('a missing file is reported as a missing heading');
      }
      if (!/is not there/.test(gone.output)) offending.push('the refusal does not say the file is absent');
      if (!/a\.md/.test(gone.output)) offending.push('the refusal does not name the path it looked in');
      return offending;
    }));
});

ticket('conversion/11', 'a copied script declares its release, and a stale one is reported once', (check) => {
  const fixture = require('./fixtures/session-hook');
  const hook = () => resolveShipped('hooks/check-version.js');
  const PAGE = `${SKILLS}/configure/SCRIPTS.md`;

  const RUNNING = '2.0.0';
  const EARLIER = '1.9.0';

  /** The lines the hook emits about a subject, as opposed to the instruction it ends with. */
  const subjectLines = (context) =>
    (context || '').split('\n').filter((line) => line.startsWith('AEP '));

  check('a repository whose copies match the running release is told nothing', () => {
    const seen = fixture.observe(hook(), {
      running: RUNNING,
      protocol: RUNNING,
      scripts: { 'report-position.js': RUNNING, 'build-knowledge-store.js': RUNNING },
    });
    return seen.stdout.trim() === '' ? [] : [`the hook emitted ${seen.stdout.trim()}`];
  });

  check('a copy from an earlier release produces one line naming it and what repairs it', () => {
    const seen = fixture.observe(hook(), {
      running: RUNNING,
      protocol: RUNNING,
      scripts: { 'report-position.js': EARLIER },
    });
    const lines = subjectLines(seen.context);
    const offending = [];
    if (lines.length !== 1) return [`${lines.length} lines were emitted about a single stale copy`];
    if (!lines[0].includes('report-position.js')) offending.push('the line does not name the stale script');
    if (!lines[0].includes(EARLIER)) offending.push('the line does not name the release it came from');
    if (!/\/aep:configure/.test(seen.context)) offending.push('nothing names what repairs it');
    return offending;
  });

  // One line rather than one per script: a repository that skipped a release is
  // behind on all of them, and the same sentence five times teaches nothing the
  // first did not.
  check('several stale copies are still one line', () => {
    const seen = fixture.observe(hook(), {
      running: RUNNING,
      protocol: RUNNING,
      scripts: { 'a.js': EARLIER, 'b.js': EARLIER, 'c.js': EARLIER },
    });
    const lines = subjectLines(seen.context);
    const offending = [];
    if (lines.length !== 1) offending.push(`${lines.length} lines were emitted about three stale copies`);
    for (const name of ['a.js', 'b.js', 'c.js']) {
      if (!(seen.context || '').includes(name)) offending.push(`${name} is not named`);
    }
    return offending;
  });

  check('a repository that copied no scripts is told nothing about them', () => {
    const seen = fixture.observe(hook(), { running: RUNNING, protocol: RUNNING });
    return seen.stdout.trim() === '' ? [] : [`the hook emitted ${seen.stdout.trim()}`];
  });

  // A copy predating the stamp and a copy somebody stripped it from look
  // identical, and warning on both puts a line nobody can act on into every
  // session of the first repository.
  check('a copy declaring no release is unknown rather than stale', () => {
    const seen = fixture.observe(hook(), {
      running: RUNNING,
      protocol: RUNNING,
      scripts: { 'report-position.js': null },
    });
    return seen.stdout.trim() === '' ? [] : [`the hook emitted ${seen.stdout.trim()}`];
  });

  // A repository with no protocol file and no copies. Absence is unknown rather
  // than stale at both subjects, or every repository that never ran this
  // framework would carry a line about it in every session.
  check('a repository that does not run this framework at all is told nothing', () => {
    const seen = fixture.observe(hook(), { running: RUNNING });
    return seen.stdout.trim() === '' ? [] : [`the hook emitted ${seen.stdout.trim()}`];
  });

  // Fired outside a project, the harness exports neither variable. Exiting
  // cleanly is half the claim: a hook that threw would also emit nothing, and a
  // check reading only the output could not tell the two apart.
  check('a hook fired with neither harness variable exits cleanly and says nothing', () => {
    const seen = fixture.observe(hook(), { running: RUNNING, protocol: EARLIER, unset: true });
    const offending = [];
    if (seen.status !== 0) offending.push(`the hook exited ${seen.status}`);
    if (seen.stdout.trim() !== '') offending.push(`the hook emitted ${seen.stdout.trim()}`);
    return offending;
  });

  check('a plugin whose manifest declares no version says nothing about anything', () => {
    const seen = fixture.observe(hook(), {
      running: null,
      protocol: EARLIER,
      scripts: { 'report-position.js': EARLIER },
    });
    return seen.stdout.trim() === '' ? [] : [`the hook emitted ${seen.stdout.trim()}`];
  });

  // The two subjects are independent in both directions, so a repository behind
  // on one is never told about the other and never has one hidden by the other.
  check('a stale protocol alone produces one line, and it is about the protocol', () => {
    const seen = fixture.observe(hook(), { running: RUNNING, protocol: EARLIER, scripts: { 'a.js': RUNNING } });
    const lines = subjectLines(seen.context);
    const offending = [];
    if (lines.length !== 1) return [`${lines.length} lines were emitted about a stale protocol alone`];
    if (!/protocol/.test(lines[0])) offending.push('the line is not about the protocol');
    return offending;
  });

  check('stale scripts are reported in a repository with no protocol file', () => {
    const seen = fixture.observe(hook(), { running: RUNNING, scripts: { 'a.js': EARLIER } });
    const lines = subjectLines(seen.context);
    return lines.length === 1 && lines[0].includes('a.js')
      ? []
      : [`a repository with no protocol file was told: ${lines.join(' | ') || '(nothing)'}`];
  });

  check('a repository behind on both subjects gets one line for each', () => {
    const seen = fixture.observe(hook(), {
      running: RUNNING,
      protocol: EARLIER,
      scripts: { 'a.js': EARLIER },
    });
    const lines = subjectLines(seen.context);
    const offending = [];
    if (lines.length !== 2) return [`${lines.length} lines were emitted for two stale subjects`];
    if (!lines.some((line) => /protocol/.test(line))) offending.push('no line is about the protocol');
    if (!lines.some((line) => line.includes('a.js'))) offending.push('no line is about the scripts');
    return offending;
  });

  /**
   * The stamp exactly as the page documents it.
   *
   * Taken from the page rather than written here, because the page is the format's
   * one home: the configuring stage writes this line and the hook reads it, and a
   * form restated in the suite would agree with the suite rather than with either.
   */
  const DOCUMENTED_STAMP = () => {
    const fence = /```js\n(\/\/ aep-release:[^\n]*)\n```/.exec(read(PAGE));
    return fence ? fence[1] : null;
  };

  check('the hook reads the stamp exactly as the page documents it', () => {
    const documented = DOCUMENTED_STAMP();
    if (!documented) return ['the page documents no stamp line in a js fence'];
    const release = documented.replace(/^\/\/ aep-release:\s*/, '').trim();
    const offending = [];
    if (!/^\d+\.\d+\.\d+$/.test(release)) offending.push(`the documented stamp carries "${release}", which is not a release`);
    // The page's own line, written verbatim with only the release changed, must
    // be the line the hook recognises -- which is what binds both ends of the
    // format to the one place that states it.
    const seen = fixture.observe(hook(), {
      running: RUNNING,
      protocol: RUNNING,
      rawScripts: { 'a.js': documented.replace(release, EARLIER) },
    });
    if (subjectLines(seen.context).length !== 1) {
      offending.push(`the hook does not recognise the page's own line: ${documented}`);
    }
    // And the same line at the running release must say nothing, or the check
    // above would pass on a hook that reported every copy it could see.
    const quiet = fixture.observe(hook(), {
      running: RUNNING,
      protocol: RUNNING,
      rawScripts: { 'a.js': documented.replace(release, RUNNING) },
    });
    if (quiet.stdout.trim() !== '') {
      offending.push(`the page's own line at the running release was reported stale: ${quiet.stdout.trim()}`);
    }
    if (!read(`${SKILLS}/configure/SKILL.md`).includes('SCRIPTS.md](SCRIPTS.md) states')) {
      offending.push('the configuration stage restates the form instead of pointing at its home');
    }
    return offending;
  });

  check('the stage is told to stamp each copy, and where the release comes from', () => {
    const text = read(`${SKILLS}/configure/SKILL.md`);
    const offending = [];
    if (!/stamp each copy with the release it came from/.test(text)) {
      offending.push('the stage is not told to stamp a copy');
    }
    // Read rather than asked for: a stage that asked would be asking the user to
    // know something only the installation does.
    if (!/manifest, read rather than asked for/.test(text)) {
      offending.push('the stage does not say where the release comes from');
    }
    return offending;
  });

  // The check reads as stronger than it is, so what it cannot see is stated
  // where the mechanism is described rather than left to be discovered.
  check('the limit of the check is stated where the mechanism is', () => {
    const text = read(PAGE);
    const offending = [];
    if (!/hand-edited copy still declaring the current release passes/.test(text)) {
      offending.push('the page does not state that a hand-edited copy passes');
    }
    if (!/not a diffing tool/.test(text)) offending.push('the page does not say why');
    if (!/undeclared release is unknown, never stale/i.test(text)) {
      offending.push('the page does not say what an undeclared release means');
    }
    return offending;
  });
});

ticket('corrections/01', 'a falsified record names what falsified it', (check) => {
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');
  const query = () => resolveShipped('scripts/query-knowledge-store.js');

  const anchorOf = (text) => text.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');

  const decision = (heading, id, edges) =>
    `---\nowner: repository\ntype: decision\nsubject: fixture\nspans:\n  - ${anchorOf(heading)}: ${id}\n${edges}---\n\n` +
    `# ${heading}\n\nIts reasoning, frozen.\n`;

  const finding = (heading, id, edges) =>
    `---\nowner: repository\ntype: evidence\nsubject: fixture\nkind: drift\nspans:\n  - ${anchorOf(heading)}: ${id}\n${edges}---\n\n` +
    `# ${heading}\n\nWhat was checked, and against what.\n`;

  const depth = (edge, closes) =>
    `---\nowner: framework\ntype: reference\nsubject: fixture\nedge: ${edge}\ncloses: ${closes}\n---\n\n` +
    `## ${edge} closes ${closes}\n\nWhy it closes there.\n`;

  const build = (files) =>
    fixture.withStore(files, (root) => ({ result: fixture.run(builder(), root), root }));

  check('a finding whose target does not name it back fails the build, naming both', () => {
    const seen = build({
      '.claude/knowledge/f.md': finding('A finding', 'fff111', 'falsifies: [ddd111]\n'),
      '.claude/knowledge/d.md': decision('A decision', 'ddd111', ''),
    });
    const offending = [];
    if (seen.result.status === 0) return ['a half-written falsification built'];
    for (const named of ['f.md', 'd.md', 'falsified-by']) {
      if (!seen.result.output.includes(named)) offending.push(`the refusal does not name ${named}`);
    }
    return offending;
  });

  // The same check with the fields exchanged. Resolution does not imply symmetry
  // in either direction, and a check written from one end only would be the
  // defect it exists to catch, one layer up.
  check('a record naming a finding it was not falsified by fails the build', () => {
    const seen = build({
      '.claude/knowledge/d.md': decision('A decision', 'ddd111', 'falsified-by: [fff111]\n'),
      '.claude/knowledge/f.md': finding('A finding', 'fff111', ''),
    });
    const offending = [];
    if (seen.result.status === 0) return ['a half-written falsification built, written from the other end'];
    if (!seen.result.output.includes('falsifies')) offending.push('the refusal does not name the missing end');
    return offending;
  });

  check('a falsification written at both ends builds', () => {
    const seen = build({
      '.claude/knowledge/f.md': finding('A finding', 'fff111', 'falsifies: [ddd111]\n'),
      '.claude/knowledge/d.md': decision('A decision', 'ddd111', 'falsified-by: [fff111]\n'),
    });
    return seen.result.status === 0 ? [] : [`a complete pair was refused: ${seen.result.output.trim()}`];
  });

  check('a falsified-by citing an id no record carries fails', () => {
    const seen = build({
      '.claude/knowledge/d.md': decision('A decision', 'ddd111', 'falsified-by: [zzz999]\n'),
    });
    const offending = [];
    if (seen.result.status === 0) return ['a citation naming nothing built'];
    if (!seen.result.output.includes('zzz999')) offending.push('the refusal does not name the id');
    return offending;
  });

  // The ADR template ships the field empty so it is discoverable, so refusing an
  // empty declaration would refuse every ADR the template produces. This edge is
  // a sibling of supersession, not of the deviation edge.
  check('a falsified-by declared with nothing in it builds, as its sibling does', () => {
    const seen = build({
      '.claude/knowledge/d.md': decision('A decision', 'ddd111', 'falsified-by: []\nsuperseded-by: []\n'),
    });
    return seen.result.status === 0 ? [] : [`an empty declaration was refused: ${seen.result.output.trim()}`];
  });

  // A chain of the same edge, which is the only shape that tests a depth of one.
  // A different edge type walked from a reached record spends its own budget, so
  // a mixed chain would be asking about the per-edge-type rule instead.
  const CLOSURE_STORE = {
    '.claude/knowledge/d.md': decision('A decision', 'ddd111', 'falsified-by: [fff111]\n'),
    '.claude/knowledge/f.md': finding('A finding', 'fff111', 'falsifies: [ddd111]\nfalsified-by: [ggg111]\n'),
    '.claude/knowledge/g.md': finding('A later finding', 'ggg111', 'falsifies: [fff111]\n'),
    '.claude/knowledge/edge-falsifies.md': depth('falsifies', 1),
    '.claude/knowledge/edge-falsified-by.md': depth('falsified-by', 1),
  };

  check('a query for a falsified record returns the finding, attributed to the edge', () =>
    fixture.withStore(CLOSURE_STORE, (root) => {
      if (fixture.run(builder(), root).status !== 0) return ['the store was refused'];
      const result = fixture.run(query(), root, ['id=ddd111']);
      if (result.status !== 0) return [`the query was refused: ${result.output.trim()}`];
      const answer = JSON.parse(result.stdout);
      const reached = answer.closure.map((entry) => `${entry['reached-by']}:${entry.record.id}`);
      // The reader this exists for is the one who opened the record, so the
      // correction has to arrive from the record's own side.
      return reached.includes('falsified-by:fff111')
        ? []
        : [`the closure reached ${reached.join(' ') || '(nothing)'}`];
    }));

  check('the closure stops at the finding rather than following what falsified it', () =>
    fixture.withStore(CLOSURE_STORE, (root) => {
      if (fixture.run(builder(), root).status !== 0) return ['the store was refused'];
      const result = fixture.run(query(), root, ['id=ddd111']);
      if (result.status !== 0) return [`the query was refused: ${result.output.trim()}`];
      const reached = JSON.parse(result.stdout).closure.map((entry) => entry.record.id);
      const offending = [];
      // One hop: the finding that falsified this record is wanted, and what
      // falsified *that* finding is the finding's own business.
      if (!reached.includes('fff111')) offending.push('the closure did not reach the finding at all');
      if (reached.includes('ggg111')) offending.push('the closure followed the edge past one hop');
      return offending;
    }));

  // The fixture above declares its own depths, so it says nothing about the ones
  // that ship. This does: one pair read from either end, and a pair closing
  // further in one direction would return a different graph depending on which
  // end somebody happened to ask about.
  check('the shipped pair closes to the same distance in both directions', () => {
    const closesAt = (edge) => {
      for (const file of markdownUnder(KNOWLEDGE)) {
        const fields = frontmatter(file);
        if (fields && fields.edge === edge) return fields.closes;
      }
      return null;
    };
    const forward = closesAt('falsifies');
    const back = closesAt('falsified-by');
    const offending = [];
    if (forward === null) offending.push('no record declares how far falsifies closes');
    if (back === null) offending.push('no record declares how far falsified-by closes');
    if (forward !== null && back !== null && forward !== back) {
      offending.push(`falsifies closes at ${forward} and falsified-by at ${back}`);
    }
    return offending;
  });

  /**
   * The whole of the guide a subject names, across the files it is cut into.
   *
   * The ADR guide is several files now, one per set of stages that reads it, and
   * which of them a given norm landed in is not what these assertions are about.
   * The subject is recovered by stripping what each file's own `stages` field
   * states.
   */
  const guideText = (subject) =>
    markdownUnder(KNOWLEDGE)
      .filter((file) => {
        const fields = frontmatter(file);
        if (!fields) return false;
        return fields.subject === subject;
      })
      .map((file) => read(file))
      .join('\n');

  check('the shipped guide states the three fields that move after commit, and why', () => {
    const text = guideText('decisions');
    const offending = [];
    if (!/only `status`, `superseded-by`, and `falsified-by` move/.test(text)) {
      offending.push('the freeze rule does not name the three fields that move');
    }
    if (!/pointers rather than reasoning/.test(text)) {
      offending.push('the freeze rule does not say why a pointer is admissible');
    }
    if (!/falsified-by: \[\]/.test(text)) offending.push('the template does not declare the field');
    return offending;
  });

  // Reaching for supersession where a clause is wrong retires a live decision to
  // fix one sentence, which loses the reasoning freezing exists to protect. The
  // guide has to say which instrument is for which, or the new one becomes the
  // one that is easier to reach for.
  check('the shipped guide says which instrument a contradiction takes', () => {
    const text = guideText('decisions');
    const offending = [];
    if (!/Reach for `falsified-by` where the argument holds and a clause is wrong/.test(text)) {
      offending.push('the guide does not say when to reach for the new edge');
    }
    if (!/for supersession where the decision itself is wrong/.test(text)) {
      offending.push('the guide does not say when supersession is still the instrument');
    }
    return offending;
  });
});

ticket('corrections/02', 'each guide is cut to the stages that read it', (check) => {
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');

  /**
   * The store as the split left it, held literally.
   *
   * Read off the store these would agree with the store however much of it had
   * been lost, which is the one thing a count exists to catch. The record total
   * is what says no record was dropped on the way between files; the row ceiling
   * is what says the split has not been quietly undone by merging files back.
   */
  const RECORDS_AFTER_THE_SPLIT = 186;
  const IMPLEMENT_ROW_CEILING = 23000; // predicted 22976 before the split, and met exactly

  /**
   * The router's stage table, written here rather than read from `.claude/`.
   *
   * This build never reads the protocol directory, and the stages and their
   * postures are the framework's own — they move only with a release — so a
   * table written here is a statement about what ships rather than about
   * whichever clone the build happens to run in.
   */
  const ROUTER = [
    ['configure', 'maintenance'],
    ['triage', 'maintenance'],
    ['design', 'design'],
    ['implement', 'implementation'],
    ['review', 'review'],
    ['research', 'research'],
    ['prototype', 'prototype'],
    ['commit', 'maintenance'],
  ];

  /** Build the shipped framework store in a scratch tree and read its ledger. */
  const withShippedStore = (body) => {
    const files = {
      '.claude/protocol.md':
        '---\nowner: framework\n---\n\n# Workflow protocol\n\n' +
        '| Stage | Mode | Guides it reads |\n| --- | --- | --- |\n' +
        ROUTER.map(([stage, posture]) => `| \`/${stage}\` | ${posture} | the records its row selects |`).join('\n') +
        '\n',
    };
    for (const file of markdownUnder(KNOWLEDGE)) files[`knowledge/${path.basename(file)}`] = read(file);
    return fixture.withStore(files, (root) => {
      const result = fixture.run(builder(), root, ['--store', `${root}/knowledge`, '--store-name', 'framework']);
      if (result.status !== 0) return [`the shipped store was refused: ${result.output.trim()}`];
      return body(JSON.parse(fixture.read(root, '.claude/position/ledger.json')));
    });
  };

  check('no record was lost or duplicated by the split', () =>
    withShippedStore((ledger) => {
      const offending = [];
      if (ledger.records.length !== RECORDS_AFTER_THE_SPLIT) {
        offending.push(`the store holds ${ledger.records.length} records and the split left ${RECORDS_AFTER_THE_SPLIT}`);
      }
      const ids = new Set(ledger.records.map((record) => record.id));
      if (ids.size !== ledger.records.length) {
        offending.push(`${ledger.records.length} records carry ${ids.size} distinct ids`);
      }
      return offending;
    }));

  // The saving the split was for. A ceiling rather than an equality, because a
  // norm added later should not fail this -- but merging the files back would
  // put the row straight through it.
  check("the implement row is below what the split predicted", () =>
    withShippedStore((ledger) => {
      const row = ledger.figures.rows.find((entry) => entry.stage === 'implement');
      return row.authored <= IMPLEMENT_ROW_CEILING
        ? []
        : [`the implement row is ${row.authored}, over the ${IMPLEMENT_ROW_CEILING} the split predicted`];
    }));

  // Every stage paying for the whole corpus is the state before the split, and
  // it is the state a careless merge would restore.
  check('no stage pays for every stage norm in the store', () =>
    withShippedStore((ledger) => {
      const total = ledger.records
        .filter((record) => record['fires-when'] === 'stage')
        .reduce((sum, record) => sum + record.size, 0);
      return ledger.figures.rows
        .filter((row) => row.authored >= total)
        .map((row) => `${row.stage} pays ${row.authored} of ${total}, which is the whole of it`);
    }));

  // The field is the source of truth and the name is checked against it. That is
  // the opposite of deriving stages from a name: nothing *learns* which stages a
  // file serves by parsing it, and a file whose name stops saying what it serves
  // is caught rather than trusted.
  check("each split file's name says which stages it serves", () =>
    withShippedStore((ledger) => {
      const offending = [];
      const seen = new Set();
      for (const record of ledger.records) {
        if (record['fires-when'] !== 'stage' || seen.has(record.file)) continue;
        seen.add(record.file);
        const name = record.file.replace(/\.md$/, '');
        const suffix = record.stages.join('-');
        if (!name.endsWith(`-${suffix}`) && name !== suffix) {
          offending.push(`${record.file} serves [${record.stages.join(', ')}] and its name does not say so`);
        }
      }
      return offending;
    }));

  check('no shipped script derives a stage from a filename', () => {
    const offending = [];
    for (const entry of entries(SCRIPTS)) {
      if (!entry.name.endsWith('.js')) continue;
      const source = read(`${SCRIPTS}/${entry.name}`);
      // A stage read out of a name would be a second home for `stages`, which is
      // the option ADR 0104 rejected wearing a different spelling.
      if (/\.(?:name|file)\b[^\n]*\.(?:split|match|replace)\([^\n]*stage/i.test(source)) {
        offending.push(`${entry.name} appears to read a stage out of a filename`);
      }
    }
    return offending;
  });
});

ticket('addressing/01', 'the rule for naming a record is stated once, and the specification agrees', (check) => {
  // The directories the store replaces. `rules` is deliberately not among them:
  // the boot tier stays files because the harness is the only channel that
  // reaches a clone without the plugin, so naming it is correct and a guard that
  // caught it would be pressing correct text to change.
  const DEPARTED = ['modes', 'policies', 'contexts', 'decisions', 'designs', 'evidence', 'tools'];

  // Anchored to "<name> directory" rather than to the sentence this ticket
  // rewrites. A guard built from the new wording matches only the new wording,
  // so a second passage resolving against a departed directory would sit unseen
  // beside a green assertion.
  check("the specification resolves a skill's declarations against the store", () => {
    const naming = new RegExp(`\\b(${DEPARTED.join('|')}) directory\\b`);
    const offending = [];
    read('specs.md')
      .split('\n')
      .forEach((line, index) => {
        const found = line.match(naming);
        if (found) offending.push(`specs.md:${index + 1} resolves against the ${found[1]} directory`);
      });
    return offending;
  });

  // Distinct from the check above and not a stricter form of it: that one catches
  // a directory named as what something resolves *against*, this one catches a
  // path written out. A passage can carry either without the other.
  check('the specification names no directory the release it specifies deletes', () => {
    const path = new RegExp(`\\.claude/(${DEPARTED.join('|')})/`);
    const offending = [];
    read('specs.md')
      .split('\n')
      .forEach((line, index) => {
        const found = line.match(path);
        if (found) offending.push(`specs.md:${index + 1} names .claude/${found[1]}/`);
      });
    return offending;
  });
});

ticket('addressing/05', 'the installed templates conform, and the router column names records', (check) => {
  const ROUTER_TEMPLATE = `${SKILLS}/configure/protocol.template.md`;

  /** Every row of the router's stage table, by stage. */
  const routerRows = () => {
    const rows = new Map();
    for (const line of read(ROUTER_TEMPLATE).split('\n')) {
      const match = line.match(/^\|\s*`\/([a-z]+)`\s*\|\s*([a-z-]+)\s*\|\s*(.*?)\s*\|\s*$/);
      if (match) rows.set(match[1], { posture: match[2], column: match[3] });
    }
    return rows;
  };

  /**
   * The subjects a stage's row actually selects, computed from the two places a
   * record can come from: the framework store as shipped, and the templates that
   * install a repository's own. Both declare `stages`, so neither is read off a
   * name -- the name is only what the subject is recovered from once the field
   * has already decided the record belongs.
   */
  const deliveredTo = (stage) => {
    const out = new Set();
    for (const file of markdownUnder(KNOWLEDGE)) {
      const fields = frontmatter(file);
      if (!fields || fields['fires-when'] !== 'stage') continue;
      if (inlineList(fields.stages).includes(stage)) out.add(fields.subject);
    }
    for (const entry of entries(`${SKILLS}/configure/policies`)) {
      const declared = INSTALLED_FRONTMATTER(`${SKILLS}/configure/policies/${entry.name}`) || [];
      const stages = declared.find((line) => /^stages:/.test(line));
      const subject = declared.find((line) => /^subject:/.test(line));
      if (stages && subject && inlineList(stages.slice('stages:'.length).trim()).includes(stage)) {
        out.add(subject.slice('subject:'.length).trim());
      }
    }
    return out;
  };

  /** The stages whose skill declares the whole corpus, which no column enumerates. */
  const wildcardStages = () => {
    const out = new Set();
    for (const file of markdownUnder(SKILLS).filter((f) => f.endsWith('/SKILL.md'))) {
      const fields = frontmatter(file);
      if (fields && inlineList(fields.metadata.policies).includes('*')) out.add(fields.name);
    }
    return out;
  };

  // Nothing at runtime reads this column -- the assembler resolves the stage and
  // the posture and stops -- so its drift produces no failure anywhere else.
  // That is the whole reason ADR 0105 made this check a condition of keeping the
  // column rather than a later improvement on it.
  check('every stage column names exactly what the store delivers to that stage', () => {
    const wildcards = wildcardStages();
    const offending = [];
    for (const [stage, row] of routerRows()) {
      if (wildcards.has(stage)) continue;
      const named = new Set([...row.column.matchAll(/`([a-z-]+)`/g)].map((match) => match[1]));
      const delivered = deliveredTo(stage);
      for (const subject of named) {
        if (!delivered.has(subject)) offending.push(`/${stage} names ${subject}, which the store does not deliver to it`);
      }
      for (const subject of delivered) {
        if (!named.has(subject)) offending.push(`/${stage} receives ${subject}, which its column omits`);
      }
    }
    return offending;
  });

  check('no template addresses a store record by location', () => {
    const departed = new RegExp(`\\.claude/(${DEPARTED_AT_TWO.join('|')})/`);
    const offending = [];
    for (const entry of entries(`${SKILLS}/configure`)) {
      if (!entry.name.endsWith('.template.md')) continue;
      read(`${SKILLS}/configure/${entry.name}`)
        .split('\n')
        .forEach((line, index) => {
          const found = line.match(departed);
          if (found) offending.push(`${entry.name}:${index + 1} names .claude/${found[1]}/`);
        });
    }
    return offending;
  });

  // `placement` names the departed set as bare prose words rather than as paths,
  // which is why the check above cannot see it. One file, one enumeration, and
  // the guard that generalises this is `06`'s.
  check('no template enumerates the departed directories as prose', () => {
    const source = read(`${SKILLS}/configure/placement.template.md`);
    const named = DEPARTED_AT_TWO.filter((directory) => new RegExp(`\\b${directory}\\b`).test(source));
    return named.length >= 3 ? [`placement.template.md enumerates ${named.join(', ')}`] : [];
  });
});

ticket('addressing/07', 'every record declares what it is about', (check) => {
  const fixture = require('./fixtures/knowledge-store');
  const builder = () => resolveShipped('scripts/build-knowledge-store.js');
  const querier = () => resolveShipped('scripts/query-knowledge-store.js');
  const STORE = '.claude/knowledge/a.md';

  const ROUTER = [
    '---',
    'owner: framework',
    '---',
    '',
    '# Workflow protocol',
    '',
    '| Stage | Mode | Norms it receives |',
    '| --- | --- | --- |',
    '| `/implement` | implementation | the records its row selects |',
    '',
  ].join('\n');

  const record = (frontmatter) =>
    `---\n${frontmatter}\n---\n\n## First thing\n\n- **The first thing is stated once** and nothing restates it.\n`;

  const withRouter = (files, body) => fixture.withStore({ '.claude/protocol.md': ROUTER, ...files }, body);

  check('a record declaring no subject is refused, and the refusal names the file', () =>
    withRouter({ [STORE]: record('owner: repository\ntype: norm\nfires-when: stage\nstages: [implement]') }, (root) => {
      const result = fixture.run(builder(), root);
      const offending = [];
      if (result.status === 0) return ['a record declaring no subject was admitted'];
      if (!/subject/.test(result.output)) offending.push('the refusal does not say what is missing');
      if (!/a\.md/.test(result.output)) offending.push('the refusal does not name the file');
      return offending;
    }));

  // The field has to reach the ledger, not merely pass validation: the query
  // reads the index and nothing else, so a subject validated and dropped would
  // satisfy every check above and answer no filter.
  check('a declared subject answers a filter and returns that record alone', () =>
    withRouter(
      {
        [STORE]: record('owner: repository\ntype: norm\nsubject: alpha\nfires-when: stage\nstages: [implement]'),
        '.claude/knowledge/b.md': record(
          'owner: repository\ntype: norm\nsubject: beta\nfires-when: stage\nstages: [implement]',
        ),
      },
      (root) => {
        if (fixture.run(builder(), root).status !== 0) return ['the store was refused'];
        const result = fixture.run(querier(), root, ['subject=alpha']);
        const offending = [];
        if (result.status !== 0) return [`the query was refused: ${result.output.trim()}`];
        if (!/alpha/.test(result.output)) offending.push('the answer does not carry the subject asked for');
        if (/beta/.test(result.output)) offending.push('the answer carries a record with another subject');
        return offending;
      },
    ));

  // A subject nothing carries is a miss rather than a refusal, on the same terms
  // as every other declared field: the caller learns the store holds no such
  // record, which is a fact, where a refusal would only say the question was not
  // answered. Asserted because a new field is exactly where that line gets
  // redrawn by accident.
  check('a subject no record carries returns an empty answer rather than a refusal', () =>
    withRouter(
      { [STORE]: record('owner: repository\ntype: norm\nsubject: alpha\nfires-when: stage\nstages: [implement]') },
      (root) => {
        if (fixture.run(builder(), root).status !== 0) return ['the store was refused'];
        const result = fixture.run(querier(), root, ['subject=nothing-carries-this']);
        const offending = [];
        if (result.status !== 0) offending.push(`an unmatched subject was refused: ${result.output.trim()}`);
        if (/alpha/.test(result.output)) offending.push('the answer carries a record the filter did not match');
        return offending;
      },
    ));

  check('every shipped record declares a subject', () => {
    const offending = [];
    for (const file of markdownUnder(KNOWLEDGE)) {
      const fields = frontmatter(file);
      if (!fields) {
        offending.push(`${file} shows no frontmatter`);
        continue;
      }
      if (!fields.subject) offending.push(`${file} declares no subject`);
    }
    return offending;
  });

  check('every derived template declares a subject in the record it installs', () => {
    const offending = [];
    for (const entry of entries(`${SKILLS}/configure/policies`)) {
      const declared = INSTALLED_FRONTMATTER(`${SKILLS}/configure/policies/${entry.name}`);
      if (declared === null) {
        offending.push(`${entry.name} shows no frontmatter for the record it installs`);
        continue;
      }
      if (!declared.some((line) => /^subject:\s*\S/.test(line))) offending.push(`${entry.name} declares no subject`);
    }
    return offending;
  });

  // The same shape as the check forbidding a stage recovered from a name, and
  // for the same reason: the declared field is the source of truth, and a
  // second one recovered by parsing is a second home for what one field states.
  check('no shipped script derives a subject from a filename', () => {
    const offending = [];
    for (const entry of entries(SCRIPTS)) {
      if (!entry.name.endsWith('.js')) continue;
      const source = read(`${SCRIPTS}/${entry.name}`);
      if (/\.(?:name|file)\b[^\n]*\.(?:split|match|replace|slice)\([^\n]*subject/i.test(source)) {
        offending.push(`${entry.name} appears to read a subject out of a filename`);
      }
    }
    return offending;
  });

  check('the record format states both filename conventions and which store each belongs to', () => {
    const page = read(`${SKILLS}/configure/policies/records.template.md`);
    const offending = [];
    if (!/subject/.test(page)) offending.push('the format does not state the subject field');
    if (!/readable name/.test(page)) offending.push("the format does not say a repository's record keeps a readable name");
    if (!/encodes? the stages/.test(page)) {
      offending.push("the format does not say a framework stage norm's name encodes its stages");
    }
    return offending;
  });
});

// ---------------------------------------------------------------------- entry

function main(argv) {
  const index = argv.indexOf('--ticket');
  let selected = [...groups.keys()];

  if (index !== -1) {
    const name = argv[index + 1];
    if (!groups.has(name)) {
      process.stderr.write(`unknown ticket: ${name === undefined ? '(none given)' : name}\n`);
      process.stderr.write(`known tickets:\n`);
      for (const id of groups.keys()) process.stderr.write(`  ${id}  ${groups.get(id).description}\n`);
      return 2;
    }
    selected = [name];
  }

  let failed = 0;
  for (const id of selected) {
    const group = groups.get(id);
    process.stdout.write(`${id} — ${group.description}\n`);
    for (const { name, run } of group.checks) {
      let offending;
      try {
        offending = run();
      } catch (error) {
        process.stdout.write(`  FAIL  ${name}\n          threw: ${error.message}\n`);
        failed += 1;
        continue;
      }
      if (offending.length === 0) {
        process.stdout.write(`  ok    ${name}\n`);
      } else {
        failed += 1;
        process.stdout.write(`  FAIL  ${name}\n`);
        for (const entry of offending) process.stdout.write(`          ${entry}\n`);
      }
    }
  }

  process.stdout.write(failed === 0 ? '\nall assertions passed\n' : `\n${failed} assertion(s) failed\n`);
  return failed === 0 ? 0 : 1;
}

process.exitCode = main(process.argv.slice(2));
