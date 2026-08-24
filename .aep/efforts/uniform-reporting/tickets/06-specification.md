---
status: resolved
blocked-by: [01, 03]
---

# docs(specs): the specification defines what a turn tells the human

## Outcome

`specs.md` defines the report contract normatively, so the suite has something
to assert against and a second implementation of AEP would build the same thing.

## Acceptance Criteria

- [ ] §16 states that every skill declares `report:`, gives the test that assigns
      it, and names the fourteen-and-three split as it stands — in the idiom §16
      already uses for the two modeless skills, and for the same reason: so the
      suite can require a declaration of every skill.
- [ ] §8's frontmatter table gains `report`, with when it applies and its
      contract, including that a note carries none.
- [ ] A section defines the contract itself: the slots, their order, the turn as
      the unit, the nested-entry rule, the no-empty-slot rule, and the early-stop
      requirement.
- [ ] §32.2 lists the new assertions the suite must make.
- [ ] §35 gains one invariant, in the numbered list's existing register.
- [ ] The version of record and any section renumbering stay consistent — the
      suite asserts `specs.md` declares a version and lists Policies among the
      primitives.

## Relevant areas

`specs.md` §8 (~211), §16 (~458), §32.2 (~832), §35 (~922). The repository's own
`AGENTS.md` explains why this file is normative rather than descriptive.

## Constraints

- **`specs.md` is not shipped**, so it may cite section numbers freely — but
  nothing under `src/` may cite it back (`[[rules/authoring]]`).
- Where the implementation and this document disagree, a human decides which is
  the defect. Do not silently amend either to match the other.

## Notes

The spec's own Components table is the map of what this must describe. Write the
requirement, not the implementation: how `verify.mjs` parses a stage name belongs
to ticket 07, not here.
