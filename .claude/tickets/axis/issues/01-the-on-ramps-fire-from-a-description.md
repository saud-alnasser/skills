---
title: 'feat(skills): work arriving from outside reaches its stage unasked'
status: resolved
blocked-by: []
part-of: axis
---

## Problem

The entry table routes a request that arrived from outside to the triage stage,
and that stage is withheld from selection. So the one thing the model can do at
that row is hand the human a command to type — the round trip the entry rule
exists to remove.

The survey sits on the same side of the axis for no stated reason. It is
reached by describing a problem — where is the architecture costing us — which
is the test the axis is decided by, and it fails that test in the direction
that keeps it unreachable.

## Outcome

Describing work that arrived from outside reaches the stage that triages it,
and describing an architecture cost reaches the stage that surveys it. Neither
needs a command.

The entry table's outside-arrival row becomes correct without being edited: the
skill moved, so the destination it names is now one the model may select.

Both skills keep their behaviour exactly. Only which side of the axis they sit
on changes, and each gains a description written as a selection condition
rather than as a summary — for a model-invoked skill the description is the
entire basis on which it is chosen.

Because the entry table can now name an unreachable destination and nothing
would notice, the suite gains the check that would have caught this: every
destination the table names is one the model may select.

## Acceptance

- A request describing an issue or pull request that arrived from outside
  reaches the triage stage with no command typed.
- A request describing an architecture cost reaches the survey stage with no
  command typed.
- Every command named as a destination in the entry table is model-invoked, and
  the suite fails when one is not.
- The guard above is confirmed to fail against a deliberate reintroduction
  before it is trusted.
- The triage stage's declared guides appear in the router's stage table, which
  today has no row for it at all.
- Both descriptions state when to use the skill and what not to use it for.
- A Decision records the reversal, cites the accepted spec line it supersedes,
  and states the test that keeps two skills exempt.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
