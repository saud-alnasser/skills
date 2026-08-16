---
aep: 2.1.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test, review]
use-when: "type-checking this repository, or reading what its compiler is actually configured to enforce"
---

# Reference — TypeScript

**This file is yours.** Installed because a `tsconfig.json` was detected. Read
that file before filling anything in below — it is the statement of what this
repository actually enforces.

## Commands

```sh
npx tsc --noEmit                 # type-check only; the usual CI gate
npx tsc -b                       # project references: builds in dependency order
npx tsc -b --force               # ignore stale build info
npx tsc --noEmit -p <tsconfig>   # one project in a monorepo
```

| Purpose | Command |
| --- | --- |
| types | `npx tsc --noEmit` |

## What the config decides

Record the answers here rather than assuming the defaults:

- **`strict`** — off means `null` is not tracked, and a change that looks safe
  under strict mode is not.
- **`moduleResolution`** — `bundler` and `node16` disagree about import
  extensions. Code that resolves in the editor can still fail in the build.
- **project references** — a monorepo with them type-checks per project.
  `tsc --noEmit` at the root can pass while a package is broken.

## Verification

**Type-checking is not building.** `tsc --noEmit` passing says nothing about the
bundler, which usually applies its own transform and its own resolution. Run
both before claiming a change compiles.

## Failure handling

- An error in `node_modules` usually means two versions of a type package, not a
  defect in the dependency.
- `// @ts-expect-error` and `any` silence the checker rather than answer it. Each
  one added is a finding worth raising (`[[rules/engineering]]`).
- A stale `tsconfig.tsbuildinfo` produces errors that vanish under `-b --force`.
  That is the diagnosis, not the fix — a build that needs `--force` is a finding.
