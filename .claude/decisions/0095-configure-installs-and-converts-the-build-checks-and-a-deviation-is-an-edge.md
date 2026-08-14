---
owner: repository
status: accepted
load-when: what the configuration stage does, or how a repository declares a departure from framework law, is in question
sources: [.claude/tickets/substrate/issues/15-what-configure-becomes-when-nothing-is-copied.md, .claude/decisions/0084-two-axes-admit-a-type-and-eight-systems-become-seven-across-three-stores.md]
supersedes: []
superseded-by: []
falsified-by: [.claude/evidence/drift/2026-08-15-adr-0095-has-the-repository-s-build-resolving-an-edge-into-a-store-it-cannot-see.md]
---

# `/configure` installs and converts, the build checks, and a deviation is an edge

ADR 0084 observes that the byte-lock apparatus exists only because framework files are
copied, and that under 2.0 nothing is copied. That removes `/configure`'s largest job and
leaves the question of what the stage is for.

**`/configure` writes only what must exist in the tree, and runs the migration.** What
must exist is small: `CLAUDE.md`, because the harness loads it by name and it cannot move
(`.claude/rules/placement.md`), and the harness settings the workflow depends on. The
migration is the other half and becomes the larger one — ADR 0091 already makes it
fixture-proven and resumable, and it stays in this stage rather than becoming its own,
because converting a repository *is* configuring it.

**Every check moves to the build.** ADR 0090 already put id minting and edge resolution
there; putting the rest beside them gives one rule that holds without a judgement at each
new check — **the build checks, `/configure` converts.** A second, thinner audit inside
`/configure` was rejected for exactly that: two checking surfaces with a boundary decided
case by case is how one obligation acquires two homes, which this framework names as its
own worst failure class. Accepted: `/configure` becomes a rarely-run stage, and a
rarely-run stage rots. That is answered by the migration fixture ADR 0091 requires, which
exercises it without a repository needing to.

**A deviation from framework law is a declared edge naming the framework record it departs
from.** With nothing copied there is no installed file to diff, so the loudness
`CLAUDE.md`'s framework-law rule depends on had lost its mechanism. ADR 0086 already rules
that cross-store conflict is a declared deviation rather than a rank; this makes the
declaration an edge, so ADR 0090's build resolves it — **an undeclared conflict fails and
a deviation naming nothing fails** — and enumerating every deviation in a repository
becomes a filter rather than an audit remembering to look. Loud by construction.

**This adds a sixth edge type and ADR 0092 must give it a depth.** `deviates-from` closes
**one hop**: the framework norm being departed from is wanted, and what *that* norm cites
is the framework's business, not the deviating repository's. The `## Deviations` section
in the protocol file is superseded by it — prose in one file that nothing resolves and
nothing counts, with no home for a deviation about a record living elsewhere.

## Considered Options

- **Keep a thinner audit in `/configure`** — rejected on the two-homes reasoning above.
- **Dissolve `/configure` entirely**, installation becoming a declared dependency —
  rejected twice over: the map puts the Spine's stage set out of scope, and something must
  still write `CLAUDE.md` into a fresh repository.
- **Keep the `## Deviations` section** — rejected: nothing resolves it, nothing counts it,
  and a deviation about a record in another file has nowhere to live.
- **No deviation mechanism, precedence decides silently** — the smallest system, rejected
  because it deletes the loudness framework law rests on and makes a lost repository norm
  indistinguishable from one that never existed, which is what *a miss is a fact* was
  bought to prevent.
