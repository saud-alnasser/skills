---
status: resolved
blocked-by: [03]
---

# refactor(protocol): modes fold into the skills that entered them

## Outcome

`src/modes/` is gone. Each mode’s Mindset and What this gives up now sit inside the skill that entered it, and no skill declares that it enters a mode. `payload.mjs` no longer ships the directory and `index.mjs` no longer has a Modes section.

## Acceptance Criteria

- [x] Requirement 41 / criterion 29: `grep -r 'modes/' src/` returns nothing outside the migration path.
- [x] Every skill that previously entered a mode carries that mode’s Mindset and What this gives up, in its own words rather than as a quotation.
- [x] `modes` leaves `PAYLOAD_DIRS`, and `MOVES` or `NOTICES` in `payload.mjs` declares the removal so an upgrade can tell a human why the directory vanished.
- [x] The suite’s `modes` section is deleted and the `skills` section absorbs whatever of it still applies.

## Relevant areas

`src/modes/`, `src/skills/`, `src/scripts/payload.mjs`, `src/scripts/index.mjs`, and the `modes` and `skills` sections of `src/scripts/verify.mjs`.

## Constraints

Fold, do not summarise. A mode’s two surviving paragraphs are the only part that was not already duplicated in its skill, so the rest is dropped rather than merged.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

### What the removal instrument turned out to be

`MOVES` was the obvious choice and is the wrong one. A move identifies its source by `was`, the hash of the content the protocol last shipped at that path, and a mode file's content differs at every 2.x release a tree could be sitting on. One hash cannot recognise eight forms of one file, and the failure would have been silent: every upgrading tree reported as a collision, its `modes/` left standing.

So `modes` joins `FORBIDDEN_DIRS`, which is the mechanism that recognises a directory rather than a file, and a `NOTICES` entry carries the reason. Both already existed and both are already tested.

### Two defects fixed here, both landed earlier

`contentHash` filtered `aep:` and `date:` but not `version:`, so once ticket 03 renamed the field the bootstrap could never be stamped for its own content: the number is written into the file after the hash is taken. It stayed invisible while the version was unchanged, because the write was a no-op. Now filters all three.

`policies/artifacts.md` still described the retired contract in prose, including an emptied required-frontmatter block that ticket 03's mechanical pass left behind, and `skills/install.md` still promised a classification the installer stopped performing. Ticket 03's constraint correctly forbade prose edits and said to raise them; they were not raised. Both corrected here.

### The version of record moved to 3.0.0

A notice declared for an unreleased version fails the suite's own invariant, that a current tree is shown nothing. `release.mjs` set it, which is the one command that may. Ticket 20 re-runs it against the finished tree.
