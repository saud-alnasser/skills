---
status: open
blocked-by: [01, 03]
---

# feat(skills): a skill that names an effort resolves its scope on entry

## Outcome

Every skill that operates on an effort runs `scope.mjs read` on entry, quotes it,
and acts inside what it got. The resolved claim and the isolation appear in
`Position`, so a human reading any turn can see which effort the run believed it
was in and how strong that claim was. `/specify` additionally reads the base for
a new effort branch from the repository's own rule rather than branching from
whatever `HEAD` is checked out.

## Acceptance Criteria

- [ ] `specify`, `plan`, `tasks`, `implement`, `refine`, `review`, `prune`, and
      `survey` each invoke `scope.mjs read` on entry and say what a non-empty
      claim obliges (criterion 10).
- [ ] Each states that the claim and the isolation go in `Position`, beside
      whatever that skill already verifies (criterion 10).
- [ ] `implement` states that an empty claim takes any effort, so an unscoped run
      is unchanged from today (criterion 3).
- [ ] `implement` states the mismatch behaviour it performs: clean switches, dirty
      stops naming both efforts and the uncommitted paths (criterion 6).
- [ ] `specify` reads the base of a new effort branch from
      `[[rules/version-control]]` and names both shapes, stacking and not
      (criterion 9).
- [ ] `prune` and `survey` state that they are confined like everything else and
      belong on an unscoped checkout (criterion 5).

## Relevant areas

`src/skills/` — the eight files named above. `src/skills/implement.md` step 0 is
the model for what a position line looks like, and its step 2 is where the claim
is already discussed. `src/policies/reporting.md` fixes what `Position` is for.

## Constraints

- **One entry line each.** A skill file is paid for on every invocation, so what
  goes in it is the invocation and the obligation, not the reasoning. The
  reasoning is in the policy.
- Do not duplicate the policy's text into eight files. Cite it.
- `implement` keeps its existing `position.mjs check` step. Scope is a second,
  separate invocation, and the two answers are printed together rather than
  merged.
- Wording that `verify.mjs` already pins, in `implement` and `specify`, stays
  intact. Read the assertions before editing those two.

## Notes

The set of skills is pinned by the suite in ticket 07, so a ninth acquiring a
scope read later is a failure rather than a drift. That mirrors the existing pin
on which skills invoke `position.mjs`.
