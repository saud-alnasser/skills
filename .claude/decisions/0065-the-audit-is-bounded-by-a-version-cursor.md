---
owner: repository
status: accepted
load-when: a repair is being added to the configuration stage, or which repairs an audit should run is in question
sources: [skills/configure/migration-changelog.md, skills/configure/SKILL.md, skills/configure/MIGRATION.md, .claude/decisions/0064-the-release-check-is-a-hook-because-only-shipped-content-knows-the-release.md]
supersedes: []
superseded-by: []
---

# The audit is bounded by a version cursor, and dated repairs have one home

Repairs the configuration stage performs because of *which release* configured a repository move into `skills/configure/migration-changelog.md`, grouped by the release that produced the shape each one repairs. The audit reads `aep-version` from the repository's protocol file and considers only entries newer than it.

The problem was not that the repairs were wrong; it was that none of them recorded a release. Ten of them had accumulated across two shipped files — three as bullets in the audit list, seven as sections in the migration page — with nothing to distinguish a repair for one historical shape from a check true of every repository forever. So the audit ran all ten every time, nothing could be retired, and the list grew by one per release in prose that read identically to the standing checks around it. The most recent addition joined without its author noticing there was a category to join.

**The split is by trigger, not by subject.** A conversion fires when detection finds a shape that was never AEP's, or was AEP's own directory layout; a catch-up fires when a version is behind. Those are different questions with different inputs, and interleaving them is what made "where does a new repair go" unanswerable.

## Considered Options

- **Version-group inside the migration page**, adding no file. Rejected: conversion and catch-up stay interleaved, so the ambiguity that produced the mess survives the cleanup.
- **Generate the file from a declared field on each spec.** The mechanism this repository reaches for by default, and unavailable: nothing declares which release an effort landed in, and adding that field is a larger change than the one it would serve. Worth revisiting if this file proves its worth.
- **Leave the repairs where they are and add a changelog that only points.** Rejected: the same repair named in two places is the second home this framework exists to prevent, and the audit stays cumulative.
- **Retire the repairs that can no longer apply.** Rejected as unnecessary rather than wrong — the cursor skips them, and judging that no reachable repository is still in some shape is a claim about repositories nobody can inspect.

## Consequences

**A hand-maintained file is safe here, and the reason is narrow.** This repository generates its indexes and compares them byte-for-byte because an index over a directory rots when the directory moves. A release entry cannot rot: it describes something already shipped and frozen. The only failure available is a *missing* newest entry, which one assertion catches.

**An absent `aep-version` means opposite things to the two readers.** The release hook stays silent, because calling a repository stale on no evidence is worse than saying nothing. The audit considers every repair, because absence proves the repository predates the field. Both follow from the same asymmetry in cost: silence loses a notification, a skipped repair loses the repository.

**The assignments govern the future, not the present.** The field arrived one release before this one, so every repository that could need any of these ten declares nothing and receives all of them regardless of how they are filed. That is what makes it safe to assign historical releases from recovered evidence rather than from records that were never kept.

**A repair filed under too late a release never fires again, and reports success.** The worst failure this shape allows, and invisible. Two mitigations: every assignment cites what it was recovered from, and where the evidence is thin the earliest plausible release wins — an over-eager repair is a no-op, a skipped one is not.
