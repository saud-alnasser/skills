---
use-when: "a change is wanted and no effort describes it yet"
---

# /specify — define WHAT is changing and WHY

Creates or updates an effort's `spec.md`. This is where work starts when nothing
already describes it.

**Posture.** Separate the problem from the solution, and hold that separation
even when the solution is obvious. The first solution offered is a hypothesis
about the problem — evidence of what the human wants, not the requirement
itself. **What this gives up** is speed to code: this command ends with nothing
runnable, and that is the trade, because a wrong problem statement costs the
whole effort and is cheapest to fix here.

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
7. **Resolve what is material, here, in this invocation.** Material means: the
   spec would be different depending on the answer. Everything else is written
   down as an assumption or an open question and left alone.

   | The uncertainty is | Resolve it by |
   | --- | --- |
   | **factual** — what an API does, what a spec says, whether a bug is fixed | `[[skills/research]]`, as a stage. It writes `evidence/research/<question>.md` |
   | **product, or a tradeoff** | `[[skills/refine]]`, as a stage. It grills and the spec comes back clarified |
   | **technical, and argument will not settle it** | `[[skills/prototype]]`, in a worktree |

   **These run inside this invocation and hand nothing back for the human to
   type.** A turn that ends by naming a command has not resolved the uncertainty;
   it has renamed it. One `/specify` on a request carrying a factual unknown
   produces the spec *and* the evidence file.

   They are stages, so they open no report of their own
   (`[[policies/reporting]]`). Everything they produce still reaches the human.
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
9. **Write the spec**, using `[[templates/spec.template]]`. The directory is
   `efforts/xxxx-<slug>/` — a literal `xxxx`, because the number is the
   tracker's and does not exist yet.
10. **Open the effort**, below. Even on a draft.

## Opening the effort

**When `spec.md` first exists, even as a draft, the effort opens.** One step, and
it is the same step for a one-line fix and a fifteen-ticket feature:

| | |
| --- | --- |
| 1 | **create the issue**, body `spec.md`, each requirement's acceptance criterion a checkbox |
| 2 | **rename** `efforts/xxxx-<slug>/` to `efforts/<number>-<slug>/`, before the first commit, so the rename never appears in history |
| 3 | **create the effort branch** |
| 4 | **commit the effort's artifacts** as one `docs` commit |
| 5 | **push, and open a draft pull request** carrying the approach from `plan.md`, and each ticket's criteria as checkboxes — or **saying tickets are not yet cut**, never an empty list |

**The pull request exists from the first draft** because it is what the effort's
own artifacts land through, and because it is where the run will keep its memory
(`[[policies/execution]]`).

**Where the repository has a tracker, both objects are required**, and an effort
found short of either is opened rather than left as it is. **Where it has none,
rows 1 and 5 have nowhere to land**: rows 2 to 4 run unchanged, a local counter
supplies the number, and the effort is a branch a human merges
(`[[policies/execution]]`). Not asking is not how a repository ends up in the
second shape — look, and say which one this is.

### It asks once, and only here

**This is the one human moment in an effort.** It asks for two things in one
breath:

- **permission to push and open a public pull request**, with the exact strings
  it will write — issue title and body, branch name, pull request title;
- **the effort's `priority:`**, which is the human's and which no file implies.

*Why one ask: both are the human's, and both are needed at the same instant.
Asking twice is two interruptions where the work needs one, and this is the step
the whole design exists to make the last one.*

**A refusal stops the opening.** It does not slide to something the agent is
allowed to do instead — the spec stays local, unopened, and the run says so.

**With no tracker there is nothing public to ask about**, so the ask narrows to
`priority:` and the branch and its commit are made. It stays one ask.

### Afterwards

**Every later revision to `spec.md`, `plan.md`, `evidence/`, or `tickets/` is a
further `docs` commit** on the effort branch. Grilling, research, and planning
become visible in the pull request as they happen rather than as one drop at the
end.

**The issue body is rewritten as the spec changes.** It is the spec's projection,
not a copy taken once.

**So are the labels.** Both objects open at `status: backlog`, and accepting the
spec moves both to `status: ready` in the same step — `spec.md` still carrying
`status: accepted`, because the field is the source and the label is the
projection (`[[policies/execution]]`). Where either has been edited by hand, the
next run corrects **the label to match the file**, never the file to match the
label.

**`priority:` is set once, here, and never touched again.** It came from the
human, and re-deriving it would overwrite the only person who knows the answer.
The same holds for any flag that invites someone to act: `flag: discussion` goes
on while the spec carries open questions, and it is the human who takes it off.

**Every label comes from what this tracker already uses.** Read the list before
naming anything; where one has to be created, say so and say why
(`[[references]]`). **Nothing AEP sets names AEP.**

**Abandoning the effort closes both objects**, labelled `flag: wontfix`. An
abandoned draft is never left open: an open draft pull request reads as work in
flight to everyone who did not have this conversation.

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
anyone would know it worked; the material uncertainty was resolved in this
invocation rather than named for later; and the effort is open — one issue, one
branch, one draft pull request — or the human refused and that is said plainly.

## Next

`[[skills/plan]]` if it needs a technical approach, `[[skills/tasks]]` if it is
already clear enough to build. **Ambiguity is not a next step** — it was resolved
at step 7, in this turn.
