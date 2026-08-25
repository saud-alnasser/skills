---

---

# Question

How does the industry isolate concurrent agent sessions in one repository, what
does it put in per-session state files, and how does it decide a session is
dead?

# Sources

- **`anthropics/claude-code` issue #43730**, "Worktree lifecycle: auto-cleanup or
  reuse across sessions", opened 2026-04-05, closed as duplicate with no visible
  maintainer response. Read 2026-08-25. Primary: a bug report against the
  reference implementation of the pattern this effort proposes.
- **`github/copilot-cli` issue #3255**, "Stale `inuse.<pid>.lock` files left
  behind on unclean exit (SIGKILL / crashes)". Read 2026-08-25. Primary.
- Search results on git worktree practice for parallel agents, and on stale lock
  detection. Read 2026-08-25. **Secondary write-ups**, used for the shape of
  common practice and not relied on for any specific claim.
- `git worktree` documentation behaviour as reported by those sources, on the
  prune-during-add point. **Not verified locally**, see Not checked.

# Findings

**source** Worktree-per-session is the dominant isolation primitive for parallel
agents, and Claude Code ships it: every new session creates a worktree under
`.claude/worktrees/` with a generated directory name (#43730). AEP proposing the
same shape is convergent with practice rather than novel.

**source** That implementation leaks exactly as this effort's spec predicts.
From #43730: *"When the session ends, the worktree is left behind. Over
days/weeks, `.claude/worktrees/` fills up with orphaned directories."* The
secondary write-ups put a worktree at 1 to 12 GB, and one reports 9.82 GB
consumed in a 20 minute session on a 2 GB codebase.

**interpretation** The leak risk in `[[efforts/54-working-surface/spec]]` is not
hypothetical and is not avoided by care. It is the observed steady state of the
best-resourced implementation of this pattern.

**source** The same issue reports no reuse path: *"There is no way to tell Claude
Code 'use this existing worktree' or 'continue in the same worktree as last
session.' Every session starts fresh."*

**interpretation** Keeping a worktree on failure, which is this effort's chosen
removal policy, is only coherent if a later run can pick it up. Otherwise a
crashed run leaves its effort branch held by a worktree nothing will ever enter
again, and the branch is locked against the run that resumes the effort. A
resume path is therefore load-bearing rather than a convenience.

**source** Copilot CLI keys session state by uuid and claims it with a pid: state
lives at `~/.copilot/session-state/<uuid>/` and the claim is a file named
`inuse.<pid>.lock` (#3255).

**source** That claim fails open in the dangerous direction. From #3255: on
SIGKILL or crash the lock file *"persists indefinitely on disk. Future session
resumption attempts incorrectly interpret the stale file as evidence the session
remains active elsewhere, prompting users with unwanted 'Force resume?'
dialogs."*

**source** Its proposed remedies are signal trapping, which covers graceful exit
only; OS advisory locks via `flock(2)` or `fcntl(F_SETLK)`, which the kernel
releases on process death; and pid liveness checking to reclaim locks owned by
dead processes.

**interpretation** All three remedies derive liveness from something the
operating system owns. A session identifier by itself has no liveness property at
all: a uuid in a file cannot be distinguished from the same uuid left by a
process that died. The pid in Copilot's filename is what carries liveness, and
the uuid only carries identity.

**conclusion** A session identifier recorded in AEP's position marker is a
**diagnostic**, not a claim. It can explain a shared checkout after the fact and
it cannot prevent one. Anything that reads it as a claim reproduces #3255, where
every abnormal exit blocks the next run until a human clears a file.

**conclusion** The mechanism has to come from somewhere the OS or git enforces.
Git's refusal against a branch a worktree holds is that thing, established in
`[[efforts/54-working-surface/evidence/research/worktree-branch-exclusion]]`, and
it needs no liveness check because it is not a lease.

**source** Common practice reaps by deriving staleness rather than by reading a
state file: a worktree is treated as stale when its remote tracking branch is
gone after `git fetch --prune`. Secondary sources also report that git runs a
lightweight `worktree prune` during `git worktree add`, so records for
directories that no longer exist clear themselves on the next add.

**interpretation** If that prune behaviour holds, a runner that creates a
worktree per run reaps dead administrative records for free. It does **not** reap
a crashed run's directory, which still exists on disk and so is not stale by
git's test. Those are the two halves of the leak and only one is free.

# Conclusion

The shape is right and matches practice: a worktree per session for the
orchestrator, a worktree per task for children, integration by the orchestrator
alone.

Three corrections to the design fall out of it. **Session identity is a
diagnostic and must never be read as a claim**, or AEP reproduces a shipped bug
in Copilot CLI. **A resume path is required** by the decision to keep a worktree
on failure, because otherwise a crash locks the effort branch permanently.
**Cleanup is two problems**, the administrative record and the directory, and
only the first one solves itself.

# Not checked

- **Whether `git worktree add` really prunes**, and under what conditions. Taken
  from secondary sources and not run locally. It matters to the leak story and is
  cheap to verify at implementation time.
- **Whether a crashed run's held branch is actually unreachable**, or whether
  `git worktree repair` or a manual prune recovers it cleanly. Not exercised.
- **What Claude Code's `--worktree` does on exit today.** #43730 describes
  session-created worktrees being left behind, and one secondary source describes
  an auto-remove-if-unchanged behaviour. The two disagree and neither was tested.
  AEP does not depend on the answer, since it owns its own worktrees, but the
  disagreement is why neither is cited as fact above.
- **Whether any tool records the unit of work in its session state**, which is
  the question behind putting an effort or tracker id in position. Nothing found
  either way, so this is an absence rather than a negative result.
- **flock and fcntl behaviour on Windows**, which is this repository's platform.
  Named as a remedy in #3255 and not portable in the form given.
