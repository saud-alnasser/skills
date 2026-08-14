---
owner: repository
title: "fix(configure): every framework template declares the release that ships it"
status: blocked
blocked-by: []
part-of: conversion
---

## Problem

A framework template's `version` is documented as correct by construction, because the
template ships with the release that ships it. Three of the five declare `1.19.0` while
shipping inside a `2.0.0` plugin, and the two declaring `2.0.0` carry content naming
directories that release deletes — so the stamp is false in both directions at once, and a
reader cannot tell a template that legitimately did not need changing from one nobody
updated.

Nothing asserts it. The only release-stamp assertion in the suite has the opposite subject:
it checks that a *derived* template carries no stamp at all.

## Outcome

Every template declaring framework ownership carries the release currently shipping, and
the build refuses a release whose templates were not restamped with it — so the stamp
cannot go stale silently, which is the state that produced this.

## Acceptance

- Every template declaring `owner: framework` carries a `version` equal to the version in
  the plugin manifest.
- Raising the manifest's version without restamping fails the build, naming each template
  with the version it carries and the version it should.
- A template declaring `owner: repository` still carries no stamp, and the existing
  assertion saying so is unchanged.
- The stamp's meaning is stated where a reader of the template would find it, and says the
  stamp records the shipping release rather than the release the content last moved at.

This ticket was blocked on `12` while the stamp was thought to assert something about the
body. It does not: under the meaning above it records which release is shipping, which is
true of a template whose prose has not yet been corrected. The edge is removed rather than
carried, so this does not wait on the `addressing` effort.

## Blocked

**The meaning this ticket assigns the stamp is the one an accepted decision rejected, with
reasons, and the design run never put those reasons in front of the choice.**

ADR 0080 defines `version` as *"the release in which that file's content last changed"* and
`specs.md` line 127 states the same — *"the release that last changed its content, a
Declared Field that routes a reader's attention and settles nothing."* The acceptance above
requires the opposite: every framework template stamped with the release currently shipping.

ADR 0080 did not merely fail to consider that; it **considered and rejected it**. Its
consequences section reads *"Initial values are recovered from history rather than stamped
uniformly, on the same recovered-evidence footing ADR 0065 established, with the earliest
plausible release winning where evidence is thin — an over-old stamp invites a look, an
over-new one forecloses it."* Its whole case for the field is that it routes attention, and
a stamp identical on every file routes attention nowhere.

That argument may still lose — a field that cannot be asserted rots, which is how two
templates came to carry `2.0.0` over 1.x content, and ADR 0080 itself says *"an unenforced
indication rots into a lie aimed at the exact reader it exists for."* But it is a decision
between two stated positions, and it needs the ADR superseded in the same change.
`/implement` may not write Decisions, so it cannot be made here.

The design run is where this belonged. It offered uniform stamping as the recommended option
without surfacing that an accepted decision had already rejected it — the reasoning above
was available and was not read before the question was asked.
