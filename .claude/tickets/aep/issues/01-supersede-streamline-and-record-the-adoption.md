# docs(knowledge): supersede streamline, and record the adoption of the specification

Status: resolved
Blocked by: —
Part of: aep

## Problem

`specs.md` is written and the aep effort is cut, but nothing in the repository's knowledge says so. Streamline's open tickets still read as the plan of record, the precedence rule still names `tickets/tenure/spec.md` as authoritative for what is built here, and the spec-evolution rule exists only inside the document it governs.

## Outcome

The adoption is recorded where decisions live, and streamline's open tickets say what happened to them. A reader who opens either effort finds one live plan, not two.

## Acceptance

- A decision records the adoption of `specs.md` as normative, its evolution rule, and where it sits relative to the truth order and the precedence ladder — including that this amends decision 0006's "everything under `.claude/`" for this one file.
- A decision records that streamline is superseded, what landed, and the transition table's dispositions, so no ticket's fate is implicit.
- Each open streamline ticket is marked superseded with a pointer to the aep ticket that absorbs it; landed tickets are untouched.
- The precedence rule points at `specs.md` for what is being built, and at this effort's tickets for what was actually done.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

This ticket writes knowledge only. It deliberately lands before the rename so that every later ticket, including the rename itself, is conforming to a recorded decision rather than to a conversation.
