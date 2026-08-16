---
aep: 2.1.1
owner: repository
date: 2026-08-16
kind: reference
mode: [specify, plan, implement, review]
use-when: "reading or writing GitHub issues, pull requests, or checks for this repository"
---

# Reference — GitHub

Corrected from the seed. The remote is `github.com/saud-alnasser/skills`.

## This repository has no task tracker in use

AEP 2.0's work is not tracked in GitHub Issues. Efforts and their tasks live
under `.aep/efforts/`, and there is nothing to mirror — **do not create issues to
represent AEP tasks** unless a human asks for it.

That makes most of the seeded issue workflow inapplicable here; it is kept below
only for the case where a human does ask.

## Reading

```sh
gh repo view --json nameWithOwner,defaultBranchRef
gh pr view <number> --json number,title,body,state,files
gh pr checks <number>
gh issue view <number> --json number,title,body,state,labels
```

Reading is always allowed. `[[rules/boundary]]` still applies: read another
repository freely, write to none.

## Pull requests

Opening or merging is the **human's**, never an agent's
(`[[rules/version-control]]`). Prepare the body; do not submit it.

Merges here squash and append the pull request number to the subject — `… (#34)`.
That is GitHub doing it. **Never write the number by hand**, and never put a
closing keyword in a commit body: on this repository a commit reaches the default
branch through a squash-merge that a human performs, so the keyword belongs in
the pull request description.

## If issues are ever used

```sh
gh issue create --title "<type(scope): summary>" --body-file <file>
gh issue edit <number> --add-label <label>
gh issue close <number> --reason completed
```

**Creating an issue publishes.** Write the whole set first, show it, get it
approved, then create.

## Failure handling

- `gh` unauthenticated fails with a message naming the login command. Report it;
  do not attempt to authenticate.
- A rate limit is a wait, not a reason to scrape the web UI.
- An operation not listed here is a gap — say so rather than guessing a flag
  (`[[rules/engineering]]`).
