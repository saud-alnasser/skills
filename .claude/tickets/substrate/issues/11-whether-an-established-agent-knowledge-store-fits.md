---
owner: repository
title: "docs(evidence): establish whether an existing agent knowledge store fits AEP"
status: resolved
blocked-by: []
part-of: substrate
type: research
---

## Question

Does a well-established knowledge store for agents already exist that AEP could
adopt, rather than building one?

Asked during `10`'s grill and ticketed rather than answered, because the answer
is an external fact and no session here has established it. It matters more than
a build-detail: if something fits, `06` answers *which to adopt* rather than
*what to build*, and the effort's shape changes.

Judge candidates against what `02`, `03`, and `07` already settled, since a store
that cannot express these is not a fit however popular it is:

- **Typed records with declared fields**, where the type is a first-class
  property and required fields vary by type.
- **Spans within a document as the addressable unit**, identified by a stable
  declared id and bound to a heading — not whole files, and not chunks a
  retriever chose.
- **Multiple stores behind one query interface**, one of which ships inside a
  distributed package and is never written to.
- **Derivation from committed markdown**, with the index rebuildable locally and
  the source remaining the reviewed artifact. A store that owns its own content
  rather than deriving it does not fit.
- **An index that is not the source of truth**, so nothing needs synchronising
  between machines.
- **Computed precedence over a result set**, or enough returned metadata that the
  caller can compute it.

Also settle what is *not* a fit and why, because the rejections are what stop
the question being reopened: general-purpose vector retrieval chunks by
similarity rather than by declared span, which the `03` decision rules out.

The answer names what exists, what each would cost to adopt, and what AEP would
have to give up to use it — or establishes that nothing fits and the build is
justified. **Report unverified starting points as unverified**: no product,
capability, or version is asserted here without a primary source read.

## Answer

`.claude/evidence/research/2026-08-13-whether-an-established-agent-knowledge-store-fits.md`,
sixteen candidates across six families, all fetched 2026-08-13.

**Nothing fits. The build is justified, and `06` answers *what to build*.** Every
candidate fails at least three of the six criteria, and **two criteria have no
candidate anywhere**: computed precedence over a result set, and a read-only
store shipped inside a distributed package federated with a writable local one
behind one interface.

The three nearest misses each fail on a different settled axis, which is what
makes the rejection durable rather than a matter of taste:

- **Open Knowledge Format v0.2** is closest on shape — committed markdown, YAML
  frontmatter, `type` always required — but its concept id *is* the file path, so
  the unit is a whole file and identity moves on rename. Fails ADR 0085 twice,
  defines no per-type required fields, and forbids rejecting a bundle over
  unknown types, which inverts ADR 0086.
- **jDocMunch** is closest on span addressing, keying a section tree by heading —
  and fails on identity exactly where it matters: a section keeps identity only
  while path, heading text, and level are unchanged, so a rename silently
  rebinds. That is the failure ADR 0085's declared id plus two-way assertion
  buys out, and it is the one carrying the fidelity floor.
- **Astro content collections** satisfy per-type schemas, derivation, and local
  rebuildability, but the unit is a whole file and headings survive only as
  render metadata.

**The vector-store rejection is narrower than this ticket assumed, and the
correction is recorded rather than smoothed over.** A caller-supplied id means a
caller *could* key one record per declared span — the chunking would be the
caller's, not the store's. The disqualifier is what such a store does not supply
— typing, span derivation, precedence, the packaged store — plus that it holds
its own copy of the text, which fails derivation. Where the retriever chooses the
chunks, ADR 0085 rules it out directly.

**Two pieces of prior art to borrow rather than reinvent**, both outside the
agent space: Sphinx independently arrived at ADR 0085's design — a declared label
before a heading, stable across a title change, with a broken reference as a
build warning — and `objects.inv` is a working analogue of ADR 0084's framework
store, a derived index shipped inside a published package, resolved by id, never
written to. `06` should read both before designing.

**Largest gap:** the `jMRI-Full` retrieval-interface specification is referenced
by jDocMunch but could not be located. If it standardises span addressing across
MCP servers it is the most relevant document in the landscape, and `06` should
try again before committing to a design.
