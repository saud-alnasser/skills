---
use-when: "a spec is accepted and needs to become executable work"
---

# /tasks — derive executable work from the spec

Converts an accepted effort into tasks. Tasks are a **map of the work**, never a
second definition of the change.

**Posture.** Decomposition is a reading of the spec, never a second draft of
it. Map what is already decided, and where the map will not close, the spec is
what is wrong. **What this gives up** is the chance to fix a gap in passing: a
task that quietly repairs a weak criterion hides the repair somewhere nobody
reviews it.

## Procedure

1. **Read the spec.** The effort's `spec.md` — requirements, acceptance criteria, and the
   technical sections if `[[skills/plan]]` ran.
2. **Find where tasks live.** Ask the repository, in this order: an existing
   `efforts/<effort>/tickets/` directory; a `[[references]]` describing the
   forge or tracker in use; the human. **Never create a local ticket system in a
   repository that already has one** — `[[policies/execution]]` and the
   protocol both forbid mirroring an external tracker.

   **Where the answer is an external tracker, read that tracker's
   `[[references]]` before writing anything.** The effort has to be findable
   there, and what carries it is the tracker's own to answer — settled once and
   recorded, then read rather than rederived. Where the reference is silent, the
   tool's own help is the authority, and the answer is written back into the
   reference so the next session reads it instead of deciding it again.
3. **Decompose by acceptance criterion**, not by file or by layer. A task that
   maps to no criterion is either scope nobody asked for or a criterion the spec
   is missing — resolve which before writing it.

   **A task is the unit a sub-agent may be given, whole** — one child, one task,
   never a fraction of one (`[[policies/execution]]`). So a task that is too large
   for one context is not "dispatched in pieces"; it is **split here**, into
   tasks that each have their own acceptance criteria. Getting this wrong at this
   step is what forces the split to happen later, at dispatch time, by guesswork.
4. **Declare dependencies explicitly.** The task graph is the only thing that
   licenses parallel work (`[[policies/execution]]`); an edge you leave implicit
   becomes a collision later.
5. **Write the tasks.**
6. **Regenerate the index** — `node .aep/scripts/index.mjs`. Local tickets earn a
   section there listing each one's effort, `status`, and `blocked-by`, which is
   how a later session finds the frontier without reading every ticket.
7. **Report the graph**: what can start now, what is blocked, and on what.

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
