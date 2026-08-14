---
owner: repository
title: "feat(knowledge): a stage norm declares its stages in a field of its own"
status: resolved
blocked-by: []
part-of: settlement
---

## Problem

The record format requires a norm whose firing condition is `stage` to name which
stage, and says a stage no router row names fails the build. Nothing states the
field or the form, so the refusal cannot be written — and a norm labelled for a
stage that does not exist builds green and then never arrives anywhere, which is
the silent failure that requirement exists to prevent.

The residue is real rather than theoretical: several of the policies being
converted are read by four stages each, so a form carrying one stage per record
turns one rule into four copies of itself at conversion scale.

## Outcome

A norm declares its firing condition and, separately, the list of stages it fires
at. Asking which norms fire at a given stage is answered by a filter on that field
alone — no substring matching, no parsing inside a value. A norm that declares the
firing kind and names no stage is refused, as is one naming a stage the router
does not carry, and each refusal names the file and the id.

## Acceptance

- A norm declaring a firing condition of `stage` together with a list of stages
  builds, and the ledger records those stages as a list rather than as text.
- A norm declaring that firing condition and no list of stages fails the build,
  named with its file and its id.
- A norm naming a stage no router row carries fails the build, named with its
  file, its id, and the offending stage.
- A norm read by more than one stage is expressible as one record.
- Declaring the stages field on a record whose firing condition is not `stage`
  fails the build, named.
- The record-format page, the scripts page, and the canonical specification
  describe the same field, and the build asserts that they agree.
- Every assertion added is confirmed to fail against a deliberate reintroduction
  of the fault it names, with the reintroduction taken from the violation rather
  than from the implementation.
