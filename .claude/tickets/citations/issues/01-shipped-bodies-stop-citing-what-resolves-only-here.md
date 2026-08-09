---
title: 'refactor(skills): shipped bodies stop citing what resolves only here'
status: resolved
blocked-by: []
part-of: citations
---

## Problem

Skill bodies and dispatched roles carry references to this repository's own
records — ADR numbers, the specification, its sections. A model running AEP in
some other repository reads them and can follow none of them.

The release changelog is the same case wearing a better disguise: its recovery
citations name ADRs and commits in this repository, and its subject being AEP's
own history does not make a commit hash followable anywhere else.

## Outcome

Nothing under the shipped surfaces references a record that exists only here.

The rule is stated once, on the surface it governs, as a test rather than a
list: a shipped file may reference only what resolves in the repository reading
it. Paths AEP installs pass. This repository's records do not.

The changelog's recovery evidence moves to the effort's own tickets, so a
maintainer auditing a release assignment can still reach it and the shipped file
carries none of it.

Upstream attribution is untouched — it is a licence obligation, and it is
provenance rather than navigation.

## Acceptance

- No file under the shipped surfaces references an ADR, the specification, or
  one of its sections.
- The suite fails when one is added, matching the shape of such a reference
  rather than the specific ones removed, and is confirmed against a deliberate
  reintroduction.
- Every upstream attribution is present and unchanged.
- References to paths AEP installs are untouched and still resolve.
- The recovery evidence for each release assignment is reachable from the
  effort's tickets.
- No sentence lost a reason a citation was carrying.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
