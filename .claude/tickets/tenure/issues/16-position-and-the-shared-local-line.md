---
title: feat(knowledge): position, and the line between shared and local
status: resolved
blocked-by: []
---

## Problem

Nothing states which parts of a Tenure repository belong to the repository and which belong to a working copy. The Marker is documented as a one-off, and `.claude/.gitignore` is a list of unrelated entries rather than a category with a rule — so every further per-clone file is another exception `/configure` has to be told about.

Separately, root `CLAUDE.md` is committed and always-on for **every** Claude reading the repository, including one with no Tenure installed, but it describes machinery — the Marker, when healing runs, who advances what — that only exists if Tenure is present. A teammate's plain Claude reads standing instructions about a file it will never have.

ADR 0012 decides both.

## Outcome

**Position** is a named category: state describing where this clone stands rather than what the repository knows. `.claude/.gitignore` states it as a definition, so a new per-clone file is covered by the rule instead of needing a new entry argued for. The invariant travels with it: nothing shared may depend on Position, so deleting every ignored file costs no other person and no other clone anything they needed.

Root `CLAUDE.md` carries only what applies to any Claude with or without the plugin — verify before claiming, the knowledge-layer table, precedence, conventions, and the pointer into the repository's Context. Tenure's own protocol moves to a file that only Tenure's skills read, reached by pointer rather than restated.

`/configure` writes both, and the split is stated where a reader of either file can see which one they are in and why.

ADR 0007's consequence still binds and must be visibly satisfied: the rules that have to fire on every turn are exactly the universal ones, so nothing unconditional may end up in the moved file.

## Acceptance

- A Claude with no Tenure installed can follow every rule in the committed always-on entrypoint without encountering an instruction about a file that does not exist for it.
- The ignore rule states the category, and a reader can decide whether a newly proposed file belongs to it without asking.
- No rule that must hold on every turn lives in the moved protocol file.
- Nothing committed reads from a per-clone file.
- `/configure` produces both files, and re-running it leaves them unchanged.

## Comments

**The moved file is `.claude/tenure.md`**, written from a new
`configure/tenure.template.md` and copied as-is — it describes Tenure, not the
repository, so it has nothing to fill in. Committed, but never always-on: only
Tenure's skills open it, and they reach it by pointer. That satisfies "nothing
committed reads from a per-clone file" in the sense ADR 0012 gives the
invariant — no *knowledge* is drawn from Position. The Marker survives the move
because it never adds an obligation: with no marker file at all, `CLAUDE.md`'s
verification-at-use rule applies unchanged and only the shortcut is lost. The
protocol file says so explicitly, and an assertion holds it to it.

**What moved was machinery, not rules.** The Marker's decision procedure, the
two drift reads, the non-ancestor case, and the one-line verification report.
`CLAUDE.md` keeps verification-at-use, healing in place, the pointer rules, and
the whole always-on set — so the cold path lost its *Marker check* step and now
reads *route, load, verify* then *state the classification*. The classification
sentence also dropped the word "tier", which is Tenure vocabulary a plain Claude
has no referent for.

**The invariant and the membership test were split deliberately.** ADR 0012 says
`.claude/.gitignore` *is* Position's definition, so the ignore file carries the
test a reader applies when adding an entry — *would this be wrong in another
clone?* — and `.claude/tenure.md` carries the concept and the invariant nothing
shared may violate. Stating both in both places would have been the duplication
this framework exists to prevent. The ignore block is written out literally in
`/configure` step 4 rather than shipped as a `.template` file, because
`verify.ps1` globs `*.md` and a non-markdown template would sit outside every
assertion that guards the shipped set.

**Two of the three new assertions failed first time on their own regex**, both
for the same reason: `[^.]{0,N}` as a sentence bound stops dead on the dot in
`.claude/` and `CLAUDE.md`. Bounded to a line instead. The third failed on
wording the file genuinely did not carry — who reads it — which is the assertion
working.

**`/implement` was run against this ticket without `/configure` having ever
run**, so `.claude/tenure.md` exists here only as a template. Ticket 12 is where
it first lands in a repository.
