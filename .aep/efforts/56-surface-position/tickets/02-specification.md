---
status: resolved
---

# docs(specs): the specification defines the surface, the role, and one marker per surface

## Outcome

`specs.md` section 18 names every surface kind and the role each carries, and
section 20 states that a marker belongs to the surface it sits in and that a
conforming skill may not check one surface's marker while stamping another's. A
conforming implementation is told what to compute and what it may not do, and the
shipped surfaces can be asserted against it.

## Acceptance Criteria

- [x] Criterion 11: six assertions added, reading `specs.md` directly. Nine
      perturbations by the builder, all firing and naming the right assertion,
      including a sixth table row caught by row count rather than by naming four
      kinds. Independently re-checked at integration: deleting the
      check-and-stamp prohibition gave `1987 passed, 1 failed`, restoring it gave
      `1988 passed, 0 failed`.
- [x] Section 20's prohibition left standing. `git diff --numstat` reports
      `28 0 specs.md`, zero deletions, so neither the effort-identity prohibition
      nor the three-key bound was touched; both greps still return 1 and both
      existing assertions still pass. Compatibility is written into the new text
      rather than assumed, and pinned by the sixth assertion.

## Relevant areas

`specs.md` sections 18, 18.1, 18.2, and 20. `src/scripts/verify.mjs` — the block
that already asserts against the `spec` variable, near the working-surface
assertions, is the pattern to copy.

## Constraints

- **This is the normative text, so it says MUST and MUST NOT** rather than
  describing what this repository happens to do.
- Do not weaken section 20. The three-key bound and the effort-identity
  prohibition both survive this change and are what the new text is written
  around.
- The specification is not shipped, so it may cite its own section numbers.
  Nothing written here travels into `src/` ([[rules/authoring]]).
- Every assertion added here is seen to fail first.

## Notes

This ticket gates 03 through 07: `verify.mjs` asserts the shipped surfaces against
the specification, so the surfaces cannot be asserted before the specification
says what they must contain.

It does not gate ticket 01, which changes behaviour rather than prose.
