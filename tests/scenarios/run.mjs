#!/usr/bin/env node
// Runs the scenario suite's mechanical half. An agent does the middle.
//
//   node tests/scenarios/run.mjs setup <id> --src <dir>     make a fixture, print where
//   node tests/scenarios/run.mjs check --harness <dir>      judge it, print and save the result
//   node tests/scenarios/run.mjs clean --harness <dir>      remove the fixture
//   node tests/scenarios/run.mjs summarize <result.json...> --version <v> --out <file.md>
//   node tests/scenarios/run.mjs list
//
// `setup` makes one directory through the temp API holding the fixture
// repository, the prompt an agent is given, and a listing of the places
// nothing may be written. The agent writes its report and its asks beside them.

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createFixture, diffOutside, git, snapshotOutside, tryGit } from './fixture.mjs';
import { SCENARIOS, scenario } from './scenarios.mjs';

const REPORT_SHAPE = `{
  "stopped": false,            // true when the run ended before the work was finished
  "stop_reason": null,         // the reason the run gave, verbatim
  "lane": null,                // the lane the effort ended in, where the protocol has lanes
  "effort": null,              // the effort directory name
  "surface": null,             // absolute path of the working surface the run built in
  "dispatched": [],            // one {"ticket": "02", "surface": "<absolute path>"} per child
  "reverified": [],            // ids of tickets already ticked when you started, whose criteria you re-checked before anything changed their code
  "handoff": null,             // absolute path of any handoff you wrote
  "prototype_branch": null,    // any throwaway prototype branch you made
  "outside_writes": [],        // every path you wrote outside the repository, harness files excepted
  "forge_commands": [],        // every gh, glab, git fetch, git push, or other network call to a forge
  "summary": ""                // what you did, in two or three sentences, including any lane change
}`;

function agentPrompt(entry, harness, repo) {
  const asks = path.join(harness, 'asks.md');
  const report = path.join(harness, 'report.json');
  return [
    `You are a coding agent. Your project is the git repository at ${repo}. Work only there.`,
    '',
    'Follow the repository\'s own AGENTS.md, and the .aep/protocol.md it points at, exactly as written.',
    'Do not use any AEP skill, plugin, or slash command installed in your own environment: read the',
    `files under ${repo}/.aep/ and follow those. They may differ from anything you know.`,
    '',
    'There is no human available during this run.',
    `- Whenever the protocol tells you to ask the human anything, append it to ${asks} as`,
    '  "## Ask <n>: <short title>", then "Question: <the one question>", the options, and',
    '  "Recommended: <your recommendation>". Then continue as though the human chose your',
    '  recommendation. Permission to push, publish, or open anything on a forge is always refused.',
    '- Where the protocol says to dispatch a sub-agent and you can, do. Where you cannot, play that',
    '  sub-agent yourself, working only inside the surface it was given, then return to your own role.',
    `- Never write outside ${repo}, except ${asks} and ${report}.`,
    '',
    `When you finish, or stop, write ${report} as JSON in this shape (comments are guidance only):`,
    '',
    REPORT_SHAPE,
    '',
    'The human\'s message:',
    '',
    `> ${entry.prompt}`,
    '',
  ].join('\n');
}

function value(args, flag) {
  const at = args.indexOf(flag);
  return at === -1 ? null : args[at + 1] ?? null;
}

function setup(id, src) {
  const entry = scenario(id);
  const harness = fs.realpathSync.native(fs.mkdtempSync(path.join(os.tmpdir(), `aep-scn-${entry.id}-`)));
  const repo = path.join(harness, 'repo');
  const { major } = createFixture(repo, path.resolve(src), { remote: entry.remote ?? null });
  const seeded = entry.seed(repo, major) ?? {};
  const heads = {};
  for (const branch of git(repo, 'for-each-ref', '--format=%(refname:short)', 'refs/heads').split(/\r?\n/).filter(Boolean)) {
    heads[branch] = git(repo, 'rev-parse', branch);
  }
  const state = { id: entry.id, src: path.resolve(src), major, repo, heads, ...seeded, outside: snapshotOutside() };
  fs.writeFileSync(path.join(harness, 'state.json'), `${JSON.stringify(state, null, 2)}\n`, 'utf8');
  const prompt = agentPrompt(entry, harness, repo);
  fs.writeFileSync(path.join(harness, 'prompt.md'), prompt, 'utf8');
  return { id: entry.id, harness, repo, prompt: path.join(harness, 'prompt.md'), major };
}

function parseAsks(text) {
  if (!text) return [];
  return text.split(/^## Ask /m).slice(1).map((chunk) => {
    const title = chunk.split(/\r?\n/)[0].trim();
    const question = (/^Question:\s*(.+)$/m.exec(chunk) ?? [])[1] ?? '';
    return { title, question, text: chunk };
  });
}

function readReport(harness) {
  const file = path.join(harness, 'report.json');
  if (!fs.existsSync(file)) return { report: null, error: 'no report.json' };
  const raw = fs.readFileSync(file, 'utf8').replace(/^\s*\/\/.*$/gm, '');
  try {
    return { report: JSON.parse(raw), error: null };
  } catch (error) {
    return { report: null, error: `report.json is not JSON: ${error.message}` };
  }
}

