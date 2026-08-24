---
use-when: "committing, branching, or preparing work to land"
---

# Rule — version control

Corrected from the seed against this repository's actual history and remote.

## The line an agent does not cross

`[[protocol]]` states it: never push, never publish. What that covers:

| Allowed | Not allowed without the human asking |
| --- | --- |
| `git add`, `git commit`, `git commit --amend`, `git branch`, local `git rebase`, `git worktree` | `git push` of anything but the effort branch below |
| reading remotes: `git fetch`, `gh pr view`, `gh issue list` | **merging** a pull request |
| local `git tag` | pushing a tag, publishing a release |
| **pushing the effort branch, opening its pull request as a draft, and marking that draft ready** when the effort closes (below) | merging it, at any point, ready or not |

*Why the line sits where it does: a commit is reversible in this clone, and a
draft pull request is reversible on the remote. Everything past those two is
not.*

## What the runner may push

**For an effort the human opened, the runner pushes the effort branch and opens
its pull request as a draft.** It does not ask, and it does not wait to be told.

**It also marks that draft ready** at the one moment the effort is finished:
converge found no gap, so the run finalises the description and hands the work
over. Readying is how the run says it is done, and a run that could not say so
would need the human back for a click.

Stated here rather than left to be inferred from the invocation, because this is
the first irreversible act AEP performs and an agent reading only the table above
would have to reason its way past a flat prohibition to do the thing the runner
exists to do. A permission an agent has to derive is a permission it will
sometimes derive the other way.

The permission is exactly that wide. **Still the human's to give:**

- **merging** a pull request, draft or ready;
- **publishing a release**;
- **pushing a tag.**

*Why the line moved: `/implement` carries a whole effort with nobody in the room,
and the pull request is where the run keeps its memory — the ledger, the ticked
criteria, the converge round (`[[policies/execution]]`). A run that cannot push
has nowhere durable to write, so a killed session loses the run rather than
resuming it. Draft is what keeps the act reversible: nobody has been asked to
review, and a draft that gets closed is a draft nobody read.*

## Commits

**Conventional Commits** — `type(scope): summary` — confirmed from the log, where
scopes name the surface changed (`protocol`, `configure`, `tracker`).

- Say what capability changed and why. **Never a file-by-file account.**
- Never `--no-verify`; never bypass signing.
- **Committing is part of finishing** — `[[skills/implement]]` lands reviewed
  work without waiting to be asked. Everything in the right-hand column above
  does wait.

## How work reaches the default branch

**A branch, merged by a pull request a human opens.** Not stacked changes,
though not for want of tooling: `gt` is installed and this repository is
`gt init`ed against trunk `main`. **No branch has ever been tracked in it** —
`.git/refs/branch-metadata` does not exist and Graphite holds no pull request
info — and every merge in the log is a flat squash from a single branch. The
shape below is what the history demonstrates, not what the tooling permits.

So a commit **references a task without closing it**: a closing keyword in a
commit fires on a later cherry-pick or rebase and closes something nobody merged.
The keyword belongs in the pull request body, which a human writes.

The log shows merged pull requests append their number — `… (#34)` — which is
GitHub's squash-merge doing it, not something to write by hand.

Consequently `blocked-by` means **wait until that task is resolved**, in the
plain-git sense.

## Branches

One branch per effort or task, named for the work.

**A chain of efforts that build on unmerged work shares one branch**, named for
the first of them. Each effort still lands as its own commits, and the branch
opens one pull request.

*Why: the second effort cannot branch from the default branch without losing what
the first one added, and its own branch off the first is a stack — which the
tooling here supports and this repository has never once used. Sharing the branch
is the option that keeps every commit reviewable against something that exists
without making this repository the first place to try stacking.*

Reconsider that when a chain actually appears. Until then the flat shape is the
one every merge in the log was reviewed under.

**An effort branch carries one commit per ticket.** `aep-3` is the working
example: each ticket lands its own commit and further work on that ticket amends
that commit rather than adding beside it.

Check `git show --stat` after any amend — an amend here can pick up files no
command staged.

*The 2.0 rewrite used to be named here as a standing exception, a single amended
commit on a branch `2.0`. That branch exists neither locally nor on the remote,
and the rewrite is in `main`. The exception was removed rather than kept as
history, because a rule read for instructions is the wrong place to keep a
finished one.*

## Pull request descriptions

Problem, solution, architectural impact, testing, related issues, breaking
changes. Never a commit-by-commit account.

---

`[[references/git]]` has the invocations; `[[references/build]]` has the checks
that must pass before a commit.
