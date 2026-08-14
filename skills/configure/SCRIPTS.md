# The scripts a repository copies into `.claude/scripts/`

The scripts a configured repository runs, written once here as JavaScript the plugin carries, and copied into the repository byte for byte. This page documents what each one does and why; it is not a description for somebody to re-implement.

**A copy, not a derivation, and not a pointer.** The three were weighed and two lost. A **pointer into the plugin** cannot be resolved by the thing that needs it: the harness exports the plugin's root to a hook process and to skill content, never to a stage's shell. A **derivation per repository** — this page's own model until 2.0 — bought polyglot fit by asking every repository to re-implement a byte-exact contract, and rested on two supports that 2.0 removed: a repository readable without the plugin, and a regenerate-and-compare check that made a re-implementation enforceable in any language. What is left of the case against copying is the fork, and the fork is now detectable: a copy declares the release it came from, and the session hook compares it against the running one.

The rule is *every script this page documents* — not this list, which is only what exists today:

| Script | Copied to | Run by | Since | Until | Written |
| --- | --- | --- | --- | --- | --- |
| index regenerator | `.claude/scripts/regenerate-indexes.js` | `/commit`, before staging | 1.0.0 | 2.0.0 | not yet |
| position report | `.claude/scripts/report-position.js` | every stage that opens with verification | 1.0.0 | — | — |
| knowledge store builder | `.claude/scripts/build-knowledge-store.js` | `/commit`, before staging | 2.0.0 | — | — |
| store query | `.claude/scripts/query-knowledge-store.js` | any stage reaching past its own row | 2.0.0 | — | — |
| row assembler | `.claude/scripts/assemble-row.js` | the harness, inlining a stage's row before its content | 2.0.0 | — | — |

**The `Written` column is not bookkeeping, and it is the one that is currently embarrassing.** A page documenting code says *this exists*; a page documenting a script nobody has written yet says something a reader has to be told rather than left to discover on the first configuration run. Each row loses the column as its script lands.

**The `Since` column is what makes the list checkable against a repository mid-upgrade.** A repository receives the scripts for the release it is on, so a page naming one from a later release is not a script somebody forgot to copy — and a check that could not tell those apart would either fail every repository behind the current release or stop noticing a specified script nobody copied. Both directions hold, bounded by **the newest release that has actually shipped** rather than the one a manifest declares: a release is declared while the work that ships it is still being built.

**`Until` is the same mechanism pointed the other way, and it is why a retired entry stays on the page rather than being deleted.** A repository still on 1.x holds the index regenerator and is right to; a repository at 2.0 has no generated index left to produce, because the four indexes become queries over the store and stop existing as files. Deleting the section would leave every unconverted repository with a script no page documents — indistinguishable, to a check, from a script nobody should have. The row reads as *carried from `Since`, and no longer carried at `Until`*, and the same reading applies to the regenerate-and-compare check below.

**JavaScript, run by `node`, and that is not a new dependency**: the plugin already ships a session hook and already invokes it with bare `node`. One language across everything executable AEP carries is what a second one would have to argue for.

**One more thing is documented here and it is not a script**: the regenerate-and-compare check, which runs the regenerator and fails on the difference. It is here because this is where the surface it holds is documented, and it needs no file of its own. It carries the index regenerator's `Until` — its whole subject is a *committed* generated file, and at 2.0 nothing derived is committed, so the check is not replaced by a stricter one; its subject is gone.

## What every shipped script owes

**Its fixture is a test in this repository's build, and no configuration run performs one.** A derived script needed proving on arrival because a mis-derivation is wrong-but-self-consistent and every later check agrees with it; a copy cannot be mis-derived, so the whole obligation moves to where the code is written. What each fixture asserts is unchanged and stays beside its script below — the reader is the build's author, not the configuring stage.

**Line endings are the checkout's.** Where nothing pins them — no `.gitattributes` — that is the platform's, because comparison is against what git put on disk. A fixed ending fails on every platform but the author's, and fails *as a stale output* rather than as the line-ending disagreement it is.

**UTF-8 without a byte-order mark.** A BOM is three bytes at the front of a file nobody sees in a diff, and it breaks byte comparison.

**What a script emits on standard output is ASCII.** Written output is read back as bytes; emitted output is captured through whatever console encoding the shell happens to have, and a non-ASCII character does not survive one that is not UTF-8 — it arrives as `?`, in output that still looks well-formed. This is not theoretical: the refusal lines below carried an arrow, and it was transcoded on a machine whose console codepage was not UTF-8. The fixture comparison was the only thing that noticed. The same argument as the rule above, one layer out.

Write files whole, and beware a write helper that appends its own trailing newline to the string it is handed: the output already ends in one, and a second is a byte of drift on every run.

**A copy is held to its source byte for byte, apart from one line it gains on the way in, and that is the check this page newly gets.** Copying is the one thing 2.0 still does, so it is the one place the byte-lock apparatus keeps a subject. The comparison cannot run in the repository — a stage's shell cannot resolve the plugin's root — so each copy declares the release it came from and the session hook reports a mismatch.

**The declaration is the copy's first line, and this is its only home:**

```js
// aep-release: 2.0.0
```

