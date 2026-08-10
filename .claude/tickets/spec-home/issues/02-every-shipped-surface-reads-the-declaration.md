---
owner: repository
title: 'fix(configure): every shipped surface reads the spec-layout declaration instead of asserting a path'
status: resolved
blocked-by: [01]
part-of: spec-home
---

## Problem

Four shipped surfaces assert that a spec is written to the flat designs
directory: the spec format policy, the ticket format policy, the design stage,
and the review stage.

Two of them are templates, so the assertion is installed into every configured
repository. The other two are stages, which nothing installs and no audit reads
back — a repository on the per-effort layout has been running both against a
location it does not use, and would never be told.

The spec format policy contradicts itself in the process: it asserts the flat
path near the top and states eighty lines later that the layout varies by
repository.

## Outcome

No shipped file says where a spec is written. Each one that needs the answer
names the declaration and stops, so a repository on either layout gets correct
behaviour from all four without any of them being edited per repository.

A reader who opens the spec format policy still learns where a spec goes without
opening a second file first — the pointer says the answer is repository-specific
and where it is kept, so stopping at the pointer cannot leave someone guessing the
default.

## Acceptance

- No shipped surface asserts where a spec is written.
- The spec format policy no longer contradicts itself about whether the layout
  varies.
- Someone reading only the spec format policy learns that the location is
  repository-specific and where it is declared.
- The design stage and the review stage locate a spec correctly under either
  layout.
- The suite fails when any of the four surfaces regains an asserted location.
  Each is confirmed separately against a deliberate reintroduction of its own
  original sentence and then restored — one guard covering all four passes while
  three are broken.
- No shipped file gained a citation that resolves only in the repository building
  AEP.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
