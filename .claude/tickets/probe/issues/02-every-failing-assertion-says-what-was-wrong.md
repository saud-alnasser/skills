---
title: 'fix(verify): every failing assertion says what was wrong'
status: resolved
blocked-by: []
part-of: probe
---

## Problem

An assertion explains itself by throwing: the message becomes the failure's
detail, and a reader of the summary learns what was actually wrong. An assertion
that returns a bare boolean instead produces a failure with the assertion's own
name and nothing else — the reader is told which claim broke and given no way to
find out how.

A hundred and thirty-two assertions do this. The tool guide already forbids it in
as many words, which makes the count a measure of how much an unenforced
prohibition is worth.

The cost lands at exactly the wrong moment. A failing build is when somebody is
already looking for the cause, and one in nine of these assertions answers by
restating the question.

## Outcome

Every assertion that can fail states what was wrong when it does. A reader of a
failure list can act on it without opening the script.

The suite asserts this over itself, so the category cannot regrow. That guard is
the one place in the suite whose subject is the suite, and it says so.

## Acceptance

- No assertion in the suite can fail without producing a detail message.
- Each repaired assertion's message names the specific thing that was wrong, not
  a restatement of the assertion's own name.
- The suite fails when an assertion with no explanation is added, and the guard
  is confirmed against a deliberate reintroduction and then restored.
- The guard does not match its own text — confirmed, since a self-matching guard
  passes forever and has happened here before.
- No assertion changed what it claims; only how it reports failing.
- `pwsh -NoProfile -File scripts/verify.ps1` passes, with the same assertion
  count as before the change.

## Comments

**A hundred and twenty, not a hundred and thirty-two.** The count in the problem
came from asking which conditions contain no `throw`. Twelve of those explain
themselves anyway: they end in a literal `$true`, so they cannot return false at
all, and their only failure is an exception raised by a helper that carries its
own message. The first draft of the guard called those silent and would have
"repaired" twelve assertions that were already correct.

**The repair wrapped each condition rather than inverting it.** `-not (EXPR)`
coerces exactly as the assertion helper already did, so pass and fail are
unchanged and only the detail is added. Flipping `-match` to `-notmatch` would
not have been equivalent: on an array those return matching and non-matching
elements, so the flipped form is true whenever any element fails rather than when
all do. Preservation was then checked rather than argued — every one of the 120
conditions still contains its original expression verbatim, and the call-site
count is identical either side.