**Two ends of one format meet here** — the configuring stage writes this line and the session hook reads it — so the form is stated once, on this page, and both point at it. A comment rather than anything structural, and the first line rather than anywhere inside, because it has to be findable in a file whose language this page does not fix and cheap to read for a hook that runs on every session start. It precedes `'use strict';` harmlessly: a directive prologue is the first *statement*, and a comment is not one.

**A stale copy produces exactly one line, naming every script that is behind and what repairs it.** One line rather than one per script, because a repository that skipped a release is behind on all of them and reading the same sentence five times teaches nothing the first did not. The protocol file's own staleness is a second line on the same terms, so a repository behind on both learns both and a repository behind on one is never told about the other.

**Silence covers three different facts and is right for all of them**: the copies match, the repository copied no scripts, and a copy declares no release. **An undeclared release is unknown, never stale** — a copy predating the stamp and a copy somebody stripped it from look identical, and warning on both would make the first repository's every session carry a line nobody can act on.

**What this catches is a copy an upgrade left behind. What it does not catch is a copy somebody edited** — a hand-edited copy still declaring the current release passes, and the reason is that the only surface holding both sides runs once per session and is not a diffing tool. Stated here rather than left to be discovered, because the check reads as stronger than it is: a green session is evidence about *which release* a copy came from and about nothing else.

Beneath that, how much *else* holds each script differs, and the difference is not cosmetic:

| | held by |
| --- | --- |
| index regenerator | its fixture, **and** the regenerate-and-compare check below |
| position report | its fixture, and nothing else |
| knowledge store builder | its fixture, **and** the store assertions the repository's own build runs |

A report is not a tracked file, so nothing can regenerate and compare it. For that script the fixture is not a safeguard on arrival but the **only** check there will ever be, and a wrong one emits a confident wrong fact that a stage then quotes as authority.

---

## The index regenerator

**Carried from 1.0.0, retired at 2.0.0.** Copy it into a repository below 2.0 and no other; a 2.0 repository reaches the same rows through the store query instead, and nothing it produces is committed.

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

The two findings differ in one thing only: the second carries a consumption mark and the first does not. **An implementation that renders them identically has lost the distinction the evidence index exists to show**, and that is what this pair is here to catch — the other two families cannot catch it, having no such state.

Run the script against it. `.claude/contexts/map.md` must be exactly:

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

All three files end with a single newline. A mismatch is the script being wrong, not the fixture.

### How the regenerator stays right afterwards

The enforcement is **the regenerate-and-compare check specified in the next section**: it regenerates each index and compares the result against what git has recorded, so a stale index, a hand-edited one, or a script that has drifted from this page all fail the build. It is a step in the checks this repository already runs, and nothing outside this repository runs it.

Which is also why **a generated index is never hand-edited**. The prohibition holds by being checked, not by being asked of whoever opens the file.

---

## The regenerate-and-compare check

**Carried from 1.0.0, retired at 2.0.0**, with the index regenerator it enforces. What it existed to catch is a *committed* generated file diverging from what regeneration produces, and at 2.0 nothing derived is committed — so it is not weakened or replaced, it loses its subject entirely.

The enforcement the prohibition above rests on, and a step in whatever already fails this repository's build — **not a third script.** Regenerating and then failing on the difference is two lines of checks a repository already runs, so it earns no script of its own and `.claude/scripts/` goes on holding only what this page documents. A script here would put a new file in every configured repository to perform a comparison that needs no code.

Three steps:

1. **Run the index regenerator** over the repository itself.
2. **Ask git what changed**, limited to the directories that script writes into, so an unrelated build artefact cannot fail this check. The invocation is the `git` reference's, as the position report's reads are.
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

Five, in this order, and the `git` reference has the exact invocations for every one:

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

Build a repository in a temporary directory: one commit, holding a seed file and a `.gitignore` that ignores the position directory — as every configured repository has. Without that ignore no case can pass, for the reason stated above, and a fixture that omitted it would be testing a tree no configured repository resembles. Capture `<head>` as its full object name, `<head7>` as the first seven characters, and `<tree>` / `<tree7>` from the fingerprint of the clean tree. Run every case but D with the run identity **unset**; D is what exercises it being present.

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

where `<live7>` is the fingerprint taken with `a.txt` present. It must differ from `<tree7>` — a fingerprint blind to an untracked file is the defect this read exists to catch, and Case B is what proves the script is not blind to one.

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

**Case G — the marker is behind `HEAD`.** Commit one more file on the first branch; call the commit it displaced `<before>` and the new `HEAD` `<after>`, and take `<tree>` again as the tree now stands. Write the marker holding `<before>` and that tree. Expected output, exactly:

```
Position
  marker  <before7>  HEAD <after7>   1 commits ahead
  tree    <tree7>  live <tree7>   tree match
  drift   1 committed, 0 uncommitted
            <the file that commit added>
  mode    commit-only (run identity unavailable)
```

**G is the only case reaching the other commit verdict, and the only one reaching the committed half of the drift list.** A and D match on the commit, B moves the tree and nothing else, and C, E and F never get past a refusal — so without it the count of commits ahead and the committed paths are written by nothing and read by nothing.

