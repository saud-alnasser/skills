---
owner: repository
title: revert(rules): return the entrypoint to its pre-effort state, and keep the scope fix
status: obsolete
blocked-by: []
part-of: streamline
---

## Obsolete

The revert was argued for on the claim that this repository is the only superseded-layout repository the migration can be proven against, so leaving it half-migrated costs the migration its only test. That claim is wrong: the pre-effort tree is recoverable at any time — `git show 087ab58` — so the migration can be run against a throwaway copy of it.

A fixture is the better test, not merely an acceptable substitute. It is repeatable where a live repository is one-shot, it exercises every conversion path rather than only the ones this tree happens to need, and it costs no churn in a history that is this framework's build record. The same technique already produced ticket 01's empirical result.

What ticket 01 left in place is the shape ADR 0021 targets. Reverting it to re-derive it seven tickets later was cost with nothing bought. Kept rather than deleted because the reasoning is the record of a decision that was nearly taken — see `.claude/decisions/0026-a-fixture-tests-the-migration-and-the-revert-is-dropped.md`.

## Problem

The first ticket of this effort changed this repository's own configuration before the shipped templates described the new shape. The effort now runs the other way round (`.claude/decisions/0025-the-templates-change-before-the-repository-adopts-them.md`), which leaves this repository half-migrated: it carries an entrypoint split that no template emits and no migration knows how to produce.

A half-migrated tree is worse than either whole one. The migration built later in this effort has exactly one repository to prove itself against, and a before-state that is neither the old layout nor the new one is not a case it should be taught to handle.

Two changes landed together and only one of them was premature. Scoping the authoring standards fixed a defect that exists regardless of which tree leads — a rule announcing a scope the harness never enforced, when onboarding already instructs that repository-discovered rules be path-scoped. That has no shipped counterpart and no reason to move.

## Outcome

**This repository's own configuration changes; nothing shipped does.**

The entrypoint carries the precedence ladder and the engineering standards again, exactly as it did before this effort began, so the migration has a clean superseded layout to convert. The scope fix stays, along with the verification improvements that are independent of which tree leads.

## Acceptance

- The always-on entrypoint states the precedence ladder and the engineering standards itself, and no rule file duplicates them.
- Every pointer that was repointed away from the entrypoint reaches it again, and each named file states the rule it is named for.
- The authoring standards keep their machine-readable scope and still do not load outside it.
- The verification improvements that do not depend on the entrypoint split survive: the always-on set is still derived from frontmatter rather than a list, rule files are still addressed correctly when nested, a scope matching nothing still fails, and pointers in unconditionally-loaded files still resolve.
- Every assertion belonging to the reverted work is removed rather than left passing vacuously.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

Revert, not redesign. The entrypoint's content returns to what it was; it does not become a third shape invented here. `git show` against the commit before this effort is the reference for what it said.

The empirical result the first ticket produced stands and is not re-derived: `paths:` frontmatter scopes loading on the installed version, confirmed against Claude Code 2.1.220 with an `InstructionsLoaded` hook. It is recorded in that ticket's comments and the later tickets rely on it.
