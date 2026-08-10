---
owner: repository
status: implemented
sources:
  - specs.md §20
  - skills/implement/SKILL.md
  - skills/configure/policies/sub-agents.template.md
  - skills/configure/policies/tickets.template.md
  - .claude/policies/version-control.md
  - agents/portion-builder.md
  - .claude/decisions/0040–0048
  - .claude/evidence/research/2026-08-05-claude-code-subagent-orchestration-primitives.md
---

# feat(skills): the build stage dispatches whole tickets, not only portions

## Problem

The orchestration effort gave the build stage one way to use children: divide **one** ticket into portions. It cannot use them for the case that occurs far more often — several tickets that do not depend on each other, sitting on the frontier, each small enough for one context and each waiting for the one before it to finish for no reason but that the stage takes one ticket per invocation.

The obvious move is to call this the same feature and dispatch a child per ticket. It is not the same feature, and every rule the first axis settled comes out differently:

- Portions produce **one commit between them**; tickets produce **one commit each**, so integration is not a squash.
- Portions are all-or-nothing; tickets are demoable alone, so a failed sibling must not sink the ones that finished.
- Portions declare **file ownership** to stay disjoint; tickets declare edges, and edges say nothing about files.
- A portion child is given part of a ticket; a **ticket** child is given a unit that may itself declare a fan-out it cannot run, because one layer is one layer.

Shipping the second axis as though it were the first would land a system whose failure semantics are wrong in exactly the case it exists for.

## Goal

`/implement` invoked **with** a ticket behaves as it does today. Invoked **without** one, it computes the set of frontier tickets that do not gate each other, states that set as a short plan, and dispatches one child per ticket — each into an isolated worktree on a branch the parent created and holds. It integrates each child's work onto that child's ticket branch, resolves collisions between them, reviews each landed ticket, and reports which of the set shipped.

## Constraints

