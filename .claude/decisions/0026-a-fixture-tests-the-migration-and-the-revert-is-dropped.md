---
status: accepted
load-when: the migration's own test strategy is in question
sources: [skills/configure/MIGRATION.md]
supersedes: []
superseded-by: []
---

# A fixture tests the migration, and the revert is dropped

Supersedes one consequence of `0025`, which held that ticket 01's entrypoint split had to be reverted so the migration would have a clean superseded layout to convert. Only that consequence is superseded — `0025`'s ordering decision stands: structural work lands in `skills/` first and this repository adopts in one later ticket.

The migration is proven against a **fixture** built from the pre-effort tree rather than against this repository's live configuration. Ticket 01's result stays where it is, and ticket 15 is obsolete.

## Why

`0025` rested on the claim that this repository is the only superseded-layout repository available, so a half-migrated tree costs the migration its only test. The claim does not hold. The pre-effort tree is recoverable from history at any time, so a throwaway copy of it can be converted as often as needed.

Once that is seen, the fixture is not a substitute for the live test — it is **better than it** on every axis that matters:

- **Repeatable.** A live repository can be migrated once. A fixture can be migrated after every change to the migration, which is what turns it into a test rather than an event.
- **Complete.** The live tree exercises only the conversion paths this repository happens to need. A fixture can carry every shape the migration claims to handle, including ones no real repository here has.
- **Free of churn.** This repository's history is the framework's build record. A commit that undoes a correct change so a later commit can redo it reads, to anyone auditing that record, as a mistake rather than as a test strategy.

The technique is already in use: ticket 01's confirmation that `paths:` frontmatter scopes loading was produced against a throwaway fixture, not against this repository. The evidence for the better approach was in the effort before the worse one was chosen.

## Consequences

**Ticket 01's work stands entire.** Both halves — the scope fix and the entrypoint split — are the shape `0021` targets. This repository reaches part of the new layout early; that is not a defect to be unwound.

**Ticket 08 owns the fixture.** The migration's test is the fixture run, and it belongs to the ticket that builds the migration rather than to the one that adopts it. A migration that is only tested by the adoption ticket is a migration whose failures are found while converting something that matters.

**Ticket 16 is adoption, not proof.** It still moves this repository onto the rest of the layout and still runs the migration to do it, but it is no longer carrying the argument for the effort's ordering.

**The general lesson is worth more than this instance.** Reaching for the live tree as a test is what produced both the original repository-first cut and the revert that was meant to correct it. Where the question is *does this transformation work*, the answer is a fixture; the live tree answers *did we adopt it*, which is a different question.
