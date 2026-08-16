---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: rule
use-when: "two sources disagree and you are about to pick one"
---

# Rule — precedence

## The order

When sources disagree, trust in this order. The later source loses.

1. **What the human said in this conversation**
2. **The repository** — source, configuration, tests, build scripts
3. **Git history, and external systems the repository designates authoritative**
4. **The effort's `spec.md`**, for the change in progress
5. **`[[rules]]`** — protocol-owned first, then repository-owned
6. **`[[references]]`**
7. **`[[contexts]]`**
8. **Evidence** — research and prototypes
9. **`[[index]]` and position** — derived state
10. **Your own reasoning**

**A human instruction overrides everything here — say so when it does, and follow it.**

## The three that get violated

**Ranks 2–3 are absolute against every AEP artifact.** An artifact contradicted
by the source is wrong. Correct the artifact — never the source, and never
explain the contradiction away. *Why: the alternative is a repository whose
documentation describes a system that has not existed for months, which is worse
than no documentation because it is trusted.*

**Rules outrank references and contexts.** A reference says how to operate
something; it never grants permission to do it. A context orients; it never
instructs. Finding a procedure documented is not finding it authorised.

**The spec outranks tasks** (`[[rules/change-control]]`), and both outrank what
seems obvious while implementing.

## Between rules

```
protocol rules  →  repository rules  →  effort rules  →  task constraints
```

A lower level MUST NOT silently violate a higher one. Where a repository rule
contradicts a protocol rule, that is a **declared deviation**
(`[[rules/ownership]]`) — recorded with its reason, not resolved in passing.

## When the order does not settle it

**Surface it. Do not pick.** A conflict an agent resolves silently is a decision
made by whoever wrote the more confident sentence. State both sources, what each
would have you do, and what it costs to be wrong either way — then let the human
choose.
