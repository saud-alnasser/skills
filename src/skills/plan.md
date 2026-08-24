---
use-when: "a spec is settled and the technical approach is not yet decided"
---

# /plan — define HOW it will be built

Writes the effort's `plan.md`, the technical approach behind a settled
`spec.md`. Run it when the change is large enough, or unfamiliar enough, that
starting to build would mean deciding architecture by accident, and **skip it
where the approach is obvious** — an effort with no `plan.md` is not an
incomplete effort.

**Posture.** Design against the codebase that exists rather than the one you
would prefer, and read the seams you intend to cut before proposing where to
cut them. A plan that would work in a clean repository and not in this one is
not a plan. **What this gives up** is optionality: finishing means committing
to an approach and writing down why the alternatives lost, which is
uncomfortable precisely when it matters most.

## Procedure

1. **Read the scope, then the spec.** `node .aep/scripts/scope.mjs read`, quoted:
   it names the effort whose `spec.md` this reads, and a non-empty claim confines
   the run to the efforts it names (`[[policies/execution]]`). The claim and the
   isolation go in `Position`, beside that spec's `status:`
   (`[[policies/reporting]]`). If `status:` is still `draft` and material
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
7. **Write the approach** into `efforts/<effort>/plan.md`, using
   `[[templates/plan.template]]`, and set `spec.md`'s `status: accepted` once the
   human has agreed. **`status` stays the spec's** — an effort has one state, and
   a plan declaring a second gives it two answers that can disagree.

## Output

`efforts/<effort>/plan.md`, carrying whichever of these apply:

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

- **The plan never restates the spec.** Requirements, acceptance criteria, and
  scope live in `spec.md` and are referenced from `plan.md`
  (`[[policies/execution]]`). Two files are what let the two travel separately:
  the spec is what a reviewer agrees to, and the plan is what an implementer
  follows.
- **Planning MUST NOT silently expand product scope.** Technical discovery that
  exposes a product-level change **stops and surfaces it** — then `spec.md`'s
  WHAT is updated deliberately, not absorbed into the HOW.
- Plan against the codebase that exists. An approach that would work in a clean
  repository and not in this one is not an approach.
- Leave the implementer no material decision that is not written down. The test:
  could someone else build this without asking you anything architectural?

## Done when

`spec.md` carries `status: accepted`, `plan.md` holds the approach, its rejected
alternatives are named, and the testing strategy says how each acceptance
criterion will be checked.

## Next

`[[skills/tasks]]`.
