---
use-when: "running a task across this monorepo's packages, or explaining why one was skipped"
---

# Reference — Turborepo

**This file is yours.** Installed because a `turbo.json` was detected. Read it
for the task graph — which tasks depend on which, and what each one caches.

## Commands

```sh
turbo run build                  # every package, in dependency order
turbo run test --filter=<pkg>    # one package
turbo run build --filter=<pkg>...    # a package and everything it depends on
turbo run build --force          # ignore the cache
turbo run build --dry=json       # what would run, and why
```

| Purpose | Command |
| --- | --- |
| build | `turbo run build` |
| test | `turbo run test` |
| one package | `turbo run <task> --filter=<pkg>` |

## The cache is the thing to understand

A task reported as **cached** did not run. That is the point, and it is also the
trap: a passing `turbo run test` may have executed nothing at all.

**When a result matters as evidence, say whether it was cached** — and re-run
with `--force` if it was (`[[policies/engineering]]`). A task whose `inputs` are
declared too narrowly caches across a change that should have invalidated it,
which is a finding about `turbo.json`, not about the run.

## Failure handling

- A task that "does not exist" is usually undeclared in `turbo.json` for that
  package, even though the script is in its `package.json`.
- Remote caching, where enabled, shares results between machines. A local result
  can come from CI. `--dry=json` shows the source.
- Never run a `publish`, `release`, or `deploy` task.
