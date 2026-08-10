---
owner: repository
title: feat(skills): configure carries the remaining mechanics, and names what needs nothing
status: resolved
blocked-by: [03, 09, 11]
part-of: mechanics
---

## Problem

Three of this effort's mechanics land in files a configured repository already has, and one lands in a file no repository has. None of them is reached by the generate step, because in each case the file exists and reads as complete.

- A repository's stage table was written before the precedence rule existed, so it may be missing guides its skills declare and nothing says whether that was deliberate.
- A repository's drift findings carry no consumption, and whether any given one has been healed is only answerable by reading the knowledge it falsified.
- A repository's marker carries one fact.
- The shipped roles gain a mode, and no repository holds them.

Left unwritten, each becomes a reader's inference from a file that merely looks shorter than the one they know. Worse, the three are not the same kind of work — one is safely repaired, one must not be, and one needs nothing at all — and a page that does not distinguish them invites a run that repairs the one that should have been reported.

## Outcome

The migration page and the audit step carry the three that need something, each stating which kind it is and why.

**The stage table is repaired.** It is derived from the skill defaults plus whatever the repository added, and the repository-specific rows are preserved for the same reason the mode-column row already preserves them — they are the part the template cannot know. A guide a skill declares and the row omits is surfaced rather than silently added, because an omission may have been deliberate and the new rule wants it recorded as such.

**Drift findings are reported, never repaired.** Whether a finding was healed is a question about knowledge elsewhere in the repository, and answering it by inference is exactly the guess the finding format exists to stop. Every unmarked finding stays unmarked, which reads as waiting — the safe default, and the behaviour every repository has today.

**The marker needs nothing**, and the page says so rather than staying silent. A marker carrying one fact means the tree is unknown, which is a defined state with a defined fallback, so it corrects itself the first time a stage advances it. Configure does not stamp a tree fact: stamping asserts that a drift read happened and was dealt with, and this stage did neither.

**The shipped roles are not part of it**, for the reason already recorded twice on that page — they belong to the plugin, and a repository gains them by updating it.

## Acceptance

- The audit repairs a stage table that predates the precedence rule, deriving it from the skill defaults and preserving repository-specific rows.
- A guide declared by a skill and absent from its row is surfaced in the plan rather than added silently.
- The migration page states that unmarked drift findings are reported and not marked, and gives the reason in terms of what marking one would require knowing.
- The page states that the marker needs no conversion, names the fallback that makes that true, and states why this stage does not write a tree fact.
- The page states that the shipped roles arrive with the plugin, citing the existing rows rather than restating their reasoning.
- Each of the three is labelled as repairing, reporting, or needing nothing, and no two are described in the same terms.
- A repository already carrying all of it is recognised as current and a re-run changes nothing.
- The suite asserts each row exists and that the repair-versus-report split is stated, with each guard confirmed to fail against its inversion rather than only its absence.
- The suite passes.

## Comments

"A repository already carrying all of it is recognised as current and a re-run changes nothing"
is met by construction rather than by an assertion of its own: re-deriving an already-correct
stage table changes nothing, leaving unmarked findings unmarked changes nothing, and the Marker
row does nothing by design. Adding a probe for it would have asserted `/configure`'s standing
idempotence rule a second time, which is the duplication the suite's own sweep exists to catch.
