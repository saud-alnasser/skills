---
status: resolved
---

# fix(protocol): nothing shipped reaches for a tracker before establishing there is one

## Outcome

The two skills that still open with a tracker call name the case where there is
none. `[[skills/install]]` step 8 reads the forge's label list to decide which of
two offers to make, and has no row for a repository with no forge to read;
`[[skills/update]]`'s 2.x section reads which efforts are in flight from the
tracker, which is the one place that section cannot fall back to the tree.

## Acceptance Criteria

- [x] Requirement 62: nothing under `skills/` or `agents/` makes a tracker call
      before establishing there is a tracker. `install.md`, `update.md`,
      `specify.md`, `implement.md`, and `reviewer-correctness.md` are each
      checked.
- [x] `install` skips the label offer entirely where there is no tracker, and
      says it skipped it rather than reporting a seeded set nobody can use.
- [x] The 2.x reshape names what it does where a 2.x tree has no tracker: there
      is nothing to reshape, and the tree half of that migration still runs.
- [x] `[[agents/reviewer-correctness]]` ticks a box that exists in both postures,
      and which one it is changes nothing about whose tick it is.
- [x] The suite asserts the absence over the payload rather than file by file, so
      the next artifact to reach for a tracker fails too.

## Relevant areas

`src/skills/install.md` step 8; `src/skills/update.md` under
`### The tracker`; `src/agents/reviewer-correctness.md` under
`## You tick the criteria, and only you`; `src/scripts/verify.mjs`.

## Constraints

`install`'s two-row table is about what a tracker already carries and stays as it
is. The tracker-less case is a third state before that table, not a third row in
it: the question "which offer" only arises once there is somewhere to offer it.

## Notes

Found by converge, after requirements 62 and 63 landed. Both predate the ticket
that gave the tracker-less posture a procedure, and neither was in that ticket's
relevant areas, which is the shape of gap it could not have caught: each step is
correct for the repository it was written for.

The suite moves in the same pass (`[[rules/authoring]]`). Write the guard, break
the thing deliberately, confirm the subject is gone, watch it fail by name.

**Built.** Two skills and one agent corrected, and one guard that asks the whole
payload the question rather than asking each file.

**The guard is the point, not the two edits.** Both steps were correct for the
repository they were written for, and neither was in the relevant areas of the
ticket that gave the tracker-less posture a procedure. A per-file check would
have to be remembered; a payload-wide one is what the third skill runs into. It
matches the phrases that *instruct* a tracker read or write rather than the word
`tracker`, which every one of these files has a reason to use.

**`install` skips the offer rather than shrinking it.** A projection with no
surface is not a smaller offer, it is no offer, and a seeded vocabulary nobody
can apply leaves a repository carrying a list it will read as work owed. Saying
it was skipped is the part that matters: a step that silently does nothing is one
nobody can tell from a step that ran.

**The 2.x reshape keeps its tree half.** A 2.x tree with no forge lost nothing in
2.x and loses nothing here, so the section says it was skipped and why rather
than the migration reporting a section it could not run.

**The sweep was weak, and the fire-check is what found it.** It first keyed on
"Read the list first", a phrase this ticket's own edit demoted to "Otherwise read
the list first" — so breaking `install` deliberately made the sweep stop
considering `install` at all, and it passed. It is keyed on
"Offer the label vocabulary" now, the step's own name. A guard whose subject an
edit can move out from under it is a guard that reports green for the wrong
reason.

Three fire-checks, each confirmed to have removed its subject before the run:

| Broken deliberately | Fired |
| --- | --- |
| `install`'s skip softened to "keep the offer short" | no skill instructs a tracker call without naming the case where there is none: skills/install.md; install skips the label offer where there is no tracker |
| the 2.x tracker-less clause cut | no skill instructs a tracker call without naming the case where there is none: skills/update.md; the 2.x reshape still runs its tree half without a tracker |
| `specify`'s tracker-less clauses cut | specify names which posture it is in rather than assuming one; specify narrows its one ask when there is nothing public to push; no skill instructs a tracker call without naming the case where there is none: skills/specify.md |

**The third one is why the sweep covers `agents/` too.** The correctness
reviewer's tick is the thing requirement 62 leans on hardest, since the resumed
run trusts it without re-deriving it, and it was written as "a criterion's
checkbox in the pull request". With no tracker that box is in the ticket file,
which is where the ticks were always stored and where the pull request was only
ever projecting them from. The defect was never a property of skills, so neither
is the guard.

| Broken deliberately | Fired |
| --- | --- |
| the reviewer's tracker-less clause cut | no skill or agent instructs a tracker call without naming the case where there is none: agents/reviewer-correctness.md |

**One pre-existing guard nearly went with it.** Rewriting that sentence moved
"verify it**, carrying inline what verified it" across a line break, and a guard
reads that phrase in a specific shape. The lines were laid out again so the
phrase stays contiguous, rather than the guard being loosened to accept the new
wrapping.
