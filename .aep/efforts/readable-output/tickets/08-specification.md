---
aep: 2.6.0
owner: repository
date: 2026-08-19
kind: ticket
status: resolved
part-of: readable-output
blocked-by: [01, 02, 03, 06]
---

# docs(specs): the specification admits an eighteenth skill and a widened contract

## Outcome

`specs.md` catches up with what the protocol now does, in the same change rather
than after it. The skill set is eighteen, the sub-skills are three, and §16.2
describes a contract over every text a human reads instead of over the turn
report alone.

## Acceptance Criteria

- [ ] §16's *exactly seventeen* becomes eighteen, the table gains a `prose` row,
      and the grouping line moves from two sub-skills to three (criterion 8).
- [ ] §16's sentence naming `tdd` and `domain` as the sub-skills admits the third.
- [ ] §16.1's *not one of the seventeen* and §29's *wraps the seventeen skills*
      both move to eighteen (criterion 8).
- [ ] The conformance list's *the skill set is exactly the seventeen of §16* moves
      to eighteen, and its modeless exception still names only `help` and
      `handoff` (criterion 8).
- [ ] §16.2 states the reader test, that the contract reaches every text a human
      reads, and that normative protocol text is exempt wherever it lives
      (criterion 8).
- [ ] §16.2 keeps everything it already says about slots, forms, and stage names.
      This widens the section; it does not replace it.
- [ ] The two script comments that state the count, in `contract.mjs` and
      `install.mjs`, agree with §16. `skills/install.md`'s *the same seventeen*
      does too.
- [ ] `verify.mjs`'s spec-to-surface comparison passes.

## Relevant areas

`specs.md` §16, §16.1, §16.2, §29, and the conformance list near the end.
`src/scripts/contract.mjs` and `src/scripts/install.mjs` carry the count in
comments. `src/skills/install.md` carries it in prose.

## Constraints

- **The specification is amended in the same change or the change is drift.**
  There is no version of this effort where the implementation moves and this file
  does not.
- The count appears in eight places outside the payload directory. Missing one
  leaves the suite green in some sections and red in another, and the failure
  names a count rather than the stale file.
- `specs.md` is exempt from the em dash ban. Do not sweep it here or anywhere.

## Notes

Blocked by 01, 02, and 03 because it describes what they did. Writing it first
would mean specifying an implementation that does not exist yet, which is the
drift this rule exists to prevent in the other direction.

Blocked by 06 for a different reason: the two count comments live in
`contract.mjs` and `install.mjs`, which 06 sweeps. The edge is a file collision
rather than a logical dependency, and `[[policies/execution]]` is explicit that
where isolation cannot be guaranteed, serial is correct and cheaper than
reconciling the collision.

**Taken beyond the listed criteria, each because this change created the
contradiction.** `verify.mjs`'s assertion label said *the seventeen specs.md
names*, a ninth count site missed when the eight were enumerated.
`src/protocol.md` named two sub-skills, which §16 naming three makes false, and
the clause costs 21 of its 279 spare bytes. §16.2 said a nested entry is `review`,
`commit`, *or either sub-skill*, and *either* does not survive a third.

**Raised at review, awaiting an outcome.** Two shipped surfaces still under-state
the sub-skill set, and neither is in this ticket's areas. `policies/reporting.md`
enumerates `tdd` and `domain` *as sub-skills* in its nested-entry sentence.
`skills/help.md`'s *what do I reach for* table routes to `tdd` and `domain` and
has no `prose` row, so the protocol's own discovery surface does not know an
eighteenth skill exists, and `verify.mjs` asserts nothing about `help.md` at all.
The second wants a ticket of its own.

**Also raised.** §16.2 now says the prohibitions are ones a script can check, but
the conformance list's §16.2 entry enumerates only the slot set. The guards land
in ticket 09, whose areas are `verify.mjs` alone, so the conformance entry
describing them has no home yet.

**Outcome recorded.** Both under-stated surfaces became ticket 11, which fixes
them and adds the guard whose absence let them survive two reviews.
