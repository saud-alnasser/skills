---
owner: repository
title: 'refactor(help): the router explains the workflow instead of routing to it'
status: resolved
blocked-by: []
part-of: axis
---

## Problem

The router's stated purpose is sending a human to the right command, organised
by how the work arrived. The boot-tier entry rule now does exactly that, so the
same job is stated in two places — and the two disagree, because only one of
them was updated when planning became selectable. The router still says only
two commands are typed by habit and names planning as one of them.

It is also withheld from selection, so the question it answers — how does this
workflow fit together — cannot reach it.

## Outcome

Asking how the workflow is used produces an explanation of it.

What the file carries is what nothing else does: what this workflow is, which
skills a human still types and why they are the exceptions, and how everything
else arrives without being named. The routing table goes, because routing has a
home and this is not it.

It becomes model-invoked, since a user with that question describes it rather
than naming a command. Its description has to distinguish a question about the
workflow from a question about the repository's own code, which is the failure
mode worth guarding: those two questions are one sentence apart.

## Acceptance

- Asking how the workflow is used, or which parts of it a human drives, produces
  the explanation without a command being typed.
- Asking how this repository's own code works does not produce it.
- The file names no command as the thing to type for work the entry rule routes.
- The two skills that remain typed are named, with the test that exempts them —
  not a list to be extended by resemblance.
- Nothing in the file claims planning is typed by habit.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
