---
owner: repository
title: "feat(knowledge): supersession is checked for symmetry, and a pointer leaves the edge list"
status: resolved
blocked-by: [03]
part-of: settlement
---

## Problem

The canonical specification requires two checks over supersession and says plainly
that the second is not implied by the first: every declared edge resolves, and the
supersession pair is additionally checked for symmetry. Resolution alone passes a
half-written supersession — a claim naming a record that exists resolves perfectly
well while that record says nothing in return. Nothing implements the symmetry
check, here or anywhere.

Two documents also list Source Pointers among the edges resolved to a record id.
Three other places state the opposite and give the reason: an edge names an id, a
pointer names a path, because a pointer targets the Codebase and the Codebase has
no ids. The two are the outlier, and a builder written from either would refuse
every pointer in the store.

## Outcome

A supersession claimed at one end and absent at the other fails the build, naming
both records and which end is missing. Pointers are described consistently as
paths in every document that describes them, and no document lists them among
edges resolved to an id. A pointer that no longer resolves is counted and named as
a figure, and the run exits zero.

## Acceptance

- A record claiming to supersede another, where that other names nothing in
  return, fails the build — naming both records and the missing end.
- The reverse case fails identically: a record claiming to be superseded by one
  that does not claim it.
- A correctly paired supersession builds.
- A supersession edge naming an id no record carries still fails as an unresolved
  edge, with its own message, so the two checks are distinguishable.
- No document lists Source Pointers among the edges resolved to a record id.
- A pointer naming a path that does not exist is counted and named, and the run
  exits zero.
- The decisions store as it stands passes the symmetry check, or every asymmetry
  it holds is reported.
- Every assertion added is confirmed to fail against a deliberate reintroduction
  of the fault it names, with the reintroduction taken from the violation rather
  than from the implementation.
