---
aep: 2.5.1
owner: repository
date: 2026-08-18
kind: ticket
status: open
part-of: runtime-adapters
blocked-by: [02]
---

# feat(adapters): the runtime-neutral `.agents` target

## Outcome

AEP renders skill wrappers into `.agents/skills/`, the one location both OpenCode
and T3 Code's picker read, for every provider T3 Code drives. It renders at
install time only — no tree is committed for it.

## Acceptance Criteria

- [ ] The `agents` target renders one wrapper per shipped skill at
      `skills/aep-<name>/SKILL.md`, and `path()` returns `null` for an agent
      under every shape (criterion 3).
- [ ] `committed` is `null`, and **no `src/adapters/agents/` directory is
      created** by any run of the generator (criterion 3).
- [ ] Its skill wrappers carry the same frontmatter as the OpenCode target's —
      `name`, `description`, `metadata` — and the same pointer body (criteria 5
      and 6).
- [ ] No wrapper it renders carries a fallback of any kind (criterion 12).
- [ ] Names match `^aep-[a-z0-9]+(-[a-z0-9]+)*$` and each equals its directory
      name (criterion 4).

## Relevant areas

`src/scripts/adapters.mjs` — the `TARGETS` record.

## Constraints

- Serialized behind [[efforts/runtime-adapters/tickets/02-opencode-target]]
  because both tasks edit the same table in the same file. The edge is about the
  file, not about the design.
- This target is the OpenCode one minus agents and minus the distribution shape.
  Where the two would share a helper, share it rather than paraphrasing it.

## Notes

`.agents/skills` is not immune to being switched off — OpenCode gates it and
`.claude` together behind one external-skills flag. The spec already says so;
nothing in this task may claim more for it than that.
