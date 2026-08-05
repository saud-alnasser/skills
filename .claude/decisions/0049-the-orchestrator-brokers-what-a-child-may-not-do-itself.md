---
status: accepted
load-when: a child needs something it is not permitted to do itself
sources: [.claude/policies/sub-agents.md]
supersedes: []
superseded-by: []
---

# The orchestrator brokers what a child may not do itself, on a closed menu

A child cannot dispatch, so it cannot run any capability that fans out — `/review` most obviously, since its two axes are themselves sub-agents. Until now that meant such work happened only in the parent, after the child was finished, which is too late for the child to act on it.

The runtime already supports the round trip. A completed sub-agent returns an `agentId` trailer, and `SendMessage` resumes it "with their full conversation history, including all previous tool calls, results, and reasoning". So: the child returns a **request**, the orchestrator performs it, and the result is sent back to the requester, which continues where it left off. No new capability, and no second layer — a capability the orchestrator runs on a child's behalf is dispatched at depth one, from the orchestrator, exactly as if it had wanted the thing itself.

**The menu is closed, and that is the whole safety property.** A child may request two things: a capability that requires dispatch, and a question put to the human. Anything else is refused without being weighed. This is not caution — an open request channel would make every prohibition in `.claude/policies/sub-agents.md` advisory, because a child forbidden to commit could simply ask. A prohibition survives a menu; it does not survive discretion exercised by the party that wants the work done.

`SendMessage` stays out of every shipped role's tool list. A child can be resumed and cannot message anyone, so child→orchestrator→child is the only path and no sibling traffic exists that the orchestrator cannot see.

**Round trips spend the brief's cap.** The policy already requires every brief to carry one; a request costs against it exactly as work does, so a child that keeps asking runs out the same way a child that keeps working does. No second budget.

## What this amends in ADR 0041

ADR 0041's principle is untouched and remains the reason this design has a shape at all: human authority is never delegated downward, and **no agent's message is another agent's consent**. Under brokering the human still answers; the orchestrator only carries the question and the reply.

The chain is **child → orchestrator → human → orchestrator → child**, and being in the middle of it imposes two obligations, one in each direction:

- **Outward, the question is attributed.** The human sees which child is asking and about which ticket. A question arriving unattributed is a question answered without its context, and the orchestrator holds the only view in which that context exists.
- **Inward, the answer is relayed as given.** The orchestrator does not summarise, resolve, or improve the human's reply on the way back. A paraphrase is the orchestrator's answer wearing the human's authority, which is the precise thing ADR 0041 forbids — and it fails silently, because the child cannot tell the difference.

Where the orchestrator genuinely cannot relay — the answer changes what the whole set is doing, not just that child — it stops the child rather than reinterpreting for it. Ending a child is honest; answering for the human is not.

What changes is the consequence. "A child that reaches a decision writes it into its change record and **stops**" gains a second outcome: it may stop **pending an answer** and resume when one arrives. The run no longer necessarily ends where the question was asked.

**The no-HITL-increment rule stands, for a new reason.** ADR 0041 barred assigning a `grilling` or `prototype` increment to a child because the build would halt where no human could be reached. That is no longer true, and the rule survives anyway: a grill is a conversation, and conducting one through a relay — across a context that cannot see the room, one message at a time — is worse than resolving it in the parent before anything is dispatched. What was a limitation is now a judgement, and it reaches the same place.

## Consequences

**The change record gains a fourth outcome.** A child returns done, failed, stopped, or **waiting** — and waiting is new. Anything reading a return has to distinguish a child that finished from one that is mid-conversation.

**Review differs by axis, again.** For a fan-out, review stays the orchestrator's, once, after every portion integrates — the portions are one ticket and there is no individual result to hand back. For a dispatched set, a child requests review of its own ticket and receives the findings, so it can fix them before its ticket lands. Same capability, opposite plumbing, for the same reason the failure rules differ (ADR 0046).

**A suspended child is still a child.** It counts against the concurrency limit while it waits, so a set whose members are all waiting on the human occupies the budget without progressing.

## Considered Options

- **Open request, orchestrator judges each one.** Rejected above: it dissolves the prohibitions it is meant to operate under.
- **A closed menu extensible by declaration on a role or ticket.** Rejected: it puts the child contract in a second place, which is the duplication the single-home rule exists to prevent.
- **Broker capabilities but never questions.** Rejected: it gives up the case that motivated this — a child one answer away from finishing, otherwise losing a full context of work.
- **A separate request budget.** Rejected: a second number to set and get wrong, where the existing cap already means "how far this child may go".

Specification §20 is amended in the same change to state the closed menu, the depth at which a brokered capability is dispatched, both obligations on the relay, and the fourth return outcome.
