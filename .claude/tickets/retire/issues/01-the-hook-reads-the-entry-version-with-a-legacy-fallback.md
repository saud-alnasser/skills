---
owner: repository
title: 'feat(hooks): the session hook reads the entry version, with a legacy fallback'
status: resolved
blocked-by: []
part-of: retire
---

## Problem

The release hook compares `aep-version` against the running manifest, and that
field is retiring. Repositories configured before per-file stamps existed
declare only the retiring field, and going silent on them reintroduces the
failure the hook was written to end.

## Outcome

The hook reads the entry file's `version` and compares it against the running
release — silent on match, one line naming the repair on mismatch, silent
outside a configured repository. Where the entry declares no `version`, the
hook falls back to `aep-version` and behaves exactly as today; where it
declares neither, the repository is unknown rather than stale, and silent.
Every branch is run directly before anything depends on it, as the hook's
first version was.

## Acceptance

- A router whose `version` differs from the running release produces the
  one-line warning; a matching one produces silence.
- A router with no `version` but an `aep-version` behaves exactly as before
  this change.
- A router declaring neither field, and a repository with no router, produce
  silence.
- The suite's hook fixtures cover the new read and the fallback, and each
  polarity was watched failing before it was trusted.
- The full suite passes.
