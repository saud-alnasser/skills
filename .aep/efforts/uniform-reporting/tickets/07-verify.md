---
status: resolved
blocked-by: [01, 02, 03, 04, 05, 06]
---

# test(verify): the shipped surfaces are asserted against the report contract

## Outcome

Every checkable claim this effort adds has an assertion in `verify.mjs`, and
each one has been **observed failing** before it is trusted.

## Acceptance Criteria

- [ ] A `reporting` section asserts the policy: the four opening slots in order,
      the three closing slots, the no-empty-slot rule, the turn unit, the
      nested-entry rule, the early-stop requirement, and the two forms
      distinguished by the stage markers rather than by value length.
- [ ] **Exactly one payload artifact contains the whole label set**, and no
      `skills/*.md` does. This is the guard that keeps the contract from growing
      a second home.
- [ ] The `skills` section asserts that all seventeen declare `report:`, that
      every value is legal, and that the fourteen full-form skills are exactly
      the ones the test selects.
- [ ] For every full-form skill, stage names extract from one of the two shapes
      and the count is non-zero. **A skill matching neither shape fails**; it is
      never skipped.
- [ ] The set of skills invoking `position.mjs` is pinned by name to `commit`,
      `implement`, `install`, so a fourth is a failure. `specify` reads
      `position/marker.json` directly rather than running the script, so it is
      not in the set — pinning it there would assert something false.
- [ ] No shipped surface naming the contract contains `terminal`, `colour`,
      `color`, `ANSI`, a pixel or column width, or a runtime name.
- [ ] **Each new assertion is perturbed**: break the thing it checks, run the
      suite, confirm it fails **naming that assertion**, restore. Quote one such
      failure in the close-out.
- [ ] For the stage-name guard specifically, confirm the perturbation **removed
      the subject**: delete a bolded lead and check the failure names that skill,
      rather than firing on something that travelled with it.
- [ ] `node src/scripts/verify.mjs` passes, and the pass count rises by at least
      the number of assertions added.

## Relevant areas

`src/scripts/verify.mjs` — `section(...)` at ~77, `assert(...)` at ~89, the
`skills` section at ~386, `skill notes` at ~465, `policies` at ~495. The idiom is
`assert('<claim>', () => /<phrase>/.test(readSrc(...)))`.

## Constraints

- **A green run proves nothing until the perturbation is confirmed to have
  removed the subject** (`[[rules/authoring]]`). The recurring failure is a guard
  matching something travelling *with* the thing it checks.
- Pin phrases that carry the meaning, not incidental wording. A phrase a
  legitimate rewrite would drop makes the suite brittle for no safety.
- The stage parser is the one piece of real logic here. Keep it in the suite —
  it checks the distribution and is not needed by an installed tree.

## Notes

There is no compiler and no test runner in this repository. A claim added
without an assertion is untested by construction, not merely under-tested.
