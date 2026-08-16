---
aep: 2.0.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, test, prototype]
use-when: "building or running this repository's containers, or bringing up its local stack"
---

# Reference — Docker

**This file is yours.** Installed because a Dockerfile or Compose file was
detected. Replace the placeholders with this repository's real service names and
targets.

## Commands

```sh
docker compose up -d             # background; the usual local stack
docker compose ps                # what is actually running
docker compose logs -f <service>
docker compose exec <service> <cmd>
docker compose down              # add -v to drop volumes — destroys local data
docker build -t <tag> .
```

## This repository's services

Fill in from the Compose file, and delete the row if there is none:

| Service | Purpose | Port |
| --- | --- | --- |
| | | |

## Verification

After bringing the stack up, **check that it is actually healthy** rather than
assuming: `docker compose ps` shows state, and a service that exits immediately
looks identical to one that never started if you only read the `up` output.

## Failure handling

- A port already in use is usually another stack still running — check before
  changing the port, which hides the conflict rather than resolving it.
- `down -v` destroys volumes and therefore local data. Never run it unasked.
- Never push an image, and never log in to a registry.
