---
title: chore(skills): adopt orchestration here
status: resolved
blocked-by: [06, 07]
part-of: orchestration
---

## Problem

Everything this effort builds ships to other repositories and none of it is installed in this one. The framework's own rule is that the templates change before the repository adopts them, so adoption is a ticket rather than a side effect — and this repository is the first place the system gets used on real work, which is how the token cost gets tested before it is recommended to anyone.

## Outcome

This repository runs the orchestration system: the sub-agent policy is installed and the router reaches it, the isolation configuration is written, and the vocabulary this effort recorded is checked against what was actually built rather than against what was planned.

Whether orchestration earns a Domain Context of its own is decided here, with the built system to look at — a Domain Context earns a file when a domain has its own vocabulary, principles, or ownership, and that is a question about what exists, not about what was intended. If it earns one, the routing table gains a row and the cross-cutting vocabulary keeps only what genuinely crosses.

The remaining check is honesty about cost. This effort's own tickets are the first candidates for a declared fan-out; whichever of them could have carried one, and did not, is recorded. A system nobody declares is the risk the spec named, and this is where it is first observable.

## Acceptance

- The sub-agent policy is installed here and the router's stage table reaches it.
- The isolation configuration is written here, and a child dispatched in this repository branches from the claim.
- Every term this effort added to the vocabulary is checked against the built system, and any that describes something that was not built is corrected or removed.
- The question of a Domain Context is decided with a stated reason either way, and the routing table matches the decision.
- The observation about which of this effort's tickets could have declared a fan-out is recorded where a finding of that kind belongs.
- The migration converts a repository that has the previous layout and not this one.
- The suite passes.

## The measurement

**All eight tickets of this effort wrote `scripts/verify.ps1`** — 01 through 07 in their commits, and 08 in this one. Not "most": every single one.

The reason is broader than the authoring rule. `.claude/rules/skills.md` requires a change to `skills/` to move the suite in the same pass, but ticket 01 touched no shipped file and still moved it by 144 lines. The real cause is that `verify.ps1` is the repository's *only* test runner, so any ticket with a checkable claim — about the specification, a policy, a template, or a role — lands its guards there.

**What that means for a fan-out, stated no more strongly than it holds.** A fan-out needs portions owning disjoint files. Portions that each carry their own guards are impossible here, because every portion would write the same file. A fan-out where the *parent* writes the guards at integration is still available — the format requires portions to own disjoint files, not that every file the ticket touches be owned by a portion. So the honest claim is that the shape most people would reach for is unavailable, not that the axis is.

**And the same fact bounds a dispatched set.** Non-blocking is not non-overlapping: any two tickets here that change what ships will both write `verify.ps1`, so a collision is the expected case rather than the exception. `parallel-tickets` counts the ungated pairs; this counts the whole effort. Same fact, two views, and neither is the other's home.

## Where this was recorded, and where it was not

It is here rather than in Context. `.claude/policies/context.md` keeps constraints that "outlive the current implementation" — splitting `verify.ps1` removes this one entirely — and `.claude/policies/evidence.md` gives graduation to `/design`, not to the stage that found it. Both review axes caught it in Context on the first pass.

## The vocabulary check

All six terms this effort added were checked against what shipped, and all six hold: Orchestration and Orchestrator against `skills/implement/SKILL.md`'s dispatch subsection, Role against the four definitions in `agents/`, Brief and Change Record against `.claude/policies/sub-agents.md`, Fan-out against `.claude/policies/tickets.md`. Nothing needed correcting or removing. Two of them were **tightened** rather than corrected: Brief and Change Record listed the policy's own format, which is a second home for it.

## Still unowned

The base-check ancestry question. Ticket 05 deferred it to 06; 06's criteria never took it; 08's do not either. `parallel-tickets` dissolves it as a side effect — one branch per ticket makes the check an equality — but for the fan-out axis as shipped it is open, and it belongs to `/design`.
