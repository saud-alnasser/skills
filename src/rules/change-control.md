---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: rule
mode: [specify, plan, refine, implement, review]
use-when: "an effort is in progress — planning it, deriving tasks, implementing, or reviewing"
---

# Rule — change control

## The hierarchy

```
spec.md  →  tasks  →  implementation
```

`spec.md` is the effort's source of truth. **A task that conflicts with the spec
is a defect in the task.** Stop, surface the conflict, and do not silently modify
the architecture to make the task work.

*Why: a task that quietly wins over the spec means the delivered system is
defined by whichever artifact was edited last, and nobody agreed to that one.*

## One spec file

The effort has exactly one durable definition, and it is `spec.md`.

- **NEVER create `plan.md`.** Planning extends the same file with Architecture,
  Components, Interfaces, Data Model, Technical Approach, Integration, Migration,
  Testing Strategy, Operational Considerations, Technical Risks.
- Tasks reference the spec; they MUST NOT copy large portions of it.

## Return to plan

If evidence discovered during implementation or review invalidates the technical
plan:

```
stop → record evidence → [[skills/plan]] → update spec.md → update tasks → continue
```

**Never** patch the architecture in place and carry on. *Why: this is the moment
implementation becomes an uncontrolled design process, and it always arrives when
the work is nearly done and stopping is most expensive.*

## Scope stays where it was put

- `[[skills/plan]]` and `[[skills/refine]]` MUST NOT silently expand product
  scope. Technical discovery that exposes a product-level change **stops and
  surfaces it**.
- `[[skills/implement]]` stays bounded by the effort. An improvement you notice
  that is not in the task is raised, not taken.
- Requirements nobody asked for are a review finding, exactly like requirements
  missed.

## Done means checked

A task is done when its acceptance criteria have been **verified explicitly**,
one at a time, against the running system. Not when the code looks right.
