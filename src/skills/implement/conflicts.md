---
use-when: "a merge or rebase has stopped with conflicts that need resolving"
---

# Landing — resolving a conflict

**A conflict is two intents a text diff could not reconcile.** Recovering both is
the work; editing the markers out is not, and a resolution that compiles is not
evidence that either intent survived.

## 1 — See the state

Which operation is in progress, which paths conflict, and what history each side
carries. `[[references]]` has the invocations for this repository.

## 2 — Find the primary source for each side

Why was each change made, and what was it for? Read the commit messages, the
ticket, the effort's `spec.md`, and the review that produced it. Never resolve a
hunk without knowing what both sides wanted.

## 3 — Resolve each hunk

- Preserve both intents where they can coexist. Where they cannot, take the one
  matching the merge's stated goal and **say which trade-off was made.**
- **Never invent new behaviour.** A third option neither side wrote is not a
  resolution.
- **Always resolve. Never abort.**

## 4 — Run this repository's checks

Type checks, tests, formatter — whatever it has. **A merge that builds is not a
merge that works.** Landing's *confirm, do not repeat* does not apply here: the
merge made a tree no earlier stage saw.

## 5 — Finish

Stage the resolved paths **by name**, then continue; on a rebase, keep going
until every commit has landed. Then run `aep.mjs land` again: it finishes the
landing — the index, the commit, the release, the stamp. A resolution is part of
landing, never a substitute for the rest of it.

## What goes in the message

A trade-off goes in the commit message: *"Kept the retry budget from the feature
branch; the base branch's cap was superseded by the new policy."*
