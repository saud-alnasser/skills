---
status: resolved
blocked-by: [04, 05]
---

# test(verify): git's refusals are asserted against real worktrees

## Outcome

The guarantee the whole design rests on is asserted rather than described. A test
creates a real worktree, holds a branch in it, and proves that the three paths
into that branch are refused, that detaching releases it, and that the incident
of 2026-08-24 cannot replay.

## Acceptance Criteria

- [x] A test creates an effort branch into a worktree and asserts
      `git worktree list` names the branch against that path (requirement 1,
      criterion 1).
- [x] `git worktree add` on the held branch, `git switch` to it, and
      `git branch -f` on it are each asserted to fail (requirement 1,
      criterion 1).
- [x] A replay asserts that a second checkout cannot reach the held branch, so
      neither the cherry-pick nor the reset that caused the incident can land
      (requirement 3, criterion 3).
- [x] `git switch --detach` in the holder is asserted to release the branch,
      after which another checkout takes it successfully (requirement 12,
      criterion 11).
- [x] A clean close leaves the branch checkout-able and the directory gone; a
      simulated failure leaves the directory present and the branch still free
      (requirement 12, criterion 11).
- [x] Every worktree the suite creates is removed by it, and a failing assertion
      does not leak one (criterion 12).

## Relevant areas

`src/scripts/verify.mjs`. Effort 51's worktree assertions are the worked example
of creating and removing a real worktree inside the suite.

## Constraints

Assert against git's actual refusal, not against a message string that a git
version may reword. Match on the failure and on the named holder, not on exact
wording.

The suite runs on Windows here. Path comparison and directory removal both
behave differently from POSIX, and a test that passes only on one is not done.

Do not assert `git update-ref` is refused. It is not, and the spec says so.

This ticket asserts git behaviour and the close-out lifecycle. Assertions over
shipped text belong to ticket 09.

## Notes

Both behaviours were probed by hand before the spec was written
(`[[efforts/54-working-surface/evidence/research/worktree-branch-exclusion]]`).
This ticket turns those probes into assertions that stay run.

`[[rules/authoring]]` requires each assertion to be seen to fail against a tree
with its subject removed. A green perturbation proves nothing until you confirm
it removed the subject.
