# feat(layout): move this repository onto the AEP shape, through the migration

Status: resolved
Blocked by: 06
Part of: aep

## Problem

Every structural ticket so far changed what ships. This repository still runs the layout they replaced, so the templates describe a shape no repository has been born into and the newest conversion has never converted a live tree.

## Outcome

**This repository's own configuration changes; nothing shipped does.**

This repository runs the specification's layout, and it got there by running the migration. Anything the migration could not do is a defect in the migration, fixed there and re-run — a step completed by hand is a step the next repository will not get.

## Acceptance

- The layout here matches what a freshly configured repository would be given, with no file from the superseded shape left behind.
- The parts already conforming — the rules split, the policies directory, the context split — are recognized as done rather than duplicated or reverted.
- The move plan was shown before anything was touched, and what happened matches it.
- Every pointer in the repository's knowledge resolves after the move, including inside files the migration did not itself rewrite.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

Absorbs streamline 16, with the same placement logic: adoption precedes the suite re-anchor so the suite is anchored to a tree that exists rather than one that is planned.
