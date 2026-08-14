---
owner: repository
title: "feat(verify): the position report ships as code rather than as a description"
status: resolved
blocked-by: [02]
part-of: conversion
---

## Problem

Every stage that opens with verification quotes the position report's output, and the report
is the one script whose correctness nothing else can second-guess: its output is not a
tracked file, so there is nothing to regenerate and compare it against. A wrongly written one
emits a confident wrong fact that a stage then quotes as authority.

It is currently specified as behaviour for each repository to re-implement, which puts that
risk in every repository rather than in one place. This repository has a working
implementation, so this is the one of the five scripts where a port can be checked against
something real rather than only against a fixture.

## Outcome

The position report ships as code and is copied like every other script. It checks the
marker's two facts against the live two, takes both drift reads when either differs, prints
the position half of the verification report, and writes the receipt the commit stage
refuses without.

## Acceptance

- The shipped script reproduces the working implementation's output byte for byte on the
  same repository state, for a match, a commit mismatch, a tree mismatch, and a marker that
  is not an ancestor.
- Its fixture cases pass, including the one that exercises the run identity being present
  and the one that exercises it being absent.
- What it emits on standard output is ASCII, and what it writes is UTF-8 without a byte-order
  mark, with the checkout's line ending.
- A receipt taken without a run identity is written as such, so a reader can tell the weaker
  attestation from the stronger one.
- The build runs the fixture and fails on a mismatch.
