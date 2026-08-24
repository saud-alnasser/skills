---
status: resolved
blocked-by: [01]
---

# feat(adapters): the OpenCode target, in both shapes

## Outcome

AEP renders an OpenCode adapter that stands on its own: skills and agents in the
repository shape an install writes, skills alone in the distribution shape a user
registers — and the distribution shape is committed under
`src/adapters/opencode/`.

## Acceptance Criteria

- [ ] The `opencode` target renders, in the **repository** shape, one wrapper per
      shipped skill at `skills/aep-<name>/SKILL.md` and one per shipped agent at
      `agents/aep-<name>.md`.
- [ ] In the **distribution** shape it renders skills only — `path()` returns
      `null` for an agent — and that shape is what `src/adapters/opencode/` holds
      (criteria 2 and 12).
- [ ] Every rendered name matches `^aep-[a-z0-9]+(-[a-z0-9]+)*$`, and each skill
      wrapper's `name:` equals its own directory name (criterion 4).
- [ ] A skill wrapper's frontmatter is exactly `name`, `description`, `metadata`;
      an agent wrapper's is exactly `description` and `mode: subagent`
      (criterion 5).
- [ ] Each wrapper names its canonical `.aep/` path, says what to do when that
      file is absent, and restates no part of the skill (criterion 6).
- [ ] The distribution fallback is a relative path whose depth is **computed from
      the path template**, not written out, and it resolves from the committed
      wrapper's own directory onto a payload file that exists (criterion 12).
- [ ] `node src/scripts/adapters.mjs` twice in a row leaves the tree unchanged.

## Relevant areas

`src/scripts/adapters.mjs`. The new committed tree at `src/adapters/opencode/`.

## Constraints

- **Nothing but `description` and `mode` on an agent wrapper.** OpenCode routes
  an unknown frontmatter key silently into `options` rather than rejecting it, so
  a stray key there fails invisibly.
- AEP's own fields ride in `metadata` on a skill and nowhere at all on an agent.
- The wrapper states that its fallback resolves from the skill's own directory,
  which is the base OpenCode announces when it loads a skill.

## Notes

Assertions for these criteria belong to the verify task, not here. What this task
owes that task is a render whose shape those assertions can be written against.
