---
owner: repository
title: "fix(configure): the installed templates conform, and the router's column names records"
status: resolved
blocked-by: [01]
part-of: addressing
---

## Problem

The templates are the sharpest case in the effort, because they are installed verbatim: a
conversion run deletes `.claude/policies/` and `.claude/modes/` and then writes a router
pointing into both. `protocol.template.md` names departed directories in its stage table and
five more times in prose, and `engineering`, `precedence`, and `placement` name them too —
`placement` as bare prose words rather than as paths, which is why a guard written against
one path spelling would miss it.

The router's third column is a special case within that. It lists `.claude/policies/*.md`
per stage, nothing at runtime reads it — the assembler resolves only the stage and its
posture — and one build assertion requires the stale form, so correcting the template fails
the build until that assertion moves with it.

## Outcome

Every template installs a file that conforms to the release installing it, and the router's
table names the records a stage receives. The column is held to the store by the build,
because nothing at runtime reads it and its drift would otherwise be silent.

## Acceptance

- No template, and no configure page other than those describing the conversion, addresses a
  store record by location or names the departed set in prose.
- The router's third column names store record subjects, and a stage whose column and a
  query over the store disagree in either direction fails the build, naming the stage and
  each subject on the side it appears.
- A guide a skill declares that its stage's column omits fails the build, naming both.
- Entering a stage still resolves that stage's posture from the router table, unchanged.
- The bullets below the table say how a tool reference is reached now that it is a record
  with no firing condition, rather than describing a row that once carried one.
- The pages whose subject is the conversion still name the directories they convert.
