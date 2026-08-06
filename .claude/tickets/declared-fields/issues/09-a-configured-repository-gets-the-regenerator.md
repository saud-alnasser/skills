---
title: feat(configure): a configured repository gets the regenerator, not a promise
status: resolved
blocked-by: []
part-of: declared-fields
---

## Problem

ADR 0057 states a consequence no ticket in this effort delivers: *"The script is committed and runnable without the plugin, like the suite it is checked by. A repository configured by AEP gets the script, not a promise that some agent will remember."*

Ticket 05 built `.claude/scripts/regenerate-indexes.ps1` for this repository and its acceptance says only that the script runs without the plugin — which it does. But `/configure` installs nothing executable. So in every repository but this one, `/commit` names an invocation that is not there, and the generated indexes AEP ships the *format* for have nothing to produce them.

The shipped `/commit` handles the absence in one line rather than failing, so nothing breaks loudly. That is the shape of the problem: the guarantee ADR 0057 records is quietly unavailable everywhere it was written for.

## Why this is not a build ticket yet

Installing an executable is a responsibility `/configure` does not currently have — it writes markdown. Three questions have to be answered before anything is built, and each changes what ships:

- **Where the source of truth lives.** A copy in every configured repository is a fork the moment the shipped one changes; a pointer into the plugin breaks the plugin-independence the whole framework rests on.
- **What happens when a repository's copy drifts** from the shipped one, and whether the suite `/configure` writes is supposed to notice.
- **Whether the migration converts an older copy**, which is the same question `MIGRATION.md` answers for every other installed artefact.

None of those is a build decision, and answering them inside `/implement` would be designing without the grill.

## Blocked

Needs `/design`. Found while building ticket 05, where the gap between the ADR's Consequences and the ticket's acceptance became visible; the user chose to ticket it rather than widen 05.

Ticket 05 is unaffected and complete against its own acceptance — this is a separate obligation that ADR 0057 created and that nothing has scheduled.

## Outcome

**The configure skill gains `SCRIPTS.md` — "Deriving `.claude/scripts/`" — and `/configure` writes the regenerator from it.** The page is a *behavioural specification*: what each index must contain, in what order, what a file declaring no fields does, what shapes are refused, and that output is byte-stable. The script is written in whatever language the repository already uses; nothing ships a copy of AEP's own.

ADR 0060 has the reasoning and names the two alternatives it rejects. `TOOLS.md` is the shape being followed one level over — a page in the configure skill that says how a committed artefact is derived — and this ticket is where that pattern first produces something executable.

The page carries a **worked fixture and its exact expected output**, because a freshly configured repository has no committed index to compare a first regeneration against: the first run creates them, so a mis-derived script is self-consistent and every later comparison agrees with it. The fixture is the one check whose answer was not produced by the thing being checked.

Templates first, per ADR 0025.

## Acceptance

- `skills/configure/SCRIPTS.md` states the output of **every** index the workflow generates — contexts, decisions, and designs — with its columns, its row order, and the em-dash for an empty cell. The suite fails if the workflow generates an index the page does not specify.
- The page states the refusals as behaviour rather than as code: a file declaring no fields stops the regeneration and is named; a list in a shape the index cannot read is refused rather than read as empty. Both are behaviours ticket 05 and its review established, and neither is recoverable from prose that only describes the happy path.
- The page carries a fixture — a small tree of contexts and decisions — and the exact bytes it must produce. `/configure` runs the derived script against it **before** running it against the repository, and says so.
- `/configure` writes `.claude/scripts/regenerate-indexes.*` in the repository's own language, and reaches the page by pointer rather than restating it — the same pairing `SKILL.md` already has with `TOOLS.md`.
- **No text-divergence check is attempted.** The entry comparison that pairs a derived tool guide with its source has nothing to compare between a specification and an implementation of it; the enforcement is ADR 0057's regenerate-and-compare, and the suite asserts that this is the mechanism rather than leaving a reader to infer it.
- This repository's own script is reconciled with the page: the suite fails if the page specifies an index the script does not produce, or the script produces one the page does not specify. It is a derived artefact now, not the source the page was written from.
- `MIGRATION.md` needs no row: there is no earlier installed copy anywhere to convert, because nothing has ever installed one. Say that rather than adding a row that converts nothing.

