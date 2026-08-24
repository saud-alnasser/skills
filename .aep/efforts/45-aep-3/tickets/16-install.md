---
status: resolved
blocked-by: [15, 01]
---

# feat(install): entrypoints and the label seed land on the way in

## Outcome

Install writes an entrypoint pointer for every runtime it targets, taking which file each runtime loads from the adapter target table rather than from prose. It offers the seeded label set where the repository carries only its tracker’s defaults, and creates only what is missing otherwise.

## Acceptance Criteria

- [x] Criterion 35: installing into a repository with no entrypoint leaves the canonical entry pointing at the bootstrap, plus one file per targeted runtime whose entire content is a pointer to it.
- [x] Criterion 36: installing or updating where a runtime entrypoint predates AEP leaves that file’s content intact with the pointer added and nothing else changed.
- [x] Criterion 37: a pointer file names the canonical entry and nothing under the protocol directory, and which file each runtime reads appears once, in the target table.
- [x] Criterion 11: install in a repository carrying only its tracker’s defaults offers the seeded set and, on acceptance, leaves the defaults gone; in a repository with its own labels it creates only what is missing, in that repository’s naming style, showing exact strings first.
- [x] The `install fixture` section of the suite asserts each of the above.

## Relevant areas

`src/scripts/install.mjs`, `src/scripts/adapters.mjs`, `src/scripts/payload.mjs`, `src/skills/install.md`, and the `install fixture` section of `src/scripts/verify.mjs`.

## Constraints

Files outside the protocol directory belong to the repository. Every write to a shared tracker is proposed with exact strings and approved before it happens.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

**Built.** `CANONICAL_ENTRYPOINT` in `contract.mjs`, an `entry:` on every row of `TARGETS`, `installEntrypoints()` in `install.mjs`, the rewritten entrypoint step and the new label-offer step in `skills/install.md`, and nineteen assertions in the `install fixture` section.

**Three cases, and the third is the one that matters.** A runtime that reads `AGENTS.md` gets nothing, because a pointer from a file to itself is a loop. A runtime whose entrypoint does not exist gets the pointer and only the pointer. A runtime whose entrypoint already exists gets the pointer appended and nothing else touched — that file may have carried instructions for years before AEP arrived, and it is none of the installer's business.

**Idempotence is by content, not by a marker.** A marker is a thing to maintain; checking for the canonical name is not. This repository's own `CLAUDE.md` proves it: the dogfood reinstall left it byte-identical, because it already pointed at `AGENTS.md`.

**The name appears once.** `CANONICAL_ENTRYPOINT` in `contract.mjs` is read by the target table and by the entrypoint seed's own `target`, so a rename moves both. The seed used to spell `AGENTS.md` as a literal.

Six fire-checks, each confirmed to have changed its subject before the run:

| Broken deliberately | Fired |
| --- | --- |
| the append branch replaced by an unconditional write | a runtime entrypoint that predates AEP keeps its content |
| the already-points-there guard forced false | a second run does not write the pointer twice |
| the pointer made to name `.aep/protocol.md` | a runtime entrypoint names nothing under the protocol directory |
| the seed target changed to a literal `ENTRY.md` | the entrypoint seed targets the canonical name |
| `entry:` removed from the claude target | every target declares which file its runtime loads |
| the exact-strings requirement softened in `install.md` | install shows the exact strings before creating anything |

**One fire-check found a defect in the guard rather than in the subject.** Removing `entry:` first aborted the whole section inside `path.join`, which reports as one failure and silently skips every assertion after it. The table check now runs before anything derives a path from it, and the derivation itself cannot throw. Re-run, the same perturbation fails by name and the section reaches its end.

**A `git checkout` mid-fire-check reverted uncommitted work in `payload.mjs`.** It was restored by re-applying the two edits, and the suite went back to green. Restoring a perturbed file by copy, never by checkout, is the only safe form when a file carries edits this ticket has not committed yet.

**Criterion 11 lands in the skill, not the script.** A script cannot propose a tracker write and wait for an answer, and every write to a shared tracker is proposed with exact strings and approved first. The script writes nothing to a tracker at all.
