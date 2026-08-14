---
owner: repository
title: "feat(delivery): a stage row is assembled and inlined before the stage reads anything"
status: resolved
blocked-by: [18, 19]
part-of: substrate
---

## Problem

A stage loads its guides as whole files, and only about half of what arrives is labelled
for the stage that loaded it. The rest is paid for and ignored — and because it is
coherent, topically-adjacent prose, it is the worst distractor class there is.

Selecting what to load cannot be handed to the model: judged selection is the mis-loading
that caused sessions to re-ask settled questions, and it was removed for that reason.

## Outcome

A stage's row is assembled from the store and inlined before the stage's own content
reaches the model — no round trip, no judgement, no opportunity to choose. The row is every
norm whose firing condition matches this stage, arriving in computed precedence order.

The assembler emits the row as several commands, each below the measured substitution
limit, because a single command above it is withheld and replaced by a preview and a path —
which is the exact round trip this decision exists to remove. It chooses its failure mode
deliberately and says which: unguarded, a failing command takes the stage offline loudly;
guarded, the row arrives with error text inlined as prose and nothing reporting it. Neither
branch is safe, so the choice is made once, in the open, and exercised by a fixture.

## Acceptance

- A stage receives only the norms whose firing condition matches it, and a reader of the
  delivered row can tell which stage it was assembled for.
- The row arrives inline, ahead of the stage's own content, with no preview and no path
  anywhere in it.
- A row larger than a single substitution's limit is delivered whole, in several commands.
- The row arrives in precedence order, and reordering the store does not reorder the row.
- A failing assembler command produces the documented failure mode, demonstrated by a
  fixture that makes a command fail.
- The measured substitution limit is asserted by a fixture, so a limit that moves fails the
  build rather than silently truncating a row.
- A norm labelled for a stage that does not exist fails the build, naming the norm.

## Comments

**The failure-mode fork was decided here rather than left open, and the decision is reversible.**
The outcome required the assembler to choose deliberately and say which; it did not say which
branch. **Unguarded** was chosen: a failing command aborts the stage and the stage receives
nothing, its own instructions included. The alternative — guarding, so the row arrives with the
shell's error text inlined as prose and nothing reporting it — was rejected because a stage
running on a row that contains an error message will act confidently on norms it does not have,
and nobody sees it. A stage that did not start is a fault somebody fixes.

Both branches are bad and the page says so. A repository preferring the other one declares a
deviation rather than editing the choice quietly, which is what keeps the reversal visible.

**Every criterion is met at specification level and none of the fixtures has been run** — the
same terms as `18`, `19`, `21` and `22`, because nothing here can run them until `/configure`
derives the script. Case C is the one worth naming: the substitution cap is specified as a
fixture rather than a constant, so the figures this effort measured become something the build
re-checks instead of something it remembers.
