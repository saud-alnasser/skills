---
owner: repository
status: accepted
load-when: how the store query serves a path-scoped norm, a citation into the framework store, or an edge's depth is in question
sources: [.claude/tickets/conversion/issues/09-the-store-query-answers-filters-and-nothing-else.md, scripts/query-knowledge-store.js]
supersedes: []
superseded-by: []
---

# The query matches a path against a pattern, and reads the other store from a copy

`conversion/09` declared an increment asking whether a filter-only surface answers
the three cases the row excludes (ADR 0089). Built to its first filter, two of the
three did not, each for its own reason, and the three choices below were taken
with the human present.

**A path-scoped norm is reached by matching a caller's path against the globs the
record declares, in a `paths` field.** The record holds a pattern and the caller
holds a path, so equality cannot join them: the one filter that would match is the
pattern the caller was trying to discover. **This does not readmit search.** ADR
0089's guarantee is that a miss is a true statement about the store rather than a
failed lookup, and what threatens it is ranking, thresholds, and results that
nearly matched — none of which a glob has. Membership in a pattern is exact, the
pattern comes from the record, and the path comes from the filesystem; neither
side is phrasing. It is the only field matched this way, and the build refuses a
`path` norm that names no pattern, on the same ground `stages` and `postures` are
refused: a norm that arrives nowhere is indistinguishable from a row that never
had it.

**A citation into the framework store is served from a copy of that store's index,
written into `.claude/position/framework-ledger.json` at configuration.** The
command-line face reads one derived index, the framework index ships prebuilt
inside the plugin package, and the harness never exposes the plugin's root to a
stage's shell — the same wall ADR 0095 met from the other side when a deviation
became reported rather than resolved. Without the copy the surface returns `empty`
for an id the corpus does hold, which is a false statement wearing the shape of
the true one this design was bought for. The copy is stale exactly as a copied
script is stale (ADR 0097), and the answer states what each store contributed so a
repository that never copied the index is distinguishable from a citation that
genuinely matches nothing.

**Each edge type's depth is declared by its own record, carrying `edge` and
`closes`.** ADR 0092 put depth on the edge type and said it is declared once; this
says where. One record per edge makes the figures reachable through the surface
they govern — `edge=supersedes` answers what that edge closes at — rather than
through a file somebody has to be told about. `closes` takes `fully` or a number
of hops and nothing else: an edge closing *to the effort root* and one closing
*fully* are the same traversal, and a vocabulary carrying both would hold a
distinction no run could ever tell apart. An edge no record declares a depth for is
refused rather than walked at a default, because a default walks a distance the
store never authorised and returns it as though it had.

## Considered Options

- **The harness matches the path and the query stays purely equality** — rejected:
  the matching would live outside the store, free to disagree with a second
  implementation, and the command-line face has no harness to do it. That face is
  the one CI has.
- **The caller names the declared pattern exactly** — rejected: honest to the
  design and useless, since it requires knowing the pattern the query was asked to
  find.
- **The command-line face answers one store and says so** — rejected: it would
  leave the fallback face unable to answer one of the three cases the query exists
  for, and the fallback is what remains when the tool face is gone.
- **The caller passes the plugin's index path** — rejected: a stage's shell is
  precisely what does not know that path, so the flag would never be passed and
  the case would be unserved by a surface that looked like it served it.
- **One record holding every depth**, or a table in a record's body — rejected:
  the first puts the figures behind a block a reader opens rather than a fact the
  query answers, and the second grows a markdown-table parser for one caller, so a
  formatting edit becomes a behaviour change.

## Consequences

**A conflict is returned for every pair of differing-rank binders among the
matches**, because matching one filter is the only evidence the store has that two
records are about the same thing. A filter broad enough to select most of the
store therefore returns a conflict list to match. That is a property of the
question rather than a finding about the corpus, and it is stated on the surface
rather than narrowed here — narrowing it would need a notion of *aboutness* the
store does not have.
