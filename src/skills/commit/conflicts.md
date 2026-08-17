---
aep: 2.3.0
owner: protocol
date: 2026-08-17
kind: skill
use-when: "a merge or rebase has stopped with conflicts that need resolving"
---

# Commit — resolving a conflict

**A conflict is two intents a text diff could not reconcile.** Recovering both
intents is the work; editing the markers out is not, and a resolution that
compiles is not evidence that either intent survived.

## 1 — See the state

Which operation is in progress, which paths conflict, and what history each side
carries. `[[references]]` has the invocations for this repository.

## 2 — Find the primary source for each side

**Why was each change made, and what was it for?** Commit messages, the task, the
effort's `spec.md`, the review that produced it.

A hunk resolved without knowing what either side wanted is a guess with a clean
diff — and it will pass review, because a resolved conflict looks the same
whether or not it kept the behaviour.

## 3 — Resolve each hunk

Preserve both intents where they can coexist. Where they genuinely cannot, take
the one matching the stated goal of the merge and **say which trade-off was
made.** A silent choice here is a behaviour change nobody reviewed, arriving
through the one place nobody looks for one.

**Never invent new behaviour.** A third option neither side wrote is not a
resolution — it is an unreviewed change in the safest possible hiding place.

**Always resolve. Never abort.** Aborting throws away the analysis and leaves the
identical conflict for the next attempt, which will be made with less context
than this one.

## 4 — Run this repository's checks

Type checks, tests, formatter — whatever it has. **A merge that builds is not a
merge that works,** and the suite is the only thing that separates them. This is
the one place `[[skills/commit]]`'s *confirm, do not repeat* does not apply: the
merge produced a tree no earlier stage ever saw.

## 5 — Finish the operation

Stage the resolved paths **by name**, then continue; on a rebase, keep going
until every commit has landed. `[[references]]` has the invocations.

Then return to `[[skills/commit]]`. A conflict resolution is part of landing the
change, not a substitute for the rest of it — the diff still has to be read
whole, and the derived state still has to be regenerated.

## What goes in the message

Where a trade-off was made, it goes in the commit message. *"Kept the retry
budget from the feature branch; the base branch's cap was superseded by the new
policy"* is the sentence that saves the next person a bisect.
