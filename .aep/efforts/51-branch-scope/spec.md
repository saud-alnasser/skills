---
status: implemented
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

**The runtime names the branch, so reading the name is not enough.** t3 Code runs
a thread in its own worktree and generates the branch itself, as `t3code/<8 hex>`
(`[[efforts/51-branch-scope/evidence/research/t3-code-worktrees]]`). A rule that
recognises an effort by branch name resolves that to nothing and falls back to
unscoped, which is safe and buys nothing, on the runtime this effort was raised
for.

**Position cannot carry the answer either.** The marker holds no effort identity
today, and giving it one creates a second source of truth beside the branch that
can disagree with it. It is also weaker than it looks: gitignored state is per
**working tree**, so it collides between two agents sharing one checkout and does
not collide between worktrees, which is the opposite of a guarantee.

# Goal

Every invocation establishes which effort it is inside **before it acts**,
computed from the branch and quoted like any other computed answer. Threads
working one effort each cannot write another effort's artifacts, take another
effort's tickets, or carry another effort's commits into a new branch.

Where the runtime isolates threads in worktrees, AEP uses what that gives and
requires none of it. Where it does not, the same rules hold with a weaker
guarantee, and the run says which it is.

# Scope

- A computed branch-to-effort resolution that does not depend on who named the
  branch, with a stated answer for every branch including the ones resolving to
  nothing.
- Detection of the isolation actually in force, and what AEP reads from it where
  the checkout is a linked worktree.
- Every skill that operates on an effort consulting the resolution on entry and
  reporting what it got.
- What confinement forbids while a run is scoped, and what it deliberately
  allows.
- What happens when the invocation names one effort and the branch claims
  another.
- Where a new effort's branch is based, read from the repository rather than
  fixed by AEP.
- Uniqueness of a ticket branch name across efforts, which parallel threads turn
  from a tidiness question into a collision.
- `specs.md` amended in the same change, assertions in `verify.mjs`, and the
  seeded version-control and t3 Code references stating their halves.
- One correction travelling with this because planning found it: `[[skills/plan]]`
  contradicts `specs.md` about where the technical approach is written.

# Requirements

1. **Scope is computed, never judged.** A script resolves the checkout to the
   efforts it is working on, and the run quotes its output. No skill derives the
   answer from a branch name in prose.
2. **Resolution reads content first and the name second.** The efforts a branch
   touches relative to the default branch are what it is working on
   (`git diff --name-only <default>...HEAD -- .aep/efforts/`), because that is
   true whoever named the branch. Where the branch has no commits of its own, the
   name is matched against effort directories and ticket ids present on the tree.
   Where neither answers, the result is unscoped.
3. **Scope is a set of efforts, usually of one.** An empty set is unscoped and may
   take any effort, which is the ordinary state of the default branch and of a
   fresh runtime-named branch. A set of more than one is what a repository's own
   rule permits when a chain of efforts shares a branch, and it is not by itself
   an error.
4. **Ambiguity is a stop only where the run must pick one.** A run that must act
   on a single effort, given a scope set of more than one and no effort named,
   ends the turn listing the set. Nothing is guessed.
5. **A scoped run writes nothing belonging to an effort outside its set.** No file
   under `efforts/<other>/`, and no ticket of another effort taken. Reading is
   unrestricted. Source outside `.aep/efforts/` is untouched by this rule, since
   changing it is what the effort exists to do.

   **There are no exemptions**, including for a skill whose subject is the whole
   tree. A `prune` or `survey` run that would remove or edit another effort's
   artifact stops, names it, and belongs on an unscoped checkout, which is where
   a tree-wide subject belongs anyway. *Why no exemption list: an exemption is a
   second mechanism deciding how strong the first one is, and it is the copy that
   goes wrong.*
6. **A named effort outside the scope set stops on a dirty tree and switches on a
   clean one.** Clean means the run checks out the named effort's branch and
   proceeds; dirty means it ends the turn naming the scope, the named effort, and
   the uncommitted paths.
