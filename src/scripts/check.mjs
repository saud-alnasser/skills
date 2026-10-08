#!/usr/bin/env node
// Checks the agent-facing text of an AEP tree against what keeps it cheap and
// safe to load: word budgets, no rationale paragraphs, and no wording that
// sends a write outside the project.
//
//   node .aep/scripts/check.mjs [--root <tree>] [--json] [--report]
//
// `--root` takes an installed `.aep/` or the distribution's `src/`, which share
// a layout. `--report` prints the same findings and exits 0, for a tree that is
// still being brought under budget.
//
// Reads files and nothing else: no git, no network.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { readArtifact, resolveAepRoot, toPosix, walk } from './contract.mjs';

/** Word budgets, by the kind of file. A word is a token holding a letter or a digit. */
export const BUDGETS = {
  protocol: 600,
  skill: 1200,
  'skill note': 600,
  policy: 800,
};

/**
 * What a standard-lane `/implement` loads before it touches code, and its
 * budget. A repository's own rules are not counted: their size is the
 * repository's choice.
 */
export const HOT_PATH = {
  budget: 4000,
  files: [
    'protocol.md',
    'skills/implement.md',
    'policies/execution.md',
    'policies/reporting.md',
    'skills/review.md',
  ],
};

/** The directories whose text an agent follows. Seeds and efforts are the repository's. */
const AGENT_FACING = ['policies', 'skills', 'agents', 'templates'];

/** Rationale: a sentence that justifies a rule instead of stating one, opening a paragraph or inline. */
const WHY = /(?:^|\s)\*{1,3}Why\b/;

/** Wording that sends a write somewhere other than the project. */
export const OUTSIDE_WRITES = [
  { name: 'outside the repository', pattern: /\boutside the (?:repository|repo)\b/i },
  { name: 'home directory', pattern: /\bhome director(?:y|ies)\b/i },
  { name: 'drive path', pattern: /(?:^|[\s`'"(])[A-Za-z]:[\\/]/ },
  { name: '/tmp path', pattern: /(?:^|[\s`'"(])\/tmp\b/ },
  { name: 'home path', pattern: /(?:^|[\s`'"(])~\// },
];

export function countWords(text) {
  return text.split(/\s+/).filter((token) => /[\p{L}\p{N}]/u.test(token)).length;
}

function bodyWords(file) {
  return countWords(readArtifact(file).body);
}

/** Every agent-facing Markdown file in the tree, as tree-relative POSIX paths. */
export function agentFacing(root) {
  const files = [];
  if (fs.existsSync(path.join(root, 'protocol.md'))) files.push('protocol.md');
  for (const dir of AGENT_FACING) {
    const full = path.join(root, dir);
    if (!fs.existsSync(full)) continue;
    for (const file of walk(full)) {
      if (file.endsWith('.md')) files.push(toPosix(root, file));
    }
  }
  return files.sort();
}

/** The budget a file is held to, or null where none applies. */
export function budgetOf(rel) {
  if (rel === 'protocol.md') return { kind: 'protocol', limit: BUDGETS.protocol };
  const parts = rel.split('/');
  if (parts[0] === 'skills') {
    return parts.length === 2
      ? { kind: 'skill', limit: BUDGETS.skill }
      : { kind: 'skill note', limit: BUDGETS['skill note'] };
  }
  if (parts[0] === 'policies') return { kind: 'policy', limit: BUDGETS.policy };
  return null;
}

export function checkBudgets(root) {
  const files = [];
  for (const rel of agentFacing(root)) {
    const budget = budgetOf(rel);
    if (!budget) continue;
    const words = bodyWords(path.join(root, ...rel.split('/')));
    files.push({ file: rel, kind: budget.kind, words, limit: budget.limit, over: words > budget.limit });
  }

  const hot = HOT_PATH.files.map((rel) => {
    const full = path.join(root, ...rel.split('/'));
    return { file: rel, words: fs.existsSync(full) ? bodyWords(full) : 0 };
  });
  const hotWords = hot.reduce((sum, entry) => sum + entry.words, 0);

  return {
    files,
    over: files.filter((entry) => entry.over),
    hotPath: { files: hot, words: hotWords, limit: HOT_PATH.budget, over: hotWords > HOT_PATH.budget },
  };
}

export function checkWhy(root) {
  const hits = [];
  for (const rel of agentFacing(root)) {
    const lines = fs.readFileSync(path.join(root, ...rel.split('/')), 'utf8').split(/\r?\n/);
    lines.forEach((line, index) => {
      if (WHY.test(line)) hits.push({ file: rel, line: index + 1 });
    });
  }
  return hits;
}

export function checkOutsideWrites(root) {
  const hits = [];
  for (const rel of agentFacing(root)) {
    const lines = fs.readFileSync(path.join(root, ...rel.split('/')), 'utf8').split(/\r?\n/);
    lines.forEach((line, index) => {
      for (const { name, pattern } of OUTSIDE_WRITES) {
        if (pattern.test(line)) hits.push({ file: rel, line: index + 1, wording: name });
      }
    });
  }
  return hits;
}

export function runChecks(root) {
  const budgets = checkBudgets(root);
  const why = checkWhy(root);
  const outside = checkOutsideWrites(root);
  const failures = budgets.over.length + (budgets.hotPath.over ? 1 : 0) + why.length + outside.length;
  return { budgets, why, outside, ok: failures === 0 };
}

function render(result) {
  const out = [];
  const { budgets, why, outside } = result;
  out.push(`budgets: ${budgets.over.length} of ${budgets.files.length} files over`);
  for (const entry of budgets.over) {
    out.push(`  over  ${entry.file}  ${entry.words}/${entry.limit} (${entry.kind})`);
  }
  const hot = budgets.hotPath;
  out.push(`standard-lane /implement load: ${hot.words}/${hot.limit}${hot.over ? '  over' : ''}`);
  for (const entry of hot.files) out.push(`        ${entry.file}  ${entry.words}`);
  out.push(`rationale (*Why) sentences: ${why.length}`);
  for (const hit of why) out.push(`  why   ${hit.file}:${hit.line}`);
  out.push(`wording that writes outside the project: ${outside.length}`);
  for (const hit of outside) out.push(`  out   ${hit.file}:${hit.line}  ${hit.wording}`);
  out.push(result.ok ? 'check: clean' : 'check: failures above');
  return `${out.join('\n')}\n`;
}

function main() {
  const args = process.argv.slice(2);
  const rootArg = args.includes('--root') ? args[args.indexOf('--root') + 1] : null;
  const root = resolveAepRoot(rootArg, import.meta.url);
  if (!root) {
    process.stderr.write('no .aep/ found. Pass --root, or run from a repository that has one\n');
    process.exit(2);
  }
  const result = runChecks(root);
  process.stdout.write(args.includes('--json') ? `${JSON.stringify(result, null, 2)}\n` : render(result));
  if (!result.ok && !args.includes('--report')) process.exit(1);
}

if (process.argv[1] && fileURLToPath(import.meta.url) === path.resolve(process.argv[1])) main();
