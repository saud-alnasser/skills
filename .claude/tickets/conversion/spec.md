---
owner: repository
status: accepted
sources:
  - specs.md
  - .claude/decisions/0097-a-shipped-script-is-copied-code-not-a-behavioural-specification.md
  - .claude/decisions/0090-nothing-derived-is-committed-and-the-build-mints-the-ids.md
  - .claude/decisions/0095-configure-installs-and-converts-the-build-checks-and-a-deviation-is-an-edge.md
  - .claude/decisions/0084-two-axes-admit-a-type-and-eight-systems-become-seven-across-three-stores.md
  - .claude/tickets/substrate/spec.md
  - skills/configure/
---

# feat(configure): what ships becomes 2.0 — records, copied scripts, and a build that checks them

## Problem

The `substrate` effort specified 2.0 and shipped none of it. Every one of its build
tickets met its criteria **at specification level with no fixture run**, and ticket 24
recorded the reason: converting the templates while the store did not exist would have
broken every guard that compares a shipped template against this repository's installed
copy. So the framework now describes a store, a delivery path, and a `/configure` that
copies nothing — while `skills/configure/` still holds twenty-one templates written for
1.x and a `SKILL.md` that installs them.

Three concrete defects follow, and none is cosmetic.

**`SKILL.md` contradicts itself inside one step.** Step 4 declares that `modes/`,
`policies/`, `contexts/`, `decisions/`, `designs/`, `evidence/`, and `tools/` have left,
then spends eight paragraphs installing files into five of them, and still wires the index
regenerator and the regenerate-and-compare check that are retired at 2.0.0.

**`migration-changelog.md` sends a repository to a directory the same release deletes** —
it instructs an upgrade to install `.claude/policies/records.md`, and `policies/` is one of
the directories that left.

**Nothing asserts any of it.** The verification suite was deleted mid-effort, so the rule
requiring every change to what ships to move the suite in the same pass names a file that
does not exist, and so does `.claude/contexts/skill-authoring.md`'s Constraint.

Underneath all three sits a distribution question 1.x answered and 2.0 invalidated. Scripts
were **derived per repository from a behavioural page**, on three supports — plugin
independence, regenerate-and-compare, and an unanswerable fork. `substrate` superseded the
first two. The third now has an answer, and until it is taken the scripts specification
describes five scripts nobody can run.

## Goal

Everything under `skills/configure/` conforms to 2.0. The fifteen templates that are no
longer copied become framework-store records with minted ids; the derived ones land as
records in the repository's store; the surviving three stay templates because the harness
finds them by name. Every script AEP depends on ships as JavaScript the plugin carries and
a repository copies, and a build written in the same language asserts the whole shipped
surface against the specification.

## Constraints

- **This repository stays on 1.x and converts last.** Its `.claude/` is not migrated by
  this effort. The Constraint in `.claude/contexts/repository.md` bounds any check asking
  *does this repository hold what the framework specifies* by the newest **cut** release,
  and 2.0.0 is declared and uncut — so this repository's `contexts/`, `decisions/`,
  `evidence/`, `policies/`, `modes/`, and `tools/` stay legal throughout.
- **The build never checks this repository's `.claude/` against anything.** No
  template-to-installed byte-lock, no sweep of the committed protocol directory. Coupling
  what ships to what this repository runs on inverts the ordering above, and produced
  sixty-two failures from one template sweep during `substrate`.
- **Three surfaces stay templates**, because the harness loads each by name and nothing
  else can reach them: `CLAUDE.md`, the protocol file, and the unconditional standards
  under `.claude/rules/`. Settled by ticket 24 and not reopened; the framework's push is
  scoped to skip what the harness already delivers, so nothing is delivered twice.
- **A record's id is minted by the build, never by an author.** A heading carrying no id
  after the build has run fails it. So the store builder exists before any record does.
- **Nothing derived is committed.** The ledger the builder produces is per-clone.

## Architecture

**The framework store is `knowledge/` at the plugin root**, beside `skills/` and `agents/`.
It ships and is never written into a repository, which is what the placement test decides
on; and it mirrors the `.claude/knowledge/` shape a repository gets, so the framework's own
tree demonstrates the record format rather than only specifying it.

**Fifteen templates stop being templates.** The seven modes become records with
`fires-when: posture`; the eight copied policies become records with `fires-when: stage`.
A template with no install is not a template — under ADR 0095 nothing is copied, so what
survives of each file is its content as a record, not its role as a source for one.

**The derived guides and the tool references become repository-owned records.** `tracker`,
`version-control`, and the four tool guides are still derived from the repository's own
facts, and what changes is where the derivation lands: `.claude/knowledge/`, not
`policies/` and `tools/`.

**A shipped script is copied code.** `scripts/*.js` in the plugin, copied into
`.claude/scripts/` name for name, each declaring the release it came from. The
`SessionStart` hook holds `CLAUDE_PLUGIN_ROOT` — which a stage's shell never does — so it
is the only surface that can compare a copy's release against the running one, and it says
one line when they differ. All five scripts the specification names are written:
the store builder, the position report, the store query, the row assembler, and the
regenerator that retires with them.

