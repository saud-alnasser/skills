---
owner: repository
title: refactor(dist): rename the framework from Tenure to AEP
status: resolved
blocked-by: [01]
part-of: aep
---

## Problem

The plugin manifest, the `/tenure:` namespace, the README, the templates, the migration's self-recognition, and the shipped prose all name a framework that no longer exists under that name. Two names in circulation means every future file chooses one, and half of them choose wrong.

## Outcome

The plugin is `aep`, the commands are `/aep:*`, and the prose says the AI Engineering Protocol. History, license attribution, and the migration rows whose job is recognizing the old name are the only survivors of the old one — the same exemption class the legacy-path guard already defines.

## Acceptance

- The plugin manifest, marketplace metadata, README, and NOTICE name AEP; LICENSE attribution to upstream projects is untouched.
- Every skill, template, and guide that named Tenure or `/tenure:` names AEP or `/aep:`, and `verify.ps1` gains a guard that fails on a reintroduction of the old name outside the exempt files.
- The migration recognizes a repository configured under the Tenure name and converts its references, listed in the move plan like every other conversion.
- The tickets directory keeps its historical names — `tickets/tenure/` and `tickets/streamline/` are the build record, and rewriting history is not a rename.
- The user-scope instruction that offers `/tenure:configure` is updated to `/aep:configure` — noted for the human, since it lives outside this repository.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

Early on purpose: every later ticket rewrites prose, and prose rewritten once in the new name is the whole reason this precedes compression. The blast radius is textual, not behavioral — nothing changes what any stage does.
