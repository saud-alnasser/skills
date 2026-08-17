---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: tracker-labels
blocked-by: [01]
---

# feat(skills): the label ladder becomes a skill note

## Outcome

`src/skills/tasks/labels.md` exists and holds the whole procedure: how to find
out what a tracker already models, the order to resolve in, how to name a label
when one is genuinely needed, where the resolution is recorded, and what is
gated on human approval. It is the only place the procedure lives.

## Acceptance Criteria

- [x] Written from `[[templates/skill.template]]`, `kind: skill`, `owner:
      protocol`, with a `use-when` naming the branch it serves — tasks live in
      an external tracker and the effort's work must be findable in it.
- [x] States the ladder **in order**, and that it stops at the first step that
      serves the fact:
      1. a first-class feature of the tracker; 2. an existing label that already
      serves it; 3. a new label.
- [x] States that **a label is never created for a fact the tracker models
      natively**, in words a guard can pin.
- [x] Carries a worked example showing the same fact landing as two different
      strings in two differently-styled trackers, and one showing it landing as
      **no label at all** where the tracker is native — the GitHub case.
- [x] Requires the resolution to be **recorded in the repository's tracker
      reference**, and states that later sessions read it rather than rederiving.
- [x] States that creating anything — label or milestone — goes through the same
      approval gate as creating issues, showing **exact strings, never a
      summary**.
- [x] States what to do when the reference has no such section yet: **write it**.
      An upgrade never re-seeds a corrected reference, so an existing
      installation reaches its resolution only through this note.
- [x] States that permission refused is a stop with a report, never a silent
      fallback to a different mechanism.
- [x] Says how to tell a native match from something merely adjacent — the open
      question the spec left for it.

## Relevant areas

`src/skills/tasks/labels.md` — new. `src/templates/skill.template.md` for shape.
`src/seed/references/github.md` is the worked native case and `gitlab.md` the
worked gap case; read both before writing the example.

## Constraints

- A note is depth, not an entry point. It must be **linked from
  `skills/tasks.md`** or the suite fails it as unreachable — but that link is
  ticket 03's, so this ticket lands a note that 03 makes reachable.
- No `specs.md`, no section numbers.
- Procedure only. The requirement is ticket 01's and this file links to it.

## Notes

The ladder is the human's design, not the spec's first draft: native feature
first, label last. The GitHub reference already proves the strong case — every
fact native, no label created at all.
