---
owner: repository
status: accepted
load-when: a stage's load list, or the always-on tier's membership, is about to change
sources: [.claude/protocol.md, skills/, .claude/rules/]
supersedes: []
superseded-by: []
---

# Stage loads are exact, and the always-on core is selected by the drift test

The stage table was permissive — a row was what a stage *may* read — so every
load was a judgement call, and mis-loads were an observed cause of settled
questions being re-asked. Decided: each stage's list is mandatory, exact, and
cut small enough to always load whole; judged selection is removed from the
corpus. The always-on tier is selected by one test — would this norm's absence
on a turn cause behavioral drift — and by it gains the entry table, the no-ask
rule, the fixed-owner rule, and the verification core, in norm form. ADR 0054's
two-homes rule stands unchanged; what changes is the semantics of the set, from
permissive to exact.

## Consequences

The affordability that justified may-read is recovered by compression rather
than by judgement: a row that cannot be afforded whole is a row that is too
big, and the fix is cutting the row, never restoring selection.
