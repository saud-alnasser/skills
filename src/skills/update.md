---
use-when: "the running AEP release differs from the one this repository declares, protocol files look wrong, or the repository still carries a 1.x or 2.x layout"
---

# /update — move a repository to the running release

Replaces protocol-owned artifacts with the running release's, preserves
everything the repository owns, and reports what needs a human.

## First: which layout is this?

Read the tree, not the version field: a layout is a fact, a version a claim.

| The repository has | Written under | Do |
| --- | --- | --- |
| `.aep/protocol.md`, and no artifact under `.aep/` carrying `owner:` | 3 or later | the procedure below |
| `.aep/protocol.md`, and artifacts carrying `owner:` | 2.x | the procedure, **then `[[skills/update/from-2]]`**, as one operation |
| a protocol file, `policies/`, `decisions/`, or `designs/` **under the runtime's own directory** (`.claude/`, `.cursor/`, `.codex/`), or a `map.md` in several directories | 1.x | `[[skills/update/migration]]`, with `[[skills/update/conversion]]`: a carry-across, not an upgrade |
| none of these | nothing | `[[skills/install]]` |

**`.aep/policies/` is not evidence of 1.x**: AEP's policies are protocol law.
Only a `policies/` directory *outside* `.aep/` says 1.x.

## Procedure

1. **Read the declared release** (`version:` on `.aep/protocol.md`) and compare
   it with the running distribution's. Equal, with a clean tree: nothing to do;
   say so and stop.
2. **Classify every file under `.aep/`** against the release's manifest
   (`[[policies/artifacts]]`): named by it is protocol-owned, the rest is the
   repository's. **Never read an `owner:` field** to decide.
3. **Detect local edits to protocol-owned files** before replacing anything, by
   comparing content with the declared release. A difference is a **defect to
   report**, with what it contained: it may be a deviation somebody meant to
   declare.
4. **Replace protocol-owned artifacts**:

   ```
   node <distribution>/scripts/install.mjs --into <repository> --update
   ```

5. **Preserve repository-owned artifacts.** `rules/`, `contexts/`,
   `references/`, and `efforts/` are untouched. **An upgrade MUST NEVER silently
   overwrite repository-owned governance**: a repository file colliding with a
   shipped name is reported for the human to resolve. **Seeds are never
   re-seeded**; where a seed changed materially, say so and let the human diff
   it. **Where a release moved a protocol-owned artifact**, the installer removes
   the old file, repairs links to it inside repository-owned artifacts, and
   reports both; a repository file at the vacated path is preserved and
   reported. Read every line of that report: it is the one case where an
   upgrade writes into files you own.
6. **Act on every notice the upgrade printed**, in this run. Where one needs a
   decision, a credential, or another skill, **report it as outstanding, naming
   the release and what is left.** Crossing 4.0.0:
   - **`tracker:`** in `[[rules/version-control]]`'s frontmatter: set `github`
     or `gitlab` where `references/` names that forge and the repository used
     its issues and pull requests; otherwise `none`. Add `setup:` and `stack:`
     where the repository has them. Show the edit before making it.
   - **`lane: full`** on every in-flight effort's `spec.md` (status `draft` or
     `accepted`), so it finishes under the rules it started with.

   **Standing, every run, where `tracker:` is on:** the merge-time job.
   Where `[[rules/version-control]]` records it as declined, say so and **do not
   offer again**. Otherwise make `[[skills/install]]`'s offer: the same text,
   the same two shapes, the same refusal path. A recorded refusal is a decision,
   not a deviation, so step 8 does not report it. An offer that cannot be settled
   here (GitLab's token is the human's to create) is reported as outstanding,
   naming the forge and what is left. Which repositories this applies to is read
   from the tree, never from a tracker.
7. **Reconcile the rules against the law that changed under them.** A rule may
   tighten or extend a policy and never soften, contradict, or opt out of one
   (`[[protocol]]`). **The candidates are computed**: every rule citing a policy
   whose text changed between the declared release and the running one.

   | The rule | Do |
   | --- | --- |
   | restates law the release changed | rewrite it to cite the policy rather than repeat it |
   | contradicts the new law | rewrite it to the new law, or record a **declared deviation** (`[[policies/artifacts]]`) where the repository means to differ |
   | tightens or extends a policy the release did not touch | **nothing** |

   **Show every edit as exact before-and-after strings, as one list, before the
   first is made. Then ask. On a refusal, write nothing.** **Never delete a
   rule**, and never settle a contradiction by removing the side that lost.
8. **Report declared deviations**, each with the release it was declared under
   and how long it has stood.
9. **Migrate what the release requires**: only migrations newer than the
   declared release, each after confirming by content that the shape it repairs
   is present.
10. **Regenerate derived state**: `node .aep/scripts/index.mjs`.
11. **Validate**: `node .aep/scripts/validate.mjs`.

## Constraints

- **Never delete a repository-owned artifact.** Where one is obsolete, say so
  and leave it to `[[skills/prune]]` and the human.
- Never resolve a governance collision by picking a side.
- Do not commit.

## Done when

- The declared release matches the running one, `validate.mjs` passes, and
  repository knowledge is intact.
- Every deviation and collision is reported, and every notice is done or
  reported as outstanding.
- Where `tracker:` is on, the merge-time job was written, declined and
  recorded, read as declined, or reported as outstanding.
- Every rule citing a changed policy is reconciled or reported; no rule was
  rewritten without its before-and-after shown first; a refusal left every rule
  byte-identical.
- From 2.x or 1.x, add that note's own conditions.
