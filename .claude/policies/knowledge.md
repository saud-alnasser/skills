# Writing knowledge

<!--
  Installed by /configure at `.claude/policies/knowledge.md`. Copied as-is — it
  describes the workflow, not this repository.

  Consolidated from /design, /implement, and /commit, which each stated their
  own half of who may write knowledge. Three partial statements of one rule is
  how the halves drift apart: the one that says "never author" and the one that
  says "write it inline" are the same rule seen from two stages.

  What is NOT here: the truth hierarchy, verification at use, healing in place,
  and the compression test. Those must fire on every turn, including turns where
  no stage runs, so they are in the always-on tier. A rule moved into this file
  would fire only when something followed the pointer to it.

  Reached by pointer from `.claude/protocol.md`'s routing table.
-->

Which stage may write which knowledge layer, and when. The layers themselves, and the truth hierarchy over them, are in `CLAUDE.md`; this is who holds the pen.

| Stage | May write | Never writes |
| --- | --- | --- |
| `/configure` | generates all of it from the repository; prunes what nothing references | — |
| `/design` | vocabulary and Decisions, as they resolve | — |
| `/implement` | concepts, boundaries, and Source Pointers the change moved | vocabulary, Decisions |
| `/commit` | corrections the diff falsified | anything new |
| `/review` | nothing | — |
| `/research`, `/prototype` | nothing — their output is Evidence | Context, Decisions |

## Why the pen moves

**`/design` writes vocabulary and Decisions because the grill is where they are produced.** Written as they resolve, never batched at the end: the refine step produces most of the durable understanding, and batching loses the half that felt obvious at the time. A Decision is offered only when it passes the bar in `.claude/policies/decisions.md` — most things do not.

**`/implement` writes what moved, and nothing else.** It has the best available view of which concepts and boundaries the change altered, which makes it the right writer for those — and the wrong one for vocabulary and Decisions, which crystallise in conversation rather than in a diff, and so belong to `/design`.

**`/commit` heals; it does not author.** It sees the change entire, which is what makes the whole-diff check against knowledge its own and nobody else's. Where the diff contradicts a Context statement, the correction goes into the same commit as the change that falsified it, so the two never land apart. Anything *new* belongs to the two stages above, which had the conversation.

## The one drift nobody heals inline

Context drift heals where it is found — the always-on tier carries that rule. **A falsified Decision is the exception: it is never healed inline.** An ADR's reasoning is frozen, and correcting or superseding one is `/design`'s pen, not the finder's — a build session rewriting a Decision mid-diff skips the grill that froze it.

The finder writes a **drift finding** instead — `.claude/policies/evidence.md` has the form, and `.claude/policies/maps.md` where a live effort indexes it — and carries on with the work that surfaced it. The healing lands with a later design run.

## What never gets written

**A change that moves no concept updates no knowledge.** Silence is the correct output. Writing something anyway to look thorough is how a knowledge layer turns into sediment, and sediment is the failure this whole layer exists to avoid.

**Implementation detail never lands in Context.** A walkthrough of how new code works is stale by the next commit, and nothing points at it. What belongs and what does not is in `.claude/policies/context.md`, and the compression test in `CLAUDE.md` gates every line either way.
