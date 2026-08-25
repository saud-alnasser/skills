---

---

# Question

Which operations does git refuse against a branch that a linked worktree holds,
and is that refusal strong enough to be the working surface's whole exclusion
mechanism?

# Sources

- `git version 2.55.0.windows.3`, run on MINGW64_NT-10.0-26200, 2026-08-25.
  The thing itself, not a write-up.
- This repository's own clone at
  `C:/Users/saud-alnasser/Documents/workspace/skills`, which held eight linked
  worktrees at the time and so exercised the case rather than a clean fixture.
- `[[efforts/51-branch-scope/evidence/research/t3-code-worktrees]]`, which
  established that two worktrees cannot hold one branch. This extends that to the
  other paths into a ref.

# Findings

**observation** A branch created directly into a worktree is held by it from the
moment it exists. `git worktree add -b _probe-surface .aep/worktrees/_probe main`
created the branch and the worktree in one step, with no window in which the
branch existed unheld.

**observation** A second worktree on that branch is refused:

```
$ git worktree add .aep/worktrees/_probe2 _probe-surface
fatal: '_probe-surface' is already used by worktree at '.../_probe'
```

**observation** Another checkout in the same clone cannot switch to it:

```
$ git switch _probe-surface
fatal: '_probe-surface' is already used by worktree at '.../_probe'
```

**observation** The ref cannot be force-moved by name from another checkout:

```
$ git branch -f _probe-surface HEAD
fatal: cannot force update the branch '_probe-surface' used by worktree at '.../_probe'
```

**observation** The plumbing path is not covered. `git update-ref` moved the held
branch with no error and no warning:

```
$ git update-ref refs/heads/_probe-surface c9202f5
$ git rev-parse --short _probe-surface
c9202f5
```

**interpretation** The refusal is enforced where git resolves a branch name on
behalf of a working tree, and absent where a caller writes the ref directly. That
covers every command an agent or a human types in ordinary work, and none of the
ways a script can reach a ref deliberately.

**interpretation** The incident in `[[efforts/54-working-surface/spec]]` is
fully covered by the three refusals above. Step 3's cherry-pick required the
shared checkout to hold effort 48's branch, which `git switch` would have
refused. Step 4's `reset --hard` resolved a branch name in the shared checkout,
which could not have been the effort branch for the same reason.

**conclusion** Holding the effort branch in the run's own worktree, from
creation, is sufficient exclusion against every porcelain path within one clone.
It is not sufficient against `update-ref`, and it does not reach a second clone.

# Conclusion

Git refuses `worktree add`, `switch`, and `branch -f` against a branch a linked
worktree holds, and does not refuse `update-ref`. The guarantee is real, it is
free, and it stops at two named places. A design that holds the branch from
creation gets it; the detached-worktree-plus-compare-and-swap shape the incident
fell back to was forced by the branch already being held elsewhere and is
strictly weaker.

# Not checked

- **`git push` into the held branch of the same clone**, and whether a fetch
  refspec updating it is refused. Both are ref writes and are likely to behave
  like `update-ref` rather than like `switch`, but that was not run.
- **Whether the refusal holds on a non-Windows git**, or on versions before
  2.55. The messages quoted are from one version on one platform.
- **What happens when the holding worktree's directory is deleted without
  `git worktree remove`.** Git keeps the administrative record until pruned, so
  the branch is presumably still held by a worktree that is not there. This bears
  on the leak named in the spec's Risks and was not exercised.
- **Whether `gt` respects the refusal** when it restacks a branch a worktree
  holds. This repository stacks with Graphite, so a restack touching held branches
  is on the path and untested.
