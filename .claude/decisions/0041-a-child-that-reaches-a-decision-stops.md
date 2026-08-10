---
owner: repository
status: accepted
load-when: a dispatched child meets a decision it cannot make
sources: [.claude/policies/sub-agents.md]
supersedes: []
superseded-by: []
---

# A child that reaches a decision stops, because it cannot ask

`AskUserQuestion`, `EnterPlanMode`, `ScheduleWakeup`, and `Workflow` are withheld from every sub-agent, and no message from any agent counts as another agent's consent for a permission prompt. AEP's human-authority principle — never silently decide architecture — therefore cannot be honoured inside a child by any amount of instruction: a child asked to present options has no surface to present them on.

So a child that reaches a decision **writes it into its change record and stops**. The orchestrator raises it, because the orchestrator is the one holding a conversation with a human. This needs no new vocabulary: a decision a child cannot make is the same event as a decision `/implement` discovers undeclared, and that is already `blocked`.

## Consequences

**No HITL design increment may be assigned to a child.** A ticket declaring both a fan-out and a `grilling` or `prototype` increment resolves that increment in the parent, before dispatching anything — otherwise the build stops in a context that cannot stop for a human.

A child may still resolve an AFK increment, because `research` and `task` types need no human present.

Specification §20 is amended in the same change to carry the bound: human authority is never delegated downward, and a child that reaches a decision records it and stops.
