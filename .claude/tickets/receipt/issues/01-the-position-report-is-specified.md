---
owner: repository
title: 'feat(skills): the position report is specified as behaviour, with a fixture'
status: resolved
blocked-by: []
part-of: receipt
---

## Problem

`skills/configure/SCRIPTS.md` specifies one script and opens by saying so — "one
script, written in the language this repository already uses, producing every
generated index." The page is named for the directory but scoped to the
regenerator, so a second derived script has nowhere to be described.

There is a second one to describe, and nothing yet says what it must emit, what it
must refuse, what it records, or how it behaves when the run identity is
unavailable. Without a fixture, a wrongly derived one produces a self-consistent
wrong answer that nothing downstream can contradict — a freshly configured
repository has nothing to compare a first run against.

## Outcome

The page covers the directory it is named for: what every derived script owes,
then one section per script. The regenerator's specification moves under that
structure with its content intact rather than being rewritten.

The position script's behaviour is specified completely enough to be derived in
another language without reading anyone's implementation — which is the whole
point of `0060`, and why this lands with **no implementation beside it**: a
reference implementation becomes the de facto contract, and ambiguities in the
prose get settled by reading code nobody promised to keep aligned.

**The script emits the position half only.** Which contexts route, whether a
pointer resolves, whether a claim contradicts source — none of that is
mechanisable, and the specification says so, so no later reader mistakes the
script's silence on them for a gap.

A worked fixture and its exact expected output ship with it.

## Acceptance

- The page's structure covers the directory: shared obligations, then one section
  per script. The regenerator's specification survives with its content intact.
- The position script's section states the reads it makes, the exact report for
  both the matching and the differing case, all three refusals, the receipt's four
  fields, and the fallback when the run identity is absent.
- The specification states that the script emits the position half only, and names
  the judgement half as the stage's.
- Each refusal states what it does not license, not only what it found.
- The fallback is contract, not aside: a run without the identity produces the
  weaker attestation **and says which mode it ran in**.
- A worked fixture and its exact expected output are on the page.
- No implementation of the position script is added by this ticket.
- Shipped text cites only what resolves where it is read.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

**One deviation from the spec as approved: the receipt's third field is `head`,
not `commit`.** The marker file already carries a field called `commit`, so a
receipt field of that name reads as an echo of the marker — and the question the
commit stage asks is the opposite one, whether a receipt attests the position that
is live now. The spec was still `draft` and was corrected in the same change, with
the reason stated where the field is defined. Nothing else about the shape moved.

**The fire-check found one guard vacuous and it was rewritten.** "The position
report specifies the reads it makes" read the whole page, and the fixture restates
the specification's own vocabulary as expected output — so deleting a read from
the contract left the guard green, because the word survived in the fixture. Three
further guards had the same scoping and were narrowed with it. Two block-reading
guards had already been caught by the same defect during authoring, when an
unscoped read counted a fixture case as a fourth refusal.

That is the third time in this effort's neighbourhood that a guard passed while
what it existed to catch sat in the tree, each time because it read a wider region
than the claim it was making. All ten guards were then confirmed to fail against a
deliberate reintroduction and the page restored byte-identical.