7. **The isolation in force is detected and reported, never required.** A linked
   worktree is distinguished from a main checkout by `--git-dir` differing from
   `--git-common-dir`. Where the checkout is a linked worktree, the sibling
   worktrees and the branch each holds are read from `git worktree list
   --porcelain`, so a claim held by another thread is reported with where it is
   held. Where it is not, the run states that the claim is advisory. **AEP never
   creates, names, or removes the runtime's worktree.**
8. **A ticket branch name is unique across efforts.** Ticket ids restart per
   effort, so two efforts each holding a ticket `03` produce one branch name for
   two claims. How uniqueness is achieved is the repository's to state in
   `[[rules/version-control]]`; that it must hold is AEP's.
9. **A new effort's branch base is read from `[[rules/version-control]]`.** Where
   the repository stacks, the new effort stacks on the current branch; where it
   does not, the base is the default branch's tip, whatever `HEAD` happens to be.
   The rule states which shape the repository is in, and `[[skills/specify]]`
   reads it rather than choosing.
10. **The resolved scope and the isolation appear in `Position`** in every turn
    report from a skill that operates on an effort, beside what that skill already
    verifies.
11. **The claim is defined in `specs.md`, asserted by `verify.mjs`, and stated in
    the seeds**, in the same change. `specs.md`'s description of position as
    "per-clone" is corrected to per working tree, which is what gitignored state
    actually is.
12. **`[[skills/plan]]` stops contradicting the specification it implements.** It
    says it "extends the same `spec.md`" and writes the approach "into
    `spec.md`", while `specs.md:443` puts the approach in `plan.md` beside it and
    `[[templates/plan.template]]` already says so. Carried here rather than left
    for a separate effort whose whole content would be three sentences, and
    stated as a requirement so it is reviewed rather than found in the diff.

# Acceptance Criteria

1. A script invocation prints the scope set for the current checkout and
   `unscoped` for a checkout resolving to none, with distinct exit codes for those
   two and for a failure to read the tree. A run quotes that output in its report.
2. On a branch named `t3code/<hex>` carrying one effort's commits, the script
   resolves that effort. On the same branch with no commits of its own, it prints
   `unscoped`. Both are asserted, because the second is the state a thread starts
   in.
3. On a branch matching no effort and touching none, `/implement <effort>` runs
   unchanged and the report says the run was unscoped.
4. A branch touching two efforts resolves to both. A run that must act on one,
   with none named, stops and the report's `Next` lists the set and the naming
   that would clear it.
5. From effort A's branch, an attempted write under `efforts/B/` stops the run and
   names the path. A read of `efforts/B/spec.md` from the same branch succeeds.
6. `/implement B` from effort A's branch with a clean tree checks out B's branch
   and proceeds; with an uncommitted change it stops, and the report names A, B,
   and the uncommitted paths.
7. Run from a linked worktree, the script reports the isolation as enforced and
   names the sibling worktree holding a given branch; run from a main checkout
   with no linked worktrees, it reports the claim as advisory. Both are asserted
   against a real worktree created and removed by the test.
8. Two efforts each carrying a ticket `03` produce two distinct branch names under
   the shipped seed's convention, and the suite fails any shipped surface that
   reverts to the bare form.

   *Narrowed by the human at close. The clause removed asked the suite to fail a
   consuming repository whose own rule produces a colliding name, which it has no
   standing to do: verification covers what ships and does not audit an installed
   tree, and AEP judges no repository's own written rules anywhere else.*
9. `/specify` from an effort branch in a non-stacking repository bases the new
   effort's branch on the default branch's tip, and no commit of the old effort
   appears in `git log <default>..<new>`. In a repository whose rule declares
   stacking, the new branch's parent is the current branch and the rule is quoted
   as the reason.
10. Every shipped skill that names an effort carries the scope and isolation lines
    in what it puts in `Position`, asserted over the shipped surfaces rather than
    checked by eye.
11. `node src/scripts/verify.mjs` passes, and every assertion added has been seen
    to fail against a tree with the guard's subject removed
    (`[[rules/authoring]]`).
