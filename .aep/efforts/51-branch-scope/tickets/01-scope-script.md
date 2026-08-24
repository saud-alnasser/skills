---
status: open
---

# feat(scripts): the claim, the working set, and the isolation are computed

## Outcome

`.aep/scripts/scope.mjs` answers where a run is, from git alone. It prints the
efforts the branch's commits claim, the efforts the tree is touching now, the
isolation in force, and the base it measured against; and it checks the second
set against the first. It ships to every configured repository, which is one
entry in `PAYLOAD_SCRIPTS` and a regenerated manifest.

## Acceptance Criteria

- [ ] `scope.mjs read` prints `claim`, `working`, `isolation`, and `base` in the
      shape `[[efforts/51-branch-scope/plan]]` fixes, exiting 0 with a non-empty
      claim, 1 when unscoped, and 2 when git or the tree cannot be read
      (criterion 1).
- [ ] On a branch named `t3code/<hex>`, `read` prints `unscoped` before that
      branch has a commit of its own and resolves to the effort once it has one
      (criterion 2). **This pair is the point of the ticket:** it passes only if
      resolution reads content rather than the branch name.
- [ ] A branch whose commits touch two effort directories resolves to both, and
      `check` still passes (criterion 4).
- [ ] `scope.mjs check` exits 1 and lists every working-set path outside the
      claim, and exits 0 when the claim is empty (criterion 5).
- [ ] `read` reports `worktree` inside a linked worktree and `checkout` in a main
      one, and names the sibling worktree holding a given branch (criterion 7).
- [ ] `PAYLOAD_SCRIPTS` carries `scope.mjs` and
      `node src/scripts/manifest.mjs --check` exits 0 (criterion 11).

## Relevant areas

`src/scripts/scope.mjs` is new. `src/scripts/payload.mjs` holds
`PAYLOAD_SCRIPTS`; `src/scripts/contract.mjs` holds the generated path block and
is never hand-edited. Read `src/scripts/position.mjs` and
`src/scripts/frontier.mjs` first: they are the vocabulary, the exit-code
meanings, and the house style for a script that computes and prints.

## Constraints

- The resolution order is fixed in `[[efforts/51-branch-scope/plan]]` under
  `# Interfaces`, step by step. Implement that order; do not invent a shortcut.
- `git status --porcelain -z`. Without `-z` a path carrying a space or a
  non-ASCII character comes back quoted and is silently skipped.
- Normalise separators before comparing. Git prints POSIX separators and
  `path.join` produces backslashes on Windows, which is where this repository
  runs.
- Never read or write `position/marker.json`. Scope is derived from git; the
  marker is a different question and the separation is deliberate.
- Dependency-free ESM, no network, and a failure to answer exits 2 rather than
  throwing.

## Notes

Both git behaviours this rests on were verified rather than assumed, and the
transcript is in
`[[efforts/51-branch-scope/evidence/research/t3-code-worktrees]]`: git refuses a
second worktree on a checked-out branch and names the holder, and `--git-dir`
differs from `--git-common-dir` inside a linked worktree.
