# Tickets

Every `/design` run leaves at least one ticket, numbered from `01` in dependency order — blockers first.

**Where they go is `.claude/policies/tracker.md`'s**, and it is the only place that records it: on a local-markdown tracker they are files under `.claude/tickets/`; on GitHub they are issues in the repository. The format below is the same either way. Read the config rather than assuming the form.

One ticket per file, or one per issue. Never a single combined file: tickets are claimed one at a time, and a combined file cannot be claimed.

## A ticket tracks work — nothing else

Engineering knowledge lives in the Codebase, in Context, and in Decisions. **None of it lives in a ticket body.** A tracker that accumulates it becomes a fourth knowledge layer that nothing verifies and nothing prunes, and it is the layer people will read first because it is the one with the search box.

So: **no implementation diary.** Not what you tried, not what went wrong on the way, not a running log of the session. Detailed engineering belongs in a spec under `.claude/designs/`, which the ticket **references** — never pastes.

## Format

```markdown
# <NN> — type(scope): summary

Status: open
Blocked by: —

## Problem

What is wrong or missing now, from the caller's or user's perspective.

## Outcome

The end-to-end behaviour this ticket makes work. Not a layer-by-layer
implementation list — the ticket says what "done" looks like, and
`/implement` decides how.

## Acceptance

- A checkable statement about observable behaviour.
- Another one.
```

The title is a Conventional Commit subject, so the ticket's commit writes itself. The id and the summary are also what `/implement` builds the branch name from, so write a summary that reads as one.

`Status:` and the edge lines are the **local-markdown form**. On GitHub the lifecycle rides the issue's native state — the mapping is under Lifecycle, below — and the edges live in the issue body; `.claude/policies/tracker.md` says which applies, and `.claude/tools/github.md` has the invocations.

### Lifecycle

```
open       created by /design, nothing else set
blocked    handed back to /design, with the reason under `## Blocked`
resolved   the work is delivered. Who sets it depends on the tracker —
           /implement on a local one, the merge on a shared one
obsolete   no longer needed. Requires a one-line reason. Never deleted
```

**On GitHub the four states ride the issue's native state — zero new labels.** `open` is an open issue. `blocked` stays open, its reason under a `## Blocked` heading in the body, beside the edges that already live there — closing it would read as delivered, and a label would be a second home for what the body already says. `resolved` is the issue closed as completed, by the merge, as below. `obsolete` is the issue closed as not planned, with a comment carrying the one-line reason; the comment is mandatory, because closed-as-not-planned alone is a verdict with the reasoning withheld. `.claude/tools/github.md` has the invocation. The mapping is GitHub's; no other forge's is in evidence.

**On a shared tracker the merge resolves the ticket, not AEP.** AEP commits and never pushes, opens a pull request, or merges, so marking a shared issue resolved would assert an outcome it does not control — and a closed issue whose pull request is later rejected is a lie the tracker now tells everyone. Which text carries the closing keyword, and which carries a reference that closes nothing, depends on how the work reaches the default branch — `/commit` decides it and `.claude/tools/github.md` has the forms. Between commit and merge nothing new is written anywhere: the branch still exists, so the Claim still holds and the ticket stays off the frontier on its own.

**This is not the triage vocabulary.** Triage roles — `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix` — describe *incoming* issues someone else filed. A build ticket `/design` created is agent-ready by construction and is never triaged, so it never carries one of those. Mixing the two sets means a ticket's status stops answering "can this be worked" and starts answering two different questions at once.

**There is no `claimed` state, and a tracker never records one.** Which instance is building a ticket right now is agent-level bookkeeping on a surface reserved for human-level facts, and a status written into a file cannot stop two instances writing it at the same moment. The Claim is the ticket's branch; `/implement` owns it and states the naming.

## Assignment

**Assignment — which human owns delivering a ticket — is a tracker fact, and it is theirs.** It is set by people, in the tracker's own way: an assignee on GitHub, a name in the ticket on a local tracker. AEP reads it and never writes it unasked.

It is not the Claim and does not overlap it. Assignment separates humans, so the Claim never has to arbitrate between two of them — only between one person's own instances, which is the small problem a branch is enough to solve.

## One ticket, one observable outcome

The checkable rule against a tracker filling with hundreds of AI-generated micro-tickets nobody reads: **a ticket must have an outcome someone can observe when it closes.** If closing it produces nothing visible, it is a step inside another ticket, not a ticket.

**Deepen, don't widen.** A small set of parent tickets, each with sub-tickets where the work actually divides — never a flat spray of siblings. Structure is carried by relationships, not by ticket count.

**One design run, one root.** Every ticket the run produces hangs beneath a single top-level ticket; a run that yields exactly one ticket makes that one the root rather than inventing a parent for it. The top level grows by one per design, whatever the count underneath — which is what makes booming visible without anyone counting. `/design` has the procedure for creating them in that order.

