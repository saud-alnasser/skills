# Migrating another AI workflow onto Tenure

Everything below runs through `/configure`'s plan-and-confirm step. **Nothing is moved or deleted before the user has seen it in the confirmed plan**, and a line the user strikes stays as it is.

## What converts, and what is adopted as found

ADR 0008 draws the line, and `CLAUDE.md` carries the principle it rests on. What it means in a migration: the repository's own engineering is **adopted as found**, and the AI workflow layer is the one exception — it converts **wholesale**, because that layer is what Tenure replaces, and leaving it in place produces **two competing workflows**, each with its own idea of where knowledge lives.

| Converts to Tenure | Adopted as found |
| --- | --- |
| agent instructions — `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurfrules`, `.clinerules`, `.ai/` | source layout, module structure, naming |
| repository knowledge — `CONTEXT.md`, `CONTEXT-MAP.md`, decision records wherever they live | test layout and framework |
| agent workflow config — `docs/agents/`, tracker and label configuration | build, CI, and release configuration |
| agent ticket stores — `.scratch/` and equivalents | commit style, label vocabulary, PR template |
| how work is done — the command pipeline, tiers, knowledge ownership | human documentation — `README.md`, `CONTRIBUTING.md`, and `docs/` that is not agent config |

A file that is both — decision records are human-facing history *and* Tenure's Decisions layer — converts, because Tenure owns that layer.

Changing a repository's conventions is a decision for its maintainers, not a side effect of adopting a workflow. `CLAUDE.md` says what to do when one of them looks wrong.

## The mattpocock migration

The case this will meet most often, since Tenure is derived from those skills. Each row is a conversion, not a copy — the destination shape is different from the source shape, so read the target format before writing.

| From | To |
| --- | --- |
| `CONTEXT.md` | `.claude/context.md`, reshaped to orientation plus a routing table |
| `CONTEXT-MAP.md` | deleted — structure is carried by directories under `.claude/contexts/` |
| `docs/adr/*` | `.claude/docs/decisions/`, unchanged in content |
| `docs/agents/*` | folded into `CLAUDE.md` and `.claude/tracker.md`; the originals are removed |
| `.scratch/*` | `.claude/tickets/` |

`CONTEXT.md` is the only one that is genuinely a rewrite. matt's is a glossary; Tenure's `context.md` is orientation with a routing table at the end, and the Domain Contexts it routes to may not exist yet. The glossary's terms survive; the file's shape does not.

## Classify, never copy

Existing documentation is **sorted**, not duplicated. Copying is how a repository ends up with the same fact in three places, drifting independently.

| What it is | Where it goes |
| --- | --- |
| implementation explanations — how a thing works | stays in source; nothing is written down |
| repository principles, vocabulary, boundaries | becomes Context |
| historical reasoning — why an approach was chosen | becomes a Decision |
| developer instructions — how to work here | becomes `CLAUDE.md` |
| temporary notes, stale TODOs, superseded plans | discarded, and named in the plan first |

Only Context and Decisions are Tenure's to hold. A guide that explains how to use the library is the README's, and moving it into Context both loses its audience and fails the compression test.

Apply that test — it is in `CLAUDE.md` — to everything before it is written. A migration is the single largest opportunity this framework has to accumulate sediment, because there is a lot of existing prose and all of it looks like it was worth writing once.

## Leave a pointer where something still references the old path

Where a converted file is still referenced from `README.md`, `CONTRIBUTING.md`, a CI job, or a source comment, leave a **pointer at the old path** rather than a broken link:

```markdown
Moved to `.claude/context.md`.
```

Two things this is not. It is not a copy — the content lives at the destination and only there. And it is not permanent: it exists because something outside Tenure's reach still points at the old location, so name those references in the plan, and where the user is willing to update them, delete the pointer instead of writing one.

A converted file that nothing references leaves nothing behind. A stub for every moved file is sediment.

## When the migration is only partly possible

A repository may carry an AI workflow whose knowledge cannot be classified with confidence — undated notes, a `CONTEXT.md` describing a structure that no longer exists, ADRs with no reasoning in them.

**Say so and leave it.** Report what could not be classified and where it still is. Guessing a destination is worse than leaving a file where the user can find it, because a wrong classification is invisible afterwards: nothing in the target layout records that a file arrived there by assumption.
