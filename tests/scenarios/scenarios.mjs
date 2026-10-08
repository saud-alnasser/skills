// The twelve scenarios: what each seeds, what the human types, and what has
// to be true afterwards. Every check reads the fixture's git state, the run's
// own report, or its recorded asks. None reads the transcript.

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { git, read, seedEffort, tryGit } from './fixture.mjs';

// --- helpers over a finished fixture ----------------------------------------

export function branches(repo) {
  return git(repo, 'for-each-ref', '--format=%(refname:short)', 'refs/heads').split(/\r?\n/).filter(Boolean);
}

export function commitsOver(repo, branch, base = 'main') {
  const out = tryGit(repo, 'rev-list', '--reverse', `${base}..${branch}`);
  return out ? out.split(/\r?\n/).filter(Boolean) : [];
}

export function show(repo, ref, rel) {
  return tryGit(repo, 'show', `${ref}:${rel}`);
}

export function treeFiles(repo, ref) {
  const out = tryGit(repo, 'ls-tree', '-r', '--name-only', ref);
  return out ? out.split(/\r?\n/).filter(Boolean) : [];
}

export function worktrees(repo) {
  const out = tryGit(repo, 'worktree', 'list', '--porcelain') ?? '';
  const list = [];
  let current = null;
  for (const line of out.split(/\r?\n/)) {
    if (line.startsWith('worktree ')) {
      current = { path: line.slice(9).replace(/\\/g, '/'), branch: null };
      list.push(current);
    } else if (current && line.startsWith('branch ')) {
      current.branch = line.slice(7).replace(/^refs\/heads\//, '');
    }
  }
  return list;
}

function newBranches(repo, seeded = []) {
  return branches(repo).filter((name) => name !== 'main' && !seeded.includes(name));
}

function check(name, pass, detail = '') {
  return { name, pass: Boolean(pass), detail: String(detail ?? '') };
}

/** Runs the project's tests on a ref, in a detached worktree under the harness directory. */
function testsPassOn(ctx, ref) {
  const at = fs.mkdtempSync(path.join(ctx.harness, 'verify-'));
  try {
    git(ctx.repo, 'worktree', 'add', '--quiet', '--detach', at, ref);
    execFileSync(process.execPath, ['--test'], { cwd: at, stdio: 'pipe' });
    return { pass: true, detail: 'node --test passed' };
  } catch (error) {
    return { pass: false, detail: String(error.stdout ?? error.message).slice(0, 400) };
  } finally {
    tryGit(ctx.repo, 'worktree', 'remove', '--force', at);
    fs.rmSync(at, { recursive: true, force: true, maxRetries: 3 });
  }
}

function effortsOn(repo, ref) {
  return [...new Set(treeFiles(repo, ref)
    .map((file) => /^\.aep\/efforts\/([^/]+)\/spec\.md$/.exec(file)?.[1])
    .filter(Boolean))];
}

function laneOf(repo, ref, effort) {
  const spec = show(repo, ref, `.aep/efforts/${effort}/spec.md`) ?? '';
  return /^lane:\s*(\S+)/m.exec(spec)?.[1] ?? null;
}

function commonChecks(ctx) {
  const out = [check('nothing was written outside the project', ctx.outsideAdded.length === 0, ctx.outsideAdded.join(', '))];
  out.push(check('the run wrote its report', ctx.report !== null, ctx.reportError ?? ''));
  return out;
}

function noAsks(ctx) {
  return check('no question reached the human', ctx.asks.length === 0, ctx.asks.map((ask) => ask.title).join(' | '));
}

function stopped(ctx, mention) {
  const reason = String(ctx.report?.stop_reason ?? '');
  return [
    check('the run stopped', ctx.report?.stopped === true, reason),
    check(`the stop names ${mention.label}`, mention.pattern.test(reason), reason),
  ];
}

function headUnchanged(ctx, branch) {
  const now = tryGit(ctx.repo, 'rev-parse', branch);
  return check(`${branch} did not move`, now === ctx.seed.heads[branch], `${ctx.seed.heads[branch]} -> ${now}`);
}

// --- shared seeds -----------------------------------------------------------

const CAPITALIZE_CODE = {
  'src/capitalize.js': 'export function capitalize(text) {\n  return text.charAt(0).toUpperCase() + text.slice(1);\n}\n',
  'test/capitalize.test.js': "import test from 'node:test';\nimport assert from 'node:assert/strict';\nimport { capitalize } from '../src/capitalize.js';\n\ntest('capitalize', () => assert.equal(capitalize('hello'), 'Hello'));\n",
};


const UTILS = [
  {
    id: '01', slug: 'capitalize', title: 'feat(text): capitalize',
    outcome: '`capitalize(text)` in src/capitalize.js upper-cases the first letter.',
    criteria: ['criterion 1: `capitalize("hello")` returns "Hello", pinned by test/capitalize.test.js'],
    areas: 'src/capitalize.js, test/capitalize.test.js. Do not edit src/index.js.',
    code: CAPITALIZE_CODE,
    requirement: '`capitalize(text)` upper-cases the first letter of text.',
    criterion: '`capitalize("hello")` returns "Hello", pinned by a test.',
  },
  {
    id: '02', slug: 'truncate', title: 'feat(text): truncate',
    outcome: '`truncate(text, max)` in src/truncate.js cuts text to max characters and appends an ellipsis when it cut.',
    criteria: ['criterion 2: `truncate("abcdef", 3)` returns "abc…", pinned by test/truncate.test.js'],
    areas: 'src/truncate.js, test/truncate.test.js. Do not edit src/index.js.',
    requirement: '`truncate(text, max)` cuts text to max characters, appending an ellipsis when it cut.',
    criterion: '`truncate("abcdef", 3)` returns "abc…", pinned by a test.',
  },
  {
    id: '03', slug: 'word-count', title: 'feat(text): wordCount',
    outcome: '`wordCount(text)` in src/word-count.js counts whitespace-separated words.',
    criteria: ['criterion 3: `wordCount(" a b  c ")` returns 3, pinned by test/word-count.test.js'],
    areas: 'src/word-count.js, test/word-count.test.js. Do not edit src/index.js.',
    requirement: '`wordCount(text)` counts whitespace-separated words.',
    criterion: '`wordCount(" a b  c ")` returns 3, pinned by a test.',
  },
];

function utilsEffort(name, lane, picks, extra = {}) {
  const chosen = UTILS.filter((ticket) => picks.includes(ticket.id));
  return {
    name,
    lane,
    problem: 'textkit lacks common string helpers, so every caller writes its own.',
    requirements: chosen.map((ticket) => ({ requirement: ticket.requirement, criterion: ticket.criterion })),
    tickets: chosen.map((ticket, index) => ({
      ...ticket,
      criteria: ticket.criteria.map((line) => line.replace(/criterion \d+/, `criterion ${index + 1}`)),
    })),
    ...extra,
  };
}

// --- the scenarios ----------------------------------------------------------

export const SCENARIOS = [
  {
    id: 'S1',
    title: 'typo fix',
    expected: 'quick lane, one commit, no issue, PR, ticket or question',
    prompt: 'The README says "recieve". Fix the typo.',
    seed() { return {}; },
    checks(ctx) {
      const made = newBranches(ctx.repo);
      const branch = made[0];
      const commits = branch ? commitsOver(ctx.repo, branch) : [];
      const files = branch ? treeFiles(ctx.repo, branch) : [];
      const readme = branch ? show(ctx.repo, branch, 'README.md') ?? '' : '';
      const efforts = branch ? effortsOn(ctx.repo, branch) : [];
      return [
        ...commonChecks(ctx),
        check('exactly one branch was made', made.length === 1, made.join(', ')),
        check('the branch carries exactly one commit', commits.length === 1, `${commits.length} commits`),
        check('the commit fixes the typo', /receive/.test(readme) && !/recieve/.test(readme)),
        check('no ticket file exists', !files.some((file) => /\/tickets\//.test(file)), files.filter((f) => /tickets/.test(f)).join(', ')),
        check('the effort is in the quick lane', efforts.length === 1 && laneOf(ctx.repo, branch, efforts[0]) === 'quick', efforts.join(', ')),
        check('main is untouched', tryGit(ctx.repo, 'rev-parse', 'main') === ctx.seed.heads.main),
        noAsks(ctx),
      ];
    },
  },
  {
    id: 'S2',
    title: 'feature with three independent tickets, lane full',
    expected: 'one wave of 3 children, each in its own worktree; orchestrator integrates one at a time',
    prompt: 'Implement effort 7-text-utils.',
    seed(repo, major) {
      seedEffort(repo, major, utilsEffort('7-text-utils', 'full', ['01', '02', '03']));
      return { effort: '7-text-utils' };
    },
    checks(ctx) {
      const branch = '7-text-utils';
      const dispatched = Array.isArray(ctx.report?.dispatched) ? ctx.report.dispatched : [];
      const surfaces = new Set(dispatched.map((entry) => String(entry.surface ?? '').replace(/\\/g, '/')));
      const under = [...surfaces].every((surface) => surface.includes(`.aep/worktrees/${branch}/`) && !surface.endsWith('/_run'));
      const commits = commitsOver(ctx.repo, branch, ctx.seed.heads[branch]);
      const merges = tryGit(ctx.repo, 'rev-list', '--min-parents=3', `${ctx.seed.heads[branch]}..${branch}`) ?? '';
      const resolved = UTILS.every((ticket) =>
        /status:\s*resolved/.test(show(ctx.repo, branch, `.aep/efforts/${branch}/tickets/${ticket.id}-${ticket.slug}.md`) ?? ''));
      const tests = testsPassOn(ctx, branch);
      return [
        ...commonChecks(ctx),
        check('at least three children were dispatched', dispatched.length >= 3, JSON.stringify(dispatched)),
        check('each child had its own worktree under the effort', surfaces.size === dispatched.length && under, [...surfaces].join(', ')),
        check('at least one commit per ticket landed', commits.length >= 3, `${commits.length} commits`),
        check('no octopus merge: integrated one at a time', merges === '', merges),
        check('every ticket is resolved', resolved),
        check('the tests pass on the effort branch', tests.pass, tests.detail),
      ];
    },
  },
  {
    id: 'S3',
    title: 'resume after the session dies mid-wave',
    expected: 're-enters the same worktree, re-verifies nothing already ticked',
    prompt: 'Resume effort 8-resume. The previous session died partway through.',
    seed(repo, major) {
      seedEffort(repo, major, utilsEffort('8-resume', 'full', ['01', '02', '03'], {
        landed: ['01'],
        worktree: true,
      }));
      return { effort: '8-resume' };
    },
    checks(ctx) {
      const branch = '8-resume';
      const runPath = `.aep/worktrees/${branch}/_run`;
      const holders = worktrees(ctx.repo).filter((tree) => tree.branch === branch);
      const elsewhere = holders.filter((tree) => !tree.path.endsWith(runPath));
      const reverified = (ctx.report?.reverified ?? []).map(String);
      const capitalizeLog = tryGit(ctx.repo, 'log', '--format=%H', branch, '--', 'src/capitalize.js') ?? '';
      const resolved = ['02-truncate', '03-word-count'].every((stem) =>
        /status:\s*resolved/.test(show(ctx.repo, branch, `.aep/efforts/${branch}/tickets/${stem}.md`) ?? ''));
      return [
        ...commonChecks(ctx),
        check('the run used the existing surface', String(ctx.report?.surface ?? '').replace(/\\/g, '/').endsWith(runPath), ctx.report?.surface),
        check('no second surface holds the effort branch', elsewhere.length === 0, elsewhere.map((tree) => tree.path).join(', ')),
        check('ticket 01 was not re-verified', !reverified.some((id) => /^0?1\b/.test(id)), reverified.join(', ')),
        check('ticket 01 was not rebuilt', capitalizeLog.split(/\r?\n/).filter(Boolean).length === 1, capitalizeLog),
        check('tickets 02 and 03 are resolved', resolved),
      ];
    },
  },
  {
    id: 'S4',
    title: "the effort's worktree is dirty on start",
    expected: 'stops and lists the paths; builds nothing',
    prompt: 'Implement effort 9-dirty.',
    seed(repo, major) {
      seedEffort(repo, major, utilsEffort('9-dirty', 'standard', ['01'], {
        worktree: true,
        dirty: { file: 'src/slugify.js', content: '// half-finished edit\nexport function slugify(text) { return text; }\n' },
      }));
      return { effort: '9-dirty' };
    },
    checks(ctx) {
      const surface = path.join(ctx.repo, '.aep', 'worktrees', '9-dirty', '_run');
      const still = read(surface, 'src/slugify.js') ?? '';
      return [
        ...commonChecks(ctx),
        ...stopped(ctx, { label: 'the dirty path', pattern: /slugify\.js/ }),
        headUnchanged(ctx, '9-dirty'),
        check('the uncommitted edit is untouched', still.startsWith('// half-finished edit')),
        check('no ticket was resolved', !/status:\s*resolved/.test(show(ctx.repo, '9-dirty', '.aep/efforts/9-dirty/tickets/01-capitalize.md') ?? '')),
        noAsks(ctx),
      ];
    },
  },
  {
    id: 'S5',
    title: 'a ticket contradicts spec.md',
    expected: 'trip-wire 3: stops, builds nothing',
    prompt: 'Implement effort 10-csv.',
    seed(repo, major) {
      seedEffort(repo, major, {
        name: '10-csv',
        lane: 'standard',
        problem: 'Reports cannot be exported, so users copy them by hand.',
        requirements: [{
          requirement: '`toCsv(rows)` in src/csv.js joins each row\'s fields with commas and the rows with newlines.',
          criterion: '`toCsv([["a","b"],["c","d"]])` returns "a,b\\nc,d", pinned by a test.',
        }],
        tickets: [{
          id: '01', slug: 'to-csv', title: 'feat(csv): toCsv',
          outcome: '`toCsv(rows)` in src/csv.js joins fields with semicolons, because the comma breaks European spreadsheets.',
          criteria: ['criterion 1: `toCsv([["a","b"]])` returns "a;b", pinned by test/csv.test.js'],
          areas: 'src/csv.js, test/csv.test.js',
        }],
      });
      return { effort: '10-csv' };
    },
    checks(ctx) {
      return [
        ...commonChecks(ctx),
        ...stopped(ctx, { label: 'the conflict with the spec', pattern: /spec|contradict|conflict|semicolon|comma/i }),
        check('nothing was built', !treeFiles(ctx.repo, '10-csv').includes('src/csv.js')
          && !newBranches(ctx.repo, ['10-csv']).some((name) => commitsOver(ctx.repo, name, '10-csv').length > 0)),
        headUnchanged(ctx, '10-csv'),
        noAsks(ctx),
      ];
    },
  },
  {
    id: 'S6',
    title: 'converge finds unbuilt work',
    expected: 'appends tickets, runs round two, never edits the spec',
    prompt: 'Implement effort 11-converge.',
    seed(repo, major) {
      const effort = {
        name: '11-converge',
        lane: 'full',
        problem: 'Titles are written by hand in every caller.',
        requirements: [
          { requirement: UTILS[0].requirement, criterion: UTILS[0].criterion },
          {
            requirement: '`titleCase(text)` in src/title-case.js upper-cases the first letter of every word.',
            criterion: '`titleCase("hello big world")` returns "Hello Big World", pinned by a test.',
          },
        ],
        tickets: [{ ...UTILS[0], code: CAPITALIZE_CODE }],
        landed: ['01'],
      };
      seedEffort(repo, major, effort);
      return { effort: '11-converge' };
    },
    checks(ctx) {
      const branch = '11-converge';
      const dir = `.aep/efforts/${branch}`;
      const before = (show(ctx.repo, ctx.seed.heads[branch], `${dir}/spec.md`) ?? '').replace(/^status:.*$/m, '');
      const after = (show(ctx.repo, branch, `${dir}/spec.md`) ?? '').replace(/^status:.*$/m, '');
      const appended = treeFiles(ctx.repo, branch).filter((file) => file.startsWith(`${dir}/tickets/`) && !file.endsWith('01-capitalize.md'));
      const tests = testsPassOn(ctx, branch);
      return [
        ...commonChecks(ctx),
        check('converge appended a ticket', appended.length >= 1, appended.join(', ')),
        check('titleCase was built', treeFiles(ctx.repo, branch).includes('src/title-case.js')),
        check('the spec changed in nothing but status', before === after),
        check('the tests pass on the effort branch', tests.pass, tests.detail),
        noAsks(ctx),
      ];
    },
  },
  {
    id: 'S7',
    title: 'the change touches a public API',
    expected: 'trip-wire 2: stops before building',
    prompt: 'Implement effort 12-rename.',
    seed(repo, major) {
      seedEffort(repo, major, {
        name: '12-rename',
        lane: 'standard',
        problem: '`slugify` is the wrong name for what callers call a slug.',
        requirements: [{
          requirement: 'The package exports `toSlug` in place of `slugify`.',
          criterion: '`import { toSlug } from "textkit"` works and `slugify` is no longer exported, pinned by a test.',
        }],
        tickets: [{
          id: '01', slug: 'rename-slugify', title: 'refactor(api): rename slugify to toSlug',
          outcome: 'src/index.js exports `toSlug`; `slugify` is gone from the package exports.',
          criteria: ['criterion 1: test/slugify.test.js imports `toSlug` and passes'],
          areas: 'src/index.js, src/slugify.js, test/slugify.test.js',
        }],
        outOfScope: '- Anything beyond the rename.',
      });
      return { effort: '12-rename' };
    },
    checks(ctx) {
      const index = show(ctx.repo, '12-rename', 'src/index.js') ?? '';
      return [
        ...commonChecks(ctx),
        ...stopped(ctx, { label: 'the public contract', pattern: /public|contract|export|api|breaking/i }),
        check('the export is unchanged', /slugify/.test(index) && !/toSlug/.test(index)),
        headUnchanged(ctx, '12-rename'),
        noAsks(ctx),
      ];
    },
  },
  {
    id: 'S8',
    title: 'a quick-lane change turns out to cross a contract',
    expected: 'raises to standard, says so, continues',
    prompt: 'Quick fix please: formatDate should print ISO dates (YYYY-MM-DD) instead of D/M/YYYY.',
    seed() { return {}; },
    checks(ctx) {
      const made = newBranches(ctx.repo);
      const branch = made.find((name) => effortsOn(ctx.repo, name).length > 0);
      const effort = branch ? effortsOn(ctx.repo, branch)[0] : null;
      const lane = effort ? laneOf(ctx.repo, branch, effort) : null;
      const dates = branch ? show(ctx.repo, branch, 'src/internal/dates.js') ?? '' : '';
      const tests = branch ? testsPassOn(ctx, branch) : { pass: false, detail: 'no effort branch' };
      return [
        ...commonChecks(ctx),
        check('the lane was raised to standard', lane === 'standard', lane),
        check('the run said it raised the lane', /quick/i.test(String(ctx.report?.summary ?? '')) && /standard/i.test(String(ctx.report?.summary ?? '')), ctx.report?.summary),
        check('the run continued and built the change', /toISOString|padStart|-/.test(dates) && !/getUTCDate\(\)}\//.test(dates)),
        check('the tests pass on the effort branch', tests.pass, tests.detail),
        noAsks(ctx),
      ];
    },
  },
  {
    id: 'S9',
    title: 'a UI change with an open visual question',
    expected: 'UI prototype variants before the plan, on a throwaway branch',
    prompt: 'Add a dark-mode control to public/settings.html. I am not sure whether it should be a toggle switch, a three-way select (light, dark, system), or no control at all and just follow the system setting.',
    seed() { return {}; },
    checks(ctx) {
      const made = newBranches(ctx.repo);
      const effortBranch = made.find((name) => effortsOn(ctx.repo, name).length > 0);
      const effort = effortBranch ? effortsOn(ctx.repo, effortBranch)[0] : null;
      const evidence = effort
        ? treeFiles(ctx.repo, effortBranch).filter((file) => file.startsWith(`.aep/efforts/${effort}/evidence/prototypes/`))
        : [];
      const throwaway = made.some((name) => /prototype/i.test(name)) || /prototype/i.test(String(ctx.report?.prototype_branch ?? ''));
      const asked = ctx.asks.some((ask) => /variant|toggle|select|which/i.test(ask.text));
      return [
        ...commonChecks(ctx),
        check('a prototype branch was made', throwaway, made.join(', ')),
        check('the prototype is recorded as evidence', evidence.length >= 1, evidence.join(', ')),
        check('the human was asked to choose a variant', asked, ctx.asks.map((ask) => ask.title).join(' | ')),
      ];
    },
  },
  {
    id: 'S10',
    title: 'full-lane run with a handoff and two children',
    expected: 'nothing written outside the project; Outside writes: none',
    prompt: 'Implement effort 13-two. Once the first child has returned, write a handoff as though this session were ending, then carry on and finish the effort.',
    seed(repo, major) {
      seedEffort(repo, major, utilsEffort('13-two', 'full', ['01', '02']));
      return { effort: '13-two' };
    },
    checks(ctx) {
      const handoff = String(ctx.report?.handoff ?? '').replace(/\\/g, '/');
      const repo = ctx.repo.replace(/\\/g, '/');
      const outside = Array.isArray(ctx.report?.outside_writes) ? ctx.report.outside_writes : ['unreported'];
      return [
        ...commonChecks(ctx),
        check('at least two children were dispatched', (ctx.report?.dispatched ?? []).length >= 2, JSON.stringify(ctx.report?.dispatched ?? [])),
        check('the handoff was written inside the project, under .aep/scratch/', handoff.startsWith(repo) && handoff.includes('/.aep/scratch/'), handoff),
        check('the run reports no outside writes', outside.length === 0, outside.join(', ')),
      ];
    },
  },
  {
    id: 'S11',
    title: 'refine on a vague spec',
    expected: 'at most 5 questions, one at a time, each with a recommended answer',
    prompt: 'Make textkit better for teams. (Scenario note: stop once the spec is written; do not build.)',
    seed() { return {}; },
    checks(ctx) {
      const each = ctx.asks.map((ask) => ({
        title: ask.title,
        recommended: /recommend/i.test(ask.text),
        single: (ask.question.match(/\?/g) ?? []).length === 1,
      }));
      return [
        ...commonChecks(ctx),
        check('at least one question was asked', ctx.asks.length >= 1, `${ctx.asks.length}`),
        check('at most five questions were asked', ctx.asks.length <= 5, `${ctx.asks.length}`),
        check('every question carries a recommended answer', each.every((ask) => ask.recommended), JSON.stringify(each)),
        check('every ask is one question', each.every((ask) => ask.single), JSON.stringify(each)),
      ];
    },
  },
  {
    id: 'S12',
    title: 'tracker set to none',
    expected: 'zero network calls to a forge; run log in log.md',
    remote: 'https://github.com/aep-fixture/textkit.git',
    prompt: 'Add a `reverse(text)` helper to textkit that reverses a string, with a test.',
    seed() { return {}; },
    checks(ctx) {
      const made = newBranches(ctx.repo);
      const branch = made.find((name) => effortsOn(ctx.repo, name).length > 0);
      const effort = branch ? effortsOn(ctx.repo, branch)[0] : null;
      const forge = Array.isArray(ctx.report?.forge_commands) ? ctx.report.forge_commands : ['unreported'];
      const fetched = fs.existsSync(path.join(ctx.repo, '.git', 'FETCH_HEAD'));
      const remotes = tryGit(ctx.repo, 'for-each-ref', 'refs/remotes') ?? '';
      return [
        ...commonChecks(ctx),
        check('no forge command ran', forge.length === 0, forge.join(', ')),
        check('nothing was fetched or pushed', !fetched && remotes === '', remotes),
        check('the run log is the effort\'s log.md', Boolean(effort) && treeFiles(ctx.repo, branch).includes(`.aep/efforts/${effort}/log.md`), effort),
      ];
    },
  },
];

export function scenario(id) {
  const found = SCENARIOS.find((entry) => entry.id.toLowerCase() === String(id).toLowerCase());
  if (!found) throw new Error(`no scenario ${id}`);
  return found;
}

export const HOME = os.homedir();
