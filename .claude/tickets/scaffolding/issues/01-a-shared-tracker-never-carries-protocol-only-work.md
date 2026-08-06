---
title: feat(configure): a shared tracker never carries protocol-only work
status: resolved
blocked-by: []
part-of: scaffolding
---

## Problem

The shipped tickets policy tests a ticket by whether it produces a branch (ADR 0035) and whether closing it produces something observable — and work whose whole effect is under the protocol directory passes both. In the field that filled a shared tracker's top level with the agent's own bookkeeping: measurement and transcription tickets whose acceptance says no file outside the protocol directory moves, on a surface read by teammates who do not run the protocol.

## Outcome

Shipped behaviour. The tickets policy states the rule: a ticket the workflow creates on a shared tracker must state an outcome outside the protocol directory. Protocol-only work is consumed, never tracked — evidence gating a map decision is produced by the map session that needs it; evidence gating a build is a declared increment on the consuming build ticket. The policy says which route applies when, and that the rule binds only what the workflow creates on a shared tracker — humans file what they like, and a local-markdown tracker is out of the rule's reach by construction.

## Acceptance

- The shipped tickets policy states that a workflow-created ticket on a shared tracker has an outcome outside the protocol directory.
- It routes protocol-only work by its consumer: a map session for decision-gating evidence, a declared increment for build-gating evidence.
- It states the two bounds: workflow-created on a shared tracker only, and the diff — never the commit type — is what the rule reads.
- The suite asserts the rule exists in the template, with the guard confirmed to fail against a reintroduction.
- The suite passes.

Spec: ADR 0038 records the decision and the rejected alternatives.
