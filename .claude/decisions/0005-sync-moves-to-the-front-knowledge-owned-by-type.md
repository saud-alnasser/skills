---
status: superseded
load-when: which stage may write which knowledge layer is being changed
sources: [.claude/policies/knowledge.md]
supersedes: []
superseded-by: [0010]
---

# Sync moves to the front, and knowledge is owned by type rather than by file

> `0010` went further and removed the sync stage entirely. The knowledge-ownership-by-type conclusion below still stands; the "sync runs at the front" framing does not.

The original shape had `/commit` run `/sync` at the end. But `/sync`'s job is to *discover* how reality diverged from knowledge, and at commit time Claude has just made the change — there is nothing to discover. End-sync is Claude rediscovering its own work through the filesystem.

Sync therefore runs at the **front**, where discovery is real: reality that moved outside Claude's sessions. `/design`'s pre-flight invokes it request-scoped; it is also invocable standalone for a whole-repo pass.

Knowledge is then written by whichever command the knowledge crystallises in:

- **`/design`** writes vocabulary and ADRs. Durable understanding is produced mostly in conversation — the grill is where terms get sharpened and trade-offs get resolved — so it is captured as it resolves rather than reconstructed later.
- **`/implement`** writes concepts, boundaries, and Source Pointers, for what it touched.
- **`/sync`** writes nothing new. It repairs pointers, prunes what reality no longer supports, and validates.

`/commit` retains validation only: tests, conventions, pointers resolve, knowledge matches the diff, then message and commit.

## Considered Options

- **Single writer (`/sync` only).** Cleanest ownership, and mid-implementation is admittedly a poor vantage point for judging what is durable. Rejected because it routes every observation through a rediscovery step, and because it loses conversational knowledge entirely — the grill's output has no code for `/sync` to find.
- **Fold `/commit` into `/implement`.** Seven commands instead of eight. Rejected because committing hand-written work is a real standalone need.

## Consequences

Supersedes the placement of `last_sync_commit` in `0002` and `0004`: the marker moves to a machine-local `.claude/marker.json`, leaving `CONTEXT.md` as pure knowledge with no frontmatter.

Two reasons. A commit can never contain its own SHA, so a marker committed alongside the source it describes always points at the parent and every session opens with a phantom sync. The alternative fix — a `Repo-knowledge: synced` commit trailer — is mangled by the squash merges this workflow otherwise recommends. And "has reality moved since *Claude* last verified" is genuinely a per-clone question: a teammate's verification is not Claude's.

The cost is that verification is not shared across clones, so each machine re-verifies independently.

Three writers means ownership must be policed by knowledge *type*, which is softer than a file lock. `/sync`'s validation pass is what catches a writer straying outside its type.
