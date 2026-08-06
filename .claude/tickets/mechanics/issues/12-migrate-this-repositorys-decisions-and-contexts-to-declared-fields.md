---
title: chore(skills): migrate this repository's decisions and contexts to declared fields
status: resolved
blocked-by: [08]
part-of: mechanics
---

## Problem

The declared-field shape ships after tickets 05 through 08, and this repository's own knowledge does not use it: fifty-one decisions with no fields and two informal status lines between them, three contexts with prose source lines, and no decisions index. Until it does, the repository that builds this framework is the one repository not running it, and every assertion written against real data has nothing to run against.

The supersession claims are the part most likely to be wrong. Two files claim to be superseded and nothing has ever checked that the superseding files agree; several more discuss supersession in prose without claiming it, and prose is not a claim.

The size is itself a hazard rather than merely a cost. Fifty-one mechanical edits is the shape of work that gets done inattentively, and inattentive here means a load condition that describes a subject instead of naming a trigger — which is the exact failure the earlier decision on routing turned on, reintroduced one file at a time.

## Outcome

Every decision and every context in this repository declares its fields, and the indexes are generated from them rather than written.

Each decision's load condition is a sentence about when to load it — the trigger, not the topic. Numbers and slugs are preserved exactly; nothing is renumbered to close a gap, because inbound references resolve by number.

The supersession graph is complete and symmetric: every claim made at one end is made at the other, and the claims that exist only as prose are either made properly or dropped as the discussions they are.

The review stage, run against a diff in this repository, reaches only the decisions the index routes to.

## Acceptance

- Every decision in this repository declares its fields, with its number and slug unchanged.
- Every context declares its sources and its load condition, and no prose source line survives.
- The decisions index and the contexts index are both generated, and regenerating either produces a byte-identical file.
- The supersession graph is symmetric, and the two existing one-sided claims are resolved at both ends.
- Every declared source path in this repository resolves.
- Each load condition states when to load the file rather than what it is about — checked by reading them, not by counting them.
- A review run against a diff touching one area reads the decisions the index routes to and no others.
- The suite passes.

## Comments

**The partial supersessions are the part the plan did not anticipate.** Three exist here, and
only two are claims: `status:` lines on 0003 and 0005. The rest — "supersedes the placement of
X in 0002 and 0004", "supersedes one consequence of 0025", "supersedes the layout stated in
0006" — are prose discussing supersession, and were left as prose rather than promoted, which
is what this ticket asks for.

0005's claim reads *superseded in part by 0010*, and the status vocabulary ticket 06 shipped has
no partial value. It is recorded as `superseded` with the pair symmetric, because 0005's own
body already carries a frozen blockquote naming exactly which half still stands — so nothing is
lost that a reader cannot recover. A future design run may want a partial value; this build did
not invent one.

**The review row was adopted here rather than in 13.** Ticket 08 deferred it precisely because
the index did not exist; this ticket creates it, so the deferral expired here.

**The load conditions are authored, and only coarsely guarded.** All fifty-four were written
from each ADR's own argument, and the suite catches a condition with no verb at all. Nothing
mechanical separates a trigger from a topic — ADR 0053 says so — and a human reading them is
the only real check. They have not had one.
