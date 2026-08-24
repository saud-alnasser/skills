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

- [x] **The installer stops reading the fields this ticket removes**, before it
      removes them. `applyMoves` decides a move source by content against the
      hash `MOVES` now carries; `rewriteMovedLinks` decides by location; and the
      move and notice gating reads `version:` with a fallback to `aep:`.

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

A return-to-plan, folded into this ticket rather than split out, and landed as
its own commit so the design change and the mechanical pass stay separable.

`install.mjs` read three fields this ticket removes, and every one failed
silently: two returned undefined and flipped a branch, and the third made a tree
look like it declared no release, which replays every move and every notice on
every upgrade forever. The suite could not catch any of it, because its install
fixtures still wrote the old fields, which is a guard matching something
travelling with the thing it checks.

Ownership of a move source cannot be decided by location: the file left the
payload, so the manifest does not name it, and a repository may legitimately have
written its own there. `MOVES` now carries `was`, the hash of the protocol text it
replaced, recovered from the commit that removed each file. A match is the
protocol's leftover and is removed; anything else is left alone and reported.

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
