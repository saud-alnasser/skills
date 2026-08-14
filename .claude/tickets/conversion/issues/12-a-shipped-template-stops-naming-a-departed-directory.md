---
owner: repository
title: "fix(configure): a shipped template stops naming a departed directory, and the guard checks naming rather than writing"
status: superseded
blocked-by: []
superseded-by: addressing/05, addressing/06 (the whole `addressing` effort, ADR 0105)
part-of: conversion
---

## Problem

Four templates under `skills/configure/` send a reader to directories the 2.0 conversion
deletes. `protocol.template.md` is the worst: its stage table names `.claude/policies/*.md`
for all eight stages, and its prose names `.claude/modes/`, `.claude/contexts/repository.md`,
`.claude/decisions/map.md`, and `.claude/tools/git.md`. `placement.template.md` enumerates
the departed set as what `.claude/` holds, `precedence.template.md` ranks
`.claude/contexts/repository.md` at rank 3, and `engineering.template.md` sends a reader to
`.claude/tools/` for every tool reference.

These five files are installed verbatim, so a conversion run deletes those directories and
then writes a router pointing into them.

A guard for this exists and its subject is one axis too narrow. `no shipped instruction
names a departed directory as a destination` matches only where an instruction says a run
*writes* — a leading-bold bare path, or the words *installed at*. Every reference above is a
place a reader is sent to *read*, so the guard passes. The criterion it was built for says
*names*, not *writes to*.

The stale form is also pinned: the router row's third column is read by nothing at runtime —
the assembler resolves only the stage and posture columns — and by one assertion, which
requires each row to contain `policies/<guide>.md`. Correcting the template fails the build.

## Outcome

Nothing under `skills/configure/` sends a reader to a directory the specification says has
left, except the pages whose subject is the conversion itself. The router's third column
names the records a stage receives rather than the files it once loaded, and the build fails
when that column and the store disagree — the column is read by no running code, so nothing
else would notice it drifting.

## Acceptance

- No shipped file names `.claude/` followed by a departed directory in any position — a
  destination, a pointer, or prose — and reintroducing one fails the build naming the file
  and the line.
- The guard's exemptions are enumerated by filename, each with the reason it is exempt, and
  a file exempted for no stated reason fails the build. A blanket skip of the configure
  directory is not an exemption.
- The router's third column names the subjects of store records, and a stage whose column
  and a query over the store disagree in either direction fails the build, naming the stage
  and each subject on the side it appears.
- A guide a skill declares that its stage's column omits fails the build, naming both.
- Entering a stage still resolves that stage's posture from the router table, unchanged by
  the column's new content.
- The bullets below the table say how a tool reference is reached now that it is a record
  with no firing condition, rather than describing a row that once carried one.

## Blocked

Two findings, either of which alone stops this.

**The subject is 28 files and 248 references, not four templates.** The design read the
defect off the templates and sized it there. Every spine skill names departed directories as
live load targets — `skills/implement/SKILL.md` alone carries 11 `.claude/policies/` and 10
`.claude/tools/` — as do all five agent definitions and six of the Primitives and On-ramps.
Excluding the three configure pages whose subject is the conversion itself, 28 shipped files
are affected. The first acceptance criterion says *no shipped file*, so the widened guard
fails against all of them the moment it lands; the ticket cannot be built as written.

**And the fix is not path substitution, which is what makes this design work rather than a
large edit.** At 2.0 a stage's row is delivered, so a spine skill naming a file to load is
wrong in a second way that survives correcting the path: there is no load target to name,
whatever directory it lives in. What each of those 248 sites says *instead* — a bare record
subject, nothing at all, or a pointer to the query for the three cases delivery excludes —
is a question about how a skill addresses the store, and it was never asked. Answering it
here would be redesigning past the discovery.

**A third finding, smaller, is about this ticket rather than the release.** The guard shape
the first criterion specifies — `.claude/` followed by a departed directory — cannot see
`placement.template.md`, which names the departed set as bare words in prose. That file is
one of the four the Problem section above names, so the criterion does not catch one of its
own stated subjects. Whatever replaces this ticket needs a guard whose subject is the
departed *concept*, not one path spelling of it.

