---
aep: 2.0.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test]
use-when: "running a target across this monorepo's projects, or finding what a change affects"
---

# Reference — Nx

**This file is yours.** Installed because an `nx.json` was detected. Read it and
each project's config for the real target names — they vary per project.

## Commands

```sh
npx nx run <project>:<target>
npx nx run-many -t build         # every project with that target
npx nx affected -t test          # only projects a change reaches
npx nx graph                     # opens a browser — interactive only
npx nx show projects
npx nx reset                     # clears the local cache and daemon
```

| Purpose | Command |
| --- | --- |
| build | `npx nx run-many -t build` |
| test | `npx nx run-many -t test` |
| affected only | `npx nx affected -t test` |

## Affected and cached

`affected` compares against a base ref, so **what it selects depends on the git
state**, not only on the working tree. On a stale branch it can select nothing.

A target reported from cache did not execute. When the result is being used as
evidence, say so — or re-run without the cache (`[[rules/evidence]]`).

## Failure handling

- A target missing on one project and present on another is normal in Nx. Check
  the project's own config before assuming a misconfiguration.
- The daemon holds stale state after a config change; `nx reset` is the
  diagnosis, and needing it routinely is a finding.
- Never run a `deploy` or `publish` target.
