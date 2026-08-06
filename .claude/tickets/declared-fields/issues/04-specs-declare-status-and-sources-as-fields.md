---
title: refactor(knowledge): a spec declares its status and sources as fields
status: resolved
blocked-by: []
part-of: declared-fields
---

## Problem

The spec format puts `Status:` and `Sources:` as prose lines under the title. `Status` is machine-written — `/commit` moves it to `implemented` when the last acceptance criterion lands, because only the last commit of a change knows every criterion is met. So a stage edits a prose line by matching it, which is the same defect as `Mode:` and `Policies:` in a family this effort is already touching.

`Sources` is the spec's Source Pointer list, verified before use like any other. Nothing can check it while it is running text.

## Outcome

A spec declares `status` and `sources` as frontmatter fields. `/commit` sets the status field rather than rewriting a line. The rule that only the status line ever moves is unchanged — it now moves as a field.

This is the precondition for indexing designs at all: an index generated from declared fields cannot show a spec that declares none.

Templates first, per ADR 0025.

## Acceptance

- The spec format declares `status` and `sources` in frontmatter, and no spec carries them as prose lines.
- The permitted status values are asserted — a spec carrying an unknown status fails the build.
- `/commit` writes the status field, and the suite fails if the skill still describes editing a prose line.
- This repository's own specs under `.claude/tickets/<effort>/` are converted in the same change, so the format has no second version in the tree.
- The frozen-reasoning rule still holds: nothing but `status` moves after a spec is accepted.

## Comments

**Driven red-first, recovering ticket 01's order after ticket 02 inverted it.** All five assertions were written and failing — each naming what it found — before a file moved. Eleven deliberate reintroductions were confirmed across the ticket, and the tree was restored after each.

**Three shape decisions the plan did not make:**

- **`sources` takes YAML's block form, one entry per line**, not the inline `[a, b]` the decisions family uses. Several specs carry entries that contain commas — `specs.md §5, §8, §9` is one pointer, not seven — and the inline form would have split them silently. Both notations are YAML lists, so this is one form for the fact and two spellings of a list, not the second home this effort exists to remove.
- **A spec with nothing to point at declares `sources: []`.** `tenure/spec.md` had no `Sources:` line at all. Absent and empty are the same fact, and only one of them is distinguishable from a spec whose sources were dropped in conversion — which is exactly the failure review found live, below.
- **The status keeps its existing vocabulary verbatim**, `superseded by <path>` included. Only the notation moved; a value that reads as a sentence is still the value the format defines, and rewriting it would have been the second change to a frozen document.

**One piece of drift, found while establishing where specs live, fixed in the same breath.** `.claude/policies/specs.md` said a spec is *"Written to `.claude/designs/<slug>.md`"*. No such directory exists here and eleven specs sit under `.claude/tickets/<effort>/`, which `.claude/policies/tracker.md` states and `specs.md` §21 corroborates. `.claude/policies/tickets.md` carried the same false path. Both now point at the tracker policy rather than restating a path — the first attempt pointed *and* restated, which review correctly called the second home it was meant to remove.

That divergence from the shipped template is not an ADR 0025 lag. Where a spec lives is this repository's own fact, and the template ships to repositories where the flat directory is right; ADR 0008 makes the installed copy the one that carries the local answer, as `tracker.md` and `version-control.md` already do.

**ADR 0029 required no amendment, and this says so rather than leaving a reader to check.** `specs.md` states nothing about a spec's own `Status:` or `Sources:` lines — §21 lists the directories and §11 scopes the `metadata:` rule to skills — so the specification is satisfied by conformance. `mechanics/10` and ticket `03` each carry an equivalent note; ticket `03`'s review found that the absence of one is itself the gap.

**What `/review` found, and what happened to it. Both axes independently proved the ticket's third criterion unmet:**

- **The `/commit` guard could not fire — fixed.** It asked whether the word `field` appeared anywhere in the step. Standards' mutation is the sharper one and is worth recording exactly: revert the imperative to ``set `Status: implemented` on the spec`` and leave the neighbouring **"Only the status field moves"** untouched, and `field` still matches — *the sentence travelling beside the defect*. All five assertions stayed green against a skill that had gone back to editing a prose line. `.claude/rules/skills.md` names this shape and says to assume you have just written one; I had. The guard now reads only the sentence that performs the write, which must name the frontmatter and must not describe a line. Both reviewers' mutations were replayed against it and both fire.
- **The `sources` half had no guard at all — fixed.** Deleting a spec's entire `sources` block left the whole suite green: only the *format* was checked, so a conversion that dropped every list on its way through would have passed. A spec is now required to declare the field, with its shape, because `sources:` followed by nothing is YAML null rather than an empty list. Four reintroductions confirm it.
- **A comment claimed a protection the code did not have — fixed.** It said a fenced `Status:` would defeat a guard that told the forms apart by capitalisation; Standards showed the sweep *fails* on one, which is a false positive and not a defeat. The comment now says what the code does and why sweeping fences is the wanted answer here, unlike in `Get-Section`.
- **Rationale was placed in the actor — deleted.** A sentence added to `skills/commit/SKILL.md` explained *why* the status is a field. `verify.ps1` already records the standing division — the rationale belongs to the format file, `/commit` carries the imperative — and the sentence also claimed the field form is what permits the edit, when the freeze rule is what permits it. Both wrong; it is gone rather than reworded.
- **A duplicated matcher — hoisted.** The expression scoping `/commit`'s spec step was copied verbatim from an assertion nine thousand lines away. It now has one home, `Get-SpecStep`, for the reason this file states about copies elsewhere: rewording the step needs coordinated edits, and the copy that gets missed still passes.
- **A loose ADR 0055 citation — dropped.** 0055 governs the harness `metadata` map on *shipped* skills and roles. A spec is neither, and citing it would have implied a bare top-level key is what 0055 sanctions when 0055 explicitly bars one. The real precedent is the contexts and decisions frontmatter, which the sentence now names.

**The CRLF bug ticket 02 fixed once came back at a new site, and is now fixed at the root.** The new `sources` assertion reported eight specs as missing a field they declared: `[ \t]*$` cannot consume the `\r` that sits before the newline, and the eight were the CRLF files. Ticket 02 stripped carriage returns inside `Get-MetadataBlock`; the extraction point everything shares is `Get-Frontmatter`, so the strip moved there and the local one is gone. A second recurrence is what says the first fix was in the wrong place.

**Two findings accepted rather than fixed, recorded so they are not re-raised:**

- **Some `sources` entries carry several pointers** — `.claude/decisions/0002, 0021, 0025, 0051` is four, and `0040–0048` is a range. Splitting them would mean writing text into documents whose reasoning is frozen, to buy a resolution check nothing in this ticket performs. Source Pointers are verified at use, by a session, not by the suite.
- **Criterion 5 is asserted under `tenure/06`, not under this ticket.** The freeze rule has one home and one pair of assertions; adding a second copy here would be the duplication fixed two bullets up. `-Ticket declared-fields/04` therefore does not cover it, which is worth knowing before trusting a single-ticket run.

Suite: 997 passed.
