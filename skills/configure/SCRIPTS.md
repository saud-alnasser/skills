# Deriving `.claude/scripts/`

The scripts this repository runs, written in the language it already uses, each specified here as **behaviour** rather than shipped as code.

**This page is the source of truth, not a copy of anyone's implementation.** A copy in every configured repository forks the moment the shipped one changes; a pointer into the plugin breaks the independence that keeps a repository useful to someone who never installed AEP. A description is neither — so what is specified here is behaviour, and the script that satisfies it belongs to the repository.

Two scripts, and the rule is *every script this page specifies* — not this list, which is only what exists today:

| Script | Written to | Run by |
| --- | --- | --- |
| index regenerator | `.claude/scripts/regenerate-indexes.<ext>` | `/commit`, before staging |
| position report | `.claude/scripts/report-position.<ext>` | every stage that opens with verification |

PowerShell, Node, Python, whatever the repository's own tooling is written in.

**One more thing is specified here and it is not a script**: the regenerate-and-compare check, which runs the regenerator and fails on the difference. It is specified here because this is where the surface it holds is specified, and it needs no file of its own.

## What every derived script owes

**Prove it on its fixture before running it on the repository.** Each specification below carries a worked fixture and its exact expected output, because a freshly configured repository has nothing to compare a first run against — a mis-derived script produces a wrong-but-self-consistent result that every later check agrees with. The fixture is the one check whose answer was not produced by the thing being checked. **Report that it was run and that it matched.**

**Line endings are the checkout's.** Where nothing pins them — no `.gitattributes` — that is the platform's, because comparison is against what git put on disk. A fixed ending fails on every platform but the author's, and fails *as a stale output* rather than as the line-ending disagreement it is.

**UTF-8 without a byte-order mark.** A BOM is three bytes at the front of a file nobody sees in a diff, and it breaks byte comparison.

**What a script emits on standard output is ASCII.** Written output is read back as bytes; emitted output is captured through whatever console encoding the shell happens to have, and a non-ASCII character does not survive one that is not UTF-8 — it arrives as `?`, in output that still looks well-formed. This is not theoretical: the refusal lines below carried an arrow, and it was transcoded on a machine whose console codepage was not UTF-8. The fixture comparison was the only thing that noticed. The same argument as the rule above, one layer out.

Write files whole, and beware a write helper that appends its own trailing newline to the string it is handed: the output already ends in one, and a second is a byte of drift on every run.

**Correctness is held by behaviour, never by text.** There is nothing to compare between this page and an implementation of it, so no entry-comparison check like the one [TOOLS.md](TOOLS.md) gets applies to either script. What differs is how much *else* holds them, and the difference is not cosmetic:

| | held by |
| --- | --- |
| index regenerator | its fixture, **and** the regenerate-and-compare check below |
| position report | its fixture, and nothing else |

A report is not a tracked file, so nothing can regenerate and compare it. For that script the fixture is not a first-run safeguard but the **only** check there will ever be, and a wrongly derived one emits a confident wrong fact that a stage then quotes as authority.

---

## The index regenerator

One script producing every generated index from the fields the indexed files declare.

### What an index is

A table produced from the frontmatter of the files in one directory, so it cannot disagree with that directory: **a file declaring no fields cannot appear, and a row pointing at nothing cannot be produced.** That property is the whole value, and every rule below protects it.

Four families, and the rule is *every index the workflow generates* — not this list, which is only what exists today:

| Family | Written to | One row per |
| --- | --- | --- |
| contexts | `.claude/contexts/map.md` | context file |
| decisions | `.claude/decisions/map.md` | ADR |
| evidence | `.claude/evidence/map.md` | finding, across every kind |
| designs | depends on the layout — see below | spec |

`map.md` is output, never input: exclude it from every directory read, or the second regeneration indexes the first.

### The output, exactly

**Every index opens with `owner: repository` frontmatter** — the generated files sit in a corpus where every instruction and knowledge file declares its owner, and the generator is the only writer here, so the declaration is emitted rather than asked of anyone:

