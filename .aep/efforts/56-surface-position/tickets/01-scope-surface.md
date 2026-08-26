---
status: resolved
---

# feat(scripts): scope computes the surface a run stands in and the role it carries

## Outcome

`scripts/scope.mjs` reports two new fields, `surface` and `role`, in both `read`
and `read --json`. Two agents in two surfaces of one effort stop returning
identical answers. Nothing is stored, no exit code moves, and no other file
changes.

## Acceptance Criteria

- [x] Criterion 1: verified against this repository's own tree, not only the
      fixture. The orchestrator's surface reads
      `surface run at .aep/worktrees/56-surface-position/_run` /
      `role orchestrator of 56-surface-position`; the main checkout reads
      `surface main` / `role none`. Pinned by the assertion `the orchestrator and
      a child of one effort stop reading alike`, which requires both fields to
      differ and neither to be `unknown`.
- [x] Criterion 2: the `scope` section went from 13 to 18 assertions. Four shapes,
      four real worktrees. The two new ones carry **deliberately crossed branch
      names**, and the assertion checks the crossing is still in place before it
      tests anything, so a derivation reading the branch answers backwards rather
      than passing, and a later edit that un-crosses them fails loudly instead of
      testing nothing. `surfaceOf` is a pure function of paths and reads no
      branch at all.
- [x] Criterion 8: `the role moves no exit code, whether it resolves or not`. One
      pair of surfaces, one resolving and one not, each read unscoped and then on
      a claiming branch, asserting `1,1` and `0,0`. Both halves of the pair fire
      when an exit code is made role-dependent.

One assertion beyond the three criteria: `a nested .aep finds its own worktrees
directory, not the root`. The plan makes the non-hardcoded worktrees directory
binding and nothing else covered it.

## Relevant areas

`src/scripts/scope.mjs` — `isolationOf`, `parseWorktrees`, `resolveScope`,
`renderRead`, `renderJson`. `src/scripts/verify.mjs` — the `section('scope', ...)`
block, whose `run`, `fieldOf`, `git` and `write` helpers are what the new fixtures
extend.

## Constraints

- The field vocabulary and the render order are fixed in
  [[efforts/56-surface-position/plan]] under Interfaces. Do not invent names.
- **Build both sides of the path comparison from git output.** `resolveScope`
  carries a comment about 8.3 short names defeating `path.relative` on Windows;
  the plan's Technical Approach says which git commands supply each side and why.
  Never resolve either side against `process.cwd()`.
- `.aep/` is not always at the repository root. `resolveScope` already handles
  that through `--show-prefix`, and the worktrees directory is found relative to
  the same root rather than from a hardcoded `.aep/worktrees`.
- Normalise to forward slashes before comparing, as `effortOf` already does.
- Every assertion added here is seen to fail first against a perturbation that
  removed its subject ([[rules/authoring]]).

## Notes

`git worktree list --porcelain` lists the main worktree first, which is what makes
the main checkout findable without a second git call. `parseWorktrees` already
returns that list.

This ticket gates nothing textual, so it can run beside ticket 02.
