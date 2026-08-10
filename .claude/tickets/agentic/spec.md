---
status: implemented
reconstructed: true
sources:
  - .claude/tickets/agentic/issues/01-rename-the-expansion-to-agentic.md
  - .claude/decisions/0034-the-rename-to-agentic-stops-at-frozen-records.md
  - README.md
  - NOTICE
  - specs.md
  - skills/configure/migration-changelog.md
---

# docs(skills): rename the expansion to the Agentic Engineering Protocol, and release the specification at 1.2.0

> **Reconstructed after the fact.** This effort landed without a spec, and the
> design index is generated from specs — so it spanned one fewer effort than
> existed, and nothing reported the gap. This file was written afterwards to
> close it.
>
> **It is not a record of what anyone intended.** Every statement below is
> derived from the effort's own resolved ticket, the Decision it produced, and
> what is in the tree; where reasoning is not recoverable from those, this says
> so instead of supplying one. A reconstruction that reads like a contemporaneous
> spec is worse than the missing row, because it invites decisions to be traced
> to reasoning nobody had.

## Problem

The framework's acronym expanded to the wrong first word — *AI* where it should
have been *Agentic*. The intended expansion was the **Agentic Engineering
Protocol**: a change to three words of prose, with the acronym, the plugin id, the
command namespace and every path unmoved.

The old expansion is deliberately not written out here. A guard forbids it in
every live file, and this file is live — which is itself part of what the effort
built, and a reader who greps for it will find it only where it was left on
purpose.

Two things made it more than a search and replace, and both are recoverable from
the ticket.

Some occurrences sat in **frozen records** — an accepted Decision, and a resolved
effort's tickets. This repository's own rules forbid editing those: a committed
Decision's reasoning is frozen and only its status moves, and history is not
repaired. So the old expansion stays greppable forever, and without an
explanation and a guard the next person to grep it reads deliberate residue as a
missed occurrence and finishes the job.

Repositories already configured by AEP carry the old expansion in their installed
protocol file, where nothing routes on the sentence and so nothing would ever
notice it was stale.

## Goal

The framework is called the Agentic Engineering Protocol everywhere it is alive;
the specification leaves draft at 1.2.0 with the manifest agreeing;
the record of its two former names is readable without opening the history; and
the frozen records that still carry the old expansion are protected by a test
rather than by intention.

## Constraints

- The acronym, the plugin id, the `/aep:` namespace and every path stay
  byte-identical. A reader who had only the acronym cannot tell the rename
  happened.
- Frozen records are not edited. That is what forces the residue to be explained
  and guarded rather than removed.

## Architecture

Where the change landed is readable from the tree: the shipped manifests, the
specification, the entrypoint, the protocol router, this repository's Context,
and the installed protocol template, plus an audit branch that reaches an
already-configured repository.

## Approach

Two alternatives were weighed and rejected, and the Decision this effort produced
records both.

**Renaming the frozen records as well** would have made the sweep complete and
left nothing to explain or guard. It was rejected because it rewrites an accepted
Decision's committed prose — the one edit the decisions policy forbids outright —
and erases the record that the framework ever carried the former name, which is
the fact a reader of the earlier effort most needs.

**Healing already-configured repositories from the migration guide** rather than
from the audit branch was rejected because that guide is opened only when another
workflow is found or the layout is superseded. A repository on the current layout
carrying a stale word is neither, so the row would have been written and never
reached.

Ordering within the effort is not recoverable — the ticket records none, and the
commit that landed it is a squash.

## Acceptance criteria

Carried over from the effort's ticket, which is the only contemporaneous
statement of what done meant:

- Every live file naming the framework expands the acronym as Agentic.
- The acronym, plugin id, namespace and paths are unchanged.
- Three named frozen records still read the old expansion.
- `README.md` and `NOTICE` name both former names in order, so residue is
  distinguishable from drift without opening the history.
- The migration guide's account of the earlier rename holds across both and needs
  no edit at the next one.
- A `/configure` audit heals an already-configured repository and reports nothing
  on one already current.
- The specification states version 1.2.0 with no draft marker, and the plugin
  manifest states the same version.
- The suite fails if a live file regains the old expansion, and separately if any
  of the three frozen records loses it.
- The full suite passes.

## Risks

Not reconstructed. A risk register records what its author feared at the time,
and inventing one now would be the failure this file's header exists to prevent.

## Out of scope

- The acronym itself, and everything keyed to it.
- The frozen records, which keep the old expansion permanently.
