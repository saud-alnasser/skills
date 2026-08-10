---
owner: repository
title: refactor(knowledge): move this repository onto the dissolved layout
status: resolved
blocked-by: [01]
---

## Problem

This repository is configured by Tenure, so it holds its own decisions under the grouping level ticket 01 removes. Until it moves, the repository that builds the framework demonstrates the layout the framework no longer installs — and it is the worked example people read.

## Outcome

This repository's own knowledge sits at the new locations, every inbound reference resolves, and the tree here matches what `/configure` would now produce.

## Acceptance

- This repository's decision records are reachable at their new location with every number and slug unchanged.
- No file in the repository — including the README, the always-on entrypoint, and the build tickets — names a pre-change path except where it is deliberately recording the migration.
- Every Source Pointer in Context and the Domain Contexts resolves.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

**"Including the build tickets" was read narrowly, by decision.** The criterion says no file may name a pre-change path except where deliberately recording the migration; `tracker.md` says this repository's ticket history *is* the build record, and an accepted spec is frozen. Rewriting the closed tenure effort would have made it describe decisions nobody made — ticket 07 would read as having specified `.claude/evidence/research/`, which it did not. So: the spec's two live Source Pointers were repaired, its one superseded-path decision annotated in place, a note added at its top, and the nine resolved tickets left alone. This follows the treatment commit `535c9f8` already applied when the spec disagreed with a later ADR. The user chose this over rewriting everything.

**Specs did not move to `.claude/designs/`, and this is unresolved.** Shipped Tenure writes specs there; this repository keeps them at `.claude/tickets/<effort>/spec.md` per its own `tracker.md`, and ADR 0008 makes the documented convention outrank the default. Leaving them is therefore correct, but the Outcome's "matches what `/configure` would now produce" is only true on that reading, and `.claude/designs/` consequently never exists here. **Open:** settle it with a deviation note in `tracker.md` — where the `Status:` deviation is already recorded that way — or a short ADR. Not done here; `/commit` does not author, and this ticket's criteria do not mention specs.

**This effort's assertions are the first to read `.claude/`.** `verify.ps1` otherwise asserts against `./skills`. The exception is justified — this ticket's subject *is* this repository's tree — and is documented in the section header so it does not read as licence to widen the others.

**A guard covering two claims passed with one of them deleted.** The banner assertion matched text carried by the decision-1 annotation, so removing the banner left it green. Caught by deleting the banner and confirming the mutation landed before trusting the result. Now two assertions, each anchored to its own site, each proven to fail for its own cause. `.claude/rules/skills.md` was healed in the same pass: it counted prior instances of this failure, and the count had already drifted.

The four remaining `layout` tickets are unaffected — 03 and 05 touch tool references and version-control policy, neither of which this moved.
