---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: open
part-of: aep-3
blocked-by: [07]
---

# docs(spec): the specification follows the implementation it defines

## Outcome

The normative specification states AEP 3: the primitive set, the frontmatter contract, the absence of modes, the skill surface, the workflow spine, the adapter entrypoint contract, and installation and upgrade under a manifest.

## Acceptance Criteria

- [ ] Criterion 46: the suite exits zero and every claim the specification makes about a shipped surface is asserted against it.
- [ ] The frontmatter section states `use-when` and `paths`, states the four checks, and no longer describes any removed field except in the migration section.
- [ ] The modes section is removed and the sections that referenced it are corrected rather than left pointing at nothing.
- [ ] The upgrade section states the two classification mechanisms and the condition under which the older one is removed.

## Relevant areas

The specification at the repository root, and `src/scripts/verify.mjs` throughout.

## Constraints

The specification is not shipped, so it may name itself and its own sections. Shipped text may not (`[[rules/authoring]]`).

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