**Case H — an unstaged modification, listed first.** Same marker as A, then edit a tracked file without staging it and add an untracked file that sorts after it. Both paths appear, each whole:

```
Position
  marker  <head7>  HEAD <head7>   commit match
  tree    <tree7>  live <live7>   tree differs
  drift   0 committed, 2 uncommitted
            <the edited file>
            <the untracked file>
  mode    commit-only (run identity unavailable)
```

**H exists because column 1 of a porcelain line is a space for exactly this status, and for no other the fixture reaches.** An untracked file gives `??` and a staged edit gives `M `, so an implementation that strips the output's leading whitespace before splitting it loses the first path's first character — in this case alone, on the first line alone. Reading the columns by position is what the read above specifies; H is what makes reading them any other way fail.

E and F are the two refusals an implementation is most likely to collapse into one, or into a crash. They are different questions with different consequences — an object that is absent against one that is present and unrelated — and a script answering both with the same line has lost the distinction the reader needs.

Every case ends with a single newline, and every case writes a receipt. After A, the receipt must hold `<head>` and `<tree>` with `"run": null` and `"mode": "commit-only"`; after D, the identifier and `"mode": "session"`.

### How the position report stays right afterwards

**By its fixture, and by nothing else.** The output is not a tracked file, so there is no regenerate-and-compare to fall back on and no second opinion of any kind. Run the fixture whenever the script or this page changes, and treat a passing report on the repository as no evidence at all — a wrong script agrees with itself.

---

## The knowledge store builder

One script minting the ids the store's records are addressed by, refusing what it cannot address, and reporting three figures it never fails on.

### What a record is

`.claude/knowledge/` is a flat directory of markdown. **The file is the unit a human writes, reviews, and diffs; the record is the unit everything else addresses** — the smallest span that is correct on its own, carried by a `##` heading. A file with no headings is one record.

Each file declares `type`, `spans`, and — for a `norm` and nothing else — `fires-when`, with `stages` beside it where the firing condition is a stage:

```markdown
---
owner: repository
type: norm
fires-when: stage
stages: [implement, commit]
spans:
  - the-marker-holds-two-facts: q7m2vk
---

## The marker holds two facts

- **The commit and the tree fingerprint are written together** — a commit
  written beside a stale tree claims a tree nobody fingerprinted.
```

All three vocabularies are **closed**, and a value outside any of them fails the build:

| Field | Values |
| --- | --- |
| `type` | `norm`, `context`, `decision`, `evidence`, `reference`, `spec` |
| `owner` | `framework`, `repository` |
| `fires-when` | `every-turn`, `path`, `stage`, `posture` |

**`owner` is refused when absent, not defaulted.** A record that is the repository's by design and one written before the field existed are otherwise indistinguishable forever — and no later run can tell them apart either, which is why absence has to fail at the moment somebody could still say which it was. This is the check the configuration audit's coverage sweep used to perform over whole files; the sweep dissolved with copying, and the declaration it was reading did not.

**`fires-when` deliberately has no judged value.** A firing condition the model decides is judged selection wearing a field's clothes, and an open vocabulary readmits it by accident — which is the mis-loading the store exists to remove.

**A `stage` norm names its stages in `stages`, a list field of its own.** The firing condition says which *kind* of condition; the list says which stages, and a norm four stages read is one record naming four rather than four records repeating one rule. It is a separate field rather than a qualifier on the value — `stage:implement,commit` — because the store is reached by filters on declared fields: a list is matched exactly, where a joined value would have to be searched inside, and a loose match is how a miss stops being a fact. The list is refused beside any other firing condition, having nothing there to qualify.

**A `posture` norm names its postures in `postures`, on the same terms, and the difference is only where the vocabulary comes from.** The router's stage table names every stage, so a stage outside it is refused; it does not name every posture, because a skill outside that table declares one too. So the posture a mode record names **is** the definition of that posture and is checked against nothing — and what a typo in one breaks appears from the other side, in the report below.

**A `path` norm names the globs it covers in `paths`, and no vocabulary checks them.** A norm scoped to a path is reached by the store query when a covered file is opened — no preprocessing runs at that moment — so the patterns have to be a declared field the query can match a path against, and a norm naming none arrives nowhere exactly as the other two would. Nothing checks the pattern itself: a glob covering no file today covers one tomorrow, and refusing it would refuse a norm written before the code it governs.

### Who writes an id

**The author writes headings and no ids; this script mints what is missing.** A hand-typed opaque token is where duplicates and copy-paste collisions come from, and the friction would land on every edit. Minting here keeps an id in the same commit as the span it names.

- **An id already present is never rewritten.** That is what makes it stable across runs, and what lets a guard keyed on one detect a norm's loss by *absence* rather than by a pattern somebody had to author correctly.
- **An id is six lowercase alphanumerics from a cryptographic source, checked against every id in the store before it is used.** Not derived from position — inserting a span would shift every binding below it. Not derived from the imperative's content — a cosmetic reformatting would read as a deletion plus an addition, which is exactly what a real loss reads as.

### What it refuses, and by what name

Each refusal names the place, because the reader's next question is always *where*:

