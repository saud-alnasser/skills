# chore(skills): adopt the second axis here

Status: resolved
Blocked by: 06
Part of: parallel-tickets

## Problem

Everything this effort builds ships to other repositories and none of it is installed in this one. The framework's rule is that templates change before the repository adopts them, so adoption is a ticket rather than a side effect — and this repository is where the cost gets measured before it is recommended to anyone.

## Outcome

This repository runs the second axis: the amended sub-agent policy is installed, the vocabulary this effort added is checked against what was actually built rather than what was planned, and the migration converts a repository that has orchestration but not this.

The honest measurement is the deliverable. This effort's own tickets form a chain — four of the seven edit one file and three edit one subsection of it — so the set this design exists to dispatch was never available to build it. That is recorded rather than glossed: a system whose first user could not use it is a finding about the system, not about the user.

The orchestration effort's tickets are the counter-example and are measured too: four were mutually ungated and all four touched `scripts/verify.ps1`, which is the collision case ADR 0048 accepts. Whether that collision would in fact have been resolvable from the two records, or whether it would have reached the human every time, is the question that decides whether the optimistic dispatch was the right trade.

## Acceptance

- The amended sub-agent policy is installed here and matches the template it ships.
- Every term this effort added to the vocabulary is checked against the built system, and any that describes something not built is corrected or removed.
- The migration converts a repository carrying the first axis and not the second.
- The chain shape of this effort's own tickets is recorded, with which of them could have run together and which could not.
- The orchestration effort's ungated-but-overlapping tickets are recorded as the measured collision case, with what the records would have had to carry for the resolution to succeed without a human.
- Whether the second axis earns a Domain Context is decided with the built system to look at, with a stated reason either way, and the routing table matches the decision.
- The suite passes.

## The measurement

**This effort is a total chain, and the largest set available at any point in it was one.** Every `Blocked by` names exactly its predecessor: `01 → 02 → 03 → 04 → 05 → 06 → 07`. So the answer to which of them could have run together is **none, at any point** — not a pair. The spec predicted *mostly* not parallelisable, reasoning from file overlap; the edges are stronger than that, and the edges are what the stage reads. The set this design exists to dispatch was never available to build it.

The part worth recording is that the chain is **genuine rather than conservative**. Each ticket needed its predecessor's surface to exist before it could be written: `03`'s role points at the policy `02` amended, and `04`'s plan block names a role the suite asserts ships, so a `04` dispatched beside `03` would name a file that was not there yet. The general shape, stated no more strongly than one effort supports: an effort that *builds* a capability tends toward a chain, because each ticket creates the surface the next one edits.

**The orchestration effort is the counter-example, and it collides on four paths, not one.** Tickets `03`, `04`, `05` and `07` all declare `Blocked by: 02` and gate none of each other, so they form a real four-member set. Read off their commits:

| Path | Written by | Shape |
| --- | --- | --- |
| `scripts/verify.ps1` | 03, 04, 05, 07 | four-way |
| `skills/implement/SKILL.md` | 04, 05 | two-way |
| `agents/researcher.md` | 03 creates, 07 edits | ordering |
| `agents/standards-reviewer.md` | 03 creates, 07 edits | ordering |

**The first two would have resolved from the records, on one condition.** Each ticket appends its own `Describe-Ticket` block to `verify.ps1`, so four children produce four disjoint additions at one anchor and the orchestrator concatenates them in ticket order. That holds only while a record distinguishes *appended a new block* from *edited an existing one* — `05` did both, and its record would have had to say which of its lines were which. Without that distinction the orchestrator is reconciling hunks, which is the thing ADR 0048 says it must not be reduced to.

**The last two are not collisions at all, and they are the sharper finding.** `07` declares no edge on `03`, but edits two files `03` *creates*. Dispatched together from one base, `07`'s child finds no `agents/researcher.md` and cannot do its ticket. The declared antichain was wrong: `07` was gated on `03` in fact and not in declaration, and nothing in this design detects that — membership is computed from the edges, and a missing edge is indistinguishable from an absent one.

So the expensive case here is not two children writing one file; that reconciles. It is a missing edge, which no amount of change-record detail repairs, because the second child never had the file to write. What the shipped system does with it is correct and cheap: that member comes back `failed`, its siblings stay landed, its ticket returns to the frontier with its worktree kept, and a re-dispatch after `03` lands succeeds. The cost is one wasted child, not a wrong integration — which is the failure rule of `parallel-tickets/06` earning its keep on the first real case anyone measured.

## The vocabulary check

All four terms this effort touched were checked against what shipped, not against what was planned, and all four hold.

- **Dispatched Set** — against `skills/implement/SKILL.md`: computed from edges, one child per ticket, own commit on own branch, parent creates every branch before dispatch, failed sibling leaves the rest landed. Every clause has a paragraph.
- **Brokered Request** — against `.claude/policies/sub-agents.md`: the two-row table, the closed menu, and the chain with its attributed question and verbatim answer are all there in the words the term uses.
- **Collision** — against the same file and the build stage: discovered at integration, resolved by the orchestrator, both records read, mechanism from the version-control policy.
- **Fan-out**, amended to name the other axis and the inverted failure rule — both hold.

Nothing needed correcting or removing. Worth noting for the next adoption ticket that this is the second effort running where the vocabulary survived unchanged; the check keeps passing, which is either the grill working or the check being written by the party that wrote the terms. It is not yet possible to tell which from two samples.

## The Domain Context decision

**The second axis earns no Domain Context of its own, and the reason is that the two axes cannot be separated without breaking both.** Each term is defined by what the other inverts — a Fan-out divides one ticket and stops whole; a Dispatched Set runs several and does not — so a second file would put the contrast across a boundary and leave whichever file a session loaded stating half of it.

Routing is the second half of the argument, and it is the one that settles it. The question that reaches `orchestration.md` is *does this work dispatch*. Which axis it is becomes knowable only once the ticket has been read, and that is after routing has already run — so a router with two rows would have no way to choose between them and would load both every time, which is the single file with extra steps.

The routing table is made to match: the `orchestration` row's sources gain `skills/implement/SKILL.md`, which is where the second axis actually lives and which the Domain Context's own `Sources:` line already named. That was a real inconsistency between the map and the file it routes to, found while checking this criterion rather than by the sweep.

## Where this was recorded, and where it was not

In the ticket, on `orchestration/08`'s precedent and for its reasons. `.claude/policies/context.md` keeps constraints that outlive the current implementation, and both halves of the measurement expire: splitting `verify.ps1` removes the four-way collision, and adding the missing edge to `orchestration/07` removes the other. `.claude/policies/evidence.md` gives graduation to `/design`, not to the stage that found it.

## Carried forward, and not this ticket's

The missing edge itself. `orchestration/07` is resolved and its ticket file is a frozen record, so correcting its `Blocked by` line now would edit history rather than fix anything — but the *general* gap is live: nothing validates that a ticket's declared edges cover the files it will touch, and the design explicitly rejected predicting overlap before dispatch. Whether an edge can be checked against a ticket's own stated scope, which is a weaker question than predicting overlap, belongs to `/design`.
