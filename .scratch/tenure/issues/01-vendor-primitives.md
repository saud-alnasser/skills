# chore(skills): vendor the primitives and rewrite their paths

Status: ready-for-agent
Blocked by: —

## Problem

Tenure composes four model-invoked primitives that matt's set already implements well: `grilling`, `tdd`, `codebase-design`, `domain-modeling`. They must live in this repo so we own them, and they must speak Tenure's layout.

## Outcome

`./skills/{grilling,tdd,codebase-design,domain-modeling}/` copied from `~/.claude/skills/`, with every path reference rewritten:

| From | To |
| --- | --- |
| `CONTEXT.md` | `.claude/context.md` |
| `CONTEXT-MAP.md` | the routing table in `.claude/context.md` |
| `docs/adr/` | `.claude/docs/decisions/` |

**Compression has one standard: high density, structure-first.** `workflow.md`'s "Caveman Compression" level is dropped — it is misnamed (called the lowest level while being the tersest), saves little against already-dense prose, and deletes exactly the relational information that tells a reader whether a statement is a fact, a constraint, or a goal. Prefer a table, a glossary entry, or a `term: definition` line over a paragraph: structure is short *and* unambiguous, which is where the savings actually come from. Compress by not writing, not by clipping grammar.

`domain-modeling` needs the most work — its `CONTEXT-FORMAT.md` currently mandates "a glossary and nothing else." Tenure's `context.md` is orientation: glossary **plus** boundaries, stable constraints, Source Pointers, and the routing table. Rewrite the format doc and the "update CONTEXT.md inline" rule accordingly, keeping the anti-rot discipline (concepts, never implementation) that made the original rule valuable.

The multi-context branch changes shape rather than disappearing. matt's `CONTEXT-MAP.md` + per-package `CONTEXT.md` is replaced by **grouping directories under `contexts/`**, so the structure is carried by the filesystem instead of by a map file that drifts:

```
contexts/
  auth.md            repo-wide domains stay flat
  database.md
  web/               a project earns a directory on the same
    routing.md       test a domain earns a file — its own
    forms.md         vocabulary or ownership
  api/
    handlers.md
```

The routing table in `context.md` lists both levels, grouped, each entry keeping its load-trigger and Source Pointer. A single-package repo simply has no directories — the flat case is not a special mode, it is the same model with nothing to group.

Remove `CONTEXT-MAP.md` handling rather than carrying both models.

`ADR-FORMAT.md` is kept almost as-is — matt's strict test and light format both win over `workflow.md`'s looser test and six mandatory sections:

- **Test:** all three of *hard to reverse*, *surprising without context*, *the result of a real trade-off*. Any missing → no ADR. A convention is not a decision; it belongs in the skill that enforces it.
- **Format:** title plus 1–3 sentences. `status`, `## Considered Options`, `## Consequences` only when they earn their place. Mandatory sections produce filler, and filler trains the reader to skim.
- **Supersession:** an ADR is a draft until committed and may be edited freely while the grill refines it. Once committed the reasoning is frozen and only `status: superseded by NNNN` moves. The superseding file names what it supersedes, so the relationship reads from either end — a reader opening the old file learns immediately that it is dead.

Path rewrite: `docs/adr/` → `.claude/docs/decisions/`. On migration, preserve each ADR's existing number and slug rather than renumbering — inbound references to `0007` must keep resolving.

## Acceptance

- No file under `./skills` references `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, or `.scratch/`.
- `domain-modeling` writes the Tenure `context.md` shape, including the routing table.
- Attribution to mattpocock/skills present (ADR 0001 records the obligation).
