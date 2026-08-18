---
aep: 2.5.1
owner: repository
date: 2026-08-18
kind: ticket
status: open
part-of: runtime-adapters
blocked-by: [04]
---

# docs(install): step 7 offers the adapter a runtime actually reads

## Outcome

`[[skills/install]]` can offer what this release ships. Its step 7 no longer
hard-names `--adapters claude`, and it states which adapters are alternatives to
each other rather than leaving the human to discover it from a warning.

## Acceptance Criteria

- [ ] Step 7 names the shipped targets and the directory each writes, without
      restating the generator's mechanics (criterion 8).
- [ ] It states that `opencode` and `agents` are **alternatives inside OpenCode**
      and that the install offers one, with the reason: both locations are read,
      so every skill would load twice under one name (criterion 8).
- [ ] The existing Claude reasoning survives — the plugin travels with the user,
      the committed adapter travels with the repository — and still says to pick
      by which the repository needs, and to say which was picked.
- [ ] The step still opens by asking. Files outside `.aep/` belong to the
      repository.
- [ ] The file cites nothing that fails to resolve where it is read: no
      `specs.md`, no section number.

## Relevant areas

`src/skills/install.md` — step 7. `src/skills/update.md` if it names the flag.

## Constraints

- **Shipped text cites only what resolves in a consuming repository.**
- Do not restate the spec or the table. The skill tells a human what to offer and
  why; the mechanics live in the script.

## Notes

This file is a shipped artifact, so editing it means the release ticket must run
before the suite passes — the stamps baseline is what fails otherwise.
