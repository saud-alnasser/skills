---
aep: 2.7.0
owner: repository
date: 2026-08-24
kind: ticket
status: open
part-of: aep-3
blocked-by: [03]
---

# feat(templates): the spec splits from the plan

## Outcome

`spec.template` covers what is changing and why; a new `plan.template` covers how. The ticket template loses `part-of`. The one-file rule that said there is no `plan.md` is gone from the template and from the policy that carried its reason.

## Acceptance Criteria

- [ ] Requirement 3: `templates/spec.template.md` and `templates/plan.template.md` both exist, and neither claims the other does not.
- [ ] Criterion 44: the ticket template’s frontmatter block is `status` and `blocked-by`.
- [ ] The superseded one-file rule is removed from the template and from `policies/execution`, and the reason it existed is replaced by requirement 46’s traceability check rather than dropped silently.
- [ ] The suite’s `templates` section asserts both templates exist and that the removed rule is gone.

## Relevant areas

`src/templates/`, `src/policies/execution.md`, and the `templates` section of `src/scripts/verify.mjs`.

## Constraints

Superseding a stated rule means removing it and saying what replaces it, in the same change. Leaving it standing beside a template that contradicts it is the failure this ticket exists to avoid.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
