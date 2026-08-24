---
use-when: "linting or formatting this repository's Python"
---

# Reference — Ruff

**This file is yours.** Installed because Ruff configuration was detected. Read
the selected rule set — Ruff's default selection is small, and what this
repository enables is the real statement of what it enforces.

## Commands

```sh
ruff check .                     # lint, reporting only
ruff check . --fix               # applies safe fixes; rewrites files
ruff check . --diff              # what --fix would do, without doing it
ruff format --check .            # formatting, reporting only
ruff format .                    # rewrites
ruff check <path> --statistics   # which rules fire, and how often
```

| Purpose | Command |
| --- | --- |
| lint | `ruff check .` |
| fix | `ruff check . --fix` |
| format check | `ruff format --check .` |

## Failure handling

- `--unsafe-fixes` changes behaviour, not just shape. Never apply them without
  reading the diff.
- **Never add `# noqa` or widen `ignore` to make a run green.** That edits what
  this repository enforces, and it is the human's call
  (`[[policies/engineering]]`).
- `ruff format` and a separately configured Black or line-length setting will
  fight. Two formatters is a finding about the setup, not a per-file problem.
- A rule firing on files you did not touch means the rule set changed, or those
  files were never clean. Say which.
