---
status: resolved
blocked-by: [11]
---

# fix(protocol): reaching a named effort means entering its surface, not checking its branch out

## Outcome

`[[policies/execution]]` and `[[skills/implement]]` both said a named effort
outside the claim is reached, on a clean tree, by checking that effort's branch
out. This effort makes that refusal-by-design: an effort in flight holds its
branch in a worktree, so `git switch` to it fails.

Both are corrected to say enter the surface, and `[[skills/plan]]` and
`[[skills/tasks]]` gain the same, since both write to the effort branch and
neither said how to reach it.

Found by converge, which is the only stage that reads the effort's whole diff.
Corrected here rather than appended as a gap, because what a change falsifies is
corrected in the change (`[[policies/execution]]`).

## Acceptance Criteria

- [x] `policies/execution.md` says a named effort on a clean tree is reached by
      entering its working surface, and that a refused switch names where the
      claim is held rather than being an obstacle (requirement 4, criterion 4).
- [x] `skills/implement.md` step 1 says the same and points at step 2
      (requirement 3, criterion 3).
- [x] `skills/plan.md` and `skills/tasks.md` each say to enter the effort's
      surface where it is not the one the checkout is on (requirement 2,
      criterion 2).
- [x] The two existing assertions that matched the old wording move with it, and
      two new ones cover the replacement, each seen to fail with its subject
      removed (requirement 11, criterion 12).
- [x] `node src/scripts/verify.mjs` passes and `node .aep/scripts/validate.mjs`
      reports no failures, with `.aep/` reinstalled from `src/` (requirement 11,
      criterion 12).

## Relevant areas

`src/policies/execution.md` under "Claiming, before dispatching",
`src/skills/implement.md` step 1, `src/skills/plan.md` and `src/skills/tasks.md`
step 1, and the two assertions in `src/scripts/verify.mjs` that pinned the old
sentence.

## Constraints

Do not weaken the dirty-tree stop. It is unchanged: dirty still ends the turn
naming the claim, the effort, and the uncommitted paths.

A refused switch is reported, never routed around. `[[policies/execution]]`
already says a claim held elsewhere is never taken, and this is that rule
arriving through git.

Re-stamping is required after editing stamped artifacts, so this ticket re-runs
`release.mjs 3.2.0` rather than leaving the suite red.

## Notes

This is converge round 2's finding. No third round runs
(`[[policies/execution]]`), so anything surfacing after this is named at the
close rather than built.
