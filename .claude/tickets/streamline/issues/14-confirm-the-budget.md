---
title: test(verify): assert the always-on budget and confirm the result
status: superseded
blocked-by: [10, 11, 12, 13]
part-of: streamline
superseded-by: aep/08 (ADR 0030)
---

## Problem

The budget this effort exists to defend is currently a number in a spec. Nothing stops the next change to an unconditionally-loaded file putting it back where it started, and the failure would be invisible — an entrypoint growing by a section reads as an improvement at the time.

## Outcome

The always-on load is asserted, so exceeding it fails the build. What loads unconditionally, what loads by path, and what loads by pointer is measured rather than described, and the measurement is the test.

## Acceptance

- The total of every file the harness injects without a pointer being followed is asserted against a stated ceiling, and the assertion fails when the ceiling is exceeded.
- The measurement excludes what is stripped before loading, so a maintainer note does not count against the budget.
- Adding an unconditionally-loaded rule file fails the assertion unless the budget is deliberately raised.
- Each of the effort's spec-level acceptance criteria is checked and its result recorded.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

Record the measured before-and-after in this ticket's comments when it closes.

**Measure what loads, not what is on disk.** Block-level HTML comments are stripped before injection, so a raw byte count overstates the budget. The spec's figure of 12,144 harness-injected chars is a raw count; measured the way it is loaded, the baseline before this effort was **11,074** — `CLAUDE.md` 7,726 and the authoring standards 3,348. Ticket 01 established both numbers before being partly reverted, and its comments hold the working.

This ticket runs after adoption, not after the templates change. Until this repository is on the new layout there is nothing here to measure, and measuring the templates instead would report the budget of a repository that does not exist.

