---
aep: 2.0.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, review]
use-when: "a commit is blocked by a hook here, or the hook checks should be run before committing"
---

# Reference — pre-commit

**This file is yours.** Installed because a `.pre-commit-config.yaml` was
detected. Read it for the hooks this repository actually runs — that list is the
set of checks a commit must pass.

## Commands

```sh
pre-commit install               # once per clone; without it the hooks never fire
pre-commit run --all-files       # run every hook over the whole repository
pre-commit run <hook-id> --all-files
pre-commit run                   # staged files only — what committing will do
```

| Purpose | Command |
| --- | --- |
| run the hooks | `pre-commit run --all-files` |
| what the commit will run | `pre-commit run` |

**Run the hooks before committing rather than discovering them at commit time.**
Several of them rewrite files, which turns a commit into a partially staged one.

## Never bypass

`git commit --no-verify` and `SKIP=<hook>` skip the checks this repository
decided to enforce. **Neither is used to get a commit through**
(`[[rules/version-control]]`). A hook that is wrong is a finding to raise; a
hook that is slow is still a hook.

## Failure handling

- A hook that modified files reports failure by design. Review the modification,
  stage it, and commit again — do not re-run until it passes without reading
  what changed.
- The first run builds isolated environments per hook and is slow. That is not
  a hang.
- A hook passing locally and failing in CI usually means the pinned revisions in
  the config were updated in one place only.
