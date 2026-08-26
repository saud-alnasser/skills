---
status: resolved
---

# docs(specs): review's unit is the effort, not the ticket

## Outcome

The specification says the two reviewer agents judge the effort, gives review's
subject as the effort branch rather than one ticket's diff, and states the commit
rule in a form an implementation running review after its commits can satisfy.

## Acceptance Criteria

- [x] Criterion 15: eight assertions added, scoped to the section 21 heading
      block. Six perturbations by the builder, all firing. The commit rule is
      pinned by two assertions rather than one, because a diff that merely
      deletes the sentence would otherwise satisfy "no longer says MUST NOT
      commit". Independently re-checked at integration: deleting the restated
      MUST sentence gave `1995 passed, 1 failed`, restoring it gave
      `1996 passed, 0 failed`. My perturbation was narrower than the builder's
      and fired one of the two, which is consistent, since it left standing the
      clause the second assertion checks.
- [x] The stage table row now reads
      `| review | the effort's diff satisfies the defined change | findings | from implement, once at the close |`.
      The assertions parse the row into cells rather than matching a wording,
      then require `effort` and not `ticket` in the Establishes cell and `close`
      and not `ticket` in the Reached cell.

A fourth site the ticket did not name was found by reading, as instructed: the
`/implement` paragraph saying it "reviews and commits each". Left alone it would
have contradicted the review paragraph two paragraphs below it.

## Relevant areas

**All three sites are in `specs.md` section 21**, "The workflow spine", verified
by reading the section boundaries rather than trusting the numbering: section 20
runs to line 692 and section 22 begins at 728.

- the stage table row, currently
  `| review | the diff satisfies the ticket | findings | from implement, per ticket |`
- the paragraph beginning "**`review`** is a stage of `implement`, run per ticket"
- the sentence "An agent MUST NOT commit work that has failed review"

Also `src/scripts/verify.mjs`. Section 20 is ticket 02's and is not touched here,
which is what keeps the two in one wave.

## Constraints

- **The commit rule is restated, never deleted.** What it protects is that
  unjudged work does not reach a human. Under the new unit that guarantee attaches
  to the handover rather than to the commit, and the replacement has to carry it.
  A diff that drops the sentence removes a protection while looking like a
  simplification.
- Section 21's sentence about `/implement` taking the effort and reviewing each
  ticket as it goes changes in the same pass, or the specification contradicts
  itself two paragraphs apart.
- Two axes stay two. Architecture stays folded into standards.
- The specification is not shipped, so it may cite its own section numbers.
  Nothing here travels into `src/` ([[rules/authoring]]).
- Every assertion added here is seen to fail first.

## Notes

Gates 11 and 12, for the same reason ticket 02 gates its strand: `verify.mjs`
asserts the shipped surfaces against the specification.

Independent of ticket 02. The two edit different sections and can run in one wave.
