---
status: resolved
blocked-by: [03]
---

# feat(skills): prune's proposal and the UI prototype's pick are option sets

## Outcome

Converge round 1 found two more shipped files that put a choice to the human:
`skills/prune.md`, whose proposal asks the human to approve each candidate, and
`skills/prototype/ui.md`, whose one question asks the human to pick a variant.
Both now link to the option-set section of `[[policies/reporting]]`, as the
eight files of ticket 03 do.

## Acceptance Criteria

- [x] Criterion 7: `skills/prune.md` puts its proposal to the human as an
      option set, by a link to `[[policies/reporting]]`.
      Verified: "skills/prune.md puts its choice as an option set, linked to
      the policy" passes; "Apply only what the human approves" is unchanged.
- [x] Criterion 7: `skills/prototype/ui.md` puts the pick between variants as
      an option set, by a link to `[[policies/reporting]]`. The variants stay
      switchable in the running screen; only the question changes.
      Verified: "skills/prototype/ui.md puts its choice as an option set,
      linked to the policy" passes.
- [x] Criterion 8: neither file restates what an option set holds.
      Verified: "the option-set rule and its fallback are stated in the policy
      and nowhere else" passes.
- [x] Criterion 11: the option-set link assertion in `verify.mjs` covers both
      files. Each new assertion is seen to fail once with its subject removed.
      Verified: 2 of 2 new assertions fired under perturbation.
- [x] `node src/scripts/verify.mjs` passes after a re-cut of the stamps for
      the two files, and this repository's tree is reinstalled.
      Verified: `release.mjs 4.1.0` re-stamped 2 artifacts (121 unchanged);
      after `install.mjs --into . --update`, `verify.mjs` printed "2380 passed,
      0 failed", `validate.mjs` "245 artifacts checked, no failures", and
      `aep check` "validate 0 failure(s)". The changelog names both files.

## Relevant areas

`src/skills/prune.md`, `src/skills/prototype/ui.md`, `src/scripts/verify.mjs`
(the option-set link list in the `reporting` section), `src/stamps.json`.

## Constraints

- An open question with no set of options (`review` asking for a ref,
  `prototype/logic` asking for a runtime) is not an option set and is not
  changed.
- `prune` keeps "apply only what the human approves".
