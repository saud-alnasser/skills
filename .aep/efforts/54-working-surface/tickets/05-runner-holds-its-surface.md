---
status: resolved
blocked-by: [03]
---

# feat(implement): the run enters its surface, integrates there, and releases it at the close

## Outcome

The runner stops landing waves in whatever checkout it was invoked from. At step
2 it enters the effort's worktree, creating it where the effort branch exists but
the surface does not, and re-entering it where a previous run left one.

At the close it releases the branch by detaching, which frees it for a human
immediately, and then removes the directory only where the run finished cleanly.
A kept worktree holds no branch, so a crashed run cannot lock an effort against
its own resumption.

## Acceptance Criteria

- [x] Step 2 enters `.aep/worktrees/<effort>/_run`, creating it from the effort
      branch where it does not exist (requirement 1, criterion 1).
- [x] Where `scope.mjs` reports isolation `worktree`, no second surface is taken
      and the run says which one it is using (requirement 2, criterion 2).
- [x] A run finding an existing worktree for its effort re-enters it rather than
      creating a second (requirement 12, criterion 11).
- [x] A run finding that worktree with a dirty tree ends the turn naming the
      uncommitted paths, matching how a named effort outside the claim behaves on
      a dirty tree (requirement 12, criterion 11).
- [x] Every child is integrated into the effort branch inside the run's own
      worktree, never in the shared checkout (requirement 3, criterion 3).
- [x] The close detaches the worktree before removing anything, so the effort
      branch is checkout-able from the main checkout even when removal fails
      (requirement 12, criterion 11).
- [x] The directory is removed on a clean close and kept on a stop or a failure
      (requirement 12, criterion 11).

## Relevant areas

`src/skills/implement.md`, step 0 for what `Position` reports, step 2 for the
claim, step 4 for integration, and the close-out. `src/policies/execution.md` as
written by ticket 03, referenced rather than restated.

## Constraints

Detach before remove, always. Detaching frees the branch even where removal
fails, and a run that reversed them would have nothing left to detach.

A run cannot remove the directory it is standing in, which on Windows fails
outright. Removal happens from outside that worktree or is left to a later run.
**Releasing the branch is the part that must not be skipped.**

Child worktrees under `.aep/worktrees/<effort>/<ticket>/` are unchanged. This
ticket does not touch how children are isolated.

## Notes

`git switch --detach` inside the holding worktree releases the claim immediately
and leaves the directory intact, verified in
`[[efforts/54-working-surface/evidence/research/worktree-branch-exclusion]]`.
That is what lets keeping a failed run's tree cost nothing.

Git runs a lightweight prune during `git worktree add`, so administrative records
for directories that no longer exist clear themselves on the next run. A kept
directory is not reaped by that and stays a human's to remove.
