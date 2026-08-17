---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [specify, plan, implement, review]
use-when: "reading or writing GitLab issues, merge requests, or pipelines for this repository"
---

# Reference — GitLab

**This file is yours.** Installed because a GitLab remote or CI configuration was
detected. Correct it where this repository differs.

## Reading

```sh
glab issue view <id>
glab issue list --all
glab mr view <id>
glab ci status
```

Reading is always allowed; `[[policies/authority]]` still governs writing.

## Tasks as issues

```sh
glab issue create --title "<title>" --description-file <file>
glab issue update <id> --label <label>
glab issue close <id>
```

**Creating an issue publishes.** Write the whole set first, show it, get it
approved, then create.

## Referencing a task from a commit

```
Refs #123           references without closing
Closes #123         only where the commit reaches the default branch through
                    its own merge request
```

`[[rules/version-control]]` has the rule and the hazard behind it.

## Merge requests

Opening or merging is the **human's**. Prepare the description; do not submit.

## Failure handling

- `glab` unauthenticated reports the login command. Report it; do not attempt to
  authenticate.
- An operation not listed here is a gap — say so rather than guessing a flag.
