# 03 — feat(skills): the protocol's marker check compares both halves

Status: resolved
Blocked by: 01, 02
Part of: mechanics

## Problem

The protocol template carries the marker check every stage runs, and it is written as a comparison plus a condition — commit equals HEAD, and the tree is clean. Under the rule ticket 01 states, that second clause is no longer what is being asked, and the template is what every configured repository actually reads. Until it moves, the specification says one thing and every installed protocol file says another.

The template also has to say what to do with a marker file it does not recognise, which today it does not: the only unrecognised case was an absent file.

## Outcome

The protocol template's marker section compares both facts and nothing else. The clean-versus-dirty distinction disappears from the rule entirely — not because dirtiness stopped mattering, but because a fingerprint of a dirty tree and a fingerprint of a clean one are the same kind of value, so there is no branch left to write.

It states what a match licenses in the narrowed terms, states the conditional re-stamp permission, and states the fallback for a marker carrying no tree fact. It points at the git guide for the invocation rather than restating it, so the recipe has one home.

## Acceptance

- The protocol template's marker check compares both facts, and no clean-tree condition remains anywhere in it.
- The template states what a match licenses, in terms that do not claim knowledge is correct.
- The template states the conditional re-stamp permission and its negation.
- The template states the fallback when the tree fact is absent.
- The template reaches the fingerprint invocation by pointer and restates none of it.
- The suite asserts the template carries no surviving clean-tree condition, and the guard is confirmed to fail against a reworded reintroduction.
- The suite asserts the licence wording and the re-stamp condition, each guard confirmed against its inversion rather than its absence.
- The suite passes.

## Comments

Three older assertions encoded the rule this ticket changed and were repointed rather than
deleted: the clean path now costs two git reads instead of one, `/commit` is no longer the only
writer, and the `$rulePattern` entry demanded the word "trusted" that this rule now explicitly
refuses. The third is the interesting one — it reported the Marker rule as *stated nowhere*
while the rule sat two lines from the pattern, because the guard was pinned to the old licence
wording rather than to the subject.
