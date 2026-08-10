---
owner: repository
status: accepted
load-when: a grill ends without reaching a decision
sources: [.claude/evidence/]
supersedes: []
superseded-by: []
---

# A discussion is a fourth kind of Evidence, not a peer of Decisions

A grill that ends without a decision is recorded at `.claude/evidence/discussions/`, beside research findings, prototype write-ups, and rejected requests.

Evidence is defined by a lifecycle property rather than by subject: it *records what was verified and when, and nothing revalidates it afterwards.* A discussion has exactly that property. What was weighed on a Tuesday stays true of that Tuesday, and no later pass reconciles it against the Codebase — which is what separates it from Context, and from a Decision, whose reasoning is frozen deliberately rather than incidentally.

The hole this fills is narrow and worth naming precisely. Alternatives **are** already recorded: every ADR carries `## Considered Options`. What has no home is the grill that produced *no* decision — the question explored and parked, the tradeoff nobody resolved, the unresolved item. `.claude/context.md` holds that the Grill is "where most durable understanding is produced", and today all of it evaporates except the one ADR that survives.

Graduation needs no new rule. A discussion promotes into an ADR exactly as a research finding promotes into Context, and `/design` already owns that step because `/design` read it and nothing downstream will.

## Considered Options

**A top-level `.claude/discussions/` with `active/` and `archived/`**, as the v2 proposal has it, was rejected on the `active/` half. An active discussion is a live thing rather than a record of something finished, which breaks the property that earns Evidence its grouping directory — and a directory whose two halves belong to different categories is one that gets filed wrong. It also adds a fourth knowledge-shaped directory that the truth hierarchy has no rank for.

**Extending the ADR format** with an `open` status and an `## Unresolved` section was rejected because it contradicts what an ADR is here: a draft until committed, and frozen afterwards. An ADR that keeps moving is a different document wearing the same numbering.

## Consequences

"Discussion" is not obviously "evidence" to a newcomer, and the grouping now visibly sorts by lifecycle rather than by subject. That cost is accepted: the alternative was a category defined by what things are called.

`/design` gains a second thing it may write into evidence, and `/triage` already writes a third. The evidence guide is the one home for what may go where, so the addition lands there rather than in each producing skill.
