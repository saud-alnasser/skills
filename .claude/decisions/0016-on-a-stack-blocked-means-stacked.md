---
status: accepted
load-when: a blocked ticket is being scheduled on a stacking repository
sources: [.claude/policies/version-control.md]
supersedes: []
superseded-by: []
---

# On a stack, blocked means stacked, not waiting

`Blocked by: 01` means *wait until 01 is resolved* on a plain git repository. On a repository using stacked changes it means *stack on top of 01*, and waiting is precisely what the tool exists to avoid.

Keeping one rule would stall the pipeline. Tenure commits but never merges, so ticket 01 sits committed-and-unmerged until the human acts; under the plain-git rule every dependent ticket is off the frontier, the frontier empties, and `/implement` has nothing to do. Graphite would make the framework strictly slower than plain git.

So on a stacking repository **a ticket joins the frontier once its blockers are committed**, not merged. `/implement` checks out the blocker's branch and creates the new one on top of it.

The rest of the model already fits. `tools/graphite.md` records that one branch is one commit's worth of reviewable change — the same rule `/implement` reaches independently by amending so that one ticket stays one commit — and `gt modify` is the safer amend, because it restacks descendants where `git commit --amend` leaves them pointing at the old commit. One root issue with sub-issues (ADR 0014) maps onto one stack with branches. `gt submit` and `gt sync` are already blocked as publishing, and `gt sync`'s deletion of merged branches releases the Claim in the same human action that closes the ticket.

## Consequences

**The Claim's unit is the stack, not the branch** (ADR 0013). `gt modify` and `gt restack` rewrite every descendant, so an instance working one branch rewrites the branches above it — other tickets' Claims. Git's worktree rule turns that into a loud failure rather than corruption, but the conclusion stands: a stack belongs to one instance, and claiming a branch in it implicitly claims everything upstack. Parallel instances need separate stacks off trunk.

**`Closes #NN` moves into the commit body here**, reversing ADR 0014's split. A branch's commit reaches trunk only by merging its own pull request, so the cherry-pick hazard that pushed the keyword out of commit messages does not exist. It also has to move: `gt submit` prompts for pull request metadata interactively and offers no flag to supply a body from a file or stdin, so Tenure cannot pre-write one. Whether `gt` prefills the description from the commit message is **not yet verified** and needs a docs fetch before it is relied on.

A rejected review low in a stack invalidates every branch above it. `/implement` says so when it stacks, because that is the cost being accepted on the user's behalf.
