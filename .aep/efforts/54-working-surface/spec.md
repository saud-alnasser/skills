---
status: implemented
---

# Problem

AEP says the branch is the claim, and #52 made that claim computable. It is
identity, and identity is not exclusion. Nothing stops two runs from writing
through the same working tree at the same time, and on 2026-08-24 two did.

Two sessions ran `/implement` in one clone, on efforts 47 and 48. Run A read its
position correctly at step 0 and then used the shared checkout as its integration
surface. Run B switched that checkout's branch twice while run A's operations
were in flight:

1. Run A checked out `artifact-paths` and dispatched three implementers into
   isolated worktrees. The children were never at risk.
2. Run B checked the shared checkout out to `post-merge-labels` and amended it.
3. Run A cherry-picked a ticket without re-reading the branch. It landed on
   effort 47's branch, a write outside run A's claim.
4. Run A read `git status`, saw a clean tree, and ran `reset --hard` to undo it.
   Run B had switched the checkout back in between, so the reset moved effort
   48's branch onto effort 47's commit.

Both refs were restored, and nothing was lost. What the incident establishes:

**Branch scoping did not fail.** `scope.mjs` was asked and answered correctly
every time. The claim was `48-artifact-paths` throughout and the run never took
another effort's ticket. This is not a defect in #52.

**The isolation signal already exists and no rule consumes it.** `scope.mjs read`
printed the isolation as the first command of the run, before the first write.
Nothing in `[[skills/implement]]` or `[[policies/execution]]` reads that field.

**The orchestrator is the one agent AEP never isolates.** `[[skills/implement]]`
step 2 puts every child in its own worktree and leaves the run itself standing in
whatever checkout it was invoked from. The effort branch is created there and
every wave lands on it.

**Position cannot tell two runs apart.** The marker is per working tree, which
`specs.md` section 20 already says, and it already names this exact failure: two
agents sharing one checkout hold one marker between them. During the incident it
reported `-> d88a17a` and then `-> 1a250cf` inside one minute of the same run,
because the other session was moving the checkout underneath. The marker carries
a `sessions` field, specified since that section was written as "the active or
relevant AEP sessions", and nothing has ever populated it. `position.mjs stamp`
preserves it under a comment saying sessions are the caller's to manage, and no
caller manages it.

The cost is not theoretical and not recoverable in general. The tree was clean,
so the damage was reversible from the reflog. The same race against uncommitted
work destroys it, and a reflog ages out.

# Goal

A run holds a working surface that no other run can write through, and it holds
it before its first write rather than after its first collision.

Git supplies the exclusion, so nothing new arbitrates. A branch held by a
worktree cannot be claimed by a second worktree, checked out by another checkout,
or moved by `git branch -f`. AEP stops leaving that guarantee on the table for
the one agent that most needs it.

Where a session identifier exists, the marker records which sessions stamped it,
so a checkout that is being shared says so to anyone reading it afterwards. That
is a diagnostic and not a second guard: the exclusion is git's, and a session
identifier is not something anything should act on.

# Scope

- The orchestrator taking its own worktree, and holding its effort branch in it
  from the moment the branch exists.
- The condition under which it does so, read from the isolation field
  `scope.mjs` already computes.
- `[[policies/execution]]` naming the working surface as something a run claims,
  beside the branch.
- The position marker recording the sessions that stamped it, filling a field the
  specification already declares and nothing has ever populated.
- The lifecycle of the run's own worktree: when it is created, when a later run
  re-enters it, when the branch claim is released, and when the directory goes.
- The lifecycle of a ticket branch, which is the same question one level down and
  was left unanswered by the tickets that created them.
- Correcting the shipped description of position as per-clone, which contradicts
  `specs.md` section 20.
- Two boundaries in `[[efforts/51-branch-scope/spec]]` that this change
  contradicts, rewritten here rather than left standing.
- This repository's own rule stating which branches are stack levels, carried
  because three implementers independently escalated on the ambiguity in one run.
- `specs.md` amended in the same change, with assertions in `verify.mjs`.

# Requirements

1. **The run holds its effort branch in its own worktree.** The effort branch is
   created directly into a worktree rather than checked out in the surface the
   run was invoked from, so the shared checkout never holds it and git's refusal
   applies from the moment the branch exists.

