---
owner: repository
title: feat(skills): a consumed drift finding records where it was healed
status: resolved
blocked-by: []
part-of: mechanics
---

## Problem

A drift finding that has been healed and one still waiting sit in the same directory in the same shape. The design stage is obliged to read waiting findings during discovery, so it reads both and re-derives which is which by opening the knowledge each one falsifies.

This is not hypothetical. The design that produced this effort did exactly that: the single finding on disk had already been healed, in the policy it falsified, and establishing that cost two file reads and a question put to the human that should never have been asked. The cost recurs on every design run and grows with the directory.

The evidence policy already has the concept — durable findings graduate, and a discussion stays on disk as the record of what was weighed — but it has no way for the file itself to say which side of that it is on.

## Outcome

The evidence policy states that a drift finding records its consumption: that it was healed, and where the healing landed. The finding's own text stays frozen — it is the dated record of a check, and rewriting it destroys what it was kept for — so the consumption is recorded as a field beside it rather than as an edit to the account.

The policy states who writes it: whoever heals the finding, in the same change as the healing, for the same reason a correction lands in the commit that falsified the statement. A finding healed in one change and marked in another has a window where it reads as waiting.

The design stage's discovery step reads the unconsumed findings, which is now a thing it can ask rather than a thing it derives.

## Acceptance

- The evidence policy states that a drift finding records whether it has been consumed and where the healing landed.
- The policy states the finding's own account is frozen and that consumption is recorded beside it, not by editing it.
- The policy states that the mark lands in the same change as the healing, and why a later mark is not equivalent.
- The design stage's discovery step reads unconsumed findings, and says so in terms that do not require opening a consumed one.
- Answering whether a given finding is still waiting requires reading only that finding.
- The finding this effort's design encountered is marked consumed, naming where it was healed.
- The suite asserts the policy's statements and that the design stage reads the unconsumed set, with each guard confirmed to fail against a reworded restatement.
- The suite passes.

## Comments

The installed evidence policy was adopted here rather than in 13. Not a scope decision taken
freely: `scaffolding/05` asserts that policy body-identical to its template, so shipping the
template alone turns the suite red, and this ticket's own last criterion is that the suite
passes. Ticket 13 keeps the protocol file and the git guide; the evidence policy is done.
