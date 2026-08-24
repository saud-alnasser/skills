---
status: draft
---

# Problem

AEP declares that **the branch is the claim** in three places — `[[policies/execution]]`
("Claiming, before dispatching"), `specs.md:612`, and `[[skills/implement]]` step 2 —
and nothing ever reads it. No artifact, no script, and no prose defines which
effort an invocation is inside. The effort is supplied by the human, in the
conversation, on every invocation.

That holds while one session runs at a time. It stops holding the moment a
runtime puts several agent threads in one repository, one per branch, which is
how t3 Code is used against this repository today. Threads share no conversation,
so the only thing distinguishing them is the branch, which is the one fact no
skill consults.

What it costs, read from the artifacts rather than assumed:

| Where | What is broken |
| --- | --- |
| `[[skills/implement]]` step 1 | says an invocation that "named an effort, **or nothing**" takes the whole effort. `scripts/frontier.mjs` requires `<effort>` and exits 2 without one. The command written to carry a whole effort unattended has a documented input state it cannot resolve |
| `[[skills/tasks]]`, `[[skills/plan]]`, `[[skills/refine]]` | each opens with "the effort's `spec.md`" and never says which effort that is. In one session the human's last message decides; across threads there is no last message they share |
| `[[skills/specify]]`, opening step 3 | creates the effort branch from whatever `HEAD` is checked out. Invoked from a thread sitting on another effort's branch, the new branch carries that effort's unmerged commits, and its pull request diff holds work nobody asked to review |
| `efforts/<other>/tickets/*.md` | a thread that takes another effort's ticket writes `status:` into the file `frontier.mjs` schedules from, on a branch that effort will never merge |

**Position cannot carry the answer.** The marker is per-clone and gitignored, so
every thread in one clone shares one value, which is the collision rather than
the fix. Its `sessions` array has been in the schema since 2.x and nothing has
ever written or read it.

# Goal

Every invocation establishes which effort it is inside **before it acts**,
computed from the checked-out branch and quoted like any other computed answer.
Threads working one effort each cannot write another effort's artifacts, take
another effort's tickets, or carry another effort's commits into a new branch.

# Scope

- A computed branch-to-effort resolution, with a stated answer for every branch,
  including the ones that resolve to nothing.
- Every skill that operates on an effort consulting it on entry and reporting
  what it got.
- What confinement forbids while a run is scoped, and what it deliberately
  allows.
- What happens when the invocation names one effort and the branch claims
  another.
- Where a new effort's branch is based, read from the repository rather than
  fixed by AEP.
- `specs.md` amended in the same change, assertions in `verify.mjs`, and the
  seeded version-control rule stating its half.

# Requirements

1. **Scope is computed, never judged.** A script resolves the checked-out branch
   to an effort or to `unscoped`, and the run quotes its output. No skill derives
   the answer from a branch name in prose.
2. **A branch resolving to no effort is unscoped**, and an unscoped run may take
   any effort. The default branch is the ordinary case of this, so AEP never
   needs to know what the default branch is called.
3. **Ambiguity is a stop.** A branch resolving to more than one effort ends the
   turn naming the candidates. Nothing is guessed.
4. **A scoped run writes nothing belonging to another effort.** No file under
   `efforts/<other>/`, and no ticket of another effort taken. Reading is
   unrestricted. Source outside `.aep/efforts/` is untouched by this rule, since
   changing it is what the effort exists to do.
5. **A named effort contradicting the branch stops on a dirty tree and switches
   on a clean one.** Clean means the run checks out the named effort's branch and
   proceeds; dirty means it ends the turn naming both efforts and the uncommitted
   paths.
6. **A new effort's branch base is read from `[[rules/version-control]]`.** Where
   the repository stacks, the new effort stacks on the current branch; where it
   does not, the base is the default branch's tip, whatever `HEAD` happens to be.
   The rule states which shape the repository is in, and `[[skills/specify]]`
   reads it rather than choosing.
7. **The resolved scope appears in `Position`** in every turn report from a skill
   that operates on an effort, beside what that skill already verifies.
8. **The claim is defined in `specs.md`, asserted by `verify.mjs`, and stated in
   the seeded rule**, in the same change.

# Acceptance Criteria

1. A script invocation prints the effort for a checked-out effort branch and
   `unscoped` for a branch matching none, with distinct exit codes for those two
   and for a failure to read the tree. A run quotes that output in its report.
