---
status: resolved
blocked-by: [16]
---

# feat(update): a 2.x tree reaches 3 without losing what the repository owns

## Outcome

`update` recognises the layout by content: a tree carrying `owner:` is 2.x and is classified by the field; a tree without it is 3 and is classified by the manifest. The 2.x branch writes the 3 layout, splits any spec carrying an architecture section, and reshapes tracker artifacts for efforts still in flight only.

## Acceptance Criteria

- [x] Criterion 32: a 2.x tree becomes a 3 tree in which every repository-owned artifact is present and unedited, every spec carrying an architecture section has become a spec and a plan, and the report names every artifact it could not translate.
- [x] Criterion 33: a repository with one landed effort and one in flight has only the second reshaped, and the landed effort’s issues and pull request are byte-identical afterwards.
- [x] Criterion 34: every tracker write is shown as exact strings before any is made, and none is made if approval is refused.
- [x] Milestones entirely AEP’s are deleted; labels are not.
- [x] The 2.x branch states its removal condition in the file rather than in a commit message.

## Relevant areas

`src/skills/update.md`, `src/skills/update/migration.md`, `src/scripts/install.mjs`, and the `install fixture` section of `src/scripts/verify.mjs`.

## Constraints

This touches shared data and has one attempt per repository. A landed effort is a record and is never rewritten. The 2.x fixture this is tested against must be built here, because migrating this repository consumes the only real one.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

**Built.** A three-way classifier in `skills/update.md`, a `Coming from 2.x` branch in the same file, the `version:` false positive removed from `skills/update/migration.md`, `RETIRED_DIRS` in `payload.mjs`, `carriesRetiredFields()` and `specsHoldingArchitecture()` in `install.mjs`, and thirty-two assertions across the `skills` and `install fixture` sections.

**The classifier reads `owner:`, and reads nothing else.** A tree declaring ownership per file was written under the contract where that field decided ownership; a tree without it is classified by the manifest. The declared version is not consulted at all — a hand-edited bootstrap and one written before the field existed both declare something that is not evidence.

**The installer names two things and converts neither.** Retired frontmatter and a spec holding `# Architecture` each need a judgement: dropping a field decides its content is really elsewhere, and splitting a spec decides what is WHAT and what is HOW. A script that guessed would have edited a repository-owned file to do it. So it reports, and `[[skills/update]]` converts with a human — which is the whole of criterion 32's second half.

**`report.retired` holds paths; a retired directory does not go in it.** The list is printed through `path.relative`, so an entry carrying its own reason came out as garbage. Retired directories got their own list.

**The 2.x fixture is built in the suite**, per this ticket's constraint. It carries a bootstrap declaring 2.4.0, artifacts under `rules/`, `contexts/`, and `efforts/` declaring `owner:`, one landed effort and one in flight, a `modes/` directory, and a locally rewritten `policies/engineering.md` declaring itself the repository's. Every repository-owned file is compared byte for byte after the upgrade, not merely checked for existing: an upgrade that reformats somebody's file has edited it whatever it meant to do.

**One assertion could not fail, and was replaced.** `a repository file declaring the retired owner field is not replaced` asked about `rules/legacy-rule.md` — but nothing the payload ships lands in `rules/`, so no classifier is ever consulted about a file standing there. The perturbation that should have broken it did nothing. The replacement asks the same question where the classifier actually answers it, and points it the way the mistake goes: a 2.x artifact declaring `owner: repository` at a path the manifest names is replaced anyway, and reported.

**A defect this ticket surfaced, and fixed.** `index.mjs` still wrote `aep:` and `owner:` into every index it generated, so every tree AEP touches reported itself as written under an older contract on its next upgrade — in the very list this ticket added, naming a conversion the repository cannot make, since the next run of the script rewrites the file. The index now carries no frontmatter at all.

Seventeen fire-checks, each confirmed to have changed its subject before the run:

| Broken deliberately | Fired |
| --- | --- |
| the 2.x row taken out of the routing table | the upgrade routes every layout it can meet |
| `or a bare version:` put back as 1.x evidence | the 1.x migration no longer reads a bare version: as evidence |
| the removal condition replaced with "for as long as it is useful" | the 2.x branch states its removal condition in the file |
| labels made deletable like milestones | the 2.x branch deletes milestones entirely AEP's and keeps labels |
| the refusal softened to "skip the deletions" | the 2.x branch writes nothing at all on a refusal |
| step 2 returned to classifying by declared `owner` | the upgrade classifies ownership by the manifest rather than a field |
| the landed-effort rule replaced with "reshaped for consistency" | the 2.x branch reshapes no tracker artifact of a landed effort |
| `carriesRetiredFields` forced empty | the upgrade names every artifact still carrying retired frontmatter |
| `specsHoldingArchitecture` forced empty | the upgrade names every spec still holding an architecture section |
| the retired directory deleted rather than reported | a directory this release stopped shipping is not deleted |
| the `modes` declaration dropped from `RETIRED_DIRS` | the directory 3 stopped shipping is declared retired |
| `copyFile` made to spare anything declaring an owner | a 2.x upgrade writes the 3 bootstrap over the 2.x one |
| the installer made to write `plan.md` itself | the upgrade splits no spec by itself |
| the installer made to rewrite the frontmatter it lists | a 2.x upgrade leaves every repository-owned artifact byte-identical |
| `repositoryOwned` made to honour `owner: repository` | a path the manifest names is replaced whatever it declares it owns |
| the local-edit report suppressed | replacing a locally edited protocol file is reported rather than silent |
| frontmatter put back into the generated index | the generated index carries no frontmatter at all |

**Two assertions were passing on the wrong evidence.** The report checks searched the whole of the installer's output, and several of those paths are printed by other lists for other reasons — so they would have passed on a run that never mentioned the conversion. Both now read the entries out of their own list, by exact string.

**Criteria 33 and 34 land in the skill, not the script.** The installer writes nothing to a tracker, and a script cannot propose a write and wait for an answer. What the script can do is refuse to touch what it cannot translate, which is what its half of criterion 32 asserts.

**Left for the release ticket:** this repository's own nine effort specs still hold `# Architecture`, `aep-3` among them. The installer reports all nine on every dogfood run, correctly. Migrating them is the repository migrating itself, which belongs with the release rather than with the mechanism.
