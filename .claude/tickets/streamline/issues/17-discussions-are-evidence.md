# feat(configure): record the grill that produced no decision

Status: superseded
Superseded by: aep/04 (ADR 0030)
Blocked by: 03
Part of: streamline

## Problem

The interrogation of a proposal is where most durable understanding is produced, and almost none of it survives. What reaches a file is the decision — and only when there was one. A grill that weighed three approaches and parked the question, a tradeoff nobody resolved, an assumption stated and never tested: all of it exists only in a conversation that ends.

The alternatives themselves are not the gap. A decision record already carries the options it considered. The gap is everything that happens when the conversation produces no decision at all, which is most conversations.

## Outcome

**Shipped behaviour changes; this repository's own configuration does not.**

A configured repository can record a discussion as evidence, beside the findings and write-ups it already keeps. A discussion holds what was asked, what was assumed, what was weighed, and what stayed open — and it is filed as a record rather than as a live document, because nothing revalidates it afterwards.

The stage that plans is the stage that writes one, and the stage that plans is also the one that promotes a discussion into a decision when it later resolves. Neither is a new rule: the guide that already says how evidence graduates covers both.

## Acceptance

- A discussion is written where evidence is kept, and the guide that defines evidence says what a discussion holds and what it does not.
- The unresolved half is a required part of the record, not an optional one — a discussion with nothing open is a decision that has not been written down yet, and says so.
- The graduation path is stated once, in the guide, and no skill restates it.
- The skill that plans states that it may write one, and the skill that writes the format is the only place the format lives.
- Nothing shipped implies a discussion is maintained after it is written; the property that separates evidence from knowledge survives the addition.
- Onboarding recognises the directory without pre-creating it, exactly as it treats the evidence directories that already exist.
- Every rule that moved has a duplication guard, and each guard fails against a deliberate reintroduction before it is trusted.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

`.claude/decisions/0027-a-discussion-is-a-fourth-kind-of-evidence.md` settles where this lives and why the two obvious alternatives were rejected. Read it before proposing a top-level directory again — the `active/` half is the specific thing that does not work.

The temptation this ticket has to resist is making a discussion a *living* document. An open question is not a live artefact to be maintained; it is a record that a question was open on a date. The moment it is maintained it becomes a fourth knowledge layer with no rank in the truth hierarchy.

This ticket does not adopt the directory here. Ticket 16 does, through the migration.
