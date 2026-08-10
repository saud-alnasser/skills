---
owner: repository
title: 'chore(contexts): the taxonomy names its third category, and a spent guard goes'
status: resolved
blocked-by: []
part-of: axis
---

## Problem

Skills divide into three groups and the knowledge layer defines two. The third
is named only in a ticket and a status file, so an inconsistency inside it — the
same category answering the invocation question two different ways — had nothing
to be measured against and sat unnoticed until the entry table exposed it.

The definition that does exist is wrong in a way the missing one explains. A
primitive is defined as a model-invoked skill with no stage of its own and then
enumerated as four; two skills outside that enumeration satisfy the definition
exactly, because they belong to the category nobody wrote down.

Separately, a guard in the suite matches a prose form that a later effort
deleted from every skill. It matches nothing, skips every stage it iterates, and
returns success — reading as coverage while checking nothing. It is superseded
in fact by a later assertion that does the same job against the field form, so
the risk is not an unguarded rule but a green result nobody can interpret.

## Outcome

Every skill belongs to exactly one named category, and the categories are
defined where Context can reach them.

The spent guard is deleted rather than repaired, because the assertion that
replaced it already covers both directions of the same containment.

One ticket outside this effort is marked superseded: the migration ticket whose
work was absorbed by the later layout effort. It is unblocked and would
otherwise be claimed by the next build that names no ticket.

## Acceptance

- The knowledge layer defines all three skill categories, and every skill in the
  tree belongs to exactly one.
- The primitive definition and its enumeration agree.
- No assertion in the suite matches a form that no longer exists in the tree.
- The superseded ticket carries a reason and is off the frontier; it is not
  deleted.
- `pwsh -NoProfile -File scripts/verify.ps1` passes, with no fewer assertions
  than it has today except the one deliberately removed.

## Comments

**The taxonomy has four categories, not three.** The ticket assumed three because
three were in evidence — spine, primitive, and the on-ramp the tickets named. The
count did not close: seven spine, four primitives and five on-ramps account for
sixteen of seventeen skills, and the seventeenth is `help`, which is none of them.
It performs no stage, is composed by nothing, and carries no arriving work.

It is defined as a **Router**, a category of one, rather than being filed under
on-ramps to make the number come out. A category of one is a smell only where the
member could have company; this one cannot, because what makes it odd is that its
subject is the framework itself — and ADR 0015 had already found the same
uniqueness from the other end, when it turned out to be the only skill whose name
could not be the framework's.

The acceptance criterion above says three, and is left as written. The build
discovering a fourth is the ticket being wrong about the tree, not the tree being
wrong.

**The specification disagreed with Context and was amended.** `specs.md` §11 filed
grilling and domain modeling as on-ramps and bug diagnosis and merge-conflict
resolution as primitives — the reverse of what the definitions imply and of what
the suite's own `$onramps` list has always held. ADR 0029 puts the amendment in
this change rather than in a follow-up.

