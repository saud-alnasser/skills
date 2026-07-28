# refactor(knowledge): split routing from vocabulary, and re-home the terms

Status: open
Blocked by: 03
Part of: streamline

## Problem

The root Context a repository is given is one file holding a routing table and its glossary, and the entrypoint instructs that all of it be loaded at session start. Most terms are irrelevant to any given request: the tier vocabulary loads when the work is a docs fix, the claim vocabulary loads when nobody is claiming anything. Routing — the cheap part, and the part needed first — cannot be read without the expensive part.

The format that decides this is owned by the skill that writes Context, and it currently describes one file doing both jobs.

## Outcome

**Shipped behaviour changes; this repository's own configuration does not.**

The Context format separates routing from vocabulary. A configured repository is given a routing file that is read first and is small, and a root Context holding only cross-cutting vocabulary. A term owned by one workflow stage belongs to the guide that uses it, and a term owned by one domain belongs to that domain's Context, so each term is paid for by the work that needs it.

## Acceptance

- The routing table is readable without loading any vocabulary.
- The format states where a term belongs, mechanically enough that two people placing the same term agree.
- A term owned by a workflow stage is defined in that stage's guide, and the vocabulary files do not restate it.
- Every file under the contexts directory has exactly one row in the routing table, and every row points at a file that exists.
- Onboarding generates the split shape, and its audit branch recognises a repository already on it.
- The compression test still gates every line written into Context, and no implementation detail is admitted by the split.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

The terms in this repository's own Context are not moved by this ticket. Their content is repository-specific knowledge rather than shipped structure, and ticket 16 moves them through the migration — which is the only way the migration gets tested against real vocabulary rather than a fixture.