| Refused | Named |
| --- | --- |
| a `spans` anchor no heading produces | the file and the anchor |
| a record stating more than one imperative | the file, the heading, and the count |
| a `type`, `owner`, or `fires-when` outside its closed set | the file and the value |
| `fires-when` on anything but a `norm` | the file and its type |
| a declared edge citing an id no record carries | the citing file, the field, and the id |
| a symmetric pair written at one end only | both files, the field, and the end that is missing |
| one id declared in two files | both files |
| a `norm` declaring `fires-when: every-turn` | the file and the id |
| a `norm` firing on a stage and declaring no stages | the file and the id |
| a `norm` naming a stage no router row names | the file, the id, and the stage |
| `stages` declared beside any other firing condition | the file and the condition |
| a `norm` firing on a posture and declaring no postures | the file and the id |
| `postures` declared beside any other firing condition | the file and the condition |
| a `norm` firing on a path and declaring no paths | the file and the id |
| `paths` declared beside any other firing condition | the file and the condition |
| `deviates-from` declared with no record in it | the file and the field |

**Two edge pairs are symmetric, and resolution does not imply symmetry.** A `superseded-by` naming a record that exists resolves perfectly well while that record says nothing in return, and that half-written pair is what the check exists for — the end somebody forgets is the one that was never the file being edited. `supersedes`/`superseded-by` is the first pair; **`falsifies`/`falsified-by` is the second, and it carries the one thing a frozen record cannot carry itself.** An ADR's prose freezes on commit, so a correction lives in another record, and a correction unreachable from what it corrects reaches nobody. No other edge is held to this: a blocker does not declare what it blocks, and an effort does not enumerate its tickets.

**A norm naming a stage no router row names is refused**, because it is the silent failure this design is most exposed to: the name is legal, the build is green, and the norm simply never arrives anywhere. Nothing downstream can catch it — a row that should have carried it looks exactly like a row that never had it.

**Every entry in the list is checked, not the first that fails.** A norm naming two stages the router does not carry would otherwise report one, and the second surfaces only once somebody has fixed the first — which reads as a new fault rather than the rest of an old one.

**A norm whose `fires-when` is `every-turn` belongs to the pushed tier, and the build refuses it in the store.** Such a norm has to fire on a turn the user did not start, and behind the store nothing would fire it — the norm would simply stop arriving, with nothing reporting that it had. The refusal is what keeps the tier boundary a fact rather than a convention: moving one there fails the build instead of quietly working until the turn that needed it.

**A heading rename therefore fails rather than silently unbinding**, which is the whole reason the binding is checked in both directions. **An unreferenced record is reported, never failed** — a norm nothing links to is legal, and only a human can tell an orphan from a root.

### What it reports, and never fails on

**The corpus's instruction count**, where an instruction is a top-level bullet or paragraph opening with a bold clause — the form the corpus already writes its rules in. **Reported and never thresholded**: a threshold cannot tell accumulation from regression, the cheapest response to a crossing is to raise it, and raising it is what erodes the guard.

**Each stage row's authored size and generated size, separately.** Rows come from the router's own stage table rather than from a list on this page, and a `map.md` in a row counts as generated while everything else counts as authored. A single total mixes prose that should not grow with indexes that must, so an ordinary decision reads exactly like the regression a bound exists to catch.

**Every posture a router row names that no record in this store defines.** It is the other side of the check the posture vocabulary deliberately does not make: the record's own value is the definition, so a typo there is invisible where it was typed and shows up here as the row that can no longer reach it. Reported rather than refused, and **only where this store defines a posture at all** — a store holding no mode record is not the store that defines them, and has nothing to say about what the router names.

### The one figure it does fail on

**The boot tier's size**, as a figure of its own rather than folded into the rows above, and **measured against a budget the build fails on**. The tier is paid on every turn where a row is paid once, so a total that mixed them would hide the only number that multiplies.

**It is bounded where the other two are not, and the difference is what each figure is made of.** The tier is authored prose throughout, and authored prose should not grow — so a crossing has exactly one meaning: somebody added an unconditionally loaded rule. The instruction count and a row's total mix content that must grow with content that must not, and a bound over a mixed figure cannot tell the regression it exists to catch from ordinary accumulation.

**The tier is the entrypoint plus every rule declaring no path scope**, and membership is read from frontmatter rather than from what a rule says about itself: a scope announced in prose is paid on every turn and enforced on none.

**Failing is not refusing, and the two are reported apart.** A tier over budget is not a defect in the store — every record is still addressable and the ledger is still correct — so the ledger is written and the report is printed, and only then does the build fail, naming the figure and the budget. Refusing instead would discard a good index and report a true thing under a false heading.

**The budget carries its basis in words, beside the number.** A bare figure cannot be told apart from one set too tight to begin with, and the cheapest response to a crossing is to raise it — which is the erosion the reporting-only treatment above exists to avoid. Stating the measurement it was set from, and the headroom allowed, is what makes a later crossing evidence rather than an inconvenience.

### Where the ledger goes

`.claude/position/ledger.json`, whole, rebuilt on every run.

