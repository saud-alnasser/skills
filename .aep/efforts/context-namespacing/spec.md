---
aep: 2.4.0
owner: repository
date: 2026-08-17
kind: spec
status: implemented
---

# Problem

A context is documented as living at `contexts/<area>.md`, flat. A monorepo has
the same area in more than one project — auth in the web app and auth in the API
— and a flat tree gives them one namespace to share.

So the project has to be encoded in the filename, and **nothing governs how**.
One author writes `web-auth.md`, the next `auth-web.md`, a third
`webapp-auth.md`. The convention is invented per repository, per author, and
per sitting, which is the failure `[[policies/artifacts]]` exists to prevent for
every other artifact kind.

Underneath that is a second, sharper problem: **nesting already works, and
nothing says so.** Verified against this tree at release 2.4.0 by creating
`contexts/web/auth.md` and running the shipped scripts:

- `validate.mjs` passed it — 101 artifacts, no failures. The frontmatter
  contract, including the `use-when` requirement, applies because that check
  reads the artifact's **top** directory.
- `index.mjs` listed it in the Contexts table by its full path. `contexts` is walked;
  `skills/` alone carries the `flat: true` flag, for a stated reason.
- a wiki link to `contexts/web/auth` resolved from another artifact.

The capability is therefore **accidental**, and three things make that costly:

- **`templates/context.template.md` says "Copy to `contexts/<area>.md`."** It is
  the only instruction an author reads, and it describes a flat tree.
- **The specification defines what a context *is* and never says where one may
  live.** A second implementation could ship a flat-only validator and conform.
- **No assertion pins it.** Contexts are walked because nobody passed
  `flat: true`. Someone adding it by analogy with `skills/` would delete every
  nested context from the index, and the suite would stay green.

# Goal

`contexts/<area>.md` and `contexts/<project>/<area>.md` are both legal, both
documented, and both asserted. Exactly one level of nesting — deeper is a
validation failure that names the file. The directory says what a context is
**named**; `paths:` still says when it **loads**.

# Scope

- The **normative statement**: the two legal shapes, the one-level limit, and
  which question each mechanism answers.
- **`templates/context.template.md`**, so an author is told both shapes and when
  each fits.
- **`validate.mjs`**: a context nested more than one level deep fails.
- **`verify.mjs`**: the above, plus that contexts are listed by walking rather
  than flat — the guard that keeps today's accident from being undone.
- A **release notice**, because the depth rule can fail a tree that validated
  before it.

# Requirements

1. **Two shapes, both legal.** `contexts/<area>.md` for something that spans the
   repository; `contexts/<project>/<area>.md` for something belonging to one
   project of a monorepo.

2. **Exactly one level.** `contexts/<project>/<area>.md` is the deepest legal
   form. Anything deeper is a validation failure naming the file and the limit.
   *A monorepo of monorepos is a shape AEP declines to model, and saying so is
   cheaper than the tree that results from not saying it.*

3. **The directory namespaces; `paths:` decides applicability.** They answer
   different questions and neither replaces the other:

   | Mechanism | Answers |
   | --- | --- |
   | the `<project>/` directory | what this context is **called**, so `web/auth` and `api/auth` can both be `auth` |
   | `paths:` | when this context **applies**, so it loads for work under those paths |

   A context under `<project>/` **may still declare `paths:`**, and normally
   will. The directory is not read as a path scope: nothing derives
   applicability from a directory name.

4. **`<project>` is the repository's word, not AEP's.** AEP does not define what
   a project is, does not require the directory to match a path in the
   repository, and does not check that it does. *Why: monorepo layouts disagree —
   `apps/web`, `packages/web`, `services/web` — and a rule that guessed would be
   wrong in most of them.*

5. **The index lists nested contexts**, in the Contexts table, by their full
   wiki-link. This is already true and becomes asserted.

6. **The template instructs both shapes**, and says which to reach for.

7. **Loading does not change.** Contexts are still selected by `use-when` and
   `paths`, still repository-owned, still progressive. No skill changes how it
   finds a context.

8. **A repository whose tree the new rule would fail is told.** The release
   declares a notice naming the limit and what to do.

