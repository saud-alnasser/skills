# Changelog

## 2.0.0

A rewrite of the framework. AEP 1.x was a Claude Code skill framework rooted in
`.claude/`; 2.0 is an agent-agnostic filesystem protocol rooted in `.aep/`. The
framework is replaced; a repository's own knowledge is converted across.

**No 1.x file upgrades in place, and this is deliberate.** The two architectures
disagree about where state lives, what governs, and how knowledge is selected, so
converting 1.x's framework files would have carried its shape into a design that
exists because that shape was wrong.

What does move is everything 2.0 has a representation for. `/update` recognises a
1.x layout by content, installs 2.0 fresh, and **converts**: contexts, tool
guides, specs, tickets and their states, evidence, repository-authored rules —
and the repository content 1.x kept *inside* framework-owned files, which is the
part a migration loses most easily. A file is dropped only where this release
ships the thing it was, never for having declared `owner: framework`.

Every derivable field is derived, including `date` from the file's own history;
`use-when` is proposed and flagged, because it is the one field nothing can
compute. Nothing is deleted, every collision stops, and the result passes
`validate.mjs` with no exemption. `skills/update/migration.md` has the mapping.

### Added

- **`.aep/` as the single canonical location.** Every runtime — Claude Code,
  Codex, Cursor, or another — reaches the same files through an adapter. A
  repository never carries one AEP state per agent.
- **Applicability metadata on every artifact.** `use-when`, `paths`, and `mode`
  decide what loads, so knowledge is selected by relevance rather than by stage.
- **A declared ownership boundary.** `owner: protocol` installs verbatim and is
  replaced by upgrades; `owner: repository` is preserved. Ownership is read off
  the declared field, never inferred from a path.
- **Seeds** — repository-owned starting points installed once, only where their
  evidence is detected: a version-control rule, a repository context, an
  entrypoint, and references for git, GitHub, GitLab, Graphite, pnpm, npm, yarn,
  Bun, Docker, and Make.
- **Templates** for every artifact kind, so a new rule, reference, context,
  spec, ticket, or role starts from the shape it must hold.
- **Skill notes** — depth at `skills/<skill>/<note>.md`, reached by link from the
  skill that owns it and paid for only by the run that takes that branch. The
  skill file stays what is true on every invocation; UI and logic prototyping,
  test and mocking judgement, the fallback smell vocabulary, module depth and
  designing twice, bug diagnosis, brief writing, conflict resolution, declining a
  request, the survey report, and the 1.x migration all live there.
- **A derived index**, regenerable byte-identically, gaining a tickets section
  exactly when local tickets exist.
- **A verification suite** asserting the shipped surfaces against `specs.md`,
  including a fixture install that proves the produced tree validates — and a
  seeded failure proving the harness can still fail.

### Changed

- **One governance layer.** Policies are gone; rules are the only one, each
  loading on its own trigger. What holds on every turn lives in the bootstrap
  instead, so no norm has two homes.
- **One spec file per effort.** `spec.md` evolves from WHAT/WHY to WHAT/WHY/HOW.
- **Scripts are JavaScript**, dependency-free ESM named `.mjs` so a consuming
  repository's `package.json` cannot change how they parse. `verify.ps1` is
  retired, and verification now covers the shipped surfaces only.
- **Everything that ships lives under `src/`.**

### Removed

- `.claude/` as canonical state — demoted to an adapter.
- Policies, the decisions database, `tools/`, the stage→dependency table, the
  boot-tier budget, discussions as an artifact kind, mandatory local tickets, and
  `plan.md`. `specs.md` §33 lists each with what replaced it.
- **Sub-agent fan-out.** A task is never split across children; independence is
  read off declared edges, never inferred. A task too large for one child is too
  large, and returns to `/tasks`.
- The third-party `NOTICE`. 2.0 vendors no upstream text, so no licence
  condition attaches to it — see `specs.md` §34, which also states what happens
  the moment that stops being true.
