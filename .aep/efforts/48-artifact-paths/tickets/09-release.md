---
status: resolved
blocked-by: [02, 05, 06, 08, 10]
---

# chore(dist): release 3.4.0 and reinstall this repository's tree

## Outcome

3.4.0 ships: the path convention, the stray check, the entrypoint assertions, and the skill-output check. This repository reinstalls onto its own release, and a consuming repository upgrading to it is told that a tree which validated before can now fail, and what to do about it.

## Acceptance Criteria

- [x] `node src/scripts/release.mjs 3.4.0` writes the version into `protocol.md`, re-baselines `src/stamps.json`, syncs the plugin manifest, and regenerates the adapters. No file is stamped by hand. — verified by the orchestrator. One command, and it moved four files: `src/protocol.md`, `specs.md`, `src/adapters/claude/.claude-plugin/plugin.json`, and `src/stamps.json`. The adapters were already current, so regenerating them was a no-op, which is what a clean tree either side of `adapters.mjs` had already said. It reported 88 artifacts unchanged and re-baselined the rest, which is the count the effort's payload edits produced. `every place the release is written agrees: specs, bootstrap, plugin, changelog` passes on 3.4.0 four ways.
- [x] The stray-check notice's gate in `payload.mjs` moves from `3.1.0` to `3.4.0` in the same change that writes the version of record. It has to move here and it cannot move earlier: a gate above the version of record tells a tree that is already current to go and check a release that has not shipped, and `verify.mjs`'s install fixture fails three assertions the moment it does. A gate left at `3.1.0` after 3.4.0 ships is the opposite failure and it is the quiet one, because every tree on 3.3.0 is already past it and is shown nothing. — verified by the orchestrator. The gate moved, and so did the literal in the assertion that pins it, which ticket 02 had written as `3.1.0` on the same assumption. **The install fixture caught the second one**: with the gate at 3.4.0 and the assertion still at 3.1.0 it failed by name, which is the assertion doing exactly the job its own comment describes. The reason the pin is a literal rather than `specVersion` is unchanged and now records that it has moved once.
- [x] Requirement 3: the notice for the stray check is present and reads as an instruction rather than a changelog entry. It says a tree with an artifact outside `.aep/` now fails, that the fix is a move the reader makes, and that AEP will not make it for them. — verified by the orchestrator. It landed with ticket 02, where the behaviour change is, so this ticket moved its gate and added no second one. `install.mjs --into . --update` printed it against this repository's own tree: "1 thing to check, crossing these releases: 3.4.0", followed by the notice in full. The assertion pins the three halves that carry the instruction rather than the word "stray", which a rewrite could drop while keeping the sentence readable.
- [x] `node src/scripts/verify.mjs` passes, including the baseline comparison, so nothing edited during the effort went unreleased. — verified by the orchestrator: **2138 passed, 0 failed**, against 2109 passed and 29 `stamps` failures before the release. The seeded failure line printed, `PASS the failure path works. Seeded failure discarded`, which `[[references/build]]` names as the thing that makes a green run trustworthy.
- [x] `node src/scripts/validate.mjs` passes on this repository's reinstalled tree, and this repository's own root is clean of strays under the check it just shipped. — verified by the orchestrator: `214 artifacts checked, no failures`, over a tree reinstalled by `install.mjs --into . --update` and an index regenerated after it. The stray arm reported nothing, which is this repository passing the check it wrote — the case that decided whether that check shipped at all.
- [x] The changelog and README are governed text and read as such: no em dashes, no curly quotes, no decorative emoji, sentence-case headings. — verified by the orchestrator. The `governed text` section sweeps both and is green; `README.md` was not edited by this effort. The 3.4.0 entry names what a reader has to do under *Upgrading* rather than only what changed, since the stray check is the one change here that can fail a tree that passed yesterday.
- [x] Every acceptance criterion in `[[efforts/48-artifact-paths/spec]]` is ticked, or the ticket that owns it is `obsolete` with its reason. — verified by the orchestrator. All ten are ticked on #48, none is obsolete, and each traces to a ticket that carries it: 1 to 05, 2 and 6 to 03, 3 and 4 to 02, 5 to 04, 7 to 08, 8 to 07, 9 to 07 and 08 between them, 10 to 06.

## Relevant areas

`src/scripts/release.mjs`, `src/protocol.md`, `src/stamps.json`, `.claude-plugin/`, `CHANGELOG.md`, `README.md`, and this repository's `.aep/` tree.

## Constraints

The baseline is re-cut once, here. `[[rules/authoring]]` makes a mid-effort re-cut a deliberate act rather than housekeeping, because it tells the suite that everything in the tree is the new reference point and would hide an unreleased edit.

Minor rather than major: nothing a consuming repository owns changes shape, and no file of theirs stops validating. What changes is that a defect they already had becomes visible.

**3.4.0 is pinned, and the pin moved once already.** This ticket was written to ship 3.3.0, and effort 56 shipped 3.3.0 from `main` on 2026-08-26 while both siblings were still building. What pins a release is the version of record, not the number a ticket wrote before the record moved under it, so this one re-cuts to 3.4.0 and effort 47 re-cuts to 3.5.0 above it. The two are still siblings on `main` rather than a stack, so nothing restacks this branch when the other moves and nothing stops them being built at the same time; only the merge is ordered. Whichever merges second restacks on `main` and re-cuts again if the record has moved again, which is the rule this paragraph is now an instance of rather than an exception to.

## Notes

The notice for the stray check may already have landed with ticket 02, where the behaviour change is. If so this ticket verifies it names 3.4.0 and does not add a second one. A release with nothing to ask of the reader declares no notice, and this one does have something to ask.

Reinstalling this repository's own tree is the dogfood the suite already asserts: a release that would ask its own tree for a conversion would ask everybody's.
