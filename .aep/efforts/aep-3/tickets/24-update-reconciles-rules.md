---
status: resolved
---

# feat(protocol): an upgrade reconciles rules against the law that changed under them

## Outcome

`[[skills/update]]` gains the step it was missing: rules are read against the
policies the crossed releases changed, classified into restating, contradicting,
or standing, and the first two are rewritten — every edit shown as exact
before-and-after strings, as one set, before the first is written, and nothing
written on a refusal. `rules/` stops being a directory the upgrade preserves
without ever looking at.

## Acceptance Criteria

- [x] Requirement 61: the reconciliation is a step with computed candidates, a
      stated classification, an approval gate, and a refusal that writes nothing.
- [x] Criterion 49: a rule restating a changed policy is rewritten to cite it; a
      rule tightening an untouched policy is byte-identical afterwards.
- [x] The candidates are **computed**, not judged — the rule's own citations of a
      policy are what select it, so the same tree raises the same list.
- [x] A rule is never deleted. A contradiction the repository means to keep
      becomes a declared deviation (`[[policies/artifacts]]`).
- [x] The constraint that an upgrade never silently overwrites repository-owned
      governance survives this ticket rather than being carved out of.
- [x] The suite asserts the step, its gate, and its refusal, and fires with the
      right name when each is broken.

## Relevant areas

`src/skills/update.md` steps 5 and 7 and the `## Constraints` and `## Done when`
sections; `src/policies/authority.md` "Between policies and rules";
`src/policies/artifacts.md` where declared deviations are defined;
`src/scripts/verify.mjs` near the update section.

## Constraints

**The approval gate is the one that already exists for tracker writes** — exact
strings, one set, ask once, write nothing on refusal (`[[policies/execution]]`).
Do not invent a second gate with different words; a governance write and a
tracker write are the same act against somebody else's property.

Step 7 already surfaces declared deviations. The new step feeds it rather than
duplicating it: a deviation this step records is one step 7 reports next time.

## Notes

Asked for by the human at the close of `aep-3`.

The instance that proves it: this repository's `[[rules/version-control]]` had to
be hand-edited during this very effort, because 3 gives the runner permission to
push the effort branch and the rule still said never push. Nothing in the upgrade
would have found that. The rule was legal against 2.x and illegal against 3, and
the only moment the two texts are read together is the upgrade.

**Built.** One step in `[[skills/update]]`, one paragraph of law in
`[[policies/authority]]`, the normative form in `specs.md` §30, and eight guards.

**The step is numbered, not appended.** It sits at 7, between acting on the
notices and reporting deviations, and the steps after it renumbered. That
position is the point: it reads rules after the protocol files have been
replaced, so the law it compares against is the law now installed, and it feeds
the deviation report rather than duplicating it.

**The candidates are computed from citations.** A rule citing nothing raises no
candidate and a rule citing three policies is checked against all three, so the
same tree raises the same list twice. The alternative, an agent reading each rule
and deciding whether it feels affected, is a step whose output depends on who ran
it.

**Three outcomes, and the third writes nothing.** A step that always finds
something to rewrite is one that rewrites rules the release never touched, so
"tightens a policy the release did not touch" is a row in the table rather than
an unstated default.

**The gate is the one that already existed.** Exact before-and-after strings, one
set, ask once, nothing written on a refusal. Not a new gate with different words:
a governance write and a tracker write are the same act against property this
session does not own, and inventing a second gate is how the two drift.

**A rule is never deleted.** The way out of a contradiction the repository means
to keep is a declared deviation, which is what `[[policies/artifacts]]` already
provided and what step 8 already reports. The constraint against deleting a
repository-owned artifact was extended rather than carved out of.

Three fire-checks, each confirmed to have removed its subject before the run:

| Broken deliberately | Fired |
| --- | --- |
| "computed, not chosen" softened to "pick the rules that look affected" | the reconciliation computes its candidates rather than judging them |
| the refusal clause cut from the gate | the reconciliation writes nothing at all on a refusal |
| the "did not touch" row cut from the table | the reconciliation classifies three cases, and one of them writes nothing |

Four more fired against `specs.md` under ticket 25's run, two of them this
ticket's: the upgrade duty list, and the rule-legality paragraph.

**Found while building, not acted on.** This repository's own
`[[rules/version-control]]` line "A branch, merged by a pull request a human
opens" is now a restatement of law that moved: 3 has the runner open the draft.
It is exactly a case for step 7, and step 7 shows the edit before making it, so
it is in the report to the human rather than in this commit.
