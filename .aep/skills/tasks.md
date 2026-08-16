---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: skill
mode: [plan]
use-when: "a spec is accepted and needs to become executable work"
---

# /tasks — derive executable work from the spec

Converts an accepted effort into tasks. Tasks are a **map of the work**, never a
second definition of the change.

**Enters `[[modes/plan]]`.**

## Procedure

1. Read the effort's `spec.md` — requirements, acceptance criteria, and the
   technical sections if `[[skills/plan]]` ran.
2. **Find where tasks live.** Ask the repository, in this order: an existing
   `efforts/<effort>/tickets/` directory; a `[[references]]` describing the
   forge or tracker in use; the human. **Never create a local ticket system in a
   repository that already has one** — `[[rules/change-control]]` and the
   protocol both forbid mirroring an external tracker.
3. **Decompose by acceptance criterion**, not by file or by layer. A task that
   maps to no criterion is either scope nobody asked for or a criterion the spec
   is missing — resolve which before writing it.

   **A task is the unit a sub-agent may be given, whole** — one child, one task,
   never a fraction of one (`[[rules/sub-agents]]`). So a task that is too large
   for one context is not "dispatched in pieces"; it is **split here**, into
   tasks that each have their own acceptance criteria. Getting this wrong at this
   step is what forces the split to happen later, at dispatch time, by guesswork.
4. **Declare dependencies explicitly.** The task graph is the only thing that
   licenses parallel work (`[[rules/sub-agents]]`); an edge you leave implicit
   becomes a collision later.
5. Write the tasks.
6. Regenerate the index — `node .aep/scripts/index.mjs`. Local tickets earn a
   section there listing each one's effort, `status`, and `blocked-by`, which is
   how a later session finds the frontier without reading every ticket.
7. Report the graph: what can start now, what is blocked, and on what.

## What a task must expose

- **scope** — bounded, independently understandable, independently executable
- **dependencies** — as `blocked-by`, for a local ticket
- **acceptance criteria** — traceable to the spec's
- **relevant files or areas**
- **implementation constraints**

Local tickets go to `efforts/<effort>/tickets/`, in the shape
`[[templates/ticket.template]]` gives, with `status: open`, `part-of: <effort>`, and
`blocked-by:` where it applies.

## Constraints

- **Tasks reference the spec; they never copy it.** A task restating the
  architecture creates a second place it can change.
- **Tasks MUST NOT redefine architecture.** If decomposition exposes that the
  architecture does not survive contact, stop and return to `[[skills/plan]]`.
- A task nobody could execute without asking you a design question is not
  finished being written.

## Done when

Every acceptance criterion in the spec is covered by at least one task, every
task traces back to at least one criterion, and the dependency edges are stated.

## Next

`[[skills/implement]]`.
