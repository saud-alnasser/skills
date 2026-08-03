# chore(configure): close the graphite configuration gap

Status: resolved
Blocked by: —
Part of: fieldwork

## Problem

This repository's configuration tree. The clone declares stacked changes — the graphite marker exists in `.git/` and the version-control policy was healed to match it this session — but no graphite reference is derived into the tools directory, so every stacking operation is a configuration gap and the suite's `layout/04` assertion stands red. Surfaced by fieldwork/01's review: its "suite passes" acceptance is unsatisfiable while the gap is open.

## Outcome

The detected tooling and the configuration agree, in whichever direction is actually wanted: either the stack is real and `/configure` derives the graphite reference, or the initialisation was incidental, the stack is retired, and the version-control model returns to plain git. Either way the suite passes with no standing exception.

## Acceptance

- The filesystem read the version-control policy names and that policy's stated model give the same answer.
- The suite passes, `layout/04` included, with no recorded exception.

## Comments

Landed as an amend to the shared `fieldwork` commit — the effort is one unit of work by the user's standing instruction. Direction: derive, not retire — the user's own session instruction ("use the graphite workflow stacking single commit per branch") is the rank-1 answer to the outcome's "whichever direction is actually wanted", so no fork was decided silently. The reference is derived verbatim from the shipped source with its provenance line, the provenance loop covers it, and the version-control policy's gap sentence became a pointer at the derived file. Review: Spec axis clean, confirming byte-fidelity and 670-passed-0-failed; Standards' one hard finding fixed in the same pass — the derived git reference's preamble still claimed the graphite link points at nothing, which this ticket falsified, so the preamble was healed and the suite gained the inverse guard (a preamble documenting a dangling link that resolves now fails), proven red before the heal. The suite passes with no recorded exception, for the first time this effort.
