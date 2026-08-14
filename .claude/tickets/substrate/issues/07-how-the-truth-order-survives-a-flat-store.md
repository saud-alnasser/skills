---
owner: repository
title: "docs(protocol): settle how the truth order survives a flat store"
status: resolved
blocked-by: [02]
part-of: substrate
type: grilling
---

## Question

Where does precedence live when structure stops carrying it?

Two orderings hold the framework together and both are currently expressed as
position. The knowledge layers — Codebase over Context over Decisions — are a
truth hierarchy stated in the entrypoint. The instruction ranks are a six-entry
list in `precedence.md`, whose most confusing clause exists only to explain that
one directory spans two ranks because loading mechanism splits it.

Flattening removes the directories that carry both. Settle:

- Whether precedence becomes a declared field on a record, computed from other
  fields, or stays a stated ordering the tool applies when it returns
  conflicting norms.
- What the tool does when two records disagree — returns both with their ranks,
  or resolves and returns one. Resolving hides the conflict; returning both
  hands the model a judgement `ADR 0075` was trying to remove.
- Whether the Codebase-wins rule needs any expression in the store at all, given
  it governs the relationship between the store and something outside it.
- Whether the rank-2/rank-5 split dissolves once loading mechanism is a field
  rather than a directory — the one place where flattening plausibly makes the
  system simpler rather than merely different, which is worth confirming rather
  than assuming.

Sharpened by `02`, which made precedence partly **inter-store**: `norm` now
exists in both the framework and knowledge stores, so a framework norm and a
repository norm can fire on the same question. Whether `owner: framework is law`
survives as a ranking rule, or is replaced by the extension-point model doing
that work, is this ticket's to settle — and it is now the sharpest part of it.

Sharpened again by `03`: coupling between norms is held by a shared heading, and
no heading spans two stores. So a repository norm that depends on a framework
norm has no mechanism at all — declared coupling was rejected within a store
because under-declaration is silent, and that objection is weaker across a
boundary where nothing else can reach. Whether this narrow case earns the
mechanism the general case refused belongs here.

## Answer

**Two orderings, each answering one question, no longer overlapping.**

**Cross-store is not a precedence question.** A repository norm contradicting a
framework norm is a **declared deviation** — loud, audited, carrying its reason
and its declaring release, forced to a disposition after one release. ADR 0073
already built the machinery. A rank would have resolved the contradiction
silently, and silent resolution is the diagnosed cause of settled questions being
re-asked; a deviation makes the same situation visible in every audit.

**Precedence orders binders only:** what the user said, then decisions, then
norms by firing breadth. `context`, `evidence`, `reference`, and `spec` leave the
ladder entirely — `specs.md` §8 says a context contains facts and never
instructions, and a record that never instructs cannot lose an instruction
conflict. They answer to the **truth hierarchy** instead: where they disagree
with the Codebase, the Codebase is right and they are healed.

**`CONTRIBUTING.md` and `README.md` leave the ladder too**, for a different
reason: ADR 0008 makes a repository's documented conventions an input the
workflow detects and adopts, so `/configure` derives the repository's own norms
*from* them. They are derivation inputs, not competing records. Six ranks become
three, and every departure is derived rather than asserted.

**A decision outranks a norm, and the conflict is productive** — the norm is
amended in the same change rather than silently suppressed, which is the same
reflex as the deviation model. This follows this repository's own recorded
practice of an ADR beating the specification that generates its norms. It
inverts today's rank 2 over rank 4; the migration must find and re-check those.

**Precedence is computed, never declared** — from type, store, and `fires-when`.
No record carries a rank field, so no record can be given the wrong one. The
`precedence.md` clause explaining that one directory spans two ranks because
loading mechanism splits it becomes a comparison of a field.

**Cross-store coupling is a citation by id, not a new mechanism.** Settled rather
than asked, because two loaded norms determine it: ADR 0085 rejected declared
coupling on silent under-declaration, and the Source Pointer model already
governs this shape — verified before use, searched for when broken, never
invented. Ids never change, so a citation resolves across releases and a dangling
one is detectable.

**Stated rather than discovered:** a context that has drifted into stating an
instruction has no rank at all under this model. The migration must find and
re-home those as norms rather than silently demoting them, and nothing would
catch one it missed.

Recorded as ADR 0086. What the tool does when two records disagree — return both
with their computed ranks, or resolve and return one — is retrieval behaviour and
graduates onto `04`.
