---
aep: 2.6.0
owner: repository
date: 2026-08-19
kind: ticket
status: open
part-of: readable-output
blocked-by: [03]
---

# refactor(scripts): the shipped scripts lose their em dashes

## Outcome

No em dash appears anywhere in `src/**/*.mjs`. Comments and strings printed to a
human are rewritten; the one legitimate use, the index's empty-cell placeholder,
becomes a named constant written as a Unicode escape, so no exemption is needed
and the guard in ticket 09 can be a flat scan.

## Acceptance Criteria

- [ ] Counting the em dash character over `src/**/*.mjs` returns zero
      (criterion 5).
- [ ] `index.mjs`'s three placeholder literals become one named constant declared
      as a Unicode escape, with a comment saying why the escape is used rather
      than the character.
- [ ] `node .aep/scripts/index.mjs` regenerates an `index.md` byte-identical to
      the one before this ticket. The placeholder's rendered output does not
      change.
- [ ] Every rewritten sentence still says what it said. Where a dash was carrying
      a clause, the sentence ends or takes a comma; parentheses and en dashes are
      not substitutes (requirement 4).
- [ ] `node src/scripts/verify.mjs` passes at least as many assertions as before
      this ticket. A rewritten comment that changed a phrase another assertion
      pins is a defect in this ticket, not in that assertion.
- [ ] `node .aep/scripts/validate.mjs` and the install fixture still pass.

## Relevant areas

Ten files hold them, measured at `92cca17`: `verify.mjs` 54 lines,
`validate.mjs` 23, `adapters.mjs` 21, `install.mjs` 20, `payload.mjs` 16,
`index.mjs` 12, `position.mjs` 7, `contract.mjs` 6, `release.mjs` 4, and
`adapters/claude/hooks/check-version.mjs` 5. Roughly 93 of the 168 lines are
comments and the rest are strings a human reads.

## Constraints

- **This is a rewrite, not a deletion.** A sentence that loses its dash and its
  meaning together has failed.
- Several of these files are pinned by assertions elsewhere in the suite. Phrases
  are pinned with `\s+` between words, so reflowing is safe and rewording is not.
  Check the suite after each file rather than at the end.
- The placeholder stays an em dash in the rendered `index.md`. That output is
  artifact prose an agent reads, and requirement 2 exempts it.

## Notes

Blocked by 03 because that ticket is the only other one editing `contract.mjs`,
and two agents editing one file is the collision the task graph exists to
prevent. Everything landing after this ticket is written without em dashes from
the start.
