---
owner: repository
status: accepted
load-when: a repository-owned file's frontmatter, the owner declaration, or the audit's coverage of the protocol directory is in question
sources: [skills/configure/, specs.md, .claude/decisions/0080-a-framework-file-declares-the-release-that-last-changed-it.md]
supersedes: []
superseded-by: []
---

# Every governed file declares its owner, and the audit sweeps the tree

A field run on a configured repository showed the post-configure shape the shipped formats specify: framework-owned files stamped, everything repository-owned — contexts, decisions, evidence, discovered rules — carrying no owner at all, leaving a file that is repository-owned by design indistinguishable forever from one that predates the owner split, while the audit checked a named list of categories rather than the tree. We decided the shipped formats for repository-owned files gain an explicit `owner: repository` declaration (no `version` — that field is framework provenance only, ADR 0080), the audit gains an inline computed coverage sweep that enumerates every committed file under the protocol directory, classifies each by owner and category, verifies it against that category's contract, and reports strays and missing declarations as findings, and a frozen migration-changelog entry backfills the declaration onto already-configured repositories by recognising shape, touching no prose. The field is load-bearing because the sweep ships in the same effort and is the thing that acts on it; the flagship's own six-field decision records stop being a deviation from the five-field law it ships. Ticket issue files owe no declaration by the shipped format — their fields are the ticket format's, though a repository's own guard may stamp them, as this one's does; the entrypoint sits at the root, outside the swept tree; committed machinery bearing no frontmatter is swept for category only; and the ignore file defines the per-clone exemptions.

## Considered Options

- **Sweep with an unstamped default** — no new fields; absence read as repository-owned. Rejected: it makes the ambiguity permanent — the audit could never distinguish deliberate ownership from a pre-split survivor — and leaves the flagship's own stamps a standing deviation from the formats it ships.
- **A derived sweep script** — pinned and fixture-tested like the position script. Rejected: it grows three shipped surfaces plus a per-repository derivation for a check the audit can compute inline with the same pattern as the existing framework-file comparison, and a mis-derived sweep is a confident wrong answer about the whole tree.

## Consequences

Every governed repository-owned file carries a constant-valued field, justified solely by the sweep that reads it — if the sweep ever retires, the field retires with it. The backfill touches every knowledge file in configured repositories once, a large mechanical diff the changelog entry must describe exactly. The sweep's category table is read off the canonical layout the entrypoint states, not restated, so a release adding a directory moves one place. Content truth stays with verification at use — the sweep's reach is structural currency only.
