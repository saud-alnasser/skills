---
status: accepted
load-when: the branches for a dispatched set are being created
sources: [skills/implement/]
supersedes: []
superseded-by: []
---

# The parent holds every claim in a dispatched set

`.claude/policies/sub-agents.md` states that a child **claims nothing**. A child given a whole ticket appears to contradict that immediately: somebody holds that ticket's claim, and the claim is the branch.

The orchestrator holds all of them. It creates every branch in the set **before dispatching anything** — creating the branch *is* the claim — and each child works one of them in an isolated worktree. The policy's rule survives verbatim: no child creates a branch, and no child commits to one.

Two things follow that are worth more than the rule they preserve.

**The set becomes visible to other instances at dispatch, not at landing.** Branches exist from the first moment, so a second clone reading the remote sees the whole set claimed rather than discovering it one ticket at a time.

**The base check becomes exact.** Ticket 05 of the orchestration effort left an unresolved question: the check that a child built on the claim was stated as ancestry, and ancestry cannot distinguish a child branched from trunk from one branched correctly, nor survive a parent that commits mid-run. With one branch per ticket created up front, the check is **equality** — the child's base is the tip of the branch that ticket was assigned, as it stood at dispatch. The ambiguity dissolves rather than being resolved.

## Consequences

**`/implement` takes a set, not a ticket.** Its "one ticket per invocation" rule becomes "one ticket, or one computed set" — selected by whether the invocation named a ticket. That is a change to the shape of the spine, not an addition to it, and it is the cost this decision accepts.

**A claim now covers work no single branch names.** The stack belongs to one instance already; this widens the same idea from a line to a set.

## Considered Options

- **A child claims its own ticket.** The most natural reading of "it builds the ticket", and rejected: it contradicts a rule shipped by orchestration/02 and the reasoning in ADR 0041, so it would need a superseding Decision to buy a property — branch creation by the child — that nothing needs.
- **One claim over the whole set rather than per ticket.** Rejected: it breaks the one-ticket-one-branch convention that makes a ticket recoverable from a branch name, which is what lets an instance that lost its context read what it was building.

Specification §20 is amended in the same change to state that the parent creates every branch in a set before dispatching, and that a child still claims nothing.
