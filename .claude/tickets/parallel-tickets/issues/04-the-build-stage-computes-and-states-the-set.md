---
owner: repository
title: feat(implement): the build stage computes and states the set before dispatching
status: resolved
blocked-by: [03]
part-of: parallel-tickets
---

## Problem

`/implement` takes one ticket per invocation, lowest number first, and does not choose. That rule exists to stop the stage inventing a decomposition, and it also stops it doing the obvious thing when four tickets on the frontier gate none of each other.

Nothing today distinguishes an invocation that named a ticket from one that did not, and nothing computes which frontier tickets can run together.

## Outcome

The invocation decides the mode. Given a ticket, the stage builds that one, exactly as it does now. Given nothing, it computes the set of frontier tickets that do not gate each other — read off the declared `Blocked by` edges, which is reading a declaration rather than making one — and works the set.

Before anything is dispatched it **states the plan**: which tickets, which role, and which branch each will be built on. Stated, not gated: nothing is pushed and every effect is locally reversible, so a wrong set is undone the way a wrong ticket is, and the plan being in the transcript is what makes it visible.

The parent then creates every branch in the set, which is the claim, and only then dispatches. A frontier holding one ticket produces a set of one, and a set of one is built without dispatching anything — a child costs more than it saves for a unit the parent could take directly.

The guardrail ships in the same edit: the stage never widens the set beyond what the edges permit, and never reorders it.

## Acceptance

- An invocation naming a ticket builds exactly that ticket, and the suite asserts that path is unchanged.
- An invocation naming nothing computes the set from declared edges, and the stage never adds a ticket the edges gate.
- The plan is stated before any branch is created, and names the tickets, the role, and the branch per ticket.
- The plan does not stop for approval, and the stage says why it does not.
- Every branch in the set is created before the first child is dispatched.
- A set of one is built in the parent without dispatching.
- Nothing in the ticket format changed — the suite asserts no new section was added to it.
- Each guard is confirmed to fail against its removal.
- The suite passes.

## Found at review

**Every guard here checked that a sentence was *present*, and both axes broke all of them by adding one.** Not a single attack deleted anything: the required phrase stayed exactly where it was and a clause underneath it reversed the rule — the named path widened into the frontier around it, the stated plan held for the human, the lone ticket dispatched after all. My own mutation harness only deleted and replaced, so it could not have found this; the reviewers appended, and everything fell over.

The fix is structural rather than another phrase: each refusal is now scoped to the **paragraph carrying the rule**, which is where an addition has to land to do its damage, and the refusals are keyed to what a widening sentence must *say* rather than to any wording of mine.

**Both `$rulePattern` entries missed a faithful restatement.** *"Membership follows from the edges alone, and from nothing else about a ticket"* matched neither of the six words the first entry required, and *"the plan is told, not asked: nothing waits on the human agreeing"* named no approval at all. Both alternations widened to the subject each rule turns on.

**Three second homes, all of them prose I wrote here.** *"Every effect is reversible in this clone"* is `.claude/rules/engineering.md`'s argument, already carried by the close-out below for the commit it does not prompt on — this now reaches it instead of remaking it. *"No child ever creates one"* is the sub-agent policy's child-side prohibition; the stage states only the parent's obligation, and one refusal now catches both that restatement and its inversion. And *"a set has no fan-out to consult"* contradicted ADR 0046, which has a member declaring one and its child declining it.

## Accepted

**`### Working a set` answers no acceptance line.** The dispatch it describes comes from this ticket's Outcome — *"and only then dispatches"* — rather than from the criteria, which stop at the branches. Kept here because the criterion about branch creation is meaningless without the act it precedes, and because leaving dispatch to `05` would put it after integration. It does not encroach on `05` or `06`. Not an ADR: it clears none of the three tests.

## Deliberately not renamed

`## 1 — Take one ticket` still says *one*, and in set mode more than one is taken. The heading was left alone and the rule beneath it scoped instead, because the section's subject is the frontier and the claim, and the mode subsection states the exception immediately. Reversible in a line if the wrong call.
