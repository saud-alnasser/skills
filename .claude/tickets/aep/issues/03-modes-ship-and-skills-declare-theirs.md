# feat(skills): ship the modes, and have every skill declare exactly one

Status: resolved
Blocked by: 02
Part of: aep

## Problem

A stage says what it produces and never what it is willing to give up to produce it. The prototype stage states that the code is thrown away and leaves every reader to infer whether tests are expected; where correctness beats speed is carried by tone throughout the spine. The specification makes this a system: a mode states the tradeoffs once, and every activity that thinks that way declares it.

## Outcome

The seven modes of spec §9 ship, each stating its priorities as tradeoffs — what it is willing to give up, not only what it wants. Every skill declares exactly one mode beside its declared policies, and no skill restates a mode's content. Two skills that think alike share the file; that is the point.

## Acceptance

- Each mode exists once, states at least one thing it gives up, and a mode that gives up nothing fails the build.
- Every shipped skill declares exactly one mode, the declaration resolves to a mode that exists, and a skill added without one fails the build.
- No skill restates a declared mode's tradeoffs; each such rule has a duplication guard confirmed to fail against a deliberate reintroduction.
- The protocol template's routing table carries the mode column, so a configured repository sees which mode each stage runs under.
- The boot budget is unchanged — modes are pointer-tier, and that is asserted rather than assumed.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

Absorbs streamline 18. The earlier rejection of a `modes/` directory was a rejection of seven modes nominally duplicating seven workflows; the resolution here is fewer modes than activities, shared. If during authoring a mode turns out to have exactly one declaring skill and no prospect of a second, fold it into that skill and amend spec §9 in the same change — that is the evolution rule working, not a failure.
