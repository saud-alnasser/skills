---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: uniform-reporting
blocked-by: [01]
---

# feat(contract): a skill declares the form it reports in

## Outcome

`report: full | short` is a legal, validated frontmatter field on a skill. The
artifact contract, the validator, the artifacts policy, and the skill template
all know it — before any skill declares one.

## Acceptance Criteria

- [ ] `src/scripts/contract.mjs` exports `REPORT_FORMS = ['full', 'short']`, in
      the idiom of `MODES` and `OWNERS` beside it, with the one-line comment
      those carry.
- [ ] `src/scripts/validate.mjs` rejects a value outside `REPORT_FORMS` on a
      top-level `skills/*.md`, naming the file and the bad value.
      **Requiring the field is ticket 04's**, landed in the same change that
      gives all seventeen skills a value — see Notes.
- [ ] `src/scripts/validate.mjs` **rejects `report:` on a skill note** —
      `skills/<skill>/<note>.md`. A note is not invoked, so declaring a form
      claims something untrue about it.
- [ ] `src/policies/artifacts.md` gains a row in the situational-fields table:
      when it applies, and its contract.
- [ ] `src/templates/skill.template.md` carries `report:` in the skill skeleton,
      and its note skeleton states that a note declares none.
- [ ] The frontmatter parser is unchanged — the field is a scalar, already inside
      the supported subset. Confirm by reading, not by assuming.
- [ ] `node src/scripts/verify.mjs` still passes with no skill yet declaring the
      field, or the ordering in this ticket is wrong and says so.

## Relevant areas

`src/scripts/contract.mjs` (`KINDS` ~28, `MODES` ~44, `MODELESS_SKILLS` ~84),
`src/scripts/validate.mjs` (`USE_WHEN_REQUIRED_DIRS` use ~97 is the nearest
pattern), `src/policies/artifacts.md` (`### What it must contain`),
`src/templates/skill.template.md`.

## Constraints

- **The field is required, not optional.** A skill whose form is undefined
  reports in no defined shape, which is the state this effort removes. The
  consequence for repository-owned skills is handled by the notice in ticket 08
  — do not soften the validator to avoid it.
- `validate.mjs` ships to every configured repository. Whatever it says on
  failure is what a stranger reads with no context: name the file, the field,
  and the legal values.
- **Keep the boundary between the two policies explicit.** `policies/artifacts`
  states the **field's frontmatter contract** — where it goes, what values it
  takes, that a note carries none. `policies/reporting` states the
  **requirement** that a skill declare a form, and the test that assigns one.
  Neither restates the other; the artifacts row links out for the test rather
  than repeating it. Raised by the standards axis reviewing ticket 01.

## Notes

The alternative — a constant in `contract.mjs` beside `MODELESS_SKILLS` — was
considered and rejected in [[efforts/uniform-reporting/spec]]: it puts the fact
in AEP's code, where a repository's own skill cannot declare one.

**Task-boundary correction, made while building this.** This ticket originally
required the field here. Doing so left the tree failing validation on all
seventeen skills until ticket 04 landed — which contradicts the plan's own
reason for this ordering: *the field becomes legal before any skill declares it,
so the tree never validates against a rule it predates*. The requirement moved
to ticket 04, where it lands in the same change that gives every skill a value,
and both commits stay green. The architecture is unchanged; only the line
between two tasks moved.
