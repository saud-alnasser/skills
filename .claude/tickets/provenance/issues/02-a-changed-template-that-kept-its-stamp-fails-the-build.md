---
owner: repository
title: 'feat(verify): a changed template that kept its stamp fails the build'
status: resolved
blocked-by: [01]
part-of: provenance
---

## Problem

A provenance stamp nothing enforces rots silently, and a stamp that has rotted
misleads the exact reader it exists for. Nothing currently notices a
framework-owned template whose content moved while its declared release stayed
behind.

## Outcome

The suite catches the lie at authoring time. It locates the most recent release
commit in history, and any framework-owned template whose content differs from
that release must carry a stamp newer than that release's version and no newer
than the currently declared one. A template unchanged since the release passes
untouched — its stamp is part of the unchanged content. When no release commit
can be found, the check names the condition and fails rather than guessing.

## Acceptance

- Editing a framework-owned template's content without moving its stamp fails
  the suite, and the failure names the file.
- Editing one and moving its stamp into the open range passes.
- A template untouched since the most recent release passes regardless of how
  old its stamp is.
- A stamp ahead of the currently declared version fails.
- A history with no findable release commit fails with the condition named,
  rather than passing with nothing bounded.
- The full suite passes.

## Comments

**Accepted, on review: the check is release-granular, and the first acceptance
line overpromised.** Both review axes found that a template already stamped
with the current version passes further edits in the same cycle. That is the
stamp's semantics, not rot: the file still last changed in this cycle, so the
stamp stays true, and no bump is owed. Enforcement bites at every release
boundary — the moment a release closes the cycle, an unbumped edit is refused.
Read the first acceptance line as: an edit that leaves the stamp at or below
the last release fails. Recorded so the next review does not re-raise it.
