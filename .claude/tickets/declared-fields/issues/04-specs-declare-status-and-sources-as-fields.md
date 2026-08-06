# refactor(knowledge): a spec declares its status and sources as fields

Status: open
Blocked by: —
Part of: declared-fields

## Problem

The spec format puts `Status:` and `Sources:` as prose lines under the title. `Status` is machine-written — `/commit` moves it to `implemented` when the last acceptance criterion lands, because only the last commit of a change knows every criterion is met. So a stage edits a prose line by matching it, which is the same defect as `Mode:` and `Policies:` in a family this effort is already touching.

`Sources` is the spec's Source Pointer list, verified before use like any other. Nothing can check it while it is running text.

## Outcome

A spec declares `status` and `sources` as frontmatter fields. `/commit` sets the status field rather than rewriting a line. The rule that only the status line ever moves is unchanged — it now moves as a field.

This is the precondition for indexing designs at all: an index generated from declared fields cannot show a spec that declares none.

Templates first, per ADR 0025.

## Acceptance

- The spec format declares `status` and `sources` in frontmatter, and no spec carries them as prose lines.
- The permitted status values are asserted — a spec carrying an unknown status fails the build.
- `/commit` writes the status field, and the suite fails if the skill still describes editing a prose line.
- This repository's own specs under `.claude/tickets/<effort>/` are converted in the same change, so the format has no second version in the tree.
- The frozen-reasoning rule still holds: nothing but `status` moves after a spec is accepted.
