---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, test, prototype]
use-when: "building, testing, or running this repository through its Makefile"
---

# Reference — Make

**This file is yours.** Installed because a `Makefile` was detected. A Makefile
is usually the most honest statement of how a repository is actually built —
**read it and fill the table below from its real targets.**

```sh
make -n <target>                 # dry run: print what would happen, change nothing
make <target>
make -j<n> <target>              # parallel, only where the Makefile declares deps correctly
```

| Purpose | Target |
| --- | --- |
| build | `make build` |
| test | `make test` |
| lint | `make lint` |
| clean | `make clean` |

**Do not invent a target.** `make` fails loudly on an unknown one, but a target
that exists and does something other than what this table claims fails quietly.

## Verification

`make -n` before running anything destructive. A `clean` target that removes more
than build output is common and is worth reading before it is run.

## Failure handling

- A target that "does nothing" is usually up-to-date, not broken. Check
  timestamps before assuming a defect.
- Parallel builds expose missing prerequisites. A failure under `-j` that passes
  serially is a finding about the Makefile, not a reason to stop using `-j`.
