---
title: 'feat(configure): the audit applies only the repairs a repository has not had'
status: resolved
blocked-by: [01]
part-of: changelog
---

## Problem

The audit re-checks every dated repair against every repository, because nothing
tells it which ones a repository has already received. The cost is not only the
work: a repair that can never be retired accumulates, and a list that grows by
one per release in prose grows invisibly.

The release field added alongside the session hook already records which release
wrote a repository's protocol. Nothing reads it.

## Outcome

The audit reads the changelog and considers only repairs from releases after the
one the repository declares. Each still confirms by content that the shape is
actually present before touching anything — the cursor narrows what is
considered, never what is verified.

A repository declaring no release has every repair considered. That is the
opposite of what the same absent field means to the session hook, which stays
silent, and the asymmetry is deliberate: a repository with no field predates the
field by definition, silence costs a notification, and a skipped repair costs a
broken repository.

A Decision records the cursor, the asymmetry, and why retiring a repair is now
unnecessary rather than merely unattempted.

## Acceptance

- An audit against a repository declaring a release considers only repairs from
  later releases, and says which it skipped.
- An audit against a repository declaring no release considers all of them.
- A considered repair still confirms the shape by content before acting.
- The current release has an entry in the changelog, and the suite fails when
  the shipped release has none.
- A dated repair reintroduced into the audit list or the migration page fails
  the build, and the guard is confirmed against a deliberate reintroduction.
- A Decision records the cursor and the two readings of an absent field.
- The specification describes the cursor and the standing-versus-dated split.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