2. **The worktree is taken always, except where the run is already isolated.**
   Where `scope.mjs` reports isolation `worktree`, the runtime already gave the
   run its own surface and AEP takes no second one. Where it reports `checkout`,
   the run takes one. This is the rule that consumes the isolation field, and it
   is unconditional on siblings: a reading of who else is in the clone can be
   correct and stale a second later, which is the race this exists to lose safely.

3. **The shared checkout is never an integration surface.**
   `[[skills/implement]]` integrates each returning child into the effort branch
   inside the run's own worktree. The line that the orchestrator is the only
   integrator gains the place the integrating happens.

4. **`[[policies/execution]]` names the working surface as a claim.** Claiming,
   before dispatching, currently says the branch is the claim, which was written
   for one run per clone. A run claims a working surface as well as a branch, and
   a worktree is how it holds one.

5. **The marker records the sessions that stamped it, and gains no other field.**
   `sessions` carries the session identity that field was specified for and has
   never held. More than one entry against one marker is what says a checkout is
   being shared. Nothing else is added: the effort is computed from the branch,
   and the working surface is the place the marker already sits, so both would be
   second copies of facts that are already derivable.

6. **The session identifier is supplied by the runtime, and it is a diagnostic
   rather than a claim.** The agent knows its own session identity because its
   harness generated one, and a script cannot discover it agent-agnostically, so
   `position.mjs` accepts it and records it. **Nothing reads it to decide whether
   to proceed.** A session identifier has no liveness: it cannot be told apart
   from the same identifier left behind by a process that died, which is a shipped
   bug in Copilot CLI where a stale lock reads as a live session
   (`[[efforts/54-working-surface/evidence/research/session-isolation-prior-art]]`).
   The exclusion is git's, and it needs no liveness because it is not a lease.
   Where a runtime supplies no identifier the field stays empty and every other
   guarantee here is unaffected.

7. **Position still MUST NOT carry which effort a run is inside.** `specs.md`
   section 20 forbids it because effort identity is computed from the branch and a
   copy here is a second source of truth. Session identity is admissible precisely
   because it is the opposite case: it is not derivable from git, so recording it
   creates no second copy of anything. Spec Kit resolves its active feature from a
   state file rather than the branch, and its own documentation gives the reason
   as working "when not using Git branches"; AEP has no non-git mode, so the
   reason does not transfer and the state file is not adopted.

8. **The shipped description of position stops saying per-clone.**
   `src/scripts/position.mjs` opens by calling the marker per-clone operational
   state and `.gitignore` carries the same word, both contradicting `specs.md`
   section 20, which effort 51 corrected and left these two behind.

9. **The boundaries this change contradicts are rewritten in it.**
   `[[efforts/51-branch-scope/spec]]` declines "requiring worktrees, or shipping
   one worktree per effort", saying AEP's own `.aep/worktrees/` is unchanged and
   unrelated, and separately declines "a registry of active sessions, in the
   position marker or anywhere else". The first is narrowed to what it was
   actually about, that scope resolution never requires a worktree of the runtime.
   The second is superseded: it contradicted `specs.md` section 20, which had
   carried the `sessions` field the whole time.

10. **This repository states which branches are stack levels.** All three
    implementers in one wave independently asked whether to track their ticket
    branch in Graphite, and all three declined and escalated. Three agents
    reaching one ambiguity is an underspecified rule.
    `[[rules/version-control]]` says stack levels are tracked and ticket build
    claims are not, or says the opposite, but says it.

11. **`specs.md` is amended in the same change and `verify.mjs` asserts every
    claim added**, each assertion having been seen to fail against a tree with its
    subject removed.

12. **The run's worktree has a stated lifecycle, and releasing the branch is
    separate from removing the directory.** It is created when the effort branch
    is, re-entered by a later run on the same effort rather than duplicated, and
    at the close the branch claim is released by detaching the worktree, which
    frees the branch for a human to check out immediately. The directory is then
    removed on a clean close and kept on a failure, so there is something to
    inspect after exactly the runs worth inspecting. **A kept worktree never holds
    a branch**, so a crashed run cannot lock an effort against its own
    resumption.

