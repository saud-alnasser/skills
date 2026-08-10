---
owner: repository
title: "feat(policies): the tickets, specs, and sub-agents policies convert to norm form"
status: resolved
blocked-by: []
part-of: crystallize
---

## Problem

The whole-effort review found ticket 04 partially delivered: the tickets,
specs, and sub-agents policies were stamped `owner: framework` and byte-locked
but not rewritten to norm form — tickets.md is unchanged at 16.5k characters
of essay-with-norms prose and is the largest guide on the `/design` and
`/implement` rows, where the knowledge family's conversion bought −20% to
−43%.

## Outcome

The three remaining delivery policies read as norms with one-line whys, under
the manifest mechanism the pilot proved, with the suite's ~70 pins on their
text preserved or knowingly updated in the same pass — the reason this was
split out rather than rushed at the end of the effort's run.

## Acceptance

- Same conversion criteria as the knowledge family: manifest per file, every
  row fire-checked, no norm lost, byte-locked pairs maintained.
- The `/design` and `/implement` row loads drop measurably further, and the
  row bounds in the suite ratchet down to hold the gain.

## Comments

Converted under the manifest mechanism: crystallize/04's existing rows still
run against the new text, complementary rows complete the inventory, and
every new or reshaped guard was watched failing against a seeded mutation.
The drop is single-digit (−5.3% across the trio) — a departure from the
knowledge family's −20% to −43%, recorded rather than forced: the trio was
already pin-dense from earlier efforts, and much of its mass is mechanism,
where clarity is never traded for compression. The gain is held by per-stage
row ceilings and a ratcheted design-turn bound; the numbers live beside the
assertions in the suite. The delta review's mutation test then exposed one
manifest row that could not fail — its pattern matched a different norm's
tail — and the row was re-anchored to its own subject and fire-checked.
