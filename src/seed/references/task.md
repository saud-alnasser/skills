---
aep: 2.1.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test, prototype]
use-when: "running this repository's commands through its Taskfile"
---

# Reference — Task

**This file is yours.** Installed because a `Taskfile` was detected. Read it and
fill the table from its real tasks.

## Commands

```sh
task --list                      # tasks carrying a description
task --list-all                  # including internal ones
task --summary <name>            # what the task does, without running it
task <name>
task --dry <name>                # print the commands, run nothing
task --force <name>              # ignore up-to-date checks
```

| Purpose | Task |
| --- | --- |
| build | `task build` |
| test | `task test` |
| lint | `task lint` |

## Up-to-date checks

A task declaring `sources` and `generates` is skipped when its inputs have not
changed, and the run reports it as up to date. **A green run may have executed
nothing** — when the result is the evidence, `--force` it
(`[[rules/evidence]]`).

## Failure handling

- A task with `deps` runs them in parallel, so a failure may come from a
  dependency rather than the named task. `--summary` shows the shape.
- Tasks can shell out to anything. Read one before running it where the name
  suggests it deploys or publishes.
- Do not invent a task name; a task that exists and does something other than
  what this table claims fails quietly.
