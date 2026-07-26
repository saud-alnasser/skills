# Tickets

Every `/design` run leaves at least one ticket on disk, in `.claude/tickets/`, numbered from `01` in dependency order — blockers first.

One ticket per file. Never a single combined file: tickets are claimed one at a time, and a combined file cannot be claimed.

## Format

```markdown
# <NN> — type(scope): summary

Status: ready-for-agent
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

The title is a Conventional Commit subject, so the ticket's commit writes itself.

`Status:` is one of `ready-for-agent`, `claimed`, `blocked`, `resolved`, `obsolete`. Claiming is the first write of any session that touches a ticket — set it and save before doing any work, so a concurrent session skips it.

## Acceptance criteria state observable outcomes

A criterion is checkable by someone who did not write the code. "Users can retry a failed payment without re-entering the card" is checkable; "the retry handler is refactored" is not — it names an implementation and can be satisfied by any change at all.

Write what becomes true, not what gets edited.

## Above Express — slicing

Below Express there is one ticket and nothing to slice. Above it, the rules that matter:

**Vertical slices, not horizontal ones.** Each ticket cuts a narrow but *complete* path through every layer it touches — schema, logic, interface, tests. A ticket that delivers "the database layer" is a horizontal slice: it cannot be demonstrated, cannot be verified alone, and defers every integration risk to the end.

Each slice is **demoable or verifiable on its own**, and sized to fit in a single fresh context window.

**Prefactoring goes first.** Make the change easy, then make the easy change — as its own ticket, blocking the ones that depend on it.

### Edges

**Every ticket after the first declares at least one of these.** A ticket with neither is unreachable — nothing explains where it came from or what has to happen before it.

```
Blocked by: 02, 05        # must be resolved before this can start
Part of: <spec name>      # the spec this ticket implements
```

`Blocked by: —` is a positive statement that this one can start immediately, and it is not the same as omitting the line. Before writing the edges, read the tickets already on disk — an edge invented without checking is how a cycle or a dangling number gets in.

The **frontier** is every ticket whose blockers are all `resolved`. That is what `/implement` picks from.

Only real gates. A ticket listed as a blocker because it is *tidier* to do first serializes work that could have run in parallel.

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
