---
owner: repository
title: 'refactor(skills): attribution follows the vendored set, not every resemblance'
status: resolved
blocked-by: []
part-of: attribution
---

## Problem

Twenty-four shipped files attribute mattpocock/skills, and nineteen of them do not
have to. Those nineteen say a *structure* was derived — a two-axis review, a core
loop, a branch discipline. Copyright protects expression, not structure, and the
upstream licence binds copies and substantial portions rather than resemblance.

So nineteen lines assert a licence obligation that does not exist. That is not a
harmless surplus: it misrepresents the licence, and it teaches the next author
that any resemblance to upstream requires a notice, which is how the set grew to
twenty-four in the first place.

Five files are different. They are recorded as *vendored* — copied text — and
while that holds, substantial portions remain, the notice is required, and
removing it would strip a third party's terms from a published repository.

The suite cannot currently tell the two apart. Its broadest guard requires at
least ten attributed files, against twenty-one that carry one, so eleven could
disappear before the build noticed — and under a rule that distinguishes vendored
from derived, a count answers the wrong question entirely.

## Outcome

Attribution appears exactly where the licence requires it: on the vendored files
and in `NOTICE`. The files that merely derived a structure say so in their own
words, or say nothing, and claim no obligation.

`NOTICE` is untouched and stays in full — substantial portions still ship, so its
terms still bind.

Which files are vendored stops being a description and becomes a checked fact.
The suite pins that set by name, so vendored material arriving without
attribution fails the build, and an attribution added out of courtesy to a file
that only borrowed a shape is refused rather than accumulating.

The rule and the Constraint say the narrowed thing, in the one place each already
lives.

## Acceptance

- `NOTICE` is unchanged, and the upstream MIT terms are still reproduced in full.
- Every file recorded as vendored still attributes upstream.
- No file that merely derived a structure claims a licence obligation.
- The suite fails when a vendored file loses its attribution, and when a file
  outside the vendored set gains one — both confirmed against a deliberate
  reintroduction and then restored.
- No assertion still gates attribution on a count of files.
- The rule and the Constraint state the vendored test, each in one place, and
  neither restates the other.
- A reader of any changed file can still tell what came from upstream, where the
  prose was carrying that and the citation was not.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
