---
use-when: "this repository uses stacked changes and a branch must be created, restacked, or submitted"
---

# Reference — Graphite

**This file is yours.** Installed because Graphite configuration was detected.
Correct it where this repository differs.

## What changes when a repository stacks

`blocked-by` stops meaning *wait until that task is resolved* and starts meaning
**stack on top of it**. A task joins the frontier once its blockers are
**committed** — not merged, not resolved.

Two consequences, both accepted on the human's behalf, so say them out loud:

- **A stack belongs to one instance.** Restacking rewrites every descendant —
  other tasks' claims — so parallel work needs separate stacks off trunk.
- **A rejected review low in the stack invalidates every branch above it.** That
  is the trade for not waiting.

## Commands

```sh
gt log short                     # the stack as it stands
gt create -m "<message>"         # branch + commit, stacked on the current branch
gt modify                        # amend the current branch, then restack descendants
gt restack                       # after any history rewrite
gt submit --stack                # PUBLISHES — the human's call, never an agent's
```

**Never `git commit --amend` on a stacked branch.** A bare amend leaves every
descendant pointing at a commit that no longer exists; `gt modify` amends and
restacks together.

## Creating a stacked branch

An effort branch is created by `aep open`, which bases it on the current
branch when `stack: true` is set in `[[rules/version-control]]`. Register it
with the tool rather than letting the tool create and name it — two tools must
produce the same name or the branch stops working as a claim. Ticket branches
(`<effort>--<ticket>`) are never stacked: `aep dispatch` creates them and
`aep land` deletes them.

```sh
git switch <blocker-effort-branch>
node .aep/scripts/aep.mjs open <slug> --lane <lane>
gt track <effort>                # register the branch aep open created
```

## Referencing a task from a commit

On a stacking repository the commit **carries the closing keyword**: it reaches
the default branch only by merging its own branch's pull request, so the
cherry-pick hazard that bans the keyword elsewhere cannot arise
(`[[rules/version-control]]`).

## Failure handling

- A restack conflict can silently drop the work of a branch in the middle of the
  stack. After resolving, check that each branch still contains what it was
  supposed to.
- `gt submit` publishes. It is never run unasked.
