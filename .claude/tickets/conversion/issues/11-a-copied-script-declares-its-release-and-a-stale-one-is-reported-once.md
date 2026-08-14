---
owner: repository
title: "feat(configure): a copied script declares its release, and a stale one is reported once"
status: resolved
blocked-by: [08, 09, 10]
part-of: conversion
---

## Problem

Copying reintroduces the fork the previous distribution model was chosen to avoid: a copy
diverges the moment the shipped one changes, and nothing reconciles them. The obvious repair
— have the repository's build compare its copy against the shipped source — is unavailable,
because the harness exports the plugin's root to a hook process and to skill content and
never to a stage's shell. A build cannot find what it would compare against.

A stale copy is also silent in the worst way. It runs, it produces confident output, and a
stage quotes that output as authority. Nothing about a wrong answer looks different from a
right one.

## Outcome

Each copied script declares the release it came from, and the session-start hook that already
compares the protocol file's release against the running one gains the same comparison for
the scripts. One line when they differ, nothing when they match. A repository without the
plugin loses a notification rather than a rule, exactly as it does for the protocol file.

What this catches is stated rather than implied: a copy left behind by an upgrade. It does
not catch a copy somebody edited, and the reason — the only surface that can see both sides
runs once per session and is not a diffing tool — is recorded where a reader would ask.

## Acceptance

- Every copied script declares the release it came from, and a configuration run writes that
  declaration rather than asking for it.
- A repository whose copies match the running release produces no output at session start.
- A repository holding a copy from an earlier release produces exactly one line naming what
  is stale and what repairs it.
- A repository with no copies, or with copies declaring no release, produces nothing —
  absence is unknown rather than stale.
- The hook stays silent for a repository that does not run this framework at all.
- The limit of the check — a hand-edited copy declaring the current release passes — is
  stated where the mechanism is described, not left for a reader to discover.
