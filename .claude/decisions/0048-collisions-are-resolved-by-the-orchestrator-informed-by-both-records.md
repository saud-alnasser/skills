---
owner: repository
status: accepted
load-when: two children wrote the same path
sources: [skills/implement/]
supersedes: []
superseded-by: []
---

# Collisions are resolved by the orchestrator, informed by both change records

**Non-blocking is not non-overlapping.** Two tickets with no edge between them may still write the same file, and the orchestration effort is its own proof: all eight of its tickets appended to `scripts/verify.ps1`, and four of them — 03, 04, 05, 07 — had no edge between any pair. Dispatched in parallel, they would have produced four children rewriting one file from one base.

The declared edges cannot fix this. `Blocked by` records what gates what, and file overlap is not a gate — making it one would put false edges in the DAG to encode a fact about text.

**The orchestrator resolves it, and the mechanism is read from `.claude/policies/version-control.md`.** On a stacking repository the collision surfaces as a restack conflict and is resolved there; on plain git it surfaces as a rebase or merge. The workflow does not carry its own merge strategy — it carries the obligation to resolve, and reads which tool does it.

What makes this different from a blind three-way merge is that the orchestrator holds **both children's change records**. ADR 0044 already named the property: a branch diff says what moved, and only the record says what the child *believed* it was doing. A conflict resolved with both intents in hand is a different act from one resolved by reading two hunks, and it is why the resolution belongs to the orchestrator rather than to whoever opens the file next.

## Consequences

**Resolution is a step with an owner, and it can fail.** Where the two intents genuinely conflict — not the text, the intent — that is a decision, and a decision the orchestrator cannot make alone goes to the human by the route every other blocked decision takes.

**The parallel set is optimistic.** Nothing predicts overlap before dispatch, because predicting it is the architecture judgement `/implement` is forbidden to make. The cost of a collision is paid at integration, by the party holding the most information about it.

## Considered Options

- **Declare ticket-level file ownership, as a fan-out does.** Rejected: `.claude/policies/tickets.md` already says a brief cannot be composed at design time "because only the dispatch has read the code" — and predicting which files a ticket will touch is the same claim about the same unread code, made a level up.
- **Dispatch only tickets that look disjoint.** Rejected: that judgement is the decomposition decision `/implement` may not make.
- **Reject the losing child and rebuild it against the new base.** A clean rule, and rejected because it discards finished work whenever two tickets share so much as a table row, which on this repository is most of them.

Specification §20 is amended in the same change to name the collision, to say why the declared edges never promised against it, and to give resolving it to the orchestrator.
