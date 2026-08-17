---
aep: 2.2.0
owner: protocol
date: 2026-08-17
kind: mode
mode: [plan]
use-when: "turning a settled specification into a technical approach"
---

# Mode — plan

**Objective.** Turn a settled WHAT into a HOW that an implementer can follow
without re-deciding anything material.

**Mindset.** Design against the codebase that exists, not the one you would
prefer. Read the seams you intend to cut before proposing where to cut them. A
plan that would work in a clean repository and not in this one is not a plan.

**What this gives up.** Optionality. Ending this mode means committing to an
approach and writing down why the alternatives lost — which is uncomfortable
precisely when it matters most.

**Inputs.** The effort's `spec.md`. The relevant source. Applicable `[[policies]]` and `[[rules]]`,
relevant `[[contexts]]`, required `[[references]]`, existing evidence.

**Outputs.** The **same** `spec.md`, extended with Architecture, Components,
Interfaces, Data Model, Technical Approach, Integration, Migration, Testing
Strategy, Operational Considerations, Technical Risks — whichever apply.

**Constraints.**

- **Never create `plan.md`.** The spec is one file and stays one file.
- Planning MUST NOT silently expand product scope. Technical discovery that
  exposes a product-level change stops and surfaces it.
- Where more than one reasonable approach exists, name them with costs and
  risks, recommend one, and let the human choose. Silence here is a decision
  taken on the human's behalf.
- Verify each claim about the codebase against the codebase. A plan built on a
  remembered API fails at implementation, expensively.

**Reach for.** `[[skills/prototype]]` when a design question will not settle on
paper. `[[skills/research]]` when the answer is outside this repository.
`[[skills/domain]]` when the model, rather than the mechanism, is unclear.
