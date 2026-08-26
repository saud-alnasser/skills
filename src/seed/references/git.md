---
use-when: "running any git operation — reading state, branching, staging, committing, or working with worktrees"
---

# Reference — git

**This file is yours.** Installed as a starting point because every repository
uses git slightly differently. Correct it where this repository differs; an
upgrade will not overwrite it.

## Reading state

```sh
git status --porcelain=v1        # machine-readable; empty output means clean
git rev-parse HEAD               # the current commit
git log --oneline -30            # detect this repository's commit convention
git branch --show-current        # the branch, and therefore the claim
```

**Detect before asserting.** Before writing a commit message, read the recent log
and follow whatever convention is already there.

## The diff under review

A review's subject is the **working tree**, not only what is committed — work is
reviewed before it is committed, so a commit-range diff alone is empty on the
path that matters most.

```sh
git merge-base <base> HEAD       # compare against this, not the raw ref
git diff <merge-base>..HEAD      # committed
git diff                         # unstaged
git diff --staged                # staged
git ls-files --others --exclude-standard   # untracked
```

Comparing against the merge-base rather than the raw ref keeps commits that
landed on the base branch since this work started from being attributed to it.

## Branching

```sh
git branch --list <name>                       # claimed here?
git ls-remote --heads origin <name>            # claimed elsewhere? fetch first
git switch -c <task-id>-<slug>                 # claim it
```

**Check both sides before creating.** A claim held elsewhere is never taken.

## Staging and committing

```sh
git add -A                       # or name paths explicitly
git commit -F <message-file>     # a file, so the message survives shell quoting
git commit --amend -F <message-file>
```

Prefer `-F` over `-m` for anything multi-line: quoting rules differ between
shells and mangle the body silently.

## Worktrees

```sh
# Anchored on the main checkout, because the path is what decides a run's role.
# Relative, git resolves it against the cwd, which nests one surface in another.
# <main> is the first entry of `git worktree list --porcelain`.
git worktree add <main>/.aep/worktrees/<effort>/<ticket-id>-<slug> -b <effort>/<ticket-id>-<slug>
git worktree list
git worktree remove <main>/.aep/worktrees/<effort>/<ticket-id>-<slug>
```

The branch name carries the effort as a namespace. Ticket ids restart at `01` in
every effort, so a bare `03-shared-id` is a name two efforts can both want.

Worktrees are infrastructure, never knowledge. `.aep/worktrees/` is gitignored.

### The run's own surface

The run holds its effort branch in a worktree too, not only its children. **Create
the branch and the worktree in one act:**

```sh
git worktree add -b <effort> .aep/worktrees/<effort>/_run <base>
```

Two commands would leave a window in which the branch exists and nothing holds
it, and that window is where another run checks it out.

### Releasing it, and removing it

**Detach first, then remove**, and run the removal **from the repository root**
rather than from inside the surface:

```sh
git -C .aep/worktrees/<effort>/_run switch --detach   # frees the branch, keeps the directory
git worktree remove .aep/worktrees/<effort>/_run      # from the root, not from inside
```

Detaching frees the branch at once, so whoever reviews the effort can check it
out, and it succeeds even where removal fails. **Releasing the branch is the part
that is not optional.** A process cannot remove the directory it is standing in,
which is why the second command is run from elsewhere.

Leaving surfaces behind is the way this pattern fails in practice, so removal is
part of finishing rather than housekeeping.

### What git refuses, and what it does not

Against a branch a worktree holds, these fail, and the message names the holder:

```
git worktree add <path> <held>     fatal: '<held>' is already used by worktree at ...
git switch <held>                  fatal: '<held>' is already used by worktree at ...
git branch -f <held> <commit>      fatal: cannot force update the branch '<held>' ...
```

**Meeting one of these is the mechanism working**, never an error to route
around: it means another run holds that claim.

Two things it does not cover:

- **`git update-ref refs/heads/<held> <commit>` moves a held branch** with no
  complaint. The refusals sit on the porcelain, not on the ref.
- **A second clone refuses nothing.** The guarantee stops at this clone.

## What is never run

`git push` in any form, and anything that publishes as a side effect.
`[[rules/version-control]]` has the boundary and the reason.

## Failure handling

- **A `fatal:` you did not expect means a check was skipped** — treat it as a bug
  in the run, not as the answer to the question you were asking.
- A detached HEAD holds no claim. Do not guess the task from the diff.
- An operation no section above covers is a gap: say so rather than guessing a
  flag (`[[policies/engineering]]`).
