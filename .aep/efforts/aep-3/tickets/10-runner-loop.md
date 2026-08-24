---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: open
part-of: aep-3
blocked-by: [09]
---

# feat(implement): one invocation carries an effort to a finished stack

## Outcome

`/implement` becomes a loop whose body is today’s wave. It schedules from the computed frontier, dispatches a child per ticket, integrates each on return, reviews, commits, and repeats until nothing unresolved remains. Three conditions stop it; a ticket whose review rejects twice is parked and the run continues.

## Acceptance Criteria

- [ ] Criterion 12: an effort with three dependency layers completes in one invocation, with every layer dispatched and no hand-back between them.
- [ ] Criterion 13: an effort whose only open tickets are blocked has the blocking work built, and an empty frontier is reported only when nothing unresolved remains.
- [ ] Criterion 14: two children in one wave touching the same file produce a conflict at the second one’s integration, named against that ticket.
- [ ] Criterion 15: the effort branch has one commit per ticket plus the `docs` commits, and a ticket producing no diff lands an empty commit carrying what was checked.
- [ ] Criterion 21: a child finding the plan invalid stops the run and names the evidence; a child touching a schema stops before it lands; a review that rejected once and passed after the fix does not stop the run.
- [ ] A ticket whose review rejects twice is parked, its dependents are left alone, and the run continues.
- [ ] The suite asserts the trip-wire set is exactly three and that the review cap is stated.

## Relevant areas

`src/skills/implement.md`, `src/skills/implement/dispatch.md`, `src/policies/execution.md`, `src/skills/commit/conflicts.md`.

## Constraints

A task is never split across sub-agents. The orchestrator is the only integrator. Children in a wave branch from the effort branch’s current tip, and the next wave branches from the new tip.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
