---
owner: repository
title: "feat(protocol): the router compresses to norm form and stage load lists become exact"
status: resolved
blocked-by: [01, 03]
part-of: crystallize
---

## Problem

The router template interleaves the Marker mechanics, the Receipt reasoning, and
the stage table with their full apologies, and its stage table is permissive — a
row is what a stage *may* read — so every stage load is a judgement call, and
mis-loads are one of the observed failure shapes.

## Outcome

The router template converts to framework-owned norm form. The stage table's
lists become mandatory and exact: a stage loads its whole row, rows are cut down
to what that stage's decisions actually depend on, and the sentence licensing
judged selection is gone. The entry table remains here as the always-on tier's
source of truth or moves wholly there — one home, whichever the specification
chose.

## Acceptance

- The router declares ownership and reads as norms with one-line whys; the
  Marker and Receipt semantics survive unchanged in meaning.
- Each stage row is a closed list; no text in the router or any policy tells a
  stage to choose among its guides.
- Every row's total load, measured, fits comfortably in a stage's opening
  context; the design row is materially smaller than today's.
- Conversion uses the manifest mechanism the pilot proved: norms inventoried,
  every row guarded and fire-checked, no norm dropped.

## Comments

Amended after resolution, at the user's direction during the crystallize/09
run: the router's ownership flipped `repository` → `framework`. The ticket's
original choice rested on the stage table being the repository's own
dependency set, but the census observed zero differing lines between template
and installed copy — the file was already law in fact. It now declares
`owner: framework` with two named extension points, the `aep-version` value
and the entries of a `## Deviations` section; ADR 0079 records the decision
and supersedes ADR 0054's per-repository derivation, the specification's
ownership and stage-table sections were amended in the same change, and the
configure audit sets the two points aside before its byte comparison so a
repository's deviations survive reinstall and upgrade.
