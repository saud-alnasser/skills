---
owner: repository
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

## Comments

**The recovery evidence lives here rather than in the shipped file.** Each release
assignment in `migration-changelog.md` was recovered from a record in this
repository, and a record number or a commit hash points at nothing in the
repositories that file is read in. The `citations` effort lifted the trail out
and it lands here, where every reference resolves.

| Release | Recovered from |
| --- | --- |
| 1.14.0 | the `changelog` effort itself |
| 1.13.0 | ADR 0064, which introduced the field and the hook that compares it |
| 1.11.0 | the `declared-fields` effort and ADR 0055, planned at `60e5c8d` and first released in 1.11.0 at `df3fe87` |
| 1.9.0 | the `mechanics` effort and ADR 0054, both added at `c688081`, released as 1.9.0 |
| 1.8.0 | the `worktrees` effort at `a24fffa`, "the ignore rule covers the harness's child workspaces", released as 1.8.0 |
| 1.7.0 | `7e7a461`, "the build stage dispatches sub-agents, on two axes", which added `.claude/policies/sub-agents.md`, both dispatched roles, and ADRs 0044–0046 in one release |
| 1.2.0 | `4227ce4`, "rename the framework as agentic engineering protocol", released as 1.2.0 |
| 1.0.0 | `b2e66ac`, which both renamed the framework and added `.claude/modes/`, at manifest version 1.0.0 |

Two assignments carry a judgement rather than a lookup. **1.7.0** shipped both
orchestration axes together, so the one-axis shape exists only in repositories
configured from a pre-release tree. **1.0.0** spans the rename and the arrival of
the modes directory, so both repairs are filed at the earliest release rather
than split — the earlier of two plausible releases is the safe direction, since
an over-eager repair is a no-op and a skipped one is not.
