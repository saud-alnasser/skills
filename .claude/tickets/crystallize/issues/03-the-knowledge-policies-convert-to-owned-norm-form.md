---
owner: repository
title: "feat(policies): the knowledge policies convert to framework-owned norm form"
status: resolved
blocked-by: [01]
part-of: crystallize
---

## Problem

The policies governing knowledge — what Context holds, the ADR bar, the
evidence lifecycle, knowledge ownership, and the map format — are essays with
the norms interleaved, own no declared owner, and carry no extension points, so
a configured repository that needs a variation has no channel but editing law.

## Outcome

The knowledge-family policy templates are rewritten to norm form, declare
`framework` ownership with the release stamp, and name their extension points
where repositories genuinely vary. Facts that belong to a repository leave the
policy text for the extension form the specification defines.

## Acceptance

- Each converted policy opens with its ownership frontmatter and reads as
  imperatives and tables, each with its one-line why.
- Every extension point is named in the file that owns it, with the form a
  repository's declaration takes.
- Each file's norms are inventoried in a manifest before rewriting; every
  manifest row has a suite guard, and every guard is fire-checked.
- This ticket is the pilot: on its first file, a seeded norm deletion fails
  the suite with that norm's name before any further conversion proceeds, and
  the proof is recorded.
- No converted policy contains a fact true of only one repository.

## Comments

The variation census for this family returned zero rows: all five installed
copies were byte-identical to their templates, and the specification names no
per-repository fact inside them — repository facts these policies touch are
already delegated by pointer to the tracker policy. Census-derived means zero
observed variation ships zero extension points, so none were named; the
deviation channel remains the escape hatch if variation appears.
