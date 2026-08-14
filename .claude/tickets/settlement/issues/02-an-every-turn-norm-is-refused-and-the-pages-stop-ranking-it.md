---
owner: repository
title: "feat(knowledge): an every-turn norm is refused, and the pages stop ranking it"
status: resolved
blocked-by: [01]
part-of: settlement
---

## Problem

The scripts page refuses a norm whose firing condition is `every-turn`, with a
reasoned paragraph behind the refusal, and the canonical specification agrees: the
boot tier stays files loaded by the harness, so a norm that must fire on a turn
nobody started has nothing behind the store to fire it.

Three places on the same pages assume such a norm exists anyway. It heads the
firing-breadth order that sorts norms among themselves, the record-format page
repeats that order, and a fixture case requires a store containing exactly such a
norm to build and produce a ledger. The store builder therefore ships seven of the
eight refusals its own page names, and reports the eighth as unmet.

## Outcome

A store containing a norm whose firing condition is `every-turn` fails the build,
named with its file and its id. The firing-breadth order covers only conditions a
record in the store can hold, and no fixture requires the refused shape to
succeed. The value stays in the closed vocabulary, so the refusal names it
specifically rather than reporting it as an unrecognised value — a reader who
moved a boot-tier rule into the store learns why it was refused, not merely that
the word was not on a list.

## Acceptance

- A store containing a norm whose firing condition is `every-turn` fails the
  build, named with its file and its id, and the message distinguishes this from
  an unrecognised firing condition.
- A firing condition outside the closed vocabulary still fails with its own,
  different message.
- No fixture case requires a store containing an `every-turn` norm to build.
- The firing-breadth order stated on the scripts page and on the record-format
  page name the same conditions, and none of them is one the build refuses.
- The store builder reports no unmet requirement against its own refusal table.
- Every assertion added is confirmed to fail against a deliberate reintroduction
  of the fault it names, with the reintroduction taken from the violation rather
  than from the implementation.
