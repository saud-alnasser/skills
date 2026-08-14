---
owner: repository
title: "feat(configure): the configuration stage stops installing what is no longer copied"
status: resolved
blocked-by: [04, 05]
part-of: conversion
---

## Problem

The configuration stage's own instructions contradict themselves inside a single step. It
declares which directories have left, then spends eight paragraphs installing files into
five of them. It still wires the index regenerator and the check that compares a regenerated
index against the committed one — both retired at 2.0.0 with the committed indexes they
existed for. It still tells the stage to prove each derived script against a fixture before
trusting it, which is an obligation that belongs to code that is derived.

A reader following it end to end reaches a step that cannot be carried out, and the first
sign of that is a configuration run that half worked.

## Outcome

The stage writes what must exist in the tree and runs the migration, and nothing else. What
must exist is the three surfaces the harness finds by name and the copied scripts. Every
check it used to perform is the build's, and where a check moved rather than vanished the
instructions say which — a check that moved and a check that disappeared must never read the
same.

The audit branch reports what the build said rather than performing a second pass of its
own, keeping only what a build cannot know: the repairs that depend on which release
configured a repository, and the pruning, because it deletes.

## Acceptance

- A configuration run against an unconfigured repository produces a working installation,
  and every file it writes outside the store is one the harness finds by name or a copied
  script.
- No step instructs the stage to install into a departed directory, to derive a script, to
  run a script against a fixture, or to wire a regenerate-and-compare check.
- Every check the stage performed in 1.x either fails the build in 2.0, demonstrated one
  check at a time, or is named as removed with its reason.
- Running the stage twice changes nothing the second time.
- A reader can follow the stage's instructions from start to finish without reaching a step
  whose destination does not exist.
