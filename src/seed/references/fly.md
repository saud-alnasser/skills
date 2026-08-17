---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, review]
use-when: "reading this application's Fly.io configuration, or inspecting what is running there"
---

# Reference — Fly.io

**This file is yours.** Installed because a `fly.toml` was detected. Record the
app name, the regions, and which processes and volumes it declares.

## Commands

```sh
fly config show                  # the resolved configuration
fly config validate
fly status                       # what is actually running
fly logs                         # live; long-running
fly releases                     # deployment history
```

| Purpose | Command |
| --- | --- |
| validate config | `fly config validate` |
| what is running | `fly status` |

## Never run

`fly deploy`, `fly scale`, `fly secrets set`, `fly machine destroy`, and
`fly volumes destroy` all change a running system, and the last two are
irreversible. Deployment and scaling are the human's
(`[[rules/version-control]]`).

`fly ssh console` and `fly proxy` open a session into production. Neither is
opened unasked.

## Failure handling

- A deploy that "did nothing" is usually a release that failed its health check
  and rolled back. `fly releases` and `fly logs` say which.
- Configuration in `fly.toml` only takes effect on deploy, so a local edit
  changes nothing about what is running — say so rather than implying it did.
- Volumes are per-region and per-machine. A service that loses data on restart
  is usually writing outside its mount.
