---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: rule
mode: [implement, review]
use-when: "committing, branching, or preparing work to land"
---

# Rule — version control

**This file is yours.** AEP installed it as a starting point because how work
lands is specific to this repository, and it is `owner: repository` so an upgrade
will never overwrite it. Correct anything below that this repository does
differently — what is here was detected or assumed at install, and detection is
not certainty.

## The line an agent does not cross

`[[protocol]]` states it: never push, never publish. What that covers:

| Allowed | Not allowed without the human asking |
| --- | --- |
| `git add`, `git commit`, `git branch`, local `git rebase`, `git worktree` | `git push` in any form |
| reading remotes: `git fetch`, and the forge's read commands | opening or merging a pull request |
| local `git tag` | pushing a tag, publishing a release, publishing a package |

*Why the line sits exactly there: a commit is reversible in this clone and
everything past it is not. That asymmetry is what makes committing unasked safe
and makes the prohibition load-bearing.*

## Commits

Conventional Commits — `type(scope): summary`.

- One logical change per commit. A summary needing "and" describes two commits.
- Say what capability changed and why. **Never a file-by-file account** — the
  diff already lists the files.
- Never `--no-verify`; never bypass signing. A failing hook is a finding, not an
  obstacle.
- **Committing is part of finishing.** `[[skills/commit]]` runs when work is
  reviewed and ready; it does not wait to be asked. What waits to be asked is
  everything in the right-hand column above.

## Branches

One branch per task, named `<task-id>-<slug>` — the id first, so the task is
recoverable from the branch name by reading up to the first `-`.

**The branch is the claim** (`[[policies/execution]]`): create it before the first
read of source, not after the first edit.

## How work reaches the default branch

This decides how a commit references its task, and getting it wrong is expensive:

| This repository | Then |
| --- | --- |
| a branch merged by a pull request a human writes | the commit references the task but **closes nothing** — a closing keyword in a commit fires on a later cherry-pick or rebase, closing something nobody merged. The keyword belongs in the pull request body |
| stacked changes, submitted by a stacking tool | the commit **carries the closing keyword** — it reaches the default branch only through its own branch's pull request, so the hazard above cannot arise |

**Confirm which applies rather than assuming.** With stacked changes,
`blocked-by` means *stack on top of*, not *wait for* — assume plain git on a
stacking repository and the frontier empties; assume stacking on a plain one and
branches get built on unmerged work that was supposed to wait.

## Pull request descriptions

Problem, solution, architectural impact, testing, related issues, breaking
changes. Never a commit-by-commit account.

---

`[[references]]` records the actual invocations — flags included. This rule says
what is required; a reference says how it is typed.
