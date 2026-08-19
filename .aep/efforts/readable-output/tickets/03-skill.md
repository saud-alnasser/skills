---
aep: 2.6.0
owner: repository
date: 2026-08-19
kind: ticket
status: resolved
part-of: readable-output
---

# feat(skills): the catalogue ships as `prose`, the eighteenth skill

## Outcome

`src/skills/prose.md` exists and carries the pattern catalogue as procedure. The
skill set becomes eighteen, the adapters publish it, and the working draft in the
output tree is deleted once its content has been carried across.

## Acceptance Criteria

- [ ] `src/skills/prose.md` declares `kind: skill`, `owner: protocol`, all eight
      modes, `report: full`, and a `use-when` naming its trigger (criterion 6).
- [ ] `node .aep/scripts/validate.mjs` passes the new file (criterion 6).
- [ ] `stageNames()` in `verify.mjs` extracts a name for **every** numbered step
      of the procedure. A procedure yielding fewer names than steps fails the
      suite, so the shape is checked by running the suite rather than by eye
      (criterion 6).
- [ ] The catalogue's metaphor-noun item is a limit rather than a ban, and carries
      the carve-out that a word the domain defines is the domain's word
      (requirement 6).
- [ ] The catalogue does not restate any of the four prohibitions as its own rule.
      It describes how to detect and repair a tell (requirement 3).
- [ ] `contract.mjs`'s `SKILLS` holds eighteen names including `prose`, its doc
      comment says eighteen, and `verify.mjs`'s on-disk comparison passes
      (criterion 7).
- [ ] `node src/scripts/adapters.mjs` regenerates all three committed trees, each
      gains a `prose` wrapper, and re-running it leaves them byte-identical
      (criterion 9).
- [ ] `.aep/skills/unslop.md` is deleted, and **only after** its content is in
      `src/skills/prose.md`. `validate.mjs`'s four failures on that file are gone.

## Relevant areas

`src/skills/prose.md` is new. `src/scripts/contract.mjs` holds `SKILLS`.
`src/skills/tdd.md` is the nearest shape to copy: a full-form sub-skill.
`.aep/skills/unslop.md` holds the draft catalogue.

## Constraints

- **Shipped text cites only what resolves where it is read.** This file may name
  `[[policies/reporting]]`. It may not name `specs.md` or a section number
  (`[[rules/authoring]]`).
- **A skill MUST NOT become governance.** Every MUST belongs to the policy.
- The catalogue stays in the skill file. It does not move to a note under
  `skills/prose/`, because every run uses all of it.
- Do not hand-edit the adapters. They are generated.

## Notes

`report: full` follows from the authoring test: invoked directly on a README the
skill writes to the repository. `tdd` is the precedent for a full-form sub-skill,
and its procedure shape is the one `stageNames()` reads.

This is the only ticket that edits `contract.mjs`, which is why ticket 06's sweep
waits on it.
