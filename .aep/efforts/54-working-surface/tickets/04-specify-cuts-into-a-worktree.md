---
status: resolved
blocked-by: [03]
---

# feat(specify): the effort branch is created into a worktree

## Outcome

Opening an effort stops checking the new branch out wherever the run is standing.
The branch is created directly into `.aep/worktrees/<effort>/_run`, so the shared
checkout never holds it and git's refusal applies from the moment the branch
exists.

Where the runtime already gave the run a worktree, no second one is taken and the
effort branch is created in the surface that exists.

## Acceptance Criteria

- [x] Opening step 3 creates the effort branch into a worktree in one act, so
      there is no window in which the branch exists unheld (requirement 1,
      criterion 1).
- [x] The branch base is still read from `[[rules/version-control]]` rather than
      chosen, unchanged by this ticket (spec Scope).
- [x] Where `scope.mjs` reports isolation `worktree`, no second worktree is
      created and the effort branch is created in the current surface
      (requirement 2, criterion 2).
- [x] Where it reports `checkout`, the worktree is created at
      `.aep/worktrees/<effort>/_run` (requirement 2, criterion 2).
- [x] The decision keys on the isolation kind and never on the enforcement
      (requirement 2).
- [x] The turn's `Position` says which surface the run is using and, where none
      was taken, why (criterion 2).

## Relevant areas

`src/skills/specify.md`, the "Opening the effort" table and the paragraph on
where the new branch is based. `src/scripts/scope.mjs` for the isolation field,
which is read and not changed.

## Constraints

AEP creates nothing under a path the runtime owns. `.aep/worktrees/` is AEP's,
which `specs.md` section 18.1 already carves out.

The single human ask in this skill stays one ask. Taking a worktree is not a
second thing to ask about.

A refusal to open the effort still leaves the spec local and unopened. It must
not leave a worktree behind.

## Notes

`git worktree add -b <branch> <path> <base>` creates the branch and the worktree
together, which is what closes the unheld window
(`[[efforts/54-working-surface/evidence/research/worktree-branch-exclusion]]`).

Where the runtime supplied the surface, creating the effort branch there switches
that worktree off the runtime's generated branch. Permitted by section 18.1,
which forbids only create, name, and remove, and recorded as a risk in
`[[efforts/54-working-surface/plan]]`.
