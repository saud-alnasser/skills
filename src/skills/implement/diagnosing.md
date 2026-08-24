---
use-when: "a task is a bug, a regression, or a slowdown whose cause is not yet known"
---

# Implement — diagnosing before fixing

A discipline for bugs whose cause is not obvious. Skip a phase only with a stated
reason.

The whole of it rests on one claim: **the hard part is building a signal, and
everything after that is mechanical.** With a fast pass/fail check that goes red
on *this* bug, bisection and hypothesis-testing consume it and converge. Without
one, no amount of reading code substitutes — you are pattern-matching against a
model of the system, and the bug exists because that model is wrong.

## 1 — Build the loop

Spend disproportionate effort here. Be aggressive; refuse to give up early.
Roughly in order of preference:

1. **A failing test** at whatever seam reaches the bug.
2. **A request** against a running instance.
3. **A command-line invocation** with a fixture input, diffed against known-good
   output.
4. **A scripted UI drive**, asserting on what the page, console, or network
   shows.
5. **A replayed trace** — capture a real request, payload, or event log and push
   it through the path in isolation.
6. **A throwaway harness** — the smallest subset of the system that reaches the
   bug in one call.
7. **A property or fuzz loop**, when the symptom is *sometimes wrong*.
8. **A bisection harness**, when it appeared between two known states. Automate
   *boot at X, check, repeat* — including the reset — so bisection runs
   unattended. `[[references]]` has the invocations.
9. **A differential loop** — one input, two versions or two configurations,
   outputs diffed.
10. **A human in the loop.** Last resort, and still structured: a script that
    says exactly what to do and captures what came back.

**Then tighten it.** Treat the loop as the product: faster (cache setup, skip
unrelated init), sharper (assert the *symptom*, not *did not crash*), more
deterministic (pin the clock, seed the randomness, isolate the filesystem, freeze
the network). *A thirty-second flaky loop is barely better than none; a
two-second deterministic one is a different tool.*

**For an intermittent bug the goal is not a clean repro, it is a higher rate.**
Loop the trigger a hundred times, parallelise, add load, narrow the timing
window. Fifty percent is debuggable. One percent is not.

### The gate

Phase 1 is done when you can name **one command you have already run**, pasting
the invocation and its output, that is:

- **red-capable** — drives the real path and asserts the **user's exact symptom**,
  so it goes red now and green when fixed. Not *runs without erroring*;
- **deterministic** — the same verdict every run, or a pinned high rate;
- **fast** — seconds;
- **unattended**, or driven by a script that tells a human precisely what to do.

**If you catch yourself reading code to build a theory before that command
exists, stop.** Jumping to a hypothesis is the exact failure this note prevents.

Where no loop can be built, **say so and stop**: list what was tried, and ask for
the one thing that would unblock it — access to an environment that reproduces
it, a captured artifact, or permission to instrument temporarily.

## 2 — Reproduce, then minimise

Watch it go red, and confirm it is **the failure that was reported**, not a
different one living nearby. Wrong bug, wrong fix.

Then shrink to the smallest scenario still going red. Cut inputs, callers,
configuration, and steps **one at a time**, re-running after each cut. Done when
every remaining element is load-bearing — removing any one turns it green.

This is not tidiness. The minimal case is the hypothesis space in phase 3 and the
regression test in phase 5.

## 3 — Hypothesise, three to five, before testing any

Generating one at a time anchors everything on the first plausible idea.

Each must be **falsifiable** — state the prediction: *if X is the cause, then
changing Y makes it disappear.* A hypothesis with no prediction is a vibe;
sharpen it or drop it.

**Show the ranked list before testing.** Domain knowledge re-ranks it instantly
(*we deployed a change to the third one yesterday*). Do not block on it — proceed
with your own ranking if nobody answers.

## 4 — Instrument

Every probe maps to a specific prediction, and **one variable changes at a
time.**

- A debugger or REPL where the environment allows it. **One breakpoint beats ten
  logs.**
- Otherwise targeted logging at the boundaries that separate the hypotheses.
  Never *log everything and search*.
- **Tag every debug probe with a unique marker** — `DEBUG-a4f2` — so cleanup is
  one search. Untagged probes survive forever.

**A slowdown takes a different branch.** Logs are the wrong instrument. Establish
a baseline measurement — a timing harness, a profiler, a query plan — then
bisect against it. Measure first, fix second.

## 5 — Fix, with the regression test first

Write the test before the fix, **but only where a correct seam exists.** A
correct seam exercises the bug as it actually occurs at the call site; a
too-shallow test gives false confidence, which is worse than no test.

**Where no correct seam exists, that is itself the finding.** Record it: the
architecture is preventing this class of bug from being locked down, and
`[[skills/survey]]` is where it goes.

Then: minimal case → failing test → watch it fail → fix → watch it pass → re-run
the phase-1 loop against the **original, un-minimised** scenario.

## 6 — Clean up, then ask what would have prevented it

- The original repro no longer reproduces. Re-run the loop.
- The regression test passes, or the missing seam is written down.
- **Every tagged probe is gone.** Search the marker.
- Any throwaway harness is deleted — or, if it grew into a real experiment,
  `[[skills/prototype]]` has the rule.
- **The hypothesis that turned out to be right goes in the commit message**, so
  the next person to debug this area learns something.

Then ask what would have prevented it. Where the answer is architectural — no
seam, tangled callers, hidden coupling — hand it to `[[skills/survey]]` with the
specifics, **after** the fix lands. You know more now than you did at the start.
