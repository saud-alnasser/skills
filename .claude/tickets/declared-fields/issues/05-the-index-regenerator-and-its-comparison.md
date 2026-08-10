---
title: feat(scripts): one regenerator produces every index, and the suite compares
status: resolved
blocked-by: []
part-of: declared-fields
---

## Problem

Two generated indexes already exist, and nothing generates them. The context format states that a generated file is never hand-edited and that the prohibition is enforced *by regenerating and comparing rather than requested of whoever opens it* — a sentence with nothing behind it, because there is no regenerator to run and no comparison in the suite.

Every index this effort adds inherits that gap, and each one added by hand is a second statement of its directory rather than a derivation from it — which is the property ADR 0053 bought and this would spend.

## Outcome

One deterministic script produces every index from the fields the indexed files declare. The suite regenerates each and compares against what is committed; a stale or hand-edited index fails the build. `/commit` invokes the script before the message is written, per ADR 0057 — commit is the last point at which the tree is known complete.

The script is built against the two indexes that already exist, because they are the only ones with a known-correct answer to check against. Reproducing them byte-for-byte is the acceptance test and the de-risking: everything later in this effort depends on the regenerator being right, and this is the only ticket where correctness can be judged against something already trusted.

## Acceptance

- Running the script reproduces the committed context index and decision index **byte-for-byte**, including row order and whitespace — no diff at all.
- The suite fails when a committed index differs from what regeneration produces. Confirm it fails against a deliberate hand-edit before trusting it.
- The script runs without the plugin installed, like the suite that checks it.
- A file under an indexed directory that declares no fields does not appear in a regeneration, and this is asserted rather than assumed.
- `/commit` invokes the regenerator, and the suite asserts that it does.
- The script is deterministic: two runs over an unchanged tree produce identical output.

## Comments

**Both committed indexes reproduce byte for byte** — 474 B and 9770 B, compared byte by byte rather than by string equality, against a copy of the tree so the check exercises the same write path `/commit` takes.

**The machinery already existed, in the wrong place.** `mechanics/08` built a decision-map renderer, loader and fixture *inside `scripts/verify.ps1`*, proved against a fixture directory because this repository's ADRs had no fields yet. This ticket graduates that into a real script and generalises it to contexts.

An earlier version of this note argued the suite's copy should stay whole. **That was wrong and review said so.** Its `$render` independently encoded the header row, the numeric order and the em-dash rule — a second renderer, which is precisely what ADR 0057 rejects when it says *a single deterministic script* produces every index — and its byte-identical, hand-edit and fieldless assertions were then checking a renderer nothing ships. Its header comment had also gone false, still claiming the regenerator lives there and that the fixture exists because this repository's ADRs have no fields yet; both expired. The renderer and those three assertions are gone, the comment is corrected, and the loader and fixture stay for the supersession-symmetry checks, which really are a decisions-format property rather than an indexing one.

**Three decisions the plan did not make. One went to the user; the other two were mine:**

- **Ordering.** `repository.md` leads, then filename order. The format said only *"repository-wide domains first and flat"*, which does not fix an order, and an unfixed order makes "byte-identical" meaningless. The rule chosen is the one that reproduces the committed file.
- **The nested Project Context group.** The format shows a label row `| **web** | | \`apps/web/\` |` and never says where that sources value comes from — no member file declares a fact about its group, and a directory has no frontmatter. The user's first answer was to build the branch against a fixture; when the underspecification surfaced, the second was to settle the rule inside this ticket. **A user instruction overrides the stage boundary, and this records that it did** — writing a format rule is normally `/design`'s. The rule: the label row carries the directory name and two empty cells, because a derived value would be the one thing a generated table may not contain, a claim its directory never made. Both format copies are amended and the example corrected.
- **No print-to-stdout mode.** An earlier draft had one so the suite could compare without writing. It was removed: the comparison would then prove something about a surface nothing else runs, while the path `/commit` actually takes went unchecked. The suite regenerates into a temporary tree instead.

**A fieldless file stops the regeneration rather than being skipped.** The acceptance says such a file "does not appear in a regeneration", and refusing satisfies that more strongly than omitting: a context or decision missing from the index is unreachable, and the silent version is discovered by whoever needed the file rather than by the build. This also matches what `mechanics/08` established.

**Line endings are the checkout's own.** At the time this was built nothing pinned one, so one blob was CRLF in a Windows working tree and LF in a POSIX one, and the script emitted `[Environment]::NewLine` to track it. `WriteAllText` rather than `Set-Content`, which appends an ending of its own to the string it is handed, still holds. **The rest was closed by `line-endings/02`:** a root `.gitattributes` pins `eol=lf`, so the checkout's ending is a fact rather than a local setting's output, and the script emits that instead of the platform's.

