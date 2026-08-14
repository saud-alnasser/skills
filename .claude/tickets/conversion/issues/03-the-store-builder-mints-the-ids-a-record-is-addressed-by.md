---
owner: repository
title: "feat(knowledge): the store builder mints the ids a record is addressed by"
status: resolved
blocked-by: [02]
part-of: conversion
---

## Problem

A record is addressed by an id, an author never writes one, and a heading carrying no id
after the build has run fails the build. Nothing in this repository builds a store, so
today that rule has no enforcer and no record can exist — every conversion that follows is
blocked on it.

The builder is also the only thing that can tell a corpus it can address from one it cannot.
Without it, a renamed heading unbinds silently, a citation naming nothing resolves by
nobody looking, and a record stating two imperatives is a defect nothing reports.

## Outcome

The builder ships, runs over a store, and mints an id for every heading that lacks one —
never rewriting one it has already written, which is what lets a guard keyed on an id
detect a norm's loss by absence rather than by a pattern somebody authored correctly.

It refuses by name: a span anchor no heading produces, a record stating more than one
imperative, a type or firing condition outside its closed set, a firing condition on
something that is not a norm, a declared edge citing an id no record carries, one id
declared twice, and a norm labelled for a stage no router row names. It reports the corpus's
instruction count, the boot tier's size, and each row's authored and generated size, and
fails on none of them.

Its ledger is per-clone and never committed.

## Acceptance

- Running the builder over a store with unlabelled headings mints an id for each, and
  running it a second time changes nothing.
- Each refusal above fires on a store seeded with exactly that fault, and the failure names
  the place — file and heading, file and value, or both files, as the fault requires.
- An empty store exits zero and reports an instruction count of zero, rather than failing:
  a repository that has not migrated yet is a true state, not a misconfiguration.
- A record nothing links to is reported and does not fail the build.
- The ledger is written to a path this repository's ignore rules already cover, and no new
  ignore entry is added.
- The build asserts each of the above against the shipped script, and each assertion is
  checked by reintroducing the fault it names.
