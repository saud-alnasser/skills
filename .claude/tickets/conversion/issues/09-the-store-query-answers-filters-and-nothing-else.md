---
owner: repository
title: "feat(knowledge): the store query answers filters and nothing else"
status: resolved
blocked-by: [03]
part-of: conversion
---

## Problem

A stage receives its row and reaches nothing else, which leaves three cases with no way to
be served: a path-scoped norm on a file being read, a cross-store norm cited by id, and the
mid-turn lookup for a question the row does not settle. Without a query those are either
unanswerable or answered by reading files, which is the judged selection the row exists to
remove.

The surface has to refuse free text, and that refusal is the whole design rather than a
restriction on it: a search that found nothing is indistinguishable from a search phrased
wrong, where a filter that matched nothing is a true statement about the store.

## Outcome

One shipped script answers filters over the store's declared fields. An argument that is not
a field and a value is refused rather than interpreted. A match comes back with the closure
its declared edges reach, computed in one call, with the depth for each edge type read from
the store rather than carried in the script. A conflict comes back with both records and
their ranks rather than resolved into one.

## Acceptance

- A filter naming a field and a value returns every record carrying it, and nothing else.
- A filter for a value no record carries returns an empty result distinguishable from an
  error.
- A bare phrase is refused, naming what it expected.
- Enumerating a field's distinct values is answerable as a filter, so the vocabulary is
  discoverable from the surface rather than remembered.
- A record that supersedes another returns that other in its closure, attributed to the edge
  that reached it; raising one edge type's depth reaches further along that edge and exactly
  as far as before along every other.
- A decision and a norm in conflict come back together with their ranks and a label saying
  whether the conflict is a declared deviation or an undeclared defect.

## Declared increments

- after the query answers its first filter: does a filter-only surface actually answer the
  three cases the row excludes, or does one of them need something the surface refuses —
  type: prototype
