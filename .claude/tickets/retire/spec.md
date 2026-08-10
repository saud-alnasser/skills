---
owner: repository
status: implemented
sources:
  - hooks/check-version.js
  - skills/configure/protocol.template.md
  - skills/configure/SKILL.md
  - skills/configure/migration-changelog.md
  - scripts/verify.ps1
  - .claude/decisions/0081-the-entry-carries-the-framework-version-and-aep-version-retires.md
---

# feat(protocol): the entry's version is the framework's version, and aep-version retires

## Problem

The router carries two version fields with different owners — `aep-version`, the release that configured the repository, and `version`, the release that last changed the file — and everywhere else carries one. The pair is load-bearing today but reads as redundancy, the audit must remember to re-stamp one of them, and the byte-lock comparison must set the re-stamped one aside as an extension point. Two facts, two lifecycles, and the file most read is the one place both appear.

## Goal

One version field everywhere. The entry file's stamp is the framework's version by construction — every release stamps the router's template with the release version, so "the release that last changed this file" and "the release this installation runs at" coincide on the one file whose job is to speak for the whole — and `aep-version` retires.

## Constraints

- **The release hook keeps a single read** — the entry's `version` against the running manifest — **with a legacy fallback**: where the entry declares no `version`, the hook reads `aep-version` instead, so repositories configured before the stamps existed keep their staleness warning until their first audit replaces the file. Chosen at the grill; the fallback needs no removal condition, because it is dead code exactly when no such repository exists, which nothing can prove.
- **No silent releases.** A release must change the entry's template even when nothing else moves — the stamp bump is itself the change — so a behind installation always has one file that differs and the warning can never be starved. The invariant is machine-checked, never remembered: the suite asserts the entry template's stamp equals the specification's declared version.
- **The router's extension points shrink to the Deviations section alone**, and every statement of the two-point set — the router's opening paragraph, the specification's ownership section, the audit's set-aside — moves in the same change (the specification amends in the same change, as its amendment rule requires).
- **Frozen records keep their history.** Accepted ADRs, resolved tickets, and evidence naming `aep-version` are records, not live consumers; nothing sweeps them, and the suite's repointed assertions must not read their mentions as homes.

## Architecture

The entry's stamp gains one defined exception to last-changed semantics, stated in the router's release section where the field lives: on every framework-owned file `version` is the release that last changed it; on the entry it is the release, always, because every release stamps it. That exception is what lets one field serve both readers — the hook asking "is this installation behind" reads the entry; a person asking "how old is this file" reads the file they are holding.

The hook's comparison becomes: installed entry `version` versus the running manifest, silent on match, one line on mismatch, silent outside a configured repository — the shape it has today with the field renamed, plus the fallback branch. The audit's changelog cursor reads the same field with unchanged mechanics, and its explicit re-stamp step disappears: replacing the entry verbatim from the new release's template *is* the re-stamp. The byte-lock set-aside narrows from two extension points to one.

The migration changelog gains one dated repair under the next release: a repository whose router still declares `aep-version` has the field dropped when the verbatim replacement lands — the audit's extension-point preservation must not carry the orphaned value forward.

## Approach

The hook moves first: teach it the new read with the fallback, verified against all its branches the way its first version was — the hook then works against a router of either generation. Retirement follows: the router template's frontmatter loses `aep-version`, its release section is rewritten around the one field, the specification's ownership clause and the audit's wording move with it, the changelog's cursor section renames its source, and the suite's assertions repoint — including the single-home guard on the extension-point enumeration, whose pattern currently requires the retired field's name.

Rejected along the way:

- **The bare collapse** — per-file stamps only, the hook sweeping every pair. Rejected at the grill: a release touching no installed file would prompt nobody, and repairs to derived surfaces would wait for an unrelated release.
- **Keeping both fields** — what the provenance effort shipped, workable but permanently carrying the redundancy and the re-stamp discipline this effort removes.
- **A per-file hook sweep on top of the entry read** — precision the audit already provides at the moment it matters; the hook's job is one line that prompts it.

## Acceptance criteria

- A session against a router whose `version` differs from the running release is told, in one line, that configuring repairs it; a matching router produces silence.
- A session against a pre-stamp router declaring only `aep-version` keeps today's warning unchanged.
- A router declaring neither field is unknown rather than stale, and silent.
- The entry template's stamp equals the specification's declared version, asserted by the suite, so a release cannot ship without stamping the entry.
- `aep-version` appears in no live surface — template, installed copy, specification prose, audit procedure, changelog cursor — while frozen records keep their mentions.
- The router names the Deviations section as its only extension point, everywhere the point set is stated.
- The full suite passes.

## Risks

- **A specification version bump lands without the entry bump.** The new equality assertion fails the build at that moment — the check is the mitigation.
- **The suite's repointed guards read frozen records as violations.** Detected while repointing: the affected assertions are scoped to live surfaces, and the perturbation discipline confirms each fires before it is trusted.
- **The fallback path rots unnoticed.** It is exercised by a fixture the same way the hook's other branches were at introduction; its silence in real repositories is success, not disuse.

## Out of scope

- The audit cursor's mechanics beyond the renamed source field.
- Past migration-changelog entries and every frozen record naming `aep-version`.
- Any per-file comparison in the hook.
- The per-file stamps and enforcement the provenance effort shipped — unchanged foundation.
