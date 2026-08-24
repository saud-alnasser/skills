---
status: resolved
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

- [x] The script assertions run `scope.mjs` in the install fixture and cover:
      the four printed fields and the three exit codes (criterion 1); `unscoped`
      before and the effort after a first commit on a `t3code/<hex>` branch
      (criterion 2); a branch touching two efforts resolving to both
      (criterion 4); `check` exiting 1 with the offending path and 0 on an empty
      claim (criterion 5).
- [x] A worktree assertion creates one with `git worktree add`, asserts
      `worktree` and the sibling path from inside it and `checkout` from the main
      one, and removes it in the same test (criterion 7).
- [x] Surface assertions cover the policy's confinement, no-exemption, mismatch,
      and uniqueness statements (criteria 3, 5, 6, 8), the skills' entry line and
      the exact set of skills that invoke `scope.mjs` (criterion 10),
      `specify`'s branch base (criterion 9), the seeds (criteria 8 and 9), and
      `skills/plan.md` naming `plan.md` (criterion 12).
- [x] `node src/scripts/verify.mjs` reports no failure outside the `stamps`
      section, and nothing newly unchecked that this effort could have checked
      (criterion 11). **The stamps are ticket 08's**: every shipped file this
      effort edits fails its stamp until `release.mjs` re-stamps it, and folding
      that release into 08 is what the human decided when the conflict surfaced.
- [x] Each new assertion was seen to fail with the right name against a
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

The record the rule asks for. Three perturbations, each run against the tree with
its subject removed, each restored with `git checkout --` afterwards.

**A. Content resolution removed.** `scope.mjs` changed so the claim comes from
`claimFromName` alone rather than from the commits, which is precisely the wrong
implementation this section exists to reject.

```
FAIL  the same branch resolves to the effort its commit touched: claim  unscoped
FAIL  renaming the branch to another effort does not move the claim:
        the name answered instead of the commits: 41-beta
FAIL  a branch touching two efforts claims both, and check still passes
FAIL  the working set outside the claim is listed, and check exits 1
8 passed, 4 failed
```

The second line is the one worth keeping: the fixture branch is named
`41-beta`, which is the other effort's exact directory name, so a name match
answers `41-beta` and a content match answers `40-alpha`. A guard that read the
name would have passed every other assertion in the section.

**B. The policy's no-exemption sentence removed**, rewritten to permit an
exemption for a tree-wide subject.

```
FAIL  confinement has no exemptions, tree-wide subjects included
23 passed, 1 failed
```

**C. One skill's scope read removed**, `prune`'s swapped for a `position.mjs`
read, which is the shape a drift would actually take.

```
FAIL  exactly the eight effort skills invoke scope.mjs
        on disk: implement, plan, refine, review, specify, survey, tasks
23 passed, 1 failed
```

**A defect the writing found.** Every prose matcher first ran against the raw
file and three failed against text that satisfied them, because a shipped file
wraps at eighty columns and the phrase straddled the break. They now run over
`flat`, which the suite already had for this. Worth recording because the failure
mode is the inverse of the one the rule warns about: not a guard that passes
while broken, but a guard that fails while correct, and the cheap fix for that is
to loosen it until it passes, which is how a real one gets switched off.
