---
title: 'fix(verify): the checkout pins its line ending, and the regenerator emits it'
status: resolved
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

## Comments

**The defect was reproduced before it was fixed, rather than reasoned about.**
With the pin in place and the script still emitting the platform's ending, the
byte comparison failed `contexts/map.md differs in length: committed 467 B,
regenerated 474 B` — 7 lines' worth of carriage returns, reported *as a stale
index*. That is the misdiagnosis the script's own comment claimed to prevent,
observed rather than predicted.

**There was no renormalising change to keep separate.** The spec and the ADR
both say stored bytes were already normalised; `git ls-files --eol` reported all
351 tracked files `i/lf`, and `git add --renormalize .` after the pin staged
nothing. So the criterion asking that the renormalisation contain nothing else
is satisfied vacuously, and the risk it guarded — a substantive edit hidden in a
diff touching every file — never arose. The whole change is four files.

**Nothing binary was normalised because there is nothing binary.** No tracked
file reports `i/-text`. That makes the tree a poor witness for the property, so
the assertion checks the *mechanism* — `text=auto`, so git decides per file —
rather than counting today's contents. The damage from forcing `text` would land
on whoever adds the first binary file, and a count would not be watching then.

**The working tree was refreshed, not just the attributes.** Attributes govern
what checkout materialises, and checkout only rewrites files whose blob differs
— so the pin alone leaves stale bytes on disk. `git rm --cached -r . && git
reset --hard` took the tree from 215 CRLF / 130 LF / 5 mixed to 350 LF. That the
tree was already inconsistent *within one clone* is the divergence this ticket
describes, seen without needing a second contributor.

**`git check-attr --stdin` is unsafe from PowerShell, and the suite does not use
it.** A PowerShell pipe joins its input with the platform's ending, so a path
arrives as `scripts/verify.ps1\r` and git answers about a file of that name.
Under `*` it answers correctly anyway, which is worse than failing — the wrong
question returns the right answer until the pattern narrows. Verified by running
it and reading git's own echo of the quoted path; the assertions pass paths as
arguments, batched.

**Four assertions, four fire-checks, seven mutations.** The pin removed
entirely, and narrowed to `*.md` so part of the tree stayed unpinned; `text`
forced instead of auto-detected; `[Environment]::NewLine` reintroduced; and each
of the record assertion's three conditions broken on its own. Every mutation
failed the assertion that owns it and no other, each with its own message, and
all were restored.

**One bound the emission check cannot cross, stated in the assertion rather than
discovered later.** Where the pin names the running platform's own ending, the
defect and the correct answer produce identical bytes and no behavioural check
can separate them. It fires here — Windows under an LF pin — which is the
configuration the defect was invisible in.

**Two comments elsewhere in the suite asserted a checkout that no longer exists
and were healed in the same pass**: one said the ignore-file comparison
normalises because the file "is checked out with the platform's", the other that
"the files are CRLF". The normalisation and the pattern shape both stay — the
hardening is deliberately not made redundant by the pin — so only the reasons
were rewritten.

**`/review` was skipped at the user's direction.** The close-out normally runs
both axes first. It did not run here, so nothing independent has read this diff;
the guards above rest on their author's own fire-checks.
