---
status: resolved
blocked-by: [04]
---

# refactor(payload): every artifact path says where it starts from

## Outcome

The 37 sites carry the root. The guard from ticket 04 goes from red to green, and the text still reads as though a person wrote it rather than as though a script ran over it.

## Acceptance Criteria

- [x] Requirement 1 / criterion 1: every site the guard listed reads unambiguously, and the guard passes across `src/skills`, `src/policies`, `src/templates`, `src/agents`, `src/protocol.md`, `src/seed`, and `src/adapters`. — verified by review: `node src/scripts/verify.mjs --section "path convention"` is `9 passed, 0 failed`, and the green is load-bearing rather than vacuous, since each of the four arms carries its own non-empty assertion. Fire-checked by the reviewer: reverting `specify.md:82` to `efforts/xxxx-<slug>/` reproduces `FAIL … 1 bare paths` naming that site.
- [x] Requirement 1: `skills/specify.md:77`, the site that produced the observed failure, names `.aep/efforts/xxxx-<slug>/`. — verified by review. It is line 82 now, reading ``The directory is `.aep/efforts/xxxx-<slug>/` — a literal `xxxx``, and the rename step below it carries the root on both halves.
- [x] Requirement 1: the five-row migration table in `skills/update/migration.md` carries the root on both columns. A reader consulting a migration table mid-upgrade is the reader who can least afford to guess a root. — verified by review, which checked all 26 rows individually rather than sampling. The table is 26 rows, not five; the count came from the plan and is stale rather than wrong work. **The 1.x column takes `<runtime>/`, not `.aep/` and not the `.claude/` this ticket's own note proposed**: `migration.md:7` and `skills/update.md:20` both say 1.x lived in whichever directory the runtime owned, and name three, so `.claude/` would be false for a Cursor or Codex tree. Raised as a fork and settled by the human on 2026-08-25. Two rows keep bare cells on each side, which is the convention working rather than an omission: `position/` and `worktrees/` on the left, `references/` and `policies/` on the right, all four single-segment area names §9.1 requires bare.
- [x] The committed adapters under `src/adapters/` are regenerated rather than hand-edited, and `node src/scripts/adapters.mjs` leaves the tree clean. — verified by review: the generator wrote 18 Claude and 14 opencode files and `git status --porcelain` is byte-identical either side of the run. The wrappers are pointers whose text derives from a heading and a `use-when`, neither of which this sweep moved, so they never carried these paths. The guard's adapters arm asserts it is non-empty, so silence there is a scanned surface rather than an unscanned one.
- [x] Sentences that changed shape still scan. Where a prefix made a line clumsy, the line is rewritten rather than left with the prefix wedged into it. — met after review, which found the first pass had not done it. Three repairs: the reflow in `help.md` had put a line break inside an emphasis span that was whole before it, `spec.template.md` had moved its orphan rather than cleared it, and the `research.md` rewrite had demoted the directory — the whole content of that step — to a trailing phrase after a comma. The bootstrap's reworded sentence took `Under` for `In` and a comma for a colon, clearing a fragment for 3 bytes where the fuller rewrite cost 7 against a 12-byte ceiling. The ten near-identical `Copy to` lines were left identical on the reviewer's argument that repetition reads as deliberate and rotation reads as a thesaurus.

## Relevant areas

23 files across `src/skills`, `src/policies`, `src/templates`, `src/agents`, `src/protocol.md`, and `src/seed`, plus the generated output under `src/adapters/`. The guard's own failure output is the authoritative list.

## Constraints

**Prose quality is not traded for mechanical safety.** A blanket prefix on 37 sites would satisfy the guard and make the text worse, which is half-solving the problem. `[[policies/reporting]]` and `[[skills/prose]]` apply to the result.

Single-segment area names are left alone. Widening the sweep to them is a different convention, it was rejected on the `protocol.md` budget, and doing it here would put the bootstrap over its limit.

`src/adapters/` is generated. Edit the payload and rerun the generator.

## Notes

Take the guard's output as the worklist rather than re-deriving it by grep. The survey and the guard were built from the same rule, and a hand-built second list is where a site gets missed.

**`protocol.md`'s primitives table is in the sweep, and the plan says it is not.** Repair 1 justifies skipping the two tables on the grounds that they "hold single-segment names in cells". That is false of the primitives table: its "Lives in" column holds `efforts/<e>/`, which is two segments, and `skills/<skill>/` appears in prose lower down. Both are in scope. Standards review caught the reasoning on 2026-08-24; do not skip the table on the plan's word.

**The bootstrap has less room than it needs, and the paragraph this replaces understated it twice.** `src/protocol.md` stands at 8171 bytes of its 8192, so the headroom is 21 rather than 28. And the guard finds five sites in it, not two: `efforts/<e>/` at line 28, `skills/<skill>/` at 94, and three script names across 154 and 155. Five prefixes cost 25 bytes against 21 available, so the sweep is four bytes short before it starts and something in the bootstrap has to give way here. Measured while building ticket 04 on 2026-08-25.

**Seven of the guard's sites are the migration table's 1.x column, and `.aep/` is the wrong root for every one of them.** `skills/update/migration.md` lines 81, 82, 86, 87, 88 and 89 name where a *pre-3.0* tree kept a file, and that tree was rooted at `.claude/`. Prefixing them with `.aep/` would make the column assert something false. Write `.claude/` instead, which the guard excuses for the same reason it excuses `.aep/`. The middle column is the one that takes `.aep/`, and lines 81, 82 and 88 carry a site in each column, so each is two edits rather than one duplicate. Correctness review caught this on 2026-08-25: the guard cannot tell a historical path from a live one, and its output does not mark them.

Some sites will read better with the path moved: "Copy to `.aep/efforts/<effort>/spec.md`" is fine, but a sentence that already named the tree in prose now says it twice, and the prose half is what goes.