# Acceptance Criteria

1. The specification defines both shapes, and states that the deepest legal form
   is one project directory. Broken version: a specification that describes
   nesting without bounding it.

2. `validate.mjs` fails `contexts/a/b/c.md`, naming the file and the one-level
   limit, and passes both `contexts/a.md` and `contexts/a/b.md`. Fire-checked in
   all three positions.

3. The specification and the template each state that the directory names and
   `paths:` scopes, and that neither is derived from the other. The suite asserts
   the claim in the shipped surface.

4. Nothing in the shipped tree derives `paths:` — or any applicability — from a
   context's directory. Verified by reading `index.mjs` and `validate.mjs`, not
   by assuming.

5. `verify.mjs` asserts that the Contexts section is **not** flat-listed, so
   adding `flat: true` fails by name. Fire-checked by adding it and watching the
   failure.

6. `templates/context.template.md` gives both shapes with a one-line rule for
   choosing. Broken version: a template that mentions nesting only in prose an
   author skips.

7. A nested context is created in this repository's own tree, `index.mjs` lists
   it and `validate.mjs` passes it, and the result is quoted — then removed if it
   describes nothing real. *This repository is not a monorepo, so a permanent
   example here would be a context that documents nothing.*

8. The release declares a notice, shown to a tree that precedes the release and
   not to one at or past it. Both proved.

9. `node src/scripts/verify.mjs` passes, and every new guard was watched failing
   with the perturbation confirmed to have removed its subject
   (`[[rules/authoring]]`).

# Constraints

- **`contexts/` is repository-owned.** The protocol may state where a context
  may live and may reject an illegal shape; it may **never move anyone's file**.
  A flat tree stays legal and stays untouched.
- **The seeded `contexts/repository.md` stays at the root of `contexts/`.** It
  describes the repository, not a project, and a monorepo has exactly one.
- **Shipped text cites only what resolves where it is read** — no `specs.md`, no
  section numbers (`[[rules/authoring]]`).
- **This is a rule about placement, not a new primitive.** A context under a
  project directory is a context, with the same frontmatter contract, the same
  ownership, and the same loading.

# Out of Scope

- **Nesting for any other artifact kind**, and not as a deferral — as a decision
  with a reason. `rules/` and `references/` are **repository-wide by nature**: a
  reference is picked up by whoever needs the tool, and a rule applies across the
  repository with `paths:` to narrow it where that matters. Neither has a
  namespace two projects can collide in. A **context** is orientation *about an
  area*, and in a monorepo the area belongs to a project — which is the whole
  reason this shape exists. `agents/`, `modes/`, and `templates/` are
  protocol-owned and flat.

  The depth rule is therefore written **for contexts specifically**, with no
  table of directories and no extension point: a mechanism that generalised
  would advertise a shape nobody wants.
- **Deriving `paths:` from the directory.** Named here because it is the obvious
  convenience and it would make the directory load-bearing for applicability —
  which Requirement 3 exists to prevent.
- **More than one level.** Explicitly rejected rather than merely unbuilt.
- **A per-project `repository.md`**, or any new seed. Seeds are unchanged.
- **Migrating an existing flat context** into a project directory, or advising
  anyone to. A flat context in a monorepo is legal and often right.
- **Changing how contexts are loaded, selected, or ranked.**
- **Defining what a project is**, or validating the directory against the
  repository's layout.

# Assumptions

- **You want this in the protocol**, not merely in this repository. Nothing here
  is specific to the repository that builds AEP — which is not a monorepo and
  will get no nested context of its own.
- **`<project>` means a unit of the monorepo** — an app, a package, a service —
  rather than an arbitrary grouping like `frontend/` across several apps. The
  rule permits either, because Requirement 4 declines to define the word; the
  guidance will name the intended use.
- The empirical probe generalises: it was run against this tree at 2.4.0 with
  the shipped scripts, so it establishes what the scripts do, not what every
  consuming repository's tooling does.

# Open Questions

Both closed at planning, and recorded in the approach below.

