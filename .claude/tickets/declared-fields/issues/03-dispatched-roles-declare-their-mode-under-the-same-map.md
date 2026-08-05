# refactor(agents): dispatched roles declare their mode under the same map

Status: open
Blocked by: 01
Part of: declared-fields

## Problem

All five files under `agents/` carry `mode:` at the top level of their frontmatter. The harness's subagent reference lists sixteen fields and `mode` is not among them, nor is `metadata` — the page makes no statement about unknown keys in either direction.

Nothing observably breaks: the roles load and their tool lists are honoured. But AEP is depending on undocumented behaviour for the one fact its orchestration reads off a role, and that dependency is currently invisible — it looks like a supported field because it sits beside supported fields. The finding is dated in `.claude/evidence/research/2026-08-05-frontmatter-extension-points-for-skills-and-agents.md`.

## Outcome

The roles declare their posture under `metadata.mode`, matching what tickets 01 and 02 established for skills. One rule, one form, both shipped surfaces.

This does not remove the undocumented dependency — no documented namespace exists on this surface — it reduces it to one place that ADR 0055 records, so a future reader finds a decision rather than an oversight.

## Acceptance

- No file under `agents/` carries a top-level `mode:` key.
- Every role declares `metadata.mode`, valued as one of the seven postures, asserted from the frontmatter rather than a list.
- The roles still load and dispatch — confirmed by running the suite and by a dispatch that reaches a role, not by inspection of the file alone.
- The same map-shape assertion from ticket 01 covers this surface; a scalar `metadata` fails here too.
- ADR 0055's record of the remaining undocumented dependency is accurate at close — if the harness turns out to reject the key, the ticket is handed back rather than worked around.