**Under `position/` rather than beside the store, and that is forced rather than chosen.** The router is framework law and states that exactly two paths sit outside that directory, both the harness's — so a third ignore exception cannot be argued for. The ledger earns the place on the category's own test: delete every ignored file under `.claude/` and no other clone loses information, while this one loses a rebuildable shortcut and re-earns it.

**A record's entry carries every fact the query answers on, because the query reads this index and nothing else.** A fact stated in a record and absent here is a fact no query can reach, which is why the entry carries the record's `owner` and its declared edges alongside the fields the filters obviously need. **`owner` and `store` are two facts rather than one** — the store says which index answers for a record, and the owner says whether it is law — and a repository asking which framework norm governs a file needs both. The edges are carried for the closure below: an edge left in the markdown would be an edge the walk could not follow, and not following one is exactly what the closure exists to make impossible to confuse with an absent one.

**Beside it sits `.claude/position/framework-ledger.json`, and it is a copy rather than a build.** The framework store ships prebuilt inside the plugin package, and a stage's shell cannot resolve the plugin's root — so configuration copies the index in, and the query reads both. It is the same wall that makes a `deviates-from` edge reported rather than resolved, met on the other side and paid for the same way a copied script is: **a stale copy is what an upgrade leaves behind, and the release stamp is what catches it.** A repository that has not been configured has no such file, and its absence is a fact rather than a fault — one store, correctly answered.

### The builder's fixture

Build a store in a temporary directory holding one file, `a.md`, with frontmatter declaring `owner: repository` and `type: norm` and `fires-when: stage`, no `spans` key, and two headings — `## First thing` and `## Second thing` — each followed by a single bolded bullet.

**Case A — a first run** — exits zero, having written a `spans` block with two entries whose anchors are `first-thing` and `second-thing`, each bound to a distinct six-character token matching `^[a-z0-9]{6}$`. Standard output contains

```
instructions: 2
```

**Case B — a second run, nothing else changed** — exits zero and both ids are byte-identical to Case A's. **This case is the specification, not a repetition of Case A**: a builder that re-mints on every run passes Case A and destroys every citation in the corpus, and only a second run can tell the two apart.

**Case C — a renamed heading** — change `## First thing` to `## The first thing` and run again: it exits non-zero, and its output names both `a.md` and `first-thing`. The id is *not* re-minted onto the new anchor — a rename is a human decision about whether the norm survived it, and guessing costs the fidelity floor exactly what it was bought for.

**Case D — two imperatives under one heading** — add a second bolded bullet under `## Second thing` and run: it exits non-zero, naming `a.md`, the heading, and the count.

**Case E — a dangling citation** — add `supersedes: [zzz999]` to the frontmatter and run: it exits non-zero, naming `a.md`, `supersedes`, and `zzz999`.

**Case F — an empty store** — remove `a.md` and run: it exits **zero**, reports `instructions: 0`, and writes a ledger with no records. An empty store is a true state of a repository that has not migrated yet, not a misconfiguration — refusing it would make the expand half of a migration impossible to land.

### How the builder stays right afterwards

**By its fixture, and by the store assertions the repository's own build runs.** The two reach different things and neither substitutes for the other: the fixture exercises refusals that the committed store is supposed never to trigger, and the build asserts over the committed store the properties that no fixture can vouch for — that a tree somebody cloned has no unaddressable span in it.

### Precedence, computed and never declared

The builder writes a **rank** onto every record it reads, from the record's type, its store, and its firing condition. **Never from a declared field** — a record that carried its own rank could carry a wrong one, and nothing would know.

Three ranks: what the user said, then decisions, then norms. **Only what binds gets one.** A `context`, `evidence`, `reference`, or `spec` record has no rank at all, and asking for one is answered with nothing rather than with a default — a description handed a number invites a caller to weigh it against an instruction, and a default is that same error wearing a safer-looking value. Those types answer to the truth hierarchy instead, where the Codebase is right and they are healed.

**Firing breadth orders norms among themselves**, as a sub-order inside one rank rather than as ranks of its own: `posture`, then `stage`, then `path`. Broadest first, path-scoped last, which is the layout this replaces.

**The order names no condition the build refuses.** A norm firing every turn cannot be in this store, so ranking it would order a set with no members and tell a reader the shape is reachable — the boot tier is files the harness loads, and nothing here orders it.

**A cross-store contradiction is a declared deviation, never a rank.** A record names what it departs from with `deviates-from`, and that edge is the one the builder does *not* resolve locally: its target lives in the framework store. It is **reported on every run** until somebody removes it. Reported once and then silently is how a deviation becomes the rule.

**The one deviation fault this build can catch is a field declaring nothing**, and it fails. An id naming no framework record is unreachable from here; a `deviates-from` that is present and empty needs nothing from the other store to be wrong — it says a repository is departing from law and says from which law nowhere. **Removing the field is what removes the report**, and removing it is the whole edit: nothing else anywhere mentions the deviation, which is the property the edge buys over the prose section it replaced.

### Source Pointers

**A pointer names a path; an edge names an id.** The asymmetry is deliberate — a pointer targets the Codebase, and the Codebase has no ids to name.

`sources` on a file applies to every span in it. A `span-sources` entry overrides it for that span alone, and an override naming an anchor no heading produces fails the build exactly as a `spans` entry does.

