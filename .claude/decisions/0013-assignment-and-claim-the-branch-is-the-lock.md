---
owner: repository
status: accepted
load-when: who is building a ticket right now has to be recorded somewhere
sources: [skills/implement/]
supersedes: []
superseded-by: []
---

# Assignment is human; the Claim is the branch

Coordination has two levels, and conflating them is what made the original single `Status: claimed` unable to serve either.

**Assignment** — which human owns delivering a ticket — lives on the tracker and is theirs. How they deliver it, and with how many instances, is not Tenure's business. **Claim** — which instance is building it now — is scoped *inside* one Assignment.

The invariant that falls out is what makes a light mechanism safe: **contention exists only ever within a single Assignment.** Two humans cannot race, because assignment already separated them. Only one human's own instances can collide, and that is a much smaller problem than the general one.

**The Claim is the branch.** `/implement` claims by creating the ticket-named branch, before any work. Git refuses to check one branch out in two worktrees, so exclusion is *enforced* rather than agreed — the one piece of the mechanism that does not depend on an instruction being followed. Reading the current branch is how an instance that lost its context knows what it was building; another clone checks a claim by fetching.

A claim another instance holds is **never taken**. It is reported, and the frontier moves on. A claim this clone's own branch identifies is not someone else's, so it is resumed or released freely.

## Considered Options

- **A Position file mirroring the claim.** Rejected once it became clear a working tree has exactly one checked-out branch: two instances sharing a clone are already on the same branch and the same files, so a claim file would not have saved them, and instances that are genuinely independent are in separate worktrees where git already refuses the overlap. The file was a second copy of a fact git holds, with no rule for which wins when they disagree.
- **An `in-progress` label, or a comment naming the branch.** Rejected: both put agent-level bookkeeping on a human surface. A label carries no identity — it says taken, never by whom — and it reintroduces the triage-vocabulary collision that separating the two vocabularies removed.
- **The assignee as the claim.** Rejected because it resolves to a person, not a working tree. It is the right primitive for Assignment and the wrong one for a Claim.
- **Claim purely in Position.** Rejected: mutual exclusion cannot be done by state no one else can read.

## Consequences

**Branch naming becomes load-bearing.** It has to encode the ticket, it is Tenure's own convention rather than one borrowed from a tool's default, and it must be identical whether the branch comes from `git` or from `gt create`.

Work on a detached HEAD has no Claim, and neither does uncommitted work before the branch exists — so claiming is the first act, not a step after discovery.

Nothing agent-level is ever written to the tracker, which keeps a Tenure-worked repository legible to teammates who have never heard of it.

Where stacked changes are in use the unit is the stack rather than one branch (ADR 0016).
