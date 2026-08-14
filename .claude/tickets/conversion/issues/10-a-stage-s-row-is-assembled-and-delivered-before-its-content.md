---
owner: repository
title: "feat(delivery): a stage's row is assembled and delivered before its content"
status: resolved
blocked-by: [03, 09]
part-of: conversion
---

## Problem

A stage's guides arrive as whole files loaded by name, and only about half of what arrives
is labelled for the stage that loaded it. The rest is paid for and ignored. The design that
fixes it — every norm whose firing condition matches this stage, assembled and inlined
before the skill's content reaches the model — is specified and has never been run against a
real corpus by anything shipped.

It carries the one failure mode in this effort with no safe default. Unguarded, a non-zero
exit from the assembler aborts the whole stage and the model receives nothing at all, its
own instructions included. Guarded, the shell's error text arrives inlined into the row as
prose with nothing reporting it. Both are worse than a row that is merely wrong, and the
choice between them cannot be deferred to whoever hits it.

## Outcome

One shipped script assembles a stage's row from the store and emits it as several commands,
each under the measured cap, arriving in computed precedence order. Its failure mode is
chosen deliberately, stated where a reader will find it, and exercised by a fixture that
makes the command fail.

## Acceptance

- Entering a stage delivers every norm whose firing condition matches it and no norm whose
  condition does not, and a reader can tell from the delivered row which stage it was
  assembled for.
- The row arrives whole and inline, with no substitution withheld for a preview and a path.
- The number of commands emitted is the smallest that keeps every one under the measured
  cap.
- The row arrives in the store's computed precedence order.
- A failing assembler produces the chosen outcome rather than the other one, demonstrated by
  a fixture that makes it fail, and what the stage receives in that case is stated on the
  page a reader would open.
- A stage's row measured against the file-list row it replaces has its dropped set inspected
  rather than trusted, and anything dropped that should have arrived is a finding.

## Declared increments

- after the assembler emits a row: what disabling inline shell execution does to a stage
  that depends on it — type: prototype
- after the assembler emits a row: whether a tool-call hook's result reaches context, and
  whether that changes which channel the boot tier uses — type: prototype
