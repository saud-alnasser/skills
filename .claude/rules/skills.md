---
paths:
  - "skills/**"
  - "scripts/verify.ps1"
---

# Authoring skills

<!--
  The scope is the frontmatter above, not prose. It was prose until this rule
  cost 3,405 chars on every turn, including turns that never opened `skills/`.
  `scripts/verify.ps1` is in scope because the first standard below is an
  obligation *on* that file — a rule about the suite that did not load when
  the suite was open would fire only where it was not needed.
-->

Standards this repository holds itself to when changing what ships. The vocabulary behind them is in `.claude/contexts/skill-authoring.md`; these are the checkable obligations.

## Every change to `skills/` moves `scripts/verify.ps1` in the same pass

There is no package manifest and no test runner here. `verify.ps1` asserts each ticket's mechanically-checkable acceptance criteria against `./skills`, and it is the only thing that catches a broken build.

```
pwsh -NoProfile -File scripts/verify.ps1                    # all tickets
pwsh -NoProfile -File scripts/verify.ps1 -Ticket tenure/09  # one, as <effort>/NN
```

Ticket numbers restart at `01` in each effort, so the effort is part of the id. An unknown id exits `2` and lists what it knows, rather than passing with nothing run.

A change that adds a checkable claim and no assertion is untested by construction, not merely under-tested.

## Placing a rule adds an entry to the `$rulePattern` table

Single-home is asserted, not trusted. When a rule is placed, add its guard to `$rulePattern` in `verify.ps1`.

**Check that the guard would actually fire.** The recurring failure is a guard that matches a phrase travelling *with* the thing it checks rather than the thing itself — it passes while what it existed to catch sits in the tree. It has happened often enough not to be worth counting; assume you have just written one. Write the guard, then confirm it fails against a deliberate reintroduction before trusting it.

Two shapes it takes. A guard written from *your own* new wording matches only that wording, so an existing restatement elsewhere goes unseen — match the subject instead. And a guard covering two claims passes when either holds, so deleting one leaves it green — one assertion per site, anchored to that site.

## Derived skills carry their attribution

Every skill derived from mattpocock/skills says so, in the skill. This is a licence obligation — see `LICENSE` and `NOTICE` — and it survives rewrites of the surrounding text.

## Short names are for the keyboard; descriptive names are for the model

User-invoked (`disable-model-invocation: true`): one word. The `/aep:` namespace is already in front of it, so the name only has to be typeable.

Model-invoked: an expressive name, and a `description` that states when to use it. That description is the entire basis on which the skill gets selected, so shortening the name for consistency costs selection accuracy and buys brevity nobody types.

This bans shortening **for brevity**, not every short name. `review` is model-invoked and one word because the namespace removed the collision its old prefix existed to avoid, and it still says when to use it.

`verify.ps1` asserts the split against each skill's frontmatter, so a rename that crosses the axis fails the build.

## Nothing shipped names a pre-migration path

`CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, and `.scratch/` are what AEP migrates *away from*, and `.claude/docs/` is AEP's own superseded layout (ADR 0018) — the same guard covers both kinds. A file under `skills/` naming one is either a bug or a migration row, and `verify.ps1`'s `$legacy` table enforces it. Only `configure/SKILL.md` and `configure/MIGRATION.md` are exempt, because detecting and converting those paths is their job.
