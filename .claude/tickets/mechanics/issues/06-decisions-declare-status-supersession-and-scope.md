---
title: feat(skills): decisions declare status, supersession, and scope
status: resolved
blocked-by: [05]
part-of: mechanics
---

## Problem

The decisions policy already treats status as a field — it says only `status: superseded by NNNN` ever moves after a decision is committed — but the field is prose on a line near the top, present in two files and absent from the rest, and nothing reads it. So the one piece of metadata the policy declares load-bearing is the one nothing bears any load with.

Supersession is worse: it is stated in whichever direction the author happened to write, in whatever words. A reader opening the old file may learn it is dead; a reader opening the new one may learn what it replaced; nothing guarantees both, and nothing notices when only one exists.

And nothing anywhere says which area a decision governs, which is why the review stage reads the whole directory.

## Outcome

The decisions policy states the fields a decision declares: its status, what it supersedes and what supersedes it, the condition under which it should be loaded, and the area it governs. The policy says which of those the author writes and which only ever move afterwards, preserving the existing freeze — the reasoning is still frozen at commit, and only status still moves.

The supersession fields are a pair, and the policy states that both ends are written together. A one-sided claim is a defect the suite catches, not a stylistic preference.

The existing numbering rules are untouched: numbers and slugs are preserved across every move, because inbound references resolve by number.

## Acceptance

- The decisions policy names each declared field and says what it is for.
- The policy states that supersession is written at both ends in the same change, and that a one-sided claim is a defect.
- The policy states which fields are frozen at commit and which may still move, preserving the existing rule that only status moves.
- The policy states the load condition is a sentence about when to load, not a subject description.
- The existing preserve-the-number rule is unchanged and still stated exactly once.
- The shipped template and the format the policy describes agree with each other.
- The suite asserts the field set, the both-ends rule, and the freeze, with each guard confirmed to fail against a reworded restatement.
- The suite passes.

## Comments

"The policy states the load condition is a sentence about when to load" is met by **pointer**,
not by statement. Both this format and the context format had stated it independently, which is
one rule in two homes — forbidden by the repository's own standard, and caught by the review's
standards axis. The context format keeps the rule as its single home and this one adopts the
mechanism; a `$rulePattern` guard now fails the build if either restates it.