**The same CRLF class bit twice more while building this**, once in an assertion's anchored pattern. That is the third and fourth occurrence in this effort. The strip now lives in `Get-Frontmatter` for frontmatter, and the one pattern that reads generated output strips explicitly and says why.

**ADR 0057 records a consequence this ticket does not deliver, and it is now ticketed rather than absorbed.** *"A repository configured by AEP gets the script, not a promise that some agent will remember."* `/configure` installs nothing from `scripts/`. Ticket 05's acceptance asks only that the script run without the plugin, which it does; shipping it is a new `/configure` responsibility with three unanswered design questions, so it is ticket `09`, blocked for `/design`. The user chose this over widening 05.

**What `/review` found, and what happened to it. The sharpest finding was a data-loss bug both axes' checks had missed:**

- **A `sources` field the index cannot read was silently rendered as no sources at all — fixed.** `sources` was never required, and a block list — the shape ticket 04 gave specs — parses as a present-but-empty value. Standards proved it with a fixture: a context declaring two real paths as a block list rendered `| [blocklist](blocklist.md) | … | — |` and exited 0. A wrong answer wearing a right one's shape, and no reader of the index could have told. The list parser now refuses both absent and unreadable, each with its own message naming the file.
- **The "runs without the plugin" assertion tested nothing — replaced.** It grepped the script's own source for three spellings I had thought of, which is the guard-matches-your-own-wording failure named in `.claude/rules/skills.md`; `$env:CLAUDE_PLUGIN_ROOT` or a relative path would have walked straight past it. Both axes flagged it independently, and Spec had already established the property the honest way. The assertion now copies the script alone into a tree holding nothing but two indexed directories — no `skills/`, no repository, no git — and runs it.
- **The label-row rule had a third home — removed, and the pattern table now guards it.** The regenerator's own doc-comment restated the format's reasoning, in a place no reader of the format would check for a contradiction. It points instead, and `$rulePattern` gained an entry, which `.claude/rules/skills.md` requires when a rule is placed.
- **The line-ending comment stated a machine-local fact as a repository one — corrected.** It asserted `core.autocrlf` is on; that resolves from *system* scope here, not from the repository, and a Windows clone configured `autocrlf=input` would hold LF on disk and see the comparison fail as a stale index — the exact misdiagnosis the comment claimed to prevent. The comment now says what is actually pinned, which is nothing, and names `.gitattributes` as the durable fix rather than making a repository-wide change nobody asked for. **Closed by `line-endings/02`, and closed as something this record got wrong.** It was filed above as a live limitation of the environment, closable by an attributes file if anyone wanted one — and framed that way nothing acted on it for several releases, because an environmental cost has nobody to fix it. It was a **defect in the script**: `SCRIPTS.md` requires the checkout's ending, nothing here made that value obtainable, and the script hardcoded the platform's in its place. The root `.gitattributes` makes the value obtainable and the script now emits it; ADR 0069 records why the pin was chosen over teaching the script to detect the ending at runtime.
- **A directory named twice — collapsed.** The families table carried each path as data *and* re-derived it inside the builder that reads it, so an edit to one would silently desynchronise the read from the write.
- **`/commit`'s absent-script line softened ADR 0057 — reworded.** It said a repository without the script carries on. It still does, but now it must *say the indexes are unverified*: the guarantee is unavailable in every repository but this one until ticket 09 lands, and silence would let an unenforced index read as an enforced one.
- **An assertion was named for something it did not check — renamed.** "before it stages" checked position against the heading that makes the commit; staging has no heading of its own.

**Two of my own claims were falsified, and both are corrected above rather than argued with:** that the suite's renderer should stay, and — in an earlier draft of these Comments — that two of the three shape decisions were put to the user. One was.

**Eight deliberate reintroductions, each caught by its own assertion and no other:** a hand edit to each committed index, `/commit` dropping the invocation, the group label row no longer emitted, a fieldless file skipped instead of refused, the script reaching into the shipped skill tree, an absent `sources` read as empty, and a block list read as empty.

**A ninth mutation caught dead code rather than a defect.** Removing the absent-field refusal changed nothing, because `[string]$Value` coerces `$null` to the empty string and collapsed "absent" into "block list" — so the branch could never run. The parameter is untyped now. This is the value of mutating a guard you believe in: the guard was fine, and the code beneath it was not.

Suite: 1005 passed.
