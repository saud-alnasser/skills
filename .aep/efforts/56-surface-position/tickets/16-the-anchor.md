---
status: resolved
blocked-by: [14, 15]
---

# fix(protocol): a ticket surface is anchored on the main checkout, and the discriminator is the underscore

## Where this came from

Review round one, standards axis, the most severe finding of either. A dispatched
child computes the wrong role on both dispatch paths, and on one of them it
computes `orchestrator` and is then granted the integrate-and-dispatch pair that
`agents/implementer` was rewritten in this same effort to refuse.

`surfaceOf` anchors every surface on the main checkout. Nothing shipped tells an
orchestrator to. `seed/references/git.md` writes the ticket worktree as a bare
relative path, which git resolves against the orchestrator's cwd, and the
orchestrator's cwd is its own surface.

- Under `worktree` isolation the child lands outside `<main>/.aep/worktrees/`,
  reads `runtime`, and therefore `orchestrator`. **This is the dangerous case.**
- Under `checkout` isolation it lands nested and reads `unknown`, which fails open
  and is merely wrong.

## Outcome

Every surface AEP creates is anchored on the main checkout, said where a run
reads it. The `runtime` row's reason becomes true, and the `_` prefix carries the
discriminator so a prototype worktree stops computing `implementer`.

## Acceptance Criteria

- [x] Requirement 2 and criterion 2, whose derivation this makes reachable: the
      dispatch step now states that a child's surface is created under the main
      checkout's `.aep/worktrees/`, never relative to the surface the orchestrator
      stands in, and names both failure modes: nested it reads `unknown` and
      refuses nothing, outside `.aep/worktrees/` it reads as a runtime surface
      whose occupant is an orchestrator.
- [x] `seed/references/git.md` anchors both invocations on the main checkout and
      says why in a comment beside them.
- [x] `the runner anchors a child surface on the main checkout` fails when the
      sentence goes: perturbed to "wherever is convenient", the suite went
      `2042 passed, 6 failed` to `2041 passed, 7 failed` naming it.
- [x] The discriminator is now the **leading underscore**. `_run` is the
      orchestrator, any other underscored name is `unknown` and fires nothing, and
      every non-underscored sibling is a ticket surface. Driven directly:
      `_run` to `run`, `03-thing` to `ticket`, `_prototype-spike` to `unknown`.
      A fixture builds the third as a real worktree, and disabling the reserved
      check makes it report `surface "ticket at .aep/worktrees/40-alpha/_prototype-spike",
      expected unknown`.
- [x] `skills/prototype.md` puts its worktree at
      `.aep/worktrees/<effort>/_prototype-<slug>`, so a prototype no longer
      computes `implementer` and is no longer forbidden to dispatch by a rule
      written for children.

**Two guards caught me while building this.** Ticket 02's row-count assertion
fired on a sixth table row I added, and it was right to: the existing final row
already maps anything unmatched to `unknown`, so the sixth was a duplicate. And
the fixture's first branch name, `40-alpha/_prototype-spike`, could not be created
because `40-alpha` already exists as a branch. That is exactly the pre-existing
git ref collision the standards review flagged in the shipped `aep-3` example,
hit live.

## Relevant areas

`src/scripts/scope.mjs`, `surfaceOf` and the `RUN` constant.
`specs.md` section 18.3, the discriminator sentence and the `ticket` row.
`src/skills/implement.md`, the dispatch step. `src/seed/references/git.md`.
`src/skills/prototype.md`. `src/scripts/verify.mjs`.

## Constraints

- **Fail open stays.** An `_`-prefixed occupant other than `_run` is `unknown`
  and fires nothing. Do not invent a third role.
- The existing crossed-branch fixture must keep passing. `surfaceOf` still reads
  no branch name.
- Shipped text may not cite `specs.md`. No em dash.
- Seen to fail first, including a fixture proving a `_prototype` sibling no longer
  reads `implementer`.
