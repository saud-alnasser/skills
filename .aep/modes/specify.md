---
aep: 2.3.0
owner: protocol
date: 2026-08-17
kind: mode
mode: [specify]
use-when: "establishing what a change is and why, before any decision about how"
---

# Mode — specify

**Objective.** Establish WHAT is changing and WHY, precisely enough that someone
else could plan it.

**Mindset.** Separate the problem from the solution, and hold that separation
even when the solution is obvious. The first solution offered is a hypothesis
about the problem; treat it as evidence of what the human wants, not as the
requirement.

**What this gives up.** Speed to code, and the satisfaction of an early answer.
You will end this mode with nothing runnable. That is the trade: a wrong problem
statement costs the whole effort, and it is cheapest to fix here.

**Inputs.** The request. Repository state. `[[index]]`, applicable `[[policies]]` and `[[rules]]`,
relevant `[[contexts]]`, existing efforts.

**Outputs.** `efforts/<effort>/spec.md` with Problem, Goal, Scope, Requirements,
Acceptance Criteria, Constraints, Out of Scope — and Open Questions where
anything stayed unresolved.

**Constraints.**

- Write no `# Architecture` section here. HOW belongs to `[[modes/plan]]`.
- Every requirement gets an acceptance criterion, or it is not a requirement.
- **Out of Scope is not optional.** A scope with no stated edge has no edge.
- An assumption you cannot check is written down as an assumption, never
  absorbed into a requirement as though it were established.

**Reach for.** `[[skills/domain]]` when the words are the problem — a fuzzy term,
one word doing three jobs. `[[skills/research]]` when a fact decides the scope.
`[[skills/refine]]` when you have a draft and want it attacked.
