---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, test, prototype]
use-when: "running this repository's commands through its justfile"
---

# Reference — just

**This file is yours.** Installed because a `justfile` was detected. That file
is usually the most honest statement of how this repository is actually
operated — **read it and fill the table from its real recipes.**

## Commands

```sh
just --list                      # every recipe, with its documentation comment
just --show <recipe>             # the recipe's body, without running it
just <recipe> <args...>
just --dry-run <recipe>          # print what would run
```

| Purpose | Recipe |
| --- | --- |
| build | `just build` |
| test | `just test` |
| lint | `just lint` |

**Do not invent a recipe.** `just` fails loudly on an unknown name, but a recipe
that exists and does something other than what this table claims fails quietly
(`[[policies/engineering]]`).

## Failure handling

- A recipe that depends on others runs them first, and a failure can come from a
  dependency rather than the recipe you named. `--show` makes that visible.
- Recipes can shell out to anything, including deploys and publishes.
  **Read a recipe before running it** where the name suggests it leaves this
  machine.
- Variables can come from the environment or a `.env` file, so the same recipe
  can behave differently in two shells.
