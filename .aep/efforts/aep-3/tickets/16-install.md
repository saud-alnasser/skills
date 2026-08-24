---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: open
part-of: aep-3
blocked-by: [15, 01]
---

# feat(install): entrypoints and the label seed land on the way in

## Outcome

Install writes an entrypoint pointer for every runtime it targets, taking which file each runtime loads from the adapter target table rather than from prose. It offers the seeded label set where the repository carries only its tracker’s defaults, and creates only what is missing otherwise.

## Acceptance Criteria

- [ ] Criterion 35: installing into a repository with no entrypoint leaves the canonical entry pointing at the bootstrap, plus one file per targeted runtime whose entire content is a pointer to it.
- [ ] Criterion 36: installing or updating where a runtime entrypoint predates AEP leaves that file’s content intact with the pointer added and nothing else changed.
- [ ] Criterion 37: a pointer file names the canonical entry and nothing under the protocol directory, and which file each runtime reads appears once, in the target table.
- [ ] Criterion 11: install in a repository carrying only its tracker’s defaults offers the seeded set and, on acceptance, leaves the defaults gone; in a repository with its own labels it creates only what is missing, in that repository’s naming style, showing exact strings first.
- [ ] The `install fixture` section of the suite asserts each of the above.

## Relevant areas

`src/scripts/install.mjs`, `src/scripts/adapters.mjs`, `src/scripts/payload.mjs`, `src/skills/install.md`, and the `install fixture` section of `src/scripts/verify.mjs`.

## Constraints

Files outside the protocol directory belong to the repository. Every write to a shared tracker is proposed with exact strings and approved before it happens.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
