---
owner: repository
title: 'feat(configure): a configured repository declares which spec layout it uses'
status: resolved
blocked-by: []
part-of: spec-home
---

## Problem

The scripts specification tells the derived index regenerator that a repository's
tracker policy says which of the two spec layouts applies. Nothing writes that
declaration: no template gives the tracker policy such a section, and no step of
the configuration stage derives one.

So the instruction dangles. Every repository AEP has configured either uses the
default layout by accident or, like the one that builds AEP, was hand-edited
afterwards to say what the template never asked for.

## Outcome

A repository configured from scratch states where its specs live, in the guide
that already carries its other per-repository facts. The configuration stage
derives the statement by reading the tree, the same way it derives which tracker
and which branching model apply — never by asking.

An audit run re-checks it, so a repository whose tracker policy predates the
section gains one instead of keeping a declaration nothing wrote.

## Acceptance

- A repository configured from scratch declares which spec layout it uses, and a
  reader can tell which from that guide alone.
- The declaration is derived from the tree, not asked about, and a repository
  holding neither shape gets the default rather than a blank.
- The regenerator's existing instruction resolves — the section it was already
  told to read now exists.
- An audit run reports a missing declaration and adds one, and reports nothing on
  a repository that already declares it.
- The suite fails if the tracker template loses the section, confirmed against a
  deliberate removal and then restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
