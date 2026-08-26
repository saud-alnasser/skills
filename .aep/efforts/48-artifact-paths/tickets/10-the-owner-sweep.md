---
status: resolved
blocked-by: [07]
---

# fix(payload): the retired owner field stops being described as live

## Outcome

Ten sites across eight shipped files describe `owner:` as a field an artifact carries. It was retired in 3.0.0 and ownership has been a fact about location since. They now say what is true, and the scan ticket 07 left red goes green — which is what verifies the sweep, rather than anybody reading ten diffs.

## Acceptance Criteria

- [x] Requirement 8: `node src/scripts/verify.mjs --section "retired fields"` passes. It was red on exactly these ten sites when ticket 07 landed, and no allowlist entry was added to make it green. — verified by the orchestrator: `26 passed, 0 failed`, against `25 passed, 1 failed` and `10 live claims` before the sweep. `RETIREMENT_DOCS` is unchanged and still asserted to hold two entries. **The green is load-bearing**, fire-checked by putting one of the ten back: restoring "Contexts are always `owner: repository`" to `context.template.md`, after confirming the sweep's sentence was gone, gives `1 live claims` naming that file and that sentence. Restored, and green again.
- [x] Requirement 8: **`skill.template.md` stops describing the field, and asserts nothing new in its place.** Its lede said a skill the repository adds is `owner: repository`; probing showed the validator rejects any file under `skills/` the release does not ship, for a skill and for a note alike, so a replacement claim about who owns one would be a second false sentence. The field's name goes and the contradiction is raised rather than papered over. — verified by the orchestrator. The lede is now "Copy to `.aep/skills/<name>.md`." and nothing else. **The first rewrite of this line was wrong and a probe caught it**: it said a release ships an exact set of paths and a file outside that set is yours, which `.aep/skills/scratch-owner-probe.md` falsified — "skills/ holds only what the protocol ships, and this release ships no such file". A second probe at `.aep/skills/plan/scratch-note-probe.md` returned the same. Both removed; `git log -S` puts that check in `6f72af5`, AEP 3 itself.
- [x] Requirement 8: `src/seed/rules/version-control.md` is corrected. A seed is written once into a consuming repository and never touched again by any upgrade, so a stale claim there has no route by which it is ever corrected, and it is the site that matters most. — verified by the orchestrator. It reads "and `rules/` is yours, so an upgrade will never overwrite it", which is the same guarantee stated by where the file sits rather than by a field nothing carries. The seeds arm of the scan is asserted non-empty, so its silence is a scanned surface rather than an unscanned one.
- [x] Requirement 8: each rewritten sentence says what replaced the field rather than deleting the claim, `skill.template.md`'s lede above being the one exception, where the claim itself is contested. Ownership is where a file sits, `[[policies/artifacts]]` states it, and a template that simply drops "always `owner: repository`" tells the reader less than it did before. — verified by the orchestrator across all ten. Four templates and the seed name the directory whose ownership answers the question — `contexts/`, `references/`, `rules/` — rather than a field; `protocol.template.md` says "`protocol.md` is the protocol's"; `install.md` and `prune.md` name the four directories the repository owns; `reviewer-standards.md` says "a protocol-owned file".
- [x] Sentences that changed shape still scan. Where removing the field left a line clumsy, the line is rewritten rather than left with a gap in it, and no rewrite demotes the point of the paragraph it sits in. — verified by the orchestrator by reading the diff at `-U2`. One rewrite was tightened on a second pass: `install.md`'s constraint had "which ownership fixes by where a file sits", a relative clause with no clean antecedent, and is now two sentences. `skill.template.md`'s note paragraph lost "declares no `mode` … and **no `report`**" — two more retired fields, named without their colons and so invisible to the guard — and keeps the live reason underneath, that a note is a stage of the run that reached it.
- [x] `node src/scripts/adapters.mjs` leaves the tree byte-identical, `node .aep/scripts/validate.mjs` reports no failures, and no section of the suite other than `stamps` is red. — verified by the orchestrator: `git status --porcelain` lists the nine edited sources and nothing under `src/adapters/` either side of the generator; `214 artifacts checked, no failures`; and the suite is `2094 passed, 29 failed` with all 29 in `stamps`, two more than before because `reviewer-standards.md` and `protocol.template.md` joined the files this effort has edited. Ticket 09 clears them.

## Relevant areas

`src/templates/context.template.md`, `protocol.template.md`, `reference.template.md`, `rule.template.md`, `skill.template.md`; `src/skills/install.md`, `src/skills/prune.md`; `src/agents/reviewer-standards.md`; `src/seed/rules/version-control.md`.

## Constraints

The scan is not touched. A sweep that edits its own guard is a sweep nobody verified, and the red-to-green transition is the whole evidence this ticket offers.

Nothing outside the ten sites moves. The files hold other prose about ownership that is already correct, and rewriting it would put the sweep's diff beyond what a reviewer can check against the guard's own list.

## Notes

`src/skills/install.md:171` is the one site where the stale reading may be defensible: "MUST preserve every existing `owner: repository` artifact. If any exist, this is an update." A 2.x tree does carry the field, and that is how the install skill tells an update from a fresh install. If that is what the sentence means it must say so, because a reader in a 3 tree finds no such artifact and concludes there is nothing to preserve.

The evidence, with every site quoted at its line, is `[[efforts/48-artifact-paths/evidence/research/retired-field-scan-corpus]]`.
