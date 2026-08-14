---
owner: repository
status: accepted
load-when: how a norm is bounded, identified, or retrieved is in question
sources: [.claude/tickets/substrate/issues/03-whether-the-record-is-the-norm-or-the-file.md]
supersedes: []
superseded-by: []
---

# The file is authored, the norm is addressed, and the id carries the fidelity floor

Files remain the unit humans write, review, and diff, and the ledger decomposes
them into the norm records the index serves. **A record is the smallest span that
is correct on its own, carried by a heading** — the Marker's two facts are one
record, expand–migrate–contract is one record, and a file with no headings is one
record. Coupling is thereby a property of where the boundary was drawn rather
than a mechanism, so no cross-reference graph exists to be under-declared, which
was the silent failure the declared-coupling alternative carried. Measured before
choosing: 107 headings against 215 norm-shaped bullets across 22 framework-owned
files, about 800 bytes per span, roughly 5× finer than file-level with no new
body syntax.

**Ids are declared in frontmatter and bind by heading anchor**, never inline,
because metadata for a markdown file lives in frontmatter without exception. They
are short opaque tokens written once and never changed, identifying **norms
rather than filenames** — so files keep readable names and the guarantee in
`.claude/policies/decisions.md` that inbound references to `0007` keep resolving
survives untouched. The suite asserts the binding in both directions, so a
heading rename fails the build rather than silently unbinding, and a duplicated
or dropped id is caught mechanically.

**The reason this is worth its cost is the fidelity floor.** A guard keyed on an
id catches a norm dropped during a rewrite by *absence*; today's guards match a
norm's subject by a pattern someone had to author correctly, and `crystallize/09`
found one that could not fire because its pattern matched a different norm's
tail. Identity turns that from a skill question into a mechanical one.

Stated rather than discovered: *smallest correct span* becomes a constraint on
how headings are written, and it is an authoring burden the suite cannot check —
an under-split record loses precision silently, an over-split one loses
correctness silently.

## Considered Options

- **The norm is the record**, each in its own file — rejected: it shatters norms
  that are only correct read together, and puts 300+ files in front of the
  reviewer where the fidelity floor currently operates.
- **The file is the record**, no decomposition — rejected: retrieval granularity
  stays a whole file, which weakens the case that a query beats an exact read and
  removes norm-level absence detection.
- **Declared coupling between small records** — rejected because
  under-declaration is silent and undetectable: the query succeeds, returns a
  fragment, and nothing reports the missing dependency.
- **Ids bound by ordinal position** — rejected: inserting a span without its id
  shifts every binding below it, indistinguishable from a deliberate reordering.
- **Ids derived from a content hash of the imperative** — rejected: a cosmetic
  reformatting reads as a deletion plus an addition, which the fidelity floor
  cannot tell from a real loss.
