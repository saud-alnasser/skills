---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: uniform-reporting
---

# feat(policies): what a turn tells the human becomes governance

## Outcome

`src/policies/reporting.md` exists and is the single definition of the report
contract: the labels, the two forms and the test that assigns them, the unit the
report is emitted per, and the rule that no slot is ever dropped. Nothing else
in the payload states any of it.

## Acceptance Criteria

- [ ] The file declares `owner: protocol`, `kind: policy`, and a `use-when` that
      states a trigger rather than a topic — it fires when authoring or auditing
      a skill's report, not "documentation about reporting".
- [ ] It names the four opening slots **in order**, and the three closing slots.
- [ ] It states that a slot with nothing to put in it **says so** rather than
      being omitted, and carries the reason: silence is indistinguishable from a
      check that never ran.
- [ ] It states that the unit is **the turn** — one opening report and one
      closing block per thing the human typed — and that a skill entered from
      inside another is a stage of that run and opens no report of its own.
- [ ] It defines the difference between the two forms as **the stage markers**,
      not as value length, and gives the test that assigns a form: does this
      skill write to the repository, dispatch a sub-agent, or decide on the
      human's behalf.
- [ ] It requires the closing block of a turn that **stops early** — empty
      frontier, refused permission, surfaced conflict — with the same three
      slots.
- [ ] It contains no word implying a rendering: no terminal, colour/color, ANSI,
      width, or runtime name.
- [ ] It cites only what resolves inside a consuming repository — no `specs.md`,
      no section number (`[[rules/authoring]]`).
- [ ] `node .aep/scripts/validate.mjs` passes on the installed tree after the
      reinstall in ticket 08; until then the file validates as part of `src/`.

## Relevant areas

`src/policies/` — four policies ship today; match their register and their
`use-when` style. `[[templates/rule.template]]` is the nearest shape.

## Constraints

- **This is governance, so it states requirements and carries its one-line
  reason for each.** A policy that argues invites re-evaluation instead of
  application.
- **It is the only home.** A skill may name a label in passing; no skill file
  carries the whole set. Ticket 07 asserts this, and a second copy here fails it.

## Notes

Everything this file must contain is in [[efforts/uniform-reporting/spec]] —
Requirements 1 through 6, and the Interfaces section. The seven words themselves
are the effort's one surviving open question; write them as the spec has them
unless the human has settled otherwise first.
