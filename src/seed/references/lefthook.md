---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, review]
use-when: "a commit or push is blocked by a hook here, or the hook checks should be run first"
---

# Reference — Lefthook

**This file is yours.** Installed because a Lefthook configuration was detected.
Read it for the commands each hook runs — that is the set of checks a commit
must pass.

## Commands

```sh
lefthook install                 # once per clone; without it the hooks never fire
lefthook run pre-commit          # run the checks without committing
lefthook run pre-push
lefthook run pre-commit --all-files
```

| Purpose | Command |
| --- | --- |
| run the pre-commit checks | `lefthook run pre-commit` |

Run these before committing. Commands configured with `stage_fixed` **rewrite
and re-stage files**, so a commit can end up containing more than was staged.

## Never bypass

`--no-verify` and `LEFTHOOK=0` skip the checks this repository decided to
enforce. Neither is used to get a change through
(`[[rules/version-control]]`). A hook that is wrong is a finding to raise.

## Failure handling

- Hooks not firing means `lefthook install` was never run in this clone.
- Commands run in parallel by default, so the output can interleave. `--verbose`
  attributes each line to its command.
- A `glob` or `files` filter that matches nothing makes a command look like it
  passed. Check what it actually ran (`[[policies/engineering]]`).
