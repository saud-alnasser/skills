---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: open
part-of: aep-3
blocked-by: [03]
---

# refactor(protocol): modes fold into the skills that entered them

## Outcome

`src/modes/` is gone. Each mode’s Mindset and What this gives up now sit inside the skill that entered it, and no skill declares that it enters a mode. `payload.mjs` no longer ships the directory and `index.mjs` no longer has a Modes section.

## Acceptance Criteria

- [ ] Requirement 41 / criterion 29: `grep -r 'modes/' src/` returns nothing outside the migration path.
- [ ] Every skill that previously entered a mode carries that mode’s Mindset and What this gives up, in its own words rather than as a quotation.
- [ ] `modes` leaves `PAYLOAD_DIRS`, and `MOVES` or `NOTICES` in `payload.mjs` declares the removal so an upgrade can tell a human why the directory vanished.
- [ ] The suite’s `modes` section is deleted and the `skills` section absorbs whatever of it still applies.

## Relevant areas

`src/modes/`, `src/skills/`, `src/scripts/payload.mjs`, `src/scripts/index.mjs`, and the `modes` and `skills` sections of `src/scripts/verify.mjs`.

## Constraints

Fold, do not summarise. A mode’s two surviving paragraphs are the only part that was not already duplicated in its skill, so the rest is dropped rather than merged.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
