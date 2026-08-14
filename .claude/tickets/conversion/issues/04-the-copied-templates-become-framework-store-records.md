---
owner: repository
title: "feat(knowledge): the copied templates become framework-store records"
status: resolved
blocked-by: [03]
part-of: conversion
---

## Problem

Fifteen files under the configuration skill are templates for an install that no longer
happens. Seven carry a reasoning posture and eight carry a workflow concern, and every one
of them was written to be copied verbatim into a repository — which 2.0 does not do. A
template with no install is not a template; it is content in a wrapper that describes a
mechanism that has been removed.

They also carry the apparatus that existed only because of copying: an owner declaration
paired with a release stamp, byte-locked to an installed copy that will never exist.

## Outcome

The framework store exists at the plugin root, beside the other shipped directories, and
holds one record per departed template. Each declares its type, and each norm declares a
firing condition from the closed vocabulary — a posture for the seven, a stage for the
eight — so what used to be carried by which directory a file sat in is carried by a field.

Every heading in the store carries a minted id. The prose each file states is preserved
statement for statement: this is a change of shape and address, never an edit of what the
framework requires.

## Acceptance

- The framework store holds one record for every template that stopped being copied, and no
  template remains for any of them.
- Every norm in the store declares a firing condition drawn from the closed set, and no
  record that is not a norm declares one.
- Every heading in the store carries a minted id, and removing one fails the build naming
  the file and the heading.
- Each converted file's norms were inventoried and numbered before the rewrite, every row of
  that inventory has a guard in the build, and each guard is checked by deleting the norm it
  names and watching it fail.
- No record in the framework store carries a release stamp or an installed-copy comparison.
- The count of norm-shaped imperatives across the store is reported, and it equals the count
  taken from the templates before conversion — a difference is a finding rather than a
  rounding.
