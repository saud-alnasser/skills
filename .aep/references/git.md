---
use-when: "running any git operation here — reading state, branching, staging, committing, or working with worktrees"
---

# Reference — git

Corrected from the seed against this repository. Plain git; no stacking tool, no
package manager, no CI-driven release.

## Reading state

```sh
git status --porcelain=v1        # machine-readable; empty output means clean
git rev-parse HEAD
git log --oneline -30            # this repository's commit convention lives here
git branch --show-current
```

Line endings are pinned to LF by `.gitattributes`, so a CRLF warning on `git add`
is git normalising as configured — not a defect, and not something to work
around.

## The diff under review

A review's subject is the **working tree**, not only what is committed — work is
reviewed before it is committed, so a commit-range diff alone is empty on the
path that matters most.

```sh
git merge-base main HEAD
git diff $(git merge-base main HEAD)..HEAD    # committed
git diff                                       # unstaged
git diff --staged                              # staged
git ls-files --others --exclude-standard       # untracked
```

Comparing against the merge-base rather than `main` directly keeps commits that
landed on `main` since this work started from being attributed to it.

## Branching

```sh
git branch --list <name>                       # claimed here?
git ls-remote --heads origin <name>            # claimed elsewhere? fetch first
git switch -c <task-id>-<slug>
```

**Check both sides before creating.** A claim held elsewhere is never taken.

## Staging and committing

```sh
git add -A
git commit -F <message-file>                   # a file, so the body survives quoting
git commit --amend -F <message-file>
git commit --amend --no-edit                   # keep the message, take the tree
```

Prefer `-F` over `-m` for anything multi-line: quoting rules differ between
shells and mangle the body silently.

**After any amend, check what actually landed:**

```sh
git show --stat HEAD | tail -5
```

An amend here can pick up files no command staged. Verifying costs one command;
discovering it later costs the commit.

## Worktrees

```sh
git worktree add .aep/worktrees/<effort>/<ticket-id>-<slug> -b <effort>/<ticket-id>-<slug>
git worktree list
git worktree remove .aep/worktrees/<effort>/<ticket-id>-<slug>
```

The branch name carries the effort as a namespace. Ticket ids restart at `01` in
every effort, so a bare `03-shared-id` is a name two efforts can both want
(`[[rules/version-control]]`).

`.aep/worktrees/` is gitignored by `.aep/.gitignore`. Worktrees are
infrastructure, never knowledge.

### The run's own surface

The run holds its effort branch in a worktree too, not only its children
(`[[policies/execution]]`). **Create the branch and the worktree in one act:**

```sh
git worktree add -b <effort> .aep/worktrees/<effort>/_run <base>
```

Two commands would leave a window in which the branch exists and nothing holds
it, and that window is where another run checks it out.

### Releasing it

**Detach first, then remove.** Separate acts, and the order is not
interchangeable:

```sh
git -C .aep/worktrees/<effort>/_run switch --detach   # frees the branch, keeps the directory
git worktree remove .aep/worktrees/<effort>/_run      # run from outside that directory
```

Detaching frees the branch at once, so whoever reviews the effort can check it
out. It also succeeds where removal fails, and removal fails routinely: a process
cannot remove the directory it is standing in, which on Windows is absolute.
**Releasing the branch is the part that is not optional.**

### What git refuses, and what it does not

Against a branch a worktree holds, these fail, and the message names the holder:

```
git worktree add <path> <held>     fatal: '<held>' is already used by worktree at ...
git switch <held>                  fatal: '<held>' is already used by worktree at ...
git branch -f <held> <commit>      fatal: cannot force update the branch '<held>' ...
```

**That is the guarantee, and it is the whole of it.** Meeting one of these is the
mechanism working rather than an error to route around: it means another run
holds that claim, and `[[policies/execution]]` says a claim held elsewhere is
never taken.

Two things it does not cover, stated because a reader who believes otherwise is
worse off than one who knows:

- **`git update-ref refs/heads/<held> <commit>` moves a held branch** with no
  complaint. The refusals sit on the porcelain, not on the ref.
- **A second clone refuses nothing.** The guarantee stops at this clone
  (`specs.md` section 18.2).

## What is never run

`git push` in any form, and anything that publishes as a side effect.
`[[rules/version-control]]` has the boundary and the reason.

## Failure handling

- **A `fatal:` you did not expect means a check was skipped** — treat it as a bug
  in the run, not as the answer to the question you were asking.
- A detached HEAD holds no claim. Do not guess the task from the diff.
- An operation no section above covers is a gap: say so rather than guessing a
  flag (`[[policies/engineering]]`).
