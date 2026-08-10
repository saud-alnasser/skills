---
owner: repository
status: accepted
load-when: several tickets are to be built at once
sources: [skills/implement/]
supersedes: []
superseded-by: []
---

# Ticket-level orchestration is a second axis, and its failure rule inverts

The orchestration effort built one axis: a ticket divides into **portions**, each worked by a child owning declared files, all squashed into one commit, and **nothing lands if any child fails**. That last rule is right for portions — a partial set satisfies no acceptance criterion, so reviewing one would review a ticket nobody built.

Dispatching whole **tickets** to children looks like the same thing and is not. `.claude/policies/tickets.md` requires every slice to be "demoable or verifiable on its own", so a landed ticket is a complete unit whatever happened to its siblings. The failure rule therefore **inverts**: siblings land, and the failed ticket returns to the frontier with its worktree intact.

Two axes with opposite semantics under one word is a hazard, so they are named apart: a **fan-out** divides one ticket, and a **dispatched set** runs several. Nothing in the workflow calls both "orchestration" without saying which.

## Consequences

**A dispatched ticket that declares a fan-out is built alone.** One layer is one layer, so the child cannot spawn the portions its ticket declares. The declaration is *declined at depth* rather than honoured recursively, and the child says so in its record. This is not a stage inventing or ignoring a decomposition: the parent chose the axis, and declining is what the depth bound makes available.

**A child cannot run `/review` or `/commit` for its own ticket.** Both dispatch or write history, and a child does neither. Review runs in the parent, per ticket, after that ticket lands — which the slicing rule already implies, since each ticket is verifiable alone.

**A set can half-land.** The session's report has to say which of N shipped, which returned, and why. A run that says "done" after landing three of five is the failure this consequence exists to prevent.

## Considered Options

- **One failure rule across both axes.** Rejected: it throws away N−1 completed, independently valid tickets because one unrelated ticket failed. The rule is the same sentence only if the units are the same, and they are not.
- **Land siblings, then stop dispatching further work.** Rejected as a middle rule that has to define "further" — and the frontier already answers what comes next.
- **Never dispatch a ticket that declares a fan-out.** Rejected: the tickets most worth parallelising are the ones large enough to have been divided, so the exclusion removes the cases the axis exists for.

Specification §20 is amended in the same change to name the two axes, contrast them row by row, and state the failure rule that inverts between them. Version 1.7.0.
