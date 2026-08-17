---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: uniform-reporting
blocked-by: [07]
---

# chore(dist): release 2.4.0, with the notice its frontmatter change requires

## Outcome

The release ships: the notice that tells a repository to declare `report:` on
its own skills, the regenerated adapter, the stamped artifacts, and this
repository's own tree reinstalled from the result.

## Acceptance Criteria

- [ ] `src/scripts/payload.mjs` gains one `NOTICES` entry with `since: '2.4.0'`,
      whose `check` names the field, both legal values, where it goes, and why it
      is required — an instruction, never a changelog entry.
- [ ] The notice is shown to a tree that precedes 2.4.0 and **not** to one at or
      past it, by the same predicate `MOVES` uses. Prove both.
- [ ] `MOVES` gains nothing. Nothing moved.
- [ ] `node src/scripts/adapters.mjs` regenerates the Claude adapter, and the
      committed adapter is not stale.
- [ ] `node src/scripts/release.mjs 2.4.0` runs. It stamps **only** the artifacts
      whose content changed; nothing is restamped by hand.
- [ ] `node src/scripts/verify.mjs` passes against the released distribution.
- [ ] This repository's own `.aep/` is reinstalled from `src/`, and
      `node .aep/scripts/validate.mjs` passes on the result.
- [ ] `node .aep/scripts/index.mjs` regenerates the index.

## Relevant areas

`src/scripts/payload.mjs` (`NOTICES` ~67 — the 2.3.0 entry is the shape),
`src/scripts/release.mjs`, `src/stamps.json`, `[[references/build]]`.

## Constraints

- **Never restamp by hand.** `aep:` is the release an artifact's content last
  changed in; a sweep destroys the only information the field carries and hides
  the defect the field exists to expose (`[[rules/authoring]]`).
- Never push and never publish (`[[rules/version-control]]`).
- The version is 2.4.0: a new required frontmatter field and a new policy, with
  nothing removed and nothing moved.

## Notes

The notice is the entire migration story for this effort. A repository-owned
skill without `report:` fails `validate.mjs` after the upgrade, deliberately —
so the notice must carry the exact one-line fix, not a description of the
change.
