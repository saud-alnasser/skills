# feat(scripts): one regenerator produces every index, and the suite compares

Status: open
Blocked by: —
Part of: declared-fields

## Problem

Two generated indexes already exist, and nothing generates them. The context format states that a generated file is never hand-edited and that the prohibition is enforced *by regenerating and comparing rather than requested of whoever opens it* — a sentence with nothing behind it, because there is no regenerator to run and no comparison in the suite.

Every index this effort adds inherits that gap, and each one added by hand is a second statement of its directory rather than a derivation from it — which is the property ADR 0053 bought and this would spend.

## Outcome

One deterministic script produces every index from the fields the indexed files declare. The suite regenerates each and compares against what is committed; a stale or hand-edited index fails the build. `/commit` invokes the script before the message is written, per ADR 0057 — commit is the last point at which the tree is known complete.

The script is built against the two indexes that already exist, because they are the only ones with a known-correct answer to check against. Reproducing them byte-for-byte is the acceptance test and the de-risking: everything later in this effort depends on the regenerator being right, and this is the only ticket where correctness can be judged against something already trusted.

## Acceptance

- Running the script reproduces the committed context index and decision index **byte-for-byte**, including row order and whitespace — no diff at all.
- The suite fails when a committed index differs from what regeneration produces. Confirm it fails against a deliberate hand-edit before trusting it.
- The script runs without the plugin installed, like the suite that checks it.
- A file under an indexed directory that declares no fields does not appear in a regeneration, and this is asserted rather than assumed.
- `/commit` invokes the regenerator, and the suite asserts that it does.
- The script is deterministic: two runs over an unchanged tree produce identical output.