**This repository's own build moves to `build/`** and returns as `verify.js`. Every
top-level directory then ships except that one, which is a shorter invariant than
distinguishing two `scripts/` directories by their contents.

## Approach

**Prefactor, then expand, then contract.** The suite comes first because every ticket after
it changes what ships, and this repository's own standard requires the suite to move in the
same pass — a set of tickets that cannot honour that standard until the last one is a set
that ships eleven unasserted changes. Then the distribution contract, because both the
records and the scripts depend on which artefact is authoritative. Then the builder, because
nothing can become a record until something mints ids. The conversions follow, and
`/configure` is rewritten only once the things it stopped installing have somewhere else to
be — rewriting it first would leave it pointing at records that do not exist yet.

Three questions ride as **declared increments** rather than being settled here. Each needs a
harness setting and a session restart that no session can perform on itself, which is what
makes them increments rather than unanswered design. They arrive here from `substrate`
tickets 19 and 21, where they were declared and could not be reached: what
`disableSkillShellExecution: true` does to a stage, and whether an `mcp_tool` hook's result
reaches context, both ride the row assembler; whether a filter-only surface answers the
cases the row excludes rides the store query.

**Options considered and rejected.**

*Records beside the skill that fires them* — rejected: it reintroduces the placement
judgement ADR 0090 removed, and a norm firing for three stages would have no home.

*Records under `skills/configure/knowledge/`* — rejected: it says the framework store
belongs to the configuration stage, which is the one stage that no longer reads it.

*Convert now, mint ids later* — rejected: every record shipped would be one the
specification already refuses.

*Keep derivation* — rejected as ADR 0097 records: two of its three supports are already
superseded and the third has an answer 2.0 makes available.

*Write only the store builder* — rejected by the user against the smaller scope: the
specification would describe five shipped scripts of which one exists.

## Acceptance criteria

- Every file under `skills/configure/` either conforms to the 2.0 specification or is gone,
  and nothing there names a directory the specification says has left.
- A reader following `SKILL.md` alone can carry out a configuration run without reaching a
  step that installs into a departed directory.
- The framework store holds one record per departed template, each declaring its type and —
  where it is a `norm` — a `fires-when` value from the closed vocabulary.
- Every heading in the framework store carries a minted id, and removing one fails the
  build with the file and the heading named.
- Running the store builder twice leaves every id unchanged.
- Each of the five specified scripts exists as JavaScript in the plugin, and a configuration
  run produces a `.claude/scripts/` whose contents are byte-identical to it.
- A copy whose declared release differs from the running one produces exactly one line at
  session start, and a matching one produces nothing.
- The build asserts the shipped surface against the specification, fails when an assertion's
  subject is removed, and reads nothing under this repository's `.claude/`.
- An upgrade run against a 1.x tree reaches every departed directory, and no instruction in
  the changelog names a destination the same release deletes.

## Risks

- **The suite is rebuilt from nothing and silently under-covers.** The deleted one had
  eighteen thousand lines; a fresh one will assert what its author remembered. Detection:
  each ticket adds its own assertions in the same pass, and each is fire-checked against a
  deliberate reintroduction before it is trusted — the standard this repository already
  holds and the one its own rule says is most often written wrong.
- **A converted record loses a norm without anything noticing.** Fifteen files are rewritten
  into a different shape, and prose that vanishes leaves no trace. Detection: conversion is
  manifest-driven — a numbered inventory of each file's norms before the rewrite, and every
  row gains a suite guard, per the quality gate the specification already carries.
- **`fires-when` is a silent-failure surface.** A record labelled for the wrong stage stops
  arriving and nothing reports it. Detection: the builder refuses a value outside the closed
  set and a stage no router row names; it cannot check that a legal value is the right one,
  and that residue is accepted.
- **Byte-identical copying fails on line endings.** A repository pinning `eol=lf` against a
  plugin checked out on a Windows default differs on every line while being identical.
  Detection: ADR 0069's pin, and the comparison strips carriage returns as the audit's
  existing rule requires.
- **Four of the five scripts have never been executed in any form.** Only the position
  report has a working implementation to port. Detection: each ships with the fixture its
  specification already carries, run in the build rather than by `/configure`.
- **The row assembler's failure mode is a fork with no safe branch** — unguarded, a non-zero
  exit aborts the stage and the model receives nothing at all; guarded, the shell's error
  text arrives inlined as prose with nothing reporting it. Detection: the choice is made
  deliberately and exercised by a failing-command fixture.

## Out of scope

- **Migrating this repository's own `.claude/`.** It converts last, by the ordering
  `substrate` chose and this effort inherits.
- **The MCP face of the store.** ADR 0088 gives the store two faces; this effort writes the
  CLI one. What the MCP face costs at call time is unmeasured and stays so.
- **Re-reading the thirteen amended and twenty-four affected decisions** that `substrate`
  ticket 16 enumerated. That is a design run of its own, and ADRs 0002, 0021, and 0056 stay
  accepted-and-contradicted until it happens.
- **Cutting release 2.0.0.** It stays declared and uncut, which is what keeps this
  repository's own 1.x tree legal.
