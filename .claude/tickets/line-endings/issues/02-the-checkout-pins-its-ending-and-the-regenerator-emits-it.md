---
title: 'fix(verify): the checkout pins its line ending, and the regenerator emits it'
status: open
blocked-by: [01]
part-of: line-endings
---

## Problem

The tree pins no line ending, so the bytes a contributor holds are a function of
their own conversion setting: one state on a platform that converts, another
where it does not, and a third where a contributor has set conversion to input.
Three reachable states for one commit.

The index regenerator emits the platform's ending, while the specification it is
derived from requires the checkout's. Those agree under exactly one of those
three states. Under conversion set to input they disagree, and the byte
comparison guarding every generated index fails — reporting a stale index, which
is the misdiagnosis the script's own comment claims to prevent.

The defect was recorded as a live limitation of the environment, closable by
pinning if anyone wanted to. Framed that way nothing acted on it for several
releases. It is a defect in the script: the specification asks it for a value
that nothing in the repository makes obtainable.

## Outcome

Every contributor materialises the same bytes for the same commit, whatever
platform they are on and whatever their local conversion setting says. The
divergence stops being invisible-until-someone's-suite-disagrees, because there
is nothing left to diverge.

The regenerator emits the ending the checkout actually holds, so the comparison
guarding every generated index succeeds for everyone rather than for whoever
matches the author's configuration. The recorded limitation is closed, and closed
as what it was — a defect in a derived script, not a cost of the environment.

Nothing AEP ships moves. The specification already covers both the pinned and the
unpinned case, and a repository that pins nothing keeps the behaviour it
describes.

The renormalisation is its own change containing nothing else, so a substantive
edit cannot hide inside a diff that touches every file, and a contributor whose
tooling objects to the pinned ending can revert one commit without restoring the
assertion that ticket 01 fixed.

## Acceptance

- Two clones of the same commit hold byte-identical files, on any platform and
  under any local conversion setting.
- The regenerator emits the ending the checkout holds, and the byte comparison
  guarding every generated index succeeds under any such setting.
- Stored content is unchanged — the pin rewrites no history, and only what
  checkout materialises moves.
- Nothing binary was normalised.
- The renormalising change contains nothing else, and the suite is green before
  it and after it.
- The recorded limitation is closed, naming what closed it and recording it as a
  defect in the script rather than a property of the environment.
- The suite fails when the script emits an ending the pin does not match,
  confirmed against a deliberate reintroduction and then restored.
- No file AEP ships changed.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
