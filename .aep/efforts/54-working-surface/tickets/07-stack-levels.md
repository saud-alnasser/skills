---
status: resolved
---

# docs(rules): this repository says which branches are stack levels

## Outcome

`[[rules/version-control]]` answers, in one place, whether a ticket branch is
tracked in Graphite. All three implementers in one wave of effort 48 reached the
same question independently, and all three correctly declined and escalated.
Three agents hitting one ambiguity is an underspecified rule rather than three
cautious agents.

## Acceptance Criteria

- [x] The rule states whether a ticket branch is tracked in Graphite, in one
      place, with the reason (requirement 10, criterion 9).
- [x] It stays consistent with the existing sentence that every branch in flight
      is tracked, either by narrowing it or by confirming it covers ticket
      branches too (requirement 10, criterion 9).
- [x] It stays consistent with `blocked-by` meaning stack on top of, which the
      rule already states (requirement 10).
- [x] An implementer reading only this rule can decide without escalating
      (criterion 9).

## Relevant areas

`.aep/rules/version-control.md`, the sections "How work reaches the default
branch" and "Branches".

## Constraints

This file is this repository's own rule, not AEP payload. It ships nothing, and
an upgrade never touches it (`[[protocol]]`).

The answer is the human's to give if the rule as written genuinely does not
imply one. Record what was decided and why, rather than picking the reading that
makes the fewest edits.

Do not restate the stacking model. The rule already describes it; this adds the
one answer it is missing.

## Notes

The tension to resolve: the rule says "every branch in flight is tracked in it",
and separately that a ticket is a branch whose parent is the branch of the ticket
its `blocked-by` names. Read together those imply ticket branches are tracked.
What made three agents hesitate is that a ticket branch is also a short-lived
build claim held by a worktree, and tracking one puts a transient branch in a
stack a human merges.

Carried in this effort because it surfaced during the same run, and folded here
at the human's direction rather than split into its own effort.
