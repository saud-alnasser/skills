---
owner: repository
title: "fix(skills): the primitives, the on-ramps, and the router stop naming a path"
status: open
blocked-by: [07]
part-of: addressing
---

## Problem

The skills with no router row address the corpus by path exactly as the stages do —
`codebase-design`, `domain-modeling`, `tdd`, `handoff`, `survey`, `diagnosing-bugs`,
`resolving-merge-conflicts`, and `help` between them.

They are not the same case as a stage, and treating them as one would be wrong in both
directions. A Primitive is reached from inside a running stage, so the row is already in
context and it declares no dependencies of its own; an On-ramp reaches a stage and may run
before any row has been assembled. What each may assume it already has therefore differs,
and neither can assume what a stage assumes.

## Outcome

None of these skills addresses a record by location, and each is correct about what it can
assume is already present — a Primitive composed inside a stage, an On-ramp that may run
ahead of one.

## Acceptance

- No Primitive, On-ramp, or the router skill addresses a store record by location.
- A passage in a Primitive relies on the composing stage's row rather than restating how to
  obtain a norm, since a Primitive never assembles one.
- A passage in an On-ramp that may run before a row exists says how the record is reached,
  rather than assuming delivery has happened.
- A passage that creates a context record or a decision record names the store and keeps the
  readable name that record would have had, on the same terms as `02`'s destinations.
- The router skill describes the workflow without naming a directory the release deletes.

## Blocked

Blocked on the same question as `02`, and unblocked by the same answer in `07`: a context
record and a decision record keep the readable names they would have had, in the flat store,
because the id addresses them and a rename costs nothing.
