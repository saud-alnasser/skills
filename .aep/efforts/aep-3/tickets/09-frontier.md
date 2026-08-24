---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: open
part-of: aep-3
blocked-by: [01]
---

# feat(scripts): the frontier is computed rather than judged

## Outcome

`scripts/frontier.mjs` ships with the payload. Given an effort it reads the tickets, resolves `blocked-by`, and prints the ready set, the blocked set with what gates each, and anything parked. The orchestrator quotes its output instead of holding the graph.

## Acceptance Criteria

- [ ] Requirement 21 / criterion 13: given an effort whose only open tickets are blocked, the output names what blocks them, so the runner can build the blocking work rather than reporting an empty frontier.
- [ ] The three output lines take the documented shape, and the exit codes distinguish work remaining, nothing unresolved, and an unreadable effort.
- [ ] It joins `PAYLOAD_SCRIPTS` and lands in an installed tree.
- [ ] It is dependency-free ESM run by a bare Node runtime, matching every other script here.
- [ ] The suite asserts the output shape against a fixture effort, and the guard is broken deliberately once.

## Relevant areas

`src/scripts/frontier.mjs` (new), `src/scripts/payload.mjs`, and `src/scripts/verify.mjs`.

## Constraints

It computes and prints. It never writes, never claims a ticket, and never decides that a ticket is parked — it reports what the ticket already says.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
