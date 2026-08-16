---
aep: 2.1.1
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, review]
use-when: "a commit or push is blocked by a git hook here, or those checks should be run first"
---

# Reference — Husky

**This file is yours.** Installed because a `.husky` directory was detected.
Read the hook scripts in it — each one is a shell script, and together they are
the set of checks a commit or push must pass here.

## What runs when

Fill this in from the actual files in `.husky/`:

| Hook | Runs |
| --- | --- |
| `pre-commit` | |
| `commit-msg` | |
| `pre-push` | |

Run the same commands directly before committing, rather than discovering them
at commit time. A `pre-commit` that calls `lint-staged` will also **rewrite
staged files**, which turns one commit into a partially staged one.

## Never bypass

`git commit --no-verify` and `git push --no-verify` skip the checks this
repository decided to enforce, and `HUSKY=0` disables them wholesale. **None of
those is used to get a change through** (`[[rules/version-control]]`). A hook
that is wrong is a finding to raise.

## Failure handling

- Hooks not firing at all usually means `husky` was never installed in this
  clone — the `prepare` script does it on install.
- A `commit-msg` hook enforces a message convention; the failure names the rule,
  and rewriting the message is the fix, not disabling the hook.
- A hook that works in a terminal and fails from an editor is a `PATH`
  difference, since editors do not load a login shell.
