---
owner: repository
status: accepted
load-when: what a 1.x surface becomes under 2.0, or how a frozen record is addressed, is in question
sources: [.claude/tickets/substrate/issues/09-what-the-migration-converts-and-what-it-refuses.md, skills/configure/MIGRATION.md]
supersedes: []
superseded-by: []
falsified-by: [.claude/evidence/drift/2026-08-15-adr-0091-s-frozen-set-names-a-ticket-and-omits-a-finding.md]
---

# Frozen records get one id, and the migration is fixture-proven and resumable

**A frozen record — an accepted ADR, a resolved ticket, a landed spec — gets one
id for the whole file and is not decomposed**, exactly as ADR 0085 treats a file
with no headings. The freeze survives with a single frontmatter field added and no
heading touched or labelled, and it matches how frozen records are used: nothing
queries an ADR's third heading, since they are routed to whole by `load-when` and
read whole. Accepted cost: the corpus is non-uniform — live records are
span-addressable, frozen ones file-addressable — so a query result's granularity
depends on the record's status. Keeping frozen records out of the store entirely
was rejected because it would make 88 ADRs invisible to the query `/review` most
needs, and minting ids throughout was rejected as reading the freeze narrowly
enough that the line would be re-argued.

**Every 1.x surface has a stated destination**, and the four generated `map.md`
indexes are deleted rather than converted, because ADR 0090 makes them queries.
The unscoped rules stay copied as the core under ADR 0088, keeping the version
stamps and byte-locking the rest of the model dissolves; scoped rules keep only a
pointer; the eight framework policies, the protocol file's norms, and the seven
modes become framework-store `norm` records separated by `fires-when`.

**Two questions were settled by norms already in force rather than decided here.**
ADR 0026 dropped the bespoke revert and made a fixture the proof mechanism, on the
ground that a fixture is repeatable, complete, and free of churn where a live tree
can be migrated only once. And `MIGRATION.md` already detects by content rather
than by presence, explicitly anticipating a repository half-way through a previous
run — so a partial tree is a recognised, resumable state and not a refusal.

Repository-owned records convert with no template to compare against, becoming
knowledge-store records with build-minted ids. Declared deviations survive as
deviations, carrying their declaring release into 2.0 to be re-read at the first
audit, where the store split may have dissolved the variation they were declared
for.