- **A child claims nothing, commits nothing, and dispatches nobody.** All three rules from `.claude/policies/sub-agents.md` hold unchanged. Everything this design needs is arranged so that they can — including the broker, whose closed menu exists precisely so that requesting is not a way around them.
- **Human authority is never delegated downward.** Brokering carries a question to the human and an answer back; it does not move who answers. No agent's message is another agent's consent (ADR 0041, amended in its consequence only by ADR 0049).
- **One ticket is still one commit**, and still on the branch named for that ticket. The axis adds concurrency, not a new history shape.
- **`/implement` never invents a decomposition.** The set is *computed from declared edges*, which is reading a declaration rather than making one, and it is stated before anything is dispatched.
- **No new ticket metadata.** The antichain is already encoded in `Blocked by`; a second declaration of the same fact would go stale against the first.
- **The version-control model is read, never assumed.** How a collision is resolved differs between stacked and plain git, and `.claude/policies/version-control.md` is where that is settled.
- **Fan-out is expensive** (orchestration's own constraint, unchanged). A set of one is a set: where the frontier holds one ticket, nothing is dispatched and the stage runs as it always did.

## Architecture

**Two axes, named apart.** A **fan-out** divides one ticket into portions. A **dispatched set** runs several whole tickets. Nothing says "orchestration" without saying which (ADR 0046).

**The parent creates every branch first.** Creating the branch is the claim, so the orchestrator claims the whole set before dispatching, and each child works one branch in its own worktree. This keeps *a child claims nothing* literally true, makes the set visible to other clones immediately, and turns the child-base check from an ancestry question into an equality one (ADR 0047).

**Integration is per ticket.** For each child that returns: reconcile its record against its diff exactly as a portion child's is reconciled, commit onto that ticket's branch, and restack in ticket order. Where two children wrote the same path, the orchestrator resolves it with **both records in hand** — the mechanism from the version-control policy, the intent from the manifests (ADR 0048).

**Failure inverts.** A child that fails or stops does not stop its siblings. Its ticket returns to the frontier with its worktree intact; the run reports which of the set landed and which did not (ADR 0046).

**The orchestrator brokers what a child may not do.** A child cannot dispatch, so it cannot run any capability that fans out — `/review` above all. It **requests**; the orchestrator performs; the result returns to the requester, which resumes with its full history. The runtime already supports this: a completed child returns an `agentId`, and `SendMessage` resumes it. The capability is dispatched at depth one from the orchestrator, so the depth bound is not bent (ADR 0049).

**The menu is closed, and that is the safety property.** A child may request a capability that requires dispatch, and a question put to the human. Nothing else is weighed. An open channel would make every prohibition in the sub-agent policy advisory, because a child forbidden to commit could simply ask. Requests spend the brief's existing cap, so a child that keeps asking runs out like one that keeps working.

**Review therefore differs by axis, like everything else here.** For a fan-out, review stays the orchestrator's, once, after every portion integrates — the portions are one ticket and there is no individual result to hand back. For a set, the child requests review of its own ticket and receives the findings, so the party that wrote the code is the party that answers for it.

## Approach

Seven tickets. The first three make the second axis *sayable* — specification, policy, role — and the next three make it *run*, in the order a run happens: before dispatch, on a clean return, on a failed one. The last adopts it here.

Note for the record, since this effort's subject is parallelism: **these tickets are mostly not parallelisable.** Four of the seven edit `skills/implement/SKILL.md`, and three edit the same subsection of it. That is the collision this design exists to handle, and it is the honest reason the set is a chain rather than a fan.

## Acceptance criteria

- `/implement <NN>` behaves exactly as it does today, and the suite asserts that path is untouched.
- `/implement` with no argument computes the non-gating frontier set from declared edges, states it, and dispatches one child per ticket.
- Every branch in the set exists before any child is dispatched, and no child creates or commits to one.
- Each child's work lands on its own ticket branch as one commit, in ticket order.
- A path written by two children is resolved by the orchestrator, using the mechanism the version-control policy names, with both change records read.
- A child that fails or stops leaves its siblings landed and its own ticket back on the frontier with its worktree kept.
- A dispatched ticket carrying a fan-out is built by one child, which records that it declined the declaration.
- A child may request exactly two things — a capability that dispatches, and a question for the human — and anything else is refused without being weighed.
- A brokered result returns to the child that asked, which resumes; requests spend the brief's cap.
- A child of a set requests its own review and receives the findings; for a fan-out, review stays the orchestrator's after integration.
- The run reports which tickets of the set shipped and which did not.
- The suite passes.

## Risks

- **The cost multiplies by the size of the set.** Orchestration's own evidence puts multi-agent work at roughly fifteen times the tokens of a chat. A five-ticket set is the most expensive thing this workflow can do, and nothing gates it — the plan is stated, not approved, on the grounds that every effect is locally reversible. If that trade is wrong, it is wrong here.
- **Collisions are discovered late by construction.** Optimistic dispatch means the cost of overlap is paid after the work is done. On a repository where most tickets touch one shared file — this one — that cost may dominate the saving.
- **Half-landed sets are a new state.** Nothing in the workflow has previously ended with some of its units shipped and others returned. The reporting obligation exists because a run that says "done" would otherwise be lying.
- **A suspended child still occupies the budget.** A child waiting on a brokered result counts against the concurrency limit, so a set whose members are all waiting on the human holds its slots without progressing. Nothing here bounds how long a human takes to answer.
- **The decisions policy has no "amended by" relationship.** ADR 0049 amends ADR 0041's consequence while leaving its principle standing, and `.claude/policies/decisions.md` records only `superseded by`. A reader arriving at 0041 will not learn that one of its consequences moved. Recorded rather than fixed: adding a relationship to the ADR format is a change to that policy, and this run has no mandate for it.

## Out of scope

- **Nested dispatch.** One layer stays one layer; a ticket child never fans out.
- **Cross-effort sets.** The frontier is computed within the effort being built, as today.
- **Predicting overlap before dispatch.** Explicitly rejected in ADR 0048, and not deferred.
- **The `Policies:` line for Primitives.** `survey` and `codebase-design` read the sub-agent policy without declaring it, because a Primitive has no router row. Recorded by orchestration/07 and untouched here — it is a question about what a Primitive is.
