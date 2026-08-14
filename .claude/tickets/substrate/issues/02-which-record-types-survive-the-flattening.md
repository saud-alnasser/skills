---
owner: repository
title: "docs(protocol): settle which record types survive the flattening"
status: resolved
blocked-by: []
part-of: substrate
type: grilling
---

## Question

Which of AEP's eight systems survive as distinct record types, and what is the
test that admits a type?

Today the taxonomy is carried by directories: rules, policies, modes, contexts,
decisions, evidence, tool guides, tickets. In a flat typed store the directory
stops carrying it and a `type` field does — so the question is no longer *where
does this file go* but *is this a different kind of thing at all*.

Settle:

- What distinguishes a type from a field on a shared type. Rules and policies
  differ in who owns them and when they fire, both of which could be fields.
- Whether "policy" survives at all, or dissolves into norms whose firing
  condition is a stage rather than a path. The user named this one directly.
- Whether Evidence is a type or a status — it is defined by nothing revalidating
  it, which is a property of the record, not its subject.
- What each surviving type requires that the others do not, since required
  fields per type are what a type buys over a tag.
- What the audit and the suite can check about a type, because a type nothing
  verifies is a comment.

The answer names the types, the test that admitted each, and what was collapsed.

## Answer

**A type is admitted by write authority crossed with post-write mutability, and
by whether the record binds or describes.** Two axes, applied consistently.
Required field sets were rejected as the test — they are consequences of the
other two, so testing on them ratifies today's accident. Retrieval was rejected
as circular: `04`, `05`, and `06` are redesigning it, so a taxonomy resting on
it could be redefined by a downstream decision.

Sorting the corpus by those axes reproduced almost exactly today's eight
systems, which established that the eight are principled rather than accidental
— and that the simplification available is not fewer distinctions but fewer
*mechanisms* carrying them.

**Three stores, one query interface.** A store declares which types it holds and
how it is backed.

| Store | Backed by | Holds |
| --- | --- | --- |
| framework | the plugin, never written into a repository | `norm` |
| knowledge | files this repository owns | `norm`, `context`, `decision`, `evidence`, `reference`, `spec` |
| tracker | files, or the forge | `ticket`, `map` |

The tracker store's pluggable backing behind a fixed interface is what makes the
model uniform across trackers: a GitHub-backed repository has no ticket files,
and it does not need any — the interface is fixed where the backing is not. That
was the objection that ruled tickets out of the knowledge store, and a store of
their own answers it.

**Seven types, and `norm` exists on both sides of the framework boundary:**

- `norm` — binds. The store is what makes it law or local. A `fires-when` field
  replaces the rules/policies/modes split: every-turn, path, stage, posture.
  **A policy is now defined rather than assumed: a norm whose firing condition
  is a stage.**
- `context` — healed, describes.
- `decision` — frozen, binds.
- `evidence` — frozen, describes; its five kinds were already a field.
- `reference` — derived, describes. The tool guides.
- `spec` — lifecycle then frozen on accept, which is what separates it from
  evidence; both are repository-owned and describe.
- `ticket` and `map` — lifecycle, in the tracker store.

Eight systems become one type in the plugin and six in the repository.

**Two consequences follow rather than being chosen.** The byte-lock apparatus —
per-file version stamps, template-versus-copy comparison, *drift there is always
a bug*, the audit's coverage sweep — exists only because framework files are
copied into a repository, and nothing is copied now. And `precedence.md`'s
clause explaining that one directory spans two ranks because loading mechanism
splits it becomes a field comparison.

Recorded as ADR 0084. Precedence across stores is sharpened but not settled, and
graduated onto `07`.