```md
---
owner: repository
---

# Context map

| Context | Load when | Sources |
| --- | --- | --- |
| [repository](repository.md) | a term, boundary, or constraint is in question | — |
| [auth](auth.md) | the request touches sessions or permissions | `src/auth/` |
| **web** | | |
| [web/routing](web/routing.md) | the request touches URL shape | `apps/web/src/routes/` |
```

```md
---
owner: repository
---

# Decision map

| ADR | Load when | Status | Sources |
| --- | --- | --- | --- |
| [0001](0001-vendor-rather-than-rewrite.md) | attribution is in question | accepted | `skills/` |
```

```md
---
owner: repository
---

# Evidence map

| Finding | Kind | Falsifies |
| --- | --- | --- |
| [2026-08-03-a-thing](drift/2026-08-03-a-thing.md) | drift | waiting — `.claude/policies/tracker.md` |
| [2026-08-04-another](drift/2026-08-04-another.md) | drift | consumed — `.claude/policies/knowledge.md` |
| [2026-08-05-a-question](research/2026-08-05-a-question.md) | research | — |
```

```md
---
owner: repository
---

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

**The evidence index's falsifies cell says whether the finding is still waiting**, so an unhealed finding is seen from the index without opening it. A finding that named something to heal renders `waiting — <paths>` until the healing has landed and `consumed — <paths>` once it has; one declaring `[]` keeps the bare em dash, having named nothing to heal.

Which of the two comes from that finding's own consumption mark — a `Consumed:` line in its body, and **the one value any index reads from outside the frontmatter.** It is read there because the mark is where the file already records its healing, and a declared field mirroring it would be a second home for one fact, free to disagree with the first.

**A finding with no mark, or a mark naming nothing, renders `waiting`.** The state is never inferred from the knowledge the finding falsified: unknown resolving to *unhealed* is the safe direction, and the opposite retires evidence nobody acted on. Deciding that a finding was consumed stays a reader's act, and this index only repeats what the file says.

### What the fields are, and what is refused

A field is read from frontmatter and nothing else — the consumption mark above is not a field, and is the single exception stated as one. Two list shapes exist and they are not interchangeable:

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

### The designs index has two layouts, and they differ in more than one place

Specs live either flat in the designs directory or one per effort beside the tickets they govern — `.claude/policies/tracker.md` says which this repository uses. **Three things change with the layout**, and a script that assumes the flat case writes the file to the wrong place under the other:

| | flat | one per effort |
| --- | --- | --- |
| specs found at | `.claude/designs/<slug>.md` | `.claude/tickets/<effort>/spec.md` |
| index written to | `.claude/designs/map.md` | `.claude/tickets/map.md` |
| a row's label / link | `<slug>` / `<slug>.md` | `<effort>` / `<effort>/spec.md` |

Under the effort layout the index is **one level above** every spec rather than beside it, because it spans every effort while each spec belongs to one. The placement rule is where that is decided, and it decides the same thing for the per-effort fog map, which lives inside its effort's directory at `.claude/tickets/<effort>/map.md` and must not be indexed as a spec.

**The two layouts are exclusive.** A tree holding both is refused rather than having one preferred, because preferring one drops every row of the other and reports it as a stale index.

### The regenerator's fixture

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

.claude/evidence/drift/2026-08-03-a-thing.md
---
kind: drift
falsifies: [.claude/policies/tracker.md]
---

# A thing

.claude/evidence/drift/2026-08-04-b-thing.md
---
kind: drift
falsifies: [.claude/policies/knowledge.md]
---

# B thing

Consumed: `.claude/policies/knowledge.md`, "Healing" — abc/01
```

The two findings differ in one thing only: the second carries a consumption mark and the first does not. **A derivation that renders them identically has lost the distinction the evidence index exists to show**, and that is what this pair is here to catch — the other two families cannot catch it, having no such state.

Run the derived script against it. `.claude/contexts/map.md` must be exactly:

```md
---
owner: repository
---

# Context map

| Context | Load when | Sources |
| --- | --- | --- |
| [repository](repository.md) | a term is in question | — |
| [auth](auth.md) | the request touches sessions | `src/auth/`, `src/session/` |
```

