---
owner: repository
title: "docs(protocol): settle what /configure becomes when nothing is copied"
status: resolved
blocked-by: [02]
part-of: substrate
type: grilling
---

## Question

`/configure` installs framework-owned files into a repository and audits them: per-file
version stamps, template-versus-copy byte comparison, and a coverage sweep. ADR 0084
observes that this entire apparatus **exists only because framework files are copied**,
and that under 2.0 nothing is copied. So what is `/configure` for?

Graduated from the map's fog on 2026-08-14. `02` sharpened it from *what does the audit
compare* to *what remains of the audit at all*.

Settle:

- **What the audit still checks.** With no copies, there is no byte comparison and no
  version stamp to read. What is left is arguably the repository's own half — declared
  fields drawn from closed vocabularies, edges that resolve, `owner: repository` files
  that drifted from what the framework expects of them. Whether that is an audit or a
  build step is the question, and ADR 0090 already put edge resolution in the build.
- **What installation becomes.** Today `/configure` writes files. If the framework store
  ships inside the plugin (ADR 0090's `objects.inv`-model package artifact), installing is
  closer to declaring a dependency than to writing a tree. What, if anything, still lands
  in `.claude/` on a fresh repository — and `CLAUDE.md` at minimum must, since ADR 0088
  keeps the core on harness push and `.claude/rules/placement.md` says the harness loads
  it by name.
- **What migration and configuration share.** ADR 0091 makes the 1.x migration
  fixture-proven and resumable, and `/configure` is where it runs. If configuration
  becomes thin, migration becomes the larger half of the same stage, and whether they stay
  one stage is a real fork rather than a naming question.
- **Whether the deviation mechanism survives unchanged.** `CLAUDE.md` states that a
  `owner: framework` file is followed as written and variation enters only through
  declared extension points, anything else being a loud declared deviation. With nothing
  copied there is no file to deviate *from* in the repository — so what a deviation is
  declared against, and what still makes it loud in every audit, needs an answer.

## Answer

Settled with the user on 2026-08-14. Recorded as **ADR 0095**.

- **`/configure` writes only what must exist in the tree and runs the migration.**
  `CLAUDE.md`, because the harness loads it by name and it cannot move, plus the harness
  settings. Migration stays in this stage and becomes its larger half — converting a
  repository *is* configuring it.
- **Every check moves to the build**, beside the id minting and edge resolution ADR 0090
  already put there. One rule: **the build checks, `/configure` converts.** A second
  thinner audit was rejected because a boundary decided case by case is how one obligation
  acquires two homes. Accepted: a rarely-run stage rots, answered by ADR 0091's migration
  fixture exercising it without a repository needing to.
- **A deviation from framework law is a declared edge naming the framework record it
  departs from** — `deviates-from`. ADR 0086 already made cross-store conflict a declared
  deviation; making it an edge means ADR 0090's build resolves it, so an undeclared
  conflict fails and a deviation naming nothing fails. Loud by construction rather than by
  an audit remembering to look.

Two consequences elsewhere, both taken in the same change: **ADR 0092 gains a sixth row**
— `deviates-from` closes one hop — and the protocol file's `## Deviations` section is
superseded, being prose that nothing resolves and nothing counts, with no home for a
deviation about a record living in another file.

## Evidence bearing on this

- ADR 0084 — the two axes, and the observation that the byte-lock apparatus and the
  `precedence.md` two-rank clause both dissolve as consequences rather than choices.
- ADR 0090 — nothing derived is committed; a prebuilt ledger ships inside the published
  plugin package as a release artifact; the build mints ids and resolves edges.
- ADR 0088 — the core stays on harness push and keeps version stamps and byte-locking.
  **That is the one place copying survives**, so whatever is decided here must leave the
  core's apparatus intact rather than dissolving it with the rest.
- ADR 0091 — what the migration converts and what it refuses.
- `.claude/evidence/prototypes/2026-08-14-does-a-fires-when-filtered-row-deliver-what-implement-needs.md`
  — measured that `tools/github.md` is 100% inert on `/implement`'s row here, because this
  repository's declared tracker makes it so. **Nothing reports an inert row entry**, and
  if anything is going to, it is this stage.
