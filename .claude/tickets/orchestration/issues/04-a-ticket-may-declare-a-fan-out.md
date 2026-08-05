---
title: feat(skills): a ticket may declare a fan-out
status: resolved
blocked-by: [02]
part-of: orchestration
---

## Problem

The build stage has no licence to divide a ticket, and it should not invent one: partitioning work into parallel units is an architecture decision, and a stage that builds what was planned or stops does not make those. But the decision has to be recorded somewhere the build stage reads, and the build stage reads the ticket. Without a declaration the choice is either made silently at build time or not at all.

## Outcome

The ticket format gains one optional section — which roles run, and which files each owns — written at design time only, exactly as a declared increment is. The design stage writes it; the tier gate still decides whether a run gets that far. A ticket without the section behaves precisely as it does today, so the change costs nothing to every ticket that does not use it.

The declaration is small by design. It names roles and file ownership and stops: the brief is composed at dispatch, because only the dispatch has read the code. The guardrail ships in the same edit — the build stage may never invent a fan-out, and a ticket that turns out to divide differently than declared hands back rather than being re-partitioned in flight.

Because a child cannot stop for a human, a ticket declaring both a fan-out and an increment needing one is contradictory; the format says so, and says which resolves first.

## Acceptance

- A ticket can declare a fan-out naming roles and the files each owns, and the design stage's text says it writes them.
- A ticket with no declaration is unchanged in every respect.
- The guardrail — the build stage never invents a fan-out — lands in the same change as the section it bounds.
- A ticket declaring both a fan-out and an increment that needs a human states which resolves first, and the format refuses the combination as written.
- The declaration names roles and ownership only; nothing in it composes a brief.
- The suite asserts the section exists in both the format and its template, the guardrail exists where it is enforced, and the contradiction case is named — each guard confirmed to fail against its removal.
- The suite passes.

## What the refusal actually refuses

The criterion asks the format to refuse the fan-out/HITL-increment combination. What ships states the order — the increment resolves in the parent before anything is dispatched — and refuses one construct: a declaration that would hand such an increment to a child. That construct is not expressible in the declared shape, which names roles and files and nothing else, so the operative rule is the ordering. Recorded rather than papered over: the refusal is the bound that becomes reachable if the shape ever grows a field that assigns work to a portion, and ADR 0041 is what it follows.

## Found at review, fixed

The installed `.claude/policies/tickets.md` had not gained the section. The criterion says the suite asserts it in "both the format and its template", and the declared-increment section this one parallels moved both copies in one commit — so the installed copy is now written and asserted body-identical to the template.

One rule was stated in three shipped files and another in two, neither guarded. Both now have one home in the format, with `/implement` and `/design` pointing, and both have single-home entries. And the pointer sending a reader to the sub-agent policy for what a role is went nowhere: that file never uses the word.
