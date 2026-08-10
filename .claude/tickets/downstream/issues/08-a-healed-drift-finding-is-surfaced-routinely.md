---
title: 'fix(knowledge): a healed drift finding is surfaced routinely rather than only by an audit'
status: open
blocked-by: []
part-of: downstream
---

## Problem

The evidence policy requires a healed finding to record its own consumption, in
the same change as the healing, written by whoever heals. Nothing surfaces one
that never got the line.

The only mechanism that looks is the configuration audit, and the migration
changelog instructs it to report and never repair — correctly, because inferring
whether a finding was consumed is a guess, and a wrong guess retires evidence
nobody acted on. The safe direction is right. What is missing is any *routine*
surfacing between full audits.

The consequence, observed: a configured repository carried a finding whose subject
had been fixed months earlier and whose decision record still described the
question as open. Nothing raised it until a full audit ran.

## Outcome

An unmarked finding is surfaced where findings are already read rather than by a
new mechanism. The design stage already routes through the evidence index and
opens the findings whose area it plans; the index is where an unconsumed finding
can be seen without opening anything, since waiting is read off the finding rather
than derived.

So the surfacing is a property of the index and the read that already happens, not
a new pass — a finding that is waiting and whose subject the current work touches
is raised at the moment somebody is positioned to answer it. The audit's
report-never-repair stance is untouched: this changes when an unmarked finding is
*seen*, never who may decide it was consumed.

## Acceptance

- An unmarked finding is visible from the evidence index without opening the
  finding.
- The design stage raises a waiting finding whose area the current work touches,
  rather than only reading the ones it planned to open.
- Nothing infers consumption; the audit's report-never-repair stance is unchanged.
- The suite fails when the index cannot distinguish a waiting finding from a
  consumed one, confirmed against a deliberate reintroduction and then restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
