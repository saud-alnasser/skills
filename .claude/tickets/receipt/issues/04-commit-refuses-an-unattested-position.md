---
owner: repository
title: 'feat(skills): commit refuses an unattested position, and the protocol stops overclaiming'
status: resolved
blocked-by: [01]
part-of: receipt
---

## Problem

`.claude/protocol.md` says the report "is the only evidence the discipline ran"
and that reporting "is what makes a lapse visible rather than silent." A run that
read no drift and printed a well-formed report is indistinguishable from one that
did the work, so the second sentence is false — and false in the direction nobody
checks, because an absence is the one thing a reader does not notice.

That sentence is where a reader goes to find out whether the discipline is
enforced. Describing an enforcement that was never built is worse than describing
none.

The protocol also presents the report as one block, when half of it is computable
and half is judgement. That conflation is why the whole thing reads as
unenforceable: the half that could be checked was never separated from the half
that cannot.

The commit stage is the only place the gap can close. It already confirms earlier
stages ran rather than re-running them, and it is the last point before work
becomes history.

## Outcome

The commit stage confirms the position was attested, exactly as it already
confirms the tests were run and the review has an outcome — a question about
state, answered from a file, re-executing nothing.

**The refusal is recoverable.** A missing receipt and a deleted position directory
look identical from outside, and only one is a defect, so the refusal names what
to run rather than only what is absent. A wall the caller cannot act on is the
failure this stage's existing refusals were written to avoid.

The protocol describes both halves and claims only what the mechanism delivers:
the position is attested, the healing is the stage's. Verification at use is
unchanged and is not asserted to be enforced.

## Acceptance

- The commit stage refuses when no receipt attests the current position, and
  proceeds when one does.
- Under the weaker mode the refusal weakens accordingly rather than passing
  silently.
- The refusal names the script to run, and a deleted position directory produces
  that same recoverable refusal rather than an error.
- The check re-executes nothing — it reads state, consistent with the stage's
  other confirmations.
- The protocol distinguishes the computed half from the judged half, says what the
  receipt attests, and no longer claims reporting makes a lapse visible.
- The protocol states the non-claim: the position is attested, the healing is not.
- The report examples in the stages that show one distinguish the two halves, and
  their computed half matches what the script emits.
- The suite fails when the refusal is removed, and when the protocol's corrected
  claim reverts — each confirmed against a deliberate reintroduction, then
  restored.
- Shipped text cites only what resolves where it is read.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

**The installed protocol must equal its template**, which the suite checks, so the
corrected section could not name this repository's script or its tool guide — it
names the directory the script is derived into and lets the derived guide carry
the path. The correction had to land at both ends regardless: a fix only in the
template is one this repository never applies, and one only in the installed copy
is one no other repository ever gets.

**An older guard pinned the literal word "Verification" inside the fenced example
in the implement stage.** The report's first line is now the script's, so the word
moved out of the fence while what the guard asserts — that step 0 shows a report —
stayed exactly as true. Re-anchored to the report's own lines.

**A fifth guard was found asserting less than it read.** "Every protocol states
what a receipt does not attest" searched the whole file, and a sentence about
verification at use has sat further up since the Marker gained its tree fact — so
deleting the claim under test left it green. All three protocol guards are now
scoped to the section that makes the claim.

Five in one effort, every one the same shape: a guard whose region was wider than
its claim. The pattern is worth a standard of its own — the scope of what a guard
reads and the scope of what it asserts are written in different places, and
nothing checks that they agree.
