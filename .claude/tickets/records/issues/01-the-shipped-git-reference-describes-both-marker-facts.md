---
title: 'fix(configure): the shipped git reference describes both facts the marker holds'
status: open
blocked-by: []
part-of: records
---

## Problem

The shipped git tool reference describes the marker file's contents as a single
commit, and calls that the whole file. The marker holds two facts: the commit,
and the tree fingerprint whose match licenses skipping the drift reads.

The same file contradicts itself one section later, where the fingerprint is
introduced as the marker's second fact. The protocol template and the commit
stage both describe the pair correctly, so this is the only shipped surface
carrying the old shape.

It is also the one a configured repository cannot fix for itself. A derived tool
reference is pinned to its shipped source, and a repository that corrects its own
copy fails the divergence check — so every configured repository is required to
hold the wrong sentence until the source changes.

## Outcome

A reader of the git reference learns what the marker file actually contains, and
the file stops disagreeing with itself between one section and the next. A
repository whose derived copy carries the corrected sentence passes the
divergence check, because the source it is pinned to now says the same thing.

A reader also learns what a marker holding only the commit means, since that shape
still exists in clones written before the second fact and resolves to reading the
tree rather than assuming it unchanged.

## Acceptance

- The git reference describes both facts the marker holds.
- The reference no longer contradicts its own later section.
- A derived copy carrying the corrected sentence passes the divergence check
  unchanged.
- A reader learns what a marker carrying only a commit means, and which way that
  resolves.
- The suite fails when a shipped reference describes the marker as holding one
  fact. The guard is anchored to the subject rather than to the corrected
  wording, and is confirmed to fail against the original sentence before being
  trusted.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
