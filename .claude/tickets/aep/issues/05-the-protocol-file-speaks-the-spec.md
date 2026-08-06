---
title: refactor(configure): align the protocol file and the entrypoint with the specification
status: resolved
blocked-by: [03, 04]
part-of: aep
---

## Problem

The shipped protocol template and entrypoint template describe the machinery in the vocabulary the specification replaced. The routing table has no mode column, the entrypoint's framing predates the twelve-system model, and neither points a reader at `specs.md` as the document that defines what they are implementing.

## Outcome

The protocol template carries the full composition of spec §18 — stage → mode + policies + tool guides — and the entrypoint template frames the repository in the specification's terms. Both stay within their tiers: nothing moves into the boot tier, and the protocol file remains pointer-read.

## Acceptance

- The routing table names each stage's mode and declared dependencies, and every named file exists in the generated layout.
- The marker, the two drift reads, and the verification report survive unchanged in substance — spec §19 is Tenure's machinery kept, and this ticket must not alter what it does.
- The entrypoint template stays within its line budget and gains no unconditional rule.
- Vocabulary matches the specification: activity, stage, mode, boot tier, position — with no term defined in two places.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

This is an alignment ticket, not a redesign. Anything discovered here that the specification did not anticipate amends `specs.md` in the same change, per the evolution rule.
