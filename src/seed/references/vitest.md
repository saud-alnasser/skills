---
aep: 2.1.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test]
use-when: "running this repository's Vitest suite, or one test from it"
---

# Reference — Vitest

**This file is yours.** Installed because a Vitest configuration was detected.
Correct the invocations from `package.json` and CI.

## Commands

```sh
npx vitest run                   # single pass — what CI runs
npx vitest                       # watch mode; never in an automated run
npx vitest run <path>            # one file
npx vitest run -t "<name>"       # one test by name
npx vitest run --coverage
npx vitest run --reporter=verbose
```

| Purpose | Command |
| --- | --- |
| test | `npx vitest run` |
| single test file | `npx vitest run <path>` |
| single test | `npx vitest run -t "<name>"` |

**`vitest` without `run` watches and never exits.** In any non-interactive
context that is a hang, not a slow suite.

## Verification

A run that reports **no test files found** exits zero. Read the count, not the
exit status — a filter that matches nothing looks exactly like a suite that
passed (`[[rules/evidence]]`).

## Failure handling

- A test passing alone and failing in the suite is shared state, not flake.
  `--no-file-parallelism` distinguishes the two; it is a diagnosis, not a fix.
- Workspace or project configs mean the root run and a package run cover
  different files. Check which one CI uses.
- Never delete or skip a failing test to reach green. A skipped test is a
  finding to raise (`[[rules/engineering]]`).
