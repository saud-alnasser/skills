---
owner: repository
title: "feat(configure): a shipped script is copied code, and the plugin gains a script home"
status: resolved
blocked-by: [01]
part-of: conversion
---

## Problem

Every script AEP depends on is specified as behaviour for a repository to re-implement, on
three supports. Two are gone: plugin independence is superseded outright, and the
regenerate-and-compare check that made a re-implementation enforceable in any language
retired with the committed indexes it compared. What is left is a page describing five
scripts that nobody has written, in a form that makes writing them somebody else's job.

The remaining objection to shipping code — a copy in every repository diverges when the
shipped one changes — was unanswerable in 1.x because nothing could see both sides. It is
answerable now, and until the change is made the specification carries a contract its own
reasoning no longer supports.

The two homes also collide. The directory that would hold shipped scripts is the same one
holding this repository's own build, and they are different categories: one ships, the
other tests what this repository produces.

## Outcome

The scripts specification documents code the plugin carries rather than behaviour somebody
re-implements, and says which of the five exist yet. A configuration run copies rather than
derives, and the obligation to prove each script against a fixture before trusting it moves
to the build — a copy cannot be mis-derived, so the check that existed for mis-derivation
has no subject.

The plugin gains a home for shipped scripts, and this repository's own build moves out of
its way, so every top-level directory ships except one.

## Acceptance

- The scripts specification describes each script as shipped code, names the release each
  was introduced in, and states plainly which are not yet written.
- No instruction anywhere tells a configuration run to derive, re-implement, or fixture-check
  a script.
- The canonical specification's layout describes the script directory as copied rather than
  derived.
- This repository's own build lives outside the shipped set, and the build asserts that
  every top-level directory except that one is shipped content.
- The decision that required derivation is closed at both ends against the one that replaces
  it.

## Comments

**The two templates were the findings, and they were the whole point of the ticket.** The
Spec axis found `policies/specs.template.md` and `protocol.template.md` still describing a
derived script after every page a reader of *this* repository would open had been converted.
Those two are the files that install into somebody else's repository, so leaving them was
shipping the superseded contract while claiming to have retired it. Both are fixed;
`specs.template.md`'s version stamp moves 1.20.0 → 2.0.0 because its content moved.

**The guard was green while silent against the form the violation actually takes.** The first
pattern matched only *derives a script* and not *a script derived into*, which is the wording
both templates used — so the assertion passed over the two live breaches it was written to
catch. Fire-checking found it; reading it would not have. It now matches both directions,
with a negative lookahead for *tool*, *guide*, and *policy*, which are still derived and must
stay derivable.

**The Standards axis did not run, and this is the record that it did not.** Two dispatches
died on API 529, and the run continued at the user's instruction rather than retrying a third
time. What that axis would have found — a contradiction with an accepted decision, a boundary
crossed — is **unrecorded rather than absent**: the Spec axis returned clean on its own terms
and says nothing about standards. A later ticket in this effort touching the same files gets
the axis it missed.

**Editing `protocol.template.md` is authoring, not healing.** It declares `owner: framework`,
which forbids editing it *where it is installed*. Here it is the source the framework ships
from, and this ticket is the change that framework law exists to be changed by. Recorded
because the frontmatter reads identically in both places and the distinction is the only
thing separating a legitimate edit from the one the law prohibits.
