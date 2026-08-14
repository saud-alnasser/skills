---
owner: framework
type: norm
subject: tickets
fires-when: stage
stages: [design, implement]
spans:
  - where-tickets-go-is-the-tracker-s: ws6636
  - no-implementation-diary: q2o91m
  - format: lspcuf
  - the-id-is-the-filename: ai96c1
  - blocked-by-is-a-list-of-bare-ids: biagnu
  - these-fields-are-the-local-markdown-form: 9okx6v
  - lifecycle: 1bsmg7
  - on-github-the-states-ride-the-issue-s-native-state: 4xwzho
  - on-a-shared-tracker-the-merge-resolves-the-ticket: lgl3lk
  - declared-increments: jmo1x0
  - declared-fan-out: 48rcka
  - the-role-is-a-shipped-agent-definition: 1t9pxg
  - the-declaration-names-roles-and-ownership-and-stops: akbdad
  - a-ticket-with-no-fan-out-is-built-by-one-instance: u48yed
  - a-fan-out-and-a-human-needing-increment-do-not-run-together: 5vxme1
  - edges: d6ncnr
  - an-empty-blocked-by-is-a-positive-statement: ounczo
  - implement-picks-from-the-frontier-and-defines-it: 1wmkjh
  - an-edge-means-the-same-on-either-tracker: gbb7um
  - marking-a-ticket-obsolete: 6h4er7
---


# Tickets

Every `/design` run leaves at least one ticket, numbered from `01` in dependency order — blockers first.

## Where tickets go is the tracker's

- **Where they go is the tracker record's, and it is the only place that records it** — files under `.claude/tickets/` on a local-markdown tracker, issues on GitHub; the format below is the same either way. Read the config rather than assuming the form.

## No implementation diary

- **No implementation diary** — not what was tried, not what went wrong on the way, not a running log of the session. Detailed engineering belongs in a spec, which the ticket **references** — never pastes; where a spec lives is the tracker record's, because it differs per repository.

## Format

```markdown
---
title: type(scope): summary
status: open
blocked-by: []
part-of: <effort>
---

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

## The id is the filename

- **The id is the filename** — `NN-<slug>.md` — so it is not restated inside. `title` is a Conventional Commit subject, so the ticket's commit writes itself; it and the id are what `/implement` builds the branch name from, so write a summary that reads as one.

## `blocked-by` is a list of bare ids

- **`blocked-by` is a list of bare ids, and `[]` is a positive statement** that this ticket can start immediately rather than the absence of an answer. A `superseded` ticket also declares `superseded-by`, naming what replaced it. A **decision ticket** declares `type` — `grilling`, `prototype`, `research`, `task` — and no build ticket does.

## These fields are the local-markdown form

- **These fields are the local-markdown form, and only that.** On GitHub the lifecycle rides the issue's native state and the edges live in the issue body, because the forge owns those facts natively — frontmatter there would be a second home for what the forge already knows, and would render as noise in its issue UI. The tracker record says which form applies; the forge reference has the invocations.

## Lifecycle

```
open       created by /design, nothing else set
blocked    handed back to /design, with the reason under `## Blocked`
resolved   the work is delivered. Who sets it depends on the tracker —
           /implement on a local one, the merge on a shared one
obsolete   no longer needed. Requires a one-line reason. Never deleted
superseded replaced by a named ticket, which `superseded-by` names.
           Not `obsolete`: that one was dropped, this one was rewritten
           somewhere else, and losing the difference loses the forwarding
```

## On GitHub the states ride the issue's native state

**On GitHub the states ride the issue's native state — zero new labels.** `open` is an open issue; `resolved` is the issue closed as completed, by the merge, as below; `blocked` stays open, its reason under a `## Blocked` heading in the body beside the edges already there — closing it would read as delivered; `obsolete` is the issue closed as not planned, with a comment carrying the one-line reason — the comment is mandatory, because closed-as-not-planned alone is a verdict with the reasoning withheld; `superseded` maps as `obsolete` does, the comment naming the replacement rather than a reason, which is the whole difference and the forge has no state for it. The mapping is GitHub's; no other forge's is in evidence. The forge reference has the invocation.

## On a shared tracker the merge resolves the ticket

