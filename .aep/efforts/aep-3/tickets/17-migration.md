---
status: open
blocked-by: [16]
---

# feat(update): a 2.x tree reaches 3 without losing what the repository owns

## Outcome

`update` recognises the layout by content: a tree carrying `owner:` is 2.x and is classified by the field; a tree without it is 3 and is classified by the manifest. The 2.x branch writes the 3 layout, splits any spec carrying an architecture section, and reshapes tracker artifacts for efforts still in flight only.

## Acceptance Criteria

- [ ] Criterion 32: a 2.x tree becomes a 3 tree in which every repository-owned artifact is present and unedited, every spec carrying an architecture section has become a spec and a plan, and the report names every artifact it could not translate.
- [ ] Criterion 33: a repository with one landed effort and one in flight has only the second reshaped, and the landed effort’s issues and pull request are byte-identical afterwards.
- [ ] Criterion 34: every tracker write is shown as exact strings before any is made, and none is made if approval is refused.
- [ ] Milestones entirely AEP’s are deleted; labels are not.
- [ ] The 2.x branch states its removal condition in the file rather than in a commit message.

## Relevant areas

`src/skills/update.md`, `src/skills/update/migration.md`, `src/scripts/install.mjs`, and the `install fixture` section of `src/scripts/verify.mjs`.

## Constraints

This touches shared data and has one attempt per repository. A landed effort is a record and is never rewritten. The 2.x fixture this is tested against must be built here, because migrating this repository consumes the only real one.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
