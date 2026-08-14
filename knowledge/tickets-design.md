---
owner: framework
type: norm
subject: tickets
fires-when: stage
stages: [design]
spans:
  - one-ticket-per-file-never-a-combined-file: takaxe
  - engineering-knowledge-never-lives-in-a-ticket-body: j6q6zx
  - triage-roles-never-appear-on-a-build-ticket: ll50bi
  - a-ticket-has-an-observable-outcome: d4j8ap
  - deepen-don-t-widen: ui10oy
  - one-design-run-one-root: 1u4bjh
  - never-ticket-a-rename-or-a-comment: w0ra3m
  - a-shared-tracker-ticket-states-an-outcome-outside-the-protocol-directory: j1owo3
  - the-test-is-the-diff: l4hmbb
  - a-path-outside-claude-decides-it: cusx4a
  - protocol-only-work-rides-its-consumer: cozlmn
  - the-rule-reads-the-diff-never-the-commit-type: 255pcu
  - a-criterion-is-checkable-by-someone-who-did-not-write-the-code: noa3jf
  - above-express-slicing: bfi6q7
  - vertical-slices-not-horizontal-ones: a23dzp
  - each-slice-is-demoable-or-verifiable-on-its-own: av29cn
  - prefactoring-goes-first: zdy1jb
  - read-the-existing-tickets-before-writing-the-edges: jd16p4
  - only-real-gates: umio0e
  - scanning-for-booming: ohjmxn
  - wide-refactors-are-the-exception: u2f7nz
  - no-file-paths-no-code: 20bgcr
---


# Tickets

Every `/design` run leaves at least one ticket, numbered from `01` in dependency order — blockers first.

## One ticket per file, never a combined file

- **One ticket per file, or one per issue — never a single combined file**: tickets are claimed one at a time, and a combined file cannot be claimed.

## Engineering knowledge never lives in a ticket body

- **Engineering knowledge lives in the Codebase, in Context, and in Decisions — never in a ticket body.** A tracker that accumulates it becomes a fourth knowledge layer nothing verifies and nothing prunes — and the one people read first, because it has the search box.

## Triage roles never appear on a build ticket

**Triage roles — `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix` — never appear on a build ticket: this is not the triage vocabulary.** They describe *incoming* issues someone else filed; a ticket `/design` created is agent-ready by construction and never carries one, and mixing the two sets makes a ticket's status answer two questions at once.

## A ticket has an observable outcome

- **A ticket must have an outcome someone can observe when it closes** — the checkable rule against a tracker filling with AI-generated micro-tickets nobody reads. If closing it produces nothing visible, it is a step inside another ticket, not a ticket.

## Deepen, don't widen

- **Deepen, don't widen.** A small set of parent tickets with sub-tickets where the work actually divides, never a flat spray of siblings — structure is carried by relationships, not by ticket count.

## One design run, one root

- **One design run, one root.** Every ticket the run produces hangs beneath a single top-level ticket, and a run that yields exactly one ticket makes that one the root — so the top level grows by one per design, and booming is visible without anyone counting. `/design` has the procedure for creating them in that order.

## Never ticket a rename or a comment

- Never create a ticket to rename a variable, move a file, or update a comment — those happen inside a ticket that has an outcome.

## A shared-tracker ticket states an outcome outside the protocol directory

- **A ticket this workflow creates on a shared tracker states an outcome outside the protocol directory.** Protocol-only work is scaffolding — an input to some deliverable, not a thing a tracker item can deliver — and a tracker item for it publishes the workflow's own bookkeeping onto a surface teammates read.

## The test is the diff

- **The test is the diff**: work is protocol-only when every path it changes sits under `.claude/`, and it stops being protocol-only the moment one path sits outside. The file list has exactly one reading, where a claim about what the work is *for* has as many readings as it has readers.

## A path outside `.claude/` decides it

- **Where a protocol-only outcome needs a change outside `.claude/`, the diff decides and the work is not protocol-only** — the tracker carries it, and no exception is argued for it: the path outside is the deliverable the rule was asking for all along, something a teammate who does not run the protocol can watch change.

## Protocol-only work rides its consumer

- **Protocol-only work rides its consumer instead.** Evidence gating a map decision is produced by the map session that needs it — how design output reaches the default branch is the version-control record's. Evidence gating a build is a declared increment on the consuming build ticket, below: the answer and the code ship in the same commit.

## The rule reads the diff, never the commit type

- **The rule reads the diff, never the commit type** — a type is a label where the diff is a fact. It binds only what the workflow creates on a shared tracker: humans file what they like and triage routes it, and on a local-markdown tracker there is nothing to bind, because the tickets are `.claude/` files and nothing publishes.

## A criterion is checkable by someone who did not write the code

**A criterion is checkable by someone who did not write the code.** "Users can retry a failed payment without re-entering the card" is checkable; "the retry handler is refactored" is not — it names an implementation and can be satisfied by any change at all. Write what becomes true, not what gets edited.

## Above Express — slicing

Below Express there is one ticket and nothing to slice. Above it:

## Vertical slices, not horizontal ones

- **Vertical slices, not horizontal ones.** Each ticket cuts a narrow but *complete* path through every layer it touches — schema, logic, interface, tests. A ticket that delivers "the database layer" is a horizontal slice: it cannot be demonstrated, cannot be verified alone, and defers every integration risk to the end.

## Each slice is demoable or verifiable on its own

- **Each slice is demoable or verifiable on its own**, and sized to fit in a single fresh context window.

## Prefactoring goes first

- **Prefactoring goes first.** Make the change easy, then make the easy change — as its own ticket, blocking the ones that depend on it.

## Read the existing tickets before writing the edges

- **Read the tickets that already exist before writing the edges** — an edge invented without checking is how a cycle or a dangling number gets in.

## Only real gates

- **Only real gates.** A ticket listed as a blocker because it is *tidier* to do first serializes work that could have run in parallel.

## Scanning for booming

**Scan the set when the tickets are cut: any ticket that is neither the root nor carries an edge is a stray** — either it belongs under a parent nobody linked, or it should not exist. The edges are what make the anti-booming rule checkable, and the answer is cheapest while the set is still being written.

## Wide refactors are the exception

A **wide refactor** — rename a column, retype a shared symbol — breaks thousands of call sites on a single edit, so no vertical slice can land green. Don't force it into a tracer bullet; sequence it **expand–contract**:

1. **Expand** — add the new form beside the old. Nothing breaks.
2. **Migrate** — move call sites in batches sized by blast radius (per package, per directory). Each batch is its own ticket, blocked by the expand; every batch stays green, because the old form still exists.
3. **Contract** — delete the old form once no caller remains. Blocked by every migrate batch.

When even the batches cannot stay green alone, keep the sequence but let them share an integration branch, and have all of them block a final integrate-and-verify ticket. Green is promised only there, and the ticket says so.

## No file paths, no code

**A ticket names no file paths and holds no code.** Both go stale fast, and a ticket that names a path teaches `/implement` to trust it instead of looking. One exception: a snippet from a prototype that encodes a decision more precisely than prose can — a state machine, a reducer, a schema, a type shape. Inline it, note that it came from a prototype, and trim it to the decision-rich part — not a working demo.
