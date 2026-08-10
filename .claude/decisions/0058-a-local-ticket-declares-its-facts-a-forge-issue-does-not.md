---
owner: repository
status: accepted
load-when: a ticket's lifecycle facts are being read or written, or the two tracker forms look inconsistent
sources: [.claude/policies/tickets.md, .claude/tickets/]
supersedes: []
superseded-by: []
---

# A local ticket declares its facts as fields; a forge issue does not

On a local-markdown tracker a ticket declares `title`, `status`, `blocked-by`, `part-of`, and `type` as frontmatter fields, and the `# ` heading is dropped — the title has one home rather than two inside one file. On a shared forge nothing changes: the lifecycle rides native issue state and the edges stay in the issue body.

The asymmetry is the decision, and it is not an oversight to be tidied later. A forge owns these facts natively — its issue state *is* the status, and frontmatter pasted into an issue body would render as noise while duplicating what the forge already knows. The tickets policy already draws this line, calling `Status:` and the edge lines *the local-markdown form*; this decision keeps the line and changes only what the local form looks like.

## Considered Options

- **Frontmatter on both forms.** Rejected: on a forge it is a second home for a fact the forge owns, and the copy nobody edits is the one that goes stale — the failure this framework is organised against.
- **Keeping the title as the `# ` heading and adding the rest as fields.** The more conservative shape, and the one recommended during design: an H1 on line one is structurally anchored, so it is not the fragile parse this effort exists to remove, and dropping it costs every renderer its document title. Overruled deliberately — the user's call was that a machine-read fact is a field without exceptions argued case by case, and a rule with no exceptions is cheaper to hold than one with a defensible one.
- **Converting only live tickets.** Rejected: two forms of one format in one tree means every reader and every assertion handles both indefinitely.

## Consequences

A local ticket file opens with its first section rather than a heading. That is the accepted cost of the title having one home.

All 110 existing ticket files convert, 92 of them already resolved. The conversion is deterministic — anchored lines to fields — so it is scriptable and therefore checkable, rather than a hand edit at that scale.

This does **not** unlock indexing tickets. `.claude/policies/maps.md` bans listing open tickets on staleness grounds that ADR 0053 dissolved for generated files, and that contradiction stands unresolved by design (ADR 0056's consequences record it). Declaring fields makes such an index *possible*; it stays *forbidden* until a decision says otherwise.
