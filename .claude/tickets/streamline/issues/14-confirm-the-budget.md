# test(verify): assert the always-on budget and confirm the result

Status: open
Blocked by: 10, 11, 12, 13
Part of: streamline

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

Record the measured before-and-after in this ticket's comments when it closes. The baseline is 20,581 chars across three files, of which 12,144 are harness-injected and 8,437 are loaded because the entrypoint instructs it.
