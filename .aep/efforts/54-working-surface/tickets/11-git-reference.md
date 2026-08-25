---
status: resolved
blocked-by: [05, 10]
---

# docs(references): the git reference carries the working-surface invocations

## Outcome

`[[references/git]]` declares itself the place for "working with worktrees" and
carries only the child-task shape: add, list, remove. The skills now require a
run to create its effort branch into a worktree, to release a claim by detaching,
and to do those two in a fixed order. None of that is here, so a run following
the reference alone cannot perform the close the runner asks for.

Appended by converge rather than cut with the others, because what a change
falsifies is only visible from the effort's whole diff.

## Acceptance Criteria

- [x] The worktree section carries creating the effort branch into
      `.aep/worktrees/<effort>/_run` in one act, and says why one act rather than
      two (requirement 1, criterion 1).
- [x] It carries `git switch --detach` as how a claim is released, and states
      that detaching comes before removing (requirement 12, criterion 11).
- [x] It names what git refuses against a held branch, so a reader meeting the
      refusal recognises it rather than treating it as an error to work around
      (requirement 1, criterion 1).
- [x] It names the two holes, `update-ref` and a second clone, consistently with
      `specs.md` section 18.2 (requirement 11, criterion 12).
- [x] The child-task example uses the namespaced branch name this repository
      requires, `<effort>/<ticket-id>-<slug>`, rather than the bare form
      (requirement 10, criterion 9).
- [x] `node src/scripts/verify.mjs` still passes and `node .aep/scripts/validate.mjs`
      reports no failures (requirement 11, criterion 12).

## Relevant areas

`.aep/references/git.md`, the `## Worktrees` section. `specs.md` section 18.2 and
`[[skills/implement]]`'s close for the behaviour being documented.

## Constraints

This is a reference: **how a tool is operated here**, not governance. It carries
invocations and the reason one is shaped as it is, and it never restates what
`[[policies/execution]]` requires.

It is repository-owned and ships nothing, so no `verify.mjs` assertion covers it
and the check is that the suite and validate still pass.

## Notes

The bare `<task-id>-<slug>` example predates the namespacing effort 51 introduced
for exactly the collision it describes. Effort 51 fixed the runner's example and
left this one, which is the same defect in the other place it was written down.
