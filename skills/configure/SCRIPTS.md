# Deriving `.claude/scripts/`

One script, written in the language this repository already uses, producing every generated index from the fields the indexed files declare.

**This page is the source of truth, not a copy of anyone's implementation.** A copy in every configured repository forks the moment the shipped one changes; a pointer into the plugin breaks the independence that keeps a repository useful to someone who never installed AEP. A description is neither — so what is specified here is **behaviour**, and the script that satisfies it belongs to the repository.

Write it to `.claude/scripts/regenerate-indexes.<ext>` — PowerShell, Node, Python, whatever the repository's own tooling is written in. `/commit` invokes it before staging.

## What an index is

A table produced from the frontmatter of the files in one directory, so it cannot disagree with that directory: **a file declaring no fields cannot appear, and a row pointing at nothing cannot be produced.** That property is the whole value, and every rule below protects it.

Four families, and the rule is *every index the workflow generates* — not this list, which is only what exists today:

| Family | Written to | One row per |
| --- | --- | --- |
| contexts | `.claude/contexts/map.md` | context file |
| decisions | `.claude/decisions/map.md` | ADR |
| evidence | `.claude/evidence/map.md` | finding, across every kind |
| designs | depends on the layout — see below | spec |

`map.md` is output, never input: exclude it from every directory read, or the second regeneration indexes the first.

## The output, exactly

```md
# Context map

| Context | Load when | Sources |
| --- | --- | --- |
| [repository](repository.md) | a term, boundary, or constraint is in question | — |
| [auth](auth.md) | the request touches sessions or permissions | `src/auth/` |
| **web** | | |
| [web/routing](web/routing.md) | the request touches URL shape | `apps/web/src/routes/` |
```

```md
# Decision map

| ADR | Load when | Status | Sources |
| --- | --- | --- | --- |
| [0001](0001-vendor-rather-than-rewrite.md) | attribution is in question | accepted | `skills/` |
```

```md
# Evidence map

| Finding | Kind | Falsifies |
| --- | --- | --- |
| [2026-08-03-a-thing](drift/2026-08-03-a-thing.md) | drift | `.claude/policies/tracker.md` |
```

```md
# Design map

| Design | Status | Sources |
| --- | --- | --- |
| [caching](caching.md) | accepted | `src/cache/` |
```

**Row order is part of the output.** Two regenerations of one unchanged directory must be byte-identical, so an unfixed order makes "byte-identical" mean nothing:

- **contexts** — `repository.md` first, it being cross-cutting rather than a domain; then filename order; then each subdirectory as a labelled group, its label row carrying the directory name in bold and two empty cells, because nothing declares a value for them.
- **decisions** — numeric, by the four-digit prefix.
- **evidence** — filename order, which is date order, with the kind directory breaking a tie.
- **designs** — the order the specs were located in, which is filename order.

**A cell with nothing in it is an em dash**, `—`, never blank. Blank reads as a column nobody filled in; the dash says the file declared nothing to point at. The one exception is a context group's label row, where blank is the point: nobody was asked.

**Path-valued cells are backticked and comma-joined.**

## What the fields are, and what is refused

A field is read from frontmatter and nothing else. Two list shapes exist and they are not interchangeable:

- **Inline** — `sources: [a, b]` — used by contexts, decisions, and evidence.
- **Block** — the key alone on its line, then indented `- entry` lines — used by specs, because a single pointer can contain a comma (`src/api/handlers.ts L40-L90` is one entry) and inline form would split it silently.

**Refuse rather than read as empty.** Every one of these stops the regeneration and names the file:

| Refused | Because |
| --- | --- |
| a file in an indexed directory with no frontmatter | a missing row makes the file unreachable, and the silent version is found by whoever needed it |
| a required field absent | the row would answer the reader's question with a blank |
| a list in the other shape | read as empty it renders a file as pointing nowhere — a wrong answer no reader could tell from a right one |
| `key:` with nothing under it | that is YAML null, not an empty list; `[]` is how a file says it points at nothing |
| a declared `kind` that disagrees with the directory the file sits in | the row would read as one kind and link to another |
| an ADR filename without a four-digit prefix | the id is the row's link text and its sort key, and neither can be invented |

