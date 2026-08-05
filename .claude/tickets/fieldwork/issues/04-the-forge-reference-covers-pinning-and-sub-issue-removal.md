---
title: feat(tools): the forge reference covers pinning and sub-issue removal
status: resolved
blocked-by: []
part-of: fieldwork
---

## Problem

The maps policy requires the map to live as a pinned issue on GitHub, and the forge reference has no entry for pinning — the operation the policy itself mandates is a guessed flag away. Sub-issue removal is mentioned in passing (the singular-path trap) but given no invocation, and it is needed the moment a ticket turns out not to belong under its parent — exactly what happened in the field.

## Outcome

Shipped behaviour. The forge reference gains the pin and unpin entries, with the at-cap behaviour — GitHub caps pinned issues per repository — explicitly marked untested rather than asserted, because the help text does not document whether pinning at cap refuses or evicts. It gains the sub-issue removal invocation with both recorded traps: the id-not-number distinction shared with the attach call, and the integer-typing flag.

## Acceptance

- Pinning and unpinning are documented invocations, and the at-cap entry says untested rather than guessing either behaviour.
- Sub-issue removal is an invocable entry naming the singular path, the id-not-number trap, and the integer-typing flag.
- The suite asserts both entries exist in the shipped reference.
- The suite passes.

## Comments

Landed as an amend to the shared `fieldwork` commit — the effort is one unit of work by the user's standing instruction. `gh issue pin`/`unpin` and the `-f`/`-F` typing were re-verified against the installed CLI; the attach call's own `-f` was healed to `-F` in the same pass, since the field evidence records the typing trap as shared and the entry would otherwise ship the bug it warns against. Review: Spec axis clean on all criteria, attach heal judged in scope; Standards' two findings fixed — the pin cap is now cited to GitHub's docs (three per repository, fetched this session; the docs are silent on at-cap behaviour, so untested stands), and the integer-flag assert is bound to the DELETE invocation itself, plant-proven against the removal entry losing its `-F` line. "The suite passes" holds with the standing recorded exception, `layout/04`, ticketed as 08.
