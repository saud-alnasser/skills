---
aep: 2.1.1
owner: protocol
date: 2026-08-16
kind: skill
mode: [implement]
use-when: "the running AEP release differs from the one this repository declares, protocol files look wrong, or the repository still carries a 1.x layout"
---

# /update — move a repository to the running release

Replaces protocol-owned artifacts with the running release's versions, preserves
everything the repository owns, and reports what needs a human.

## First: which operation is this?

Read the tree before the version, because a 1.x repository declares a version the
upgrade path cannot use.

| The repository has | Do |
| --- | --- |
| `.aep/protocol.md` | the upgrade below |
| a protocol file outside `.aep/`, or a `policies/`, `decisions/`, or `designs/` directory, or a `map.md` in several directories | `[[skills/update/migration]]` — a 1.x carry-across, not an upgrade |
| neither | `[[skills/install]]` |

**Recognise 1.x by content, never by version string.** The layout is the fact; a
version field in a tree that predates the field is not.

## Procedure

1. **Read the declared release** — the `aep:` field on `.aep/protocol.md` — and
   compare it with the running distribution's. Equal, with a clean tree, means
   there is nothing to do; say so and stop.
2. **Classify every file under `.aep/`** by its declared `owner`
   (`[[rules/ownership]]`) — never by which directory it sits in.
3. **Detect local edits to protocol-owned files** before replacing anything:
   compare each against the release it declares. A difference is a **defect to
   report**, and what it contained goes to the human — it may be a deviation
   somebody meant to declare.
4. **Replace protocol-owned artifacts** with the running release's:

   ```
   node <distribution>/scripts/install.mjs --into <repository> --update
   ```

5. **Preserve repository-owned artifacts.** `contexts/`, `references/`,
   `efforts/`, the seeded rules, and any rule this repository added are
   untouched — the installer decides by each file's declared `owner`, never by
   its path, so a repository rule sharing a filename with a shipped one survives.
   **An upgrade MUST NEVER silently overwrite repository-owned governance** —
   where a shipped rule now collides with a repository rule, report the collision
   and let the human resolve it.

   **Seeds are never re-seeded.** A starting point the repository has since
   corrected is its own file now; a newer release's version of it is not an
   improvement to be applied. Where a seed has changed materially, **say so and
   let the human diff it** rather than touching the file.
6. **Report declared deviations.** Every deviation recorded under `[[rules]]` is
   surfaced with the release it was declared under and how long it has stood.
   *A deviation nobody is reminded of becomes a silent fork.*
7. **Migrate what the release requires**, applying only migrations newer than the
   release the repository declared, and each only after confirming by content
   that the shape it repairs is actually present.
8. **Regenerate derived state**: `node .aep/scripts/index.mjs`.
9. **Validate**: `node .aep/scripts/validate.mjs`.

## Constraints

- **Never delete a repository-owned artifact.** Where one is obsolete, say so and
  let `[[skills/prune]]` and the human handle it.
- Never resolve a rule collision by picking a side.
- Do not commit.

## Done when

The declared release matches the running one, `validate.mjs` passes, repository
knowledge is intact, and every deviation and collision has been reported.

Coming from 1.x, add: every 1.x file has a recorded outcome, nothing was deleted,
every proposed `use-when` is listed for confirmation, and the old layer is no
longer governing (`[[skills/update/migration]]`).
