---
use-when: "building a ticket in this effort and the approach is not obvious from the spec"
---

# Architecture

The run holds its effort branch in a worktree it creates, and git supplies the
exclusion. Nothing arbitrates, nothing leases, and nothing checks liveness.

Two facts carry the whole design, both probed rather than assumed
(`[[efforts/54-working-surface/evidence/research/worktree-branch-exclusion]]`):

- A branch a linked worktree holds cannot be taken by `git worktree add`, reached
  by `git switch`, or moved by `git branch -f`, anywhere in the clone.
- `git switch --detach` inside the holding worktree releases that claim
  immediately, leaving the directory intact.

The second is what makes the lifecycle work. **Releasing the branch and removing
the directory are separate acts**, so the branch can be freed the instant the run
closes while the directory's fate is decided independently. Every earlier shape
conflated them and inherited a choice between leaking directories and losing the
post-mortem surface.

## What lost, and why

**Detached worktree plus compare-and-swap on the ref.** What the incident fell
back to, and named as an open question in the handoff. It exists only because the
branch was already held by the shared checkout, so no worktree could take it. Cut
the branch into the worktree at creation and the situation never arises. Strictly
weaker: a compare-and-swap is a check the run performs, and the refusal is a check
git performs.

**A lock file, lease, or session registry.** Rejected on primary evidence.
Copilot CLI keys session state by uuid and claims it with `inuse.<pid>.lock`; on
SIGKILL the lock persists and later runs read it as a live session
(`[[efforts/54-working-surface/evidence/research/session-isolation-prior-art]]`).
Every remedy proposed there derives liveness from the operating system. A session
identifier has none, so it cannot be a claim. Git's refusal needs no liveness
because it is not a lease.

**A state file naming the active effort, as Spec Kit does.** Spec Kit resolves
its feature from `.specify/feature.json` rather than the branch, and its own
reference gives the reason: to work "when not using Git branches". AEP has no
non-git mode, so the reason does not transfer, and `specs.md` section 20 forbids
the copy outright. Read as precedence rather than as a file, Spec Kit's practice
is derive-from-git-then-fall-back, which `scope.mjs` already implements.

**An unconditional worktree, even inside one the runtime gave.** Nests a worktree
in a worktree for no gain. Rejected by the human at grill.

**Gating on the isolation field's `enforcement`.** See Technical Risks: that
field answers a different question and is wrong for this one.

# Components

| Surface | Becomes responsible for |
| --- | --- |
| `src/skills/specify.md` | creating the effort branch **into** a worktree, in the opening step, rather than checking it out where the run stands |
| `src/skills/implement.md` | entering or creating the run's worktree at step 2, integrating children there, and running the close-out lifecycle |
| `src/policies/execution.md` | stating that a run claims a working surface as well as a branch, under "Claiming, before dispatching" |
| `src/scripts/position.mjs` | accepting a session identifier on `stamp`, recording it in `sessions`, and losing the word "per-clone" from its header |
| `specs.md` | section 18.1 gaining that detection drives an action, section 20 gaining the `sessions` semantics and keeping its prohibition |
| `src/scripts/verify.mjs` | one assertion per claim added |
| `.aep/rules/version-control.md` | this repository's answer on which branches are Graphite stack levels |
| `.aep/efforts/51-branch-scope/spec.md` | two Out of Scope bullets rewritten |

`src/scripts/scope.mjs` is **not** changed. It already prints everything the rule
needs.

# Interfaces

```
node .aep/scripts/position.mjs stamp [--session <id>] [--root <path>]
```

`--session` is optional. Supplied, the identifier is recorded in `sessions` with
the time it stamped. Omitted, `sessions` is preserved exactly as it is today, so
every existing caller keeps working unchanged.

The marker's shape, and nothing beyond it:

```json
{
  "tree": "...",
  "head": "...",
  "sessions": [{ "id": "...", "at": "..." }]
}
```

The run's worktree path is a convention, not a configured value:

```
.aep/worktrees/<effort>/_run          the orchestrator's surface
.aep/worktrees/<effort>/<ticket>      a child's, unchanged
```

# Data Model

`sessions` moves from a declared-and-empty array to a populated one. Entries
append; nothing prunes them, because pruning would require deciding a session is
dead, which is the judgement this design refuses to make.

**Nothing else is added to the marker.** `effort` is computed by `scope.mjs` from
the branch, and the working surface is the directory the marker already sits in.
Both would be second copies of derivable facts, which is what `specs.md` section
20 forbids and why.

# Technical Approach

The order is forced in two places and free elsewhere.

1. **`specs.md` first.** Sections 18.1 and 20 are the contract the rest is judged
   against, and `verify.mjs` asserts against the shipped surfaces rather than the
   specification, so writing the guards before the law they encode gets the
   dependency backwards.
2. **`position.mjs` and the per-clone wording.** Self-contained, no dependants,
   and it makes the drift correction reviewable on its own rather than buried in
   the behavioural change.
3. **`policies/execution.md`.** The governance sentence the skills reference.
   Before them, so neither skill points at a line that does not exist yet.
4. **`skills/specify.md` and `skills/implement.md`.** Independent of each other:
   one creates the surface, the other enters and closes it. They may be built
   concurrently and share no file.
