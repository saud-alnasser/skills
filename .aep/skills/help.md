---
use-when: "the question is about AEP itself — what to reach for, and when"
---

# /help — what AEP is and what to reach for

For questions about the **protocol**. A question about this repository's own code
or architecture is answered directly, from `[[contexts]]` and the source.

## The model in one screen

AEP is a filesystem protocol. All its state is plain files under `.aep/`, and it
does not care which agent runtime you are. `[[protocol]]` is the bootstrap — read
that first; everything else loads when its `use-when` fires.

| Primitive | Answers |
| --- | --- |
| `[[policies]]` | what MUST be done, in every repository AEP governs |
| `[[rules]]` | what MUST be done *here* |
| `[[references]]` | how a tool is operated *here* |
| `[[contexts]]` | what to know about an area, and where to look |
| evidence | what has been discovered — research and prototypes |
| efforts | what change is being made; `spec.md` is its truth |
| tasks | executable work derived from the spec |
| `[[agents]]` | who does work, in what role |
| worktrees | isolated execution; never knowledge |
| position | lightweight operational state; never truth |

## The spine

```
/specify → /plan? → /tasks → /implement
```

`plan` when the approach is not obvious. Everything else is a capability rather
than a stage.

**Four commands, and grilling, research, and review are not among them** — they
are stages the four run. `[[skills/refine]]`, `[[skills/research]]`, and
`[[skills/review]]` are still here to be read, and reaching for one directly is
reaching for depth rather than typing a command.

**Pick the smallest process that produces a reliable result.**

```
simple:   /specify → /tasks → /implement
complex:  /specify → research → prototype → /plan → /tasks
          → parallel /implement
```

## What to reach for

| You want to | Reach for |
| --- | --- |
| start a change nobody has described yet | `[[skills/specify]]` |
| have a plan attacked before building it | `[[skills/refine]]` |
| decide the technical approach | `[[skills/plan]]` |
| turn an accepted spec into work | `[[skills/tasks]]` |
| build a task | `[[skills/implement]]` |
| judge finished work | `[[skills/review]]` |
| establish an external fact | `[[skills/research]]` |
| answer *can this work* | `[[skills/prototype]]` |
| find where the codebase is costing you | `[[skills/survey]]` |
| build one behaviour test-first | `[[skills/tdd]]` |
| fix the words the problem is described in | `[[skills/domain]]` |
| make text read as though a person wrote it | `[[skills/prose]]` |
| join a repository to AEP | `[[skills/install]]` |
| move to a newer AEP release, or bring a 1.x repository forward | `[[skills/update]]` |
| resolve a merge conflict | `[[skills/implement/conflicts]]` |
| diagnose a bug whose cause is unknown | `[[skills/implement/diagnosing]]` |
| clear out stale AEP artifacts | `[[skills/prune]]` |
| carry work into a fresh session | `[[skills/handoff]]` |

A skill file is what that skill does on **every** invocation. Depth for one
branch sits beside it as `skills/<skill>/<note>.md` and is read only when the
skill sends you there — so *what a good test asserts* or *how to prototype a UI*
costs nothing on the runs that never ask.

An effort is two files: **`spec.md` is what and why, `plan.md` is how.** Neither
restates the other, and `plan.md` is written only where the approach is not
obvious.

## Things people expect and will not find

- **No decisions directory.** The reasoning lives in the spec that made the
  change, beside the evidence that informed it.
- **No mandatory tickets.** Local tickets are optional; external trackers stay
  external and are never mirrored.
- **No synchronization command.** Nothing reconciles the whole tree on a
  schedule. Verification happens where a statement is about to be relied on, and
  drift is fixed where it is found.
- **No push, no publish.** Ever, unasked.

## Answering questions about AEP

Answer from the artifacts, quoting the file. Where AEP genuinely does not say,
say that — do not invent protocol.
