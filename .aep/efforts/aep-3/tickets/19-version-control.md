---
status: open
blocked-by: [10]
---

# chore(rules): this repository states what the runner may push

## Outcome

The runner pushes a branch and opens a draft pull request at the start of every effort, which is the first irreversible act AEP performs. This repository’s version-control rule states that permission explicitly instead of forbidding it outright.

## Acceptance Criteria

- [ ] Criterion 45: the rule names pushing a branch and opening a draft pull request as permitted for an effort the human opened, stated rather than implied, and nothing else in the not-allowed column moves.
- [ ] The rule says why the line moved and what still requires asking: merging, publishing a release, and pushing a tag.
- [ ] The stacked-changes sentence is corrected or confirmed against what this repository actually does.

## Relevant areas

`.aep/rules/version-control.md`.

## Constraints

This file is `owner: repository` and is this repository’s alone. It is not shipped, and no seed changes with it.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
