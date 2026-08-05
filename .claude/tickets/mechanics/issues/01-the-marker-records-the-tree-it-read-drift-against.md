# 01 — feat(specs): the marker records the tree it read drift against

Status: resolved
Blocked by: —
Part of: mechanics

## Problem

The specification's marker rule pairs an identity test with a liveness test: the marker matches when its commit equals HEAD *and the tree is clean*. So any uncommitted edit invalidates the cache permanently, whatever it was and whoever already read it, and the stage that reads that drift has nowhere to record having read it.

The specification also states what a match licenses in the strongest available terms — context is trusted with no reading at all. That claim is only earnable by a stage that verified everything, which is why the marker has exactly one writer today and why adding a second would be unsafe under the wording as it stands.

## Outcome

The specification's verification section states that the marker records two facts, a commit and a tree, and that a match on both licenses exactly one thing: skipping the two drift reads. Verification at use is unaffected and the specification says so, so a later reader cannot mistake a matching marker for a statement that any particular knowledge is correct.

It states who may write which half. The commit stage writes both, as it does now. Any stage that reads drift and *deals with what it found* may re-stamp the tree alone — the permission is conditional on the dealing, not on the reading, and a stage that merely observed drift has earned nothing.

It states that a marker carrying only a commit means the tree is unknown, which returns the behaviour to today's live check. No repository needs migrating.

## Acceptance

- The specification states the marker's two facts and that both are compared.
- The specification states that a match licenses skipping the drift reads and nothing more, in terms that distinguish it from the claim that knowledge is correct.
- The specification states that verification at use is unchanged by a matching marker.
- The specification names the commit stage as the writer of both halves and states the conditional permission to re-stamp the tree alone.
- The re-stamp permission is stated as conditional on having dealt with the drift, and the negation — a stage that read drift and did nothing about it may not re-stamp — is stated rather than left to inference.
- The specification states that an absent tree fact means unknown, and that the check falls back to the live one.
- A decision records why the marker's claim was narrowed rather than kept as-is, what the alternatives were, and why a second writer is safe only under the narrowed claim.
- The suite asserts each of the above against the specification, and each guard is confirmed to fail against a reworded restatement.
- The suite passes.