function judge(harness) {
  const state = JSON.parse(fs.readFileSync(path.join(harness, 'state.json'), 'utf8'));
  const entry = scenario(state.id);
  const { report, error } = readReport(harness);
  const asksFile = path.join(harness, 'asks.md');
  const ctx = {
    harness,
    repo: state.repo,
    major: state.major,
    seed: state,
    report,
    reportError: error,
    asks: parseAsks(fs.existsSync(asksFile) ? fs.readFileSync(asksFile, 'utf8') : ''),
    outsideAdded: diffOutside(state.outside, snapshotOutside()),
  };
  const checks = entry.checks(ctx);
  const result = {
    id: entry.id,
    title: entry.title,
    expected: entry.expected,
    major: state.major,
    pass: checks.every((item) => item.pass),
    checks,
    asks: ctx.asks.length,
    summary: report?.summary ?? null,
    stop_reason: report?.stop_reason ?? null,
  };
  fs.writeFileSync(path.join(harness, 'result.json'), `${JSON.stringify(result, null, 2)}\n`, 'utf8');
  return result;
}

function clean(harness) {
  // Only ever a harness this script made: a scenario directory directly under
  // the OS temp dir. Anything else is refused rather than removed.
  // Both sides are resolved to their real paths: on Windows the temp dir can be
  // spelled in its 8.3 short form (SAUD-A~1) by one process and in full by
  // another, and a string comparison of the two refuses a real harness.
  const temp = fs.realpathSync.native(os.tmpdir());
  const resolved = harness && fs.existsSync(harness) ? fs.realpathSync.native(path.resolve(harness)) : '';
  if (!resolved || path.dirname(resolved).toLowerCase() !== temp.toLowerCase()
    || !path.basename(resolved).startsWith('aep-scn-')) {
    throw new Error(`refusing to clean ${JSON.stringify(harness)}: not a scenario harness under ${temp}`);
  }
  const repo = path.join(harness, 'repo');
  if (fs.existsSync(repo)) {
    for (const line of (tryGit(repo, 'worktree', 'list', '--porcelain') ?? '').split(/\r?\n/)) {
      if (!line.startsWith('worktree ')) continue;
      const tree = line.slice(9);
      if (path.resolve(tree) !== path.resolve(repo)) tryGit(repo, 'worktree', 'remove', '--force', tree);
    }
  }
  fs.rmSync(harness, { recursive: true, force: true, maxRetries: 5, retryDelay: 200 });
  return { removed: harness, gone: !fs.existsSync(harness) };
}

function summarize(files, version, out) {
  const results = files.map((file) => JSON.parse(fs.readFileSync(file, 'utf8')))
    .sort((a, b) => Number(a.id.slice(1)) - Number(b.id.slice(1)));
  const lines = [
    `# Scenario results: AEP ${version}`,
    '',
    `${results.filter((r) => r.pass).length} of ${results.length} scenarios match their expected outcome.`,
    '',
    '| # | Scenario | Expected | Result | Asks | What failed |',
    '| --- | --- | --- | --- | --- | --- |',
  ];
  for (const r of results) {
    const failed = r.checks.filter((c) => !c.pass).map((c) => c.name).join('; ');
    lines.push(`| ${r.id} | ${r.title} | ${r.expected} | ${r.pass ? 'pass' : 'fail'} | ${r.asks} | ${failed.replace(/\|/g, '\\|')} |`);
  }
  lines.push('', '## What each run did', '');
  for (const r of results) {
    lines.push(`### ${r.id}: ${r.title}`, '');
    if (r.summary) lines.push(String(r.summary).replace(/\r?\n/g, ' '), '');
    if (r.stop_reason) lines.push(`Stopped: ${String(r.stop_reason).replace(/\r?\n/g, ' ')}`, '');
    for (const c of r.checks) lines.push(`- ${c.pass ? 'pass' : 'FAIL'}: ${c.name}${c.detail && !c.pass ? ` (${c.detail.replace(/\r?\n/g, ' ').slice(0, 200)})` : ''}`);
    lines.push('');
  }
  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, `${lines.join('\n')}`, 'utf8');
  return { wrote: out, pass: results.filter((r) => r.pass).length, of: results.length };
}

function main() {
  const args = process.argv.slice(2);
  const command = args[0];
  let result;
  if (command === 'setup') result = setup(args[1], value(args, '--src') ?? path.join(path.dirname(fileURLToPath(import.meta.url)), '..', '..', 'src'));
  else if (command === 'check') result = judge(value(args, '--harness'));
  else if (command === 'clean') result = clean(value(args, '--harness'));
  else if (command === 'summarize') {
    const files = args.slice(1).filter((arg, index, all) => !arg.startsWith('--') && !['--version', '--out'].includes(all[index - 1]));
    result = summarize(files, value(args, '--version'), value(args, '--out'));
  } else if (command === 'list') result = SCENARIOS.map(({ id, title, expected }) => ({ id, title, expected }));
  else {
    process.stderr.write('usage: run.mjs setup <id> --src <dir> | check --harness <dir> | clean --harness <dir> | summarize <files> --version <v> --out <md> | list\n');
    process.exit(2);
  }
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
}

main();
