---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: policy-rule-split
---

# feat(install): declared moves retire the old rule files and repair their links

## Outcome

`policies/` is a payload directory and `rules/` a repository one. An upgrade from
2.1.x removes each protocol-owned rule file whose content now ships as a policy,
rewrites the links that pointed at it, and reports every removal, every rewrite,
and every collision.

## Acceptance Criteria

- [ ] `PAYLOAD_DIRS` names `policies` and not `rules`; `REPOSITORY_DIRS` names
      `rules`, so a fresh install creates it empty for the repository to fill.
      *(spec criterion 2)*
- [ ] `payload.mjs` exports `MOVES` with the nine entries, each carrying `from`,
      `to`, and `since`.
- [ ] Under `--update`, a `from` file declaring `owner: protocol` is deleted and
      reported as moved. *(spec criterion 9)*
- [ ] Under `--update`, a `from` file declaring `owner: repository` is left
      untouched and reported as a collision.
- [ ] The link rewriter honours every narrowing condition in the spec's
      `# Interfaces`, including skipping a name whose `rules/<name>.md` still
      exists after the moves. *(spec criterion 10)*
- [ ] Every rewritten file and every replacement appears in the report.
- [ ] Running the upgrade twice changes nothing the second time.
- [ ] Nothing happens without `--update`: a fresh install performs no moves and
      no rewrites.
- [ ] `verify.mjs`'s manifest section covers `MOVES` — every `to` names a file
      the release ships, and every `from` names one it does not. *(`[[rules/authoring]]`
      — the suite moves in the same pass)*

## Relevant areas

`src/scripts/payload.mjs` — `PAYLOAD_DIRS`, `REPOSITORY_DIRS`, the new `MOVES`.
`src/scripts/install.mjs` — `copyDir`'s retirement reporting is the existing
behaviour to sit beside, not to replace; retirement still means *no longer
shipped*, and a move is a different thing.

## Constraints

- **The link rewriter is the highest-risk code in this effort.** It is the first
  thing in the protocol that writes into a repository-owned file. Every condition
  in the spec's `# Interfaces` is a narrowing, and none of them is optional.
- Replace the link target only. An alias or anchor the link carried survives
  verbatim.
- No anchor is ever constructed. The rewritten target is the plain policy path,
  for the reason recorded in the spec.
- `install.mjs` continues to decide what it may overwrite by reading each
  target's declared `owner`. A repository-owned file sitting in `policies/` is
  preserved here and failed by `validate.mjs`; this task does not correct it.
- Legacy 1.x detection stays scoped to `.claude/`, `.cursor/`, `.codex/`. Do not
  widen it, and do not let `.aep/policies/` reach it. *(spec criterion 11)*

## Notes

The fixtures that prove all of this are task 08's. This task's own check is
running an upgrade by hand against a tree shaped like 2.1 and reading the report.
