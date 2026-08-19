---
aep: 2.6.0
owner: repository
date: 2026-08-19
kind: ticket
status: open
part-of: readable-output
blocked-by: [01, 02, 04, 05, 06, 07, 08]
---

# test(verify): every claim this effort adds has an assertion that has been seen to fail

## Outcome

The suite judges the widened policy, the reconciliation clauses, the em dash
prohibition, and the exemption that keeps `specs.md` out of it. Each new guard
has been broken deliberately once and observed failing by name.

## Acceptance Criteria

- [ ] Guards on the widened policy: its `use-when` names more than the turn
      report; the reader test sentence is present; both worked lists are present;
      the link to `skills/prose` is present; each of the four prohibitions is
      named (criteria 1, 2, 3, 4).
- [ ] A guard over `src/**/*.mjs` fails on any em dash. Perturbation: reintroduce
      one into a comment, run the suite, confirm it fails naming that file
      (criterion 5).
- [ ] A guard over `README.md` and `CHANGELOG.md` fails on any em dash, with the
      file list **pinned rather than derived** (criterion 10).
- [ ] A guard asserts `specs.md` and `AGENTS.md` are **not** in that list. The
      perturbation is adding them and confirming the suite goes red, which proves
      the exemption is real rather than incidental (criterion 10).
- [ ] Guards on `policies/execution`: all three obligations present, each failing
      independently when removed; the seam bound present; the account clause's
      second half present, so the first-half-only version fails; the substance
      clause present, so the presentation-only version fails (criteria 11, 12,
      13, 14).
- [ ] A guard asserts `skills/implement` links the reconciliation section
      (criterion 15).
- [ ] A guard asserts nothing under `src/agents/` mentions the catalogue, so the
      version where the obligation drifted downward to children fails
      (requirement 13).
- [ ] **Every new assertion is perturbed**: break the thing it checks, run the
      suite, confirm it fails naming that assertion, restore. Quote one such
      failure in the close-out.
- [ ] For the em dash guard specifically, confirm the perturbation **removed the
      subject**. A guard that matched the word "dash" in a comment rather than the
      character would pass while the character sits in the tree.
- [ ] `node src/scripts/verify.mjs` passes apart from the stamps baseline, which
      ticket 10 clears.

## Relevant areas

`src/scripts/verify.mjs`: the `reporting` section, the `policies` section, and a
new scan over the shipped surfaces for the prohibited characters.

## Constraints

- **A green run proves nothing until the perturbation is confirmed to have
  removed the subject** (`[[rules/authoring]]`). The recurring failure here is a
  guard matching something travelling with the thing it checks.
- Pin phrases that carry meaning, not incidental wording, and use `\s+` between
  words because the payload rewraps at 80 columns.
- This ticket adds no em dashes of its own. It lands after the sweep.

## Notes

Not blocked by 03: that ticket's own criteria are checked by assertions that
already exist, the `SKILLS` comparison and the adapter staleness guard.

The `specs.md` exemption guard is the one worth the most care. It is the only
assertion here that proves a **negative**, and the only way to trust it is to add
the file to the list and watch the suite go red.
