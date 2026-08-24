---
status: resolved
---

# docs(protocol): a path in shipped text says where it starts from

## Outcome

The convention is written down before anything enforces it or sweeps to it. A path with two or more segments carries `.aep/`; a bare primitive-area name does not. `protocol.md` states it beside the link convention it already states, and `policies/artifacts.md` carries the reason, so somebody authoring a new artifact meets it rather than inferring it.

## Acceptance Criteria

- [x] Requirement 2 / criterion 2: `protocol.md` states the path convention alongside the link convention, and the suite fails if that statement is removed. — verified by review, fire-checked: deleting the two sentences from the link paragraph turned `[protocol.md] the bootstrap states the path convention beside the link convention: nothing says when a filesystem path carries the root` red, and the assertion stayed green when a neighbouring sentence was inserted and both statements were re-wrapped and re-ordered inside the same section.
- [x] Requirement 6 / criterion 6: `policies/artifacts.md` carries the convention and **why this form** rather than a root sigil or prose, under "Where it goes" where the ownership table already answers the neighbouring question. Removing the reason fails the suite. — verified by review, fire-checked three ways: deleting only the reason paragraphs reddens `policies/artifacts says why the convention takes this form`, deleting only the rule reddens `states the path convention where it states location`, and moving the whole block to the end of the file — out of "Where it goes", text intact — reddens both. So the two go red independently and the placement is enforced.
- [x] Requirement 1: the convention is stated in a form a reader can apply without seeing an example, and it says what the single-segment case is, because a rule that only covers the case that broke leaves the other one to be guessed. — verified by review: both surfaces state both arms, and both arms are asserted (`two segments or more carries .aep/` and `bare area name does not`). Caveat raised as a review question, not a defect: `protocol.md`'s compressed form drops the "naming an AEP artifact" scope that `policies/artifacts.md` and `specs.md` §9.1 both carry.
- [x] `protocol.md` stays inside its 8192-byte budget. It stands at 8043 and this ticket may spend about 95. — verified by review: `wc -c src/protocol.md` is 8151 against 8043 at `d88a17a`, so 108 spent and 41 bytes of headroom left. Inside the budget; 13 bytes over the ticket's own estimate, and the note's "roughly 50 bytes left" is really 41.
- [x] `specs.md` states the convention normatively in the same pass, since it is a claim about what a conforming implementation's shipped text does. — verified by review: §9.1 "Filesystem paths in prose" carries both arms as MUST/MUST NOT, records the two rejected forms, and cross-refers to §31.2, which exists.

## Relevant areas

`src/protocol.md`, `src/policies/artifacts.md`, `specs.md`, and `src/scripts/verify.mjs` for the two assertions above.

## Constraints

The statement is the deliverable, not the sweep. No payload file changes here beyond the two named: ticket 05 does the 37 sites, and doing any of them early makes the guard in ticket 04 unable to prove it was ever red.

`policies/artifacts.md` is AEP's law and ships to every consuming repository, so what it says must hold in a repository with no `src/` and no specification of its own.

## Notes

The budget is the reason the convention is what it is. Prefixing every tree path costs 120 bytes against 149 of headroom, leaving 29 for a sentence that needs about 85; prefixing only multi-segment paths costs 10. The alternatives and the arithmetic are in `[[efforts/48-artifact-paths/plan]]` and are not repeated here.

Worth stating in the diff for whoever comes next: after this ticket the bootstrap has roughly 50 bytes of headroom left, which is a much tighter ceiling than the one this effort found.
