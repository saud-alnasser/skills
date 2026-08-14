---
owner: repository
kind: research
falsifies: []
---

# Can a database be AEP's authoritative store, given it must be repository-owned?

Verified against: project documentation and repository pages fetched 2026-08-13.
Status: answered. Open: no embedded versioned database was found, and absence is
inferred from the two market leaders rather than from an exhaustive sweep.

Third and widest framing of the store question, asked after the markdown constraint
was withdrawn: *the most efficient store for framework-owned knowledge, repository-owned
knowledge, and tracking, with a strong query API, local and never cloud, free and open
source, and well-established.* The two prior findings assumed markdown; this one does
not.

## Answer

**A database cannot be the authoritative store, and the blocker is not performance,
licensing, or maturity — it is that every versioned database brings its own version
control.**

The category that solves structured-data versioning is real, mature, and free:

- **Dolt** — 24.2k stars, Apache-2.0, 31,494 commits on main, actively developed. A
  MySQL-compatible database with genuine branch, diff, merge, and log over table rows,
  with **cell-wise rather than line-wise conflicts**. On its own terms it is excellent.
  — [github.com/dolthub/dolt](https://github.com/dolthub/dolt)
- **TerminusDB** — 3.4k stars, Apache-2.0, 5,798 commits, under new maintainers with an
  enterprise edition. A document graph database storing JSON in a schema-enforced graph,
  versioning individual triples, with structured semantic diffs.
  — [github.com/terminusdb/terminusdb](https://github.com/terminusdb/terminusdb)

Both fail AEP on the same two counts, and both counts are structural:

**They require a server process.** Dolt is started with `dolt sql-server`; TerminusDB is
distributed for Docker. Neither is embedded or in-process. A plugin-shipped store that
needs a daemon inherits the failure ADR 0088 already had to design around — a stdio
server that dies is never reconnected — and multiplies it by a second runtime a
repository must install.

**Their version control is their own, and it is not git.** Dolt stores a database in its
own directory with its own commit graph, "entirely independent of Git itself"; git
cannot diff or merge it. TerminusDB is the same shape. That is disqualifying against a
norm AEP already holds: `.claude/policies/knowledge.md` requires that a correction
"lands in the same commit as the change, so the two never land apart." **Two version
control systems means two histories, and knowledge and the code it governs can then land
apart** — which is precisely the failure the norm exists to prevent. A repository would
also be asking reviewers to approve a change whose knowledge half is invisible to the
pull request.

## What this leaves, and why it is not a compromise

The efficiency question and the repository-owned question have different answers, and
the split already recorded is the resolution rather than a concession to it:
**authoritative text in git — one history, reviewable, mergeable — with a derived index
that is local, gitignored, and rebuilt.**

For that derived index the answer is **SQLite**, and the establishment test the question
asked for understates it: SQLite is public domain rather than a starred GitHub project,
and is the most widely deployed database in existence. The workload is the reason it is
sufficient rather than a compromise — under ADR 0089 every query is a filter over
declared fields with no free-text search, and the corpus is on the order of hundreds of
records, so this is point lookups and filtered scans over a small table. DuckDB's
documented advantage is 10–100× on OLAP aggregations over large datasets, which is a
workload this is not.

## The finding that matters most

**None of the improvements the question is aimed at come from the storage engine.**
Fewer tokens comes from filtering a row by `fires-when` (ADR 0089 as amended); speed
comes from delivering the row by preprocessing instead of N file reads; determinism comes
from filters replacing judged selection; the structural simplification comes from types
being fields rather than directories. A faster database moves none of those numbers,
because none of them is bounded by storage.

Stated plainly so it is not rediscovered: at a corpus of hundreds of records, **storage
efficiency is not a constraint on this system at all**, and choosing a store for
efficiency would optimise the one axis that was never binding.

## Limitations

- **The absence of an embedded versioned database is inferred, not swept.** Dolt and
  TerminusDB are the two the search surfaced; a smaller in-process project with git-native
  storage would not have appeared, and would change the first half of this answer.
- **Every claim is fetched documentation, not source or execution.** No database was
  installed, started, or measured; the DuckDB and SQLite comparison figures are a
  secondary source's summary, not a benchmark run here.
- **Star counts and commit totals are as displayed on 2026-08-13** and are a proxy for
  establishment, not a measure of fitness.