and `.claude/decisions/map.md` exactly:

```md
---
owner: repository
---

# Decision map

| ADR | Load when | Status | Sources |
| --- | --- | --- | --- |
| [0002](0002-events-not-http.md) | two contexts need to communicate | accepted | `src/ordering/` |
```

and `.claude/evidence/map.md` exactly:

```md
---
owner: repository
---

# Evidence map

| Finding | Kind | Falsifies |
| --- | --- | --- |
| [2026-08-03-a-thing](drift/2026-08-03-a-thing.md) | drift | waiting — `.claude/policies/tracker.md` |
| [2026-08-04-b-thing](drift/2026-08-04-b-thing.md) | drift | consumed — `.claude/policies/knowledge.md` |
```

All three files end with a single newline. A mismatch is the derivation being wrong, not the fixture.

### How the regenerator stays right afterwards

The enforcement is **the regenerate-and-compare check specified in the next section**: it regenerates each index and compares the result against what git has recorded, so a stale index, a hand-edited one, or a script that has drifted from this page all fail the build. It is a step in the checks this repository already runs, and nothing outside this repository runs it.

Which is also why **a generated index is never hand-edited**. The prohibition holds by being checked, not by being asked of whoever opens the file.

---

## The regenerate-and-compare check

The enforcement the prohibition above rests on, and a step in whatever already fails this repository's build — **not a third script.** Regenerating and then failing on the difference is two lines of checks a repository already runs, so it earns no derived surface of its own and `.claude/scripts/` goes on holding only what this page specifies. A script here would put a new file in every configured repository to perform a comparison that needs no code.

Three steps:

1. **Run the index regenerator** over the repository itself.
2. **Ask git what changed**, limited to the directories that script writes into, so an unrelated build artefact cannot fail this check. The invocation is `.claude/tools/git.md`'s, as the position report's reads are.
3. **Fail on any answer that is not empty, naming every path in it.** A count says an index is stale and never which one, and which one is the reader's next question.

**Both halves of git's answer count — staged and unstaged.** Step 1 overwrites every index it produces, so a hand edit left only in the working tree is gone before step 2 looks at anything; what survives the overwrite is what git had already recorded. A comparison reading the working tree alone reports a tree the regeneration has just corrected, and calls it clean.

### The check's fixture

Build a git repository in a temporary directory: one context file declaring the fields the regenerator requires, and the `.claude/contexts/map.md` that regenerating produces from it. Commit both, so the tree starts clean.

**Case A — a clean tree** — run the check: it exits zero and prints nothing.

**Case B — a hand-edited index** — change one cell of the committed `map.md` by hand, `git add` the edit, then run the check: it exits non-zero, and its output is exactly

```
.claude/contexts/map.md
```

**The `git add` is the fixture rather than a detail of it.** Step 1 overwrites that file before step 2 looks at anything, so an edit left in the working tree and never staged is gone by the time the comparison runs — the check reports a clean tree, and it is right, because by then nothing was wrong. Staging is what puts the edit where the overwrite cannot reach it, which is what a *committed* hand edit does in the case this check exists for. **Testing it unstaged proves the opposite of what it appears to prove**: a session ran exactly that, read the clean report as the mechanism failing to catch hand edits, and reported that.

---

## The position report

One script reporting where this clone stands, and attesting that it did.

### What it emits, and what it does not

The verification report a stage opens with has **two halves, and only one of them can be computed.**

**Position** is mechanical: the Marker's two facts against the live two, and the drift lists when they differ. **Judgement** is the stage's own: which contexts the work routes to, whether a Source Pointer still resolves, whether a Context statement is contradicted by source, and what was done about each.

**This script emits the position half and never the judgement half.** No script can produce the second — it requires knowing what the work touches and reading what it claims. The stage prints its own half beneath the script's output.

That boundary is what makes any of this enforceable. The half that can be checked was previously not separated from the half that cannot, which is why the whole report read as something nobody could verify.

