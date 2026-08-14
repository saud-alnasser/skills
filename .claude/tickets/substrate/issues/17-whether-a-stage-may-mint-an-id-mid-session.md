---
owner: repository
title: "docs(protocol): settle whether a stage may mint an id mid-session"
status: resolved
blocked-by: [03, 06]
part-of: substrate
type: grilling
---

## Question

ADR 0090 settles that **the build mints ids** and that a heading without one fails the
suite. Two parts of the fog it was graduated from are therefore already answered:
`/configure` does not generate them, and a hand-added heading with no id fails. What
remains is narrower and was not answered:

**May a stage mint an id mid-session, or must it run the build?**

Graduated from the map's fog on 2026-08-14, reduced to its residue by ADR 0090 rather
than sharpened by it.

The case is concrete. `/implement` writes a Context span or a Decision during a build.
Under ADR 0090 that heading has no id until the build runs. Either:

- **The stage runs the build**, which mints the id and writes it into frontmatter — but
  the build also mints ids for every other unlabelled heading in the tree and resolves
  every edge, so a stage writing one span pays a whole-tree pass and may pull unrelated
  work into its own diff. This repository has already been bitten by exactly that shape:
  ADR 0090 records a dispatched researcher clobbering generated indexes by regenerating
  over in-flight work.
- **The stage mints inline**, which reintroduces the duplicate-id and dropped-id failure
  modes ADR 0090 says minting at build time *"designs out"* — and hand-minted opaque
  tokens are what its rejected `Author-written ids` option was rejected for.

Neither is obviously right, which is what makes this a ticket rather than a consequence.

A second question the same ADR opens and does not close: **the build writes to files a
human authored, which no AEP tool does today.** Whether that needs a guard — a stage
declaring it, a diff the human sees, a refusal to touch a dirty file — is part of the
same decision, because the mid-session case is where it happens most often and least
visibly.

## Answer

Settled with the user on 2026-08-14. Recorded as **ADR 0096**.

**A span is authored without an id, and `/commit` runs the build before the commit
lands.** This is the shape that already exists rather than a new one — ADR 0057 has the
commit stage invoking the regenerator today, for the reason that applies here unchanged:
commit is the last point at which the tree is known complete. It satisfies
`.claude/policies/knowledge.md` directly, since the id lands in the same commit as the
span it addresses.

Accepted: **a span has no id for the session it was written in**, so nothing can cite it
until the commit. Narrower than it looks — an edge is authored against something that
already exists, and a genuine forward reference lands in one commit that one build
resolves.

Both alternatives were rejected on evidence rather than preference. A stage running the
build mid-session pulls unrelated headings into its own diff, and ADR 0090 records that
clobbering happening with a narrower script. Inline minting is ADR 0090's rejected
author-written-ids option under another name, and `08`'s item 6 found two spans sharing
one heading text in `tickets.md` — so collision is observed, not hypothetical.

One consequence reaches `/commit`: its build pass may now write to files a human authored,
so it **shows what it minted** rather than minting silently.

## Evidence bearing on this

- ADR 0090 — the build mints ids; an unlabelled heading fails; author-written ids
  rejected; the observed clobbering that motivated moving derived files out of git.
- ADR 0085 — the id carries the fidelity floor, so a wrong or duplicate id is not a
  cosmetic defect: it is the mechanism that detects a lost norm.
- `.claude/policies/knowledge.md` — a correction lands *"in the same commit as the change,
  so the two never land apart"*, which is the constraint any answer here has to satisfy: a
  span written mid-session and id-less until some later build has landed apart from its id.
- `.claude/evidence/prototypes/2026-08-14-does-a-fires-when-filtered-row-deliver-what-implement-needs.md`
  — found two spans sharing one heading text in `tickets.md`, which is why heading-text
  identity was rejected and why duplicate detection is not hypothetical.
