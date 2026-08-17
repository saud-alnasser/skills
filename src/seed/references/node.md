---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, test, prototype]
use-when: "running this repository on Node — its pinned version, its scripts, or its built-in test runner"
---

# Reference — Node

**This file is yours.** Installed because a Node version pin was detected. The
pinned version is the one fact here that is already true; everything below is a
draft.

## The pinned version

```sh
cat .nvmrc                       # or .node-version — whichever this repository pins with
node --version                   # what is actually running
```

**Check these agree before diagnosing anything.** A failure that only reproduces
locally is a version mismatch far more often than it is a defect, and the two
look identical in a stack trace.

## Commands

```sh
node --run <script>              # runs a package.json script without a package manager
node --test                      # the built-in runner (Node 18+); see below first
node --test --test-name-pattern "<name>"
node --env-file=.env <entry>     # Node 20+; no dotenv dependency needed
node --watch <entry>
```

## Which test runner this repository actually uses

Fill this in, and delete the rest:

| Purpose | Command |
| --- | --- |
| test | `node --test` |
| single test file | `node --test <path>` |

**`node --test` is not the suite unless this repository says it is.** A
`package.json` whose `test` script runs Vitest or Jest means `node --test` finds
a different set of files, passes, and tells you nothing about CI.

## Failure handling

- `ERR_MODULE_NOT_FOUND` on a relative import is usually a missing file
  extension under ESM, not a missing dependency.
- An API that exists in the local Node and not in the pinned one fails only in
  CI. Check the pin before reaching for a polyfill.
- Never publish a package, and never run a script whose name suggests it does.