**A pointer that no longer resolves is reported broken and never rewritten.** Recovery is a search somebody performs; a build that failed here would press whoever hit it toward inventing a replacement, which is the one outcome the rule exists to prevent.

### Two more fixture cases

**Case G — precedence** — a store holding one `decision`, one `norm` with `fires-when: posture` naming a posture, one `norm` with `fires-when: path` naming a glob, and one `context`. The ledger gives the decision a lower rank number than either norm, gives both norms the same rank and different breadths with `posture` lower than `path`, and gives the context **no rank** — not zero.

**The two norms are `posture` and `path` rather than `every-turn` and `path`, and that is not a detail.** The assertion's subject is that firing breadth orders norms among themselves, which any two breadths demonstrate; seeding it with a store the build must refuse would make the refusal and the suite contradict each other, and whoever added the refusal would read the failure as their own bug.

**Case H — a declared deviation and a broken pointer** — one record declaring `deviates-from: [fw0001]` and `sources` naming a path that does not exist. It exits **zero** and its output contains

```
deviations: 1
broken pointers: 1
```

naming `fw0001` and the missing path. Both are reports rather than failures, and both are the whole case: a build that failed on either would turn a declaration into a blocker and a search into a guess.

---

## The store query

One script answering filters over the store's declared fields, written to `.claude/scripts/query-knowledge-store.js`.

### Two faces, one index

**The store answers on two faces: a tool the model calls, and this command line.** The tool is the fast path; the command line is the fallback for when the server is gone, and the only face CI has. What dies is the server rather than the machine, so the fallback is a script step whose output a stage quotes rather than a second retrieval path somebody has to keep correct.

**Both faces read one derived index and nothing else.** The same question put to either returns the same answer, and a disagreement is a defect in whichever is not reading the index — never a preference for one of them. Two indexes would be two stores wearing one name, and the one exercised less would rot first.

**The command-line face hands back a path rather than a row once the answer is large.** A result above roughly 30,000 characters is withheld by the harness, which persists it and returns a preview and a path. That is loud rather than silent — the wrapper names the size — but it is a second step, and a caller expecting a row would otherwise read a preview as the whole answer.

### Filters, and nothing else

**There is no free-text parameter, and adding one would undo the property the surface exists for.** A filter over declared fields that matches nothing has made *a true statement about the store*; a search that finds nothing has only failed to find something. A caller can act on the first and can only guess at the second.

- **A filter naming a field no record declares is refused, naming the field.** Interpreting it — matching loosely, or falling back to scanning text — is how a miss stops being a fact.
- **An argument that does not parse as `field=value` is refused too.** A bare phrase is what a caller reaching for a search would type, so refusing it is what makes "no free text" a property rather than a sentence.
- **The filterable fields come from the records themselves**, never from a list in the script: a field the format gains becomes filterable with no edit here, and a field nothing declares cannot be quietly accepted.
- **A filter given no value enumerates that field's distinct values, with a count each.** It is the same grammar rather than a second surface — `type=` asks what types the store holds — so the vocabulary is discoverable without a second thing that could drift from the filters. The count is what separates a value one record carries by accident from one the store uses.
- **A query naming no filter at all is refused**, and the refusal lists the declared fields. Returning the whole store would be an answer nobody asked for, and a caller who did not know where to start learns the vocabulary from the refusal.

**One field is matched as a pattern, and it is the only one.** A path-scoped norm declares the globs it covers and a caller holds a path, so equality cannot join them: the one filter that would match is the pattern the caller was trying to discover. So `paths=src/db/schema.ts` returns every norm whose declared globs cover that path. **This is not free text arriving by another door** — a path is a fact about the filesystem and coverage by a glob is exact set membership, with no ranking, no threshold, and no record that nearly matched. The pattern comes from the record and the path comes from the caller, and neither side is phrasing.

**An empty answer exits zero and says `empty`; a refusal exits non-zero.** If the two shared an exit code they would be one answer from the caller's side, which is the collapse this whole design is against.

**The answer names how many records each store contributed.** A repository that never copied the framework index and one whose citation genuinely matches nothing otherwise return the same empty result — and the first is a configuration fault while the second is the true statement the surface exists to make.

### The closure, and where depth lives

**Every match comes back with the closure its declared edges reach, computed in one call.** Returning edge ids for the caller to fetch makes each hop a model decision, and makes *not following* an edge indistinguishable from there being nothing to follow.

**Depth is a property of the edge type, declared once in the store, and never a query parameter.** A global depth is too large for one edge and too small for another, and the short case stops one hop short leaving no signal that it did. Each number is a fact about what that edge *means* rather than a figure somebody tuned — so it is read from a record in the store, not carried in the script, which would be a second home free to disagree with the one a reader would edit.

**One record per edge type, declaring `edge` and `closes`.** The store's own machinery carries the depths, so `edge=supersedes` answers what that edge closes at and `edge=` enumerates every edge the store knows — the figures are reachable through the surface they govern rather than by opening a file somebody has to be told about. `closes` takes `fully` or a number of hops, and **two words meaning one walk are not offered**: an edge closing *to the effort root* and one closing *fully* are the same traversal, and a vocabulary carrying both would hold a distinction no run could ever tell apart.

