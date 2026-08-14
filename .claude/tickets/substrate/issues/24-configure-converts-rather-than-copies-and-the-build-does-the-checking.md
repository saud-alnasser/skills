---
owner: repository
title: "feat(configure): configure converts rather than copies and the build does the checking"
status: resolved
blocked-by: [23]
part-of: substrate
---

## Problem

Configuration today copies the framework's files into a repository and then audits the
copies for drift. Once the corpus is a store the framework serves, copying is the wrong
verb: there is nothing to copy, and an audit comparing copies against originals is checking
a relationship that no longer exists.

A deviation from framework law is also recorded as prose today, which means it is loud only
to a reader who happens to open the right file.

## Outcome

Configuration writes only the two things the harness must find by name — the entry file and
the harness settings — and otherwise converts an installation onto the store. Every check it
used to perform moves to the build, so checking happens where the corpus is assembled rather
than in a stage somebody has to remember to run.

A deviation from framework law becomes a declared edge rather than a paragraph, so it is
loud by construction: it appears in every audit until it is removed, and nothing has to
notice it in prose.

## Acceptance

- Running configuration on an unconfigured repository produces a working installation, and
  the only files it writes outside the store are **the surfaces the harness finds by name**:
  the entry file, the harness settings, and the unconditional standards under
  `.claude/rules/`. Anything else written outside the store fails the build, named.
- Running configuration on a 1.x installation converts it, and the result is identical to
  running the migration directly.
- Every check that configuration performed in 1.x fails the build in 2.0, demonstrated one
  check at a time.
- A repository deviating from framework law reports that deviation in every audit, and the
  report names the record deviated from.
- Removing the deviation removes the report, with no other edit required.
- Running configuration twice changes nothing the second time.

## Comments

**Criterion 1 was rewritten mid-build, by the user, after the build hit a contradiction it
could not resolve itself.** The account below is what was found; the resolution is the
paragraph after it. Both are kept — the finding is why the criterion reads as it now does.

**Criterion 1 as originally written contradicted a Constraint in
`.claude/contexts/repository.md`, and the contradiction was load-bearing rather than a wording
problem.**

The criterion says the only files written outside the store are the entry file and the harness
settings — so the four unconditional standards become records in `.claude/knowledge/`, pushed
into the boot tier by the framework, which is `19`'s outcome. The Constraint says *nothing
committed may assume AEP is installed*: a teammate who clones this repository without the
plugin must still be able to follow every rule in `CLAUDE.md` and `.claude/rules/`, **because
the harness loads both without it**.

Those cannot both hold. Push is the plugin's channel. Without the plugin a clone loads
`CLAUDE.md` and whatever sits unscoped in `.claude/rules/`, and nothing else — a record in the
store is committed and readable, but reaching it is a pointer somebody follows, and a norm that
fires only when the model chooses to look is the silent failure the tier model exists to
prevent. So the unconditional norms must remain files in `.claude/rules/`, and configuration
writes more than two files outside the store.

**This was not visible before the build.** Both statements were written for their own ticket
and neither names the other; what surfaced them together is criterion 1 forcing `rules/` out of
the layout, and the four guards that then fail are the check working — `the always-on list names
every unconditional rule, in both copies` is precisely the one that catches it.

**The fork was three ways and the user took the first**: name a third surface; drop push and
serve the boot tier from files, superseding `19`; or accept a degraded plugin-less clone and
supersede the Constraint by ADR.

**The resolution is that there was never a second rule to bend.** Criterion 1's own
justification is *the files the harness must find by name* — and the harness auto-loads every
unscoped file under `.claude/rules/` by exactly that convention. So the unconditional standards
were always inside the criterion's stated reason and outside its stated list; naming them makes
the criterion say what it already meant. `19` and the Constraint both stand unamended, and no
Decision was needed.

**What that costs, stated because it is real**: the four standards are delivered twice — as
files the harness loads and as records the framework pushes — unless push is scoped to skip
what the harness already delivers. It is scoped, and the scoping is asserted.

**`19`'s boot-tier debit is settled here, and the figure `19` recorded was measured against the
wrong baseline.** `19` compared the grown template against this repository's live tier. The
honest comparison is the template against **the effort's own base**, and the guard added here
computes it rather than remembering a number: `main` holds 4,681 characters, and the template
now holds fewer. The debit is repaid, and a future run that regrows the tier fails on the
arithmetic instead of on somebody noticing.

**Ten guards were re-pointed, none deleted**, and the distinction is the ticket's own rule —
a check that moved and a check that vanished must not look the same. Three carried the
deviation from a prose section to the edge; three followed the record kinds down from the
directories they used to be; two followed the layer table and the two derived policies into the
store; one followed the extension point to nothing; one followed the disposition failure from
the audit to the build. Each was fire-checked against a deliberate reintroduction.

**The category set is now the layout plus the directories step 4 says have left, parsed from
that sentence.** This is the ordering constraint working rather than being worked around:
`.claude/contexts/repository.md` says a check asking *does this repository have what the
framework specifies* is bounded by the newest cut release, and 2.0.0 is declared and uncut — so
this repository's `contexts/`, `decisions/`, `evidence/`, `policies/`, `modes/` and `tools/` are
legal until it converts. **Not every template under `skills/configure/` has been converted**,
and this is what lets the unconverted ones keep passing while the converted ones move.

**Every criterion is met at specification level and none of the fixtures has been run** — the
same terms as `18` through `23`. Criterion 2 in particular — *converting a 1.x installation is
identical to running the migration directly* — is stated by construction, because step 5 sends
the conversion to the changelog entry rather than describing a second one, and there is no
second implementation for it to disagree with.

**`19`'s two declared increments are still unanswered.** They are declared on `19` and
`/implement` never invents one, so nothing moved them here. Both are `prototype` questions
needing a harness restart no session can perform on itself; answering them needs a `/design`
run that moves them onto a ticket that can reach them.