12. `skills/plan.md` names `plan.md` as what it writes, no longer says it extends
    `spec.md`, and the suite fails if that sentence returns.

# Constraints

- **Branch naming belongs to the repository, and sometimes to the runtime.**
  `specs.md:218` assigns it to the repository; t3 Code assigns it to itself by
  generating one. Resolution must therefore work with no cooperation from the
  name, which is why content is the primary path and the name is the fallback
  rather than the reverse.
- **No new committed state and no new per-clone state.** The answer derives from
  the branch, the tree, and git's own worktree records, all of which already
  exist. Position keeps its current meaning and its current fields.
- **Worktrees are used where present and never required.** A worktree per thread
  is the runtime's choice, and AEP running under a runtime that gives none must
  behave identically apart from the strength of the claim it reports.
- **A detached `HEAD` names no branch and holds no claim** (`[[skills/implement]]`),
  so it resolves by content if it has any and otherwise to unscoped. The existing
  requirement that the branch is created before the first edit is what keeps an
  effort from being built from one.
- **The enforcement is git's, and it stops at the clone.** Two worktrees cannot
  hold one branch, verified rather than assumed
  (`[[efforts/51-branch-scope/evidence/research/t3-code-worktrees]]`). Two clones
  can. Nothing here may read as though the guard covers the second case.
- **Resolution costs one git invocation and must stay that cheap**, because it
  runs on entry to every skill that touches an effort.

# Out of Scope

- **Locking, leases, or arbitration between threads.** Where worktrees are in use
  git already refuses the second claim; where they are not, the branch is a
  convention and this effort does not turn it into a lock.
- **Creating, naming, or removing the runtime's worktree**, and renaming a branch
  the runtime generated. AEP reads what the runtime did and does not reach into
  it.
- **Requiring worktrees, or shipping one worktree per effort.** AEP's own
  `.aep/worktrees/` for sub-agent isolation is unchanged and unrelated.
- **A registry of active sessions**, in the position marker or anywhere else. The
  answer is derivable from git, and a second copy of a derivable fact is a copy
  that goes stale.
- **Changing how the position marker computes drift.** `head` and `tree` keep
  their meaning; only the word describing where the marker lives is corrected.
- **Tracker-side concurrency.** Two threads editing one issue or one pull request
  is a real problem and a different one.
- **Automatic rebasing, merging, or syncing between effort branches.**

# Assumptions

- t3 Code runs a thread in its own worktree, generating `t3code/<8 hex>` as the
  branch unless the human names one. **Whether that is the default or opt-in is
  not established** and the design does not depend on it
  (`[[efforts/51-branch-scope/evidence/research/t3-code-worktrees]]`).
- `efforts/` is committed, so a branch carries the effort directory it works on
  and resolution reads it from the branch being resolved. A newly opened effort is
  invisible from the default branch, which is correct rather than a gap.
- The default branch is discoverable per repository. Content resolution is stated
  against it, so a repository where it cannot be determined falls back to name
  matching and then to unscoped.

# Risks

- **A thread's first turn is unscoped, and that is when it opens the effort.** A
  fresh runtime branch touches nothing, so content resolution is empty and the
  name resolves to nothing. The guard engages only from the first commit onward,
  which is acceptable for `/specify` and would not be for `/implement`. The
  criteria pin both states so the gap is visible rather than discovered.
- **Over-confinement surfaces as a stop in ordinary work.** An effort superseding
  an earlier one, or a release stamping several, writes outside its set by design.
  A guard that fires often gets worked around, and a guard that is worked around
  is worse than none because it is believed.
- **Content resolution is only as good as the default branch it diffs against.** A
  stale local default branch, or a repository whose default is not what
  `origin/HEAD` says, resolves a branch to more efforts than it is working on.
- **The seed and this repository differ in shape** (per-task branches against
  per-effort branches), so a resolution written against one alone is wrong in the
  other. Both shapes are exercised, or the requirement is untested.
