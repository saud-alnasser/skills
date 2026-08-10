---
owner: repository
title: refactor(skills): compress the build spine
status: superseded
blocked-by: [09]
part-of: streamline
superseded-by: aep/09 (ADR 0030)
---

## Problem

The three stages that plan, build, and land a change carry the most prose in the framework and the most rhetorical amplification with it. Rules are stated as arguments defending themselves, which costs tokens on every invocation and invites re-evaluation of rules that would be followed anyway.

## Outcome

Planning, building, and committing say the same things in far less text. Rhetoric is gone. One clause of rationale survives only where a rule would read as arbitrary without it. Substance that belongs to a guide is pointed at rather than restated.

## Acceptance

- Every stage these three own still exists and still does what it did.
- No claim guarded by an assertion was lost, demonstrated by the suite passing rather than by review.
- Each of the three declares the guides it reads and restates none of them.
- Rationale that survives is attached to a rule that would read as arbitrary without it; rationale attached to a self-evident rule is gone.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
