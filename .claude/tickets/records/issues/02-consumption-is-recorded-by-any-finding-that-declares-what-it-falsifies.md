---
title: 'fix(knowledge): any finding declaring what it falsifies records its consumption'
status: open
blocked-by: []
part-of: records
---

## Problem

A finding whose drift has been healed carries a line saying where the healing
landed, so a healed finding and a waiting one are distinguishable without opening
whatever each falsified. That obligation is stated under the drift heading and
phrased in terms of drift.

Every kind of finding can declare what it falsifies — the field is required of
all of them, and the generated index has a column for it. So a research finding
that falsifies something and is then acted on falls outside the obligation's
wording while being inside its purpose.

One such finding exists now: it declares what it falsifies, the ticket it
falsified is resolved, and that ticket's own comments cite the finding as what
lifted its block. It carries no consumption line, so every design run over that
area reads it as waiting and pays the cost the line was written to remove.

## Outcome

The obligation is stated in terms of the field a finding declares rather than the
kind it happens to be, so a reader of any finding knows whether it is owed a
consumption line without deciding which heading governs them.

The one finding whose consumption is establishable from a resolved ticket citing
it carries its line, with its account untouched. No other finding is marked:
widening the rule does not make an unchecked finding consumed, and leaving one
unmarked reads as waiting, which is the safe direction.

## Acceptance

- The consumption obligation reaches any finding that declares what it falsifies,
  and states its scope by that field rather than by kind.
- A reader of a non-drift finding can tell whether it is owed a line.
- The finding whose consumption is establishable carries its line, naming where
  the healing landed.
- That finding's account is byte-identical to before — nothing about what was
  checked, when, or against which commit moved.
- No other finding gained a line.
- The suite fails when a finding declaring what it falsifies is consumed with no
  line recorded, confirmed against a deliberate reintroduction and then restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
