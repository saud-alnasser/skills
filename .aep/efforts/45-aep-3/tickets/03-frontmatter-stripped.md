---
status: resolved
blocked-by: [02]
---

# refactor(protocol): every artifact drops the six fields nothing reads

## Outcome

`aep`, `date`, `kind`, `mode`, `report`, `owner`, and `part-of` are gone from every shipped artifact and from every template’s example block. What remains is `use-when`, `paths` where it narrows, and the effort state fields. Validation now requires the new shape rather than merely accepting it.

## Acceptance Criteria

- [x] **The installer stops reading the fields this ticket removes**, before it
      removes them. `applyMoves` decides a move source by content against the
      hash `MOVES` now carries; `rewriteMovedLinks` decides by location; and the
      move and notice gating reads `version:` with a fallback to `aep:`.

- [x] Requirement 55 / criterion 38: a skill’s frontmatter is `use-when` and nothing else. No artifact under the payload carries any removed field, and the bootstrap is the only file naming a release.

      *Verified:* no artifact under the payload carries a retired field — `validate.mjs` fails one that does, on a protocol path — and `src/protocol.md` is the only Markdown file in the distribution naming a release.
- [x] Criterion 44: the ticket template’s example frontmatter is `status` and `blocked-by`, and nothing else.

      *Verified:* `the ticket template shows status and blocked-by, and nothing else`.
- [x] `paths` survives on the artifacts that carry it.

      *Verified:* `paths` survives on `policies/artifacts.md` and on the context and rule templates.
- [x] `validate.mjs` now rejects a removed field rather than ignoring it, and the guard is broken deliberately once.

      *Verified:* `validate.mjs` fails a retired field on a protocol path and tolerates it elsewhere, which is what keeps an upgrade from failing a tree for carrying what AEP handed it.
- [x] Criterion 39 still holds after the strip: content hashes are unchanged, because the hash already stripped `aep:` and `date:`.

      *Verified with a correction.* What holds is that identical content hashes identically: the hashing function did not change, and `stamping an artifact does not change its own hash` is green. **The stated reason is wrong for four of the six fields.** `contentHash` strips `aep:`, `version:`, and `date:` only, so removing `kind`, `mode`, `report`, `owner`, and `part-of` did move those files' hashes — deliberately, and `release.mjs` restamped them. Criterion 39 of the spec carries the same inaccurate clause and is a finding rather than a gap.

## Relevant areas

Every `.md` under `src/` outside `src/seed/`, plus `src/templates/`. `src/scripts/validate.mjs` for the tightening.

## Constraints

A mechanical pass over every shipped artifact is where a hand-edit gets reverted silently. Change frontmatter only. Any prose edit that travels with this pass is out of scope and is raised rather than taken.

## Notes

The strip removed `aep:` from the bootstrap and nothing replaced it, so every
tree looked like it declared no release and the whole install fixture failed.
Requirement 58's `version:` had to land here rather than in ticket 07: it is not
an independent rename, it is what keeps the bootstrap answering the question the
strip would otherwise delete the answer to.

Four retired fields survive, in fenced examples inside landed effort specs. They
are left there deliberately. An effort's spec records what that effort decided,
and rewriting it to match a later contract falsifies the record, which is the
same reason requirement 48 leaves a landed effort's tracker artifacts alone.

The baseline was re-cut mid-effort. `aep:` and `date:` were excluded from the
content hash, but `kind`, `mode`, `report`, and `owner` were not, so removing
them changed 129 hashes and left the suite with sixty-two failures. Re-cutting is
stated in `[[rules/authoring]]` rather than done quietly: the baseline is now the
whole of edit detection, so moving it is a deliberate act.

Validation rejects a retired field on a path the protocol ships and tolerates it
everywhere else. A repository's own rules and contexts were written under the old
contract and an upgrade never edits them, so failing those would fail a tree for
holding exactly what AEP gave it and then refused to touch.

A return-to-plan, folded into this ticket rather than split out, and landed as
its own commit so the design change and the mechanical pass stay separable.

`install.mjs` read three fields this ticket removes, and every one failed
silently: two returned undefined and flipped a branch, and the third made a tree
look like it declared no release, which replays every move and every notice on
every upgrade forever. The suite could not catch any of it, because its install
fixtures still wrote the old fields, which is a guard matching something
travelling with the thing it checks.

Ownership of a move source cannot be decided by location: the file left the
payload, so the manifest does not name it, and a repository may legitimately have
written its own there. `MOVES` now carries `was`, the hash of the protocol text it
replaced, recovered from the commit that removed each file. A match is the
protocol's leftover and is removed; anything else is left alone and reported.

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
