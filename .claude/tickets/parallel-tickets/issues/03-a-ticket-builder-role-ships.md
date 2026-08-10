---
owner: repository
title: feat(skills): a ticket-builder role ships
status: resolved
blocked-by: [02]
part-of: parallel-tickets
---

## Problem

The shipped roster has a `portion-builder`, whose whole instruction is that the files its brief names are the ones it may write and everything outside them belongs to somebody else. A child given a whole ticket has the opposite situation — no declared ownership, and an acceptance list of its own to satisfy — so dispatching `portion-builder` for it would hand a child a constraint that does not apply and withhold the one that does.

## Outcome

One more role, named for the unit it takes. It builds one ticket against that ticket's own acceptance criteria, and what bounds it is the ticket rather than a file list.

It carries the two things a ticket child gets wrong if nobody says them: that a fan-out on its ticket is declined rather than run, because it cannot dispatch; and that finishing means the ticket's criteria are met and recorded, not that the work felt complete.

Its tool list survives being dispatched in the background, like every other shipped role, and it denies itself the dispatch tool. The roster stays small — this is the fifth role and there is no sixth pending.

## Acceptance

- The role ships, is dispatchable by name, and its identity comes from the name rather than its location.
- It points at the sub-agent policy and restates none of it.
- It denies itself the tool that would let it dispatch further.
- Its tool list is asserted against the set a background child retains.
- It states that a declared fan-out on its ticket is declined, and that the decline is recorded.
- It states that done means the ticket's own acceptance criteria are met, and where it says so.
- It relies on no frontmatter field a plugin ignores.
- The suite asserts the roster is exactly the roles this framework dispatches — no more.
- Each guard is confirmed to fail against its removal.
- The suite passes.

## Two criteria collided, and how

Criterion 22 says the role restates none of the policy; criterion 25 says it states that a declared fan-out is declined and the decline recorded — which `parallel-tickets/02` had since made the *policy's* rule. Both are satisfied by splitting them: the role carries the **obligation** (do not run it, do not work the portions by hand, record that you declined) and points for the **rule**. Single-home is the framework's central claim and outranks a criterion written before the policy existed.

The Outcome said "the fourth role". It was the fifth — corrected above rather than left as a wrong record.

## Found at review

**The role restated the policy, under a paragraph claiming to repeat nothing.** *"Nobody hands you a file list, because there is none to hand"* was the policy's ownership sentence, near enough word for word — and my guard *required* it, so the check was protecting the duplication. The role now states the bound; the policy states the ownership; and the guard refuses the restatement rather than demanding it.

**Two guards passed on the rule inverted.** *"You do not run it as a dispatch — work the declared portions yourself, one at a time"* keeps every phrase the guard checked while doing exactly what the depth bound forbids, and `disallowedTools` cannot stop it because no dispatch occurs. Likewise *"where you see an improvement outside your ticket, make it while you are there"* kept the premise and reversed the conclusion. Both now anchored on the consequence rather than the premise.

**Criterion 26's second half was unguarded** — *"and where it says so"* could be deleted with the suite green.

## A gap this ticket found and did not close

`$rulePattern` cannot express a rule whose home is a **role**. The table is swept two ways: `tenure/02` requires exactly one home under `skills/`, and `orchestration/07` requires that no role match any entry. A rule homed in `agents/` therefore fails both at once — stated nowhere, and restated by the file that states it. Verified by trying it.

The consequence is live: the decline rule `parallel-tickets/02` placed in the policy has no entry, so a paraphrase of it planted in a role is not caught. Closing this needs the sweeps to accept `agents/` as a home, which is shared machinery and belongs to `/design`.
