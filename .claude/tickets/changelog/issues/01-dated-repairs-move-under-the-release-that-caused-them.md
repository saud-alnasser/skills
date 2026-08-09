---
title: 'refactor(configure): dated repairs move under the release that caused them'
status: resolved
blocked-by: []
part-of: changelog
---

## Problem

Ten repairs for shapes past releases left behind are spread across two shipped
files, and not one records which release. Three are bullets in the audit list,
sitting among standing checks they are indistinguishable from. Seven are
sections in the migration page, beside conversions that fire on detection rather
than on a version.

Nothing can tell which of the ten a given repository still needs.

## Outcome

Every dated repair sits in one file, `skills/configure/migration-changelog.md`,
under the release that produced the shape it repairs. Each release says where to
look and what to fix; a release that changed only what ships says so and carries
no repair.

The audit list keeps standing checks alone — the ones true of every conforming
repository on every run. The migration page keeps conversion and the procedure
shared by any migration, and says so, so a reader who opens it looking for
catch-up finds out where that went instead of concluding it was dropped.

Nothing is retired and nothing is reworded on the way across: a repair that
moves is the same repair, so the move can be reviewed as a move.

Each release assignment cites what it was recovered from. A repair filed under a
release later than the one that caused it will never fire again on the
repositories that need it most, and it will report success while not firing.
Where the evidence is thin, the earliest plausible release wins.

## Acceptance

- All ten dated repairs appear in the changelog, each under a release.
- None remains in the audit list or in the migration page.
- Each entry states where to look and what to repair, and cites the Decision or
  effort its release was recovered from.
- A release that shipped no repair has an entry saying so, rather than being
  absent.
- The migration page states what it covers now.
- No repair's wording changed in the move, beyond what relocating it required.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
