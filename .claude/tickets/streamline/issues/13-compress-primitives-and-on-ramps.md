# refactor(skills): compress the primitives and the on-ramps

Status: superseded
Superseded by: aep/09 (ADR 0030)
Blocked by: 09
Part of: streamline

## Problem

The four primitives and the on-ramp skills carry the same rhetorical weight as the spine while being invoked more often and more incidentally — a primitive is composed by other skills, so its cost is paid inside another stage's budget rather than on its own.

## Outcome

The primitives and on-ramps are compressed on the same standard. Their attribution is untouched.

## Acceptance

- Every skill derived from the upstream project still carries its attribution, which survives the rewrite because it is a licence obligation rather than prose.
- Each primitive still supplies the vocabulary the spine composes it for.
- Every on-ramp still routes to the stage it routed to.
- The router over the whole set still names every skill that exists and none that does not.
- No claim guarded by an assertion was lost.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
