---
owner: repository
title: "fix(skills): the rule for naming a record is stated once, and the specification stops resolving against departed directories"
status: resolved
blocked-by: []
part-of: addressing
---

## Problem

Twenty-eight shipped files are about to be reworded, and nothing says what the wording should
be. Each ticket inventing its own phrasing produces five dialects of one rule, and the
inconsistency is invisible in any single diff.

The specification cannot settle it as it stands, because it is stale in the same way its
subjects are: it resolves a skill's mode "against the modes directory" and its dependencies
"against the policies directory", neither of which survives conversion.

## Outcome

One statement of how shipped text names a record, in the repository's own standards where
the later tickets read it, and a specification that agrees with it. Nothing else in the
effort has to decide the question a second time.

## Acceptance

- The standard says what replaces a path for each of the three reference kinds — a delivered
  norm, a `reference`, and an instruction to open a file — and a reader applying it to a
  passage reaches one answer rather than a choice.
- It states why the path goes rather than moving, so a later reader cannot conclude the fix
  was cosmetic and reintroduce a corrected path.
- `specs.md` resolves a skill's mode and dependency declarations against the store, and
  names no directory the release deletes.
- The standard says `.claude/rules/` is not covered, and why — the boot tier stays files
  because the harness is the only channel reaching a clone without the plugin.
