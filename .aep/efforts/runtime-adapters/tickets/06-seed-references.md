---
status: resolved
---

# feat(seed): references for OpenCode and T3 Code

## Outcome

A repository that runs OpenCode gets a starting point for operating AEP under it,
and one whose team uses T3 Code gets a starting point that says T3 Code delegates
to the provider — including which skill locations it reads and in what order.
Neither installs anywhere the evidence is absent.

## Acceptance Criteria

- [ ] `src/seed/references/opencode.md` and `src/seed/references/t3code.md` exist,
      each `owner: repository`, `kind: reference`, with a `use-when`, and each
      saying in its first paragraph that it is a starting point to be corrected
      (criterion 11).
- [ ] `payload.mjs` gains two `reference(...)` rows: OpenCode detected by
      `opencode.json` or `opencode.jsonc`; T3 Code by `t3.json` (criterion 11).
- [ ] **Neither detector names `.opencode/`**, which the OpenCode adapter itself
      creates — detecting on it would make AEP's own output the evidence that the
      repository uses OpenCode (criterion 11).
- [ ] Installing into a fixture holding `opencode.json` seeds
      `references/opencode.md`; one without it does not. Same for `t3.json` and
      `references/t3code.md` (criterion 11).
- [ ] The T3 Code reference records that T3 Code wraps provider CLIs and defines
      no format of its own, and that it reads the provider config directory, then
      `<workspace>/.agents/skills`, then `<workspace>/.claude/skills`, later
      winning on a name collision.
- [ ] Both cite only what resolves where they are read.

## Relevant areas

`src/seed/references/` — every existing seed is the shape to copy.
`src/scripts/payload.mjs` — the `reference` helper and the `SEEDS` list.

## Constraints

- A seed is a **draft to be corrected, not a description that is already true**,
  and it says so in its own first paragraph.
- A detector that guesses wider than the evidence installs a reference for a tool
  the repository does not have. That is the one failure a seed must not have.

## Notes

Independent of the generator work: this task touches only `payload.mjs` and two
new files, so it can run alongside
[[efforts/runtime-adapters/tickets/01-target-table]].

Both new seeds are shipped artifacts, so the stamps baseline fails until the
release ticket runs. That is expected, not a defect in this task.
