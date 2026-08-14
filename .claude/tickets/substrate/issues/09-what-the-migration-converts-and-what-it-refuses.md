---
owner: repository
title: "docs(configure): settle what the 1.x migration converts and what it refuses"
status: resolved
blocked-by: [03, 06]
part-of: substrate
type: grilling
---

## Question

What does a 1.x installation become under 2.0, and what does the migration
decline to touch?

`/configure` already recognises superseded layouts by content and converts them,
so the capability exists; what 2.0 needs is the mapping and its boundaries. The
user made migration a requirement rather than a nicety, which means 2.0 may not
choose a shape that cannot be reached from 1.x.

Settle:

- What each 1.x surface maps onto: the protocol file, ten policies, seven modes,
  the rules split by loading mechanism, contexts, decisions, evidence, tool
  guides, tickets.
- What happens to frozen records. Accepted ADRs, resolved tickets, and landed
  specs are never rewritten — so either the store holds both shapes, or the
  migration converts a subset and the corpus is permanently mixed. Both are
  liveable; only one can be true.
- Whether a repository mid-migration is a valid state or a refused one, and what
  a session finds if it opens one.
- What the migration does with a repository's declared deviations and its
  repository-owned records, which by construction have no framework template to
  convert against.
- Whether conversion is reversible, and if not, what is captured before it runs.

## Answer

**The mapping.** Every 1.x surface has a destination, and the ones that vanish
vanish for a stated reason:

| 1.x | 2.0 |
| --- | --- |
| root `CLAUDE.md` | stays, harness-pushed; gains the store pointer and the unreachable-store instruction |
| unscoped `rules/` | stays copied — the core (ADR 0088), keeping version stamps and byte-locking |
| scoped `rules/` | a pointer only; its norms move to the knowledge store as `fires-when: path` |
| `protocol.md` | framework store norms; its stage table becomes the row assembly |
| the eight framework `policies/` | framework store, `norm`, `fires-when: stage` |
| `tracker.md`, `version-control.md` | knowledge store, `norm`, repository-owned |
| the seven `modes/` | framework store, `norm`, `fires-when: posture` |
| `contexts/` | knowledge store, `context` |
| `decisions/` | knowledge store, `decision` — frozen, one id each |
| `evidence/` | knowledge store, `evidence` — frozen, one id each |
| `tools/` | knowledge store, `reference` |
| `tickets/<effort>/spec.md` | knowledge store, `spec` |
| `tickets/<effort>/issues/`, `map.md` | tracker store |
| the four generated `map.md` indexes | **deleted** — they become queries (ADR 0090) |
| `position/`, `scripts/` | unchanged; `scripts/` gains the index rebuild step |

**Frozen records get one id for the whole file and are not decomposed**, exactly
as ADR 0085 treats a file with no headings. The freeze survives with a single
frontmatter field added and no heading touched, and it matches how frozen records
are used: nothing queries an ADR's third heading — they are routed to whole by
`load-when` and read whole. Accepted cost: the corpus is non-uniform, live records
being span-addressable and frozen ones file-addressable, so a query result's
granularity depends on the record's status.

**Conversion needs no bespoke revert, and mid-migration is a recognised state.**
Both were settled by norms already in force rather than decided here. ADR 0026
dropped the revert and made a **fixture** the proof mechanism — *where the
question is does this transformation work, the answer is a fixture; the live tree
answers did we adopt it*. And `MIGRATION.md` already detects **by content, not by
presence**, explicitly anticipating "a repository half-way through a previous run"
and reporting converted only when every check holds. 2.0's migration inherits
both: proven against a fixture carrying every shape it claims to handle, and
resumable rather than refused.

**Repository-owned records convert without a template to convert against**, which
is what makes them the easy case: they become knowledge-store records of the
matching type, with ids minted by the build (ADR 0090). **Declared deviations
survive as deviations** — ADR 0086 widened the channel rather than closing it, so
a 1.x deviation carries its declaring release into 2.0 and is re-read against the
new model at the first audit, where the store split may have dissolved the
variation it was declared for.

Recorded as ADR 0091.
