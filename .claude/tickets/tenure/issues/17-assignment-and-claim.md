# feat(coordination): assignment, claim, and the branch as the lock

Status: resolved
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

## Comments

**`claimed` left the lifecycle entirely.** It was a tracker state, and ADR 0013
puts nothing agent-level on the tracker — so `TICKETS.md` now runs `open`,
`blocked`, `resolved`, `obsolete`, and says explicitly that no `claimed` state
exists rather than quietly dropping it. Three assertions moved with it (tickets
03, 04, 14), which is what caught the change being incomplete.

**The branch name is `<ticket-id>-<slug>`.** The id leads so the ticket is
recoverable by reading to the first `-`, which is what makes recovery-from-
branch a read rather than a search. It is a Tenure default, so ADR 0008 applies
and a repository's existing convention wins — `.claude/tracker.md` gained a
`## Branch naming` slot for it, next to a new `## Assignment` slot for how this
repository records who owns delivery.

**A hand-back splits into two acts.** `Status: blocked` keeps the ticket off the
frontier; deleting the branch stops the clone holding a Claim on work nobody is
doing. Neither alone is enough. The branch is kept where a partial commit exists
— deleting it would destroy the evidence the hand-back exists to preserve, which
is the same reason the working tree is left alone.

**Every invocation was run, not recalled.** Verified against git 2.55.0 and gh
2.75.0: `git branch --show-current` (empty on a detached HEAD — a real answer,
and the reference says so, because empty otherwise reads as a failed command),
`git switch -c`, `git show-ref --verify --quiet`, `git ls-remote --heads`,
`git fetch --prune`, and the worktree refusal, reproduced in a scratch
repository: `fatal: '<branch>' is already used by worktree at '<path>'`, exit
128. On the `gh` side, `--add-assignee`/`--remove-assignee` and the `assignees`
JSON field.

**`gh issue develop` is documented as a trap rather than left out.** It is what
a reader reaches for on a GitHub repository, and it is wrong twice: it creates
the branch on the remote, which publishes, and it names it GitHub's way rather
than Tenure's. `--list` sees only branches it created, so it is not the claim
read either.

**Three assertions failed first on scoping, not content** — `Get-Section` only
scopes `## ` headings and the Claim is a `### ` subsection. Scoping was worth
keeping rather than widening: step 1 also carries the frontier and the obsolete
branch, both of which use the word "claim", so a whole-section search would have
passed on unrelated prose.
