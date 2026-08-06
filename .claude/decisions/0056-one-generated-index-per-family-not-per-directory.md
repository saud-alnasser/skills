---
status: accepted
load-when: an index is being added for a directory, or a declared field looks like it restates a path
sources: [.claude/evidence/, .claude/policies/evidence.md]
supersedes: []
superseded-by: []
---

# One generated index per family, not per directory

Evidence's five kinds share one index at the family root rather than one under each kind's directory. The consequence is that each file declares its **kind** as a field — which, under a per-directory index, would restate the path and be sediment.

The five kinds exist as separate directories because they are produced by different stages, but they are governed by one sentence: *read the directory before producing more*. That obligation is what an index removes, and it is the same obligation across all five. Five indexes would answer it five times, and a reader asking "has this been investigated already" would consult five files to find out.

The rule that survives: **a declared field restates the path only while the index is scoped to that path.** Widen the index and the same field becomes the column that makes it readable. Neither the field nor the directory changed — the question the index answers did.

## Considered Options

- **One index under each kind's directory.** Rejected: it multiplies the read the index exists to remove, and it leaves the cross-kind question — what is waiting anywhere in evidence — answerable only by reading all five.
- **One global index over all of `.claude/`.** Rejected: a generated index is a committed file that changes on every write beneath it, so one file spanning every family is the worst merge surface available here, and it would index families that nothing routes to.
- **Keeping the kind implicit and inferring it from the row's link path.** Rejected: it makes the index's own column depend on parsing a path, which is the class of fragility this effort exists to remove.

## Consequences

The index-earning test becomes a question about the reader rather than about the directory: what is the widest question somebody asks of these files at once, and does one file answer it. That is why the policy, mode, and tool guides get no index under this decision — nobody asks a question spanning them; they are reached by pointer from a known path.

Tickets are deliberately not covered. `.claude/policies/maps.md` forbids listing open tickets on the ground that the list goes stale — a ground ADR 0053 dissolved for generated files. That contradiction is real and left standing here; reopening it is its own decision, not a consequence of this one.
