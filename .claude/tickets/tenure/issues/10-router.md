---
owner: repository
title: feat(skills): router over the Tenure skill set
status: resolved
blocked-by: [03, 06, 08, 09]
---

## Problem

Tenure's user-invoked skills carry no description, so nothing but the human can reach them — and the human becomes the index. `ask-matt` solves this for matt's set; Tenure needs its own, and cannot reuse that one because the inventory and the flow both changed.

## Outcome

`./skills/<router>/` — user-invoked, replacing `ask-matt`.

Names every skill and when to reach for it, organised by how work actually arrives:

- **Main flow** — `/design` → `/implement` → `/code-review` → `/commit`, with `/research` and `/prototype` as gated detours. `/design` covers spec, tickets, and the foggy multi-session map; there is nothing else to reach for while planning.
- **On-ramps** — `/triage` for incoming issues, `/diagnosing-bugs` for something broken.
- **Knowledge** — `/configure`, once per repository and re-run for the periodic audit. Verification and healing are continuous and have no command.
- **Underneath** — `grilling`, `tdd`, `codebase-design`, `domain-modeling` as the vocabulary and discipline layers.
- **Crossing sessions** — `/handoff` vs `/compact`, and why the smart zone forces the choice.

Document the tier model here too: `max(Floor, Gates)`, chosen after the grill, overridable by the user in either direction.

## Acceptance

- Every skill in `./skills` appears exactly once.
- The router explains *when* to reach for each, not what each contains.
- The router is `/tenure`, reading as "ask the tenured engineer". Spine commands stay bare (`/design`, `/implement`, `/commit`), so the name appears only here and in prose.

## Comments

**This ticket's Outcome names twelve skills; the repository has seventeen.**
`tools`, `resolving-merge-conflicts`, and `improve-codebase-architecture` are
in none of the five bullet groups, while Acceptance requires every skill to
appear. Resolved against the **spec's Scope section**, which files `tools`
under Primitives and the other two under On-ramps — so `tools` went underneath
and the two on-ramps got groups of their own. Following the bullets rather
than the acceptance criterion would have left three skills unreachable.

**"Appears exactly once" is asserted as *entries*, not mentions.** The first
version counted every occurrence of a skill's name and failed immediately: a
router cross-references constantly and has to — `/design` is named nine times
in eleven useful places. What must not happen twice is a skill **filed under
two groups**, because then the answer to "where does this belong" depends on
which group you read first.

**"Explains *when*, not what" needed a positive assertion, and it bit.** The
first check was the contrapositive only — does the router name another skill's
disclosed file — and no plausible router prose does, so it passed regardless.
The positive form requires every entry to **open** with a situation, before the
em-dash separator. It immediately failed four entries that opened with a
description, including `/configure`'s.

**Three `_Avoid_` words were in the first draft.** *"Main flow"* is on
**Spine**'s avoid list, and this ticket's own Outcome seeds it — the section is
now `## The Spine`. *"Interview"* is on **Grill**'s. *"Resynchronise"* is on
**Healing**'s, and was being used to deny such a command exists, which is still
the word the reader then goes looking for.

**The tier model is a deliberate second statement, and one clause was cut back
to one home.** This ticket says to document `max(Floor, Gates)` here; ADR 0007
says a rule has one home. Split on what would drift: the router carries the
*shape* of the decision, because a human choosing whether to type `/design`
needs it, and `verify.ps1` asserts the **Floor and Gate tables** exist in
`/design` alone. But *"and their override stands"* was near-verbatim in both —
`/design` enforces it, so the router now says what the user can do and who
takes it, with a `$rulePattern` guard on the enforcement clause.

**Two gaps came from `ask-matt` and were restored.** `/configure` was not
stated as a **precondition** — it was filed fourth, after the flow that depends
on it, and `triage` and `tdd` both hard-require files it writes. And
`/improve-codebase-architecture` had only the spare-moment trigger; matt's
router also carried the handoff from a diagnosis whose real finding is that
there was no seam to lock the bug down, and nothing in Tenure changed to
justify dropping it.

**A defect from ticket 08 was found and fixed here.** An earlier edit wrote
literal CR/LF characters into a regex where `\r?\n` was intended, so the
pattern depended on `verify.ps1`'s own line endings. Unrelated to this ticket
and recorded because it changes a resolved ticket's assertion.

**Four PowerShell defects in this ticket's own assertions**, each of which
made a check quieter than it read: `-notmatch 'x' + $y` binds tighter than the
concatenation, so the pattern was never built; `^` without `(?m)` anchored to
the section rather than each line, so only the first primitive could match;
`-ne` on an array filters instead of comparing, so the stray-home check was
correct only by accident; and a `Get-Section` heading pattern with three
alternatives could have matched a different heading than intended.

311 assertions, 35 mutations. All six harnesses re-run clean — 262 mutations.
