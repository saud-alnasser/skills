---
owner: repository
paths:
  - "skills/**"
  - "agents/**"
  - "build/verify.js"
---

# Authoring skills

<!--
  The scope is the frontmatter above, not prose. It was prose until this rule
  cost 3,405 chars on every turn, including turns that never opened `skills/`.
  `build/verify.js` is in scope because the first standard below is an
  obligation *on* that file — a rule about the suite that did not load when
  the suite was open would fire only where it was not needed.
-->

Standards this repository holds itself to when changing what ships. The vocabulary behind them is in `.claude/contexts/skill-authoring.md`; these are the checkable obligations.

## Every change to what ships moves `build/verify.js` in the same pass

There is no package manifest and no test runner here. `build/verify.js` asserts that **what ships adheres to `specs.md`** — `skills/`, `agents/`, `knowledge/`, `scripts/`, and the configure skill's remaining templates — and it is the only thing that catches a broken build.

```
node build/verify.js                          # every group
node build/verify.js --ticket conversion/01   # one, as <effort>/NN
```

Ticket numbers restart at `01` in each effort, so the effort is part of the id. An unknown id exits `2` and lists what it knows, rather than passing with nothing run.

**Assertions are grouped under the ticket that introduced them**, which is what makes the group name an `<effort>/NN` and what lets a change be checked against the ticket that asked for it rather than against the whole suite.

A change that adds a checkable claim and no assertion is untested by construction, not merely under-tested.

**The suite never checks this repository's `.claude/` against anything** — no template-to-installed byte-lock, no sweep of the committed protocol directory, no assertion asking whether this repository holds what the framework specifies. Such a check couples what ships to what this repository happens to run on, so a shipped template cannot change shape until this repository is converted — inverting the ordering that builds into what ships first and converts this repository last. A guard failing because a shipped file no longer matches something under `.claude/` **is the defect, not the file**: rescope it or delete it, and never contort shipped content to satisfy it.

## Placing a rule in shipped text adds an assertion under the ticket that placed it

Single-home is asserted, not trusted. When a rule is placed in what ships — a skill, an agent definition, or a template — add a guard for it to `build/verify.js`, in the group named for the ticket doing the placing. A rule this repository places in its own `.claude/` is single-homed by the same standard and guarded by nothing here, because guarding it would mean reading the protocol directory, which is the coupling the section above refuses.

**Check that the guard would actually fire.** The recurring failure is a guard that matches a phrase travelling *with* the thing it checks rather than the thing itself — it passes while what it existed to catch sits in the tree. It has happened often enough not to be worth counting; assume you have just written one. Write the guard, then confirm it fails against a deliberate reintroduction before trusting it.

Two shapes it takes. A guard written from *your own* new wording matches only that wording, so an existing restatement elsewhere goes unseen — match the subject instead. And a guard covering two claims passes when either holds, so deleting one leaves it green — one assertion per site, anchored to that site.

## Shipped text cites only what resolves where it is read

A file under `skills/` or `agents/` is read in whatever repository AEP is running in, and a template is written verbatim into one. So a reference in either may name only what exists there. `.claude/policies/tickets.md` resolves in every configured repository — that is what installing it is for. `ADR 0058` resolves in exactly one.

**The test is followability, not usefulness.** An ADR number, `specs.md`, or one of its sections points at this repository's own records, and in somebody else's repository it is worse than a dead link: ADRs are numbered from `0001` on the same scheme, so a shipped `ADR 0058` is indistinguishable from theirs.

Delete the citation. Where it was carrying a reason the surrounding prose does not state, **state the reason** — a citation doing real work leaves a hole when it goes, and the hole is invisible because the sentence still reads well.

This repository's own knowledge is not shipped and keeps its citations, and the derived guides are written per repository from that repository's facts, so theirs are read where they resolve. Upstream attribution is exempt for the reason below: it is provenance the licence requires, not navigation.

`build/verify.js` asserts the two unambiguous forms over the shipped surfaces — an ADR number, and a section mark on a line naming no file. A bare `specs.md` is deliberately unguarded: the canonical specification and the shipped guide `policies/specs.md` share a filename, so a guard on the bare name fires on correct content, and a guard that fires on correct content gets rescoped by whoever hits it. The standard above still binds; only part of it is mechanical.

## Shipped text names a record by subject, never by location

A norm, a context, a decision, a reference — every record in the store is reached by delivery
or by query, and **nothing in the store is reached by opening a file somebody chose**. So a
path in shipped prose is not a stale detail: it instructs the one behaviour the delivery
mechanism exists to remove, and it goes on instructing it after the path is corrected.

**Correcting a path is therefore the wrong repair. The path goes.** What replaces it is
decided by what the record's type does at delivery:

| The passage names | It becomes |
| --- | --- |
| a norm the stage receives in its row | the subject alone — the norm is already inlined ahead of the skill's own content, so a pointer would point inside the window |
| a `reference` | the subject, and a pointer that survives — a `reference` carries no firing condition, is never delivered, and is fetched at the operation that needs it |
| an instruction to open a file | a query against the store, and the passage says what happens when the store cannot be reached |

The subject stays rather than the pointer being deleted outright, because a skill still
points at what governs a passage: a reader outside a running stage has no row, and the
frontmatter declaration alone does not say which passage answers to which record.

**`.claude/rules/` is not covered by any of this.** The boot tier stays files because the
harness is the only channel that reaches a clone without the plugin, so a reference to it
resolves where it is read and is correct as written.

## Vendored files carry attribution; borrowed shapes do not

**The test is whether text was copied.** A file holding text vendored from mattpocock/skills says so, in the file, and that line survives rewrites of the surrounding prose. It is a licence obligation — the upstream licence is MIT, and its condition binds copies and substantial portions.

**A structure borrowed from upstream is not a copy.** A two-axis review, a core loop, a branch discipline: copyright protects expression rather than shape, so a file that derived only a shape carries no obligation and states none. Attributing anyway is not free caution — it asserts a licence requirement that does not exist, which misstates the licence exactly as omitting a required one does.

`NOTICE` reproduces the upstream terms in full and stays while any vendored text ships. It is the repository-level notice; the per-file lines are the file-level one, and only vendored files need them.

`build/verify.js` pins the vendored set by name and fails in both directions — vendored text without attribution, and attribution on a file that vendored nothing.

## Short names are for the keyboard; descriptive names are for the model

User-invoked (`disable-model-invocation: true`): one word. The `/aep:` namespace is already in front of it, so the name only has to be typeable.

Model-invoked: an expressive name, and a `description` that states when to use it. That description is the entire basis on which the skill gets selected, so shortening the name for consistency costs selection accuracy and buys brevity nobody types.

This bans shortening **for brevity**, not every short name. `review` is model-invoked and one word because the namespace removed the collision its old prefix existed to avoid, and it still says when to use it.

`build/verify.js` asserts the split against each skill's frontmatter, so a rename that crosses the axis fails the build.

## Nothing shipped names a pre-migration path

`CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, and `.scratch/` are what AEP migrates *away from*, and `.claude/docs/` is AEP's own superseded layout (ADR 0018) — the same guard covers both kinds. A file under `skills/` naming one is either a bug or a migration row, and `build/verify.js`'s legacy table enforces it. Only `configure/SKILL.md` and `configure/MIGRATION.md` are exempt, because detecting and converting those paths is their job.
