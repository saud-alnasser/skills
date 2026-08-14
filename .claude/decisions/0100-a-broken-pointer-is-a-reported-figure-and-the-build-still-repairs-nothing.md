---
owner: repository
status: accepted
load-when: how a Source Pointer, a drift finding, or the Marker behaves once knowledge is spans rather than files is in question
sources: [skills/configure/policies/records.template.md, skills/configure/SCRIPTS.md, scripts/build-knowledge-store.js, .claude/policies/context.md]
supersedes: [0094]
superseded-by: []
---

# A broken pointer is a reported figure, and the build still repairs nothing

The build **counts** Source Pointers that no longer resolve and names them, and
fails on none of them. ADR 0094 decided the opposite — that a pointer at a path
deleted months ago stays green until somebody follows it — and it is superseded
here rather than narrowed, because that clause is part of what it decided.

**The ground under 0094 moved.** It rejected checking that a pointer's path exists
partly on a concrete fact: *"the regenerator's own shipped fixture declares
`sources` over directories that do not exist and expects the run to succeed, so
the check would fail the script's own proof."* That regenerator retires at 2.0.0,
and the store builder replacing it has no such fixture. The argument was sound and
its support is expiring.

**What 0094 refused is still refused, and the distinction is the whole decision.**
It rejected a *warn-only* variant on the grounds that ADR 0088 chose harness push
precisely to avoid a channel that fails without stopping anything. A figure in a
ledger a stage queries is not that channel: it is data with a reader, not a warning
into a stream. And the deeper reason the build must not fail here is untouched —
a build that failed on an unresolvable pointer would press whoever hit it toward
inventing a replacement path, which is the one outcome the recovery rule exists to
prevent. **Reporting is the only disposition that neither hides the breakage nor
manufactures a repair.**

**0094's other three positions are carried forward unchanged**, and each keeps its
original reasoning, which stays readable in 0094 itself:

- A Source Pointer is declared on the file, and a span may override it.
- A drift finding's `falsifies` names an id, and a file-level form stays legal.
- The Marker does not move: its two facts are whole-repository values, and
  flattening changes nothing about what a match licenses.

## Considered Options

- **Follow 0094 and drop the reporting**, deleting it from both pages and from the
  builder that already ships it. The default when a document and an accepted
  decision disagree. Rejected: it retires a figure the builder computes almost for
  free, on an argument whose supporting fact expires this release.
- **Report it in the ledger and never in the printed output.** Narrower, and it
  meets 0088's objection precisely. Rejected as the worse half of the trade: a
  figure nothing surfaces is one nobody acts on, which is the same silence with
  better manners.
- **Fail the build on a broken pointer.** Rejected for the reason 0094 gave and
  this record keeps: it converts a search somebody must perform into a guess
  somebody is pressed into.

## Consequences

**Pointers remain unvalidated at declaration and checked at use.** Verification at
use is still the check; the count is a report about the store, not a gate on it.

**An asymmetry stays and is still deliberate**: every declared edge resolves or
the build fails, and a pointer does neither, because an edge names an id and a
pointer names a path.
