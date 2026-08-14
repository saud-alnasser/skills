---
owner: repository
title: "feat(knowledge): the query is filters over declared fields and returns its closure"
status: resolved
blocked-by: [18]
part-of: substrate
---

## Problem

The row deliberately excludes three things: a path-scoped norm on a file being read, a
cross-store norm cited by id, and the mid-turn lookup for a question the row does not
settle. Today each is reached by loading a file and hoping the right statement is in it.

Free-text search would be judged selection wearing a different hat, and it has a worse
failure than being wrong: a caller cannot tell *nothing governs this* from *my query was
badly worded*. That distinction is invisible at the call site, and it is exactly the one
that lets a stage decide something the store already settled.

## Outcome

The store answers filters over declared fields and nothing else — no free text. A filter
that matches nothing returns an empty result that is a **true statement about the store**,
distinguishable from an error, so a caller never has to guess which happened.

A query returns the declared-edge closure of its match alongside the match, with traversal
depth declared per edge type rather than tuned globally — so the depth applied is a fact
about what that kind of edge means.

Conflicts are returned, never resolved. Both records come back with their ranks and a label
saying which kind of conflict it is: a declared deviation across stores, or an undeclared
defect within one. Applying the rank and returning a single record would suppress the
obligation that a decision-versus-norm conflict is productive.

## Acceptance

- A query for a field value no record carries returns an empty result, and that result is
  distinguishable from a failure by the caller.
- The query surface accepts no free-text input, and an attempt to pass one is refused
  rather than interpreted.
- Every norm in the store is reachable through at least one filter, asserted by the build
  rather than sampled.
- A query returns the closure of its match, and the depth applied to each edge is
  attributable to that edge's declared type.
- A conflict between a decision and a norm returns both records with their ranks and a
  label naming the conflict kind.
- Changing an edge type's declared depth changes the closure for every edge of that type
  and no others.

## Declared increments

- after the filter surface answers its first query: whether it answers all three excluded
  cases — a path-scoped norm on a covered file, a cross-store norm cited by id, and a
  mid-turn lookup — including the adversarial case where the settling norm is phrased in
  vocabulary the asker would not use — type: prototype
