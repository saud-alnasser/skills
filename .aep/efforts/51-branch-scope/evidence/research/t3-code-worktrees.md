---

---

# Question

When T3 Code runs a thread in its own git worktree, what does that give branch-derived scope that a plain checkout does not, and what does it take away?

# Sources

| Source | What it is | Read |
| --- | --- | --- |
| `src/seed/references/t3code.md` | this repository's own seeded reference, written when T3 Code support landed | 2026-08-24 |
| `pingdotgg-t3code.mintlify.app/guides/git-workflow` | T3 Code's own documentation, hosted on Mintlify under the vendor's account | 2026-08-24 |
| `mintlify.wiki/pingdotgg/t3code/configuration/project-scripts` | same documentation set, project scripts page | 2026-08-24 |
| search summaries of `t3codedocs.com` and `betterstack.com` | **secondary write-ups**, not the vendor | 2026-08-24 |
| local git probe, git 2.x on Windows | **observation**, run in a scratch repository and deleted | 2026-08-24 |
| `git worktree list --porcelain`, `git diff --name-only main...HEAD` in this repository | **observation** | 2026-08-24 |

# Findings

**source** T3 Code runs a thread in a worktree and automates the git commands. The vendor documentation distinguishes "worktree threads" from local-development threads, and describes creating one as an explicit action rather than describing it as the default. The human running this repository reports worktrees are the default in their use. *True of the documentation reachable on 2026-08-24; the vendor pages do not state a default either way.*

**source** The branch for a worktree thread is auto-generated as `t3code/<8 hex>`, and the human may instead "Specify a branch when creating the thread" (git-workflow guide).

**source** The worktree is placed inside the project at `.t3-worktrees/<thread-id>/` (git-workflow guide).

**source** A project script may carry `runOnWorktreeCreate`, "Whether to automatically run this script when creating a new worktree", and "For worktree-based threads, scripts run in the worktree directory" (project-scripts page). This repository's seeded reference already records the same fact from the other side: scripts declared in `t3.json` "run for everyone, including on worktree creation".

**source** T3 Code's own per-thread state lives in that worktree's gitignored `.t3` (secondary write-up quoting the vendor docs; not confirmed against a vendor page directly).

**observation** Git refuses a second worktree on a branch already checked out, and the refusal names where the claim is held:

```
fatal: 'effort-x' is already used by worktree at '.../wt-probe/w1'
```

**observation** A linked worktree is distinguishable from the main checkout without heuristics: `git rev-parse --git-dir` differs from `--git-common-dir` inside a linked worktree and matches it in the main one.

**observation** `git worktree list --porcelain` prints every sibling worktree with its path and its branch, machine-readable.

**observation** An effort resolves from a branch's *content*, with no dependence on the branch name:

```
$ git diff --name-only main...HEAD -- .aep/efforts/
.aep/efforts/51-branch-scope/spec.md
```

**interpretation** The auto-generated branch name defeats name-only resolution. `t3code/a1b2c3d4` matches no effort directory and no ticket id, so a default T3 Code thread resolves to unscoped: safe, since unscoped is exactly today's behaviour, and worth nothing, since the guard never engages on the runtime the effort was raised for.

**interpretation** Worktrees turn the branch claim from a convention into an enforced one, but only inside a clone. Two worktrees cannot hold one branch, so two threads in one clone cannot both be on effort A's branch. Two clones can, and no git mechanism prevents it.

**interpretation** The position marker is per **working tree**, not per clone. It is gitignored, so each worktree carries its own. `specs.md:618` calls it "per-clone", which is imprecise under worktrees and was written before this runtime existed.

**conclusion** Worktrees give three things AEP can use and does not have to require: an enforced claim inside the clone, a machine-readable list of the other threads and what each has claimed, and a per-thread position marker that no longer collides. They take away the assumption that a branch name is AEP's to read, because the runtime generates it.

# Conclusion

Branch-derived scope survives worktrees and is strengthened by them, provided resolution does not depend on the branch **name**. Content resolution answers the same question from the diff against the default branch, costs one git invocation, and is indifferent to who named the branch. Name matching remains worth keeping as the cheap path and as the only path available before a branch has any commits.

The isolation available is a property to be detected and reported, never required: a linked worktree inside a clone is an enforced claim, a plain checkout shared by two agents has no claim at all, and separate clones are advisory.

# Not checked

- Whether worktree threads are T3 Code's default or opt-in. The vendor documentation reachable here does not say, and the answer changes nothing in the design, which supports both.
- Whether T3 Code copies untracked or gitignored files into a new worktree. Not documented on the pages read. It matters only for `.env`-shaped files, and not for AEP, whose gitignored state is `position/` and `worktrees/`, both of which are correct to start empty.
- Whether `.t3-worktrees/` is added to `.gitignore` by T3 Code. If it is not, `position.mjs` folds it into the tree fingerprint through `git ls-files --others`, and every thread's tree reads as moved.
- The T3 Code version any of this is true of. The documentation pages carry no version, and the local probe says nothing about T3 Code at all.
