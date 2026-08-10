---
owner: repository
title: feat(configure): the tracker declares what a ticket is, and the map reads it
status: resolved
blocked-by: []
part-of: fieldwork
---

## Problem

The maps policy asserts, unconditionally, that decision tickets go on the tracker. On a repository whose version-control policy makes a ticket branch-bound — one ticket becomes one branch, one commit, one pull request — a decision produces no branch, so the assertion published seven structurally invalid issues in the field, and nothing in AEP could have caught it: no step compares the assertion against the target's own definition of a ticket.

## Outcome

Shipped behaviour. The tracker policy template carries a declared fact — what a ticket is here, branch-bound or tracked intent, citing the version-control policy it was read from — written by `/configure` at detect time and re-checked by its audit run. The maps policy places decision work by reading the declaration: branch-bound routes decisions into the design document, resolved in place with only the map itself on the tracker; tracked intent keeps decision tickets as written today. The mechanical detect test appears once, in the tracker template, as the fallback for a repository configured before this field.

## Acceptance

- The tracker policy template declares what a ticket is, with the detect test stated there and nowhere else.
- `/configure` detects and writes the declaration; its audit re-reads the version-control policy against it.
- The maps policy contains no unconditional claim that decision work goes on the tracker; it branches on the declaration, and the branch-bound branch names the design document as where decision work lives.
- The suite asserts the declaration exists in the template and that the maps policy reads it, with the guard confirmed to fail against a reintroduced unconditional assertion.
- The suite passes.

Spec: ADR 0035 records the decision and the rejected at-use routing step.

## Comments

Review: seven findings fixed in the diff — among them the field anecdote removed from the shipped policy, and the single-home guard broadened to the detect test's subject and confirmed to fire against a reworded reintroduction. The eighth — "The suite passes" against the standing `layout/04` failure — is ticketed as 08: the failure predates this ticket and closing it is `/configure` work. Acceptance met with that one recorded exception. `Status: resolved` is written at staging time rather than after `/commit` returns: a post-return edit would leave the tree dirty or force an amend the stacking gap (ticket 08) makes unsafe, and the guard's purpose — no resolved ticket without its commit — is kept by landing both in one commit.