1. ~~Should the guidance say when to nest?~~ **One line in the template**, at the
   moment an author chooses a path. Guidance, not a rule: a checkable version —
   *a project directory must hold more than one context* — would punish the
   honest case of a project with exactly one.
2. ~~Should the index group by project?~~ **No.** One flat table with full
   wiki-links, which is what Requirement 5 already asserts. Grouping is a
   separate decision and would be a change to what the index is, not to where a
   context may live.

# Risks

- **The depth rule can fail a tree that passed yesterday.** Requirement 8's
  notice is the mitigation, and it is only as good as the wording.
- **The directory gets read as a scope anyway.** Requirement 3 states the
  separation and Acceptance Criterion 4 checks the shipped tree for it, but an
  author who assumes the directory scopes will write a context with no `paths:`
  and be surprised when it loads everywhere. This is the failure most likely to
  survive the change.
- **A rule with no example in this repository.** Criterion 7 exercises it in a
  probe rather than a fixture, so the only permanent demonstration will be in
  the suite's temporary trees — which is honest, and also easy to under-test.

# Architecture

**The depth rule ships in `validate.mjs`, not in `verify.mjs`.**

There is already a one-level rule in this distribution — a skill note sits beside
its skill and no deeper — and it is asserted in `verify.mjs`. That placement is
right for a note and wrong here, and the difference is *who writes the file*: a
note **ships**, so the distribution's own suite is the last thing between it and
a release. A context is **authored in the consuming repository**, where
`verify.mjs` never runs. A rule that lived there would never reach the person
who broke it.

**The rule is written for contexts specifically** — no table of directories, no
extension point. `rules/` and `references/` are repository-wide by nature, so
neither has a namespace two projects can collide in, and a generalised mechanism
would advertise a shape nobody wants. The reason is recorded in Out of Scope
rather than left to inference.

```
validate.mjs        rejects contexts/<project>/<area>/<deeper>.md, naming the limit
  specs.md §12      the two legal shapes, and which mechanism answers which question
  context.template  both shapes, and the one line that chooses between them
    verify.mjs      asserts all of the above, and drives the validator over a
                    fixture at each of the three depths
```

**What is deliberately left alone.** `index.mjs` already walks `contexts/` and
already lists a nested one by its full wiki-link — that is the accident this
effort makes deliberate, and the change is an **assertion**, not an edit. The
Contexts table stays one flat list.

**Alternatives, and why they lost.**

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| A depth table keyed by directory | extending to `rules/` later is one line | advertises an extension that was considered and rejected | invites nesting where it buys nothing | a constant with one entry |
| Every repository-owned directory | consistent across kinds | `rules/` and `references/` are repository-wide, so it solves a collision they cannot have | fails more existing trees, for nothing | three entries to explain |
| **Contexts only, written plainly** — chosen | matches the one kind that has the problem | the asymmetry is real | someone nests `rules/web/` and nothing objects | one check |

*The chosen row is the human's criterion, not a compromise: a reference is picked
up by whoever needs the tool and a rule scopes with `paths:`, so only a context
is named after an area a project can own.*

# Components

| # | File | Change |
| --- | --- | --- |
| 1 | `specs.md` §12 | the two legal shapes, the one-level limit, and the namespaces-versus-scopes split |
| 2 | `specs.md` §32.2, §35 | the assertions the suite must make, and one invariant |
| 3 | `src/templates/context.template.md` | both shapes, and the one line that chooses |
| 4 | `src/scripts/validate.mjs` | reject a context deeper than one project directory |
| 5 | `src/scripts/verify.mjs` | a `contexts` section: the shipped claims, plus the validator driven over a fixture at three depths |
| 6 | `src/scripts/payload.mjs` | a `NOTICES` entry for the release |
| 7 | `src/adapters/claude/**`, `src/stamps.json`, `CHANGELOG.md`, `.aep/` | release, adapter, changelog, reinstall |

# Interfaces

**The legal shapes**, and the only two:

```
contexts/<area>.md                  spans the repository
contexts/<project>/<area>.md        belongs to one project of a monorepo
contexts/<project>/<x>/<area>.md    rejected
```

**The validator's failure**, which is the whole user interface of this change. It
names the file, the limit, and the legal form — because whoever reads it has no
other source:

