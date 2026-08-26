---
status: resolved
blocked-by: [04, 05, 06]
---

# feat(policies): the reporting table names every skill that reads position

## Outcome

`policies/reporting`'s table of what each skill puts in `Position` has a row for
every skill that invokes `position.mjs`, and a cross-check makes the two sets
impossible to separate again. The table stops being a description of what was true
when it was written.

## Acceptance Criteria

- [x] Criterion 9: rows added for `install`, `prune`, `specify` and `survey`.
      **Four, not the three this ticket named**: `install` invokes
      `position.mjs stamp` and is in the invoker set, so it needed one too. Its
      row says `*nothing to verify*: no marker exists yet, and this run writes the
      first one`, which is the honest answer rather than filler.
- [x] Two computed sets. One side is the existing `readsPosition` derivation from
      the skill files; the other is parsed out of the policy's own table. No
      literal skill list appears in the new code. Independently re-checked at
      integration by giving `plan` a position read: `no row for plan`,
      `2020 passed, 7 failed`, restored to `2023 passed, 4 failed`. Nothing was
      edited to make `plan` appear.

**The check is one-directional on purpose**, invokers subset of rows rather than
equality. `review` has a row and reads no marker, so equality would have forced it
out of the table or into a position read nobody asked for. The reason is carried
in the code.

The builder also pinned the table's existing reasoning with three assertions, so a
later edit cannot quietly turn a description of what each reader puts in the slot
into a requirement that every skill read position.

It applied ticket 03's lesson before judging its own red: it confirmed the removed
row was all that changed, checking `survey` still invoked the script, rather than
treating any failure as proof.

## Relevant areas

`src/policies/reporting.md` — the section "`Position` is filled with what the
skill already verifies", whose table currently has rows for `implement`,
`review`, and a catch-all for skills that read no repository state.
`src/scripts/verify.mjs`.

## Constraints

- The existing reason under the table survives: the slot is fixed, its content is
  not, and making every skill read position would be a behavioural change nobody
  asked for. That reasoning is what keeps this table from becoming a requirement
  that all skills read position.
- The catch-all row for a skill that reads no repository state stays. It is still
  the right answer for the skills this effort does not touch.
- Shipped text may not cite `specs.md` ([[rules/authoring]]).
- The cross-check is seen to fail first: add a `position.mjs` call to a skill with
  no row and confirm it goes red naming that skill.

## Notes

This is last among the surface changes because the set it asserts is only final
once 04, 05 and 06 have landed. Written earlier, it asserts a set that is about to
change and has to be edited twice.
