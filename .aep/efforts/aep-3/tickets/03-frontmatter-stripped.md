---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: open
part-of: aep-3
blocked-by: [02]
---

# refactor(protocol): every artifact drops the six fields nothing reads

## Outcome

`aep`, `date`, `kind`, `mode`, `report`, `owner`, and `part-of` are gone from every shipped artifact and from every template’s example block. What remains is `use-when`, `paths` where it narrows, and the effort state fields. Validation now requires the new shape rather than merely accepting it.

## Acceptance Criteria

- [ ] Requirement 55 / criterion 38: a skill’s frontmatter is `use-when` and nothing else. No artifact under the payload carries any removed field, and the bootstrap is the only file naming a release.
- [ ] Criterion 44: the ticket template’s example frontmatter is `status` and `blocked-by`, and nothing else.
- [ ] `paths` survives on the artifacts that carry it.
- [ ] `validate.mjs` now rejects a removed field rather than ignoring it, and the guard is broken deliberately once.
- [ ] Criterion 39 still holds after the strip: content hashes are unchanged, because the hash already stripped `aep:` and `date:`.

## Relevant areas

Every `.md` under `src/` outside `src/seed/`, plus `src/templates/`. `src/scripts/validate.mjs` for the tightening.

## Constraints

A mechanical pass over every shipped artifact is where a hand-edit gets reverted silently. Change frontmatter only. Any prose edit that travels with this pass is out of scope and is raised rather than taken.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
