---
status: resolved
blocked-by: [14, 15]
---

# fix(protocol): a surface is removed, not only released

## Outcome

The close says a surface is removed on a clean finish and then says a run cannot
remove the directory it stands in, so in practice nothing is ever removed. Child
worktrees have no removal step at all. A clone therefore accumulates one
directory per effort and one per ticket.

That is the observed steady state of this pattern rather than a hypothetical:
Claude Code's own worktrees are reported filling up for exactly this reason, at 1
to 12 GB each
(`[[efforts/54-working-surface/evidence/research/session-isolation-prior-art]]`).

The close now says where the removal is performed from, and a run entering a
surface reaps AEP's own worktrees whose branch is gone.

## Acceptance Criteria

- [x] The close says the removal is performed **from outside the surface**, from
      the repository root, rather than saying it cannot be done (requirement 12,
      criterion 14).
- [x] The landing step removes a ticket's worktree in the same breath as its
      branch (requirement 13, criterion 13).
- [x] Nothing reaps another run's surface, and the shipped text says why: a
      directory a stopped run kept deliberately and one an abandoned run left
      behind are indistinguishable from outside (requirement 12, criterion 14).
- [x] `policies/execution.md` and `specs.md` carry the same, so this is a
      requirement rather than one skill's habit (requirement 11, criterion 14).
- [x] The suite asserts against real worktrees that a surface is removable from
      the repository root while the process stands elsewhere, which is what makes
      the close achievable, and the assertion has been seen to fail with its
      subject removed (requirement 11, criterion 12).

## Relevant areas

`src/skills/implement.md`, step 2 for the reap and the close for the removal.
`src/policies/execution.md` under "Returning, and integrating". `specs.md` section
18.2. `src/scripts/verify.mjs`.

## Constraints

**Never reap a worktree the runtime owns.** `specs.md` section 18.1 forbids
creating, naming, or removing one, and that is unchanged.

**A run removes only its own surface.** A first draft of this ticket added a
reaper for worktrees whose branch was gone. Git refuses to delete a branch a
worktree holds, so the only reapable ones are detached, and a detached surface is
exactly what a stopped run keeps deliberately for inspection. The reaper would
have destroyed those. The spec's Out of Scope already declined this and was
right.

**Removal stays best-effort; releasing the branch does not.** A removal that
fails leaves a detached directory holding nothing, which is recoverable. The
ordering is unchanged.

## Notes

The spec's own line that a run removes its own surface was unachievable as
written, in the same shape as requirement 12's crash clause: the blocker is only
that the process is standing inside. This session removed `_build` from `_run`
while both existed, which is the proof that outside-in removal works.