```
contexts/web/admin/auth.md: a context sits at contexts/<area>.md or
  contexts/<project>/<area>.md — one project directory deep, no more
```

**The template's choosing line**, which is the other interface:

> Copy to `contexts/<area>.md` — or `contexts/<project>/<area>.md` in a monorepo,
> when two projects would otherwise fight over the same area name. One project
> directory deep, no more.

# Technical Approach

1. **`specs.md`** — §12 gains the shapes and the split, §32.2 the assertions, §35
   the invariant. Normative first, so nothing is asserted before it is defined.
2. **The template**, so an author meets both shapes at the moment of choosing.
3. **`validate.mjs`** — the check, in `checkArtifact`, beside the other
   situational-field rules. It reads the same `rel`/`segments` the function
   already computes, so it costs no new parsing.
4. **`verify.mjs`** — the `contexts` section. The depth proof reuses the existing
   pattern for asserting a rejection: write the offending file into the install
   fixture, run **the fixture's own** `validate.mjs` with piped output, require a
   non-zero exit whose message names the limit, then remove the file before
   anything downstream reads that tree.
5. **The notice**, then the release, adapter, changelog, and reinstall.

**The probe, and what happens to it.** Acceptance Criterion 7 wants a nested
context created in this repository's tree. It is created, quoted, and
**removed** — this repository is not a monorepo, so a permanent
`contexts/<project>/…` here would be a context that documents nothing, and a
context contradicted by the repository is worse than none.

# Testing Strategy

| AC | Guard |
| --- | --- |
| 1 | `specs.md` defines both shapes and bounds the depth — asserted by the suite's specification checks |
| 2 | the fixture accepts `contexts/a.md` and `contexts/a/b.md` and **rejects** `contexts/a/b/c.md`, with the failure naming the limit. Three positions, one guard each |
| 3 | the template and the specification each state that the directory names and `paths:` scopes |
| 4 | no shipped script derives applicability from a context's directory — asserted over `index.mjs` and `validate.mjs` by reading them for a `contexts`-keyed path rule |
| 5 | the Contexts section of `index.mjs` is **not** flat-listed; adding `flat: true` fails by name |
| 6 | the template carries both shapes and the choosing line |
| 7 | the probe runs in this tree, its `index.mjs` and `validate.mjs` output is quoted in the ticket, and the file is gone by the commit |
| 8 | the notice shows to a tree preceding the release and not to one at or past it |
| 9 | `node src/scripts/verify.mjs` passes, and every new guard was watched failing with its subject confirmed removed |

# Migration

**Nothing moves.** `MOVES` gains no entry; no flat context is relocated and none
is advised to be.

**One notice**, filtered by the same predicate `MOVES` uses. It names the limit,
gives the two legal shapes, and says what to do with a deeper file — move it up
to `contexts/<project>/<area>.md`, or flatten it. It does not offer to do it:
`contexts/` is repository-owned and an upgrade never edits a file the repository
owns.

# Operational Considerations

- **A repository with a context nested two or more levels deep fails
  `validate.mjs` after upgrading.** This is the only outward-facing consequence,
  it is deliberate, and the notice carries the fix. Expected to be rare: nothing
  ever told anyone the shape was legal.
- **`contexts/repository.md` is unaffected** — depth one, at the root, seeded
  once. A monorepo has exactly one of it.
- `index.mjs` output changes only for repositories that actually nest, and for
  them it already worked.

# Technical Risks

- **The check must not fire on what is already legal.** `contexts/repository.md`
  and `contexts/<project>/<area>.md` must both pass. The fire-check therefore
  runs at three depths rather than one, because a guard proven only on the
  failing case can still reject the passing one.
- **The directory read as a scope.** Named in Risks above and unchanged by the
  approach: `paths:` still decides applicability, and Acceptance Criterion 4 is
  the guard that no shipped script quietly starts deriving it.
- **A guard that passes by not looking.** The `flat: true` assertion is a
  negative — it fails only if someone adds a flag. It is fire-checked by adding
  the flag, which is the only way to know it can fail at all.
