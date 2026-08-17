---
aep: 2.4.0
owner: protocol
date: 2026-08-17
kind: skill
mode: [plan]
report: full
use-when: "a spec is settled and the technical approach is not yet decided"
---

# /plan — define HOW it will be built

Extends the **same** `spec.md` with the technical approach. Run it when the
change is large enough, or unfamiliar enough, that starting to build would mean
deciding architecture by accident.

**Enters `[[modes/plan]]`.** Read it and hold its tradeoffs.

## Procedure

1. **Read the spec.** The effort's `spec.md`. If `status:` is still `draft` and material
   questions are open, go back to `[[skills/refine]]` first.
2. **Read the code you intend to change** — not the parts you remember, the parts
   you will touch. `[[policies/engineering]]`: names are not proof.
3. **Load what applies.** Applicable `[[policies]]` and `[[rules]]`, relevant `[[contexts]]`, required
   `[[references]]`, and any existing evidence for this effort.
4. **Identify the technical uncertainty** and resolve what is material —
   `[[skills/research]]` for facts, `[[skills/prototype]]` for feel.
5. **Root cause, not workaround.** When the plan hits a limitation, find out *why
   the limitation exists* before designing around it — this is the last stage
   that can still see the choice. Where a workaround genuinely is the answer, the
   spec records **why it exists, what else was considered, and the condition
   under which it is removed.** Without a removal condition, "temporary" is an
   intention rather than a state anything can leave.
6. **Where more than one reasonable approach exists, put them on the table.**
   Each named, in this shape:

   | | Advantages | Disadvantages | Risks | Maintenance |
   | --- | --- | --- | --- | --- |
   | Approach A | | | | |
   | Approach B | | | | |

   **Recommend one, with reasoning. The human chooses.** This is the whole
   mechanism behind *never silently decide architecture* — an alternative left
   unmentioned is a decision already taken (`[[policies/engineering]]`).

   Where the alternatives are not obvious, or where only one has been produced,
   `[[skills/plan/design-it-twice]]` is how to generate ones that genuinely
   disagree. Where the approach turns on **where a module boundary goes**,
   `[[skills/plan/depth]]` has the vocabulary and the rules for moving one.
7. **Write the approach** into `spec.md` — using `[[templates/spec.template]]` for the
   headings — and set `status: accepted` once the human has agreed.

## Output

The same `spec.md`, gaining whichever of these apply:

```markdown
# Architecture
# Components
# Interfaces
# Data Model
# Technical Approach
# Integration
# Migration
# Testing Strategy
# Operational Considerations
# Technical Risks
```

## Constraints

- **NEVER create `plan.md`.** `[[policies/execution]]` has the reason.
- **Planning MUST NOT silently expand product scope.** Technical discovery that
  exposes a product-level change **stops and surfaces it** — then `spec.md`'s
  WHAT is updated deliberately, not absorbed into the HOW.
- Plan against the codebase that exists. An approach that would work in a clean
  repository and not in this one is not an approach.
- Leave the implementer no material decision that is not written down. The test:
  could someone else build this without asking you anything architectural?

## Done when

`status: accepted`, the approach is written, its rejected alternatives are named,
and the testing strategy says how the acceptance criteria will be checked.

## Next

`[[skills/tasks]]`.
