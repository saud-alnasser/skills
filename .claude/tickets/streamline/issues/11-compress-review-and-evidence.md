---
owner: repository
title: refactor(skills): compress the review and evidence stages
status: superseded
blocked-by: [09]
part-of: streamline
superseded-by: aep/09 (ADR 0030)
---

## Problem

The review stage and the two evidence stages carry the same rhetorical weight as the build spine, and the evidence stages additionally restate how findings graduate into knowledge — which is now a guide's subject rather than theirs.

## Outcome

Reviewing, researching, and prototyping say the same things in far less text, and point at the evidence guide rather than restating how a finding becomes knowledge. Their behind-pointer files are compressed on the same standard.

## Acceptance

- Both review axes survive, and the standard each checks against is unchanged.
- Throwaway prototype code is still always deleted, and the write-up is still kept.
- How a finding graduates into knowledge is stated in the guide and in none of these three.
- No claim guarded by an assertion was lost.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
