---
owner: repository
title: 'feat(skills): configure derives every specified script, not only the regenerator'
status: resolved
blocked-by: [01]
part-of: receipt
---

## Problem

The configuration stage writes one script because one was specified. With a second
on the page, a stage that still writes one leaves every configured repository with
a commit gate whose input nothing produces — and the failure surfaces at the first
commit, in a stage that cannot fix it.

The audit branch has the same shape: it checks what it was told to check, so a
script it does not know about is a gap that reads as a pass.

## Outcome

The stage derives every script the page specifies, in the repository's own
language, and runs each against its fixture before it is run against anything
real — the one check whose answer was not produced by the thing being checked.

The audit covers the directory against the page rather than a named file, so a
third specified script is a gap the audit reports rather than one it is silent
about.

Position gains a member by the category rule rather than by a new exception, which
is what `0012` named the category for.

## Acceptance

- The stage derives every script specified on the page, and a repository
  configured from scratch has both.
- Each derived script is run against its fixture during configuration, and a
  mismatch stops the stage rather than being reported and passed.
- The audit covers the scripts directory against the page and names a specified
  script that is missing.
- The receipt is ignored by the position category rule, with no entry naming it
  individually.
- The suite fails when the stage derives only the regenerator, and when the audit
  stops covering the second script — each confirmed against a deliberate
  reintroduction, then restored.
- Shipped text cites only what resolves where it is read.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
