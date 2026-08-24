---
status: resolved
blocked-by: [03]
---

# refactor(skills): commit and the labels ladder are removed, four commands remain

## Outcome

`skills/commit.md` and `skills/tasks/labels.md` are gone. Commit’s mechanics live inline in the runner and its two effort-level judgements move to converge. `commit/conflicts.md` survives as depth the runner reads. `refine`, `research`, and `review` survive as files but are no longer registered as commands, leaving four workflow commands and the utilities.

## Acceptance Criteria

- [x] Requirement 43: `src/skills/commit.md` does not exist and the conflict note does, at `src/skills/implement/conflicts.md`.

  Corrected during implementation. The note could not stay under `skills/commit/`: the artifact contract requires a note to sit beside a real skill and to be linked from it, and both become impossible the moment `skills/commit.md` is deleted. Moved to the skill that reads it. `spec.md` requirement 43 and criterion 43 were corrected in the same change.
- [x] Requirement 45: `src/skills/tasks/labels.md` does not exist.
- [x] Requirement 42 / criterion 30: the adapter registers `specify`, `plan`, `tasks`, `implement`, and the utilities, and does not register `refine`, `research`, `review`, `commit`, or `converge`.
- [x] Criterion 29: the suite asserts the two deletions by name.
- [x] `survey`, `domain`, and `prune` are present and unchanged.
- [x] `MOVES` or `NOTICES` declares both removals so an upgrade explains them.

## Relevant areas

`src/skills/`, `src/scripts/adapters.mjs`, `src/scripts/payload.mjs`, `src/scripts/contract.mjs`, and the `skills` section of `src/scripts/verify.mjs`.

## Constraints

Commit’s content is redistributed, not deleted. Anything in it that is not mechanics and not an effort-level judgement is a finding to raise before this ticket closes.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

### Where the two effort-level judgements went

Converge does not exist yet: ticket 12 builds it, behind ticket 10. So both judgements are stated at the effort level in `skills/implement.md`, under a heading for when the effort has no unresolved task left, and ticket 12 moves them into the converge section it writes. Nothing is lost in between, and the runner already reaches that point on its own.

### A guard that passed its own fire-check, wrongly

The first version of the registration guard asked `STAGE_SKILLS` whether the skills on it had been excluded from a render that `STAGE_SKILLS` itself filtered. Dropping a name moved both sides together and the assertion stayed green. Rewritten to pin the three names the requirement states, with a second assertion that the mechanism and the requirement name the same set, so they cannot drift apart either.

This is the failure `[[rules/authoring]]` describes exactly: a guard matching something travelling with the thing it checks. It survived writing the warning into the comment above it.

### What was raised rather than taken

`/commit`'s stage-confirmation questions asked whether position was read this run. `/implement` already reads position at step 0 and stamps it on the way out, so the question is answered by the skill's own structure and is not restated.

The suite's `readsPosition` pin drops from three skills to two for the same reason.
