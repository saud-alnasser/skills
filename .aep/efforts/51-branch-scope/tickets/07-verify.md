---
status: open
blocked-by: [01, 02, 03, 04, 05, 06]
---

# test(verify): every claim this effort adds is asserted, and each was seen to fail

## Outcome

`verify.mjs` carries an assertion for every mechanically checkable claim this
effort adds, named after the section of `specs.md` that demands it, and each one
has been watched failing against a tree with its subject removed. The script's
behaviour is exercised against a real fixture repository, including a real
worktree created and removed by the test.

## Acceptance Criteria

- [ ] The script assertions run `scope.mjs` in the install fixture and cover:
      the four printed fields and the three exit codes (criterion 1); `unscoped`
      before and the effort after a first commit on a `t3code/<hex>` branch
      (criterion 2); a branch touching two efforts resolving to both
      (criterion 4); `check` exiting 1 with the offending path and 0 on an empty
      claim (criterion 5).
- [ ] A worktree assertion creates one with `git worktree add`, asserts
      `worktree` and the sibling path from inside it and `checkout` from the main
      one, and removes it in the same test (criterion 7).
- [ ] Surface assertions cover the policy's confinement, no-exemption, mismatch,
      and uniqueness statements (criteria 3, 5, 6, 8), the skills' entry line and
      the exact set of skills that invoke `scope.mjs` (criterion 10),
      `specify`'s branch base (criterion 9), the seeds (criteria 8 and 9), and
      `skills/plan.md` naming `plan.md` (criterion 12).
- [ ] `node src/scripts/verify.mjs` passes, and the run reports nothing newly
      unchecked that this effort could have checked (criterion 11).
- [ ] Each new assertion was seen to fail with the right name against a
      deliberately broken tree, and the perturbation used is recorded in this
      ticket's notes (criterion 11).

## Relevant areas

`src/scripts/verify.mjs`. `installFixture()` near the top already installs into a
temporary git repository and is reused across sections; extend it with a helper
that commits and branches rather than building a second fixture. The pinned-set
pattern to copy is the `position.mjs` assertion, which fails when the set of
skills invoking a script changes.

## Constraints

- **A green run proves nothing until the perturbation is confirmed to have
  removed the subject** (`[[rules/authoring]]`). For the content-resolution
  assertions the two perturbations are: rename the branch, which must not change
  the answer, and remove the effort commit, which must.
- Assertions are named after the `specs.md` section that demands them, matching
  the file's existing convention.
- The worktree test must remove its worktree explicitly. A throw before removal
  leaves a registration in the fixture's common `.git`; the fixture is temporary,
  but relying on that hides a leak the same code would have in a real repository.
- Where a claim cannot be checked mechanically, report it as unchecked rather
  than omitting it, which is what the file already does at the end of a run.

## Notes

The record of which perturbation was used for which assertion goes here, in this
ticket, as it is done. That is the evidence the rule asks for, and it is
worthless a week later if nobody wrote down which guard was actually watched to
fail.
