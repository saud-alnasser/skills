---
status: resolved
---

# docs(specs): the specification says a run claims the surface it writes through

## Outcome

Section 18.1 stops establishing only the strength of the claim and says what a
run does about it: where the isolation is `checkout`, the run takes a worktree of
AEP's own before its first write. Section 20 says what `sessions` holds, and that
nothing may act on it, while keeping its prohibition on effort identity untouched.

This is the contract every other ticket is judged against, which is why it lands
before them.

## Acceptance Criteria

- [x] Section 18.1 states that a run whose isolation is `checkout` takes a
      worktree of AEP's own before its first write, keyed on the kind of
      isolation and never on the enforcement (requirement 2).
- [x] Section 18.1 still forbids requiring a worktree of the runtime, and still
      forbids creating, naming, or removing one the runtime owns. Neither
      sentence is weakened (requirement 1, and the spec's Out of Scope).
- [x] Section 20 states that `sessions` holds runtime-supplied identifiers, that
      they are a diagnostic, and that no conforming implementation reads them to
      decide whether to proceed (requirements 5, 6).
- [x] Section 20 still states that position MUST NOT carry which effort a run is
      inside, and its declared marker shape gains no key beyond `head`, `tree`,
      and `sessions` (requirement 7, criterion 10).
- [x] No wording in section 20 describes the marker as per-clone (requirement 8,
      criterion 7).
- [x] The numbered requirement list at the end of `specs.md` gains an entry for
      the working surface, in the style of the existing items 55 and 56
      (requirement 11).

## Relevant areas

`specs.md`, sections 18.1, 19.2, 20, and the numbered requirement list at the
end. `[[efforts/54-working-surface/plan]]` under Components and Integration says
what each surface becomes responsible for.

## Constraints

Normative protocol text is **exempt** from how governed text reads, including the
four prohibitions: its reader is the agent building against it
(`[[policies/reporting]]`). Match the surrounding sections, which is why the em
dashes already in `specs.md` are correct there and would not be in a commit
message.

Append to the numbered requirement list rather than renumbering it. Existing
numbers are cited from elsewhere in the tree.

## Notes

The plan orders this first because `verify.mjs` asserts over the shipped
surfaces rather than over `specs.md`, so writing the guards before the law they
encode inverts the dependency.

Section 18.1's existing carve-out already says AEP's own `.aep/worktrees/` is
unaffected by the MUST NOT, and that the orchestrator creates and removes those.
This ticket extends that sentence rather than arguing with it.
