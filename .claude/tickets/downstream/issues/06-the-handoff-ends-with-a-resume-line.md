---
title: 'feat(skills): the handoff ends with a copy-paste resume line and names where it lives'
status: resolved
blocked-by: []
part-of: downstream
---

## Problem

A handoff document is worthless until a fresh session reads it, and the skill that
writes one never says how that happens. It has been asked for by hand in two
consecutive sessions — the same request, twice, because the skill produces a file
and stops.

The location half is already stated: the skill says to save it to the operating
system's temporary directory and never into the workspace. That rule was violated
anyway, by a session that wrote its handoff to the workspace root and had to be
corrected. What is missing is precision rather than the rule: *the operating
system's temporary directory* is a category, and the session has one specific
scratchpad directory it was given.

Both corrections were saved to one project's memory, which reaches no other
project. That is the one-directional gap ticket `01` names for tool references,
in a second place: a correction that lands in a project's memory instead of in the
shipped skill fixes one project and no others.

## Outcome

Every handoff ends with a resume paragraph the user can copy verbatim into a new
session, naming the document's own path. Not an instruction to write one where it
fits — the last thing in the document, always, because a handoff whose reader
cannot be told how to start is scaffolding that did not reach anybody.

The location instruction names the session's own scratchpad directory rather than
the temporary directory as a category, so there is one path rather than a class of
acceptable ones.

## Acceptance

- The skill requires a resume paragraph as the document's last section, and the
  paragraph names the handoff's own path.
- The instruction is unconditional — there is no branch on which a handoff ends
  without one.
- The location instruction names the session scratchpad specifically, and keeps
  the existing prohibition on writing into the workspace.
- The suite fails when the skill carries no resume-line requirement, confirmed
  against a deliberate removal and then restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
