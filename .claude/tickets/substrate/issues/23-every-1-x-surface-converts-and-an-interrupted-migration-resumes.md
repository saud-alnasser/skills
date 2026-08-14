---
owner: repository
title: "feat(migration): every 1.x surface converts and an interrupted migration resumes"
status: resolved
blocked-by: [18, 20, 21, 22]
part-of: substrate
---

## Problem

A 1.x installation cannot reach 2.0 by hand. The corpus is thousands of spans across three
kinds of store, and every one of them needs identity it does not have. Migration was a
constraint on the design from the outset — a shape that could not carry the existing corpus
across was never a candidate — so this is where that constraint is honoured or the effort
fails.

The dangerous failure is not a crash. It is a surface that quietly has no destination and
is dropped, discovered months later by someone looking for a norm that used to be there.

## Outcome

Every 1.x surface has a destination, and a surface without one is an error naming it rather
than a file skipped in silence. Frozen records — accepted decisions, resolved tickets,
landed specs — receive one id each and are **not decomposed**: they gain identity, not
edits, and their prose comes through untouched.

The migration is proven against fixtures rather than against the live tree, and it is
resumable: interrupted halfway it completes on a second run instead of duplicating what it
already wrote.

This is the contract half of the refactor. It runs only after the store, the row, and the
query have each proven the destination is real.

## Acceptance

- Running the migration against a 1.x fixture produces a 2.0 tree, and every input surface
  is accounted for in the output.
- A surface with no destination stops the migration and is named in the error.
- An accepted decision, a resolved ticket, and a landed spec each come through with their
  prose byte-identical and exactly one id added.
- Interrupting the migration and re-running it completes the work, and the result is
  identical to an uninterrupted run.
- Every row a stage assembles after migration is diffed against the file-list row it
  replaced, and the dropped set is reported rather than assumed correct.
- A norm that the diff shows dropped is either justified in the report or fixed before the
  ticket closes.
- Running the migration twice on an already-migrated tree changes nothing.
- The migration changelog's entry for the release this effort declares names every repair a
  1.x repository needs to reach 2.0, and a converted surface with no repair named there is
  reported rather than left to a reader to notice.

## Comments

**The conversion is a dated repair, so it went into the changelog's 2.0.0 entry and not into
`MIGRATION.md`.** `changelog/01` split those two pages by what a repair fires on — a shape
detection finds, or a release a repository was configured by — and this one fires on the
release. The entry stopped declaring itself a placeholder in the same change, which is the
half of the work `26` deliberately left open.

**A heading depth the file had never used was introduced, and the alternative was worse.**
The entry is one repair with six parts, and the file's established shape is `###` per repair.
Flattening the parts to `###` would have asserted six repairs where there is one, in the file
whose own comment warns what a misfiled repair costs — so the parts are `####`. The
release-and-repair guards read `^##\s` and `^###\s`, neither of which matches a fourth hash,
so nothing that reads this file was disturbed.

**Criterion 3 could not be met without a change to the record format, and it is a computed
rule rather than a declared field.** `spans` held one entry per `##` heading, which for a
decision record means an id for `## Considered Options` — so "exactly one id added" and the
format contradicted each other. `records.template.md` now excepts the three frozen types, and
which records decompose is **computed from the type**, on the same reasoning the format
already gives for precedence: a flag a file declares about itself can be wrong about itself.

**One question was found and deliberately not answered: what happens to a directory the
conversion empties.** The store is flat, so `.claude/contexts/` has nothing left once its
files are records — but whether the directory should then go is a fact about the *generated
layout*, which `SKILL.md`'s tree still names and `24` owns. The conversion **reports the
emptied set and removes nothing**; deleting a directory the layout still names only means the
next configuration run recreates it. **`24` is where this is settled**, and it is written here
rather than onto that ticket because only design writes a criterion.

**Every criterion is met at specification level and none of the fixtures has been run** — the
same terms as `18`, `19`, `20`, `21` and `22`. Cases A–F are stated with their expected
outcomes; nothing here can execute them until `/configure` derives the scripts they run
against, and `24` is where they first can.

**The waiting drift finding is still waiting, and this was its last candidate.**
`2026-08-13-a-row-bound-cannot-tell-index-growth-from-prose-reinflation` says its structural
fix lands when the Decisions index stops being loaded whole and becomes a store a stage
queries. This entry specifies exactly that — but the finding falsifies an assertion in
`scripts/verify.ps1`, and *this* repository's rows do not change until it is itself converted.
Consumption is written by whoever heals, in the same change as the healing, so the finding
stays unmarked: waiting is the safe direction and inferring consumption is the guess the
format exists to prevent.