### The reads

Five, in this order, and `.claude/tools/git.md` has the exact invocations for every one:

1. **The marker file** — its `commit` and `tree`. The path has one home and that guide is it; read it fresh from there, never from memory.
2. **`HEAD`**, as a full object name.
3. **Does the marker's commit still exist**, and **is it an ancestor of `HEAD`**. Two separate questions with two separate refusals.
4. **The tree fingerprint** — a git tree object built through a throwaway index seeded from the repository's own. Seeding is not an optimisation: without it every file in the worktree is re-hashed on every stage, and the check costs more than the reads it replaces.
5. **The two drift reads** — what commits changed since the marker, excluding the protocol directory; and what is uncommitted, including untracked files.

Read four and five **only when an identity differs**. A match on both licenses skipping them, and skipping them is the entire point.

### The report, exactly

Two spaces of indent, the label in a six-wide field, two spaces, then the columns. Object names are abbreviated to seven characters.

When both identities match:

```
Position
  marker  b74df9e  HEAD b74df9e   commit match
  tree    9f1d2af  live 9f1d2af   tree match
  drift   reads skipped
  mode    session 468b4f04
```

When either differs, the drift lines carry the paths and not a count alone — a count says something moved and never what, which is the read the stage is about to need:

```
Position
  marker  a3f91c2  HEAD b74df9e   14 commits ahead
  tree    9f1d2af  live 3a1c802   tree differs
  drift   6 committed, 2 uncommitted
            src/db/schema.ts
            src/db/migrate.ts
  mode    commit-only (run identity unavailable)
```

Committed paths first, then uncommitted, each on its own line at twelve spaces. **Never truncated.** A capped list hides the one path that mattered and reports the same shape as a complete one.

The commit verdict is `commit match`, or the count of commits `HEAD` is ahead. The tree verdict is `tree match` or `tree differs`. Neither is ever both.

**A marker carrying no tree fact takes the differing branch**, and is not a fourth refusal. The tree is unknown, so the drift reads run — unknown resolving to *read it* is the safe direction, where the reverse would skip a read on the strength of a fact nobody recorded.

### The three refusals

Each ends the report, and each says **what it does not license** rather than only what was found. All three are results, not errors — the script exits zero and the stage acts on the answer.

**The marker file is absent.** Nothing was ever verified in this clone:

```
Position
  marker  absent
  -> nothing was verified in this clone; everything the request touches is unverified
  mode    session 468b4f04
```

**The marker's commit no longer exists** — rewritten, or never fetched:

```
Position
  marker  a3f91c2  gone from this clone
  -> no diff is possible from it; everything the request touches is unverified
  mode    session 468b4f04
```

**The marker is not an ancestor of `HEAD`** — a branch switch, a rebase, a reset:

```
Position
  marker  a3f91c2  HEAD b74df9e   not an ancestor
  -> the diff between them is meaningless; everything the request touches is unverified
  mode    session 468b4f04
```

A missing marker file is **an answer, not a prompt to look elsewhere.** Do not search for another path, and do not treat a refusal as a reason to skip the report.

### The receipt

The same run writes `.claude/position/receipt.json`, whole, four fields and no others:

```json
{
  "run": "468b4f04-ab27-4249-8cd5-01e3ea341a84",
  "mode": "session",
  "head": "b74df9e8fa2a6cf4a446920efe3ce5a085060778",
  "tree": "9f1d2afa509f8cb582acf6f721d0c154104f56d1"
}
```

`head` and `tree` are what was **observed** — the live values, never the marker's. That distinction is the whole usefulness of the file: the commit stage asks whether a receipt attests *this* position, and a receipt echoing the marker would answer a different question.

**A receipt is written on every run, including all three refusals.** A refusal is a computed position whose answer is *unverified*, and a clone with no marker must still be able to commit.

The receipt is **Position** — per-clone, never committed. `.claude/.gitignore` already covers it by category, so no entry names it individually.

