---
title: feat(configure): one guide per workflow concern, reached by pointer
status: resolved
blocked-by: [02]
part-of: streamline
---

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

### Built

Nine guides: seven copied, two derived. The scope question the ticket left open — whether the existing single-home format documents move too, or only the concerns genuinely restated across skills — was settled toward moving everything rule-bearing, because ADR 0022 holds that nothing carrying a rule may require the plugin to read, and the ticket lifecycle, the spec status vocabulary, and the 3-of-3 bar are all rules.

**Criterion 1 is only half mechanical.** Reachability is asserted in both directions — every shipped guide has a row, every routed guide exists. *One concern per guide* is a judgement, not a check, and no mechanical form of it was found.

**The `nothing validates it afterwards` property had three homes**, two of which predate this effort. Found by widening a guard that had been written from the new wording and so matched only the file just edited — the failure `.claude/rules/skills.md` names by example. Recorded because the guard passing at one home is what made it invisible until the pattern was loosened.

### Consequence for a later ticket

`/design` on a repository that has never run `/configure` now has no ticket format to read. That was already true of the tracker guide, but extending it to the formats turns onboarding from the recommended first step into a required one. No ticket covers it and nothing shipped says it, so it needs `/design` rather than a line slipped into a skill.
