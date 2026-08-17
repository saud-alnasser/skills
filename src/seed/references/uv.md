---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, test, prototype]
use-when: "installing dependencies or running commands in this Python project's environment"
---

# Reference — uv

**This file is yours.** Installed because a `uv.lock` was detected. Fill the
table from `pyproject.toml` and CI.

## Commands

```sh
uv sync --frozen                 # what CI runs; fails rather than updating the lock
uv sync --all-extras             # include optional dependency groups
uv run <command>                 # runs inside the project environment
uv run pytest
uv lock --check                  # is the lock current for pyproject.toml
uv add <pkg>                     # a decision, not a mechanical step
uv python pin <version>
```

| Purpose | Command |
| --- | --- |
| install | `uv sync --frozen` |
| test | `uv run pytest` |
| lint | `uv run ruff check .` |
| types | `uv run mypy .` |

**Prefer `uv run` to activating the environment.** It resolves the project
environment explicitly, so a command cannot silently execute against the system
Python — which is the failure that produces "it works locally" most often here.

## Failure handling

- `--frozen` failing means `uv.lock` and `pyproject.toml` disagree. That is a
  finding, not a flag to drop.
- A package that imports in one shell and not another is almost always the wrong
  interpreter. `uv run python -c "import sys; print(sys.executable)"` settles it.
- Adding a dependency is an architectural decision and goes to the human with
  its alternatives (`[[policies/engineering]]`).
- **Never publish.** `uv publish` reaches an index.
