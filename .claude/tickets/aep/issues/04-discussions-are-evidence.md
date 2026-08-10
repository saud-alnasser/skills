---
owner: repository
title: feat(configure): record the discussion that produced no decision
status: resolved
blocked-by: [02]
part-of: aep
---

## Problem

The interrogation of a proposal is where most durable understanding is produced, and almost none of it survives. What reaches a file is the decision — and only when there was one. A grill that weighed three approaches and parked the question exists only in a conversation that ends.

## Outcome

A configured repository records discussions as evidence, per spec §13: the problem, the questions, the assumptions, the alternatives, the tradeoffs, and — required — what stayed open. Filed as a record, never maintained. The stage that plans writes one and later promotes it when it resolves; the evidence policy states the graduation path once.

## Acceptance

- A discussion is written under evidence, and the evidence policy defines what one holds and what it never holds.
- The unresolved half is required — a discussion with nothing open says it is an unwritten decision.
- The graduation path is stated once, in the policy; no skill restates it.
- Nothing shipped implies a discussion is maintained after it is written.
- Onboarding recognizes the directory without pre-creating it, exactly as it treats the evidence directories that already exist.
- Every rule that moved has a duplication guard, confirmed against a deliberate reintroduction.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

Absorbs streamline 17 unchanged in substance; ADR 0027 settled the placement and still holds under the specification — spec §13 is that decision written as a system. This ticket does not adopt the directory here; ticket 07 does, through the migration.
