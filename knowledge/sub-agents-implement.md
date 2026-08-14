---
owner: framework
type: norm
subject: sub-agents
fires-when: stage
stages: [implement]
spans:
  - the-part-is-a-portion-of-one-ticket-or-a-whole-ticket: 9br8i4
  - a-ticket-child-declines-a-fan-out-it-finds-declared: t5a5m3
  - a-ticket-child-neither-creates-nor-commits-to-its-branch: n5xqx0
---


# Sub-agents

The contract between a dispatching stage and its children — a norm rather than a second router, because a child inherits the entrypoint hierarchy and reaches this record through the same chain a session uses.

## The part is a portion of one ticket or a whole ticket

**The part is either a portion of one ticket or a whole ticket**, and the unit is the only thing that differs between them: a portion child owns the files its brief names; a ticket child owns its ticket, and what *done* means for it is that ticket's own acceptance criteria — nobody hands it a file list, because a set never had one to hand.

## A ticket child declines a fan-out it finds declared

**A ticket child that finds a fan-out declared on its ticket declines it and records the decline, then builds the whole ticket itself.** It cannot dispatch, so it cannot run the portions — the reason is that bound rather than a judgement about the work, which is why it says so rather than quietly building. Declining is not stopping, and it never divides the work some other way.

One contract, in four parts: what a child may use, what is closed to it, what it may ask for, and the two shapes that cross the boundary between it and its parent.

## A ticket child neither creates nor commits to its branch

- **A ticket child neither creates nor commits to the branch it works on.** The parent created it — that is the claim — and the orchestrator commits what the child produced. Nor does it review its own work unasked: review dispatches, and dispatching is closed to it — the orchestrator runs it, on request.
