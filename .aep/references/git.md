---
aep: 2.1.1
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, review]
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
git worktree add .aep/worktrees/<task-id> -b <task-id>-<slug>
git worktree list
git worktree remove .aep/worktrees/<task-id>
```

`.aep/worktrees/` is gitignored by `.aep/.gitignore`. Worktrees are
infrastructure, never knowledge.

## What is never run

`git push` in any form, and anything that publishes as a side effect.
`[[rules/version-control]]` has the boundary and the reason.

## Failure handling

- **A `fatal:` you did not expect means a check was skipped** — treat it as a bug
  in the run, not as the answer to the question you were asking.
- A detached HEAD holds no claim. Do not guess the task from the diff.
- An operation no section above covers is a gap: say so rather than guessing a
  flag (`[[policies/engineering]]`).
