---
owner: repository
title: 'feat(protocol): aep-version retires, and the entry stamp is the release'
status: resolved
blocked-by: [01]
part-of: retire
---

## Problem

With the hook reading the entry's `version`, the second version field has no
live reader on a current repository — but it is still declared by the router
template, named by the specification and the audit as an extension point, read
by the changelog's cursor section, and asserted by the suite. A retired field
still stated everywhere is not retired.

## Outcome

The router carries one version field whose release section states the entry's
exception: on every framework-owned file the stamp is the release that last
changed it, and on the entry it is the release, always, because every release
stamps it. The extension points shrink to the Deviations section alone
everywhere the set is stated — router, specification, audit set-aside. The
changelog's cursor reads the surviving field with unchanged mechanics, its
explicit re-stamp step gone, and a dated repair drops the orphaned field from
repositories whose audit would otherwise preserve it forever. The suite
asserts the entry template's stamp equals the specification's declared
version, so a release cannot ship without stamping the entry, and every
repointed guard was watched failing before it was trusted.

## Acceptance

- The router template and its installed copy declare `version` and no other
  version field, and the release section states the entry's exception.
- The specification's ownership clause and the router's opening paragraph name
  the Deviations section as the only extension point, and the audit sets aside
  exactly that.
- The changelog's cursor section reads the surviving field, and a dated repair
  under the next release drops the orphaned field where an audit finds it.
- A specification version bump without the matching entry stamp fails the
  suite naming both values.
- Frozen records keeping their `aep-version` mentions trip no repointed guard.
- The full suite passes.
