---
status: open
---

# docs(specs): the specification says what a run is scoped by

## Outcome

`specs.md` defines scope normatively, so every shipped surface that mentions it
is implementing something rather than inventing it. It names the claim, the
working set, the unscoped state, the ambiguity stop, and the rule that isolation
is detected and never required. It also corrects the description of position:
gitignored state is per working tree, not per clone.

## Acceptance Criteria

- [ ] `specs.md` defines the claim as the efforts a branch's own commits touch,
      the working set as what the tree touches now, and confinement as the second
      measured against the first (requirement 11).
- [ ] It states that an empty claim is unscoped and permits any effort, and that a
      run needing one effort from a larger set stops rather than choosing
      (requirement 11).
- [ ] It states that the isolation in force is detected and reported and that a
      conforming implementation MUST NOT require worktrees or create the
      runtime's own (requirement 11).
- [ ] It states that a ticket branch MUST be unique across efforts, leaving the
      mechanism to the repository (requirement 11).
- [ ] Section 20 no longer calls position per-clone (requirement 11).
- [ ] The numbered invariant list at the end gains the entry, in the style of the
      ones around it (requirement 11).

## Relevant areas

`specs.md` sections 18 to 20 are where worktrees, parallelism, and position
already live, and section 19.2 already carries "the branch is the claim". The
numbered invariants are at the end of the file. `specs.md` is not shipped, so it
may cite itself and this repository freely.

## Constraints

- **This lands before the shipped surfaces that cite it.** `verify.mjs` asserts
  surfaces against this file, and `[[rules/authoring]]` forbids shipped text from
  citing what does not resolve where it is read.
- Match the register of the sections around it: MUST and MUST NOT where the
  claim is normative, and an italic *why* paragraph where a reader would
  otherwise ask.
- Do not restate `spec.md`. The specification says what conforms; the effort's
  spec says what is changing.

## Notes

The per-clone correction is small and load-bearing: it is the sentence that made
the position marker look like a viable scope holder in the first place.
