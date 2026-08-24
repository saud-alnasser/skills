---
status: resolved
blocked-by: [09]
---

# feat(implement): one invocation carries an effort to a finished stack

## Outcome

`/implement` becomes a loop whose body is today’s wave. It schedules from the computed frontier, dispatches a child per ticket, integrates each on return, reviews, commits, and repeats until nothing unresolved remains. Three conditions stop it; a ticket whose review rejects twice is parked and the run continues.

## Acceptance Criteria

- [x] Criterion 12: an effort with three dependency layers completes in one invocation, with every layer dispatched and no hand-back between them.
- [x] Criterion 13: an effort whose only open tickets are blocked has the blocking work built, and an empty frontier is reported only when nothing unresolved remains.
- [x] Criterion 14: two children in one wave touching the same file produce a conflict at the second one’s integration, named against that ticket.
- [x] Criterion 15: the effort branch has one commit per ticket plus the `docs` commits, and a ticket producing no diff lands an empty commit carrying what was checked.
- [x] Criterion 21: a child finding the plan invalid stops the run and names the evidence; a child touching a schema stops before it lands; a review that rejected once and passed after the fix does not stop the run.
- [x] A ticket whose review rejects twice is parked, its dependents are left alone, and the run continues.
- [x] The suite asserts the trip-wire set is exactly three and that the review cap is stated.

## Relevant areas

`src/skills/implement.md`, `src/skills/implement/dispatch.md`, `src/policies/execution.md`, `src/skills/commit/conflicts.md`.

## Constraints

A task is never split across sub-agents. The orchestrator is the only integrator. Children in a wave branch from the effort branch’s current tip, and the next wave branches from the new tip.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

### The trip-wire set is counted, not matched

A regex naming the three conditions passes with a fourth sitting beside them, which is exactly how a fixed set grows. Both guards, the runner's table and the policy's list, count rows and report what they found. Fire-checked by adding a fourth to each; both named it.

### What is stated here and produced elsewhere

The loop schedules, integrates, reviews, lands, and repeats. Two things it refers to do not exist yet: converge, which ticket 12 builds and which is what actually ends a run, and the run log, which ticket 11 builds and which is where the ledger and the parked tickets become durable. Until those land the loop is complete as written and its exit condition is stated rather than implemented.

### Vocabulary

The runner says ticket throughout, following the spec's requirements 20 to 28. The protocol's primitive is still a task; a ticket is what one is called where it lives. `policies/execution` keeps task, because it governs sub-agent dispatch generally rather than this loop.
