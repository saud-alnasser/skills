---
title: 'fix(design): protocol-only work is refused where it is created, and the test reads the diff'
status: resolved
blocked-by: []
part-of: downstream
---

## Problem

The ticket format says a shared tracker never carries protocol-only work, and the
design stage is told to check it — *a set still containing one is a set-cutting
error, caught here while nothing has been created*. It has been violated three
times in one configured repository, every time by the workflow itself, and every
time the violation was noticed only after the issue was published. One of the
three was closed as completed, so the mis-filing was never noticed at all.

A rule caught after publication three times running is not being enforced where it
is stated. Creating an issue publishes; the check sits upstream of that and does
not fire.

There is also an ambiguity that made the third case arguable. The rule speaks of
work whose *whole effect* sits under the protocol directory, which is a statement
about outcomes — but a reader checking it reaches for the file list, and that
issue's fix would have touched a workflow file outside the directory while its
outcome was protocol-only. The rule and the evidence a reader consults are not the
same thing.

## Outcome

The test is stated as the diff, because that is what a reader actually consults
and what the version-control policy already uses to identify the one pull request
allowed to change nothing outside the protocol directory. Outcome-shaped wording
invites two readings; the diff has one.

The check fires where the tickets are created rather than where the set is drafted,
so the last moment before publication is the moment it runs.

## Acceptance

- The protocol-only test is stated against the diff rather than against the
  outcome, in the ticket format.
- The check runs immediately before creation on a shared tracker, not only while
  the set is being drafted.
- The wording covers the case where a protocol-only outcome requires a change
  outside the protocol directory, and says which way it falls.
- The suite fails when the test is stated only as an outcome, confirmed against a
  deliberate reintroduction and then restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
