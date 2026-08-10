---
owner: repository
status: implemented
sources:
  - scripts/verify.ps1
  - .claude/scripts/regenerate-indexes.ps1
  - .claude/tickets/declared-fields/issues/05-the-index-regenerator-and-its-comparison.md
  - skills/configure/SCRIPTS.md §What every derived script owes
  - .claude/decisions/0069-this-repository-pins-its-checkout-ending-so-a-derived-script-can-emit-it.md
---

# fix(verify): make the checkout's line ending knowable, and stop assertions depending on it

## Problem

Two defects, and the second was recorded years-of-releases ago as a property of
the environment rather than as the bug it is.

**Assertions read frontmatter with a pattern that cannot match on a CRLF
checkout.** Anchoring to the end of a line with a class matching only spaces and
tabs leaves the carriage return unconsumed, so the field reads as absent. The
release assertion does this and fails now: three sources state the same version
and the suite reports them as disagreeing. A false failure is worse than a
missing assertion — it points at a file that is correct, and it teaches a reader
to discount the suite.

**The index regenerator emits the platform's line ending while the specification
it is derived from requires the checkout's.** Those coincide only under one
configuration — automatic conversion enabled, on Windows — which is this
machine by accident of a system-scope setting. Under conversion set to input the
checkout holds one ending and the script writes the other, and the byte
comparison that guards every generated index fails as a stale index. That is
precisely the misdiagnosis the regenerator's own comment claims to prevent.

The second was written down as a live limitation of the repository, to be closed
by an attributes file nobody had asked for. That framing is wrong, and it is why
nothing acted on it: the specification's rule is implementable only if the
checkout's ending is knowable, and nothing makes it knowable. **The script is
defective in a configuration nobody has run, and the limitation is the shape of
the defect rather than an environmental cost.**

Both defects share one root: the tree pins nothing, so what lands on disk is
whatever each clone's configuration produces.

## Goal

Every clone materialises the same bytes, on every platform and under any local
conversion setting; the derived script emits the ending the checkout actually
holds; and no assertion's verdict depends on either.

## Constraints

- **Contributor divergence is the thing being removed**, not traded away. Any
  outcome where two clones of the same commit hold different bytes fails this.
- **Nothing shipped changes.** The scripts specification already covers both the
  pinned and unpinned cases correctly; the defect is in this repository's derived
  script, which treated the unpinned case as permanent.
- Stored bytes are already normalised, so pinning rewrites no history and the
  change is confined to what checkout materialises.
- The renormalising change must be separable from the behavioural one, or a
  substantive edit hides inside a diff touching every file.

## Architecture

Three layers, and only the first two are load-bearing for correctness.

The **pin** is a repository-level attributes file fixing the working-tree ending,
which overrides each contributor's local conversion setting and makes the
checkout's ending a fact rather than a function of configuration.

The **emission** follows: with the checkout's ending knowable, the derived script
emits it, which is what its specification asked for all along.

The **hardening** makes assertions indifferent to the ending regardless. It is
not made redundant by the pin — it is what keeps the suite green while the pin
lands, and what stops a file outside the pin's reach from reintroducing the
failure.

## Approach

Harden first. It fixes the failing assertion immediately and on the tree as it
stands, which means the renormalising change can be judged against a green suite
rather than a red one. It also unblocks every other ticket in every other effort,
each of which ends its acceptance with the suite passing.

Pin second, as its own change containing nothing else, with the script's emission
moving in the same change — the two cannot be separated without leaving a window
where the script writes an ending the tree no longer holds.

Rejected, and recorded in the Decision rather than re-argued here: pinning only
the generated indexes, and hardening alone with no pin.

## Acceptance criteria

- Two clones of the same commit hold byte-identical files, on any platform and
  under any local conversion setting.
- The derived script emits the ending the checkout holds, so the byte comparison
  guarding every generated index succeeds under any such setting.
- No assertion's verdict depends on the line ending of the tree it read.
- The suite passes before the renormalising change and after it.
- The renormalisation is its own change and contains nothing else.
- The limitation recorded against the regenerator is closed, naming what closed
  it, and recorded as a defect in the script rather than a cost of the
  environment.
- The suite fails when an assertion reading a field is written in the fragile
  form, and when the script emits an ending the pin does not match — each
  confirmed against a deliberate reintroduction and then restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Risks

**A contributor's tooling objects to the pinned ending.** Detection: the pin
lands as its own change, so reverting it costs one commit and leaves the
hardening — the half that fixes the failing assertion — untouched.

**The renormalisation hides a substantive edit.** A change touching every text
file makes one real edit invisible. Detection: it is its own commit containing
nothing else, made against a suite already green.

**The guard matches the correction rather than the defect.** A pattern written
from the new wording passes while the old form sits elsewhere. Detection: anchor
each guard to its subject — an assertion reading a field, and the script's
emitted ending — and confirm each fails against a deliberate reintroduction
before trusting it.

**A file escapes the pin.** Binary content must not be normalised, and automatic
detection is what prevents it. Detection: compare the tree's reported endings
before and after, and confirm nothing binary moved.

## Out of scope

- Any change to what AEP ships. The scripts specification is already correct.
- Changing which endings the specification permits a derived script to emit.
- Repairing any other repository's checkout.
