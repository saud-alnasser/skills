---
status: open
blocked-by: [10]
---

# feat(implement): the pull request becomes the run’s memory

## Outcome

Criteria are ticked in the pull request by the correctness reviewer at the moment each verifies, carrying inline what verified it. A collapsed run log holds the ledger, recorded items, the converge round, and review attempts. Nothing the run needs lives only in its context, so compaction is harmless and a killed session resumes from the pull request.

## Acceptance Criteria

- [ ] Criterion 20: a checkbox is ticked by the correctness reviewer, and never by the agent that wrote the code it refers to.
- [ ] Criterion 22: opening the pull request partway through a run shows which tickets are done, which criteria of the in-flight ticket are verified, and what verified each.
- [ ] Criterion 23: killing a run at ticket six of ten and re-invoking resumes at the first unverified criterion, re-verifying nothing ticked and trusting nothing not ticked.
- [ ] Criterion 24: a run crossing an auto-compaction boundary completes correctly and its close names every ticket, including those that landed before the boundary.
- [ ] Criterion 25: a fresh session reaches the same next ticket, converge round, and recorded-item list, read from the pull request alone.
- [ ] No AEP text instructs an agent to compact, and the reason is stated where a reader would look for it.

## Relevant areas

`src/skills/implement.md`, `src/agents/reviewer-correctness.md`, `src/policies/execution.md`, `src/policies/reporting.md`.

## Constraints

The tracker is read, never mirrored into the protocol directory. A failed write to the run log is a defect to report rather than a silent continue.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
