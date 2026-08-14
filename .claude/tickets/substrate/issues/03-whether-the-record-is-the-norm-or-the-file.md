---
owner: repository
title: "docs(protocol): settle whether the record is the norm or the file"
status: resolved
blocked-by: [02]
part-of: substrate
type: grilling
---

## Question

Is the unit of the store a file holding many norms, or one norm?

Today a policy file holds dozens of norms and is loaded whole. A store built for
retrieval probably wants the norm itself as the addressable record — but that
inverts how every norm in the corpus is currently authored, and the cost is not
obviously worth it.

Settle:

- What a norm record carries if it is the unit: an identity, its type, its
  owner, when it fires, the imperative, the one-line why (`ADR 0074`), and the
  suite guard that pins it.
- What holds a norm's *context* when its neighbours are no longer beside it.
  Several norms in the corpus are only correct read together — the Marker's two
  facts, the expand–contract sequence — and a store that shatters them produces
  confidently wrong answers.
- Whether a container survives above the norm, and if so what it is for once it
  is no longer the loading unit.
- What authoring one looks like by hand, since a human writes the first version
  of every norm regardless of what serves it.
- Whether the ~600 suite assertions can be re-anchored to norm records without
  losing the fire-check discipline `crystallize` established.

This is the decision that makes retrieval possible or leaves 2.0 as file loading
with extra steps.

## Answer

**The file is authored; the norm is addressed.** Files remain the unit humans
write, review, and diff — the review path that caught thirteen lost norms during
`crystallize` — and the ledger decomposes them into the norm records the index
serves. The container survives as the authored, reviewed, and migrated unit; at
query time it is a locator rather than a payload.

**A record is the smallest span that is correct on its own, carried by a
heading.** Not a bullet: the Marker's two facts are one record, expand–migrate–
contract is one record, and a file with no headings — `boundary`, `placement`,
`precedence`, `knowledge`, and all seven modes — is one record, which is right
at 1–2.5 KB and internally coupled. Coupling is therefore a property of where
the boundary was drawn rather than a mechanism: there is no cross-reference
graph to maintain and nothing to under-declare, which was the silent failure the
alternative carried.

Measured before choosing: 107 headings against 215 norm-shaped bullets across 22
framework-owned files, roughly 800 bytes per heading-span. Heading granularity
is about 5× finer than file-level and needs no new body syntax.

**Ids are declared in frontmatter and bind by heading anchor** — `id` with `at`
— never inline, because metadata for a markdown file lives in frontmatter
without exception. They are short opaque tokens written once at authoring and
never changed, and they identify **norms rather than filenames**, so files keep
readable names and `.claude/policies/decisions.md`'s guarantee that inbound
references to `0007` keep resolving is untouched.

**The suite asserts the binding in both directions** — every declared anchor
resolves to a heading, every heading carries an id — so a heading rename fails
the build rather than silently unbinding, and the two failure modes declared ids
introduce, a duplicate and a dropped one, are caught mechanically.

**The id is what carries the fidelity floor.** A guard keyed on an id catches a
norm dropped during a rewrite by *absence*, where today's guards match a norm's
subject by a pattern someone had to author correctly — the failure `crystallize/
09` hit, where a manifest row could not fire because its pattern matched a
different norm's tail. This is the point in the effort where quality increases
rather than merely holding.

**Stated rather than discovered:** *smallest correct span* is now a constraint on
how headings are written, not only a retrieval property. It is an authoring
burden the suite cannot check — an under-split record loses precision silently,
an over-split one loses correctness silently.

Recorded as ADR 0085. Cross-store coupling — a repository norm depending on a
framework norm, which no shared heading can hold — is graduated onto `07`.
