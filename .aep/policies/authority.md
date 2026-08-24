---
use-when: "two sources disagree, or the work reaches a repository other than this one"
---

# Policy — authority

What to trust when sources conflict, and what this session is entitled to act on.

## The order

When sources disagree, trust in this order. The later source loses.

1. **What the human said in this conversation**
2. **The repository** — source, configuration, tests, build scripts
3. **Git history, and external systems the repository designates authoritative**
4. **The effort's `spec.md`**, for the change in progress
5. **`[[policies]]`** — AEP's law
6. **`[[rules]]`** — this repository's own governance
7. **`[[references]]`**
8. **`[[contexts]]`**
9. **Evidence** — research and prototypes
10. **`[[index]]` and position** — derived state
11. **Your own reasoning**

**A human instruction overrides everything here — say so when it does, and follow it.**

## The three that get violated

**Ranks 2–3 are absolute against every AEP artifact.** An artifact contradicted
by the source is wrong. Correct the artifact — never the source, and never
explain the contradiction away. *Why: the alternative is a repository whose
documentation describes a system that has not existed for months, which is worse
than no documentation because it is trusted.*

**Governance outranks references and contexts.** A reference says how to operate
something; it never grants permission to do it. A context orients; it never
instructs. Finding a procedure documented is not finding it authorised.

**The spec outranks tasks** (`[[policies/execution]]`), and both outrank what
seems obvious while implementing.

## Between policies and rules

```
policies  →  rules  →  effort rules  →  task constraints
```

A policy is AEP's and is never edited in a repository. A rule is the
repository's, and it may **tighten or extend** a policy — never soften it,
contradict it, or opt out of it.

A repository that genuinely must differ from a policy records a **declared
deviation** (`[[policies/artifacts]]`), with its reason and the release it was
declared under. It does not resolve the conflict in passing.

## When the order does not settle it

**Surface it. Do not pick.** A conflict an agent resolves silently is a decision
made by whoever wrote the more confident sentence. State both sources, what each
would have you do, and what it costs to be wrong either way — then let the human
choose.

## Work that reaches another repository

**This session works on one repository. Work for any other leaves as a report.**

| In another repository | |
| --- | --- |
| reading its files, history, issues | **allowed** — a claim is checked by reading what makes it |
| writing or editing a file | **not allowed** |
| planning its work — a spec, tasks, an effort | **not allowed** |
| running a skill against it | **not allowed** |

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

**A worktree is not another repository.** One created for this effort
(`[[policies/execution]]`) is this repository, checked out elsewhere; working in
it crosses no boundary. A checkout of a *different* project does, however
convenient the path makes it look.
