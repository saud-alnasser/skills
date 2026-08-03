# 04 — feat(design): discovery surfaces drift, and the set routes protocol-only work

Status: resolved
Blocked by: 01, 03
Part of: scaffolding

## Problem

An orphan drift finding — filed when no effort was live — is dormant until something reads it, and nothing in the design stage is obliged to. And the stage that cuts ticket sets is the one place the tracker rule from 01 can actually be enforced: without a step saying so, a set with a protocol-only ticket in it ships before anything checks.

## Outcome

Shipped behaviour. The design stage's discovery step reads the drift-finding directory for unconsumed findings in the area being planned, so a waiting finding surfaces the next time anyone plans over its ground and its healing joins that run's deliverable. When the stage cuts a ticket set, protocol-only work routes to a map session or a declared increment as the tickets policy directs — the stage points at the policy rather than restating it, and a set containing a protocol-only ticket is a set-cutting error caught before anything is created.

## Acceptance

- The design stage's discovery names the drift-finding read, scoped to the area being planned.
- Its set-cutting points at the tickets policy's routing for protocol-only work and creates no protocol-only ticket.
- The stage points; the rules stay stated once, in the policies from 01 and 03.
- The suite asserts the discovery read exists and that the skill points rather than restates, with the guard confirmed to fail against a reintroduction.
- The suite passes.

Spec: ADRs 0038 and 0039 record the decisions this wiring enforces.
