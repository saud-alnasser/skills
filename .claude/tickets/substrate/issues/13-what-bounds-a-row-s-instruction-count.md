---
owner: repository
title: "docs(protocol): settle what bounds a row's instruction count"
status: resolved
blocked-by: [04]
part-of: substrate
type: grilling
---

## Question

The suite bounds a stage row in **characters**. The measured predictor of a norm
arriving and being silently skipped is the **number of simultaneous instructions**.
What instrument bounds the second, and at what value?

**That there is such a bound is settled** — it is part of the composite chosen in
[`which-substrate-design-the-six-findings-support`](../../../evidence/discussions/2026-08-13-which-substrate-design-the-six-findings-support.md).
What it counts and what it permits is not.

Surfaced by
[`what-a-norm-corpus-must-look-like-to-actually-be-followed`](../../../evidence/research/2026-08-13-what-a-norm-corpus-must-look-like-to-actually-be-followed.md).
IFScale finds that "models overwhelmingly err toward omission errors as instruction
density increases", with primacy effects peaking around 150–200 instructions and the
best frontier models at 68% accuracy at 500. This repository measures 222
norm-shaped imperatives across 132,172 characters of protocol corpus — about 595
characters each — putting a row at the current 68,000-character `/review` bound at
an estimated 100–115 simultaneous instructions.

**The two bounds diverge under ADR 0089**, which is why this cannot ride on the
existing one. Filtering a row by `fires-when` removes prose a stage cannot use,
which cuts characters hard and instruction count much less. A row can pass a
tightened character bound with its density untouched, and the compliance risk
unmoved.

Settle:

- **What counts as one instruction.** Once ADR 0085's spans are records, a norm is
  a record and counting is a query — but a record holding three imperatives in one
  span counts as one, and whether that is right is the question the fidelity floor
  already circles.
- **What the bound permits, and how it is derived.** The current character bounds
  were set by observation and ratcheted; a count bound set the same way inherits
  the same weakness — the drift finding on the `/review` row records what a
  ratchet without a structural fix costs.
- **Whether the response to a row over the bound is to cut the row or to cut the
  corpus.** The discussion left this genuinely open: fewer norms is the other
  answer to the same measurement, and it is the one nothing in this effort has
  costed. **`08`'s item 6 has since measured the first half and it did not work** —
  see below.
- **Whether ordering within a row is declared.** Primacy is measured, so position
  in the payload is not neutral. If a row is a filter result, its order is
  currently whatever the query returns.

## Evidence bearing on this

- `.claude/evidence/research/2026-08-13-what-a-norm-corpus-must-look-like-to-actually-be-followed.md`
  — the density curve, the omission finding, the primacy peak, and this
  repository's measured counts. Its own limitation is load-bearing here: **no
  accuracy figure at ~100 instructions was obtained**, so whether AEP's rows sit
  in the degradation band is inferred from the curve's shape rather than read off
  it.
- AEP has no detector for a norm that arrived and was not applied. The Marker,
  verification at use, and drift findings all catch knowledge that is *wrong*.
  Filtering the row is the only lever the design currently has against a norm that
  was correct, present, loaded, and skipped — which is what raises the stakes on
  this bound above tidiness.
- `.claude/evidence/prototypes/2026-08-14-does-a-fires-when-filtered-row-deliver-what-implement-needs.md`
  — **the lever was measured and it is weaker than assumed.** Filtering
  `/implement`'s row by `fires-when` cuts 34.7% of characters but only **27.4% of
  norm-shaped imperatives, 168 to 122**: the prose it removes is disproportionately
  the *why* clauses ADR 0074 requires, not the imperatives themselves, so density
  barely moves. The filtered row does not fall below the 100–115 band this ticket
  was opened about. **This does not settle the ticket; it removes one of its
  answers** — a smaller row is measured to be insufficient on the largest row, so
  the count bound cannot ride on ADR 0089's filter and the corpus half is now the
  live half.

## What the measurement changes

**The two bounds diverge harder than the ticket assumed, and in the stated direction.**
The concern above was that a row could pass a tightened character bound with its
density untouched. Measured, that is not a hypothetical: 34.7% of characters against
27.4% of imperatives on the same row, and the residue is still ~122 instructions.

## Answer

Settled with the user on 2026-08-14, after the measurement rather than before it.
Recorded as **ADR 0093**.

- **The response to a row over its count is fewer norms, not a smaller row.** Chosen
  against the measurement: the row-cut was costed at 168 → 122 imperatives and does not
  clear the band. The corpus is where the remaining work is.
- **A record is one instruction, and a record carrying more than one imperative fails the
  build.** This unifies the count with ADR 0085's addressable span instead of adding a
  second unit, and turns the counting rule into a forcing function for *the smallest span
  that is correct alone* — a discipline 0085 wanted and could not check. Much of the
  corpus fails it today; under *cut the corpus* the failures are the worklist.
- **The count is reported, never thresholded.** A ratchet was rejected on this
  repository's own drift finding; a literature-derived number was rejected because
  IFScale's per-density figures were never obtained.
- **A row arrives ordered by ADR 0086's computed precedence**, highest-ranked binder
  first, with non-binders as a defined tail. Primacy is measured, so a filter result's
  natural order spends a real effect on nothing.

One defect closed on the way: ADR 0023 and ADR 0085 both called something *the fidelity
floor*. They are complementary and are now named apart — **the id carries the addressing
floor, the suite carries the compression floor**.
