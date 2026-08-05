---
title: feat(skills): the commit stage writes both halves, and a stage may re-stamp the tree
status: resolved
blocked-by: [03]
part-of: mechanics
---

## Problem

The commit stage advances the marker, and it writes one fact. With a second fact in the file, a commit stage that writes only the commit leaves a stale tree beside a fresh commit — which is worse than writing neither, because the pair would then claim a tree nobody fingerprinted.

Nothing yet gives any other stage permission to write anything, so the second writer the rule allows does not exist in any skill. Until one does, the tree fact is inert: after a commit the tree is clean, and the first edit afterwards invalidates the marker exactly as it does today.

## Outcome

The commit stage writes both facts when it advances the marker, in one write, so the pair is never half-fresh.

The stages that read drift gain the re-stamp: having read both drift sources and dealt with what they found — healed it, or judged it outside what the work touches and said so — the stage writes the tree fact alone and leaves the commit fact untouched. A stage that read drift and did neither does not re-stamp, and the skill says which of the two it did.

The verification report already required of every stage is where the dealing becomes visible, so re-stamping does not introduce a new thing to say — it attaches to something the stage was already obliged to state.

## Acceptance

- Committing writes both facts together, and a run that advances the marker leaves neither stale.
- A stage that reads drift and heals or discounts it writes the tree fact and leaves the commit fact unchanged.
- A stage that reads drift and neither heals nor discounts it writes nothing.
- Which of the two happened is visible in the verification report that stage already opens with.
- Working through two consecutive stages against an unchanged dirty tree reads that tree's drift exactly once.
- Changing the tree between two stages causes the second to read drift again.
- The re-stamp is stated once, in the place the permission belongs, and no stage restates it — asserted by a single-home guard confirmed to fail against a reworded restatement.
- The suite passes.

## Comments

The single-home guard went into the suite's `$singleHome` table rather than `$rulePattern`.
The two are not interchangeable: `$rulePattern` membership additionally asserts that a rule
must *not* appear in the protocol file, because those are the rules that fire every turn. The
re-stamp permission is router machinery and belongs there, so filing it in `$rulePattern` made
`tenure/16` report it as an unconditional rule that had leaked. It sits beside the Marker
cache-validity rule, which is in that table for the same reason.
