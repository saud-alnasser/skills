---
title: 'fix(configure): the generated-index prohibition gains the mechanism it asserts'
status: resolved
blocked-by: []
part-of: downstream
---

## Problem

The specification says a generated file is never hand-edited and **the
prohibition is enforced** by comparing it against a regeneration. The scripts page
says **the suite** regenerates each index and compares it against what is
committed, so a stale index, a hand-edited one, or a drifted script all fail the
build.

There is no such suite in a configured repository, and none is specified. The
scripts page specifies exactly two scripts — the index regenerator and the
position report — and neither compares anything. The regenerator *writes*
indexes; nothing checks them afterwards. This repository satisfies the claim with
a private suite it does not ship.

Downstream, the claim is carried byte-for-byte in three installed policy files
while nothing in that repository's CI references the protocol directory at all.
Its indexes are correct because a human ran the script, which is exactly the
arrangement those three sentences say does not exist.

**And the directory is closed against fixing it locally**, correctly: the layout
names `.claude/scripts/` as derived, and the audit checks it in both directions —
every script the page specifies exists, and nothing sits there that it does not
specify. The all-derived model is deliberate. The gap is a missing entry on a
page, not a broken rule — but from inside a configured repository the reconciling
sentence is invisible, because it lives in the plugin's specification and the
installed knowledge carries no copy. A repository that hits the constraint sees a
prohibition with no rationale, and *the framework contradicts itself* is the
natural reading.

## Outcome

The enforcement is specified where the derived surfaces are specified, and it is
a step rather than a third script: regenerating and then failing on any resulting
difference needs no new derived surface, and keeps the all-derived model intact.
`/configure` installs it, and the audit re-checks it like anything else it
derives.

The step carries a fixture, because the enforcement is the thing three policy
files assert and it is currently the one claim built on the scripts that nothing
proves. **The fixture states that the tamper is staged.** A tamper left in the
working tree is erased by the regenerator before the comparison runs, so it
reports clean — and the session that tested it that way concluded the mechanism
misses hand edits and reported that. A wrong test of an enforcement produces a
confident wrong answer with nothing to check it against.

The derived-only rationale lands in the installed specification policy rather
than only in the plugin's, so a repository that hits the constraint can read why
it exists where it is standing.

The two asserting sentences name the mechanism instead of gesturing at a suite
that only one repository has.

## Acceptance

- The enforcement is specified on the page that specifies derived surfaces, and
  it introduces no new script.
- `/configure` installs it, and the audit re-checks it.
- The specification and the scripts page name the mechanism rather than asserting
  an unnamed suite.
- The fixture fails on a staged tamper and passes on a clean tree, and it states
  that the tamper is staged and why a working-tree tamper proves nothing.
- The installed specification policy carries the reason `.claude/scripts/` holds
  only what is derived.
- The suite fails when the asserting sentences name no mechanism, and when the
  fixture's tamper is unstaged — each confirmed against a deliberate
  reintroduction and then restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
