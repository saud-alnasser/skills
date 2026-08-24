---
status: open
blocked-by: [07]
---

# chore(dist): the adapter is regenerated and this repository reinstalls its own tree

## Outcome

The generated surfaces match the payload they are generated from, and this
repository's own `.aep/` is the installation of the `src/` it now ships rather
than of the one it shipped yesterday. Nothing in this ticket is hand-written.

## Acceptance Criteria

- [ ] `node src/scripts/adapters.mjs` has been run and the committed adapters are
      current, which `verify.mjs` asserts by failing on a stale one
      (criterion 11).
- [ ] `node src/scripts/manifest.mjs --check` exits 0, so `contract.mjs`'s
      generated block lists `scope.mjs` (criterion 11).
- [ ] This repository's `.aep/` has been reinstalled from `src/`, and
      `node .aep/scripts/validate.mjs` reports no failure this effort introduced
      (criterion 11).
- [ ] `node .aep/scripts/index.mjs` has been run and `index.md` is current
      (criterion 11).
- [ ] `node src/scripts/verify.mjs` passes on the final tree (criterion 11).

## Relevant areas

`src/scripts/adapters.mjs`, `manifest.mjs`, `install.mjs`, and
`.aep/scripts/index.mjs`. `[[references/build]]` carries the invocations.

## Constraints

- **Every artifact here is generated. Never hand-edit one**, in `src/adapters/`
  or in `contract.mjs`'s generated block. A hand-edit passes review and is
  destroyed by the next regeneration, which is the worst of both.
- **Do not cut a release.** Stamping a version is a separate decision and a
  human's; this ticket makes the tree consistent and stops.
- `validate.mjs` currently reports one pre-existing failure, an empty
  `efforts/47-post-merge-labels/` directory belonging to another effort. Leave it.
  It is outside this effort's claim, which is the rule this effort is building.

## Notes

The reinstall is what proves the payload change works from the outside: a script
that ships correctly here and not into a fresh tree fails in the install fixture
first, in ticket 07, and in this one second.
