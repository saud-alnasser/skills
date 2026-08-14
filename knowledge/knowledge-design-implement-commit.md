---
owner: framework
type: norm
subject: knowledge
fires-when: stage
stages: [design, implement, commit]
spans:
  - who-holds-the-pen: k8h2gd
  - a-falsified-decision-is-not-healed-inline: x0sdrr
  - a-change-moving-no-concept-writes-nothing: qiuzly
  - implementation-detail-stays-out-of-context: jnnfic
---


# Writing knowledge

Which stage may write which knowledge layer. The layers themselves, and the truth hierarchy over them, are in `CLAUDE.md`; this is who holds the pen.

## Who holds the pen

| Stage | May write | Never writes |
| --- | --- | --- |
| `/configure` | generates all of it from the repository; prunes what nothing references | — |
| `/design` | vocabulary and Decisions, as they resolve | — |
| `/implement` | concepts, boundaries, and Source Pointers the change moved | vocabulary, Decisions |
| `/commit` | corrections the diff falsified | anything new |
| `/review` | nothing | — |
| `/research`, `/prototype` | nothing — their output is Evidence | Context, Decisions |

## A falsified Decision is not healed inline

- **A falsified Decision is never healed inline: write a drift finding and carry on** — an ADR's reasoning is frozen, and superseding one is `/design`'s pen, behind a grill. The form is `evidence.md`'s; where a live effort indexes it is `maps.md`'s.

## A change moving no concept writes nothing

- **A change that moves no concept updates no knowledge** — silence is the correct output; writing to look thorough turns a knowledge layer into sediment.

## Implementation detail stays out of Context

- **Implementation detail never lands in Context** — it is stale by the next commit. `context.md` says what belongs; the compression test in `CLAUDE.md` gates every line.
