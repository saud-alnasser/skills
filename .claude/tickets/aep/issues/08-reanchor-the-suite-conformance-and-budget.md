---
title: test(verify): re-anchor the suite to the AEP shape, close coverage, and assert the budget
status: resolved
blocked-by: [07]
part-of: aep
---

## Problem

The suite is the only test this repository has, and the compression ticket is about to rewrite most of the prose it asserts against. Its assertions cover only claims somebody chose to assert — a claim no assertion reaches can be compressed away with the suite green. And the boot budget the whole loading model defends is still a number in a spec rather than an assertion.

## Outcome

The suite asserts the AEP shape, its coverage is audited file by file before any compression, and the specification's mechanical conformance surface is asserted: boot budget, mode declarations, dependency resolution, single-home guards.

## Acceptance

- Every assertion resolves against the adopted layout, and none references a superseded path.
- Each file scheduled for compression is audited for load-bearing claims with no assertion; each gap is closed or recorded with its reason.
- A new assertion fails against a deliberate removal of its claim and passes against a reworded equivalent, confirmed rather than assumed.
- The boot tier's total is asserted against a stated ceiling; the measurement excludes what the harness strips before loading; adding an unconditional rule fails it unless the ceiling is deliberately raised.
- Every skill's mode and dependency declarations resolve, asserted mechanically.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

Absorbs streamline 09 and 14. Sits before compression for streamline's reason, which survives the reframing: compressing first leaves the suite unable to distinguish an intended rewrite from a lost claim.

Audit record at close. Re-anchoring happened in ticket 07 (fifteen assertions moved with the layout); this ticket swept what remained — one stale remedy string. The coverage audit probed the claims compression is most likely to drop: never-redesigns, the two review axes, prototype deletion, never-pushes, marker advancement, citation-on-findings, and graduation all carry concept-anchored assertions already; the one gap found was the report-when-clean rule, closed here and confirmed to fail against removal. The boot tier measures 9,206 chars as loaded (CLAUDE.md 6,373 + precedence 1,460 + engineering 1,373); the ceiling is asserted at 9,500 as a ratchet, and ticket 09 lowers it to 5,000 when compression lands. Mode and dependency declarations were already asserted by aep/03, aep/05, and streamline 06.
