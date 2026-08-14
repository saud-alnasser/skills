---
owner: repository
title: "fix(configure): the upgrade path reaches every departed directory"
status: resolved
blocked-by: [06]
part-of: conversion
---

## Problem

The upgrade path tells a repository to install the record format into a directory that the
same release deletes. That is not a typo with a small blast radius: the record format is
what the conversion writes to and the build reads, so a repository following the instruction
either fails or ends up with the one file describing the store sitting outside it.

More broadly, the changelog holds repairs for repositories left in historical shapes, and
2.0 creates the largest shape change the framework has had — six directories leave, every
file in them becomes a record, and every script changes how it arrives. A repository
upgrading across that boundary needs each of those reached, and a surface with no
destination has to be an error naming it rather than a file quietly skipped.

## Outcome

The upgrade path converts a 1.x tree onto the 2.0 shape: every departed directory has a
destination, every script is replaced by its copy, and an interrupted run resumes rather
than duplicating. No instruction names a destination the same release removes.

## Acceptance

- Running the upgrade against a fixture 1.x tree produces a 2.0 tree with every 1.x surface
  accounted for, and a surface with no destination is an error naming it.
- Re-running after an interruption completes rather than duplicating.
- An accepted decision, a resolved ticket, and a landed spec each come through with their
  prose unchanged and one id each.
- No changelog entry names a destination that the release it is filed under deletes, and the
  build asserts this over every entry rather than the one that was wrong.
- Each entry still recognises the shape it repairs by content before acting, so an entry
  considered against a repository that never had that shape is a no-op.
