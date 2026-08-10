---
owner: repository
title: refactor(agents): dispatched roles declare their mode under the same map
status: resolved
blocked-by: [01]
part-of: declared-fields
---

## Problem

All five files under `agents/` carry `mode:` at the top level of their frontmatter. The harness's subagent reference lists sixteen fields and `mode` is not among them, nor is `metadata` — the page makes no statement about unknown keys in either direction.

Nothing observably breaks: the roles load and their tool lists are honoured. But AEP is depending on undocumented behaviour for the one fact its orchestration reads off a role, and that dependency is currently invisible — it looks like a supported field because it sits beside supported fields. The finding is dated in `.claude/evidence/research/2026-08-05-frontmatter-extension-points-for-skills-and-agents.md`.

## Outcome

The roles declare their posture under `metadata.mode`, matching what tickets 01 and 02 established for skills. One rule, one form, both shipped surfaces.

This does not remove the undocumented dependency — no documented namespace exists on this surface — it reduces it to one place that ADR 0055 records, so a future reader finds a decision rather than an oversight.

## Acceptance

- No file under `agents/` carries a top-level `mode:` key.
- Every role declares `metadata.mode`, valued as one of the seven postures, asserted from the frontmatter rather than a list.
- The roles still load and dispatch — confirmed by running the suite and by a dispatch that reaches a role, not by inspection of the file alone.
- The same map-shape assertion from ticket 01 covers this surface; a scalar `metadata` fails here too.
- ADR 0055's record of the remaining undocumented dependency is accurate at close — if the harness turns out to reject the key, the ticket is handed back rather than worked around.

## Comments

**Every criterion is discharged, including the dispatch — after an earlier version of this note claimed it was impossible.** That claim was wrong, and wrong in the way this repository has a rule against: `.claude/tools/plugin.md` documents `claude --plugin-dir .`, which *"loads this directory as the plugin for that session"* and *"takes precedence over an installed marketplace plugin of the same name."* The impossibility was asserted from the observation that the harness had loaded the installed `aep/1.9.0/agents/` copies, without reading the committed tool guide that says how to override them. `/review` found it by running the command.

**What the probe established, and how it discriminated.** Listing the `aep:` roles under `--plugin-dir .` returned all five with their real descriptions. To prove the working tree was the source rather than the installed copy, one role's `description` was temporarily corrupted; that role alone came back as the placeholder *"Agent from aep plugin"* while the other four kept their text, which is only possible if the working-tree file determined the outcome. Re-run clean, all five load.

So the harness **accepts an unlisted `metadata` key in subagent frontmatter** — observed, at the version in use, not merely reasoned. ADR 0055 recorded this as deferred: *"an experiment would date a version-specific fact this decision does not turn on."* The experiment has now been run and it agrees with the decision. The ADR is committed and its reasoning frozen, so nothing there moves; this observation is worth graduating into evidence, which is `/design`'s to do and not this stage's.

**What `/review` found, and what happened to it:**

- **A dangling `$m` in a rewritten assertion — fixed.** The refactor removed the variable but not a reference to it inside a `throw`, so the tradeoff guard still fired but reported `Cannot index into a null array` instead of naming the role and the word. The property survived; the diagnostic did not, and a guard nobody can read the output of is a guard confirmed only by whoever ran the mutation that day.
- **Two comments stated facts nobody checked — fixed.** One claimed the mode was "asserted in one place instead of assumed in four" when five roles ship and this same diff adds two more assertions over them. The other claimed the two shipped surfaces "are read by different harness parsers"; the evidence file records two documented *field tables* and says nothing about parsers. The second assertion is worth keeping and its true reason is simpler and checkable — a sweep over `skills/` never opens `agents/`. This is the same failure ticket 01 recorded catching, made again.
- **A null mode degraded silently — fixed.** With no declared mode the body-repeat search became a different question and passed. Assertions run independently, so the earlier one catching it first is not something this one may lean on.
- **`specs.md` needed no amendment, and now says so.** §11 scopes the `metadata:` rule to skills and §20 prescribes nothing about where a role's mode sits, so ADR 0029 is satisfied by conformance rather than by a change. `mechanics/10` carries an equivalent note; this ticket offered the reader none.

**Both new guards were confirmed against deliberate reintroductions** — a top-level `mode:` restored on a role, and a scalar `metadata` — each firing alone, with the tree restored after each.
