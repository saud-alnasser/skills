---
status: resolved
blocked-by: [08, 11, 12, 13, 17, 18, 19]
---

# chore(dist): release AEP 3.0.0

## Outcome

The distribution is cut at 3.0.0 and this repository is reinstalled from it, which is what exercises the migration before it reaches anywhere else.

## Acceptance Criteria

- [x] Criterion 46: the verification suite exits zero.
- [x] `release.mjs` sets the version of record with one write and updates the baseline.
- [x] The adapter is regenerated and is not stale.
- [x] This repository’s installed tree is rebuilt from the distribution and validates, with every repository-owned artifact preserved.
- [x] The changelog states what an upgrading repository has to know: the removed fields, the removed directory, the two removed skills, and the two classification mechanisms.

## Relevant areas

`src/scripts/release.mjs`, `src/scripts/adapters.mjs`, the changelog, and the installed tree.

## Constraints

Never restamp by hand. Cutting a release is one command, and the adapter is generated rather than edited.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

**Cut.** `release.mjs 3.0.0` from one argument, adapters and manifest regenerated rather than edited, this repository reinstalled from the distribution, index regenerated, validation clean at 142 artifacts, and the suite green at 1813 with exit 0.

**The release reaches four files and one command writes all four.** `specs.md`'s version line, `protocol.md`'s `version:`, the plugin manifest, and the newest changelog heading now have to agree, so a version set by hand in one of them fails rather than shipping. Nothing before this asked the four to match.

**The changelog is checked against what it has to say, not that it exists.** Every retired field by name, every directory this release stopped shipping, the two removed commands, both classification mechanisms, and the removal condition for the older one. Each check reads the entry for this release rather than the whole file, because every one of those subjects appears somewhere in the file's history and a whole-document search would pass on a release that said nothing. Two of the five fire-checks proved that: the first perturbation left the subject somewhere else in the entry and nothing failed, which is a green run on an unapplied perturbation. Redone with the subject actually gone, both fired.

**A landed effort is not asked to split its spec.** The `# Architecture` report was naming all nine of this repository's effort specs, eight of them finished. That is the same principle the tracker rule rests on: a landed effort is the record of what was built and reviewed, so splitting it rewrites the record to match a layout the work was never done under, and reports a conversion the repository has no reason to make on every upgrade it ever runs. `specsHoldingArchitecture` now skips `status: implemented`. Retired frontmatter is still named on a landed effort, and that is the right difference: dropping a field the contract no longer has changes nothing the record says.

**`aep-3` split, being the one effort still in flight.** `spec.md` keeps `# Problem` through `# Risks`; `plan.md` takes `# Architecture` through `# Technical Risks`, verbatim, no wording changed either side.

**The plan template was telling every reader to write illegal frontmatter.** It showed `status: draft`, which §8 makes legal on a spec and a ticket and nowhere else, so `validate.mjs` rejected the first plan written from it. Fixed to a `use-when`, with the reason in the file: an effort has one state, the spec declares it, and a plan declaring a second gives the effort two answers that can disagree.

**The dogfood is now an assertion rather than a habit.** A dry-run upgrade of this repository by the release it ships must report nothing to convert and nothing retired. This tree is the first one every release meets, and a release that would ask its own tree for a conversion is one that would ask everybody's.

Eight fire-checks, each confirmed to have changed its subject before the run:

| Broken deliberately | Fired |
| --- | --- |
| the landed-effort skip replaced with a status-present test | the upgrade asks no landed effort to split its spec |
| `status: draft` put back in the plan template | the plan template shows a use-when and no status |
| every mention of `report` taken out of the entry | the changelog names every retired field |
| every mention of `modes/` taken out of the entry | the changelog names every directory this release stopped shipping |
| the removed-commands paragraph reworded to say nothing | the changelog names the commands this release removed |
| the classifier paragraph reworded to say nothing | the changelog names both ways a tree is classified |
| the bootstrap's version set by hand | every place the release is written agrees |
| the architecture folded back into `aep-3`'s spec | this repository needs nothing converted by the release it ships |

**Two perturbations that proved nothing, and what they were replaced with.** Removing the words `and part-of` from the field list left `part-of` named in the sentence after it, and renaming the `modes/` heading left `.aep/modes/` two paragraphs down. Both ran green. A perturbation is only a fire-check once the subject is actually gone from what the assertion reads.

**The changelog gained the effort, not just the cut.** One invocation runs the effort rather than the wave, an effort is one issue and one pull request, `plan.md` is back, and the upgrade names what it will not convert. An upgrading repository cannot find any of that out by reading its own tree.
