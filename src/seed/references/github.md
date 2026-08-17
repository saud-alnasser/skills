---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [specify, plan, implement, review]
use-when: "reading or writing GitHub issues, pull requests, or checks for this repository"
---

# Reference — GitHub

**This file is yours.** Installed because a GitHub remote was detected. Correct
it where this repository differs.

## Reading

```sh
gh issue view <number> --json number,title,body,state,labels
gh issue list --state open --limit 50
gh pr view <number> --json number,title,body,state,files
gh pr checks <number>
gh repo view --json nameWithOwner,defaultBranchRef
```

Reading is always allowed. `[[policies/authority]]` still applies: read another
repository freely, write to none.

## Tasks as issues

Where this repository keeps AEP tasks in GitHub Issues rather than under the
effort:

```sh
gh issue create --title "<type(scope): summary>" --body-file <file>
gh issue edit <number> --add-label <label>
gh issue close <number> --reason completed
```

**Creating an issue publishes.** It lands in other people's workspace, so it is
gated exactly as opening a pull request is: write the whole set first, show it,
get it approved, and only then create — root first, then children, then the
links.

## Referencing a task from a commit

Which form to use is `[[rules/version-control]]`'s, and it depends on how work
reaches the default branch:

```
Refs #123          a reference that closes nothing
Closes #123        only where the commit reaches the default branch through
                   its own branch's pull request
```

A closing keyword in a commit stays live: a later cherry-pick or rebase closes an
issue nobody merged.

## Pull requests

Opening or merging a pull request is the **human's**, never an agent's
(`[[rules/version-control]]`). Prepare the body; do not submit it.

## Failure handling

- `gh` unauthenticated fails with a message naming the login command. Report it;
  do not attempt to authenticate.
- A rate limit is a wait, not a reason to switch to scraping the web UI.
- An operation not listed here is a gap — say so rather than guessing a flag.
