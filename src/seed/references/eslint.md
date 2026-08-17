---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, review]
use-when: "linting this repository, or deciding what to do about a rule that fires"
---

# Reference — ESLint

**This file is yours.** Installed because an ESLint configuration was detected.
Replace the commands below with the ones `package.json` and CI actually run.

## Commands

```sh
npx eslint .                     # everything the config covers
npx eslint <path>                # one file or directory
npx eslint . --max-warnings 0    # what CI usually runs — a warning fails the build
npx eslint . --fix               # rewrites files; read the diff
npx eslint --print-config <file> # which rules actually apply to that file
```

| Purpose | Command |
| --- | --- |
| lint | `npx eslint .` |
| fix | `npx eslint . --fix` |

## Which config format

Flat config (`eslint.config.js`) and legacy (`.eslintrc.*`) select rules
differently and do not merge. **Check which one this repository has** before
reasoning about why a rule does or does not fire — `--print-config` answers it
directly rather than by inference.

## Failure handling

- **`--fix` is not free.** It rewrites source, and on a large repository it
  produces a diff nobody reviewed. Run it scoped to what you changed.
- **Never silence a rule to make a run green.** An inline `eslint-disable`, a
  widened `ignores`, or a rule downgraded in the config is a change to what this
  repository enforces — that is the human's call, and it is raised, not taken
  (`[[policies/engineering]]`).
- A rule firing on untouched files means the config changed, or the files were
  never clean. Say which; do not fix both silently.
- Formatting rules that fight Prettier mean the two are configured
  independently. That is a finding about the setup, not something to work around
  file by file.
