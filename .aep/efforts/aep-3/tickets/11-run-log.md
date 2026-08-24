---
status: resolved
blocked-by: [10]
---

# feat(implement): the pull request becomes the run’s memory

## Outcome

Criteria are ticked in the pull request by the correctness reviewer at the moment each verifies, carrying inline what verified it. A collapsed run log holds the ledger, recorded items, the converge round, and review attempts. Nothing the run needs lives only in its context, so compaction is harmless and a killed session resumes from the pull request.

## Acceptance Criteria

- [x] Criterion 20: a checkbox is ticked by the correctness reviewer, and never by the agent that wrote the code it refers to.
- [x] Criterion 22: opening the pull request partway through a run shows which tickets are done, which criteria of the in-flight ticket are verified, and what verified each.
- [x] Criterion 23: killing a run at ticket six of ten and re-invoking resumes at the first unverified criterion, re-verifying nothing ticked and trusting nothing not ticked.
- [x] Criterion 24: a run crossing an auto-compaction boundary completes correctly and its close names every ticket, including those that landed before the boundary.
- [x] Criterion 25: a fresh session reaches the same next ticket, converge round, and recorded-item list, read from the pull request alone.
- [x] No AEP text instructs an agent to compact, and the reason is stated where a reader would look for it.

## Relevant areas

`src/skills/implement.md`, `src/agents/reviewer-correctness.md`, `src/policies/execution.md`, `src/policies/reporting.md`.

## Constraints

The tracker is read, never mirrored into the protocol directory. A failed write to the run log is a defect to report rather than a silent continue.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

## Implementation notes

Three durable homes, chosen so nothing is written twice: **commits** say which
tickets landed, **ticked checkboxes in the pull request body** say which criteria
are verified and what verified each, and a **collapsed run log** holds what has
no other home — the ledger, the converge round, review attempts per ticket, items
recorded but not acted on, and anything a child raised short of a trip-wire.

**The tick is the load-bearing part.** It is made by
`[[agents/reviewer-correctness]]` at the moment it verifies, never by the agent
that wrote the code, and that is exactly what lets a resumed run trust it without
re-deriving it. Re-verify nothing ticked; trust nothing unticked. A criterion the
reviewer could not verify stays blank and is re-verified by whoever resumes,
which is the cheap failure. A wrongly ticked one is never looked at again, which
is the expensive one.

**Written as the run proceeds, not at the close.** A record written at the end is
a record that does not exist for the failure it was meant to survive. The runner
writes it as step 6 of landing, before taking the next ticket.

**A failed write is reported, never continued past.** The run has just lost its
memory and does not know it yet, so continuing produces a confident close over
work nobody can find.

**The ledger now has two homes and one shape.** `policies/reporting.md` says the
copy in the turn and the copy in the run log are the same lines, same order, same
columns, because two renderings of one ledger diverge and the run reads whichever
it finds.

**Compaction:** stated as harmless, with the run not stopping for it, and the
prohibition on depending on it stated with its reason in both
`policies/execution.md` and the runner. The suite sweeps the whole payload for
text instructing an agent to compact rather than checking the three files this
ticket touched, since that instruction would arrive in whichever file nobody
thought to check.

**Fire-checks, five, each confirmed to have changed the subject first:**

| Perturbation | Failure |
| --- | --- |
| both statements that the author never ticks removed | `the agent that wrote the code never ticks its own criteria` |
| resumption changed to re-check everything | `a resumed run re-verifies nothing ticked and trusts nothing unticked` |
| `items recorded but not acted on` dropped from the run log's contents | `the run log carries what was recorded and not acted on` |
| a compaction instruction appended to `skills/prune.md` | `no shipped artifact instructs an agent to compact: instructing it: skills/prune.md` |
| the failed write softened to "is logged" | `a failed write to the run log is reported rather than continued past` |

The run log's contents are asserted one row at a time rather than by a single
check over the table: one assertion over all five passes while any single row is
missing, and the row that goes is whichever was least convenient to write.

**Criteria 22 through 25 are stated behaviour, not executed runs.** Nothing opens
a pull request yet — that is ticket 14 — so no fixture can kill a run at ticket
six and resume it. What is asserted is that each behaviour is stated where the
runner and the reviewer will read it. Ticket 20 exercises the loop end to end.
