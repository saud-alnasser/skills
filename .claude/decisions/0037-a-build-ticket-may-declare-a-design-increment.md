---
status: accepted
load-when: a plan meets a decision only partial code can answer
sources: [.claude/policies/tickets.md]
supersedes: []
superseded-by: []
---

# A build ticket may declare a design increment

Amends `specs.md` §10 (version 1.2.0 → 1.3.0). Some decisions are answerable only once partial code exists — whether a surface reads as raised needs real rows; locale behaviour needs a populated table — and the workflow's phase split forced them into a guess recorded as settled or an unplanned `blocked` hand-back. We decided a build ticket MAY declare, **at design time only**, a *design increment*: the step, the question, and the type. `/implement` resolves AFK types (`research`, `task`) inline where the fact becomes measurable, and stops at HITL types (`grilling`, `prototype`) holding the claim — a scheduled session rather than an ambush, and not `blocked`, because the plan is right and only the human is absent. The map's exit condition relaxes to *every remaining decision settled or declared as a scoped increment*, which is what lets a map finish honestly.

## Considered Options

Cutting ticket boundaries at decision points — build up to the answerable moment, decide, build on — keeps `/implement` fully decision-free but forces boundaries by decision rather than by demoable slice and turns every inline-resolvable fact into a full ticket cycle. Leaving the status quo keeps the two bad options the field run hit: silent architecture inside a build commit, or a lost run.

## Consequences

The load-bearing part is the guardrail, shipped in the same edit as the mechanism: `/implement` may never invent an increment, and an undeclared decision is still `blocked`, exactly as before — without this, declared increments are a scope-creep vector. The value is predictability, not a new control-flow path: for HITL types, "invoke `/design`" and "stop for the human" are the same event, but a declared stop can be scheduled and a discovered one loses the run.
