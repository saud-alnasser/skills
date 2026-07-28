# refactor(rules): split the rules directory and make a scoped rule actually scoped

Status: open
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
