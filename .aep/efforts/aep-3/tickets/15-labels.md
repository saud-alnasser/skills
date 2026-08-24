---
status: open
blocked-by: [14]
---

# feat(protocol): labels project the effort’s state onto the tracker

## Outcome

The issue and pull request carry the repository’s own labels. Derived labels re-sync on every write; initial ones are written once and never revised. The spec keeps its `status:` field and the label projects it, so the file wins when they disagree. A seeded label set ships for repositories that have none.

## Acceptance Criteria

- [ ] Criterion 7: moving an effort from draft to accepted changes both objects from backlog to ready in the same step, the spec still carries its status, and editing either by hand and re-running corrects the label to match the file, never the reverse.
- [ ] Criterion 8: the objects carry only labels that existed before the effort unless the run reported creating one and said why, and no label names AEP.
- [ ] Criterion 9: a pull request changing a dependency manifest carries the dependencies flag; one firing the public-contract trip-wire carries the breaking-changes flag.
- [ ] Criterion 10: a pull request going ready carries a size label matching the thresholds in that label’s own description, computed from the diff.
- [ ] Requirement 15: `priority:` and any flag that invites another person are written once and never revised, and a human’s change is not overwritten.
- [ ] `src/seed/labels.json` exists and carries the five families with descriptions that state a trigger.

## Relevant areas

`src/policies/execution.md`, `src/skills/specify.md`, `src/skills/implement.md`, `src/seed/labels.json` (new), `src/seed/references/github.md`.

## Constraints

A label is a marking of what the files say and never becomes the thing that says it. The repository outranks its projection.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