**Distance is counted per edge type rather than over the walk as a whole.** That is what makes each declared number a statement about its own edge: raising one reaches further along that edge and exactly as far as before along every other, and a path mixing two edge types spends each budget separately.

**An edge no record declares a depth for is refused, and never walked at some default.** A default would walk a distance the store never declared and hand the result back as though it had — which is the silent under-return the whole surface is built against, arriving from the one direction a filter cannot cover.

### Conflicts are returned, never resolved

**Two binding records that could both apply come back together, with their ranks and a label** naming the conflict as a declared deviation across stores or an undeclared defect within one. Applying the rank here and handing back one record would suppress the obligation that a decision-versus-norm conflict is *productive* — the norm is amended in the same change rather than quietly losing to a comparison nobody saw.

**Only records of differing rank are paired**, because two norms at one rank are ordered by firing breadth rather than in conflict, and pairing them would report the corpus's ordinary shape as a defect. **Matching one filter is the evidence that two records could both apply** — the filter is the question, and the store has no other way to know two records are about the same thing. So a filter broad enough to select most of the store returns a conflict list to match, and that is a property of the question rather than a finding about the corpus.

### The query's fixture

Against a store holding one `decision`, one `norm`, and one `context`:

**Case A — a hit** — `type=decision` exits zero, `empty` is false, and one record comes back.

**Case B — a miss** — `type=spec` exits **zero**, `empty` is true, and `matches` is empty. **This is the case the surface exists for**; a non-zero exit here is the defect.

**Case C — an undeclared field** — `banana=x` exits non-zero and names `banana`.

**Case D — free text** — `how do I mint an id` exits non-zero and says the surface takes none.

**Case E — the closure** — with `supersedes` declared at depth 1, querying a record that supersedes another returns that other in the closure, attributed to the `supersedes` edge.

**Case F — depth belongs to the edge** — raise `supersedes` to 2 and the closure reaches one hop further along that edge and **exactly as far as before along every other**. Give the two edge types disjoint targets when checking this: sharing one turns the test into a question about which edge was walked first.

**Case G — a conflict** — a decision and a norm both matching return a conflict carrying both records, both ranks, and a label.

**Case H — the vocabulary** — `type=` exits zero and enumerates the store's distinct types with a count each. A value the store does not hold is absent from the list rather than present at zero: the enumeration says what is there.

**Case I — a path** — a norm declaring `paths: [src/db/**]` is returned by `paths=src/db/schema.ts` and not by `paths=src/api/handler.ts`. Both halves, because a matcher that returned everything would pass the first alone.

**Case J — the other store** — with a framework index copied in beside the repository's, a citation by an id only that store carries comes back, and the answer says which store answered. Without it, the same citation is empty — which is why the store counts are in the answer at all.

**Case K — an edge with no depth** — a record declaring an edge no record declares a `closes` for exits non-zero and names the edge. Walking it at some default would return a subgraph the store never authorised, and stopping quietly would be the under-return this surface exists to prevent.

---

## The row assembler

One script assembling a stage's row and emitting it for inlining, written to `.claude/scripts/assemble-row.js`. It is the only script the *harness* runs rather than a stage: the row has to be in place before the stage's own content reaches the model.

### What a row is

**Every norm whose `fires-when` matches this stage, and nothing else.** Not a selection — **no judgement enters anywhere**, because judged selection is the mis-loading this whole design removes, and a filter that a model may override is judged selection with extra steps. A norm that matches arrives; one that does not, does not; and there is no third outcome for anybody to tune.

**Two firing conditions reach a stage's row, and they are not the same fact.** A `stage` norm names this stage in `stages`. A `posture` norm names the posture this stage runs under, because a mode is delivered when a stage declaring it starts — so a row names a posture, and the mode arrives with the row or nowhere at all. Which posture a stage runs under is read from the router's own stage table, the one statement of what a stage reads that the delivery path itself depends on. A `path` norm is the query's, and an `every-turn` norm cannot be in this store.

**A stage's row size therefore counts both**, and the builder's figure above is computed the same way. A figure counting only the stage norms would report a row smaller than the one delivered, which is the one direction a size figure must never be wrong in.

**The row names the stage it was assembled for**, in its opening line. Rows are otherwise indistinguishable from one another, so a row delivered to the wrong stage would read as correct — and the failure it produces appears somewhere else entirely, as a stage quietly missing norms it should have had.

**The framework store's records arrive as text rather than as index entries, and this is the one place that is possible.** The harness exports the plugin's root to skill content, and skill content is what invokes this script — so delivery can read the framework store where a stage's own shell cannot, which is the same wall the query meets and pays for with a copied index. Given no framework store, the row is the repository's records alone and **the opening line says so**: a row that was short because nothing was passed to it must not read like a row that was short because nothing matched.

**The row arrives in computed precedence order** — the order the builder computes from type, store, and firing breadth, never the order the store happened to yield. **Reordering the store does not reorder the row.** A row whose order came from the filesystem would put the binding records wherever a rename left them.

### Several commands, never one

