---
status: resolved
blocked-by: [05]
---

# feat(verify): a skill's declared output is checked against the specification

## Outcome

`skills/plan.md` names `plan.md` as its output, and the suite is what keeps it that way. The check is driven from the specification's own skill table, so the next release that reassigns an output edits the table and the table then fails the skill.

## Acceptance Criteria

- [x] Requirement 10 / criterion 10: `skills/plan.md` names `plan.md` and no longer says it extends `spec.md`. Restoring the sentence that says it does fails `verify.mjs`, and the failure names the skill and the artifact it disagreed about rather than reporting an unmatched substring. Seen to fail before the correction and to pass after. — verified by the orchestrator. `node src/scripts/verify.mjs --section "skill output"` is `15 passed, 0 failed`. Fire-checked by putting the 2.x Output section back — ``The **same** `spec.md`, gaining whichever of these apply`` — after confirming the perturbation had actually removed the corrected text: `13 passed, 2 failed`, `skills/plan names plan.md, the artifact §21 assigns it` and `skills/plan names no artifact §21 assigns to another stage: assigned plan.md, also names spec.md`. Both name the skill and the artifact. Restored, `git status` clean, `15 passed, 0 failed`. **The sentence the assertion covers is the Output section's, not the lede's**: the corrected file still says "the technical approach behind a settled `spec.md`" in its opening, which is true, so no general rule can reach a lede without failing the corrected corpus. The plan scopes the check to `## Output` for that reason.
- [x] Requirement 10: the assertion is general. For every skill the specification's table names, that skill's `## Output` section names the artifact assigned to it and names no other effort artifact. — verified by the orchestrator. The loop runs over every row of the §21 spine table whose Writes cell names a backticked artifact, and the foreign-artifact set is derived from that same column rather than from a list beside it. `--verbose` shows it firing for four skills and three artifacts: `specify`/`spec.md`, `refine`/`spec.md`, `research`/`evidence/research/`, `plan`/`plan.md`. Fire-checked on a skill other than the one that drifted: pointing `skills/research.md`'s Output at `spec.md` gives `13 passed, 2 failed` — `skills/research names evidence/research/, the artifact §21 assigns it` and `assigned evidence/research/, also names spec.md`. Restored, tree clean.
- [x] Requirement 10: **the parse asserts a minimum row count before asserting anything about rows.** A parser that matches nothing returns an empty map and passes every row it does not have, which is a green run and a dead check. — verified by the orchestrator. Two guards sit ahead of the loop: the header is where the check reads it, and the table parses to at least eight rows, with a third asserting at least four of them assign a named artifact. Fire-checked by inserting a blank line after the separator row, which leaves the header intact and makes every row unreachable — the vacuous case exactly. Result: `1 passed, 2 failed`, `the spine table parses, with every stage the specification lists: parsed 0 rows, expected at least 8` and `the specification assigns a named artifact to at least four stages: 0 stages write a named artifact`. **Not one per-skill assertion ran**, which is what the guard exists to stop reading as a clean run. `specs.md` restored, tree clean.
- [x] The skill's step 7 sends the approach to `plan.md`, and its Output block points at `[[templates/plan.template]]` rather than reproducing the ten headings the template already holds. — verified by the orchestrator. Step 7 reads "**Write the approach** into `.aep/efforts/<effort>/plan.md`, using `[[templates/plan.template]]`". The Output block is now three sentences naming the file and the template and says what to do with the headings rather than listing them; `src/templates/plan.template.md` carries all ten, `# Architecture` through `# Technical Risks`. `node .aep/scripts/validate.mjs` is `212 artifacts checked, no failures`, so the link resolves. `node src/scripts/adapters.mjs` leaves the tree byte-identical.
- [x] `specs.md` is unchanged by this ticket except where the table's shape had to be made parseable. It is the authority here, and editing the authority to match the implementation is the inversion this effort exists to prevent. — verified by the orchestrator, **and one cell changed that this wording does not cover.** The §21 spine table was already parseable and its shape was not touched: `git diff origin/main..HEAD -- specs.md` leaves it byte-identical, and no hunk anywhere in the file was made to accommodate the check. The one change is §16's skill list, `plan` from "add technical detail to the same spec — HOW" to "establish the technical approach beside the spec — HOW". That is not the inversion the criterion guards: the cell contradicted §21's own normative sentence two hundred lines below it, nothing in `verify.mjs` reads it, and the correction moved the authority into agreement with itself rather than with the skill. Recorded in the run log and left for the reviewers at converge, who can revert it against this criterion's letter.

## Relevant areas

`src/skills/plan.md`, `src/scripts/verify.mjs`, and the skill table in `specs.md` as the input the check reads.

## Constraints

The correction follows the specification, not the other way round. Where the two disagree the skill is what moves.

No new frontmatter field. Declaring the output per skill was considered and rejected in `[[efforts/48-artifact-paths/plan]]`: AEP 3 removed six fields on the argument that each one's answer already lives somewhere else, and reversing that is its own change made explicitly, not a checking detail.

## Notes

The reproduction of the template's headings inside the skill is why this drifted rather than being noticed. `[[policies/artifacts]]` says a link is a relationship rather than a copy and that the summary is a second home that drifts first, and that is exactly what happened: the template moved to `plan.md` and its copy inside the skill did not. The fix removes the second home rather than updating it.

Binding the suite to a table's formatting is accepted brittleness. The alternative is a list of outputs maintained beside the specification, which is a second home for the same fact and would drift the way the skill did. The non-empty assertion is what keeps brittle from becoming dishonest.
