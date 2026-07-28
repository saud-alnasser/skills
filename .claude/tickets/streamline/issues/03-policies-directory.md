# feat(configure): one guide per workflow concern, reached by pointer

Status: open
Blocked by: 02
Part of: streamline

## Problem

Onboarding installs two policy files, and they answer two questions well. Every other workflow concern — how knowledge loads and heals, what a ticket is and how it is sliced, when a decision is worth recording, how evidence graduates — is stated inside whichever skill happens to need it, and restated in the next skill that needs it too. There is no tier for a guide selected by workflow stage, because a stage cannot be expressed as a file pattern.

## Outcome

**Shipped behaviour changes; this repository's own configuration does not.**

A configured repository is given a guide directory holding one file per workflow concern or repository aspect. The two existing policy templates move into it unchanged in substance. The concerns currently spread across skills are consolidated, each into one guide that the skills point at instead of restating.

The guides are committed markdown, so a reader without the plugin reaches every one of them from the entrypoint.

## Acceptance

- Each guide covers exactly one concern and is reachable by pointer from the generated protocol's routing table.
- A concern consolidated from several skills is stated in the guide and in no skill.
- The two existing policy templates keep what they say; only their location and their name change.
- A guide that describes this repository rather than the workflow is still derived per repository rather than copied, so a configured repository does not inherit somebody else's facts.
- Every rule that moved has a duplication guard in the verification script, and each guard fails against a deliberate reintroduction before it is trusted.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

The recurring failure named in the authoring standards applies directly here: a guard written from the *new* wording matches only that wording and misses a restatement that survived elsewhere. Anchor each guard to the subject, not to the sentence just written.

The line between a guide that ships as a template and a guide derived from the repository is the same line `.claude/decisions/0019-tool-references-are-derived-per-repository.md` already drew for tool references. Draw it per guide rather than assuming one answer covers all of them.
