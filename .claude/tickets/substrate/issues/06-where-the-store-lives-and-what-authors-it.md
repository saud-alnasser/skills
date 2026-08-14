---
owner: repository
title: "docs(protocol): settle where the store lives and what authors it"
status: resolved
blocked-by: [01, 03, 11]
part-of: substrate
type: grilling
---

## Question

What is the store, physically — and which of its forms is authored, which
derived?

The user's sketch is a flat directory of typed records. That is one of several
shapes, and the choice decides what can be reviewed in a pull request, what the
audit compares, and what a merge conflict looks like.

Settle:

- Whether records are authored as markdown and compiled to an index the tool
  queries, or authored directly into a structured form with markdown as export.
  `ADR 0053` says a generated file is never hand-edited and the prohibition is
  enforced by regenerate-and-compare — whichever side is derived inherits that.
- Where it lives. `.claude/memory/` was the user's suggestion; the name collides
  with Claude Code's own memory feature and with the user's auto-memory
  directory, so it needs deciding rather than inheriting.
- Whether the store is committed. A derived index that is not committed cannot
  be diffed; one that is committed is a second copy that can disagree with its
  source between commits.
- What a reviewer sees. A norm change today is a readable diff, and that is how
  every `crystallize` conversion was caught mid-rewrite; 2.0 must not lose it.
- How the framework's own records and a configured repository's records coexist
  in one store, given `owner: framework` is byte-locked to a template and
  `owner: repository` is healable.

## Answer

**Nothing derived is committed.** That was the deciding criterion, given in place
of the options offered, and it settles the chain: markdown files are committed
and diffed, which is the review path ADR 0085 protects; the index is local,
gitignored, and rebuildable; and no intermediate artifact sits in version control
in either store. A prebuilt ledger still ships **inside the published plugin
package** on the `objects.inv` model `11` surfaced — a release build artifact
rather than source, so it never appears in a diff and an install pays no parse
cost.

**The criterion reaches further than the ledger, and that is the larger result.**
Today's four generated indexes — `contexts/map.md`, `decisions/map.md`,
`evidence/map.md`, `tickets/map.md` — are committed derived files that must be
regenerated on every knowledge change. Under ADR 0084 they become queries, so
they stop existing as files at all and regenerate-and-compare goes with them.
The friction is not hypothetical: the design session that produced this map
regenerated them eight times, and a dispatched researcher clobbered them by
regenerating over in-flight work and had to revert.

**The knowledge store lives at `.claude/knowledge/`, flat**, matching the store's
name in ADR 0084. `.claude/memory/` was rejected on a verified collision rather
than taste: `01` established that the harness loads auto memory `MEMORY.md` at
position 2 of its documented startup sequence, so the word already names a
different mechanism in the same tree.

Flat is settled by ADR 0084 rather than chosen here: once `type` is a field
rather than a directory, the grouping the filesystem carries today — a Project
Context's directory, an effort's — becomes a declared field like any other, and
nothing navigates the store by hand once the tool serves it. One directory, one
rule, no placement judgement. This is the answer to the *simpler file structure*
goal at the level below the directory count.

**The build mints ids; a heading without one fails the suite.** An author writes
a heading and runs the build, which writes the id into frontmatter. This designs
out most of the duplicate-id and dropped-id failure modes ADR 0085 introduced,
rather than catching them after the fact on every knowledge edit. Two costs
accepted: an author who never runs the build ships a red tree, and the build
writes to files a human authored, which no AEP tool does today.

**The field vocabulary is discoverable by construction**, closing the cost `04`
flagged: with queries as filters over declared fields, enumerating a field's
distinct values is a filter like any other, so a caller can ask what values exist
rather than having to know them.

Recorded as ADR 0090.
