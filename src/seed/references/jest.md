---
use-when: "running this repository's Jest suite, or one test from it"
---

# Reference — Jest

**This file is yours.** Installed because a Jest configuration was detected.
Correct the invocations from `package.json` and CI.

## Commands

```sh
npx jest                         # single pass
npx jest <pattern>               # files matching a path pattern
npx jest -t "<name>"             # one test by name
npx jest --ci                    # what CI runs: no snapshot writing
npx jest --runInBand             # serial — for diagnosing cross-test state
npx jest --coverage
```

| Purpose | Command |
| --- | --- |
| test | `npx jest --ci` |
| single test file | `npx jest <path>` |
| single test | `npx jest -t "<name>"` |

## Snapshots

`--ci` fails on a missing snapshot instead of writing one, which is why CI uses
it. **`-u` rewrites snapshots to match current behaviour** — that turns a
failing assertion into a passing one without anyone deciding the new output is
correct. Read the diff first, and never run it to clear an unexplained failure.

## Failure handling

- A test passing alone and failing in the suite is shared state. `--runInBand`
  tells you which; it is not the fix.
- `Cannot find module` after a dependency change usually means the transform or
  `moduleNameMapper` config, not a missing install.
- Open handles keeping the process alive: `--detectOpenHandles`. A suite that
  needs `--forceExit` is leaking something, and that is a finding.