Never create a ticket to rename a variable, move a file, or update a comment. Those happen inside a ticket that has an outcome.

## Acceptance criteria state observable outcomes

A criterion is checkable by someone who did not write the code. "Users can retry a failed payment without re-entering the card" is checkable; "the retry handler is refactored" is not — it names an implementation and can be satisfied by any change at all.

Write what becomes true, not what gets edited.

## Declared increments

Some decisions are answerable only once partial code exists — whether a surface reads as raised needs real rows; how a table behaves in another locale needs a populated table. A build ticket MAY carry those decisions as **declared increments**, written at design time only — never added during the build:

```markdown
## Declared increments

- after <step>: <the question> — type: <grilling|research|prototype|task>
```

The step names where in the build the question becomes answerable; the question is stated as sharply as a decision ticket's; the type is the map vocabulary's (`.claude/policies/maps.md`). What `/implement` does on reaching one — which types resolve inline, which stop for the human, and the guardrail on what it may never do — is that skill's to state. An increment's resolution is recorded where any design decision lands: an ADR when it clears the bar in `.claude/policies/decisions.md`, the design document otherwise.

## Above Express — slicing

Below Express there is one ticket and nothing to slice. Above it, the rules that matter:

**Vertical slices, not horizontal ones.** Each ticket cuts a narrow but *complete* path through every layer it touches — schema, logic, interface, tests. A ticket that delivers "the database layer" is a horizontal slice: it cannot be demonstrated, cannot be verified alone, and defers every integration risk to the end.

Each slice is **demoable or verifiable on its own**, and sized to fit in a single fresh context window.

**Prefactoring goes first.** Make the change easy, then make the easy change — as its own ticket, blocking the ones that depend on it.

### Edges

**Every ticket after the first declares at least one of these.** A ticket with neither is unreachable — nothing explains where it came from or what has to happen before it.

```
Blocked by: 02, 05        # this cannot start until those are delivered
Part of: <spec name>      # the spec this ticket implements
```

`Blocked by: —` is a positive statement that this one can start immediately, and it is not the same as omitting the line. Before writing the edges, read the tickets that already exist — an edge invented without checking is how a cycle or a dangling number gets in.

`/implement` picks from the **frontier**, and defines it — including what "delivered" has to mean before a blocked ticket becomes buildable, which is not the same answer on every repository. Cut the edges by what actually gates what, and leave that reading to the skill that acts on it.

Only real gates. A ticket listed as a blocker because it is *tidier* to do first serializes work that could have run in parallel.

An edge means the same thing on either tracker; only the syntax moves. `.claude/policies/tracker.md` says which applies.

| Tracker | `part of` | `blocks` | `related` |
| --- | --- | --- | --- |
| local markdown | a `Part of:` line | a `Blocked by: NN, NN` line | a `Related: NN` line |
| GitHub | the sub-issues API, else a task list in the parent | `Blocked by: #NN` in the body | `#NN` mentioned in the body |

The GitHub column is what `.claude/tools/github.md` documents and nothing more: `gh` has **no blocking subcommand**, so the edge lives in the issue body — legible to humans, and exactly what the local tracker does anyway. Read that file before issuing anything; a native-sounding invocation that does not exist is the guessed CLI the reference exists to prevent.

`related` carries no ordering and blocks nothing. It is for an issue worth reading first, and it is the edge to reach for when a blocker would be a lie.

### Scanning for booming

The edges make the anti-booming rule checkable, which is the point of requiring them: **scan the set, and any ticket that is neither the root nor carries an edge is a stray.** Either it belongs under a parent nobody linked, or it should not exist. Do this when the tickets are cut, while the answer is still cheap.

### Wide refactors are the exception

A **wide refactor** — rename a column, retype a shared symbol — has a blast radius across the whole codebase, so a single edit breaks thousands of call sites and no vertical slice can land green. Don't force it into a tracer bullet. Sequence it **expand–contract**:

1. **Expand** — add the new form beside the old. Nothing breaks.
2. **Migrate** — move call sites in batches sized by blast radius (per package, per directory). Each batch is its own ticket, blocked by the expand. Every batch stays green, because the old form still exists.
3. **Contract** — delete the old form once no caller remains. Blocked by every migrate batch.

When even the batches cannot stay green alone, keep the sequence but let them share an integration branch, and have all of them block a final integrate-and-verify ticket. Green is promised only there, and the ticket says so.

## No file paths, no code

Both go stale fast, and a ticket that names a path teaches `/implement` to trust it instead of looking.

Exception: a snippet from a prototype that encodes a decision more precisely than prose can — a state machine, a reducer, a schema, a type shape. Inline it, note that it came from a prototype, and trim it to the decision-rich part. Not a working demo.

## Marking a ticket obsolete

Set `Status: obsolete` and add a one-line reason. Never delete it — the reason it existed is part of the record, and a deleted ticket takes that with it.
