---
owner: repository
status: superseded
load-when: how a Source Pointer, a drift finding, or the Marker behaves once knowledge is spans rather than files is in question
sources: [.claude/tickets/substrate/issues/14-how-verification-at-use-survives-the-flattening.md, .claude/policies/context.md]
supersedes: []
superseded-by: [0100]
---

# A pointer is inherited, a finding names an id, and the Marker does not move

Verification at use is written against files and ADR 0085 makes the addressable unit a
span. Its three parts do not have one answer, and treating them as one is what this
decision refuses.

**A Source Pointer is declared on the file and a span may override it.** Most spans in a
file genuinely share a pointer, so the common case is authored once and the exception is
explicit. Span-level-only was rejected on ADR 0056's own test: a field repeated across
every span of a file that shares it restates the file and is sediment. File-level-only was
rejected because a file whose spans point at different code already has an imprecise
pointer, and flattening makes that visible rather than creating it — declining to fix it
is declining the one improvement the flattening offers here. The split mirrors ADR 0085's
own: **the file is authored, the norm is addressed.**

**A drift finding's `falsifies` names an id.** ADR 0090's build already resolves
`falsifies` as one of five declared edges, so the target is validated and a broken one
fails — which a path can never be, because the build cannot check that a path still
contains the claim the finding was about. Healing then scopes to the record that actually
moved rather than to whatever shared its file. A file-level form stays legal, because a
finding about a whole file is a real shape and forcing it to name a span would be a
precision the finder does not have.

**The Marker does not move, and saying so is cheaper than leaving it to be inferred.** Its
two facts are a commit and a fingerprint of the working tree — both whole-repository
values, neither addressed at any granularity. Flattening changes what knowledge *is* and
changes nothing about what the Marker records or what a match licenses. ADR 0052 stands
untouched.

**The asymmetry between edges and pointers is kept, and the reason is stated rather than
left as an omission.** The build validates every declared edge and does not validate a
Source Pointer. An edge points at knowledge, which has ids; a pointer points at the
Codebase, which has none — and `.claude/policies/context.md` defines it as *"a navigation
coordinate, never a claim"*, so there is nothing to check it against. **Verification at
use is the check**, at the moment the pointer is followed, which is where the protocol
already puts the recovery procedure. Accepted: a pointer at a path deleted months ago
stays green until somebody follows it. Checking mere path existence was rejected — ADR
0071 considered declared-pointer resolution and left it out deliberately, and the
regenerator's own shipped fixture declares `sources` over directories that do not exist
and expects the run to succeed, so the check would fail the script's own proof. A
warn-only variant was rejected as the loud-versus-silent trade made badly.

## Considered Options

- **Span-level pointers only** — rejected as sediment by ADR 0056's test.
- **File-level pointers only, unchanged** — rejected: it declines the precision the
  flattening makes available at no cost to the common case.
- **`falsifies` keeps naming paths** — rejected: it spends the identity ADR 0085 bought
  and leaves the one edge that could be validated unvalidated.
- **The build checks that a `sources` path exists** — rejected on ADR 0071's recorded
  reasoning and the regenerator fixture that would have to change to accommodate it.
- **Warn on an unresolvable pointer without failing** — rejected: ADR 0088 chose harness
  push precisely to avoid a channel that fails without stopping anything.
