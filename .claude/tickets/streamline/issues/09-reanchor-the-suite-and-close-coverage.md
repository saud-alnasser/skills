# test(verify): re-anchor the suite to the new layout and close its coverage gaps

Status: open
Blocked by: 16
Part of: streamline

## Problem

The verification script is the only test this repository has, and the compression tickets are about to rewrite most of the prose it asserts against. Its assertions are anchored to concepts rather than to literal sentences, which is why compression is survivable at all — but they cover only the claims somebody chose to assert. A claim no assertion reaches can be compressed away and the suite stays green, which would make a green run evidence of nothing.

## Outcome

The suite asserts the new layout, and its coverage is audited file by file so that passing it means fidelity was kept rather than untested. Every load-bearing claim in a file about to be compressed has an assertion anchored to the concept, so a rewrite that drops the claim fails and a rewrite that only changes the wording does not.

## Acceptance

- Every assertion resolves against the new layout, and none references a path from the superseded one.
- Each file scheduled for compression has been audited for load-bearing claims with no assertion, and each gap found is either closed or recorded with the reason it was left.
- An assertion added by this ticket fails against a deliberate removal of the claim it guards, confirmed rather than assumed.
- An assertion added by this ticket passes against a reworded but equivalent statement of the same claim.
- Addressing a single ticket's assertions still works, and an unknown identifier still exits non-zero and lists what it knows.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

This is the gate for the rest of the effort and is placed before every compression ticket deliberately. Compressing first would leave the suite red across four tickets with no way to tell an intended rewrite from a lost claim.

It is also placed *after* adoption rather than before it, so the new layout it asserts against is a tree that exists rather than one that is planned. Assertions written against an imagined layout are the ones that pass while describing nothing.

Both failure shapes named in the authoring standards apply. A guard written from new wording matches only that wording; a guard covering two claims passes when either holds. One assertion per claim, anchored to the subject.
