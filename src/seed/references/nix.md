---
aep: 2.1.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test, prototype]
use-when: "entering this repository's development environment, or building it through Nix"
---

# Reference — Nix

**This file is yours.** Installed because a Nix expression was detected. Record
whether this repository uses flakes or the classic files, and what the
development shell actually provides.

## Commands

```sh
nix develop                      # the flake's dev shell; interactive
nix develop -c <command>         # run one command inside it, non-interactively
nix-shell                        # classic shell.nix
nix build .#<output>
nix flake check                  # evaluates and runs the flake's checks
nix flake metadata
```

| Purpose | Command |
| --- | --- |
| dev shell | `nix develop` |
| run a command in it | `nix develop -c <command>` |
| build | `nix build` |

**`nix develop -c` is the form to use in an automated run.** A bare
`nix develop` opens an interactive shell and never returns.

## Why it is here

The development shell is the statement of what this repository needs installed.
A tool that is missing outside it and present inside it is not a broken machine —
it is the environment working. Reach for the shell before installing anything
globally.

## Failure handling

- The first evaluation can download a great deal and take a long time. That is
  not a hang.
- A flake input that has moved changes the environment without any local edit;
  `flake.lock` is what pins it, and updating it is a decision, not a step.
- Never run garbage collection or delete store paths — that affects the whole
  machine, not this repository.
