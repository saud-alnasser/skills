---
owner: repository
status: implemented
sources:
  - NOTICE
  - skills/
  - agents/
  - .claude/rules/skills.md
  - .claude/contexts/repository.md
  - scripts/verify.ps1
  - .claude/decisions/0066-attribution-rides-vendored-material-not-derived-structure.md
---

# refactor(skills): attribution follows the vendored set, not every resemblance

## Problem

Twenty-four shipped files attribute mattpocock/skills. Five are recorded as
*vendored* — copied text. The other nineteen say a *structure* was derived: a
two-axis review, a core loop, a branch discipline.

Copyright protects expression rather than structure, and the upstream licence is
MIT, whose condition binds copies and substantial portions rather than
resemblance. So nineteen of those lines assert an obligation that does not exist.
That is not harmless surplus — it misstates the licence, and it teaches the next
author that resembling upstream requires a notice, which is how twenty-four
accumulated.

The suite cannot tell the two apart. Its broadest guard requires at least ten
attributed files against twenty-one that carry one, so eleven could vanish before
the build noticed; under a rule that distinguishes vendored from derived, a count
answers the wrong question anyway.

## Goal

Attribution appears exactly where the licence requires it, and the requirement is
checked rather than described.

## Constraints

- **`NOTICE` is untouched.** Five files are vendored, so substantial portions
  still ship and the upstream MIT terms still bind. Removing it would strip a
  third party's required notice from a published repository.
- **Every vendored file keeps its attribution**, and that set is named rather
  than inferred from a resemblance judgement.
- **Nothing is reworded beyond removing the claim.** Where the line was carrying
  provenance the surrounding prose does not state, the provenance stays — in the
  file's own words, claiming nothing about the licence.

## Architecture

**One test: was text copied, or was a shape borrowed?** Copied text is vendored
and attributed. A borrowed shape is neither, however strong the resemblance.

That test is already recorded per file, in the word each attribution uses —
"vendored" against "derived" — so the partition exists and needs reading rather
than inventing.

The rule lives in `.claude/rules/skills.md`, already scoped to the shipped
surfaces, and the Constraint it narrows lives in `.claude/contexts/repository.md`.
Each states the vendored test once; neither restates the other.

**The vendored set becomes a checked fact rather than a description**, because it
now decides whether a licence notice is required. The suite pins it by name, so
vendored material without attribution fails, and an attribution added out of
courtesy to a file that only borrowed a shape fails too — the second direction is
what stops the set regrowing.

## Approach

The rule and the Constraint move first, so the sweep has something to be checked
against rather than the other way round.

The suite's existing attribution guards were written against the wider set and
several become wrong rather than merely loose. They are replaced by pinning the
set, which is why the count-based guard goes rather than being tightened.

The reasoning is `.claude/decisions/0066`'s and is not restated here.

## Acceptance criteria

- `NOTICE` is unchanged and reproduces the upstream terms in full.
- Every vendored file still attributes upstream; no other shipped file does.
- The suite fails both when a vendored file loses attribution and when a
  non-vendored file gains one, each confirmed against a deliberate reintroduction.
- No assertion gates attribution on a count of files.
- The rule and the Constraint each state the vendored test once.
- No file lost provenance a citation was carrying.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Risks

- **A file is vendored and not marked as such**, so the sweep strips a notice the
  licence required. This is the one failure with consequences outside the
  repository. Detected by treating the recorded word as the partition and
  changing no file's classification during the sweep; a reclassification is a
  separate decision, not a step in a removal pass.
- **A removed line was the only statement of where something came from.** The
  prose still reads well without it, which is what makes the loss silent.
  Mitigated by reading each sentence without the citation before accepting it.
- **The pinned set is a second home for a fact the files already carry**, and the
  two drift. Bounded by pinning names only, and by the guard failing in both
  directions so a divergence cannot sit green.

## Out of scope

- **Rewriting the five vendored files** so nothing substantial remains. That
  would end the obligation altogether and is a content decision about five
  shipped skills, not a licensing one. `0066` records it as available later.
- **`LICENSE`.** It is this repository's own Apache-2.0 grant and is unrelated.
- **Upstream references that are navigation rather than attribution.**
