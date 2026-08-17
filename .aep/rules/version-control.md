---
aep: 2.1.1
owner: repository
date: 2026-08-17
kind: rule
mode: [implement, review]
use-when: "committing, branching, or preparing work to land"
---

# Rule — version control

Corrected from the seed against this repository's actual history and remote.

## The line an agent does not cross

`[[protocol]]` states it: never push, never publish. What that covers:

| Allowed | Not allowed without the human asking |
| --- | --- |
| `git add`, `git commit`, `git commit --amend`, `git branch`, local `git rebase`, `git worktree` | `git push` in any form |
| reading remotes: `git fetch`, `gh pr view`, `gh issue list` | opening or merging a pull request |
| local `git tag` | pushing a tag, publishing a release |

*Why the line sits exactly there: a commit is reversible in this clone and
everything past it is not.*

## Commits

**Conventional Commits** — `type(scope): summary` — confirmed from the log, where
scopes name the surface changed (`protocol`, `configure`, `tracker`).

- Say what capability changed and why. **Never a file-by-file account.**
- Never `--no-verify`; never bypass signing.
- **Committing is part of finishing** — `[[skills/commit]]` does not wait to be
  asked. Everything in the right-hand column above does.

## How work reaches the default branch

**A branch, merged by a pull request a human opens.** Not stacked changes — there
is no Graphite configuration here.

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
the first one added, and it cannot get its own branch off the first without
stacking — which this repository has no tooling for. Sharing the branch is the
option that keeps every commit reviewable against something that exists.*

**The 2.0 rewrite is the standing exception**, and it is deliberate: it lives on
branch `2.0` as a **single commit**, and every further change **amends** that
commit rather than adding to it. Check `git show --stat` after an amend — an
amend here can pick up files no command staged.

## Pull request descriptions

Problem, solution, architectural impact, testing, related issues, breaking
changes. Never a commit-by-commit account.

---

`[[references/git]]` has the invocations; `[[references/build]]` has the checks
that must pass before a commit.
