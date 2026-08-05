# A child branches from the Claim, and its change record drives integration

Worktree isolation branches from the repository's **default branch, not the parent session's `HEAD`**, unless the base ref is set to head. A child dispatched by `/implement` is working a portion of a claimed ticket, so a child that branches from trunk builds against the wrong tree and does it silently — the failure produces plausible code and an integration that looks routine. Branching from the Claim is therefore a configuration obligation, written by `/configure`, not a sentence in a skill anyone can forget.

**The change record is the manifest the orchestrator integrates by**, not a summary it reads afterwards. The child names what it changed and why; the orchestrator takes the child's workspace and integrates on that basis. Navigating by the record rather than by the branch alone is what makes the file-ownership half of a fan-out declaration enforceable — a branch diff says what moved, and only the record says what the child *believed* it was doing, so having both is what turns a boundary breach into something detectable instead of something merged.

So integration **reconciles the record against the child's actual diff before anything lands.** A path in the diff the record does not declare, or a path outside what that child was declared to own, stops the integration for the whole fan-out. Both are the same failure seen from the orchestrator's side: the manifest cannot be trusted to drive integration, and a manifest that cannot be trusted is worse than none, because it reads as a check that happened.

What lands is a **squash**, because `/implement`'s rule is one ticket, one commit, amended. A merge commit per child would make a fanned-out ticket structurally different in history from every other ticket, for no reader's benefit, and would break the amend that keeps the rule true.

The Claim's unit widens the way it already widened for stacks: **claiming the ticket claims every child worktree beneath it.**

## Considered Options

- **Squashing each child's branch blindly.** The obvious mechanism, and it was the first choice here. Rejected: git alone cannot tell a change the child was asked for from one it wandered into, so declared file ownership would be a comment rather than a constraint.
- **Trusting the record and not reading the diff.** Rejected in the other direction: a record that under-reports silently drops work, and the child is the last party that should be believed unchecked about its own boundary.
- **A real merge commit per child.** Rejected — it buys a history nobody reads and costs the one-ticket-one-commit invariant.
- **Children propose, the orchestrator re-implements.** Rejected: the orchestrator's window then absorbs every portion, which defeats the isolation that motivated fanning out.
- **Children sharing the parent's working directory with declared file ownership.** Rejected: nothing enforces the disjointness. Two children told to own different files still collide on a shared import or test helper, and the loser's edit vanishes with no error — the exact failure worktree isolation is documented to prevent.

## Consequences

**No partial integration.** If any child fails, or any reconciliation fails, nothing lands: a subset satisfies no acceptance criterion, and reviewing it would review a ticket that was never built. The successful children's worktrees are left in place holding their work — the cleanup sweep skips a worktree that still holds changes — so a resumed session continues rather than rebuilding.

Isolation is enforced rather than agreed: a worktree-isolated child's git commands fail if they redirect into the main checkout. A child cannot integrate itself even if instructed to, which is what makes the orchestrator the only integrator by construction.

**The record acquires a second reader and a second failure mode.** It was a hand-back; it is now load-bearing, so a vague one is a defect rather than a style problem, and the format has to be specific enough to reconcile against a diff.

Specification §20 is amended in the same change to make the orchestrator the only integrator, and to require the record be reconciled against the child's diff before anything lands.
