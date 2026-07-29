# The out-of-scope knowledge base

`.claude/evidence/out-of-scope/` holds the record of **rejected requests**. Two jobs:

1. **Memory** — why a request was rejected, kept once the issue is closed and the discussion has scrolled away.
2. **Deduplication** — the same request arrives again in different words, and the previous decision surfaces instead of being argued from scratch.

It sits under `.claude/evidence/` with the research findings and prototype write-ups because it is the same kind of thing: a record of what was concluded and when, which nothing revalidates afterwards. It is not a Decision, and that is why it is not a peer of `.claude/decisions/`. An ADR answers *why this approach*; this answers *why not this request at all*.

## One file per concept

```
.claude/evidence/out-of-scope/
├── dark-mode.md
├── plugin-system.md
└── graphql-api.md
```

Per **concept**, never per issue. Three issues asking for the same thing share one file. Name it in short kebab-case, recognisable without opening it.

## Format

Write it as a short design document, not a database row — paragraphs, an example, whatever makes the reasoning land for someone meeting it for the first time.

```markdown
# Dark Mode

This project does not support dark mode or user-facing theming.

## Why this is out of scope

The rendering pipeline assumes a single palette resolved at build time.
Supporting themes would need a provider around the whole tree, per-component
theme-aware resolution, and somewhere to persist a preference — a large
architectural change, against a project whose focus is content authoring.
Theming is a downstream concern for whoever embeds the output.

## Prior requests

- #42 — "Add dark mode support"
- #87 — "Night theme for accessibility"
- #134 — "Dark theme option"
```

**The reason has to be substantive and durable.** Not *we don't want this* but why — project scope, a technical constraint, a strategic choice already made. Avoid anything temporary: *we're too busy right now* is a deferral, and recording it as a rejection means the next person reads a lie.

## When to check it

During step 1 of triage, every time. Match by **concept similarity, not keyword** — *night theme* matches `dark-mode.md`. On a match, surface it rather than acting on it:

> This looks like `.claude/evidence/out-of-scope/dark-mode.md` — rejected before because {reason}. Still the same view?

The maintainer may **confirm** (append the new issue to *Prior requests*, close), **reconsider** (delete or rewrite the file, and the issue goes through normal triage), or **disagree** (related but distinct — normal triage).

## When to write to it

Only when an **enhancement** is *rejected* as `wontfix`. This covers enhancement PRs exactly as it covers issues — a rejected PR is recorded so the same request does not come back as fresh code.

**Do not write here when something is closed as `wontfix` because it is already implemented.** That is a built feature, not a rejected one, and recording it poisons every future dedup check with a rejection that never happened. The closing comment points at where the feature already lives.

The flow: decide it is out of scope → check for an existing file → append the issue to *Prior requests*, or create the file → comment, linking the file → close with `wontfix`.

## Changing your mind

Delete the file. Old issues are historical records and are not reopened; the new issue that prompted the reconsideration goes through normal triage.

---

Derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for AEP.
