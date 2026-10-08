---
use-when: "a task is a bug, a regression, or a slowdown whose cause is not yet known"
---

# Implement — diagnosing before fixing

For a bug whose cause is not obvious. Skip a phase only with a stated reason.
**Build the signal first; everything after it is mechanical.**

## 1 — Build the loop

Spend disproportionate effort here, and do not give up early. In rough order of
preference: a failing test at the seam that reaches the bug; a request against a
running instance; a CLI run on a fixture, diffed against known-good output; a
scripted UI drive asserting on page, console, or network; a replayed trace; a
throwaway harness reaching the bug in one call; a property or fuzz loop for
*sometimes wrong*; an automated bisection (*boot at X, check, reset, repeat*,
invocations in `[[references]]`); a differential loop across two versions or
configs; and last, a human following a script that captures what came back.

**Tighten it:** faster (cache setup, skip unrelated init), sharper (assert the
symptom, not *did not crash*), deterministic (pin the clock, seed randomness,
isolate the filesystem, freeze the network). An intermittent bug needs a higher
rate, not a clean repro: loop it, parallelise, add load, narrow the timing.

**The gate.** Name one command you have already run — paste it and its output —
that is **red-capable** (drives the real path, asserts the user's exact symptom),
**deterministic** (or a pinned high rate), **fast** (seconds), and
**unattended** (or a script telling a human exactly what to do). Reading code to
build a theory before it exists: stop. No loop can be built: stop diagnosing, park
the ticket with what was tried, and put the one thing that would unblock it in
`## Needs you`.

## 2 — Reproduce, then minimise

Watch it go red, and confirm it is the reported failure, not a neighbour. Cut
inputs, callers, config, and steps **one at a time**, re-running after each,
until every remaining element is load-bearing. The minimal case is the
hypothesis space and the regression test.

## 3 — Hypothesise, three to five, before testing any

Each falsifiable: *if X is the cause, changing Y makes it disappear.* One with
no prediction is sharpened or dropped. Show the ranked list before testing;
proceed on your own ranking if nobody answers.

## 4 — Instrument

Every probe maps to a prediction; change **one variable at a time**. A debugger
where available — one breakpoint beats ten logs — otherwise logging at the
boundaries between hypotheses, never everywhere. **Tag every probe** with a
unique marker (`DEBUG-a4f2`). A slowdown takes a baseline measurement instead —
timing harness, profiler, query plan — then bisects against it.

## 5 — Fix, regression test first

Write the test first, **only where a correct seam exists** — one that exercises
the bug as it occurs at the call site. No correct seam is itself the finding:
record it for `[[skills/survey]]`. Then: minimal case → failing test → watch it
fail → fix → watch it pass → re-run the phase-1 loop on the original,
un-minimised scenario.

## 6 — Clean up

- The original repro no longer reproduces; the regression test passes, or the
  missing seam is written down.
- Every tagged probe is gone — search the marker.
- Throwaway harnesses are deleted, or `[[skills/prototype]]` governs one that
  grew.
- The hypothesis that proved right goes in the commit message.

Then, after the fix lands, hand anything architectural that would have prevented
it — no seam, tangled callers, hidden coupling — to `[[skills/survey]]`.
