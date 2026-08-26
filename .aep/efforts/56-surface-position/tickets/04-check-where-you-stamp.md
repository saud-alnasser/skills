---
status: resolved
blocked-by: [02]
---

# feat(implement): the position check happens in the surface the run will stamp

## Outcome

`/implement` reads the marker of the surface it entered rather than the marker of
the checkout it was invoked in. Its check and its stamp address one file, so the
drift answer it quotes in `Position` describes the tree it is about to work in.

## Acceptance Criteria

- [x] Criterion 4: the check moved to step 2 under `Check the marker, in the
      surface you just entered`. The assertion compares document positions:
      `scope < enter < check`. Measured at integration on the landed file:
      scope 1082, enter 5651, check 6660, stamp 14671. It pins the document's
      order, not a runtime behaviour, because a `worktree` run takes no second
      surface and the two orderings are invisible to it.
- [x] The scope read stays at step 0, and the assertion pins it from **both**
      sides rather than leaving it merely unmoved: `scope > enter` fails with
      "the scope read no longer precedes the surface it decides".

The builder wrote the guard **before** the document edit and ran it against the
defective order: `the marker is checked before the surface it stamps is entered`,
`1996 passed, 1 failed`. That is the strongest form of seen-to-fail-first, since
the subject was the real defect rather than a reintroduced one.

## Relevant areas

`src/skills/implement.md` — step 0 ("Position. Every invocation."), step 2
("Claim it"), and step 6's stamp. `src/scripts/verify.mjs` — the assertions near
`skills/implement fills Position from the position script`.

## Constraints

- **Splitting step 0 is expected.** The scope read establishes the isolation,
  which decides whether a surface is taken; the marker check has to follow the
  surface. Say why the two halves sit where they do, or the next reader merges
  them back.
- `Nothing to report is still reported` and the sentence about a marker match
  licensing only the drift read both survive. There are assertions on them.
- The stamp at step 6 does not move.
- Shipped text may not cite `specs.md` ([[rules/authoring]]).
- The ordering assertion is seen to fail first, against a version with the steps
  in their current order.

## Notes

A run invoked in a surface the runtime supplied takes no second surface, so for it
the two orderings are identical. The assertion has to pin the document's order
rather than a runtime behaviour, because the failing case is the `checkout` one.
