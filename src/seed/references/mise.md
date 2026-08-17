---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, test, prototype]
use-when: "a tool version here does not match what this repository pins, or its tasks need running"
---

# Reference — mise

**This file is yours.** Installed because a tool-version pin was detected —
`mise.toml` or `.tool-versions`, the latter of which `asdf` also reads. Record
which of the two this repository actually uses.

## Commands

```sh
mise install                     # every pinned tool, at the pinned version
mise current                     # what is active right now
mise exec -- <command>           # run one command with the pinned versions
mise run <task>                  # tasks defined in mise.toml
mise doctor                      # why activation is not working
```

| Purpose | Command |
| --- | --- |
| install the pinned tools | `mise install` |
| run with the pins | `mise exec -- <command>` |

## The versions are the point

These pins are the statement of what this repository is built and tested
against. **A version mismatch is the first thing to check** when something fails
locally and not in CI — `mise current` against the pin answers it in one line,
and it is far more often the cause than the code.

`mise exec --` is the reliable form in an automated run: shell activation
depends on a hook that may not have loaded.

## Failure handling

- A tool resolving to the system version means mise is installed but not
  activated for that shell. `mise doctor` says so.
- Changing a pin changes what everyone builds with. That is a decision, not a
  step (`[[policies/engineering]]`).
- Some backends run install scripts from upstream. Adding a new tool to the pins
  is worth raising rather than doing quietly.
