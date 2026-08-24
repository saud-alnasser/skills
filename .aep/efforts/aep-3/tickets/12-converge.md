---
status: resolved
blocked-by: [10]
---

# feat(implement): converge decides when the effort is done

## Outcome

When no unresolved ticket remains the runner converges: it assesses the codebase against the spec and the plan, appends the gap as tickets, and continues. It runs at most twice. It distinguishes work not built from an approach that does not work, and it owns the two effort-level judgements the commit skill used to make from one ticket’s diff.

## Acceptance Criteria

- [x] Criterion 16: an effort whose tickets are resolved but whose spec has an unmet requirement gains tickets for the gap and continues rather than completing.
- [x] Criterion 17: an effort whose tickets are resolved and whose spec is satisfied has converge find no gap and the pull request go ready in the same run.
- [x] Criterion 18: a converge round finding the approach itself unable to satisfy a requirement stops on the return-to-plan trip-wire rather than appending tickets.
- [x] Criterion 19: an effort reaching the cap ends with the remaining gaps named at the close and in the pull request, and the pull request not marked ready.
- [x] Criterion 28: a diff relocating something a context pointer names is caught by converge and the context is corrected before the pull request goes ready.
- [x] Converge appends and never edits the spec or the plan, and the suite asserts that prohibition is stated.

## Relevant areas

`src/skills/implement.md`, `src/policies/execution.md`, `src/policies/engineering.md`.

## Constraints

Converge assesses; it does not redefine. Two rounds, fixed, with the reason for the number stated rather than left as a magic value.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

## Implementation notes

Converge is stated in three places, each answering a different reader's
question. `policies/execution.md` says what converge is and what it may not do;
`skills/implement.md` step 5 is the procedure; `policies/engineering.md` says
converge is not a route around deciding architecture silently.

**The line that carries the most weight is the one separating "not built" from
"does not work".** Both look identical from inside a single diff, and only the
first may become tickets. A gap the design cannot close is the plan being wrong,
and appending a ticket against it buys another round of the same failure while
producing a written ticket, which reads as progress. That is why the constraint
is repeated in `engineering.md` under `## Decisions` rather than only in
`execution.md`: converge is the one stage with the whole diff in view and nobody
reviewing it, so it is the natural place for autonomy above the plan to be
acquired quietly.

**Append, never edit, for the same reason.** A converge that could edit `spec.md`
would close every gap it found by narrowing what was asked, and the run would end
green having agreed with itself.

**The cap's reason ships beside the number.** Two rounds, with why-two stated in
the policy and again in the runner, because a bare cap is a magic value the next
reader raises.

**The two effort-level judgements moved here from `skills/commit`**, which ticket
05 removed. They sat in the runner's old step 5 as a stopgap; they are now
converge's, in the policy, with the runner asking them.

**Two ticket-10 assertions were rewritten rather than left passing.** The runner
now sends an empty frontier to converge instead of ending, so the assertion that
an empty frontier "ends the run only when nothing unresolved remains" was
asserting the opposite of what the file says. The two effort-level judgement
assertions moved to the `converge` section and the runner keeps one that it
reaches step 5 at all, since a runner missing that step reads exactly like one
whose tickets ran out.

**Fire-checks, four, each confirmed to have changed the subject first:**

| Perturbation | Failure |
| --- | --- |
| the `MUST NOT edit` prohibition removed | `the policy forbids converge editing spec.md or plan.md` |
| the cap changed to three rounds | `the cap is two rounds, in both the policy and the runner` |
| `skills/converge.md` created | `converge is not invocable and ships no skill of its own`, plus the skill-set assertion |
| `Converge never builds around the second` removed | `converge never builds around the second` |

**Criteria 16, 17, 18, 19 and 28 are stated behaviour rather than executed
runs.** Nothing yet runs an effort end to end in a fixture: the pull request
converge readies is opened by ticket 14 and the run log it writes into is ticket
11. What is asserted here is that each behaviour is stated where the runner will
read it. Ticket 20 is where the whole loop is exercised.

**One em dash was caught by the governed-text guard** in a regex matching the
`## 5 — Converge` heading. Rewritten as `/^## 5 .*Converge$/m`.
