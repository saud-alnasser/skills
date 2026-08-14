---
owner: repository
status: accepted
load-when: where the store lives, what is committed, or who writes a norm's id is in question
sources: [.claude/tickets/substrate/issues/06-where-the-store-lives-and-what-authors-it.md]
supersedes: [0018, 0057, 0071]
superseded-by: []
---

# Nothing derived is committed, and the build mints the ids

**Nothing derived is committed.** Markdown files are committed and diffed — the
review path ADR 0085 protects — while the index is local, gitignored, and
rebuildable, and no intermediate artifact sits in version control in either
store. A prebuilt ledger ships **inside the published plugin package** on the
`objects.inv` model, a release build artifact rather than source, so it never
appears in a diff and an install pays no parse cost.

**The criterion reaches past the ledger, which is the larger result.** The four
generated indexes that exist today are committed derived files requiring
regeneration on every knowledge change; under ADR 0084 they become queries and
stop existing as files, taking regenerate-and-compare with them. The friction was
observed rather than predicted: the design session producing this decision
regenerated them eight times, and a dispatched researcher clobbered them by
regenerating over in-flight work.

**The knowledge store lives at `.claude/knowledge/`, flat.** `.claude/memory/`
was rejected on a verified collision — the harness loads auto memory `MEMORY.md`
at position 2 of its documented startup sequence, so the word already names a
different mechanism in the same tree. Flat follows from ADR 0084 making `type` a
field rather than a directory: grouping that today is carried by the filesystem —
a Project Context's directory, an effort's — becomes a declared field like every
other, and nothing navigates the store by hand once the tool serves it. One
directory, one rule, no placement judgement.

**The build mints ids and a heading without one fails the suite.** An author
writes a heading and runs the build, which writes the id into frontmatter,
designing out most of the duplicate-id and dropped-id failure modes ADR 0085
introduced rather than catching them after the fact on every edit. Accepted: an
author who never runs the build ships a red tree, and the build writes to files a
human authored, which no AEP tool does today. The field vocabulary is
discoverable by construction, since enumerating a field's distinct values is a
filter like any other — closing the cost ADR 0089 flagged.

**The build also resolves every declared edge, and an unresolved one fails.** The
id-minting pass already walks every record; validating that each `supersedes`,
`part-of`, `blocked-by`, `falsifies`, `sources`, and `deviates-from` target exists is the
same walk — the sixth is ADR 0095's, and it is what makes an undeclared departure from
framework law fail rather than pass quietly.
This is what makes ADR 0085's opaque ids worth their cost over wikilinks — a
wikilink rebinds silently on rename, a declared id that resolves to nothing is
detectable — and ADR 0092's closure depends on it, since a closure over a broken
edge returns a quietly smaller set. **Unreferenced records are reported, never
failed**: a norm nothing links to is legal, and only a human can tell an orphan
from a root.

## Considered Options

- **A committed ledger in both stores**, enforced by regenerate-and-compare —
  rejected against the stated criterion: every knowledge edit would carry a
  paired ledger diff, which is review noise and a merge-conflict surface on a
  file nobody authored.
- **An asymmetric ledger**, framework-shipped and repository-local — rejected for
  the same reason on its committed half, though its shipped half survives as the
  package artifact above.
- **Author-written ids** — rejected: hand-typed opaque tokens are where duplicates
  and copy-paste collisions come from, and the friction lands on every edit.
- **Optional ids, unlabelled spans unaddressable** — rejected: it makes the
  fidelity floor opt-in, and a norm nobody labelled is one the id-keyed guard
  cannot detect the loss of.
