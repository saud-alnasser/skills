---
status: accepted
load-when: whether a stage should prompt before committing is in question
sources: [skills/implement/]
supersedes: []
superseded-by: []
---

# `/implement` commits after `/review` without asking

`/implement` runs `/review`, applies the fixes, and then commits through `/commit` — no "commit and resolve this ticket?" prompt. The standing prohibition on pushing, opening pull requests, and submitting stacks is unchanged and is what keeps this safe.

The prompt was buying nothing. One ticket is one commit, and further changes amend it rather than stacking new commits, so answering "not yet" and answering "yes, then change something" converge on an identical tree. The user was being asked to choose between two paths to the same place, once per ticket.

## Considered Options

**Keeping the ask** is the status quo. Rejected as friction with no corresponding safety: nothing is published, and every effect is locally reversible.

**Committing automatically unless a gate fires** — review found something it could not fix, the diff touched a boundary the ticket did not name, or an acceptance criterion is unmet — was the closest alternative and was rejected as under-specified. Unless every gate is genuinely checkable it degrades into "ask when unsure", which is always. The gates worth having are already `/review`'s job, and a review that cannot resolve something should say so rather than route through a commit prompt.

## Consequences

`CLAUDE.md`'s "Committing is asked for; pushing … is the human's call" no longer describes what happens and is corrected in the same effort. The line separating what Tenure may do from what only a human may do moves from *commit* to *push*, which is where it was always doing the real work.

A user who wants to inspect before anything enters history loses that point. They keep every recovery — amend, reset, or discard — and the commit is never published without them.
