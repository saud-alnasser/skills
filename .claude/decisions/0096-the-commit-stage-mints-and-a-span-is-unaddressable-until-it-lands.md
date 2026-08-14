---
owner: repository
status: accepted
load-when: when a span's id comes into existence, or whether a stage may mint one, is in question
sources: [.claude/tickets/substrate/issues/17-whether-a-stage-may-mint-an-id-mid-session.md, .claude/decisions/0090-nothing-derived-is-committed-and-the-build-mints-the-ids.md]
supersedes: []
superseded-by: []
---

# The commit stage mints, and a span is unaddressable until it lands

ADR 0090 settles that the build mints ids and that an unlabelled heading fails the suite.
It leaves open *when* the build runs when a span is authored mid-session, and the two
obvious answers are both wrong.

**A span is authored without an id, and `/commit` runs the build before the commit
lands.** This is the shape that already exists rather than a new one: ADR 0057 has the
commit stage invoking the regenerator today, for the reason that applies here unchanged —
commit is the last point at which the tree is known complete, and a pass run earlier is
falsified by a later edit in the same change. It also satisfies
`.claude/policies/knowledge.md` directly: the id lands in the same commit as the span it
addresses, so the two never land apart.

**Accepted: a span has no id for the session it was written in, so nothing can cite it
until the commit.** A record written and referenced within one session is the case this
costs, and it is narrower than it looks — an edge is authored against something that
already exists, and a span authored in the same session is reachable as text by whoever
wrote it. Where a genuine forward reference is needed, the two land in one commit and one
build resolves both.

**A stage running the build mid-session was rejected on observed harm.** The build is a
whole-tree pass: it mints ids for every unlabelled heading anywhere and resolves every
edge, so a stage writing one span pulls unrelated headings into its own diff. ADR 0090
records this happening — a dispatched researcher clobbered generated indexes by
regenerating over in-flight work — and that was with a narrower script than this one.

**Inline minting was rejected as ADR 0090's own rejected option under another name.**
Hand-generated opaque tokens are where duplicates and copy-paste collisions come from, and
the prototype
`.claude/evidence/prototypes/2026-08-14-does-a-fires-when-filtered-row-deliver-what-implement-needs.md`
found two spans sharing one heading text inside `.claude/policies/tickets.md`, so
collision is observed rather than hypothetical.

**One consequence reaches `/implement`.** Committing already happens as part of building
without being asked, so a build that writes knowledge already reaches a commit in the same
run. What changes is that the commit stage's build pass may now write to files a human
authored — ADR 0090 accepts that in general, and this decision is where it actually
happens, so `/commit` shows what it minted rather than minting silently.

## Considered Options

- **The writing stage runs the build immediately** — rejected on the clobbering ADR 0090
  already recorded, and because it makes every knowledge write a whole-tree operation.
- **The stage mints inline, the build validates later** — rejected as ADR 0090's
  author-written-ids option restated, with an observed collision behind it.
- **A build scoped to the files a stage touched** — rejected: ADR 0090's pass resolves
  every declared edge, which needs the whole tree, so a scoped pass would either skip
  resolution or report false failures for edges whose targets it did not read.
