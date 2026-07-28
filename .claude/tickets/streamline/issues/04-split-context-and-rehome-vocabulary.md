# refactor(knowledge): split routing from vocabulary, and re-home the terms

Status: open
Blocked by: 03
Part of: streamline

## Problem

The root Context is one file holding a routing table and twenty-five glossary terms, and the entrypoint instructs that all of it be loaded at session start. Most terms are irrelevant to any given request: the tier vocabulary loads when the work is a docs fix, the claim vocabulary loads when nobody is claiming anything. Routing — the cheap part, and the part needed first — cannot be read without the expensive part.

## Outcome

Routing and vocabulary are separate files. The routing table is read first and is small. Cross-cutting vocabulary stays in the root Context. A term owned by one workflow stage moves to the guide that uses it, and a term owned by one domain moves to that domain's Context, so each term is paid for by the work that needs it.

## Acceptance

- The routing table is readable without loading any vocabulary.
- Every term appears exactly once across the routing file, the root Context, the guides, and the Domain Contexts.
- A term that moved is reachable from the file that uses it, and no file references a term whose home it does not name.
- Every file under the contexts directory has exactly one row in the routing table, and every row points at a file that exists.
- No implementation detail entered Context during the move.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
