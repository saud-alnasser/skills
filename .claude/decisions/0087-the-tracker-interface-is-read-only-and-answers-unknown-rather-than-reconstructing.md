---
owner: repository
status: accepted
load-when: the tracker store's interface, or what it may answer, is in question
sources: [.claude/tickets/substrate/issues/10-what-the-tracker-store-s-fixed-interface-guarantees.md, .claude/policies/tickets.md]
supersedes: []
superseded-by: []
---

# The tracker interface is read-only, and answers `unknown` rather than reconstructing

The tracker store's fixed interface **reads and never writes**. Writes keep the
paths they use today — files on a local-markdown tracker, and on a shared one the
merge, which AEP does not perform. The two backings already differ in whether AEP
writes at all, so a uniform write surface would either forbid what is safe
locally or permit what is unsafe remotely; keeping the interface read-only also
puts the standing prohibition on publishing structurally out of reach rather than
stating and enforcing it.

**The contract is what every backing can answer losslessly, and anything else is
an explicit `unknown`.** GitHub maps `obsolete` and `superseded` onto one native
state, distinguished only by a mandatory comment's wording; reconstructing the
distinction means parsing prose, which is confidently wrong whenever the comment
is worded unexpectedly, and a wrong state is indistinguishable from a right one at
the call site. A caller can branch on `unknown` and cannot branch on a wrong
answer that looks right — the same reflex as the evidence format's, where absent
and unrecoverable are different facts and only the second needs stating.
**`unavailable` is a third answer**, kept separate so an outage never reads as a
fact about the ticket.

Two consequences follow. `map` belongs to the tracker store and `spec` to the
knowledge store, because a map has a forge representation — a pinned issue — and
both spec layouts are file layouts. And **no capability declaration is needed**:
with a read-only interface and an explicit `unknown`, a caller never branches on
which backing it is talking to, so the tracker policy's declared fields stay
repository facts rather than becoming a runtime API.

## Considered Options

- **Read and write with publishing excluded** — rejected: the backings differ in
  what may safely be written, so one uniform write surface must be wrong for one
  of them.
- **Read and write with each backing declaring its writes** — rejected: callers
  branching on a capability declaration is judged selection wearing a different
  hat, and a caller that forgets to check simply does not write, silently.
- **Reconstruct the canonical state on a lossy backing** — rejected as prose
  parsing that fails invisibly.
- **Expose native states plus a declared mapping** — rejected: every caller
  re-implements the interpretation, which is the duplication a fixed interface
  exists to remove.
