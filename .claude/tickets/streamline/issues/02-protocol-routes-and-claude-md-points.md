# refactor(knowledge): the protocol becomes the router, and the entrypoint becomes a pointer

Status: open
Blocked by: 01
Part of: streamline

## Problem

The always-on entrypoint is nine sections long and most of them do not apply to most turns. Pull-request description conventions load when the request is a question. Meanwhile the file describing the workflow's machinery is named after the framework rather than after what it does, and it routes nothing — every skill rediscovers which guides it needs.

## Outcome

The entrypoint states what this repository is and where the machinery lives, and stops there. The protocol file is renamed for its job and becomes the router: it carries the cache check, the two drift reads, the verification report, and the table saying which guides each workflow stage reads. It is reached by pointer, so a turn that answers a question does not pay for it.

A reader without the plugin follows the same pointer and reads the same file, because every guide is committed.

## Acceptance

- The entrypoint names no machinery that requires the plugin to exist, and every file it points at is committed and readable without it.
- The protocol file states which guides each workflow stage reads, in one place.
- Nothing that must fire unconditionally is left only in the protocol file, where it would fire only when a skill happens to run.
- Following the entrypoint's pointers as a reader with no plugin installed reaches every rule that reader is expected to obey.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
