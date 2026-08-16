---
aep: 2.1.1
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, review]
use-when: "writing a commit message in this repository, or explaining why a release did or did not happen"
---

# Reference — semantic-release

**This file is yours.** Installed because semantic-release configuration was
detected. Record which branches release, and which plugins are configured —
those two facts decide everything below.

## The commit message is the release

Versions here are computed from commit messages, so **a commit message is not
documentation — it is an input to the released version number.**

| Message | Effect |
| --- | --- |
| `fix: …` | patch |
| `feat: …` | minor |
| any type with `!` after it, or a `BREAKING CHANGE:` footer | major |
| `chore:`, `docs:`, `refactor:`, `test:` | no release |

Confirm this against the configured preset before relying on it — a repository
may narrow or extend the set.

## Commands

```sh
npx semantic-release --dry-run   # what would be released, and why; changes nothing
```

**That is the only invocation to run locally.** A real run tags, publishes,
pushes, and opens release notes — it is CI's job, and it is irreversible
(`[[rules/version-control]]`).

## Failure handling

- "No release published" is usually correct: no commit since the last release
  carried a releasing type. `--dry-run` says which commits it considered.
- An accidental `feat:` on an internal change ships a minor version nobody
  intended. That is worth catching in review, because it cannot be taken back.
- A release that fails partway can leave a tag without a published artifact.
  Report it; never re-run the release to tidy it up.
