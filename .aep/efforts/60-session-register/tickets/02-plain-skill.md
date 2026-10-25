---
status: resolved
blocked-by: [01]
---

# feat(skills): plain ships as the eighteenth skill and carries the controlled register's craft

## Outcome

A new sub-skill, `skills/plain.md`, published as `/aep:plain`, holds the worked
craft of the controlled register: worked word pairs, sketch patterns, the
option-set template in its picker and lettered forms, one brief, one return,
and one turn report. It governs nothing. The reporting policy links to it, and
the skill set is eighteen everywhere it is counted.

## Acceptance Criteria

- [x] Criterion 2: `src/skills/plain.md` exists, restates no MUST from the
      policy, and links to `[[policies/reporting]]`. The policy's "how
      controlled text reads" section links to the new skill by a wiki link. `SKILLS` in
      `contract.mjs`, `specs.md` §15 (count, sub-skill list, table row), §28,
      and §31, and the suite all say eighteen.
      Verified: `verify.mjs --section skills` passes "the reporting policy
      sends the controlled register's craft to skills/plain", "plain links to
      the reporting policy for its law", and "plain restates no MUST"; `--section
      'the specification'` passes "the specification and the payload name the
      same skills" and "specs.md states the skill count it lists" (18).
- [x] Criterion 3, the skill half: a worked pair, one word swapped for an
      approved word with nothing lost, and one word outside the vocabulary kept
      because no approved word carries its meaning.
      Verified: "plain carries a swap that loses nothing" (*utilize* to *use*)
      and "a word kept because no approved word carries it" (*stale*) pass.
- [x] Criterion 4, the skill half: a worked example of a domain or AEP term
      kept as a technical name.
      Verified: "plain carries a technical name kept exactly" (*claim*,
      *surface*, and a domain's *tenant*) passes.
- [x] Criterion 6, the skill half: at least one sketch in a fenced block, drawn
      with box-drawing characters in Excalidraw style.
      Verified: "plain carries a sketch drawn with box-drawing characters"
      passes; the skill ships a flow and a before-and-after.
- [x] `src/skills/help.md` has a row for the new skill, as a wiki link, and its `prose` row
      says public text.
      Verified: "skills/help routes to every shipped skill but itself" passes,
      and the `prose` row reads "write public text".
- [x] The adapters and the manifest are regenerated (`adapters.mjs`,
      `manifest.mjs`), and `/aep:plain` is in every committed target.
      Verified: `node src/scripts/adapters.mjs` wrote 19 claude and 15 opencode
      files, including `src/adapters/claude/skills/plain/SKILL.md` and
      `src/adapters/opencode/skills/aep-plain/SKILL.md`; `manifest.mjs` wrote
      65 paths. Those two directories are the only committed targets.
- [x] Criterion 11: `verify.mjs` asserts the eighteen-skill set, that `plain`
      states a posture and what it gives up, that it carries each worked item
      above, and that it restates no MUST. Each new assertion is seen to fail
      once with its subject removed.
      Verified: `node src/scripts/verify.mjs` fails only on the stamps of
      `policies/reporting.md`, `skills/help.md`, and `skills/plain.md`
      (expected until 07). 16 of 16 assertions fired under perturbation. Two
      ran SILENT first and were fixed: the skills section aborted on a
      shadowed `flat`, and the sketch check needed every sketch removed, not
      one. `plain.md` is 1097/1200 words.

## Relevant areas

`src/skills/plain.md` (new), `src/skills/help.md`, `src/scripts/contract.mjs`
(`SKILLS`), `src/scripts/verify.mjs` (skill set, posture list, the "exactly
seventeen" checks), `specs.md` §15, §28, §31, `src/adapters/`, the manifest in
`src/scripts/contract.mjs`. Frontmatter and body shape:
`[[efforts/60-session-register/plan]]`, under Interfaces.

## Constraints

- At most 1200 words in the body.
- Ships no STE text and no word list. Names ASD-STE100 only as the source, and
  says it is free from ASD (`[[efforts/60-session-register/evidence/research/ste100-licence]]`).
- Every worked example obeys the policy it illustrates, including the four
  prohibitions.
- As a stage inside another skill, it reports nothing; invoked on a text, it
  reports like `prose`.
