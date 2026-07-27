# feat(coordination): assignment, claim, and the branch as the lock

Status: ready-for-agent
Blocked by: —

## Problem

Claiming is currently a `Status: claimed` line written into the ticket. On a repository worked by several people, each running several instances, that does not do the one job claiming has: two instances read the same ticket, both write the claim, both build it, and neither finds out until the second pull request.

It also conflates two different facts under one word — which human owns delivering the work, and which instance is building it right now. ADR 0013 separates them and decides where each lives.

## Outcome

**Assignment** — which human owns delivery — is human-level, lives on the tracker, and is never Tenure's to write unasked. Because it separates humans, contention exists only ever within a single Assignment, and that is what makes a light claim mechanism safe rather than reckless.

**The Claim is the branch.** `/implement` claims by creating the ticket-named branch, before any work — not after the first edit, which is the same as not claiming. Git refuses to check one branch out in two worktrees, so exclusion is enforced rather than agreed. An instance that lost its context recovers what it was building by reading the current branch; another clone checks a claim by fetching.

A claim another instance holds is **never taken** — it is reported plainly and the frontier moves on. A claim this clone's own branch identifies is resumed or released freely, because it is not someone else's.

Branch naming becomes load-bearing and is Tenure's own convention, identical whichever tool creates the branch, rather than borrowed from any tool's default.

Nothing agent-level is written to the tracker.

## Acceptance

- Two instances given the same ticket in separate worktrees cannot both proceed, and the second is told why rather than failing obscurely.
- An instance resuming after losing its context recovers which ticket it was building without asking and without reading any file the repository does not carry.
- Claiming happens before the first edit, and a run that edits first is a failure the discipline names.
- A claim held elsewhere is reported, never taken.
- The tracker carries no fact about which instance is working.
- Every tracker invocation this ticket introduces exists in the tool reference, verified against the CLI rather than recalled.