Required per family: `load-when` for contexts; `load-when` and `status` for decisions; `kind` for evidence; `status` for specs. Every family requires its list field, and `[]` satisfies it.

**Read only `*.md`, one level deep**, except evidence — whose kinds are directories, walked one level further. A family whose directory does not exist is an error naming it; a family that exists but holds no file produces **no index at all**, because a table with a header and no rows is a claim that the directory was read and found empty.

## The designs index has two layouts, and they differ in more than one place

Specs live either flat in the designs directory or one per effort beside the tickets they govern — `.claude/policies/tracker.md` says which this repository uses. **Three things change with the layout**, and a script that assumes the flat case writes the file to the wrong place under the other:

| | flat | one per effort |
| --- | --- | --- |
| specs found at | `.claude/designs/<slug>.md` | `.claude/tickets/<effort>/spec.md` |
| index written to | `.claude/designs/map.md` | `.claude/tickets/map.md` |
| a row's label / link | `<slug>` / `<slug>.md` | `<effort>` / `<effort>/spec.md` |

Under the effort layout the index is **one level above** every spec rather than beside it, because it spans every effort while each spec belongs to one. The placement rule is where that is decided, and it decides the same thing for the per-effort fog map, which lives inside its effort's directory at `.claude/tickets/<effort>/map.md` and must not be indexed as a spec.

**The two layouts are exclusive.** A tree holding both is refused rather than having one preferred, because preferring one drops every row of the other and reports it as a stale index.

## Line endings

Emit the line ending the checkout uses. Where nothing pins it — no `.gitattributes` — that is the platform's, because comparison is against what git put on disk. A fixed ending makes byte-for-byte comparison fail on every platform but the author's, and fail *as a stale index* rather than as the line-ending disagreement it is.

**UTF-8 without a byte-order mark.** A BOM is three bytes at the front of a file nobody sees in a diff, and it breaks the byte comparison this page's whole enforcement rests on.

Write the file whole. Beware a write helper that appends its own trailing newline to the string it is handed: the output already ends in one, and a second is a byte of drift on every run.

## Prove it on the fixture before running it on the repository

**A freshly configured repository has no committed index to compare a first regeneration against.** The first run creates them, so a mis-derived script produces a wrong-but-self-consistent result that every later comparison agrees with. The fixture below is the one check whose answer was not produced by the thing being checked.

Build this tree in a temporary directory:

```
.claude/contexts/repository.md
---
load-when: a term is in question
sources: []
---

# R

.claude/contexts/auth.md
---
load-when: the request touches sessions
sources: [src/auth/, src/session/]
---

# Auth

.claude/decisions/0002-events-not-http.md
---
status: accepted
load-when: two contexts need to communicate
sources: [src/ordering/]
supersedes: []
superseded-by: []
---

# Events, not HTTP
```

Run the derived script against it. `.claude/contexts/map.md` must be exactly:

```md
# Context map

| Context | Load when | Sources |
| --- | --- | --- |
| [repository](repository.md) | a term is in question | — |
| [auth](auth.md) | the request touches sessions | `src/auth/`, `src/session/` |
```

and `.claude/decisions/map.md` exactly:

```md
# Decision map

| ADR | Load when | Status | Sources |
| --- | --- | --- | --- |
| [0002](0002-events-not-http.md) | two contexts need to communicate | accepted | `src/ordering/` |
```

Both files end with a single newline. **Report that this was run and that it matched**, then run the script against the repository. A mismatch is the derivation being wrong, not the fixture.

## How it stays right afterwards

**By behaviour, never by text.** There is nothing to compare between this page and an implementation of it, so no entry-comparison check like the one `TOOLS.md` gets applies. The enforcement is the regenerate-and-compare rule's: the suite regenerates each index and compares it against what is committed, so a stale index, a hand-edited one, or a script that has drifted from this page all fail the build.

Which is also why **a generated index is never hand-edited**. The prohibition holds by being checked, not by being asked of whoever opens the file.
