---
owner: repository
title: "docs(tracker): settle what the tracker store's fixed interface guarantees"
status: resolved
blocked-by: [02]
part-of: substrate
type: grilling
---

## Question

What does the tracker store's query interface guarantee, when its backing is
files in one repository and a forge API in another?

`02` put tickets and maps in a store of their own precisely so the backing could
vary while the interface did not. That answered the uniformity objection; it did
not say what uniform *means*.

Settle:

- What every backing must answer, and what a caller may therefore rely on —
  the frontier, a ticket's edges, an effort's set, a map's decisions.
- What a backing is allowed to answer differently, and how a caller learns which
  it is talking to. `tracker.md` already declares `tracker`, `spec-home`, and
  `ticket-model` as repository facts; whether those become the interface's own
  capability declaration or stay prose is part of this.
- What happens when a backing cannot answer at all — a forge that is offline, or
  a lifecycle state one tracker has and another does not. `tickets.md` maps five
  states onto GitHub's native two, and the mapping is lossy in one direction.
- Whether `map` belongs here or in the knowledge store. It was placed with
  tickets because it indexes them, but a map is design reasoning and a `spec`
  went the other way on that argument.
- Whether the interface reads only, or writes. A stage that resolves a ticket
  writes to the tracker today; through a fixed interface that becomes an API
  call, and the standing prohibition on publishing has to be expressed in it.

## Answer

**The interface is read-only.** Writes keep the paths they use today — files on a
local-markdown tracker, and on a shared one the merge, which AEP does not
perform. The prohibition on publishing therefore needs no expression in the
interface, because the interface cannot reach that far; and dropping the
interface costs speed rather than capability. The two backings already differ in
whether AEP writes at all, which is what made a uniform write surface either
forbid what is safe locally or permit what is unsafe remotely.

**`map` belongs to the tracker store and `spec` to the knowledge store**, settled
by norm rather than chosen: `.claude/policies/maps.md` gives a map a forge
representation — a pinned issue on GitHub — where both of `.claude/policies/
specs.md`'s layouts are file layouts. A record with a forge representation is the
tracker's.

**The contract is what every backing can answer losslessly.** Where a backing
cannot represent something — `obsolete` against `superseded` on GitHub, which
`.claude/policies/tickets.md` maps onto one native state distinguished only by a
comment's wording — the interface returns an explicit `unknown` and never a
reconstruction. Parsing that comment would be confidently wrong whenever it was
worded unexpectedly, and a wrong state is indistinguishable from a right one at
the call site. A caller can branch on `unknown`; it cannot branch on a wrong
answer that looks right. This follows the recorded reflex that absent and
unrecoverable are different facts and only the second needs stating.

**`unknown` and `unavailable` are different answers.** A backing that cannot
represent a fact returns the first; a backing that did not respond returns the
second. Conflating them would let an outage read as a fact about the ticket.

**No capability declaration is needed** — a consequence rather than a goal. With
a read-only interface and an explicit `unknown`, a caller never branches on which
backing it is talking to, so the tracker policy's declared fields stay repository
facts for derivation and for human readers rather than becoming a runtime API.
The alternative, a caller that asks a backing what it supports, was judged
selection wearing a different hat, with a silent failure when a caller forgets to
ask.

Recorded as ADR 0087.
