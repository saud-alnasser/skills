---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, review]
use-when: "checking or applying this repository's formatting"
---

# Reference — Prettier

**This file is yours.** Installed because a Prettier configuration was detected.
Correct the commands from `package.json` and CI.

## Commands

```sh
npx prettier --check .           # what CI runs; reports, changes nothing
npx prettier --write <path>      # rewrites — scope it to what you touched
npx prettier --check <path>
```

| Purpose | Command |
| --- | --- |
| format check | `npx prettier --check .` |
| format | `npx prettier --write .` |

## Scope before running

**`--write .` across a repository that was not already formatted produces a diff
nobody asked for**, and it buries the change under it. Format what you changed.
If the repository is genuinely unformatted, that is a separate change with its
own commit, and it is the human's to schedule.

Check `.prettierignore` — a path listed there is deliberate, and formatting it
anyway undoes a decision.

## Failure handling

- A `--check` failure names files, not reasons. Run `--write` on one of them and
  read the diff to see what the config actually wants.
- Prettier and ESLint disagreeing about formatting means both are enforcing it.
  Report it; do not resolve it by hand-formatting to satisfy whichever ran last.
- A formatting-only diff mixed into a behavioural change hides the change. Keep
  them apart (`[[rules/version-control]]`).
