---
aep: 2.1.1
owner: protocol
date: 2026-08-16
kind: rule
use-when: "the work touches a repository other than the one this session is in"
---

# Rule — the repository boundary

**This session works on one repository. Work for any other leaves as a report.**

| In another repository | |
| --- | --- |
| reading its files, history, issues | **allowed** — a claim is checked by reading what makes it |
| writing or editing a file | **not allowed** |
| planning its work — a spec, tasks, an effort | **not allowed** |
| running a skill against it | **not allowed** |

## What that means in practice

- **The deliverable is the write-up**, handed to whoever works there. It is
  finished when the report is written, not when the change is made.
- **A finding about another repository is a report, not an options list.** A
  diagnosis offered with options becomes a proposal this session then owns. State
  what was found, what it costs, and what would close it — **do not offer to do
  it**, and do not recommend this session as the place.
- **Authorization does not transfer.** Being told to fix something is not being
  told to fix it *here*: where the session stands is a fact about the session,
  not about the work. Ask if it is genuinely unclear.
- **Say it in the turn it is reached.** *Why: the failure is a chain of
  individually authorised steps with no obvious place to stop; naming the
  crossing gives the human one, and it costs a sentence.*
- **A clean position check licenses none of this.** It answers *has this
  repository moved under me*, never *is this repository mine to change*.

## Worktrees are not another repository

A worktree created for this effort (`[[rules/sub-agents]]`) is this repository,
checked out elsewhere. Working in one crosses no boundary. A checkout of a
*different* project does, however convenient the path makes it look.
