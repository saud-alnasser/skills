# 16 — feat(skills): a spent worktree is removed, and the orchestrator decides when

Status: resolved
Blocked by: —
Part of: mechanics

## Problem

Nothing in this framework ever deletes a worktree. Two rules say one is **kept** — a failed or stopped child's, so a resumed session continues rather than rebuilds — and no rule anywhere says when one stops being worth keeping. The harness creates them and nothing removes them, so every dispatched child leaves a full checkout behind for the life of the clone, including every child whose work landed hours ago.

The ignore rule keeps them out of the repository, which is why this has been invisible rather than absent: the cost is disk and noise in a directory nobody reads, and it grows once per dispatched ticket forever.

Nothing else can decide it. The harness knows a worktree exists and not whether the work in it reached a branch. A child cannot decide it — it is bound not to, and it is gone by the time the question is answerable. Only the party that integrated the work knows the work is safe elsewhere.

## Outcome

The build stage states when a worktree is spent and removes it: **once the work it held has landed** — integrated, committed, and therefore recoverable from the branch rather than from the checkout. A worktree that is spent holds nothing its branch does not.

The existing retention rule is untouched and is the boundary: a failed or stopped child's worktree is kept, because that is exactly what lets its ticket be resumed. Removal reaches what has landed and nothing that might still be resumed, so the two rules meet without overlapping.

The determination is the orchestrator's and is named as such — not the harness's, which cannot see whether work landed, and not the child's, which is bound against it and gone besides.

**The removal is never forced.** Git refuses to remove a worktree that still holds uncommitted or untracked work, and that refusal is a second opinion on the orchestrator's determination rather than an obstacle to it: a worktree that will not come away cleanly is one whose work had not, in fact, all landed. Forcing past it would destroy the evidence that the judgement was wrong.

The git guide carries the invocations, including what `prune` does and does not do, because a reader who assumes it removes directories will believe stale checkouts have been cleaned when only bookkeeping has.

## Acceptance

- The build stage states when a worktree is spent, in terms of the work having landed rather than of time passing or the child having exited.
- The stage states that the determination is the orchestrator's, and why neither the harness nor the child can make it.
- The existing rule that a failed or stopped child's worktree is kept survives unchanged, and the two rules are stated so that neither reaches the other's case.
- The stage states that removal is never forced, and gives git's refusal as the reason rather than as a caveat.
- The git guide carries the removal and listing invocations, and states that `prune` clears bookkeeping only and deletes no working directory.
- The invocations in the guide run as written against this repository.
- Removal is stated once, and no other file restates it — asserted by a single-home guard confirmed to fail against a restatement.
- The suite passes.
