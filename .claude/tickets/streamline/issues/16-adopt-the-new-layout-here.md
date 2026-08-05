---
title: feat(layout): move this repository onto the new layout, through the migration
status: superseded
blocked-by: [08]
part-of: streamline
superseded-by: aep/07 (ADR 0030)
---

## Problem

Every structural ticket in this effort changed what ships. This repository still runs the layout they replaced, so nothing in the effort has been exercised against a real tree — the templates describe a shape no repository has yet been born into, and the migration that converts the superseded layout has never converted one.

Part of the layout is already here — ticket 01 landed the rules split before the effort was re-ordered — and the rest is not. Adopting the remainder by hand would leave the migration doing the work only on paper.

## Outcome

**This repository's own configuration changes; nothing shipped does.**

This repository runs the new layout, and it got there by running the migration rather than by being edited into shape. Anything the migration could not do is a defect in the migration, fixed there and re-run, rather than finished by hand — a step completed manually is a step the next repository will not get.

## Acceptance

- The layout here matches what a freshly configured repository would be given, with no file from the superseded shape left behind.
- The conversion was performed by the migration, and every gap found in it was fixed in the migration and the run repeated — not completed by hand.
- The parts of the layout this repository already had are recognised as done rather than duplicated or reverted, which is the content-based recognition onboarding already claims.
- The move plan was shown before anything was touched, and what happened matches it.
- Every pointer in the repository's knowledge resolves after the move, including the ones inside files the migration did not itself rewrite.
- Re-running onboarding now reports what exists rather than duplicating it.
- Per-clone state is still per-clone: deleting every ignored file loses this clone a shortcut and loses no other clone any information.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

This ticket adopts; it does not prove. Ticket 08 owns the migration's test, against a fixture — `.claude/decisions/0026-a-fixture-tests-the-migration-and-the-revert-is-dropped.md` has why that separation matters. Still treat a failure here as a migration bug first and a repository problem second, the same disposition `.claude/decisions/0017-phase-2-closes-by-adoption-not-execution.md` sets for the workflow's own skills.

Placed before the suite is re-anchored so that re-anchoring asserts against a tree that exists rather than one that is planned.

This repository arriving at part of the layout early is not a defect to unwind. A half-adopted tree is a real state the migration should handle, and handling it is now an acceptance criterion rather than something arranged away.
