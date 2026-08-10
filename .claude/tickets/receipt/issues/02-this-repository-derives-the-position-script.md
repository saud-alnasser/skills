---
owner: repository
title: 'feat(skills): this repository derives the position script from the specification'
status: resolved
blocked-by: [01]
part-of: receipt
---

## Problem

A specification with no implementation anywhere is a contract nobody has tested.
`0060`'s closing consequence binds this repository specifically: its own script is
a derived artefact like any other and must be reconcilable with the description,
rather than being the thing the description was written from.

The eight invocations the position report needs are recorded in `.claude/tools/`
and reproduced from memory at the start of every stage. A reader without the
script still needs them, so they cannot simply be replaced by a script name.

## Outcome

This repository holds its own position script beside the regenerator, derived from
the page rather than from anyone's idea of what the page meant, and producing the
fixture's expected output exactly.

The tool guide names the script for the composite read and keeps the underlying
invocations, so both readers are served: the one running the script, and the one
without it.

The suite runs the derived script against the fixture and compares. That is the
only check available — a position report is not a tracked file, so nothing can be
regenerated and compared the way an index is, and the fixture is therefore the one
check whose answer was not produced by the thing being checked.

## Acceptance

- The derived script produces the fixture's expected output exactly.
- It emits the position half only, and writes the receipt in the same run.
- Both the matching and the differing case are exercised, and all three refusals.
- The fallback path is exercised: with the run identity absent, the report and the
  receipt both say the mode was the weaker one.
- The suite runs the script against the fixture and fails when the two diverge —
  confirmed against a deliberate divergence, then restored.
- The suite fails when the mode goes unstated — confirmed against a deliberate
  removal, then restored.
- `.claude/tools/git.md` names the script for the composite read and keeps the
  underlying invocations.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

**Deriving the contract found five defects in it, which is what deriving is for.**

- **Position must be ignored, or the mechanism cannot work at all.** The fixture
  repository had no `.gitignore`, so the marker — and the receipt the script
  writes during its own run — counted toward the fingerprint being reported. The
  tree could never match the marker written from it. This is a precondition of
  the design rather than a fixture detail, and the page now says so where the
  receipt is defined.
- **The report was not portable.** The refusal lines carried `→`, and it does not
  survive a console encoding that is not UTF-8 — captured here through a
  `dos-720` codepage it arrived as `?`, in a report that still read correctly.
  Emitted output is now ASCII, stated as a rule beside the byte-order mark, whose
  argument it is one layer out. Only the fixture comparison noticed.
- **Two under-specifications.** The page never named the variable the run
  identity comes from, so a deriver could not implement the fallback; and it never
  said what a marker carrying no tree fact does. Both are now stated — the second
  takes the differing branch rather than becoming a fourth refusal, because
  unknown resolving to *read it* is the safe direction.
- **Only one of three refusals was reachable.** The fixture stopped at the absent
  marker. Cases E and F were added for a marker whose commit is gone and one that
  is not an ancestor — the pair a derivation most plausibly collapses into one,
  since both end the report and only the reasons differ.
- **`git rev-list --count` had no entry in the reference.** A configuration gap
  rather than licence to guess: verified against the command's own option list,
  then written into the derived guide and the shipped source it derives from.

**The tool guide is derived, and shared sections must match their source byte for
byte.** The script's path and language are facts about this clone, so naming it
is a new section rather than an edit to `Check the Marker` — an edit there would
have put a PowerShell path into what every other repository derives from.

**Ticket 01's "no implementation beside the contract" guard is gone.** It was true
of that ticket's diff and cannot be true of the tree, because an effort is one
commit here and this ticket amends the same one. What replaces it is the
both-directions check that page and directory agree on which scripts exist.

**The fire-check found the receipt guard vacuous.** It wrote a marker whose tree
equalled the live one, so "records what was observed" and "records what the marker
said" were indistinguishable — perturbing the script to echo the marker left it
green. It now writes a marker holding a tree the clone does not have. That is the
fourth guard in this effort caught asserting less than it read.
