---
use-when: "a spec is accepted and needs to become executable work"
---

# /tasks — derive executable work from the spec

Turns an accepted standard- or full-lane effort into tickets: a **map of the
work**, never a second definition of the change. A quick-lane effort has no
tickets — its `# Check` is the ticket — so go straight to `[[skills/implement]]`.

**Posture.** Decomposition reads the spec; it never redrafts it. Where the map
will not close, the spec is what is wrong. **What this gives up** is fixing a
gap in passing: a ticket that quietly repairs a weak criterion hides the repair
where nobody reviews it.

## Procedure

1. **Start in the effort's surface.**
   `node .aep/scripts/aep.mjs start <effort>`, quoting its `summary`: it enters
   the surface whose branch this writes to, and a scoped run stays inside its
   claim (`[[policies/execution]]`). Read `spec.md` whole, and `plan.md` where
   `[[skills/plan]]` ran.
2. **Tickets are files under `.aep/efforts/<effort>/tickets/`.** Never tracker
   objects: the `blocked-by` edges are fields a script reads, and the frontier is
   computed from the directory.
3. **Cut vertical slices.** Each ticket is a thin, complete path through every
   layer it needs — schema, API, UI, tests — checkable on its own and sized to
   one fresh context. Never "all the models, then all the routes". Prefactoring
   comes first, as its own ticket. Decompose by acceptance criterion, never by
   file or layer: a ticket mapping to no criterion is scope nobody asked for or
   a criterion the spec is missing — settle which before writing it.
4. **A wide rename or retype goes expand → migrate → contract.** The expand
   ticket adds the new form beside the old; one migrate ticket per batch of call
   sites, each blocked by the expand; the contract ticket removes the old form,
   blocked by every batch. Every ticket lands green.
5. **One ticket is one child's whole job** (`[[policies/execution/parallel]]`).
   One too large for a single context is split here, into tickets with their own
   criteria — never divided at dispatch.
6. **Declare every dependency** as `blocked-by`. Edges are the only licence for
   parallel work; an implicit one becomes a collision.
7. **Write the tickets** from `[[templates/ticket.template]]`: `status: open`,
   `blocked-by:` where it applies, nothing else in the frontmatter. Each exposes
   its scope, its dependencies, acceptance criteria that cite the spec's numbers
   (`requirement 3`, `criterion 4`), the areas it touches, and its constraints.
8. **Check that every ticket traces:** `node .aep/scripts/validate.mjs`. A
   ticket citing nothing, or a number the spec does not define, fails by name.
   It answers *does this ticket come from somewhere*, never *is it right* —
   that is `[[skills/review]]`'s reading. An implemented effort is skipped.
9. **Regenerate the index** (`node .aep/scripts/index.mjs`) and commit the
   tickets as one `docs` commit in the surface.
10. **Report the graph:** what can start now, what is blocked, and on what.

## Constraints

- **Tickets cite the spec; they never copy it.**
- **Tickets never redefine architecture.** Decomposition that shows the
  architecture does not survive contact stops and returns to `[[skills/plan]]`.
- A ticket nobody could build without asking you a design question is not
  finished.

## Done when

Every acceptance criterion is covered by at least one ticket, every ticket
traces to one, and the edges are stated.

## Next

`[[skills/implement]]`.
