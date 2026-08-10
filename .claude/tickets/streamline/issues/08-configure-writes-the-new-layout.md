---
owner: repository
title: feat(configure): the migration converts the superseded layout
status: superseded
blocked-by: [05, 06, 07]
part-of: streamline
superseded-by: layout/06 (ADR 0063)
---

## Problem

The templates now generate the new layout, so a repository configured from scratch is born correct. A repository already running Tenure is not: it sits on the shape those templates replaced, and the migration branch knows how to convert other AI workflows and Tenure's previous layout, but not this one.

Onboarding is documented as the intended way to maintain a configured repository, so a migration that does not cover the newest move makes re-running it report a repository as current when it is a layout behind.

## Outcome

**Shipped behaviour changes; this repository's own configuration does not.**

The migration gains the conversion from the layout this effort replaced, alongside the conversions it already performs. It moves files whose format is already correct, so the work is mechanical and its risk is the mechanical one: a reference left pointing where a file no longer is. Re-running it on an already-converted repository recognises the new shape rather than duplicating it.

## Acceptance

- A repository on the superseded layout is converted to the new one, and the conversion is listed in the move plan before anything is touched.
- Every reference into a moved file is repointed, including references inside files the move did not otherwise rewrite.
- Re-running onboarding on an already-converted repository reports what exists rather than duplicating it, and does not report a converted repository as needing conversion.
- Recognition is by content rather than by presence, so a file that exists but describes the superseded shape is a finding rather than a pass.
- Nothing shipped names a pre-migration path except the files whose job is detecting and converting them.
- The conversion is demonstrated against a **fixture** built from the pre-effort tree — a throwaway copy, converted and inspected — rather than against any live repository, and the fixture carries every shape the migration claims to handle rather than only the ones this repository has.
- Re-running the migration against an already-converted fixture changes nothing, so idempotence is shown rather than asserted.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

This ticket was originally the whole of onboarding's catch-up, cut when the effort ran repository-first. The template work distributed into the structural tickets that own each file, so what remains is the migration alone — a much narrower blast radius than the ticket started with.

It is still the ticket whose errors are invisible here and visible in somebody else's repository, which is why the fixture belongs to this ticket rather than to the one that adopts. A migration first exercised while converting something that matters is being debugged, not tested.

The pre-effort tree is at `087ab58`, recoverable with `git show` or a throwaway worktree. `.claude/decisions/0026-a-fixture-tests-the-migration-and-the-revert-is-dropped.md` has why the fixture beats the live tree on every axis, including repeatability and coverage.

**Superseded by the `layout` effort.** This ticket was cut when the templates
generated a layout the migration branch did not yet know how to convert. The
`layout` effort then rebuilt that surface directly, and `/configure`'s migration
now recognises the superseded shape by content — which is the outcome this
ticket was written to reach. It is left on disk rather than deleted, because a
deleted ticket loses the reason it existed; it is marked rather than left open,
because it was unblocked and the next build naming no ticket would have claimed
work already done.
