---
name: domain-modeling
description: Build and sharpen a project's domain model. Use when the user wants to pin down domain terminology or a ubiquitous language, record an architectural decision, or when another skill needs to maintain the domain model.
metadata:
  mode: design
  policies: [context, decisions]
---

# Domain Modeling

Actively build and sharpen the project's domain model as you design. This is the *active* discipline — challenging terms, inventing edge-case scenarios, and writing Context and Decisions down the moment they crystallise. (Merely *reading* Context for vocabulary is not this skill — that's a one-line habit any skill can do. This skill is for when you're changing the model, not just consuming it.)

## Where the knowledge lives

The three knowledge layers and the truth hierarchy between them are in `CLAUDE.md`. This skill is the one that *writes* two of them, so what it adds is the shape on disk:

```
.claude/
├── contexts/
│   ├── map.md                 the routing table, and nothing else
│   ├── repository.md          vocabulary that crosses domains
│   ├── auth.md                repo-wide domains stay flat
│   ├── database.md
│   └── web/                   a project earns a directory on the same test
│       ├── routing.md         a domain earns a file — its own vocabulary
│       └── forms.md           or ownership
└── decisions/                 the third layer, a peer of the second
    ├── 0001-event-sourced-orders.md
    └── 0002-postgres-for-write-model.md
```

Decisions sit beside Context rather than below it because `CLAUDE.md` presents the two as peers, and a tree that buries one of them contradicts the model on the page a reader meets first (ADR 0018).

A single-package repo simply has no directories under `contexts/`. The flat case is not a special mode — it is the same model with nothing to group.

Create files lazily, only when you have something to write. If no Context exists, create `.claude/contexts/repository.md` when the first term resolves. If no decisions directory exists, create it when the first Decision needs recording.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in Context, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with the Codebase

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

Resolve it in the direction `CLAUDE.md`'s truth hierarchy requires: the documentation changes, never the reading of the code.

### Update Context inline

When a term resolves, write it to Context right there. Don't batch these up — capture them as they happen.

What goes in, what stays out, and the compression test that decides: `.claude/policies/context.md`.

### Offer Decisions sparingly

A Decision is recorded only when it passes the 3-of-3 test in `.claude/policies/decisions.md` — and most things don't. Offer one when the conversation has just produced a choice that was hard to reverse, will look surprising later, and had real alternatives; otherwise say nothing and keep grilling.

---

Vendored from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for AEP.
