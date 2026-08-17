---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: ticket
status: open
part-of: uniform-reporting
blocked-by: [03]
---

# refactor(skills): every skill declares its form and names its stages

## Outcome

All seventeen shipped skills declare `report:`, and every full-form skill's
stage names extract mechanically from its own procedure — from numbered headings
where it has them, from a bolded lead on each procedure item where it does not.
No skill gains, loses, or reorders a step.

## Acceptance Criteria

- [ ] All seventeen declare `report:`, and the value matches the test: `full` for
      the fourteen that write to the repository, dispatch, or decide on the
      human's behalf; `short` for `help`, `survey`, and `domain`.
- [ ] **`src/scripts/validate.mjs` turns the requirement on in this same
      change** — a skill declaring no `report:` becomes a failure naming that
      skill. Ticket 03 made the field legal and checked its value; requiring it
      before every skill had one would have left the tree failing against a rule
      it predates. Fire-check it: remove the field from one skill, watch the
      failure name that skill, restore.
- [ ] Every full-form skill matches exactly one of the two shapes:
      `^## (\d+) — (.+)$` — today `implement`, `review`, `commit` — or
      `^(\d+)\. \*\*(.+?)[.:]?\*\*` under `## Procedure`.
- [ ] The eleven `## Procedure` skills have a bolded lead on **every** numbered
      item. Several already do; the change is completing them, never renumbering
      or resequencing.
- [ ] Each extracted stage name is a name a human would recognise as the step —
      not the first clause of a sentence that happens to be bold.
- [ ] **The step lists are identical before and after.** Record both lists in the
      close-out, per skill, and show them matching. This is the criterion the
      whole ticket is judged on.
- [ ] No skill file contains the full label set — a skill may name one label in
      passing, and the contract stays in the policy.
- [ ] `node .aep/scripts/validate.mjs` passes.

## Relevant areas

`src/skills/*.md`, top level only — a note under `src/skills/<skill>/` declares
no form and is not touched. `src/skills/implement.md`, `review.md`, and
`commit.md` already carry numbered stage headings and keep them.

## Constraints

- **Presentation only.** Adding a bolded lead to *"Read the effort's spec.md"* is
  presentation. Splitting it into two steps, merging two steps, or reordering
  them is not, and fails this ticket.
- **Stay bounded.** Seventeen files open at once is the classic invitation to fix
  something else in passing. An improvement noticed here is raised, not taken
  (`[[policies/engineering]]`).
- Do not add a position read to any skill. Ticket 05 owns that check and pins the
  four that have one.

## Notes

The alternative — converting all fourteen to numbered stage headings — was
rejected in [[efforts/uniform-reporting/spec]]: it would triple the length of
eleven compact skills for no gain, and a two-shape parser is smaller than the
diff that would remove one shape.