## Re-planned

**Unblocked by an answer, not by a workaround.** The user's proposal — a descriptive page in the configure skill saying how the script is built — dissolves the fork this ticket was blocked on, because a description is neither a copy that forks nor a pointer that breaks plugin-independence. All three of the questions above are answered: the source of truth is the page; drift is checked behaviourally rather than textually, since there is no text to compare; and the migration has nothing to convert.

Two decisions were put to the user and both took the recommended side: the page is a behavioural specification rather than a reference implementation with porting notes, and the first-run gap is closed by a worked fixture rather than by `/configure` authoring test-suite assertions in an arbitrary framework or by accepting the gap.

## Comments

**A stale enumeration in this ticket's own first criterion, handled by taking the rule over the list.** It names *"contexts, decisions, and designs"*; ticket 06 added a fourth, evidence, after this ticket was written. The criterion's rule — *every index the workflow generates* — is what the assertion tests, and it tests it in both directions rather than against any list.

**What `/review` found, and what happened to it. The worst finding is that the page was wrong in the one place a derived script would act on it:**

- **`SCRIPTS.md` contradicted ADR 0059 — fixed.** It said the designs index sits *"beside the specs"* and that *"the rows are identical"* under both layouts. ADR 0059's own rejected-option list names that first sentence as false: under the effort layout the index sits one level **above** every spec, at `.claude/tickets/map.md`. The rows differ too — label and link are `<slug>`/`<slug>.md` in one and `<effort>`/`<effort>/spec.md` in the other. A script derived from that page would have written the file to the wrong directory in every repository using the effort layout. The page now carries a table of the three things that change, and an assertion checks that both destination paths are stated.
- **Four of the six assertions could not fire — fixed.** The fixture check transcribed the fixture's *input* into the assertion and compared only the output, so editing the page's input, or deleting the whole fixture block, changed nothing. It now parses the tree out of the page and runs *that*. The family check derived the script's families from **doc comments** while its own comment claimed it read the script, so a family added to the builder table was invisible; it now reads the emitted titles from the builders and compares **both directions**, catching a family the page invents as well as one it omits. And nothing at all covered byte-stability — deleting the whole section left every other assertion green.
- **`/configure` instructed writing to a directory its own layout did not name — fixed.** `.claude/scripts/` was absent from the generated tree and from `specs.md` §21, which is exactly the failure ADR 0050 records and which `SKILL.md` states as a rule two lines above where I broke it.
- **The specification was incomplete in four ways a derived script would get wrong — fixed.** UTF-8 **without** a byte-order mark, since a BOM is three invisible bytes that break the comparison the page's whole enforcement rests on; an unnumbered ADR filename is refused; a family directory that exists but holds no file produces no index rather than an empty table; and reads are `*.md`, one level deep, except evidence whose kinds are directories.

**Two findings recorded rather than fixed:**

- **`/commit` names a fixed `.ps1` path.** A repository deriving a Python or Node script satisfies this page and then hits `/commit`'s absent-script branch forever, reporting its indexes unverified. That is a defect in the shipped commit stage rather than in this page, and fixing it means deciding how `/commit` locates a script whose extension it cannot know — which is a decision, not a build.
- **The page restates the context format's table shape and row order.** Both ship into the same repository, so it is arguably a second home; the counter-argument is that a specification someone implements from cannot be a pointer to four other formats. Left as it is, flagged, and no `$rulePattern` entry added because the right resolution is not obvious.

Eight deliberate reintroductions, each caught: a fixture claiming output its own input does not produce, the fixture block deleted outright, an index dropped from the page, an index the page invents, a refusal dropped, the byte-stability section deleted, the BOM rule alone dropped, and the pointer from `/configure` removed.

Suite: 1036 passed.
