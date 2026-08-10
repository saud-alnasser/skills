---
owner: framework
version: 1.19.0
---

# Writing knowledge

<!-- Installed by /configure at `.claude/policies/knowledge.md`. -->

Which stage may write which knowledge layer. The layers themselves, and the truth hierarchy over them, are in `CLAUDE.md`; this is who holds the pen.

| Stage | May write | Never writes |
| --- | --- | --- |
| `/configure` | generates all of it from the repository; prunes what nothing references | — |
| `/design` | vocabulary and Decisions, as they resolve | — |
| `/implement` | concepts, boundaries, and Source Pointers the change moved | vocabulary, Decisions |
| `/commit` | corrections the diff falsified | anything new |
| `/review` | nothing | — |
| `/research`, `/prototype` | nothing — their output is Evidence | Context, Decisions |

- **`/design` writes vocabulary and Decisions as they resolve, never batched at the end** — the grill produces them, and batching loses the half that felt obvious at the time.
- **A Decision is offered only when it clears the bar in `.claude/policies/decisions.md`** — most things do not.
- **`/implement` writes only the concepts, boundaries, and Source Pointers its change moved** — a diff shows what moved; vocabulary and Decisions crystallise in conversation, which is `/design`'s surface.
- **`/commit` heals what its diff falsified and authors nothing new** — the correction lands in the same commit as the change, so the two never land apart.
- **A falsified Decision is never healed inline: write a drift finding and carry on** — an ADR's reasoning is frozen, and superseding one is `/design`'s pen, behind a grill. The form is `.claude/policies/evidence.md`'s; where a live effort indexes it is `.claude/policies/maps.md`'s.
- **A change that moves no concept updates no knowledge** — silence is the correct output; writing to look thorough turns a knowledge layer into sediment.
- **Implementation detail never lands in Context** — it is stale by the next commit. `.claude/policies/context.md` says what belongs; the compression test in `CLAUDE.md` gates every line.
