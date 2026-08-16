---
aep: 2.0.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test]
use-when: "running this repository's Python tests, or narrowing to one of them"
---

# Reference — pytest

**This file is yours.** Installed because pytest configuration was detected.
Read the config block for the markers, the test paths, and any `addopts` — those
options apply to every run whether or not you type them.

## Commands

```sh
pytest                           # everything the config selects
pytest <path>::<test_name>       # exactly one test
pytest -k "<expression>"         # by name
pytest -m "<marker>"             # by marker
pytest -x                        # stop at the first failure
pytest --lf                      # only what failed last run
pytest -q                        # quiet; -vv for the opposite
```

| Purpose | Command |
| --- | --- |
| test | `pytest` |
| single test | `pytest <path>::<name>` |

## Verification

Read the collected count. `pytest -k` matching nothing prints
**no tests ran** and exits **5**, not 1 — a result that is easy to read as
success in a script that only checks for a non-zero exit
(`[[rules/evidence]]`).

## Failure handling

- An import error at collection is usually the working directory or an editable
  install, not a missing package.
- A test passing alone and failing in the suite is shared state — often a
  session-scoped fixture. `-p no:randomly` and running the pair together
  isolate it.
- `addopts` in the config can add coverage gates or `-x` invisibly. A local run
  that behaves differently from the documented one usually starts there.
- Never mark a failing test `xfail` or `skip` to reach green. That is a change
  to what this repository claims works, and it is raised, not taken.
