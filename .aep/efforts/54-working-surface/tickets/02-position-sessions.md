---
status: resolved
blocked-by: [01]
---

# feat(scripts): the marker records the sessions that stamped it

## Outcome

`position.mjs stamp` accepts a session identifier and records it in `sessions`,
the field the specification has declared since section 20 was written and nothing
has ever populated. The header stops calling the marker per-clone, which
contradicts that same section.

Nothing reads the field back to make a decision. It exists so that a shared
checkout says so to whoever reads it afterwards.

## Acceptance Criteria

- [x] `node .aep/scripts/position.mjs stamp --session <id>` records the
      identifier in `sessions`, and `read` prints it (requirement 5,
      criterion 5).
- [x] `stamp` with no `--session` preserves `sessions` exactly as today and
      changes nothing else about the marker, so every existing caller keeps
      working (requirement 6, criterion 5).
- [x] Two stamps carrying two identifiers are both present in one marker
      (requirement 5, criterion 6).
- [x] The marker carries no key beyond `head`, `tree`, and `sessions`. No effort,
      no tracker id, no working surface (requirement 7, criterion 10).
- [x] The header comment and `.gitignore`'s comment describe the marker as per
      working tree, and the string "per-clone" appears nowhere against it
      (requirement 8, criterion 7).
- [x] Nothing in the script branches on the contents of `sessions`
      (requirement 6, criterion 6).

## Relevant areas

`src/scripts/position.mjs`, its header comment and the `stamp` branch of `main`.
`.gitignore`, whose comment carries the same wording. `specs.md` section 20 for
the declared shape, written by ticket 01.

## Constraints

`sessions` entries append. Nothing prunes them: pruning would mean deciding a
session is dead, and a session identifier carries no liveness
(`[[efforts/54-working-surface/evidence/research/session-isolation-prior-art]]`).

The script stays dependency-free ESM run by a bare Node runtime
(`[[contexts/repository]]`).

`--session` is optional. A runtime that supplies no identifier must reach every
other guarantee in this effort unchanged (requirement 6).

## Notes

The existing comment in `stamp` says sessions are the caller's to manage, and no
caller has ever managed them. This ticket makes that sentence true rather than
removing it.
