---
status: resolved
blocked-by: [02]
---

# feat(skills): prune and survey check the marker on entry and stamp it at close

## Outcome

The two skills that live in the main checkout treat it as a surface like any
other: they check its marker on entry beside the scope read they already do, and
stamp it at close. The main checkout's marker stops being a file `/install` writes
once and nothing ever reads.

## Acceptance Criteria

- [x] Criterion 6: the set is
      `['implement', 'install', 'prune', 'specify', 'survey']`, reconciled at
      integration from this ticket's four and ticket 05's three. The comment
      gives a reason per member. Merging it exposed a defect neither child could
      see: this ticket's closing line read "the last two stamp", which after
      inserting `specify` alphabetically would have named `specify` and `survey`,
      and `specify` stamps nothing. `prune` and `survey` are now named outright,
      with `specify` called out as the exception that proves the rule.
- [x] Criterion 6: `prune's stamp leaves a marker for the tree it read`. The
      fixture pulls the two commands out of `prune.md`'s own text rather than
      hard-coding them, and deletes a tracked file **without committing**, which
      is what separates the tree prune read from any tree it could have
      committed.
- [x] Both fill `Position` and neither gained a report. The existing assertions
      `each of the eight puts the claim and the isolation in Position` and
      `no shipped artifact declares a report form` both still pass, and the diffs
      touch only `## Procedure`.

The builder's fourth perturbation is the one that mattered: it fire-checked the
**fixture** rather than the text assertions, by making `stamp` write a reversed
head. That removed the fixture's actual subject, and it failed with
`marker head df9d623f... is not the tree prune read, c3abffe4...`.

## Relevant areas

`src/skills/prune.md` — step 1, which already runs `scope.mjs read` and
`validate.mjs` and already fills `Position`. `src/skills/survey.md` — step 1,
same shape. `src/scripts/verify.mjs` — the invoker-set assertion and its comment.

## Constraints

- **They stamp because the marker records the tree a run read, not the tree it
  committed.** That reasoning is `position.mjs`'s own header and it is what
  settled the question; a diff that makes them check without stamping contradicts
  requirement 6.
- Neither skill gains a report. Both already open one and both already fill
  `Position`; this is one more thing in a slot that exists.
- `/domain` is deliberately not in this ticket. It is a stage and a stage opens no
  report. See the spec's Out of Scope.
- Shipped text may not cite `specs.md` ([[rules/authoring]]).
- The invoker-set assertion is **rewritten to the new set, never loosened**. A
  subset test or a deleted assertion removes the check that made this problem
  visible, and it is listed as a technical risk in
  [[efforts/56-surface-position/plan]].

## Notes

Ticket 05 also edits the invoker-set assertion. See its Notes for how a collision
resolves.
