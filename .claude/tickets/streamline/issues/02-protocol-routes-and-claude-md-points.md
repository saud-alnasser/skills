# refactor(configure): the protocol becomes the router, and the entrypoint becomes a pointer

Status: open
Blocked by: —
Part of: streamline

## Problem

The entrypoint a configured repository is given is nine sections long and most of them do not apply to most turns. Pull-request description conventions load when the request is a question. Meanwhile the template for the file describing the workflow's machinery is named after the framework rather than after what it does, and it routes nothing — every skill rediscovers which guides it needs.

## Outcome

**Shipped behaviour changes; this repository's own configuration does not.**

A repository configured after this ticket is given an entrypoint that states what the repository is and where the machinery lives, and stops there. The protocol template is renamed for its job and generates the router: it carries the cache check, the two drift reads, the verification report, and the table saying which guides each workflow stage reads. It is reached by pointer, so a turn that answers a question does not pay for it.

A reader without the plugin follows the same pointer and reads the same file, because every generated guide is committed.

## Acceptance

- A repository configured from these templates has an entrypoint that names no machinery requiring the plugin, and every file it points at is generated and committed.
- The generated protocol file states which guides each workflow stage reads, in one place.
- Nothing that must fire unconditionally is left only in the protocol file, where it would fire only when a skill happens to run.
- The rename is complete: nothing shipped names the old template, and onboarding writes the new one.
- Onboarding still writes both halves or neither, so a generated entrypoint never points at a file that was not written.
- The generated entrypoint stays within its line budget.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

The entrypoint here is not edited by this ticket even though it is generated from the template being changed. Ticket 16 adopts the result through the migration.

This repository's rules already carry part of the shape being shipped, because ticket 01 landed before the effort was re-ordered. That is not drift to correct — see `.claude/decisions/0026-a-fixture-tests-the-migration-and-the-revert-is-dropped.md`. Ship the template against what the template should say, not against what this tree currently has.