**On a shared tracker the merge resolves the ticket, not AEP.** AEP commits and never pushes, opens a pull request, or merges, so it would be asserting an outcome it does not control — a closed issue whose pull request is later rejected is a lie the tracker now tells everyone. Which text carries the closing keyword, and which a reference that closes nothing, is `/commit`'s, read from how the work reaches the default branch; the forge reference has the forms. Between commit and merge nothing new is written: the branch still exists, so the Claim still holds and the ticket stays off the frontier on its own.

## Declared increments

Some decisions are answerable only once partial code exists — whether a surface reads as raised needs real rows. A build ticket MAY carry those decisions as **declared increments**, written at design time only — never added during the build:

```markdown
## Declared increments

- after <step>: <the question> — type: <grilling|research|prototype|task>
```

The step names where in the build the question becomes answerable; the question is stated as sharply as a decision ticket's; the type is the map vocabulary's (`maps.md`). What `/implement` does on reaching one — which types resolve inline, which stop for the human, and the guardrail on what it may never do — is that skill's to state. An increment's resolution is recorded where any design decision lands: an ADR when it clears the bar in `decisions.md`, the design document otherwise.

## Declared fan-out

Dividing a ticket into portions worked in parallel is an architecture decision, so it is declared rather than discovered. A build ticket MAY carry one **fan-out**, written at design time only — never added during the build:

```markdown
## Fan-out

- <role>: <the files this portion owns>
```

## The role is a shipped agent definition

- **The role is a shipped agent definition, named rather than described.** The files are that portion's to write and no other portion's — overlapping ownership is not a fan-out, it is two children editing the same file with no way to tell afterwards which meant what. What a dispatched child is bound by is `sub-agents.md`'s.

## The declaration names roles and ownership, and stops

- **The declaration names roles and ownership, and stops.** It does not compose a brief: what to tell a child can only be written once the code has been read, which is at dispatch and not at design time. What `/implement` does with a declaration — how it dispatches, how it integrates, and the guardrail on what it may never do — is that skill's to state.

## A ticket with no fan-out is built by one instance

- **A ticket with no `## Fan-out` section is a ticket built by one instance**, unchanged in every respect.

## A fan-out and a human-needing increment do not run together

- **A fan-out and an increment needing a human do not run together.** A child has no surface on which to ask one, so a `grilling` or `prototype` increment on a fanned-out ticket **resolves first, in the parent, before anything is dispatched** — a declaration that would hand such an increment to a child is refused rather than reordered, because the portion is wrong, not merely early. An AFK increment — `research` or `task` — needs nobody present and may sit inside a portion.

## Edges

**Every ticket after the first declares at least one of these.** A ticket with neither is unreachable — nothing explains where it came from or what has to happen before it.

```
Blocked by: 02, 05        # this cannot start until those are delivered
Part of: <spec name>      # the spec this ticket implements
```

## An empty `Blocked by` is a positive statement

- **`Blocked by: —` is a positive statement** that this one can start immediately, and it is not the same as omitting the line.

## Implement picks from the frontier and defines it

- **`/implement` picks from the frontier, and defines it** — including what "delivered" has to mean before a blocked ticket becomes buildable, which is not the same answer on every repository.

## An edge means the same on either tracker

- An edge means the same thing on either tracker; only the syntax moves. The tracker record says which applies.

| Tracker | `part of` | `blocks` | `related` |
| --- | --- | --- | --- |
| local markdown | a `Part of:` line | a `Blocked by: NN, NN` line | a `Related: NN` line |
| GitHub | the sub-issues API, else a task list in the parent | `Blocked by: #NN` in the body | `#NN` mentioned in the body |

The GitHub column is what the forge reference documents and nothing more: `gh` has **no blocking subcommand**, so the edge lives in the issue body — legible to humans, and exactly what the local tracker does anyway. Read that record before issuing anything; a native-sounding invocation that does not exist is the guessed CLI the reference exists to prevent.

`related` carries no ordering and blocks nothing — the edge for an issue worth reading first, and the one to reach for when a blocker would be a lie.

## Marking a ticket obsolete

**Set `Status: obsolete` and add a one-line reason — never delete it.** The reason it existed is part of the record, and a deleted ticket takes that with it.
