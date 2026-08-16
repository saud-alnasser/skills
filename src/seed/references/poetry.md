---
aep: 2.1.1
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test, prototype]
use-when: "installing dependencies or running commands in this Poetry project's environment"
---

# Reference — Poetry

**This file is yours.** Installed because a `poetry.lock` was detected. Fill the
table from `pyproject.toml` and CI.

## Commands

```sh
poetry install --sync            # matches the environment to the lock exactly
poetry check --lock              # is the lock current for pyproject.toml
poetry run <command>             # runs inside the project environment
poetry run pytest
poetry env info --path           # which interpreter is actually in use
poetry add <pkg>                 # a decision, not a mechanical step
```

| Purpose | Command |
| --- | --- |
| install | `poetry install` |
| test | `poetry run pytest` |
| lint | `poetry run ruff check .` |
| types | `poetry run mypy .` |

**Prefer `poetry run` to activating a shell.** An activated shell that has gone
stale runs the system Python and produces failures that look like missing
packages.

## Failure handling

- `poetry check --lock` failing means the lock and the manifest disagree.
  Regenerating the lock to clear it also moves versions nobody asked to move —
  that is a change, not a fix.
- Resolution that hangs is usually an unbounded version constraint, not a
  network problem.
- Adding a dependency is an architectural decision and goes to the human with
  its alternatives (`[[rules/engineering]]`).
- **Never `poetry publish`.**
