---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, test]
use-when: "installing this Python project's dependencies from its requirements files"
---

# Reference — pip

**This file is yours.** Installed because a requirements file was detected.
Record which files exist and what each one is for — a repository usually has
more than one, and installing the wrong one produces a subtly different
environment.

## Commands

```sh
python -m venv .venv                            # then activate, or call .venv/bin/python directly
python -m pip install -r requirements.txt
python -m pip install -r requirements-dev.txt   # if this repository has one
python -m pip install -e .                      # editable, for a package repository
python -m pip check                             # reports conflicting installed versions
python -m pip freeze                            # what is actually installed
```

| Purpose | Command |
| --- | --- |
| install | `python -m pip install -r requirements.txt` |
| test | `pytest` |

**Always `python -m pip`, never bare `pip`.** The bare command can belong to a
different interpreter than the one that will run the code, and the resulting
`ModuleNotFoundError` looks like a failed install rather than the wrong
environment.

## Failure handling

- A `requirements.txt` without pinned versions installs something different
  every day. A failure that appeared with no code change usually starts there.
- `pip freeze > requirements.txt` captures the whole environment, including
  transitive packages and local tooling. It is not a way to add one dependency.
- Adding a dependency is an architectural decision and goes to the human with
  its alternatives (`[[policies/engineering]]`).
- Never install into the system interpreter, and never publish.
