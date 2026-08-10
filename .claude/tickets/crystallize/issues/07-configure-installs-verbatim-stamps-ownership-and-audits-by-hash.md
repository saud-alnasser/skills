---
owner: repository
title: "feat(configure): the fixed core installs verbatim, ownership is stamped, and the audit compares by hash"
status: resolved
blocked-by: [02, 03, 04, 05]
part-of: crystallize
---

## Problem

`/configure` derives whole policy files per repository, which is what made every
installed file mutable and framework law negotiable. Its audit compares derived
prose to templates by judgement, and nothing installs, stamps, or checks an
ownership boundary because none exists.

## Outcome

`/configure` installs framework-owned files verbatim with their owner and
release stamp, writes repository facts only into the extension forms the
policies name, and records any variation with no point to enter through as a
declared deviation. The audit compares framework-owned files byte-for-byte
against the release — a mismatch is a defect to reinstall, never drift to heal
— and surfaces every deviation on every run. The upgrade path replaces
framework-owned files verbatim and leaves extensions untouched. What
`/configure` writes outside the protocol directory is asserted as the bound ADR
0076 states, not a count.

## Acceptance

- After a fresh configure, every installed instruction file declares its owner,
  and repository facts exist only in extensions.
- Editing one byte of a framework-owned file makes the next audit name that
  file as defective; healing language is never applied to it.
- A deviation appears in every audit output until removed, with its reason and
  the release it was declared under; the audit computes its age, and one
  release without a disposition fails the run.
- Every extension point the installed policies name traces to a row in the
  variation census — the observed diff between templates and installed copies
  plus the specification's per-repository facts — and the census is committed
  as evidence.
- An upgrade run changes framework-owned files only, verbatim to the new
  release, and no extension or deviation is lost.
- The migration converts a repository on the previous layout without losing any
  repository fact, and the configure-writes drift finding is marked consumed,
  naming ADR 0076.
