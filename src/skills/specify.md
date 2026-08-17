---
aep: 2.3.0
owner: protocol
date: 2026-08-17
kind: skill
mode: [specify]
report: full
use-when: "a change is wanted and no effort describes it yet"
---

# /specify — define WHAT is changing and WHY

Creates or updates an effort's `spec.md`. This is where work starts when nothing
already describes it.

**Enters `[[modes/specify]]`.** Read it and hold its tradeoffs.

## Procedure

1. **Orient.** Read `[[index]]`. Check `position/marker.json` against the current
   `HEAD` and working tree — where they differ, the tree moved under you and
   anything you remember about it is suspect.
2. **Check for an existing effort, and for an existing boundary.** A request that
   extends work already specified belongs in that effort's spec, not a new one —
   two efforts describing one change is the failure this step prevents. A request
   this repository has already declined is not re-argued from scratch:
   `[[skills/specify/out-of-scope]]` has where those are recorded and what to do
   on a match.
3. **Load what applies.** Applicable `[[policies]]` and `[[rules]]`, then
   relevant `[[contexts]]`.
   By `use-when` and `paths` — never everything.
4. **Inspect the repository.** Never describe a change to code you have not read.
5. **State your understanding.** Say plainly what you now believe about the
   problem and the code, **including the assumptions you are making** — as a
   position, not a question. A position invites correction; a question invites
   agreement. **Never skip it**: obvious work is where wrong models survive
   longest, and a wrong model is free to fix here and expensive after a plan is
   built on it.

   The unverified half of it is what fills `Assuming` in this turn's opening
   report (`[[policies/reporting]]`); the rest is prose and stays prose.
6. **Identify uncertainty, and classify it** — factual, technical, or
   product. `[[policies/engineering]]` routes each to its instrument.
7. **Resolve what is material.** Material means: the spec would be different
   depending on the answer. Everything else is written down as an assumption or
   an open question and left alone.
8. **Size the work — now, never earlier.** Sizing before you understand the
   problem anchors everything that follows to the guess.

   | The change is | Floor |
   | --- | --- |
   | docs, config, a bug fix, an isolated refactor | straight to `[[skills/tasks]]` |
   | a feature, an API addition, a schema change | `[[skills/refine]]`, then `[[skills/plan]]` |
   | a migration, an architecture change, anything security- or performance-critical, anything crossing domains | evidence first, then both |

   Then raise it — **never lower it** — if any of these fire: a load-bearing
   assumption is unverified; the change crosses a boundary, a public contract, or
   data at rest; it is too large for one context; it is too foggy to scope.

   **Report the floor, what fired, and the result.** The human overrides in
   either direction, and their override stands. The floor is what this turn's
   `Next` names (`[[policies/reporting]]`).
9. **Write the spec**, using `[[templates/spec.template]]`.

## Output

`efforts/<effort>/spec.md`, where `<effort>` is a kebab-case slug naming the
change, with `status: draft`:

```markdown
# Problem
# Goal
# Scope
# Requirements
# Acceptance Criteria
# Constraints
# Out of Scope
```

Add `# Assumptions`, `# Open Questions`, `# Risks` where they have content. Omit
a heading rather than writing "N/A" under it.

## Constraints

- **No `# Architecture` here.** HOW is `[[skills/plan]]`'s. A specify run that
  starts designing has skipped the step that makes designing safe.
- Every requirement gets an acceptance criterion. A requirement with no way to
  tell whether it was met is a wish.
- **Out of Scope is mandatory.** Write it even when it feels obvious — the
  obvious exclusion is the one that gets built. Where the exclusion is about the
  repository rather than this change, it outlives the effort and belongs
  elsewhere (`[[skills/specify/out-of-scope]]`).
- Create `evidence/` and `tickets/` only when something goes in them.

## Done when

The spec answers what is changing, why, what is explicitly not changing, and how
anyone would know it worked — and the human has seen it.

## Next

`[[skills/refine]]` if ambiguity remains. `[[skills/plan]]` if it needs a
technical approach. `[[skills/tasks]]` if it is already clear enough to build.
