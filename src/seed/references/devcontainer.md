---
aep: 2.1.1
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test, prototype]
use-when: "reproducing this repository's development environment, or explaining a difference between it and the host"
---

# Reference — Dev Containers

**This file is yours.** Installed because a dev container configuration was
detected. Read it for the base image, the features, and the lifecycle commands —
together they are the statement of what this repository needs installed.

## Commands

```sh
devcontainer up --workspace-folder .              # build and start
devcontainer exec --workspace-folder . <command>  # run one command inside
devcontainer build --workspace-folder .
```

| Purpose | Command |
| --- | --- |
| start | `devcontainer up --workspace-folder .` |
| run a command inside | `devcontainer exec --workspace-folder . <cmd>` |

## Inside and outside

**A command run on the host is not the same command run in the container**, and
the difference — tool versions, available services, filesystem case sensitivity
— is exactly what the container exists to remove. When reporting that something
works, say which side it was run on (`[[rules/evidence]]`).

`postCreateCommand` and `postStartCommand` run automatically. A dependency that
is present after a rebuild and absent otherwise usually comes from one of them.

## Failure handling

- A rebuild that appears to change nothing is a cached image layer; the config
  offers a rebuild-without-cache, and needing it routinely is a finding.
- Bind-mounted files keep host permissions, which is the usual cause of a
  permission error that only appears inside the container.
- A port that is not reachable from the host is usually not forwarded in the
  config, rather than a server that failed to start.
