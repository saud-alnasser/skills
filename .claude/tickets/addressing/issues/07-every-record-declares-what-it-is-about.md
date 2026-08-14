---
owner: repository
title: "feat(knowledge): every record declares what it is about, and no script recovers it from a filename"
status: resolved
blocked-by: []
part-of: addressing
---

## Problem

The store has no field for what a record is *about*. Its declared fields say what type it is,
who owns it, when it fires, and which stages or postures or paths that means — nothing says
its subject. So a caller that needs one particular record can only filter on `file`, and the
record format states in as many words that a filename is not an address: an id *"names a norm
rather than a filename, so files keep readable names and a rename costs nothing."*

The concept is already in use everywhere and reconstructed everywhere. A skill declares its
dependencies as bare subjects. The router's column names them. The build recovers them by
stripping a stage suffix off a filename, in more than one place. Three surfaces parse what no
record states, and a fourth — a dispatched child needing its contract — cannot parse anything,
because it does not know which file to look in.

The store also carries two filename conventions and documents neither: a repository's records
take whatever readable name they would have had, and framework stage norms encode the stages
they serve. A reader of one flat directory sees both and has nothing to tell them apart.

## Outcome

Asking the store for a record by what it is about is a filter like any other, and no shipped
script recovers a subject by parsing a name. A reader of the record format learns both
filename conventions and which store each belongs to.

## Acceptance

- Every record in both stores declares `subject`, and a record declaring none fails the build
  naming the file.
- A query filtering on `subject` returns that record and no other, and enumerating the field
  lists the subjects the store holds.
- No shipped script derives a subject from a filename — the check is the same shape as the
  one already forbidding a stage derived that way.
- The router's column is checked against the `subject` field rather than against a name with
  a suffix stripped off it, and the check still fails in both directions.
- The three derived templates declare `subject` in the record each installs.
- The record format states that a repository's record keeps a readable name of its own
  choosing, that a framework stage norm's name encodes the stages it serves, and why the two
  differ.
- A subject no record carries returns an empty answer at exit zero, distinguishable from a
  refusal — `subject` behaves as every other declared field does.

  This criterion was written the other way round, requiring a refusal. That contradicts the
  decision that a filter matching nothing has made a true statement about the store while a
  refusal has not, and building it would have broken the assertions holding that line. The
  intent — that `subject` is a field like any other — is what survives.