5. **The two rewrites** of effort 51's boundaries and this repository's
   version-control rule. Independent of everything above and of each other.
6. **`verify.mjs` last**, because it asserts over the finished shipped tree, and
   each assertion is seen to fail first (`[[rules/authoring]]`).
7. **Reinstall**, so `.aep/` catches up with `src/` (`[[contexts/repository]]`).

# Integration

Touches `specs.md`, which this effort does not own in the ordinary sense: it is
the normative contract every consuming implementation is judged against. Section
18.1 currently says detection establishes only "the strength of the claim", and
requirement 2 makes it drive an action. That widening is the change most worth a
reviewer's attention.

Touches `.aep/rules/version-control.md` and `.aep/efforts/51-branch-scope/spec.md`,
both repository-owned rather than payload. Neither ships. Both are inside this
run's claim, so no confinement stop applies.

# Migration

**Existing installed trees keep working.** `--session` is optional, so a marker
without `sessions` populated is valid and an older caller stamps exactly as
before. No marker is rewritten on upgrade, and none needs to be: position is
re-derived rather than trusted (`specs.md` section 20).

**Efforts already in flight are not retrofitted.** Efforts 47 and 48 finish under
the shape they started in, per the spec's Out of Scope. Their existing worktrees
under `.aep/worktrees/` are untouched by this change.

**A run standing in a shared checkout when the new rule lands** creates its
worktree on its next invocation and continues there. Nothing has to be migrated,
because the effort branch moves to the new surface by being checked out in it.

# Testing Strategy

Every criterion in `spec.md` gets a named check. The git behaviours are asserted
against a real worktree the test creates and removes, as effort 51 did, rather
than described.

| Criterion | Checked by |
| --- | --- |
| 1 | a test creating an effort branch into a worktree, then asserting the three refusals by their git messages |
| 2 | `verify.mjs` over the shipped skills: the rule keys on `kind`, and the `worktree` case takes none |
| 3 | a replay: a second checkout attempts the incident's cherry-pick and reset, and both are refused by git |
| 4 | `verify.mjs` failing a shipped `policies/execution.md` with the working-surface sentence removed |
| 5 | `position.mjs stamp --session` round-tripped through `read`; a shape assertion rejecting any fourth key |
| 6 | two stamps, two identifiers, both present; plus a grep-shaped assertion that no shipped surface branches on `sessions` |
| 7 | grep for "per-clone" against the marker across the shipped tree |
| 8 | a link and content assertion over effort 51's rewritten bullets |
| 9 | `verify.mjs` asserting the version-control rule answers the Graphite question in one place |
| 10 | a shape assertion on the marker, plus the prohibition still present in `specs.md` section 20 |
| 11 | a test that runs the close twice: clean, then simulated failure, asserting the branch is checkout-able in both and the directory survives only the second |
| 12 | `node src/scripts/verify.mjs`, with each new assertion seen to fail first |

# Operational Considerations

**The close is two acts and the order matters.** Detach first, then remove. Detach
frees the branch even if removal fails, and removal is best-effort. A run that
reversed them would have nothing to detach.

**A run cannot remove the directory it is standing in**, particularly on Windows
where a process's working directory cannot be deleted. Removal therefore runs
from outside the worktree, or is left to the next run. Detaching, which is what
actually matters, has no such constraint.

**Dead administrative records clear themselves.** Git runs a lightweight prune
during `git worktree add`, so a runner creating a worktree per run reaps records
for directories that no longer exist. It does **not** reap a kept directory, which
is the half that stays a human's job.

**By hand, after a crash:** nothing. The kept worktree holds no branch, so the
effort resumes normally and the next run re-enters the directory.

# Technical Risks

**`enforcement` is computed wrong and this effort must not lean on it.**
`isolationOf` sets `enforcement: worktrees.length > 1 ? 'enforced' : 'advisory'`,
which describes the clone rather than the checkout. `specs.md` section 18.1
defines the distinction as inside-a-clone against across-clones, which
`worktree list` cannot answer. This is why the shared checkout printed
`checkout, enforced` while being the unprotected surface that caused the
incident. **The rule keys on `kind`**, which is computed correctly from
`--git-dir` against `--git-common-dir`. Fixing `enforcement` is a real defect and
is **not in this effort's scope**; it is raised at the close for the human to
place.

**A worktree per run is expensive.** Secondary sources report 1 to 12 GB per
worktree and one case of 9.82 GB in a twenty minute session. Build artifacts
multiply per surface. This lands hardest on repositories with large build caches
and is the strongest argument anyone will make against the change.

**The two shapes differ.** This repository puts each ticket on its own branch in a
Graphite stack; the seeded shape lands a wave on the effort branch. A close-out
written against one is wrong in the other. Both are exercised or requirement 12 is
untested, which is the trap effort 51 recorded and then hit.

**A runtime-owned worktree gets its branch switched.** Where the runtime supplied
the surface, AEP creates the effort branch there. Permitted by section 18.1, which
forbids only create, name, and remove. It would first show up as a runtime thread
whose pull request stops receiving commits while the work continues elsewhere.

**`git update-ref` still bypasses everything.** No design here closes it, and the
spec's Constraints say so. It would show up exactly as the incident did, and only
a script would do it.
