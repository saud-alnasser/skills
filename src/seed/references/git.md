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
git worktree add .aep/worktrees/<task-id> -b <task-id>-<slug>
git worktree list
git worktree remove .aep/worktrees/<task-id>
```

Worktrees are infrastructure, never knowledge. `.aep/worktrees/` is gitignored.

## What is never run

`git push` in any form, and anything that publishes as a side effect.
`[[rules/version-control]]` has the boundary and the reason.

## Failure handling

- **A `fatal:` you did not expect means a check was skipped** — treat it as a bug
  in the run, not as the answer to the question you were asking.
- A detached HEAD holds no claim. Do not guess the task from the diff.
- An operation no section above covers is a gap: say so rather than guessing a
  flag (`[[policies/engineering]]`).
