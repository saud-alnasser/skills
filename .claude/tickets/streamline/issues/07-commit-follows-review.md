# feat(implement): commit follows review without asking

Status: resolved
Blocked by: 02
Part of: streamline

## Problem

Building a ticket ends with a prompt asking whether to commit and resolve it. The prompt buys nothing: one ticket is one commit and further changes amend it, so accepting and then changing something reaches the same tree as declining and changing something. The user is asked, once per ticket, to choose between two routes to an identical result.

The always-on entrypoint states that committing is asked for, which is the line that will stop describing what happens.

## Outcome

Building a ticket runs the review, applies its fixes, and commits. Further changes amend that commit, as they already did. Nothing is published, and the prohibition on pushing is untouched — it is what makes committing without asking safe, so it becomes load-bearing rather than merely standing.

## Acceptance

- Finishing a ticket produces a commit without a prompt, and the review has run and its fixes are applied before the commit exists.
- The commit is still written by the stage that owns commits, which remains the only writer of the verification cache.
- Requesting a change after the commit amends it rather than adding a second commit for the same ticket.
- Nothing pushes, opens a pull request, or submits a stack.
- The always-on entrypoint's account of what is asked for and what is the human's call matches what now happens.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

### Built

The prompt is guarded in all three shapes it took — prose, a step in the loop diagram, and a landmark `/review` ordered itself against. Deleting one and leaving the others is how a retired behaviour keeps being described in the files nobody re-read.

The push prohibition is now stated as *what makes committing without asking safe*, which is the difference between a standing rule and a load-bearing one. With the prompt gone, nothing else pauses the close-out, so the skill also says that a `/commit` which refuses stops it rather than being worked around.

**Shipped only.** This repository's `.claude/rules/engineering.md` still says committing is asked for, and that is still true here: the plugin runs from an installed cache, so `/implement` keeps asking until it is republished. Ticket 16 adopts.

### An assertion that survived the behaviour it asserted

`a ticket resolves only when the user says so` **kept passing after the behaviour was deleted**, because its pattern matched the word "asked" in an unrelated sentence about further changes. Two assertions failed honestly; this one would have sat green asserting a rule the code had abandoned.

Found by rewriting the section, not by the suite — which is the point. This is the same class as the section-scoped guard recorded on ticket 04: **an assertion whose pattern is loose enough to be satisfied by neighbouring prose cannot fail when its subject disappears.** Ticket 09's coverage audit is the place to sweep for it, and the sweep does not need the tree to exist, so it is not gated on ticket 16.

### The harness that validates the guards is the least reliable part

Three defects in it now, across three tickets: a count parameter that was actually `RegexOptions`, a parameter named `$Input` shadowing an automatic variable, and an outcome classifier that reported a miss as an exception because it matched the word "exception" inside passing assertion names.

The suite has produced no false pass this session. The harness that proves the suite has produced three false results. Worth its own attention at ticket 09 — every ticket's evidence rests on it.
