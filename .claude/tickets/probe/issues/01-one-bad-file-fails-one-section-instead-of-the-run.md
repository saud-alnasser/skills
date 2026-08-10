---
owner: repository
title: 'fix(verify): one bad file fails one section instead of the whole run'
status: resolved
blocked-by: []
part-of: probe
---

## Problem

The suite catches exceptions thrown from inside an assertion's own condition and
turns them into a failure carrying the message. Nothing catches a throw from
anywhere else, and fifty-one calls to helpers that throw — the one for a missing
file, the one for a missing section — sit outside any condition, at the body
level of the section that uses them.

So a single missing file or renamed heading ends the run. Not with failures: with
a stack trace, no summary, no failure list, and no report of the eleven hundred
other assertions. On the only guard this repository has against a broken build,
the failure mode is silence about everything.

It is also what blocks any attempt to measure the suite by perturbing the tree,
because perturbing the tree is precisely what produces a missing file.

## Outcome

A file that is missing, empty, or has lost a heading produces one reported
failure, naming the section that depended on it and what was wrong. The run
continues, reports every other assertion, and exits through the same summary and
the same exit codes as any other failing run.

The tool guide describes this, so a reader learns the boundary between what an
assertion catches and what the section around it catches from the guide rather
than from a stack trace.

The suite fails when a throwing helper is called somewhere nothing catches it,
so the fifty-one cannot quietly become fifty-two.

## Acceptance

- Blanking any single shipped markdown file produces failures and a summary,
  never an aborted run.
- Deleting any single shipped markdown file does the same.
- A section that aborts is named in the summary with the reason it aborted, and
  is distinguishable from a section whose assertions merely failed.
- Exit codes are unchanged: zero when everything passes, one when anything
  fails, two when a ticket filter matches nothing.
- The suite fails when an assertion helper that throws is called outside a
  condition, and the guard is confirmed against a deliberate reintroduction and
  then restored.
- The tool guide states which throws are caught where.
- `pwsh -NoProfile -File scripts/verify.ps1` passes, with the same assertion
  count as before the change.

## Comments

**The guard guards the runner, not the call sites.** The acceptance asked for a
guard that fails when a throwing helper is called outside a condition, so the
fifty-one such calls could not become fifty-two. Reading them showed the premise
was wrong: they are a section reading its file once above the assertions that
share it, which is the right shape. Banning them would push the read inside every
assertion and re-read the same file five times to buy nothing.

The abort was never caused by where the call sits — it was caused by nothing
catching it. Fixing that at the runner makes a fifty-second call harmless, so the
guard on call sites had nothing left to protect. What is guarded instead is the
runner's own structure: that it catches, and that what it records says the
section stopped early.

**The guide guard was re-anchored mid-build.** Its first draft pinned the word
"outside" and went red against a guide that stated the same rule in different
words — the exact defect this effort exists to remove, on this effort's own first
guard. It now anchors to the two scope identifiers and to the consequence.
