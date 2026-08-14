---
owner: repository
title: "fix(skills): the stages name the records they receive rather than files to open"
status: open
blocked-by: [07]
part-of: addressing
---

## Problem

Every stage with a router row addresses its norms by path. `implement` carries the most —
eleven `.claude/policies/` references and ten `.claude/tools/` — and `design`, `review`,
`commit`, `research`, `prototype`, and `triage` carry the rest. After conversion none of
those paths exists, and a stage following one is doing the thing delivery removed: opening a
file it chose.

## Outcome

A stage's prose names the record that governs each passage and never its location. A reader
can still tell what governs; a stage receiving its row finds the norm already present rather
than a path to chase.

## Acceptance

- No file for a stage carrying a router row addresses a store record by location.
- Every passage that lost a path names the record by subject, and each subject named matches
  one the store actually carries.
- A tool guide is still pointed at, because a `reference` is never delivered — and the
  passage says it is reached at the operation rather than loaded with the row.
- Each stage's prose agrees with its own `metadata.policies` declaration: a subject named in
  the body is one the frontmatter declares, or the frontmatter gains it.
- A passage that names where a stage *writes* a record names the store, and the name it gives
  the file is the readable one that record would have had — a destination is the one kind of
  reference that keeps a path, and it is not an exception to the rule but the other side of it.
- `configure` is untouched here — it is `05`'s, together with the router table it installs.

## Blocked

This was blocked on where a stage writes a record it creates and what it is called. `07`
answers it: the store is flat, a repository's record keeps whatever readable name it would
have had, and the id rather than the name is what addresses it. A destination therefore
changes directory and keeps its name.
