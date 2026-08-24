---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: open
part-of: aep-3
blocked-by: [01]
---

# feat(protocol): the frontmatter contract shrinks and use-when gains real checks

## Outcome

`validate.mjs` accepts the AEP 3 frontmatter shape and enforces it: `use-when` and `paths`, plus `status` and `blocked-by` on effort artifacts. `use-when` gains the four mechanical checks that make the concentration of discovery into one field safe. `release.mjs` loses its per-artifact stamping pass, and `index.mjs` stops rendering a Modes column and stops computing a date.

## Acceptance Criteria

- [ ] Requirement 60 / criterion 43: a `use-when` reading `"Database documentation"` fails by name; one reading `"changing anything under src/"` passes; one repeating its own file’s heading fails.
- [ ] The four checks are each a hard failure: names an occasion, is not a bare noun phrase, does not restate the heading, and is within the stated length bound.
- [ ] Requirement 59 / criterion 39: `release.mjs` sets the version of record with one write to the bootstrap and performs no per-artifact stamping. Hashes it produces for unchanged content are identical to those the 2.x tree produced.
- [ ] `index.mjs` renders no Modes column and computes no `date` for the index itself.
- [ ] `contract.mjs` no longer exports `KINDS`, `MODES`, `REPORT_FORMS`, or `MODELESS_SKILLS`, and every consumer of them in `validate.mjs` and `verify.mjs` is rewritten in the same change.
- [ ] The suite’s `frontmatter` and `stamps` sections assert the above, and each new guard is broken deliberately once.
- [ ] The admission line at the end of a run narrows to what the four proxies do not cover rather than disappearing.

## Relevant areas

`src/scripts/validate.mjs`, `src/scripts/release.mjs`, `src/scripts/index.mjs`, and the `frontmatter` and `stamps` sections of `src/scripts/verify.mjs`.

## Constraints

The payload still carries every removed field at this point. Validation must accept the new shape and must not yet require it, or ticket 03 has no tree to run in.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
