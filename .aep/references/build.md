---
aep: 2.0.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test, review]
use-when: "checking, regenerating, or installing this repository's own output"
---

# Reference — building and checking AEP

There is **no package manager, no manifest, and no dependency**. Every command is
a bare Node invocation from the repository root.

## Prerequisites

Node with ESM support, and `git` on the path. Nothing else.

## Commands

```sh
node src/scripts/verify.mjs                    # the whole suite — run before every commit
node src/scripts/verify.mjs --verbose          # every passing assertion, not just failures
node src/scripts/verify.mjs --section links    # one section
node src/scripts/adapters.mjs                  # regenerate src/adapters/claude/
node src/scripts/install.mjs --into <dir>      # install a distribution into a repository
node .aep/scripts/index.mjs                    # regenerate .aep/index.md
node .aep/scripts/validate.mjs                 # check an installed tree
```

## Expected output

`verify.mjs` prints one line per section, a `N passed, M failed` summary, and — on
success — the list of things it deliberately does **not** check mechanically.
Exit status is 0 only when `M` is 0.

The last section, `the guard fires`, seeds a failure and discards it. That line
proves the harness can still tell a failure from a pass; **a run that does not
print it should not be trusted**, however green the rest looks.

## Verification

After changing anything under `src/`, the sequence is:

```sh
node src/scripts/adapters.mjs && node src/scripts/verify.mjs
```

Regenerating the adapter first, because the suite asserts the committed adapter
is current and will otherwise fail on a file the command you are about to run
would have fixed.

To re-dogfood this repository's own `.aep/` after a payload change:

```sh
node src/scripts/install.mjs --into . --update && node .aep/scripts/index.mjs
```

Repository-owned files — this one, `[[contexts/repository]]`,
`[[rules/authoring]]`, the seeded references — survive that; protocol-owned ones
are replaced.

## Failure handling

- A `links` failure names the file and the exact unresolved target. Search for
  where the concept moved; **never create a file to satisfy a link**.
- An `adapter … is current` failure means `adapters.mjs` was not re-run.
- An `install fixture` failure quotes the fixture's own `validate.mjs` output,
  which is where the real diagnosis is.
- A section that reports `ABORT` threw before its assertions ran — the remaining
  checks in that section did **not** execute, so a low failure count there means
  nothing.

## Never run

Nothing here publishes. `[[rules/version-control]]` governs what is never run
against the remote.
