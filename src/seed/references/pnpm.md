---
use-when: "installing dependencies, running scripts, or working across workspace packages"
---

# Reference — pnpm

**This file is yours.** Installed because `pnpm-lock.yaml` was detected. Replace
the placeholders below with what this repository actually runs — read
`package.json` scripts and the CI workflow rather than assuming the defaults.

## Commands

```sh
pnpm install --frozen-lockfile   # what CI runs; fails rather than updating the lockfile
pnpm run <script>                # see package.json for what exists
pnpm --filter <package> run <script>   # one workspace package
pnpm -r run <script>             # every package, in dependency order
```

## This repository's scripts

Fill these in from `package.json`, and delete any that do not exist:

| Purpose | Command |
| --- | --- |
| build | `pnpm run build` |
| test | `pnpm run test` |
| single test file | `pnpm run test -- <path>` |
| lint | `pnpm run lint` |
| types | `pnpm run typecheck` |

**Do not invent a script.** A command named here that `package.json` does not
define will be trusted and will fail (`[[policies/engineering]]`).

## Adding a dependency

```sh
pnpm add <pkg>                   # runtime
pnpm add -D <pkg>                # development
pnpm add -w <pkg>                # workspace root
```

Adding a dependency is an architectural decision, not a mechanical one — it is
put to the human with its alternatives (`[[policies/engineering]]`).

## Failure handling

- `--frozen-lockfile` failing means the lockfile and `package.json` disagree.
  That is a finding, not something to fix by dropping the flag.
- A workspace script that exists in one package and not another is a gap in the
  repository, worth reporting.
- Never publish a package.
