---
paths:
  - "skills/**"
  - "agents/**"
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

## Shipped text cites only what resolves where it is read

A file under `skills/` or `agents/` is read in whatever repository AEP is running in, and a template is written verbatim into one. So a reference in either may name only what exists there. `.claude/policies/tickets.md` resolves in every configured repository — that is what installing it is for. `ADR 0058` resolves in exactly one.

**The test is followability, not usefulness.** An ADR number, `specs.md`, or one of its sections points at this repository's own records, and in somebody else's repository it is worse than a dead link: ADRs are numbered from `0001` on the same scheme, so a shipped `ADR 0058` is indistinguishable from theirs.

Delete the citation. Where it was carrying a reason the surrounding prose does not state, **state the reason** — a citation doing real work leaves a hole when it goes, and the hole is invisible because the sentence still reads well.

This repository's own knowledge is not shipped and keeps its citations, and the derived guides are written per repository from that repository's facts, so theirs are read where they resolve. Upstream attribution is exempt for the reason below: it is provenance the licence requires, not navigation.

`verify.ps1` asserts this over the shipped surfaces.

## Vendored files carry attribution; borrowed shapes do not

**The test is whether text was copied.** A file holding text vendored from mattpocock/skills says so, in the file, and that line survives rewrites of the surrounding prose. It is a licence obligation — the upstream licence is MIT, and its condition binds copies and substantial portions.

**A structure borrowed from upstream is not a copy.** A two-axis review, a core loop, a branch discipline: copyright protects expression rather than shape, so a file that derived only a shape carries no obligation and states none. Attributing anyway is not free caution — it asserts a licence requirement that does not exist, which misstates the licence exactly as omitting a required one does.

`NOTICE` reproduces the upstream terms in full and stays while any vendored text ships. It is the repository-level notice; the per-file lines are the file-level one, and only vendored files need them.

`verify.ps1` pins the vendored set by name and fails in both directions — vendored text without attribution, and attribution on a file that vendored nothing.

## Short names are for the keyboard; descriptive names are for the model

User-invoked (`disable-model-invocation: true`): one word. The `/aep:` namespace is already in front of it, so the name only has to be typeable.

Model-invoked: an expressive name, and a `description` that states when to use it. That description is the entire basis on which the skill gets selected, so shortening the name for consistency costs selection accuracy and buys brevity nobody types.

This bans shortening **for brevity**, not every short name. `review` is model-invoked and one word because the namespace removed the collision its old prefix existed to avoid, and it still says when to use it.

`verify.ps1` asserts the split against each skill's frontmatter, so a rename that crosses the axis fails the build.

## Nothing shipped names a pre-migration path

`CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, and `.scratch/` are what AEP migrates *away from*, and `.claude/docs/` is AEP's own superseded layout (ADR 0018) — the same guard covers both kinds. A file under `skills/` naming one is either a bug or a migration row, and `verify.ps1`'s `$legacy` table enforces it. Only `configure/SKILL.md` and `configure/MIGRATION.md` are exempt, because detecting and converting those paths is their job.
