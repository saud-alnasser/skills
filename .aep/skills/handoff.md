---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: skill
use-when: "this session is ending or has run long, and the next session must pick the work up"
---

# /handoff — carry the work into a fresh session

Writes what the next session needs to continue, so that context ending does not
mean progress ending.

## Why this exists

A long thread stops reasoning well before it stops working, and the tell is
subtle: it keeps answering, just worse. Handing off is the deliberate exit —
compaction keeps you here and loses the verbatim history; a handoff forks.

## First, put durable knowledge where it belongs

**A handoff is not a place to store knowledge** (`[[protocol]]`: no hidden
memory). Before writing it, move anything durable to its home:

| What you learned | Where it goes |
| --- | --- |
| a fact established from sources | `efforts/<e>/evidence/research/` |
| an experiment's outcome | `efforts/<e>/evidence/prototypes/` |
| a change to what is being built | the effort's `spec.md` |
| how an area of the repository works | `contexts/` |
| how a tool is operated here | `references/` |
| a requirement on behaviour | `rules/` |

**What is left over is what a handoff is for**: the state of *this session's*
work, which belongs to no artifact.

## The handoff

Write to a scratch location outside the repository — a handoff is session state,
not repository knowledge, and committing one puts a conversation in the history.

```markdown
# Handoff — <effort or task>

## Where the work stands
## What is done, and verified how
## What is in progress, and exactly where it stopped
## What is decided — and by whom
## What is still open
## What was tried and rejected, and why
## Files that matter
## Resume with
```

## Constraints

- **`Resume with` is one copy-pasteable line** that opens the next session
  against this file. A handoff the human has to reconstruct an invocation for
  has failed at its only job.
- **Record rejected approaches.** Without them the next session re-derives them,
  confidently, at full cost.
- State what is **decided** versus what is **assumed**. A fresh session cannot
  tell them apart from the artifacts alone, and will treat both as settled.
- Never leave uncommitted work unexplained: say what is in the tree and why.

## Done when

A session with no memory of this one could read the artifacts plus the handoff
and continue without asking what happened.
