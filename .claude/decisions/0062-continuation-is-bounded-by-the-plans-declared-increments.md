---
status: accepted
load-when: a build run has to decide whether to take another ticket, or how far autonomous work may go before stopping
sources: [skills/implement/SKILL.md, specs.md, .claude/policies/tickets.md]
supersedes: []
superseded-by: []
---

# Continuation is bounded by the plan's declared increments, not by a count or a checkpoint

An invocation that named no ticket now runs on past the one it delivered, and the bound on how far is **the declared increments the plan already carries** — it stops at one whose type needs the human, and at nothing else it invented. The alternative bounds were a fixed checkpoint at each dependency layer, a ticket count, and no bound at all; each would have put the stopping points somewhere other than where the human chose them.

The reasoning is that the plan is already the right place for this. `/design` writes increments typed by whether the human must be present, and ADR 0041 already treats two of those types as requiring one. So the stopping points are selected at design time, on the tickets, by whoever approved them — and the build stage reads them rather than deciding. A checkpoint per dependency layer would instead stop wherever the graph happened to branch, which is not where judgement is needed; no bound at all would resolve a `grilling` increment with nobody present, contradicting ADR 0041.

## Consequences

**A plan that declares no increment runs to the end of its unblocked work.** That is the plan saying so rather than the stage deciding it, but it does move weight onto declaring increments honestly at design time — a plan that under-declares now costs more than it did when every ticket was a checkpoint by default.

An invocation that *named* a ticket still ends after it. Continuation belongs to the set, and taking a second ticket after being handed one would be choosing work the stage was not given.