**The row is emitted as several commands, each below the measured substitution cap.** A single substitution over roughly 30,000 characters is withheld: the harness persists it and substitutes a preview and a path instead — which is exactly the round trip inlining exists to remove, arriving disguised as success.

**The cap is per substitution rather than per assembled body**, which is what makes this work at all: several commands each under it carry a row far larger than any one of them could. Four substitutions of about 20,000 characters have been measured composing and delivering whole.

**The ceiling is documented, and no variable raises it.** A valid result inlines up to roughly 30,000 characters; `BASH_MAX_OUTPUT_LENGTH` enlarges the window the result is read back through and explicitly does not move that boundary, so a bigger substitution cannot be bought by configuration. **The assembler stays at 20,000 regardless**, and the gap is deliberate: the two failures are not comparable. Overshooting costs a row silently replaced by a preview that reads like a row; undershooting costs one more boundary, at roughly 1.6 to 1.75 seconds. The documented ceiling is recorded as a bound, not spent.

**Chunk boundaries cost seconds and payload bytes cost almost nothing** — roughly 1.6 to 1.75 seconds per boundary against about 23 milliseconds inside a command at either size. So the assembler emits chunks **as large as the proven floor allows and as few as possible**; splitting finer is not free caution, it is the only part of this that is slow.

**A chunk index past the end of the row is emitted as nothing, and exits zero.** A skill carries a fixed number of substitution slots and a row does not, so the slots beyond a row's end are the ordinary case rather than a fault — and a refusal there would take the stage down under the failure rule below for a row that was simply short. **What that costs is a boundary per unused slot**, which is the one figure this design pays without a measurement behind it: how many slots a skill should carry is a question about the largest row the corpus will ever hold, and it is not answered here.

**A record larger than one substitution stops the assembly rather than being split or truncated.** Splitting cuts a norm in half and truncating produces a shorter row, and a shorter row reads as a shorter row — which is the silent failure the whole chunking scheme exists to avoid. The refusal names the record and its size.

### The failure mode is chosen, not discovered

An assembler command can fail, and **neither branch is safe**:

| | what the stage receives |
| --- | --- |
| unguarded | nothing at all — a non-zero exit aborts the whole skill, its own instructions included |
| guarded | the row, with the shell's error text inlined as prose and nothing reporting it |

**So the choice is made here, in the open, rather than falling out of how somebody wrote the script.** Guarded is the wrong default: a stage running on a row containing an error message is a stage that will act, confidently, on norms it does not have. **Fail unguarded, and let the stage go down loudly** — a stage that did not start is a fault somebody fixes, where a stage that started wrong is one nobody sees.

**A repository that chooses otherwise records it as a deviation**, because this is a decision with a real cost either way and a silent reversal of it is indistinguishable from never having considered it.

### The third outcome, which the choice above cannot reach

**With `disableSkillShellExecution: true` set, the harness never runs the command.** It replaces it with the literal text `[shell command execution disabled by policy]` and **renders the skill anyway**. So the stage starts — alive, holding its own instructions, with that one sentence where its entire row should be.

**That is the guarded outcome, arriving by policy rather than by choice.** It bypasses the choice above completely: failing unguarded protects nothing when no command runs and no exit code is ever produced to fail on. The setting is most often applied in managed settings, where the repository cannot override it, and it reaches every skill from a user, project, plugin, or additional-directory source. **Nothing the assembler does can prevent this**, which is why it is stated here rather than solved there.

**What defends against it is the row's opening line.** A row begins by naming the stage it was assembled for, so a delivered row that does not begin with that header is not a row. The check belongs to whatever inlines the assembler — not to the assembler, which in this case never ran.

Two other sessions produce literal text in the same position and are worth recognising: a skill **synced from a claude.ai account** has its `!` command lines delivered verbatim rather than executed, and a **Cowork session** substitutes the same policy placeholder for every one of them.

### The assembler's fixture

**Case A — a small row** — one matching norm, one command, delivered inline; standard output contains the norm's text and no `persisted-output` wrapper, no preview, and no path.

**Case B — a row over the cap** — enough matching norms to exceed one substitution. Exits zero having emitted **more than one command**, every chunk under the cap, and the concatenation is the whole row with nothing withheld.

**Case C — the cap itself** — the largest single substitution the harness accepts is **re-run against the harness rather than recorded as a constant**. A harness whose cap moved down would otherwise silently truncate a row, and the truncation reads as a shorter row rather than as a fault. Failing here is the point: a moved cap is a fact about the harness that this page has to learn. **This one case cannot run in the build**, which has no harness to ask — it is a measurement, and the constant in the script carries the bracket it was measured within so a later run can be compared against something.

**Case D — an assembly that cannot complete** — a record whose text the index promises and the store does not hold. The assembler exits non-zero and emits **no row at all**, rather than the row minus that record. This is the half of the failure mode the build can reach: what the *harness* then does with a non-zero exit is the harness's, and is stated above rather than asserted here.

**Case F — a record over the cap** — one record longer than a single substitution exits non-zero, naming the record and its size. Neither splitting nor truncating is available, so this is the case where the row genuinely cannot be delivered and says so.

**Case E — order** — reorder the store's files on disk, re-assemble, and the row is byte-identical. The order is computed, so the filesystem cannot vote.
