---
name: diagnosing-bugs
description: Diagnosis loop for hard bugs and performance regressions. Use when the user says "diagnose" or "debug this", or reports something broken, throwing, failing, or slow.
---

# Diagnosing Bugs

A discipline for hard bugs. Skip a phase only with a stated reason.

Load `.claude/context.md` for the mental model, and the Domain Contexts its routing table points at for the area the bug is in. Read the ADRs in `.claude/docs/decisions/` covering that area before proposing anything that would contradict one.

## Phase 1 — Build a feedback loop

**This is the skill.** Everything after it is mechanical. With a **tight** pass/fail signal that goes red on *this* bug, you will find the cause — bisection, hypothesis-testing, and instrumentation all just consume it. Without one, no amount of reading code will save you.

Spend disproportionate effort here. Be aggressive, be creative, refuse to give up.

### Ways to build one, in roughly this order

1. **A failing test** at whatever seam reaches the bug.
2. **An HTTP call** against a running dev server.
3. **A CLI invocation** with a fixture input, diffed against a known-good snapshot.
4. **A headless browser script** driving the UI and asserting on DOM, console, or network.
5. **A replayed trace.** Save a real request, payload, or event log, and push it through the code path in isolation.
6. **A throwaway harness** — the smallest subset of the system that reaches the bug in one call.
7. **A property or fuzz loop**, when the symptom is *sometimes wrong*.
8. **A bisection harness**, when the bug appeared between two known states — automate "boot at X, check, repeat" so bisection can drive it unattended. The invocations, and the reset that has to follow, are in [`tools/git.md`](../tools/git.md).
9. **A differential loop** — same input through two versions or two configs, outputs diffed.
10. **A human in the loop.** Last resort, and still structured: a script that tells the human exactly what to click and captures what came back.

Build the right loop and the bug is most of the way fixed.

### Tighten it

Treat the loop as a product. Once *a* loop exists, make it better:

- **Faster** — cache the setup, skip unrelated init, narrow the scope.
- **Sharper** — assert the specific symptom, not *didn't crash*.
- **More deterministic** — pin the clock, seed the RNG, isolate the filesystem, freeze the network.

A thirty-second flaky loop is barely better than none. A two-second deterministic one is a different tool entirely.

### Non-deterministic bugs

The goal is not a clean repro, it is a **higher reproduction rate**. Loop the trigger a hundred times, parallelise, add stress, narrow the timing window, inject sleeps. A 50% flake is debuggable; 1% is not. Raise the rate until it is.

### When you genuinely cannot build one

Stop, and say so. List what was tried, and ask for the thing that would unblock it — access to an environment that reproduces it, a captured artifact (HAR, log dump, core dump, a recording with timestamps), or permission to instrument production temporarily.

**Do not proceed to hypothesise without a loop.**

### Completion criterion

Phase 1 is done when you can name **one command** — a script, a test invocation, a request — that you have **already run at least once**, pasting the invocation and its output, and that is:

- **Red-capable** — it drives the actual bug path and asserts the **user's exact symptom**, so it goes red now and green when fixed. Not *runs without erroring*: it must be able to catch this specific bug.
- **Deterministic** — the same verdict every run, or a pinned high reproduction rate.
- **Fast** — seconds.
- **Runnable unattended** — or, where a human genuinely has to click, driven by a script that tells them exactly what to do and captures what came back. A human in the loop is allowed; an unstructured one is not.

If you catch yourself reading code to build a theory before that command exists, **stop**. Jumping to a hypothesis is the exact failure this skill exists to prevent. No red-capable command, no Phase 2.

## Phase 2 — Reproduce, then minimise

Run the loop and watch it go red. Confirm:

- It produces the failure **the user described**, not a different one that lives nearby. Wrong bug, wrong fix.
- It reproduces across runs, or at a rate high enough to debug against.
- The exact symptom is captured, so a later phase can tell whether the fix addressed it.

Then **minimise**: shrink to the smallest scenario that still goes red. Cut inputs, callers, config, data, and steps **one at a time**, re-running after each cut.

This is not tidiness. A minimal repro shrinks the hypothesis space in Phase 3, and it becomes the regression test in Phase 5. Done when **every remaining element is load-bearing** — removing any one turns the loop green.

## Phase 3 — Hypothesise

Generate **three to five ranked hypotheses before testing any of them.** Generating one at a time anchors everything on the first plausible idea.

Each must be **falsifiable** — state the prediction:

> If X is the cause, then changing Y makes the bug disappear / changing Z makes it worse.

A hypothesis with no prediction is a vibe. Sharpen it or drop it.

**Show the ranked list before testing.** Domain knowledge re-ranks it instantly — *we deployed a change to #3 yesterday* — and rules out what has already been checked. Cheap, and it saves hours. Do not block on it; proceed with your ranking if nobody is there.

## Phase 4 — Instrument

Every probe maps to a specific prediction from Phase 3, and **one variable changes at a time**.

1. **A debugger or REPL**, where the environment allows it. One breakpoint beats ten logs.
2. **Targeted logs** at the boundaries that separate the hypotheses.
3. Never *log everything and grep*.

**Tag every debug log** with a unique prefix — `[DEBUG-a4f2]` — so cleanup is one search. Untagged logs survive forever; tagged ones die.

**Performance regressions take a different branch.** Logs are usually the wrong instrument. Establish a baseline measurement — a timing harness, a profiler, a query plan — and then bisect. Measure first, fix second.

## Phase 5 — Fix, with a regression test

Write the regression test **before the fix**, but only if there is a **correct seam** for it.

A correct seam exercises the **real bug pattern as it occurs at the call site**. A seam that is too shallow — a single-caller test for a bug that needs several, a unit test that cannot reproduce the chain that triggered it — gives false confidence, which is worse than no test.

**If no correct seam exists, that is itself the finding.** Record it: the architecture is preventing this bug from being locked down.

Where a seam does exist: turn the minimised repro into a failing test there, watch it fail, apply the fix, watch it pass, then re-run the Phase 1 loop against the original un-minimised scenario.

## Phase 6 — Clean up, then ask what would have prevented it

Before declaring it done:

- The original repro no longer reproduces — re-run the Phase 1 loop.
- The regression test passes, or the absence of a seam is written down.
- Every `[DEBUG-…]` probe is gone. Search the prefix.
- Any throwaway harness is deleted. `prototype` has the rule if one grew into a real experiment.
- **The hypothesis that turned out to be right is in the commit message**, so the next person to debug this area learns something.

**Then ask what would have prevented this bug.** If the answer is architectural — no good seam, tangled callers, hidden coupling — hand it to `survey` with the specifics. Make that recommendation **after** the fix lands, not before: you know more now than you did at the start, and a recommendation made early is a recommendation made from the theory you began with.

---

Derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for Tenure.
