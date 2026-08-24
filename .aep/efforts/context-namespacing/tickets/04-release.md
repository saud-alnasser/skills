---
status: resolved
blocked-by: [03]
---

# chore(dist): release 2.5.0, with the notice the depth rule requires

## Outcome

The release ships the notice for the new limit, the regenerated adapter, the
changelog entry, the stamped artifacts, and this repository's own tree
reinstalled from the result.

## Acceptance Criteria

- [ ] `src/scripts/payload.mjs` gains one `NOTICES` entry with `since: '2.5.0'`
      naming the limit, both legal shapes, and what to do with a deeper file —
      move it up or flatten it. An instruction, never a changelog entry.
- [ ] The notice says the upgrade **will not** move the file: `contexts/` is
      repository-owned and an upgrade never edits what the repository owns.
- [ ] The notice is shown to a tree preceding 2.5.0 and **not** to one at or past
      it, by the same predicate `MOVES` uses. Prove both.
- [ ] `MOVES` gains nothing. Nothing moved.
- [ ] `CHANGELOG.md` gains a 2.5.0 entry saying what changed and why, with the
      upgrading note.
- [ ] `node src/scripts/adapters.mjs` regenerates the adapter, and the committed
      adapter is not stale.
- [ ] `node src/scripts/release.mjs 2.5.0` runs. It stamps **only** what changed;
      nothing is restamped by hand.
- [ ] `node src/scripts/verify.mjs` passes against the released distribution.
- [ ] This repository's `.aep/` is reinstalled, `node .aep/scripts/index.mjs` run,
      and `node .aep/scripts/validate.mjs` passes.

## Relevant areas

`src/scripts/payload.mjs` (`NOTICES` — the 2.4.0 and 2.3.0 entries are the
shape), `src/scripts/release.mjs`, `CHANGELOG.md`, `src/stamps.json`,
`[[references/build]]`.

## Constraints

- **Never restamp by hand.** `aep:` is the release an artifact's content last
  changed in; a sweep destroys the only information the field carries
  (`[[rules/authoring]]`).
- Never push, never publish (`[[rules/version-control]]`).
- 2.5.0: a new validation rule and a documented layout, with nothing removed and
  nothing moved.

## Notes

**Raised at planning, and the human may overturn it:** whether the notice is
worth shipping at all. Nothing ever told anyone that deep nesting was legal, so
the tree it rescues may not exist. It ships unless overridden, on the reasoning
that four lines is cheap and it is the only thing standing between a stranger and
a validator failure they cannot explain.
