---
title: feat(configure): the design PR is the only protocol-only landing
status: resolved
blocked-by: []
part-of: scaffolding
---

## Problem

Design output — the spec, the decisions, the evidence, the resolved map sections — is protocol-only by nature, and nothing shipped says how it reaches the default branch. The maps policy's branch-bound path says each resolution "lands as its own `docs:` commit" and stops there: on what branch, through what review, is unstated, so the field improvised — and once protocol-only tracker items are banned, an unstated landing path becomes a missing one.

## Outcome

Shipped behaviour. The version-control policy names the one exception to protocol-only work riding its consumer: a pull request whose entire diff sits under the protocol directory is a **design PR** — the deliverable of a single design run, one per run, reviewable because approving it is approving the plan before anyone builds. Everything else protocol-only rides the consuming build PR. The maps policy's branch-bound path lands each session's resolutions as that session's design PR, so a multi-session effort puts resolved decisions on the default branch between sessions instead of holding them on a long-lived branch.

## Acceptance

- The shipped version-control policy states the design PR exception: entire diff under the protocol directory, one per design run, and that no other protocol-only pull request exists.
- The shipped maps policy's branch-bound landing path names the per-session design PR where it today names only a `docs:` commit.
- Both state the mechanical test as the diff, not a label or commit type.
- The suite asserts the exception is stated once, in the version-control template, with the guard confirmed to fail against a reintroduction elsewhere.
- The suite passes.

Spec: ADR 0038 records the decision and the rejected landing paths.

## Comments

Review: three judgement findings. The maps sentence carrying the cadence and ADR 0038's rationale was trimmed to the landing fact plus the pointer, and the guard gained the per-session alternation that restatement shape had evaded. The third — the diff-not-label test stated in both templates — is accepted by design, not fixed: tickets 01 and 02 each demanded the bound on their own side, and the two statements are two firing sites (tracker-side at set-cutting, PR-side at landing), per the placement rule in skill-authoring. Future reviews read this rather than re-raising it.
