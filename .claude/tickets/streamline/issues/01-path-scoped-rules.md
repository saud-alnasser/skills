# refactor(rules): split the rules directory and make a scoped rule actually scoped

Status: resolved
Blocked by: —
Part of: streamline

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

### Deliberate inconsistency, until `streamline/08`

The shipped templates under `skills/` still tell a configured repository that unconditional rules live in `CLAUDE.md`. That is this effort's sequencing — the repository adopts the layout before the templates emit it — and `streamline/08` closes it. Recorded so it is not filed as drift in the meantime.
