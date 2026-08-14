---
owner: repository
status: accepted
load-when: two records disagree, or where a rule ranks against a decision is in question
sources: [.claude/tickets/substrate/issues/07-how-the-truth-order-survives-a-flat-store.md, .claude/rules/precedence.md]
supersedes: []
superseded-by: []
---

# Cross-store conflict is a deviation, and precedence orders only what binds

A repository norm contradicting a framework norm is **not a precedence question**:
it is a declared deviation under ADR 0073 — loud, audited, carrying its reason and
declaring release, forced to a disposition after one release. A rank would resolve
the contradiction silently, and silent resolution is the diagnosed cause of settled
questions being re-asked.

**Precedence orders binders only** — what the user said, then decisions, then norms
by firing breadth. `context`, `evidence`, `reference`, and `spec` leave the ladder,
because `specs.md` §8 holds that a context contains facts and never instructions,
and a record that never instructs cannot lose an instruction conflict; they answer
to the truth hierarchy instead, where the Codebase is right and they are healed.
`CONTRIBUTING.md` and `README.md` leave it for a second reason: ADR 0008 makes a
repository's documented conventions an input the workflow detects and adopts, so
they are derivation inputs rather than competing records. **Six ranks become
three, every departure derived rather than asserted.**

**A decision outranks a norm, and the conflict is productive** — the norm is
amended in the same change rather than silently suppressed, following this
repository's own practice of an ADR beating the specification that generates its
norms. This inverts today's rank 2 over rank 4, which the migration must find and
re-check. **Precedence is computed from type, store, and `fires-when`, never
declared**, so no record can carry a wrong rank.

Cross-store coupling is a **citation by id**, reusing the Source Pointer model —
verified before use, searched for when broken, never invented — rather than the
declared-coupling graph ADR 0085 rejected for silent under-declaration.

Stated rather than discovered: a context that has drifted into stating an
instruction has no rank at all under this model, and nothing would catch one the
migration missed.

## Considered Options

- **Framework outranks repository by rank** — rejected: the losing norm sits in
  the store doing nothing and nobody is told, so a repository accumulates norms it
  believes are in force and are not.
- **Repository outranks framework** — rejected: it reverses ADR 0073 and restores
  the licence to treat framework law as negotiable.
- **Keep every type in one ordering** — rejected: it preserves the category error
  of ranking a type that never instructs, and keeps two partly-overlapping
  orderings to re-derive on every read.
- **No ordering; contradiction is a defect** — rejected: with no ladder there is
  no answer at the moment of use, and every inconsistency becomes a blocker.
- **Norm over decision** — rejected: an accepted ADR could be quietly overridden by
  a norm nobody re-derived against it.
- **Preserve today's interleave** — rejected: it encodes an accident of the old
  three-tier layout and 2.0 could not state a reason for it.