2. On a branch matching no effort, `/implement <effort>` runs unchanged and the
   report says the run was unscoped.
3. A branch whose name resolves to two efforts produces a stop, and the report's
   `Next` names both candidates and the checkout that would clear it.
4. From effort A's branch, an attempted write under `efforts/B/` stops the run and
   names the path. A read of `efforts/B/spec.md` from the same branch succeeds.
5. `/implement B` from effort A's branch with a clean tree checks out B's branch
   and proceeds; with an uncommitted change it stops, and the report names A, B,
   and the uncommitted paths.
6. `/specify` from an effort branch in a non-stacking repository bases the new
   effort's branch on the default branch's tip, and no commit of the old effort
   appears in `git log <default>..<new>`. In a repository whose rule declares
   stacking, the new branch's parent is the current branch and the rule is quoted
   as the reason.
7. Every shipped skill that names an effort carries the scope line in what it puts
   in `Position`, asserted over the shipped surfaces rather than checked by eye.
8. `node src/scripts/verify.mjs` passes, and every assertion added has been seen
   to fail against a tree with the guard's subject removed
   (`[[rules/authoring]]`).

# Constraints

- **Branch naming belongs to the repository** (`specs.md:218`; the seed ships
  `<task-id>-<slug>` while this repository uses `<effort>` and
  `<ticket-id>-<slug>`). Resolution matches against effort directories and ticket
  ids **present on the checked-out tree**, never against a pattern AEP fixes. A
  repository free to name branches its own way is a repository whose branch names
  AEP cannot parse by rule.
- **No new committed state and no new per-clone state.** The answer derives from
  the branch and the tree, both of which already exist. Position keeps its current
  meaning and its current fields.
- **It works when threads are separate clones, separate worktrees, or one
  checkout**, because the runtime chooses that and AEP does not.
- **A detached `HEAD` names no branch and holds no claim** (`[[skills/implement]]`),
  so it resolves to unscoped. The existing requirement that the branch is created
  before the first edit is what keeps an effort from being built from one.
- **The guard is advisory across clones.** Nothing here arbitrates two agents that
  both check out the same effort branch, and this must not read as though it does.

# Out of Scope

- **Locking, leases, or arbitration between threads.** The branch is a claim
  rather than a lock, and the failure being addressed is a run acting on the wrong
  effort, not two runs racing on the right one.
- **Making worktrees mandatory, or one worktree per effort.** A worktree's
  identity is the branch checked out in it, so mandating worktrees adds a
  requirement without adding an answer.
- **A registry of active sessions**, in the position marker or anywhere else.
  Rejected on the ground the problem statement rejects position on: per-clone
  state cannot distinguish threads in one clone.
- **Changing how the position marker computes drift.** `head` and `tree` keep
  their meaning; scope is a separate question reported beside them.
- **Tracker-side concurrency.** Two threads editing one issue or one pull request
  is a real problem and a different one.
- **Automatic rebasing, merging, or syncing between effort branches.**

# Assumptions

- t3 Code isolates threads by branch and may run them against one clone. The
  design does not depend on which, which is why the failures above are stated from
  the artifacts rather than from an observed t3 Code run.
- `efforts/` is committed, so an effort branch carries its own effort directory and
  resolution reads it from the branch being resolved. A newly opened effort is
  invisible from the default branch, which is correct rather than a gap.

# Open Questions

- Whether `prune` and `survey`, whose subject is the whole tree rather than one
  effort, are confined by requirement 4 or exempt from it. Stopping a `prune` that
  would remove another effort's stale artifact is defensible, and so is exempting
  it. The answer decides whether the guard is about the path or about the run's
  subject. **Settle before `/tasks`.**

# Risks

- **Over-confinement surfaces as a stop in ordinary work.** An effort superseding
  an earlier one, or a release stamping several, writes outside itself by design.
  A guard that fires often gets worked around, and a guard that is worked around
  is worse than none because it is believed.
- **A resolution matching too loosely claims the wrong effort silently**, which is
  this effort's own failure mode reintroduced one layer down. The id prefix is the
  anchor, and the ambiguity stop is what keeps a loose match from becoming a wrong
  answer.
- **The seed and this repository differ in shape** (per-task branches against
  per-effort branches), so a resolution written against one alone is wrong in the
  other. Both shapes are exercised, or the requirement is untested.
