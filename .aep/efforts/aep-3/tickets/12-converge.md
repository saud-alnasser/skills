---
status: open
blocked-by: [10]
---

# feat(implement): converge decides when the effort is done

## Outcome

When no unresolved ticket remains the runner converges: it assesses the codebase against the spec and the plan, appends the gap as tickets, and continues. It runs at most twice. It distinguishes work not built from an approach that does not work, and it owns the two effort-level judgements the commit skill used to make from one ticket’s diff.

## Acceptance Criteria

- [ ] Criterion 16: an effort whose tickets are resolved but whose spec has an unmet requirement gains tickets for the gap and continues rather than completing.
- [ ] Criterion 17: an effort whose tickets are resolved and whose spec is satisfied has converge find no gap and the pull request go ready in the same run.
- [ ] Criterion 18: a converge round finding the approach itself unable to satisfy a requirement stops on the return-to-plan trip-wire rather than appending tickets.
- [ ] Criterion 19: an effort reaching the cap ends with the remaining gaps named at the close and in the pull request, and the pull request not marked ready.
- [ ] Criterion 28: a diff relocating something a context pointer names is caught by converge and the context is corrected before the pull request goes ready.
- [ ] Converge appends and never edits the spec or the plan, and the suite asserts that prohibition is stated.

## Relevant areas

`src/skills/implement.md`, `src/policies/execution.md`, `src/policies/engineering.md`.

## Constraints

Converge assesses; it does not redefine. Two rounds, fixed, with the reason for the number stated rather than left as a magic value.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
