---
use-when: "linting or formatting this repository with Biome"
---

# Reference — Biome

**This file is yours.** Installed because a Biome configuration was detected.
Correct the commands from `package.json` and CI.

## Commands

```sh
npx biome check .                # lint + format + import order, reporting only
npx biome ci .                   # what CI runs — never writes
npx biome check --write .        # applies safe fixes (Biome 2.x)
npx biome format --write <path>
npx biome lint <path>
```

| Purpose | Command |
| --- | --- |
| lint + format check | `npx biome ci .` |
| fix | `npx biome check --write .` |

**Check the installed major version.** Biome 1.x spells the write flags
`--apply` and `--apply-unsafe`; 2.x spells them `--write` and `--unsafe`. A
command from the wrong major fails in a way that reads like a missing feature.

## Failure handling

- `--unsafe` fixes change behaviour, not just shape. Never apply them without
  reading the diff, and never as part of an unrelated change.
- Biome running beside ESLint or Prettier means two tools own formatting. That
  is a finding about the setup (`[[policies/engineering]]`), not something to settle
  per file.
- A rule fired by `check` but not by the editor usually means the editor is
  using a different Biome binary than the repository pins.
