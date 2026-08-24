---
status: resolved
blocked-by: [03, 09]
---

# fix(skills): the discovery surface knows there is an eighteenth skill

## Outcome

`skills/help`'s *what do I reach for* table routes to `prose`, and
`policies/reporting`'s nested-entry sentence names all three sub-skills. A guard
asserts the first, so a nineteenth skill cannot arrive unreachable the way the
eighteenth did.

## Acceptance Criteria

- [ ] `src/skills/help.md`'s *What to reach for* table carries a `prose` row,
      phrased as a thing the reader wants rather than as the skill's name.
- [ ] `src/policies/reporting.md`'s nested-entry sentence names `tdd`, `domain`,
      and `prose`, so the enumeration is not short by one.
- [ ] `verify.mjs` asserts `skills/help` links every shipped skill but itself,
      derived from `SKILLS` rather than from a second list that would drift the
      same way.
- [ ] That guard is broken deliberately once, by removing one row, and observed
      failing while naming the skill that went missing.
- [ ] `specs.md`'s conformance list records the new claim, because a checkable
      claim the specification does not state is drift in the other direction.

## Relevant areas

`src/skills/help.md`, its *What to reach for* table. `src/policies/reporting.md`,
the *The unit is the turn* section. `src/scripts/verify.mjs`'s `skills` section,
which is where `SKILLS` is already compared against what is on disk.

## Constraints

- **The guard derives its expectation from `SKILLS`.** A second hand-written list
  of what `help` should route to is the same failure one level up: it drifts, and
  nothing catches it.
- `help` does not route to itself. A reader already holding it does not need
  telling where it is.
- This changes no requirement in `spec.md`. It closes a surface the requirements
  implied and nobody enumerated.

## Notes

Raised at ticket 08's review and again at ticket 09's, both times as *awaiting an
outcome*. The outcome is this ticket.

The reason it survived two reviews is the fourth criterion's subject: nothing in
the suite asserted anything about `help.md` at all, so an eighteenth skill could
ship, be wrapped by every adapter, be named in `specs.md`, and still be
unreachable from the surface whose whole job is answering *what do I reach for*.
