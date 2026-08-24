---
status: resolved
blocked-by: [04, 06, 07]
---

# test(verify): the suite judges every adapter, not the Claude one

## Outcome

Every checkable claim this effort adds has an assertion, and each has been
**observed failing** before it is trusted. The `adapter` section loops over
targets; only the plugin manifest, the hook, and the marketplace stay Claude's
alone.

## Acceptance Criteria

- [ ] For every target: the render covers one wrapper per shipped skill, and per
      shipped agent where that target wraps agents — a target rendering nothing
      **fails** rather than passing vacuously (criteria 1, 2, 3).
- [ ] For every committed target: each file is present and byte-identical to the
      render, and the committed tree holds no generated file the generator does
      not produce (criteria 1, 10).
- [ ] **No committed `src/adapters/agents/` exists** (criterion 3).
- [ ] Every rendered name matches `^aep-[a-z0-9]+(-[a-z0-9]+)*$` for the prefixed
      targets, and each skill wrapper's `name:` equals its directory (criterion 4).
- [ ] Frontmatter key sets are compared **exactly**, per target and per kind
      (criterion 5).
- [ ] The pointer assertion runs over every target (criterion 6).
- [ ] The note-as-a-command assertion asks the target for the path rather than
      building `skills/<name>/SKILL.md` by hand — under a prefix the hand-built
      path matches nothing and passes while a note is published (criterion 10).
- [ ] Every rendered fallback resolves, from the committed wrapper's own
      directory, onto a file that exists; targets that declare no fallback carry
      none (criterion 12).
- [ ] The install fixture is extended: each `--adapters` value writes the right
      directories, an unknown name exits non-zero, the overlapping pair warns,
      and each detector seeds only where its evidence is present (criteria 7, 8,
      11).
- [ ] The amended specification sections are asserted by content (criterion 13).
- [ ] **Each new assertion is perturbed**: break the thing it checks, run the
      suite, confirm it fails naming that assertion, restore. Quote one such
      failure in the close-out.
- [ ] For the vacuity guard specifically, confirm the perturbation **removed the
      subject** — a target that renders nothing must fail by name, not merely
      produce a lower count.
- [ ] `node src/scripts/verify.mjs` passes apart from the stamps baseline, which
      the release ticket clears.

## Relevant areas

`src/scripts/verify.mjs` — the `adapter` section, the note assertion, and the
install fixture section.

## Constraints

- **A green run proves nothing until the perturbation is confirmed to have
  removed the subject** — the recurring failure here is a guard that matches
  something travelling with the thing it checks.
- Pin phrases that carry meaning, not incidental wording.

## Notes

The Claude-only assertions — plugin manifest keys, the hook's commands, the
marketplace entry — describe one runtime's packaging and must not be generalized
into the loop.
