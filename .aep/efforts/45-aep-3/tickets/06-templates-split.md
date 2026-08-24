---
status: resolved
blocked-by: [03]
---

# feat(templates): the spec splits from the plan

## Outcome

`spec.template` covers what is changing and why; a new `plan.template` covers how. The ticket template loses `part-of`. The one-file rule that said there is no `plan.md` is gone from the template and from the policy that carried its reason.

## Acceptance Criteria

- [x] Requirement 3: `templates/spec.template.md` and `templates/plan.template.md` both exist, and neither claims the other does not.
- [x] Criterion 44: the ticket template’s frontmatter block is `status` and `blocked-by`.
- [x] The superseded one-file rule is removed from the template and from `policies/execution`, and the reason it existed is replaced by requirement 46’s traceability check rather than dropped silently.
- [x] The suite’s `templates` section asserts both templates exist and that the removed rule is gone.

## Relevant areas

`src/templates/`, `src/policies/execution.md`, and the `templates` section of `src/scripts/verify.mjs`.

## Constraints

Superseding a stated rule means removing it and saying what replaces it, in the same change. Leaving it standing beside a template that contradicts it is the failure this ticket exists to avoid.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

### The rule was stated in five places

`templates/spec.template`, `policies/execution`, `policies/artifacts`, `skills/plan`, `skills/help`, and enforced a sixth time in `validate.mjs`. Superseding it meant removing all six in one change, since any one left standing contradicts what now ships. The reason it existed, one claim living in one place, is carried by requirement 46's traceability check, stated in `policies/execution` where the rule was.

### A defect found while editing beside it

`policies/artifacts` still opened with "Every AEP artifact declares `owner:`, and the owner is read off that field, never inferred from a directory". Ticket 01 reversed exactly that, and three suite assertions were pinning the false prose in place, passing because they tested the sentence rather than the behaviour. Section rewritten and the assertions rewritten with it, including one that fails on any retired field the policy still documents.

### A guard that passed its own fire-check, again

The retired-field guard matched `` `field:` `` with a colon, and the field table writes the name bare. It missed every row in the table, which is the half of the file most likely to keep a dead field. Second time in this wave that a guard needed the perturbation to find it, and both times the perturbation was the only thing that did.
