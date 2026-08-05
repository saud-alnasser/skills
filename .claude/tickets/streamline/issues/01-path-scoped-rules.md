---
title: refactor(rules): split the rules directory and make a scoped rule actually scoped
status: resolved
blocked-by: []
part-of: streamline
---

## Problem

A rule that applies to part of the tree announces its scope in prose and is loaded everywhere anyway. The authoring standards file states it applies to the skills tree, then costs 3,405 chars on every turn — including turns that never open that tree. Claude Code supports frontmatter that makes such a scope mechanical, and the file has no frontmatter at all.

Separately, the engineering standards that must fire unconditionally live in the always-on entrypoint, which is the file this effort needs to empty.

## Outcome

Rules are placed by loading mechanism. Standards that fire unconditionally live in their own rule files and load on every turn. A standard owned by part of the tree carries path frontmatter and loads only when Claude reads a file it covers. The scope of every rule is enforced by the harness rather than honoured by Claude.

## Acceptance

- A rule scoped to part of the tree does not appear in context when Claude works outside that scope, confirmed by the mechanism that logs which instruction files loaded and why — not by inspection.
- The engineering standards and the precedence ladder each load unconditionally and each state their subject once.
- No standard is stated both in a rule file and in the always-on entrypoint.
- The scope of each rule is machine-readable; no rule relies on prose to describe where it applies.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

Confirm the scoping empirically before trusting it. The documented behaviour around path frontmatter has changed across several recent releases, and this ticket is the one that finds out whether it works on the installed version rather than assuming from the reference.

### Confirmed, on Claude Code 2.1.220

Measured with an `InstructionsLoaded` hook over a throwaway fixture, dumping each event to a log. The installed version is past every version caveat the reference records for this feature.

| Claude reads | unscoped rule | scoped rule |
| --- | --- | --- |
| a file no glob covers | `session_start` | *absent* |
| `src/app.ts` against `src/**/*.ts` | `session_start` | `path_glob_match` |
| `skills/design/SKILL.md` against `skills/**` | `session_start` | `path_glob_match` |
| `scripts/verify.ps1` against the bare path | `session_start` | `path_glob_match` |

Both glob forms this repository now depends on were confirmed individually, rather than inferring `skills/**` from the reference's `src/**/*.ts` example. A scope that matches nothing is the failure mode with no symptom — the rule silently never fires and the frontmatter still reads as correct — so `verify.ps1` also resolves every declared glob against the tree.

### Budget

Harness-injected, block-level HTML comments stripped because those never reach context:

| | before | after |
| --- | --- | --- |
| `CLAUDE.md` | 7,726 | 6,120 |
| `.claude/rules/precedence.md` | — | 1,321 |
| `.claude/rules/engineering.md` | — | 1,373 |
| `.claude/rules/skills.md` | 3,348 | *conditional* |
| **always-on total** | **11,074** | **8,814** |

The spec's baseline of 12,144 for this set is a raw byte count; stripping comments first puts the true always-on baseline at 11,074. `streamline/14` should measure the ceiling the same way it is loaded, which its second criterion already requires.

### This landed before the effort was re-ordered, and it stands

Recorded here rather than by editing the work above, because this ticket is the build record of what actually happened.

The effort was re-cut ship-first afterwards (`.claude/decisions/0025-the-templates-change-before-the-repository-adopts-them.md`), which briefly implied reverting the entrypoint split so the migration would have a clean superseded layout to convert. That revert was cut as ticket 15 and then dropped: the pre-effort tree is recoverable from history, so the migration is tested against a fixture instead, which is repeatable and covers more than this tree ever would. `.claude/decisions/0026-a-fixture-tests-the-migration-and-the-revert-is-dropped.md` has the reasoning.

So nothing here is unwound:

- **The entrypoint split stands.** It is the shape ADR 0021 targets, reached early rather than wrongly. Ticket 02 makes the template emit it; ticket 16 recognises it as already done rather than duplicating it.
- **The scope fix stands.** The authoring standards are a rule about building Tenure itself and exist in no other repository, so there is nothing to ship. Onboarding already instructs that repository-discovered rules be path-scoped; this repository was not following its own shipped instruction. That was a defect here regardless of which tree leads.
- **The empirical result stands.** The table above is the confirmation later tickets rely on — and the fixture technique it used is the one ticket 08 now adopts for the migration.
- **The verification work stands**, including the assertions about the split.

What this ticket got wrong was only its *position* in the effort, and position is not something a landed change has to carry.
