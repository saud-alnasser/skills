---
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
- **Committing is part of finishing.** `[[skills/implement]]` lands work when it is
  reviewed and ready; it does not wait to be asked. What waits to be asked is
  everything in the right-hand column above.

## Branches

One branch per ticket, cut from the branch its effort is on and named
`<effort>/<ticket-id>-<slug>`, where `<effort>` is the effort directory's own
name: `51-branch-scope/03-execution-policy`.

**The namespace is what makes the name unique**, and uniqueness across efforts
is required (`[[policies/execution]]`). Ticket ids restart at `01` in every
effort, so two efforts each holding a ticket `03` want one bare `03-<slug>` for
two different claims. Under a runtime that gives each thread its own worktree,
git refuses the second outright; without one, the second run quietly takes a
claim the first is already holding. The namespace also gives a fresh branch an
effort before it has any commits: the first segment is an effort directory name,
and that is the only signal a branch with nothing on it carries.

**Existing branches keep the names they have.** The convention is forward-only:
a branch already called `03-execution-policy` still resolves to its effort by
what its commits touch, and renaming one breaks the claim whoever is on it
holds.

**The branch is the claim** (`[[policies/execution]]`): create it before the first
read of source, not after the first edit.

## How work reaches the default branch

Two things turn on which of these a repository does, and getting either wrong is
expensive. The first is how a commit references its task:

| This repository | Then |
| --- | --- |
| a branch merged by a pull request a human writes | the commit references the task but **closes nothing** — a closing keyword in a commit fires on a later cherry-pick or rebase, closing something nobody merged. The keyword belongs in the pull request body |
| stacked changes, submitted by a stacking tool | the commit **carries the closing keyword** — it reaches the default branch only through its own branch's pull request, so the hazard above cannot arise |

The second is where a new effort's branch starts, and it is the same row that
answers it. `[[skills/specify]]` reads this rule rather than branching from
whatever `HEAD` happens to be checked out:

| This repository | A new effort's branch is based on |
| --- | --- |
| a branch merged by a pull request | the default branch's tip, fetched first. An effort opened from another effort's branch carries that effort's unmerged commits, and its pull request then asks for a review of work nobody in it wrote |
| stacked changes | the current branch, which is what stacking means. The parent change is reviewed on its own branch and lands through its own pull request |

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