**That ignore is a precondition of the whole mechanism, not bookkeeping.** The script writes the receipt into the position directory during the run, and the marker sits there too. A tree that counted either would have a different fingerprint after the run than the one just reported, and the marker could never match the tree it was written from — every stage would read drift that was only its own attestation.

### The fallback, which is contract rather than aside

The run identity comes from `CLAUDE_CODE_SESSION_ID` in the environment. **It is observed rather than documented** — it carries the right value in a tool call, but the reference names only the effort level as reaching one and names the session identifier only as JSON input to a hook. So the script never requires it:

| | `run` | `mode` |
| --- | --- | --- |
| identity available | the identifier | `session` |
| identity absent | `null` | `commit-only` |

Under `commit-only` the report says so on its `mode` line, in the words shown above. **A downgrade that is not stated is a downgrade nobody can detect** — which is the entire mitigation, and the reason the mode is a field rather than an inference.

### The position report's fixture

Object names cannot be literals here — a commit's name depends on when and by whom it was made — so the fixture captures them and the expected output is stated with substitutions. That is still a byte comparison: substitute the captured values, then compare.

Build a repository in a temporary directory: one commit, holding a seed file and a `.gitignore` that ignores the position directory — as every configured repository has. Without that ignore no case can pass, for the reason stated above, and a fixture that omitted it would be testing a tree no configured repository resembles. Capture `<head>` as its full object name, `<head7>` as the first seven characters, and `<tree>` / `<tree7>` from the fingerprint of the clean tree. Run cases A to C with the run identity **unset**; D is what exercises it being present.

**Case A — both identities match.** Write the marker file holding `<head>` and `<tree>`. Expected output, exactly:

```
Position
  marker  <head7>  HEAD <head7>   commit match
  tree    <tree7>  live <tree7>   tree match
  drift   reads skipped
  mode    commit-only (run identity unavailable)
```

**Case B — the tree differs.** Same marker, then add one untracked file `a.txt`. Expected output, exactly:

```
Position
  marker  <head7>  HEAD <head7>   commit match
  tree    <tree7>  live <live7>   tree differs
  drift   0 committed, 1 uncommitted
            a.txt
  mode    commit-only (run identity unavailable)
```

where `<live7>` is the fingerprint taken with `a.txt` present. It must differ from `<tree7>` — a fingerprint blind to an untracked file is the defect this read exists to catch, and Case B is what proves the derived script is not blind to one.

**Case C — no marker file.** Remove it. Expected output, exactly:

```
Position
  marker  absent
  -> nothing was verified in this clone; everything the request touches is unverified
  mode    commit-only (run identity unavailable)
```

**Case D — the identity is present.** Case A again with the session identifier set to `test-run-id`. Only the last line changes, to `  mode    session test-run-id`.

**Case E — the marker's commit is gone.** Write the marker holding a well-formed object name that names no object here. Expected output, exactly:

```
Position
  marker  <gone7>  gone from this clone
  -> no diff is possible from it; everything the request touches is unverified
  mode    commit-only (run identity unavailable)
```

**Case F — the marker is not an ancestor.** Commit once on a second branch, return to the first, and write the marker holding the second branch's commit. It exists, and `HEAD` is not descended from it. Expected output, exactly:

```
Position
  marker  <other7>  HEAD <head7>   not an ancestor
  -> the diff between them is meaningless; everything the request touches is unverified
  mode    commit-only (run identity unavailable)
```

E and F are the two refusals a derivation is most likely to collapse into one, or into a crash. They are different questions with different consequences — an object that is absent against one that is present and unrelated — and a script answering both with the same line has lost the distinction the reader needs.

Every case ends with a single newline, and every case writes a receipt. After A, the receipt must hold `<head>` and `<tree>` with `"run": null` and `"mode": "commit-only"`; after D, the identifier and `"mode": "session"`.

### How the position report stays right afterwards

**By its fixture, and by nothing else.** The output is not a tracked file, so there is no regenerate-and-compare to fall back on and no second opinion of any kind. Run the fixture whenever the script or this page changes, and treat a passing report on the repository as no evidence at all — a wrongly derived script agrees with itself.
