---
owner: repository
title: "feat(configure): the derived guides and tool references become repository-owned records"
status: resolved
blocked-by: [03]
part-of: conversion
---

## Problem

Two guides and every tool reference are derived from a repository's own facts rather than
copied, so they survive 2.0 as work the configuration stage still does. What does not
survive is where they land: each is written as a whole file into a directory the
specification says has left, so a conforming run would create directories the layout does
not name.

One of them is worse than stale. The record format itself is installed as a guide into the
departed directory, which means the file describing what a record is arrives somewhere no
record may live.

## Outcome

Derivation is unchanged — the repository's facts still go into declared fields, and its
prose still elaborates them in its own terms — and the output lands in the repository's
store as records like any other, repository-owned, addressed by minted ids.

A departure from framework law stops being a paragraph and becomes a declared edge naming
the framework record departed from, so the build resolves it and reports it on every run
until it is removed.

## Acceptance

- A configuration run produces the two derived guides, the record format, and one reference
  per tool as records in the repository's store, and creates none of the departed
  directories.
- Each derived record declares repository ownership and no release stamp.
- A repository declaring a departure from framework law does so as an edge that the build
  resolves; an edge naming nothing fails the build, and removing the edge removes the report
  with no other edit.
- The single-file test command is present in the tool references or its absence is reported
  as a configuration gap.
- The build asserts that no shipped instruction names a departed directory as a destination.
