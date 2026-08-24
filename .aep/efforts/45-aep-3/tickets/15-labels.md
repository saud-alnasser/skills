---
status: resolved
blocked-by: [14]
---

# feat(protocol): labels project the effort’s state onto the tracker

## Outcome

The issue and pull request carry the repository’s own labels. Derived labels re-sync on every write; initial ones are written once and never revised. The spec keeps its `status:` field and the label projects it, so the file wins when they disagree. A seeded label set ships for repositories that have none.

## Acceptance Criteria

- [x] Criterion 7: moving an effort from draft to accepted changes both objects from backlog to ready in the same step, the spec still carries its status, and editing either by hand and re-running corrects the label to match the file, never the reverse.
- [x] Criterion 8: the objects carry only labels that existed before the effort unless the run reported creating one and said why, and no label names AEP.
- [x] Criterion 9: a pull request changing a dependency manifest carries the dependencies flag; one firing the public-contract trip-wire carries the breaking-changes flag.
- [x] Criterion 10: a pull request going ready carries a size label matching the thresholds in that label’s own description, computed from the diff.
- [x] Requirement 15: `priority:` and any flag that invites another person are written once and never revised, and a human’s change is not overwritten.
- [x] `src/seed/labels.json` exists and carries the five families with descriptions that state a trigger.

## Relevant areas

`src/policies/execution.md`, `src/skills/specify.md`, `src/skills/implement.md`, `src/seed/labels.json` (new), `src/seed/references/github.md`.

## Constraints

A label is a marking of what the files say and never becomes the thing that says it. The repository outranks its projection.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

**Built.** `## Labels are markings, never state` in `policies/execution.md`, the two skills that write labels, `src/seed/labels.json`, the GitHub seed's own vocabulary table, and `section('labels')` in `verify.mjs` (38 assertions).

**The whole section turns on one distinction**, so it is asserted per family rather than as prose: `status:`, `type:`, `size:`, and most flags are derived and re-synced on every write; `priority:` and the flags that invite a person are initial and never touched again. A family that drifts to the wrong side reads exactly as well as one on the right side, which is why each is pinned individually and `priority:` is checked in both directions at once.

**The size thresholds are checked for gaps and overlaps, not just for presence.** A `size:` family reading *under 10 / 10-99 / 100-499 / 500-999 / 1000+* is checkable by anyone reading the tracker; one reading *a medium change* is not, and one whose bands skip 500 puts a diff in no band at all.

Six fire-checks, each confirmed to have changed its subject before the run:

| Broken deliberately | Fired |
| --- | --- |
| `priority:` moved from Initial to Derived | `priority:` is initial and not derived |
| `size: m`'s description reduced to prose | every size description states a line threshold; the thresholds do not overlap or leave a gap |
| a `flag: aep effort` label added to the seed | no seeded label names AEP |
| the `type` family deleted | the label seed carries five families |
| the runner told to re-derive `priority:` | the runner is told priority is not among them |
| the policy's prohibition inverted | no label AEP sets names AEP |

**`labels.json` needed a declaration, and it is not a `SEEDS` entry.** The seeds guard fired the moment the file appeared, which is what it is for. But every `SEEDS` entry has a path in the tree and this one never will: what it seeds lives in the tracker, not under `.aep/`. So `payload.mjs` exports `LABEL_SEED` beside `SEEDS`, and the guard accepts both, rather than either list growing a conditional for the other.

**One guard failed for a reason that had nothing to do with what it asserts.** The section reads structure -- paragraphs, and table rows anchored to line boundaries -- and this checkout is CRLF, so `split('

')` found one paragraph and every anchored regex missed. Line endings are normalised at the top of the section, with the reason written down; the rest of the suite reads phrases and is unaffected.

**Left for ticket 16.** `install` offering the seeded set, replacing a tracker's defaults on acceptance, and creating only what is missing in a repository that has its own labels (criterion 11 of the effort spec). Nothing here writes to a tracker.