13. **A ticket branch and the worktree holding it are released once its work
    reaches the effort branch.** It is a build claim, held so git refuses a second
    run the same ticket, and it holds nothing the moment the orchestrator has
    integrated it. The directory goes with the branch: releasing one and leaving
    the other is how a clone fills with worktrees whose branches no longer
    exist. Nothing shipped
    says what becomes of one, so runs leave them behind: twelve branches whose
    every commit is already in the effort branch, plus stacking metadata
    describing levels that will never be reviewed or merged on their own.

    **The effort branch is the reviewable unit, and a ticket branch is not.**
    That follows from `[[policies/execution]]` allowing exactly one pull request
    per effort: a branch that is integrated rather than merged is not a level of
    anything. Where this repository's rule says otherwise, the rule is corrected
    here.

# Acceptance Criteria

1. A run that creates an effort branch produces a worktree holding it, and
   `git worktree list` names the branch against that path. In the same clone,
   `git switch <effort>`, `git worktree add <path> <effort>`, and
   `git branch -f <effort> HEAD` each fail with git's "already used by worktree"
   or "cannot force update" message. All three are asserted rather than described.

2. With `scope.mjs` reporting isolation `worktree`, a run creates no second
   worktree, and the report says which surface it is using and why it took none.
   With it reporting `checkout`, a run takes one. Both states are asserted.

3. Replaying the incident, a second checkout in the clone cannot reach the effort
   branch by any porcelain path while the run holds it. The cherry-pick of step 3
   and the reset of step 4 are both refused by git rather than by an AEP check.

4. `[[policies/execution]]` states that a run claims a working surface, and
   `verify.mjs` fails a shipped tree where that sentence is absent.

5. `node .aep/scripts/position.mjs stamp` with a session identifier records it in
   `sessions`, and `read` prints it. Stamping without one leaves the field empty
   and changes nothing else about the marker. The marker carries no field beyond
   `head`, `tree`, and `sessions`, and `verify.mjs` fails a shipped tree that adds
   one.

6. Two stamps from two session identifiers against one marker are both visible in
   it, which is the state that says a checkout is being shared. No shipped surface
   branches on the contents of `sessions`, asserted by the suite, because a
   session identifier carries no liveness and a run that gated on one would block
   on a crashed session's leftovers.

7. Grepping the shipped tree for "per-clone" against the marker returns nothing,
   and `verify.mjs` fails if it returns.

8. `[[efforts/51-branch-scope/spec]]` no longer declines what this effort builds,
   and its rewritten bullets say what they still cover. No effort in the tree
   declines something another effort delivers.

9. `[[rules/version-control]]` answers, in one place, whether a ticket branch is
   tracked in Graphite. An implementer brief that reaches the question finds the
   answer without escalating.

10. No shipped surface writes an effort, a tracker id, or a working surface into
    the marker, asserted over the shipped tree rather than checked by eye. The
    prohibition in `specs.md` section 20 is still stated there after the amendment.

11. A run whose effort already has a worktree at the conventional path re-enters
    it rather than creating a second, and stops naming the paths where that tree
    is dirty. After a clean close the effort branch is checked out successfully
    from the main checkout, proving the claim was released. After a simulated
    failure the directory still exists and the branch is still free.

12. `node src/scripts/verify.mjs` passes, and every assertion added has been seen
    to fail against a tree with the guard's subject removed
    (`[[rules/authoring]]`).

13. The shipped close says a ticket branch and its worktree are both released
    once the work is in the effort branch, and the suite fails a tree where either
    instruction is absent. A finished effort leaves one branch behind, its own,
    and no worktree of its own, verified against this effort itself
    (requirement 13).

14. A run's own surface is removed rather than only released: the close performs
    the removal from outside that directory, and the suite fails a shipped close
    that says removal is impossible rather than saying where it is done from.
    Nothing reaps another run's surface, and the suite fails a shipped tree that
    tells a run to (requirement 12).

15. The shipped seed carries the same worktree invocations as this repository's
    own reference, so a repository installing this release does not receive a
    reference contradicting the protocol in it (requirement 11).

