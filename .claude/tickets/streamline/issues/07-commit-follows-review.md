# feat(implement): commit follows review without asking

Status: open
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
