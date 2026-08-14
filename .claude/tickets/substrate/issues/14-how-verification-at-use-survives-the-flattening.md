---
owner: repository
title: "docs(protocol): settle how verification at use survives the flattening"
status: resolved
blocked-by: [03]
part-of: substrate
type: grilling
---

## Question

Verification at use is the repository's central discipline: a Context statement is
checked against the Codebase at the point of use, Source Pointers are verified before
use, and drift is fixed where it is found. All three are written against **files**.
ADR 0085 makes the addressable unit a **span**. What happens to each?

Graduated from the map's fog on 2026-08-14, once `03` resolved and made the record unit
concrete enough to state the question against.

Four parts, and they do not have the same answer:

- **Source Pointers.** `sources:` is declared per file today and `.claude/policies/context.md`
  calls it *"a navigation coordinate, never a claim"*. Once a context file holds many
  addressable spans, does the pointer stay a file-level field, or does a span declare its
  own? A file-level pointer on a file whose spans point at different code is already
  imprecise; flattening makes that visible rather than creating it.
- **The drift model.** A drift finding declares what it `falsifies`. Against a file that
  is a path; against a span that is an id, and ADR 0090's build resolves it. Whether a
  finding may falsify a *span* rather than a file decides whether healing is scoped to
  what actually moved.
- **The Marker.** It records the commit and tree fingerprint Context was last verified
  against — a whole-repository fact. Nothing about flattening obviously changes it, and
  saying so explicitly is cheaper than leaving a reader to wonder.
- **Recovering a broken pointer.** `.claude/protocol.md` says search for where the concept
  moved and never invent a path. With opaque ids and build-time edge resolution (ADR
  0090), a broken *edge* now fails the build. A broken **Source Pointer** still points at
  the Codebase, which the build does not validate — so the two failure modes diverge, and
  whether that is right is the question.

## Answer

Settled with the user on 2026-08-14. Recorded as **ADR 0094**. The four parts do not
have one answer, which is the shape of the result.

- **A Source Pointer is declared on the file; a span may override it.** Most spans share
  a pointer, so the common case is authored once. Span-only was rejected as sediment by
  ADR 0056's own test; file-only was rejected as declining the precision the flattening
  offers free.
- **`falsifies` names an id.** ADR 0090's build already resolves it, so the target is
  validated where a path never could be, and healing scopes to the record that moved. A
  file-level form stays legal, because a finding about a whole file is a real shape.
- **The Marker does not move.** Its two facts are whole-repository values addressed at no
  granularity; ADR 0052 stands untouched. Stated rather than left to be inferred.
- **The edge/pointer asymmetry is kept and the reason is written down.** An edge points at
  knowledge, which has ids; a pointer points at the Codebase, which has none. Verification
  at use is the check. Path-existence checking was rejected on ADR 0071's recorded
  reasoning and on the regenerator fixture that expects `sources` over absent directories
  to succeed; warn-only was rejected as the loud-versus-silent trade made badly.

## Evidence bearing on this

- ADR 0085 — the file is authored, the norm is addressed; ids declared in frontmatter and
  bound by anchor; the id carries the fidelity floor.
- ADR 0090 — the build mints ids and resolves every declared edge; an unresolved edge
  fails, an unreferenced record is only reported. **Edges are validated; Source Pointers
  into the Codebase are not**, which is the asymmetry this ticket has to justify or close.
- `.claude/policies/context.md`, `## What gets written` — the Source Pointer definition
  and the `load-when` rule, both currently file-level fields.
- `CLAUDE.md` — *"Source Pointers are verified before use, always"*. Whatever is decided
  here may not weaken that; the boot tier states it and the boot tier is not this
  effort's to relax.