16. A shipped surface tells the run to pass its session identifier to
    `position.mjs stamp`, so `sessions` is populated in an ordinary run rather
    than only in the suite (requirement 6).

# Constraints

- **The exclusion is git's, and it stops at porcelain.** Verified rather than
  assumed: `git switch`, `git worktree add`, and `git branch -f` are all refused
  against a branch a worktree holds, and
  `git update-ref refs/heads/<branch> <sha>` moved it silently. Nothing here may
  read as though the guard covers the plumbing path, or the second clone.

- **AEP never creates, names, or removes the runtime's worktree.** Carried
  forward from effort 51 and unaffected. What this change adds is AEP's own
  worktree under `.aep/worktrees/`, which AEP already creates for children.

- **Agent-agnostic, so session identity arrives from outside.** AEP has no way to
  ask a harness what session it is. The identifier is passed in or the field is
  empty, and no guarantee here depends on it being filled.

- **Position stays lightweight and stays out of the way.** It is operational
  state, not a database and not a source of truth (`specs.md` section 20). If it
  conflicts with the repository, the repository wins.

- **`src/` is the source and `.aep/` is this repository's installed output.**
  Changes land in `src/` and reach `.aep/` by reinstalling
  (`[[contexts/repository]]`).

- **A worktree per run costs setup and disk.** The design has to say what removes
  one, or the guard that prevents a collision leaks directories until somebody
  turns it off.

# Out of Scope

- **Requiring a worktree of the runtime.** This is effort 51's boundary and it
  still holds, narrowed to what it was about: scope resolution behaves identically
  where the runtime gives no worktree, and reports a weaker claim. What changes is
  that AEP's own runner takes one of AEP's own.

- **Locking, leases, or arbitration.** Beyond what git already refuses, nothing
  is invented. A run that finds a claim held reports it and stops, as it does
  today.

- **Cross-clone exclusion.** Two clones can hold one branch and git will not stop
  them. Out of reach and not attempted.

- **Effort identity in the position marker.** Forbidden by `specs.md` section 20
  and restated as requirement 7 so that this change is not read as opening the
  door.

- **Changing how drift is computed.** `tree` and `head` keep their meanings and
  their comparison is untouched.

- **Reaping another run's abandoned worktree.** A run removes its own. Deciding
  when somebody else's is dead is a different problem and a worse one.

- **Tracker-side concurrency.** Two sessions editing one issue or one pull
  request is real and is not this.

- **Retrofitting the two efforts in flight.** Efforts 47 and 48 finish under the
  shape they started in.

# Assumptions

- The incident is accurate as the handoff records it. The reflog it quotes has
  aged past re-reading, so the account is taken as written.

- A harness that runs one agent session exposes an identifier for it. Claude Code
  does. Whether every supported runtime does is not established, which is why
  requirement 6 makes the field optional rather than load-bearing.

- `.aep/worktrees/` is an acceptable home for the run's own surface. It is
  gitignored, it is where AEP already puts children, and nothing else claims it.

# Risks

- **A guard that litters gets turned off.** One worktree per run, every run,
  including solo ones, leaves directories behind whenever a session dies. The
  removal story is load-bearing rather than a detail.

- **Overclaiming the guarantee.** `update-ref` bypasses it and a second clone
  ignores it. Text that reads as though the working surface is inviolable is worse
  than text that names the two holes, because it is believed.

- **`sessions` has no machine consumer, deliberately.** Requirement 6 forbids
  anything reading it to decide, so its only reader is a person doing a
  post-mortem. That is the correct design and it is also exactly how the field
  came to be empty for a whole major version. If nothing ever reads it, the honest
  outcome is to remove it rather than carry it a second time.

- **A runtime that linked a pull request to its own branch.** Where the runtime
  supplied the worktree, AEP switches it to the effort branch, and a runtime
  tracking `t3code/<hex>` sees that branch stop moving. Permitted by `specs.md`
  section 18.1, which forbids only creating, naming, and removing, and not
  observed here. It would surface as a thread whose pull request goes quiet while
  the work continues.

- **The two shapes differ.** This repository puts a ticket on its own branch and
  the seeded shape puts a wave on the effort branch. A working-surface rule
  written against one is wrong in the other, which is the trap effort 51 recorded
  and hit.
