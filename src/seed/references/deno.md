---
aep: 2.1.1
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test, prototype]
use-when: "running, testing, or checking this repository with Deno"
---

# Reference — Deno

**This file is yours.** Installed because a Deno configuration or lockfile was
detected. Fill the table from the `tasks` block in `deno.json`.

## Commands

```sh
deno task                        # lists the tasks this repository defines
deno task <name>
deno test                        # add only the permissions the tests need
deno check <entry>               # type-check without running
deno fmt --check                 # reporting; `deno fmt` rewrites
deno lint
deno install --frozen            # honours deno.lock exactly
```

| Purpose | Command |
| --- | --- |
| build | `deno task build` |
| test | `deno task test` |
| lint | `deno lint` |
| types | `deno check <entry>` |

## Permissions

Deno denies by default, and `-A` turns that off wholesale. **Prefer the narrow
flags** — `--allow-read=<path>`, `--allow-net=<host>` — and treat a test that
only passes under `-A` as a question about what it is actually reaching for.

## Failure handling

- A `--frozen` install failing means the lockfile and the imports disagree. That
  is a finding, not a flag to drop.
- Node compatibility runs through `npm:` and `node:` specifiers and is close but
  not total. A missing API is worth confirming against what this repository
  deploys on.
- Never publish. `deno publish` reaches a registry.
