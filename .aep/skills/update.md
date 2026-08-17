---
aep: 2.3.0
owner: protocol
date: 2026-08-17
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
| a protocol file, `policies/`, `decisions/`, or `designs/` **under the runtime's own directory** — `.claude/`, `.cursor/`, `.codex/` — or a `map.md` in several directories | `[[skills/update/migration]]` — a 1.x carry-across, not an upgrade |
| neither | `[[skills/install]]` |

**Recognise 1.x by content, never by version string.** The layout is the fact; a
version field in a tree that predates the field is not.

**`.aep/policies/` is not evidence of 1.x.** The word is used by both versions
and means opposite things: 1.x policies were the repository's, derived per
repository; AEP's are protocol law, identical everywhere. Only a `policies/`
directory *outside* `.aep/` says 1.x.

## Procedure

1. **Read the declared release** — the `aep:` field on `.aep/protocol.md` — and
   compare it with the running distribution's. Equal, with a clean tree, means
   there is nothing to do; say so and stop.
2. **Classify every file under `.aep/`** by its declared `owner`
   (`[[policies/artifacts]]`) — never by which directory it sits in.
3. **Detect local edits to protocol-owned files** before replacing anything:
   compare each against the release it declares. A difference is a **defect to
   report**, and what it contained goes to the human — it may be a deviation
   somebody meant to declare.
4. **Replace protocol-owned artifacts** with the running release's:

   ```
   node <distribution>/scripts/install.mjs --into <repository> --update
   ```

5. **Preserve repository-owned artifacts.** `rules/`, `contexts/`, `references/`,
   and `efforts/` are untouched — the installer decides by each file's declared
   `owner`, never by its path, so a repository file standing where a shipped one
   would land survives. **An upgrade MUST NEVER silently overwrite
   repository-owned governance** — where a repository file collides with a
   shipped name, report the collision and let the human resolve it.

   **Seeds are never re-seeded.** A starting point the repository has since
   corrected is its own file now; a newer release's version of it is not an
   improvement to be applied. Where a seed has changed materially, **say so and
   let the human diff it** rather than touching the file.

   **Where a release moved a protocol-owned artifact**, the installer removes the
   old file, repairs links that pointed at it inside repository-owned artifacts,
   and reports both. A move is not a retirement: the content still exists, at a
   new path, and leaving the old file would govern the repository with two copies
   of one text. A repository file standing at the vacated path is preserved and
   reported instead — read every line of that report, because it is the one
   circumstance in which an upgrade writes into files you own.
6. **Act on the notices the upgrade printed.** A release declares what it needs
   of the reader where moving files is not enough, and the installer prints
   exactly the ones for the releases being crossed — most often something
   repository-owned that an upgrade correctly refuses to touch.

   **A notice is acted on, not read.** Do what it says, in this run. Where it
   cannot be done here — it needs a decision, a credential, or another skill —
   **report it as outstanding, naming the release and what is left**. Printing a
   notice and moving on is how it is missed: the output scrolls, the upgrade
   reports success, and nothing ever asks again.

7. **Report declared deviations.** Every deviation recorded under `[[rules]]` is
   surfaced with the release it was declared under and how long it has stood.
   *A deviation nobody is reminded of becomes a silent fork.*
8. **Migrate what the release requires**, applying only migrations newer than the
   release the repository declared, and each only after confirming by content
   that the shape it repairs is actually present.
9. **Regenerate derived state**: `node .aep/scripts/index.mjs`.
10. **Validate**: `node .aep/scripts/validate.mjs`.

## Constraints

- **Never delete a repository-owned artifact.** Where one is obsolete, say so and
  let `[[skills/prune]]` and the human handle it.
- Never resolve a governance collision by picking a side.
- Do not commit.

## Done when

The declared release matches the running one, `validate.mjs` passes, repository
knowledge is intact, every deviation and collision has been reported, and every
notice the upgrade printed has been done or reported as outstanding.

Coming from 1.x, add: every 1.x file has a recorded outcome, nothing was deleted,
every proposed `use-when` is listed for confirmation, and the old layer is no
longer governing (`[[skills/update/migration]]`).
