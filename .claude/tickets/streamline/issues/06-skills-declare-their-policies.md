---
owner: repository
title: feat(skills): each skill declares the guides it reads
status: resolved
blocked-by: [03]
part-of: streamline
---

## Problem

A skill establishes what it needs by restating it. There is no line at the top of a skill saying which guides apply, so the same machinery is rebuilt in each skill's own words — which is both the duplication the framework exists to prevent and the reason understanding is reconstructed on every invocation.

## Outcome

Every skill names the guides it reads, near the top, as pointers. Reading a skill therefore tells you what else to read before acting, and a skill read in isolation still says what it depends on. The declaration is body text rather than frontmatter, because nothing in the harness would act on a frontmatter field and a second place to keep true is the failure mode.

## Acceptance

- Every skill that reads a guide names it, and every guide named by any skill exists — asserted, so a renamed guide breaks the build rather than a run.
- A skill names only guides it actually reads.
- No skill restates the substance of a guide it points at.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

### Built

The declaration and the protocol's routing table are two expressions of one mapping, and this ticket is where the second one arrives — so it is also where they are checked against each other, in both directions. **They had already drifted in three places.** Two were real defects rather than bookkeeping: `/design` and `/commit` both branch on whether the tracker is shared, and neither pointed at the one file that records the answer.

`/configure` declares the directory rather than a list, because it reads every guide. Enumerating them would make a tenth guide a tenth edit.

### Two API guesses, both mine, both in one ticket

**`[regex]::Replace(input, pattern, replacement, 1)`** — the static overload's fourth parameter is `RegexOptions`, not a count, so `1` means `IgnoreCase` and every match was replaced. It put a second declaration inside two write-up templates, where it read as part of what a user copies. There is now an assertion that no skill declares twice.

**`$Input` as a parameter name** in the mutation harness — a PowerShell automatic variable, so the function returned nothing and wrote empty files. Every case reported as caught, by a null-reference exception rather than by the assertion aimed at it. **The harness said six guards were proven and none were.** A mutation run that reports success without naming which assertion fired is not evidence; the re-run names one per case.

Both are the standing rule against guessing an API. Neither would have been caught by the suite, because both were in the tooling around it.

### Healed while here

An empty file made the suite throw `Value cannot be null` instead of reporting findings — discovered because the broken harness produced one. Ten sites read skill files directly; all now go through one helper that yields an empty string. An empty file is a real failure and now reads like one.
