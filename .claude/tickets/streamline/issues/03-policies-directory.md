# feat(knowledge): one guide per workflow concern, reached by pointer

Status: open
Blocked by: 02
Part of: streamline

## Problem

Two policy files exist and answer two questions well. Every other workflow concern — how knowledge loads and heals, what a ticket is and how it is sliced, when a decision is worth recording, how evidence graduates — is stated inside whichever skill happens to need it, and restated in the next skill that needs it too. There is no tier for a guide selected by workflow stage, because a stage cannot be expressed as a file pattern.

## Outcome

A guide directory holds one file per workflow concern or repository aspect. The two existing policy files move into it unchanged in substance. The concerns currently spread across skills are consolidated, each into one file that the skills point at instead of restating.

## Acceptance

- Each guide covers exactly one concern and is reachable by pointer from the protocol's routing table.
- A concern consolidated from several skills is stated in the guide and in no skill.
- The two existing policy files keep what they say; only their location changes.
- Every rule that moved has a duplication guard in the verification script, and each guard fails against a deliberate reintroduction before it is trusted.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

The recurring failure named in the authoring standards applies directly here: a guard written from the *new* wording matches only that wording and misses a restatement that survived elsewhere. Anchor each guard to the subject, not to the sentence just written.
