---
owner: repository
---

# The record format

<!--
  Installed by /configure at `.claude/knowledge/records.md`, the format every
  other record in this store is written to and the build reads. It is
  repository-owned like the rest of the store: nothing is copied into a
  repository under 2.0 that a repository may not then heal.

  Every `##` heading below is one record's address, and the build mints the id
  it is bound by into `spans`. An author writes the headings and no ids.
-->

{The installed record's frontmatter:}

```yaml
---
owner: repository
type: norm
subject: records
fires-when: stage
stages: [configure, design, implement, commit]
---
```

The knowledge store is a flat directory of markdown files, and a **record** is the smallest span inside one that is correct on its own. Files stay the unit a human writes, reviews, and diffs; records are the unit everything else addresses.

## Where the store is

**`.claude/knowledge/`, flat — one directory, one rule, no placement judgement.** Grouping that a filesystem carries today, a Project Context's directory or an effort's, becomes a declared field like every other, and nothing navigates the store by hand once the build serves it.

## Nothing derived is committed

**Nothing derived is committed.** The markdown is committed and diffed; the ledger the build produces is `.claude/position/ledger.json`, rebuildable and never in a diff. It sits under `position/` because the router is framework law and names exactly two paths outside that directory, both the harness's — so the ledger enters through the category's own test rather than as a third exception: delete every ignored file under `.claude/` and no other clone loses information.

## What a file declares

```markdown
---
owner: repository
type: norm
fires-when: stage
stages: [implement, commit]
spans:
  - the-marker-holds-two-facts: q7m2vk
  - a-broken-pointer-is-searched-for: 4h1zbd
---

## The marker holds two facts

- **The commit and the tree fingerprint are written together** — a commit
  written beside a stale tree claims a tree nobody fingerprinted.

## A broken pointer is searched for

- **A pointer that no longer resolves is searched for, never invented** — an
  invented path is a wrong answer wearing a right answer's shape.
```

## Every record declares what it is about

- **`subject` is what the record is about, and it is declared rather than recovered from the filename.** The id addresses a record precisely so a file can keep a readable name and a rename can cost nothing — which means the name is not a handle, and without this field nothing could name one record at all. A record declaring no subject fails the build, and so does one whose subject is not lowercase words joined by hyphens: the subject is what a caller types into a filter and what the router's column names, and those two have to be the same token.

## Two filename conventions, and which store each belongs to

- **A repository's record keeps whatever readable name it would have had; a framework stage norm's name encodes the stages it serves.** Both are in one flat directory and a reader sees both, so the difference is stated rather than left to be inferred: the framework's names carry stages because the split that produced those files needs each name checkable against its `stages` field, and a repository writes no such split. Neither convention is load-bearing for *finding* a record — `subject` and the id are — which is what makes two of them harmless rather than a trap.

## The type vocabulary is closed

- **`type` is one of `norm`, `context`, `decision`, `evidence`, `reference`, `spec` in this store** — `ticket` and `map` belong to the tracker store and never appear here. The set is closed and a value outside it fails the build.

## A firing condition is a norm's and nobody else's

- **`fires-when` is declared by a `norm` and by nothing else**, drawn from the closed vocabulary `every-turn`, `path`, `stage`, `posture`. **There is deliberately no judged value** — a firing condition the model decides is judged selection wearing a field's clothes, which is the mis-loading this store exists to remove.

## A stage norm names its stages

- **A `stage` norm names its stages in `stages`, a list, and a stage no router row names fails the build.** The vocabulary being closed bounds the *kind* of firing condition and says nothing about which stages, so a norm naming a stage that does not exist is legal-looking, builds green, and then never arrives anywhere — and a row that should have carried it is indistinguishable from a row that never had it. A `stage` norm declaring no stages fails the same way, and an empty list is the same fault as no field.

## The stages are a list because the query never matches inside a value

- **`stages` is a list rather than a qualifier on `fires-when`, because the query filters on declared fields and never inside a value.** A norm several stages read is one record naming them all; asking which norms fire at a stage is then an exact match, where a joined value would make it a substring search — the loose match that turns a miss into a guess. Declaring `stages` beside any other firing condition fails the build, the list having nothing to qualify.

## A posture norm names its postures, and the store defines them

- **A `posture` norm names its postures in `postures`, on the same terms, and the store defines the vocabulary rather than the router.** The router's stage table names every stage, so a stage outside it is refused; it does not name every posture, because a skill outside that table declares one too. So the posture a mode record names **is** the definition, unchecked against anything — and what a typo in one breaks surfaces from the other side: a posture a router row names that no record defines is reported, and only where this store holds a mode record at all. A `posture` norm naming no posture fails the build, and so does `postures` beside any other firing condition.

## A path norm names the globs it covers

- **A `path` norm names the globs it covers in `paths`, and the query matches a path against them.** Such a norm is reached at the moment a covered file is opened, where no preprocessing runs, so the patterns have to be a declared field rather than something read out of a file somebody happened to have open. Nothing checks a pattern — a glob covering no file today covers one tomorrow, and refusing it would refuse a norm written before the code it governs — but a `path` norm naming no path fails the build, and so does `paths` beside any other firing condition.

## The spans field binds an anchor to an id

- **`spans` maps a heading's anchor to that heading's id**, one entry per `##` heading in the file. The anchor is the heading text lowercased with runs of non-alphanumerics collapsed to a single hyphen.

## A frozen account takes one id for the whole file

- **A `decision`, `spec`, or `evidence` record takes one id for the whole file**, and `spans` holds that single entry, keyed on the file's title heading rather than on a `##`. The three are frozen accounts of what was decided, agreed, or observed, so their `##` headings are one record's sections rather than separate statements — minting an id per heading would advertise a citable span for `## Considered Options`, and a citation of it says nothing. **Which records decompose is computed from the type and never declared**, on the same reasoning as precedence below: a flag a file declares about itself can be wrong about itself.

## What an id is

**An id is a short opaque token, written once by the build and never changed.** Six lowercase alphanumerics, carrying no meaning: it names a norm rather than a filename, so files keep readable names and a rename costs nothing.

## The build mints what an author leaves out

- **An author writes headings and no ids; the build mints what is missing.** That is what keeps an id in the same commit as the span it names, and it designs out the duplicate-id and copy-paste collisions a hand-typed token invites.

## No stage mints an id mid-session

- **No stage mints an id mid-session.** An id that appeared during a session is one nobody can cite from the commit it was supposed to land in.

## An unlabelled heading fails the build

- **A heading carrying no id after the build has run fails the build**, and the failure names the file and the heading. Optional labelling would make the fidelity floor opt-in, and a span nobody labelled is one the id-keyed guard cannot detect the loss of.

## A span naming no heading fails the build

- **A `spans` entry naming an anchor no heading produces fails the build.** A heading rename therefore fails rather than silently unbinding, which is the whole reason the binding is asserted in both directions.

## One instruction per record

**A record states one thing.** Two imperatives under one heading cannot be cited apart, so the finer of the two is unaddressable — and the corpus is what shrinks under this rule rather than the row that carries it.

## What counts as a norm-shaped imperative

- **A norm-shaped imperative is a top-level bullet or paragraph opening with a bold clause** — the form this corpus already writes its rules in. A record carrying more than one fails the build, named.

## The instruction count is reported and never thresholded

- **The corpus's instruction count is reported and never thresholded.** A threshold is the conflated bound that fails today: it cannot tell accumulation from regression, and the cheapest response to a crossing is to ratchet it, which erodes the guard. Reporting is what lets the two be told apart.

## Authored size and generated size are separate figures

**Authored size and generated size are separate figures.** A single total conflates prose that should not grow with indexes that must, so adding a decision reads exactly like the regression a bound exists to catch.

## Adding a decision moves only the generated figure

- **Adding a decision moves the generated figure and leaves the authored one still.** That is the property the split is for, and the one worth checking when either number moves.

## Every declared edge resolves

**Every declared edge is resolved by the build, and one that resolves to nothing fails it.** `supersedes`, `superseded-by`, `part-of`, `blocked-by`, `falsifies`, and `falsified-by` all name a record; a citation naming an id that does not exist is named with the id and the citing file. `sources` is not among them — it names a path, for the reason under Source Pointers below — and `deviates-from` names a record in the framework store, which this build cannot see, so it is reported on every run rather than resolved.

## Supersession is checked for symmetry

- **Supersession is additionally checked for symmetry, which resolution does not imply.** A `superseded-by` naming a record that exists resolves perfectly well while that record says nothing in return, and that half-written pair is what the rule exists for. Both ends are named, along with the end that is missing.

## Falsification is checked for symmetry too

- **Falsification is the second pair held to symmetry, and for the same reason as the first.** A frozen record cannot carry its own correction, so the correction lives in another record — and one unreachable from what it corrects reaches nobody, because the reader it exists for is the one who opened the record rather than the index. The forward edge alone is the tempting half: it sits in the file being written. No other edge is held to this — a blocker does not declare what it blocks, and an effort does not enumerate its tickets.

## An unreferenced record is reported

- **An unreferenced record is reported, never failed** — a norm nothing links to is legal, and only a human can tell an orphan from a root.

## Precedence is computed

**Precedence is computed from a record's type, its store, and its firing condition, and never declared** — so no record can carry a rank that is wrong. Six ranks collapse to three: what the user said, then decisions, then norms.

## Only what binds carries a rank

- **Only what binds carries a rank.** A `context`, `evidence`, `reference`, or `spec` record has none, and asking for one is answered with nothing rather than a default — a description given a number invites a caller to weigh it against an instruction. They answer to the truth hierarchy instead, where the Codebase is right and they are healed.

## Firing breadth orders norms among themselves

- **Firing breadth orders norms among themselves** — `posture`, then `stage`, then `path` — as the sub-order inside one rank rather than as ranks of their own. It names no condition the build refuses, so a norm firing every turn appears nowhere in it: that norm cannot be in this store, and ranking it would order a set with no members.

## A decision outranks a norm, productively

- **A decision outranks a norm, and that conflict is productive**: the norm is amended in the same change. A conflict comes back with both records and their ranks, because applying the rank and returning one would suppress the obligation.

## A cross-store contradiction is a declared deviation

- **A cross-store contradiction is a declared deviation, never a rank.** A record declares `deviates-from` naming the framework record it departs from, and the build reports it on every run until it is removed — ranking it would resolve it silently in someone's favour. A `deviates-from` declared with nothing in it fails the build: an edge naming nothing is a departure nobody can trace.

## A pointer names a path and an edge names an id

**A pointer names a path and an edge names an id, and the asymmetry is deliberate** — a pointer targets the Codebase, which has no ids to name.

## A file's pointers apply to every span, and a span may override

- **`sources` declared on a file applies to every span in it; a `span-sources` entry overrides it for that span alone.** An override naming an anchor no heading produces fails the build, exactly as a `spans` entry does.

## A broken pointer is reported and never rewritten

- **A pointer that no longer resolves is reported broken and never rewritten.** Recovery is a search somebody performs; a build that failed here would press whoever hit it toward the invented replacement the rule exists to stop.
