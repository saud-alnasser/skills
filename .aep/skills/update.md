---
use-when: "the running AEP release differs from the one this repository declares, protocol files look wrong, or the repository still carries a 1.x or 2.x layout"
---

# /update — move a repository to the running release

Replaces protocol-owned artifacts with the running release's versions, preserves
everything the repository owns, and reports what needs a human.

## First: which layout is this?

Read the tree before the version. A layout is a fact about which files exist; a
version field is a claim, and a tree written before the field existed, or one
whose bootstrap somebody hand-edited, makes it a wrong one.

| The repository has | Written under | Do |
| --- | --- | --- |
| `.aep/protocol.md`, and no artifact under `.aep/` carrying `owner:` | 3 | the upgrade below |
| `.aep/protocol.md`, and artifacts carrying `owner:` | 2.x | the upgrade below, **then the 2.x section after it** — one operation, not two |
| a protocol file, `policies/`, `decisions/`, or `designs/` **under the runtime's own directory** — `.claude/`, `.cursor/`, `.codex/` — or a `map.md` in several directories | 1.x | `[[skills/update/migration]]` — a carry-across, not an upgrade |
| none of these | nothing | `[[skills/install]]` |

**`owner:` is what identifies a 2.x tree, because declaring ownership per file
is exactly what that field was for.** Ownership is a lookup now
(`[[policies/artifacts]]`), so a tree still declaring it per file is telling you
which contract wrote it.

**`.aep/policies/` is not evidence of 1.x.** The word is used by both versions
and means opposite things: 1.x policies were the repository's, derived per
repository; AEP's are protocol law, identical everywhere. Only a `policies/`
directory *outside* `.aep/` says 1.x.

## Procedure

1. **Read the declared release** — the `aep:` field on `.aep/protocol.md` — and
   compare it with the running distribution's. Equal, with a clean tree, means
   there is nothing to do; say so and stop.
2. **Classify every file under `.aep/`** against the manifest the running
   release carries (`[[policies/artifacts]]`). Protocol-owned means *named by the
   manifest*; everything else under `.aep/` is the repository's. **Do not read an
   `owner:` field** — in a 3 tree there is none, and in a 2.x tree it is evidence
   of which contract wrote the file rather than an instruction to this step.
3. **Detect local edits to protocol-owned files** before replacing anything:
   compare each against the release it declares. A difference is a **defect to
   report**, and what it contained goes to the human — it may be a deviation
   somebody meant to declare.
4. **Replace protocol-owned artifacts** with the running release's:

   ```
   node <distribution>/scripts/install.mjs --into <repository> --update
   ```

5. **Preserve repository-owned artifacts.** `rules/`, `contexts/`, `references/`,
   and `efforts/` are untouched — the installer replaces exactly what the
   manifest names, so a repository file standing where a shipped one would land
   is not in it and survives. **An upgrade MUST NEVER silently overwrite
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

## Coming from 2.x

The installer has already done the mechanical half: protocol files replaced,
every directory this release stopped shipping reported, and two lists printed
that it deliberately did not act on — artifacts still carrying retired
frontmatter, and effort specs still holding an architecture section. It names
them rather than converting them because each needs a judgement, and a judgement
made silently by a script is the one nobody can review.

**This section's removal condition, stated here rather than left to somebody's
sense of when it stopped mattering: it goes when no repository the maintainer
knows of still carries a 2.x layout.** A compatibility branch with no stated end
is a branch nobody removes, and it is read on every upgrade forever.

### The frontmatter

Every retired field is **dropped, never converted.** Each one's answer already
lives somewhere else in 3, and writing it into a 3 field would create a second
answer that can disagree with the first:

| The 2.x field | Where its answer is now |
| --- | --- |
| `owner:` | the manifest, and the two directory lists it is built from |
| `kind:` | the directory the artifact sits in |
| `mode:`, `report:` | the posture each skill states for itself |
| `aep:`, `date:` | `protocol.md`'s `version:`, which is the one artifact that declares a release |
| `part-of:` | the effort directory the ticket is filed under |

`use-when` carries unchanged, and `status:` and `blocked-by:` carry unchanged on
a ticket. **Nothing else in the frontmatter survives**, and a file whose whole
frontmatter is retired fields loses the block entirely.

Do this to every file the installer listed, and to no file it did not — the list
is `readArtifact` over the actual tree, which is a better reader of frontmatter
than a grep.

### The specs

2.x kept an effort's architecture inside its spec. 3 splits them: `spec.md`
holds WHAT and WHY, `plan.md` holds HOW (`[[skills/plan]]`). For each spec the
installer named:

1. move the architecture section into a `plan.md` beside it, **verbatim**;
2. leave the rest of `spec.md` exactly as it stands;
3. **change no wording in either file.** A split is a move. Improving the prose
   on the way past makes the diff unreviewable, and the one question worth
   answering about a migration is whether anything was lost.

Where the section is empty, or holds a single line pointing elsewhere, that is
still a split — an effort in 3 has a plan, and an empty one is honest.

### The tracker

**An effort that has landed is a record.** Its issues, its pull request, and
every comment on it are what happened and what was reviewed. They are never
reshaped — not for consistency, not to make an old effort look like the current
one. Read which efforts are still in flight from the tracker rather than from
the tree, and touch only those.

| The 2.x object | Do |
| --- | --- |
| an in-flight effort's per-task issues | collapse into **one** issue for the effort, and one pull request (`[[skills/specify]]`) |
| an in-flight effort's labels | re-sync to the projection in `[[policies/execution]]` |
| a milestone **entirely AEP's**, every issue under it belonging to an AEP effort | delete |
| a milestone anything else uses | leave, and say so |
| **any label** | **keep** |
| a landed effort's anything | **nothing** |

**Labels are kept even where AEP created them.** Deleting one strips it from
every closed issue this migration correctly refused to touch, which edits the
record by a side effect. They are also how the reshaping finds its work, and a
tool that deletes its own index halfway through is a tool that cannot be run
twice.

**Show every tracker write as the exact string it will be** — each title, each
body, each label name, each deletion — as one list, before the first one is
made. Then ask.

**On a refusal, write nothing.** Not the uncontroversial subset, not the ones
that were listed first, not the deletions "since they were AEP's anyway." A
tracker is other people's workspace (`[[policies/authority]]`), the writes are
visible to everyone in it, and a deleted milestone does not come back.

## Constraints

- **Never delete a repository-owned artifact.** Where one is obsolete, say so and
  let `[[skills/prune]]` and the human handle it.
- Never resolve a governance collision by picking a side.
- Do not commit.

## Done when

The declared release matches the running one, `validate.mjs` passes, repository
knowledge is intact, every deviation and collision has been reported, and every
notice the upgrade printed has been done or reported as outstanding.

Coming from 2.x, add: no artifact under `.aep/` carries a retired field, no
effort spec holds an architecture section, every tracker write was shown before
it was made, and every landed effort is byte-identical to what it was.

Coming from 1.x, add: every 1.x file has a recorded outcome, nothing was deleted,
every proposed `use-when` is listed for confirmation, and the old layer is no
longer governing (`[[skills/update/migration]]`).
