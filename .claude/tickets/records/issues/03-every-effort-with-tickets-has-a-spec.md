---
owner: repository
title: 'fix(knowledge): every effort with tickets has a spec, and a reconstructed one says so'
status: resolved
blocked-by: []
part-of: records
---

## Problem

The design index is generated from specs, one row per effort. An effort holding
tickets and no spec produces no row, and the generation succeeds — so the index
silently spans fewer efforts than exist and nothing reports the gap.

One effort is in that state. It landed long ago, which means a spec written for it
now is a reconstruction of intent rather than a record of it. A reconstruction
that reads like a record is worse than the missing row: it invites a later reader
to trace decisions to reasoning nobody actually had.

## Outcome

Every effort holding tickets has a spec, and the design index spans all of them.

A spec written after its effort landed is identifiable as reconstruction from the
file itself — not from a commit message, which a reader of the file will not see.
The distinction is legible to someone who opens only the spec.

An effort left in the gapped state is caught by the suite rather than by the next
audit, so the index cannot quietly under-report again.

## Acceptance

- Every effort holding tickets has a spec, and the design index has a row for
  each.
- A spec written after its effort landed states in the file that it is a
  reconstruction, and a reader who opens only that file can tell.
- The reconstructed spec's content is derived from the effort's resolved tickets
  and what actually landed, and claims no reasoning that cannot be traced to one
  of those.
- The suite fails when an effort holds tickets and no spec, confirmed against a
  deliberate reintroduction and then restored.
- The suite fails when a spec predating the convention carries no reconstruction
  marker.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
