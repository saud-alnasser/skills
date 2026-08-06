---
title: feat(configure): give version control its own policy file
status: resolved
blocked-by: [03]
---

## Problem

Nothing answers "how does work move from a ticket to a merged change here". Whether the repository uses plain git or stacked changes is probed by `/implement` at build time; branch naming sits in the tracker configuration, a file named for the ticket tracker and described by its own header as being about the tracker. The answer is split across a skill, a probe, and a file whose name does not suggest it — and the always-on entrypoint names none of them, so a teammate without the plugin cannot reach the tracker configuration at all despite every skill reading it.

## Outcome

`/configure` writes a version-control policy file stating which model the repository uses, its branch convention, its commit discipline, and the never-push rule. The tracker configuration keeps what it is named for. The always-on entrypoint names both policy files. `/implement` reads the stated model and verifies it at use rather than probing for it.

## Acceptance

- A configured repository has a version-control policy file stating which model applies, the branch convention, the commit discipline, and the never-push rule.
- The tracker template states none of those, and the constraint that a branch must encode the ticket id travels with the branch convention to its new home.
- The always-on entrypoint names both policy files and stays under 200 lines, asserted rather than assumed.
- `/implement` learns which model applies by reading the file and verifying the statement at use; no build-time probe remains as the source of the answer.
- A repository whose stated model no longer matches reality is caught by verification at use and healed in place, not deferred.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

**The check lives beside the claim, not in `/implement`.** The template states which model applies and carries the one read that confirms it; `/implement` reads the file and does what it says. The alternative — the statement in the committed file and the check inside the skill — was rejected because it reopens exactly the gap ticket 03 closed for tool references: a teammate with no plugin would hold a claim about their own repository with no way to test it. The cost is that a committed file carries an instruction, which is unusual for a policy file; it is accepted because the instruction is one filesystem read and describes nothing about Tenure.

**Deviation from criterion 1: the never-push rule is pointed at, not stated.** `CLAUDE.md` carries it as an always-on rule, so a second copy in the policy file is a second home for something that must fire on every turn — the failure this framework exists to prevent. What the file states instead is *how work lands here*: which route a finished branch takes to the default branch, and who takes it. That is a fact about the repository and about its humans, it is what the file's name promises, and it is not recoverable from `CLAUDE.md`. Asserted in both directions, so the deviation cannot relax back into a copy.

**`tenure/19`'s assertion was repointed, not relaxed.** Its criterion 2 — which meaning of `Blocked by:` applies is read, never assumed — is unchanged and still true; only the source of the read moved, from a build-time probe to this file. The guard now accepts either the original wording or a reference to the policy file, so removing the file and reverting to an assumption fails there as well as here. Confirmed by mutation.

**Scope taken beyond the ticket, deliberately.** `/commit` keys its closing-keyword choice on how the work lands and had no stated source for that. One clause now points at the policy file. Without it, the first thing `/commit` does with the new fact is guess at it — which is the failure this ticket exists to remove, one skill over.

**No `$rulePattern` entry for the model check.** The `.git/.graphite_repo_config` read appears twice under `skills/` — in this template and in the Graphite tool reference — and those are two audiences rather than two homes: one says what this repository *is*, the other says how to drive a CLI. A duplication guard on the subject would fail against a correct tree. What is guarded instead is the second home that would actually be wrong: `/implement` carrying the invocation itself.

**A risk in the spec is already retired.** It lists "a line-count assertion, which does not exist yet and should" as the detection for `CLAUDE.md` outgrowing its budget. `tenure/02` has asserted it since the original build; the template is at 116 lines.

**No Context update.** The policy/invocation split is ADR 0020's and is already recorded there; nothing in `.claude/context.md` or the Domain Contexts moved.
