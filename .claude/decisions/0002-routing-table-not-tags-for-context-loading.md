---
owner: repository
status: accepted
load-when: context loading is being changed, or frontmatter is proposed for routing
sources: [.claude/contexts/]
supersedes: []
superseded-by: []
---

# Context loading uses a routing table, not frontmatter tags

`CONTEXT.md` ends with a Routing Table naming each Domain Context, the condition for loading it, and its Source Pointer. The original spec instead put `domain` + `tags` frontmatter on every file for "semantic discovery without a central index."

Tags describe what a file is *about*; the agent's actual question is *when to load it*. A trigger sentence answers that; a keyword list does not. The table also sits where the agent already is — it read `CONTEXT.md` at startup — so routing costs no extra tool call, where grepping frontmatter does.

## Consequences

The table is a central index and can drift when a Domain Context is added without updating it. `/configure`'s periodic audit validates that every file in `contexts/` appears in the table, which is a checkable criterion.

Frontmatter shrinks to load-bearing fields only: `last_sync_commit` on `CONTEXT.md`, optional `status` on ADRs. Per-document `version` is dropped — nothing reads it, nothing enforces the increment rule, and git already versions these files.
