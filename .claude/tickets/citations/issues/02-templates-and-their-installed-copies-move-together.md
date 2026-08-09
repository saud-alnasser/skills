---
title: 'refactor(configure): templates and their installed copies stop citing this repository'
status: resolved
blocked-by: [01]
part-of: citations
---

## Problem

Ten citations are written **verbatim into other people's repositories**. A
repository configured by AEP receives a protocol file, an entrypoint, and
several policies that cite decision records it has never had — numbered on the
same scheme its own records use, so they are not even recognisable as foreign.

Fifteen more sit in this repository's copies of those same files. They are not a
separate problem: a copy is required to match its template, so they move when
the templates do or the pair stops agreeing.

## Outcome

A freshly configured repository receives no reference it cannot follow.

Each template and its installed copy change together and still agree. The
derived guides are left alone — they are written per repository from that
repository's own facts, so a citation in this repository's copy is read in this
repository, where it resolves.

## Acceptance

- No template contains a reference that resolves only in this repository.
- Each template and its installed copy still agree.
- The derived guides keep their citations, and the distinction between a copied
  guide and a derived one is what decides it rather than the file's directory.
- A repository configured from these templates receives no unfollowable
  reference, checked against what the templates would write rather than against
  this repository's copies.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
