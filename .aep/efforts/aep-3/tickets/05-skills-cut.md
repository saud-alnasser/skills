---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: open
part-of: aep-3
blocked-by: [03]
---

# refactor(skills): commit and the labels ladder are removed, four commands remain

## Outcome

`skills/commit.md` and `skills/tasks/labels.md` are gone. Commit’s mechanics live inline in the runner and its two effort-level judgements move to converge. `commit/conflicts.md` survives as depth the runner reads. `refine`, `research`, and `review` survive as files but are no longer registered as commands, leaving four workflow commands and the utilities.

## Acceptance Criteria

- [ ] Requirement 43: `src/skills/commit.md` does not exist and `src/skills/commit/conflicts.md` does.
- [ ] Requirement 45: `src/skills/tasks/labels.md` does not exist.
- [ ] Requirement 42 / criterion 30: the adapter registers `specify`, `plan`, `tasks`, `implement`, and the utilities, and does not register `refine`, `research`, `review`, `commit`, or `converge`.
- [ ] Criterion 29: the suite asserts the two deletions by name.
- [ ] `survey`, `domain`, and `prune` are present and unchanged.
- [ ] `MOVES` or `NOTICES` declares both removals so an upgrade explains them.

## Relevant areas

`src/skills/`, `src/scripts/adapters.mjs`, `src/scripts/payload.mjs`, `src/scripts/contract.mjs`, and the `skills` section of `src/scripts/verify.mjs`.

## Constraints

Commit’s content is redistributed, not deleted. Anything in it that is not mechanics and not an effort-level judgement is a finding to raise before this ticket closes.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
