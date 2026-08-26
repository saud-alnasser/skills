---
status: obsolete
---

# fix(verify): a forge reference is recognised by what it is, not by one heading

## Outcome

The rule that a tracker reference ships with its merge-time automation fires for
any tracker reference, rather than only for one that copies an existing heading
byte for byte.

## Acceptance Criteria

- [ ] A new seeded forge reference with a tracker section worded differently is
      still required to declare an automation. Today the discriminator is
      `includes('## AEP in this tracker')`, so a reference heading its section
      differently is not recognised as a tracker reference at all and the
      requirement does not reach it.
- [ ] Fire-checked by adding a forge reference whose heading differs and watching
      the automation assertion fail by name, then removing it.
- [ ] Criterion 5 of `[[efforts/47-post-merge-labels/spec]]` is either met as
      written, or its wording is narrowed to what is actually enforced and the
      narrowing says why.

## Relevant areas

`src/scripts/verify.mjs`, the `seeds` section and `TRACKER_SECTION`.
`src/scripts/payload.mjs`, `forge()`.

## Notes

Raised by the correctness review of 2026-08-26, which added a `gitea` reference
headed `## AEP in the Gitea tracker`, declared it with `reference()` rather than
`forge()`, and watched the automation assertion not fire.

Ticket 05's own tick is honestly scoped: it says a reference "that carries the
tracker section". Criterion 5 in `spec.md` is broader than that, and the gap
between the two is this ticket. The mechanism was the point of requirement 5, so
a mechanism that keys on prose somebody has to copy exactly is half of one.

## Accepted, not fixed, on 2026-08-26

**`obsolete` here means nobody is going to do it under effort 47.** It does not
mean the finding was wrong, and nothing below has been disproved.

The human was given the state of the effort with these four open on the frontier,
and the two ways out: build them, or accept them and close. They chose to close
and merge. `[[skills/review]]` reserves **Accepted** to the human precisely so a
reviewer cannot dispose of its own findings, and this is that outcome exercised.
It is recorded here rather than in the run log alone, because a pull request is
about a diff and this ticket outlives it.

**The defect is still real and now has no owner.** `obsolete` satisfies the
frontier and stops the effort stalling; it creates no follow-up. Whoever wants
this fixed opens an effort for it, and the analysis above is written to be
picked up as-is.
