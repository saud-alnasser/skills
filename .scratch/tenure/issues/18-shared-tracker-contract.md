# feat(tracker): what tenure may write to a tracker other people read

Status: ready-for-agent
Blocked by: 17

## Problem

`tools/github.md` gates pull request creation as publishing and leaves `gh issue create` ungated, so `/design` can create a whole ticket set in a shared tracker unasked. That is the booming failure at its worst, because it lands in other people's workspace rather than a local directory.

Three further gaps, all decided by ADR 0014. `/design` currently produces a flat set of siblings, so N top-level issues appear at once with nothing grouping them. `/implement`'s frontier is defined over build tickets but on a shared tracker the triage queue and the frontier are the same list, and an incoming `ready-for-agent` issue has no outcome, no acceptance criteria, and no edges to build from. And `/implement` sets `resolved` after the commit, which asserts an outcome Tenure does not control — it never pushes, opens a pull request, or merges.

## Outcome

Creating an issue is publishing, and is gated exactly as pull request creation already is. The ticket set is proposed, iterated, and approved before anything is created, and lives in the design document until then — where a teammate can argue with the breakdown while that is still cheap.

One `/design` run creates exactly **one root issue**, with every ticket beneath it as a sub-issue; a design yielding a single ticket makes that ticket the root. The tracker's top level grows by one per design, which makes booming visible without counting.

The frontier is build tickets only. An incoming issue is `/design`'s input and becomes a root; `/implement` meeting a bare one says so and stops.

The **merge** resolves the ticket. Commits carry a non-closing reference; the drafted pull request body carries the closing keyword; `/implement` never closes a shared-tracker ticket. Between commit and merge no new tracker state is needed, because the branch still exists and the Claim still holds.

Parent/child uses only what the tool reference documents. Nothing in the ticket format may promise an invocation `gh` does not have.

## Acceptance

- No issue is created without explicit approval, and the proposed set survives a context reset.
- A `/design` run adds exactly one top-level issue to the tracker, whatever the ticket count.
- An incoming issue with no acceptance criteria is refused by `/implement` with the reason, and routed.
- A committed-but-unmerged ticket is off the frontier without any tracker write having marked it so.
- Every relationship the ticket format promises is one the tool reference documents.
- The tool reference's parent/child guidance is findable by someone looking for parent/child, not only by someone looking for blocking.
