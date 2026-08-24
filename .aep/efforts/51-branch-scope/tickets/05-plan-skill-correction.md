---
status: resolved
blocked-by: [04]
---

# fix(skills): the plan skill stops contradicting the specification

## Outcome

`/plan` writes `plan.md`, which is what `specs.md` requires and what
`[[templates/plan.template]]` already describes. The skill file stops saying it
extends `spec.md` with the approach, so the two artifacts that tell an agent
where the approach goes stop disagreeing.

## Acceptance Criteria

- [x] `skills/plan.md` names `plan.md` as what it writes, in its opening line, its
      step 7, and its `## Output` section (criterion 12).
- [x] No sentence in it says the approach is written into `spec.md`, and its
      `## Output` no longer lists the technical headings as sections `spec.md`
      gains (criterion 12).
- [x] It still says the plan is written only where the approach is not obvious,
      which is what `specs.md` requires and what the current text gets right
      (criterion 12).

## Relevant areas

`src/skills/plan.md` lines 7, 20, 50, and 55 are the four places the
contradiction lives. `specs.md` section 14.2 is the authority.
`src/templates/plan.template.md` already says the right thing and is the model
for the corrected wording.

## Constraints

- **Correction only.** This ticket changes where the approach is written and
  nothing else about how `/plan` behaves. Anything else found in that file is
  raised, not fixed here.
- The `status` field stays the spec's. The template already forbids a plan
  declaring one, and the corrected skill must not reintroduce it.

## Notes

Found while running `/plan` on this effort, which had to choose between the skill
and the specification and followed the specification. Folded into this effort
rather than spun out, because a separate effort carrying three sentences costs
more in ceremony than the fix costs to review here. It is a requirement rather
than a passing edit so that it is reviewed on purpose.
