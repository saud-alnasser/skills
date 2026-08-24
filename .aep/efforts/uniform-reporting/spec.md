---
status: implemented
---

# Problem

What a skill tells the human is invented locally, skill by skill, and nothing
governs it.

Some of it is deliberate and load-bearing. `[[skills/implement]]` opens with a
mandatory position report quoted from the script, on the reasoning that *a silent
check is indistinguishable from one that never ran*. `[[skills/specify]]` requires
a stated understanding carrying its assumptions, and a report of the sizing floor.
`[[skills/review]]` fixes two headings and caps each. `[[skills/tasks]]` reports
the graph. `[[skills/install]]` and `[[skills/update]]` report what they assumed
on the repository's behalf.

Every one of those was written for its own skill. They use different vocabulary
for the same act, they fire at different points, most of the seventeen skills say
nothing about narration at all, and the specification has no section defining it.

The cost falls on the human:

- **The shape changes under them.** Two invocations of AEP produce two different
  report layouts, so nothing can be found by position and every output is read
  from the top.
- **Silence is ambiguous.** Where a skill states no position check, the human
  cannot tell a clean tree from an unread one.
- **Decisions made on their behalf are invisible.** Routing — *this was judged a
  new change, so `/specify` is running* — happens in every invocation and is
  stated in almost none, so a wrong route is discovered by its consequences.
- **The end of a turn leaves no handhold.** What state the work is now in, what
  the near next step is, and what is still unsettled are reconstructed by the
  human from the transcript, every time.

# Goal

A human reading any AEP invocation, in any repository, on any runtime, sees the
same report in the same shape: where the agent is standing and what it verified,
how it classified the request and why this skill is running, what it is assuming,
the stages it is about to cross — each one marked as it is crossed — and, at the
end, the current state, the near next step, and anything unsettled with how to
settle it.

The protocol's behaviour is exactly what it is today. Only what reaches the human
changes.

# Scope

- A **fixed report skeleton** — verbatim labels, fixed order — for what a skill
  states on entry, at each stage boundary, and on exit.
- Its application across **every shipped skill**, absorbing the reporting each
  skill invented for itself so there is one shape rather than one plus sixteen.
- Its definition as **protocol-owned, agent-agnostic** text: a contract over what
  is stated, never over how a runtime renders it.
- The **normative statement** in `specs.md` and the **assertions** in the
  verification suite, in the same change.

# Requirements

1. **One skeleton, verbatim.** A single fixed set of labels, in a fixed order, is
   defined once and used by every skill. A skill does not word it in its own
   register and does not reorder it.

   **The unit is the turn, not the skill entry.** One thing the human typed
   produces exactly one opening report and exactly one closing block, emitted by
   the outermost skill. A skill entered from inside another — `[[skills/review]]`
   and ``skills/commit`` from `[[skills/implement]]`'s close-out,
   `[[skills/tdd]]` and `[[skills/domain]]` as sub-skills — is announced as a
   **stage of the run it is inside**, and opens no report of its own. Everything
   those skills produce is unaffected; only the preamble is not repeated. *Why:
   one typed command can enter four skills, and four preambles for one request is
   the ceremony that gets skipped — and a contract skipped in practice is
   advisory in fact.*

2. **The opening report states four things**, in this order: **standing** — the
   state this skill establishes on entry, verified; **classification and
   routing** — what kind of request this was judged to be, which skill is
   therefore running, and why; **assumptions in force** — what is being proceeded
   on without verification, separated from what was checked; **the stages ahead**
   — the steps this invocation will cross, named.

   **The standing slot is one label filled with what each skill already
   verifies** — never a new check. `/implement` fills it with the marker against
   `HEAD` and the tree, `/review` with the pinned merge-base and the subject's
   size, `/commit` with the fact that the stages ran — position, tests, review
   outcomes, which is what its own step 1 establishes — and `/research` with
   *nothing to verify*.
   Thirteen skills read no position today and none of them starts. *Why the label
   is fixed but its content is not: a slot that can be omitted is the crack
   uniformity leaks out of — the human stops reading by position and starts
   reading by label — while a mandatory position check in every skill buys that
   uniformity with a behaviour change nobody asked for.*

   **A skill with nothing to verify states that it has nothing to verify.**
   Silence is indistinguishable from an unread check, which is the reasoning
   `[[skills/implement]]` already carries and this generalises.

3. **Two forms, and the form is a property of the skill, not of the run.** One
   test — *does this skill write to the repository, dispatch a sub-agent, or
   decide on the human's behalf?* — is applied once, at authoring time, and the
   answer is declared in the skill's own file. It is never re-evaluated mid-run,
   so the human knows which shape they will get before the invocation starts.

   Applying the test to what ships today:

   | Form | Skills |
   | --- | --- |
   | **full** | `specify` `refine` `plan` `tasks` `implement` `review` `commit` `research` `prototype` `prune` `install` `update` `tdd` `handoff` |
   | **short** | `help` `survey` `domain` |

   `refine` and `handoff` are full because both write to the repository — `refine`
   into `spec.md`, `handoff` when it moves durable knowledge to its home before
   writing the handoff itself.

   **Both forms carry the same four labels, in the same order. What separates
   them is the stage markers.** A full-form skill lists every stage in `Stages`
   and marks each one as it is crossed; a short-form skill names one stage and
   emits no markers. A slot is never dropped, and a reader learns one layout and
   never meets a second. *Why the difference sits here: the preamble is paid once
   and the markers are paid per stage, so the recurring cost — and therefore the
   only saving worth defining a second form for — is the markers.*

   ```
   full                                short
   Standing   marker ed03670           Standing   nothing to verify
              HEAD ed03670  clean      Request    question about AEP -> /help
   Request    task 03 ready ->         Assuming   —
              /implement               Stages     answer
   Assuming   frontier is the
              recorded query's answer
   Stages     position > take >
              claim > build > review
   ```

   An invocation never silently omits the report; the short form is a shorter
   report, never no report.

4. **A full-form skill marks each stage as it is crossed**, using the stage names
   its opening report listed. The names match; a stage that appears in the run
   but not in the opening list is a defect in one of the two. A short-form skill
   emits no markers, so it has nothing to match.

   **The stage names come from the skill's own procedure**, which is where they
   already are: three skills declare them as numbered headings and eleven carry
   them as a numbered list under `## Procedure`. Naming a step is presentation
   and adds none — Requirement 7 still holds.

5. **Every turn closes with a fixed closing block** carrying three labelled
   slots: **state** — where the work now stands; **next** — the near next step,
   as a suggestion; **unsettled** — anything that should be settled before
   continuing, each with how to settle it. It is a lantern, not a map — the near
   objects only, never a roadmap.

   **A turn that stops early closes with the same block.** An empty frontier, a
   refused permission, a request that routes elsewhere, a conflict surfaced
   instead of resolved — each ends the turn, and each is where the lantern is
   worth the most. The `Unsettled` slot is what the block exists for; a run that
   stopped *because* something is unsettled and then closed silently has failed
   at the one job.

6. **The contract is content, not rendering.** It states what must appear and in
   what order. It assumes no terminal, no colour, no width, no markup dialect,
   and no runtime feature.

7. **No procedure changes.** No skill gains, loses, or reorders a step, and no
   decision any skill makes today is made differently. The diff is what is said,
   never what is done.

8. **The requirement is normative and asserted.** `specs.md` defines the contract,
   and the verification suite fails when a shipped skill does not satisfy it.

# Acceptance Criteria

1. The skeleton is defined in exactly one shipped artifact. Every skill that
   reports reaches it by link, and no skill restates it. The suite asserts that
   the definition exists in exactly one place and that no skill file carries a
   second copy of the labels.

1a. The contract states that the unit is the turn and that a nested skill entry
   opens no report. The suite asserts this, and asserts that the skills reached
   from inside another — `review` and `commit` from `implement`, `tdd`, `domain`
   — say so where they are reached from. Broken version: a `/implement` run that
   emits three opening reports.

2. The suite asserts each of the four elements is required by the contract, by
   name, and that they are required in the stated order. It further asserts that
   **no slot is optional**: the contract states that a skill with nothing to put
   in one says so rather than omitting the line. Broken version: a skill whose
   opening report is three lines instead of four.

2a. No skill acquires a position read it does not perform today. Verified by
   listing the skills that invoke `position.mjs` before this change and after,
   and showing the two lists identical.

3. **Every shipped skill declares its form**, and the declaration matches the
   test. The suite asserts the declaration is present on all seventeen, that
   nothing selects a form at runtime, and that the contract defines the
   difference as the stage markers rather than as value length. Broken version: a
   skill that writes to the repository and declares itself short.

4. For every **full-form** skill, the stage names in its procedure and the stage
   names its opening report lists are the same set, in the same order. The suite
   asserts this by reading each skill's own procedure — its numbered headings
   where it has them, its `## Procedure` list where it does not — so the two
   cannot drift. Broken version: a skill whose `Stages` line names five steps
   while its procedure has six.

5. The suite asserts the closing block is required, and that it requires all three
   of state, near next step, and unsettled-with-how-to-settle. A skill that ends
   without it fails.

6. No shipped surface naming this contract mentions a terminal, colour, width,
   ANSI, or a named runtime. The suite asserts this over the contract's own text.

7. The diff for this effort adds, removes, and reorders no procedural step in any
   skill. Verified by reading each skill's step list before and after and showing
   them identical.

8. `node src/scripts/verify.mjs` passes, and each new guard was confirmed to fire
   by deliberately breaking the thing it checks and watching it fail by name
   (`[[rules/authoring]]`).

9. `[[skills/implement]]`'s position report, `[[skills/specify]]`'s stated
   understanding, `[[skills/review]]`'s two headings, and `[[skills/tasks]]`'s
   graph report each either conform to the skeleton or are named in the contract
   as a declared extension of it. None survives as a competing shape.

# Constraints

- **Agent-agnostic.** AEP MUST NOT assume a runtime, and a report contract is
  exactly where that assumption creeps in. The contract governs content; how a
  runtime paints it is the runtime's business. *Why: the moment the contract
  implies a terminal, every non-terminal consumer is out of conformance for
  reasons unrelated to what they say.*
- **One home, no summaries.** The skeleton is defined once and linked to. A skill
  that repeats the labels inline becomes the copy that drifts.
- **Shipped text cites only what resolves where it is read.** The contract is read
  inside a consuming repository, so it may not cite `specs.md` or a section
  number (`[[rules/authoring]]`).
- **`protocol.md` has a byte budget** the suite enforces. Whatever the contract
  costs the bootstrap, it must fit inside it.
- **The report is paid for on every turn**, out of the human's attention and the
  agent's context, in every repository running AEP. It competes directly with
  *pick the smallest process that produces a reliable result*.
- **The existing reporting is precedent, not competition.** `/implement`'s step 0
  exists for a stated reason and that reason survives; the contract must be able
  to express it rather than replace it with something weaker.

# Out of Scope

- **Sub-agent returns.** The child-to-orchestrator contract — done, failed,
  stopped, waiting, plus a path and a compressed summary — is defined in
  `[[policies/execution]]` and is not human-facing. It is untouched.
- **Script output.** `position.mjs`, `validate.mjs`, and `index.mjs` produce what
  they produce; a skill quotes it. This effort does not restyle a script's output,
  and does not move a line from the script's half of a report into the agent's.
- **Any change to a skill's procedure**, its decisions, its ordering, or what it
  produces. This effort is legible narration over unchanged behaviour.
- **Runtime rendering** — colour, ANSI, boxes, progress indicators, spinners,
  tables in a particular Markdown dialect, or anything a specific runtime can do
  and another cannot.
- **The adapter's wrapper text.** Generated from the payload, and out of scope
  unless regenerating it is a mechanical consequence.
- **Localisation.** The contract is English, like the rest of the distribution.
- **A conversational register for the agent generally.** This governs the report
  at entry, at stage boundaries, and at exit — not every sentence the agent says.

# Assumptions

- The request is about **human-facing output only**. Machine-facing output and
  agent-to-agent output are unchanged.
- **The contract names no extension point**, so a repository that must differ
  differs the way it differs from any protocol-owned artifact: a **declared
  deviation**, recorded in a repository rule with its reason and the release it
  was declared under, surfaced by `[[skills/update]]` on every run
  (`[[policies/artifacts]]`). This is not a decision this effort makes — it is
  what the policy already says about every protocol-owned artifact, and the
  report contract is one.
- **Seven labels can be written that read naturally in all seventeen skills.**
  Believed, not demonstrated. `/help` and `/handoff` enter no mode; `/help` now
  fills `Standing` with *nothing to verify — explains the protocol*, which is
  honest but is also the thinnest the slot ever gets.
- The four opening elements and the three closing ones are **the right set**.
  They came from the request and survived one grill, which moved `Position` to
  `Standing`, made the unit the turn, and put the full/short difference in the
  stage markers. The **words** on the labels have not been attacked — see Open
  Questions.

# Open Questions

1. **Are these the right seven words?** `Standing` `Request` `Assuming` `Stages`
   / `State` `Next` `Unsettled`. They are quoted verbatim by seventeen skills and
   pinned by the suite, so they are cheap to change now and expensive after.
   `Standing` in particular was chosen to survive holding four different kinds of
   verified state; whether it reads as *state of the work* rather than *state of
   the agent* is exactly the kind of thing `[[skills/domain]]` settles.
2. ~~Where does the contract live?~~ **Answered below** — the invariant in the
   bootstrap, the detail in a policy.

# Risks

- **Ceremony.** A fixed block on a one-line change reads as noise, and noise gets
  skipped. A contract skipped in practice is advisory in fact, and it will be
  skipped exactly where the human was least likely to notice it was needed.
- **A second home for state.** The opening report lists stages; the skill's own
  procedure defines them. Two statements of one thing, and the suite has to hold
  them together or they drift.
- **Brittle assertions.** Asserting literal labels makes every wording change a
  suite change. Asserting loosely makes the guard match something travelling with
  the thing rather than the thing itself — the failure `[[rules/authoring]]` names
  specifically.
- **Cost compounding.** Seven labels per turn, plus one marker per stage, in
  every consuming repository. Fourteen of seventeen skills are full-form, so the
  short form relieves almost nothing — the protocol may have made every small
  task more expensive to buy legibility on the large ones. This is the risk to
  watch after it ships, and the one nothing in the suite can catch.
- **The lantern degrades into a form to fill in.** `Next` and `Unsettled` are
  only worth their lines when they say something the human did not already know.
  A run that closes with *Next: continue* has satisfied the contract and told
  them nothing, and no assertion can tell the two apart.

# Architecture

**The contract splits along the line AEP already splits governance on.** The
bootstrap holds what is true on every turn; the policy holds the detail needed
when authoring or auditing a skill. This is the shape *Ownership is declared*
already has — one invariant in `[[protocol]]`, the full contract in
`[[policies/artifacts]]`.

```
protocol.md                  "Every turn reports" — the turn unit, and the link  ~330 bytes
└── policies/reporting.md    the skeleton, the two forms, the test, the slots
    └── skills/*.md          report: full | short  +  stage names in the procedure
        └── verify.mjs       asserts the contract, the declarations, the stages
```

**Measured, not assumed:** `src/protocol.md` is 7,407 bytes against the
8,192-byte budget `verify.mjs` enforces, so the invariant fits in existing
headroom and the budget constant does not move.

**Alternatives, and why they lost.**

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| A policy alone | one file; validator and suite already handle policies | its `use-when` fires every turn, and the bootstrap is where an always-applying requirement belongs | becomes the policy nobody loads by trigger, because the trigger is *always* — the failure `[[policies/artifacts]]` names | one file |
| The bootstrap alone | one home, loaded by definition | the full contract is 1.5–2.5 KB against 785 bytes of headroom | the bootstrap grows into the governance layer the suite asserts it is not | budget constant moves |
| **Bootstrap + policy** — chosen | fits the headroom; matches the shape already in use; detail loads when it applies | two files | the invariant and the policy drift | one link |

Two further decisions, both taken with the human:

**The form is declared in frontmatter**, `report: full | short`, rather than held
as a constant in `contract.mjs` beside `MODELESS_SKILLS`. *Why: the artifact
carries its own applicability metadata everywhere else in AEP, and a
repository's own skill must be able to declare a form. A constant would put the
fact in AEP's code, where a repository cannot reach it.* The cost is a change to
the frontmatter contract and a release notice.

**Stage names are read out of the skill's own procedure**, never declared
separately. *Why: a `stages:` field would be a second statement of what the
procedure already says, and the two would drift — the risk this spec already
names.* Eleven skills get their `## Procedure` items normalised to a bolded
lead; three already carry numbered stage headings and keep them.

# Components

| # | File | Change |
| --- | --- | --- |
| 1 | `src/policies/reporting.md` | **new.** `owner: protocol`, `kind: policy`. The skeleton, the labels, the two forms and the test that assigns them, the turn unit, the nested-entry rule, the no-empty-slot rule |
| 2 | `src/protocol.md` | one invariant under **The invariants**, naming the turn unit and linking to the policy |
| 3 | `src/skills/*.md` (17) | `report:` in frontmatter; procedure items normalised to bolded leads (11 files); bespoke entry and exit narration absorbed or pointed at the policy |
| 4 | `src/templates/skill.template.md` | `report:` in the skeleton, and the note skeleton states that a note carries none |
| 5 | `src/scripts/contract.mjs` | `REPORT_FORMS = ['full', 'short']` |
| 6 | `src/scripts/validate.mjs` | `report:` required on every top-level `skills/*.md`, value drawn from `REPORT_FORMS`, forbidden on a note |
| 7 | `src/scripts/verify.mjs` | a `Reporting` section: the contract's content, the per-skill declarations, the stage-name check |
| 8 | `specs.md` | §16 gains the contract; §32.2 gains the assertions; §35 gains an invariant |
| 9 | `src/scripts/payload.mjs` | a `NOTICES` entry: repository-owned skills must declare `report:` |
| 10 | `src/adapters/claude/**` | regenerated by `adapters.mjs` |
| 11 | `src/stamps.json`, `.aep/` | release, then reinstall this repository's own tree |

# Interfaces

**Frontmatter.** One situational field, on skills only:

```yaml
report: full | short
```

Required on every top-level `skills/<name>.md`. **Forbidden on a note** — a note
is not invoked, so it opens no report, and declaring one would imply it does.
The existing parser in `contract.mjs` reads it with no change: it is a scalar,
already inside the supported subset.

**Stage extraction**, the one new piece of parsing:

```
numbered headings   ^## (\d+) — (.+)$              implement, review, commit
bolded leads        ^(\d+)\. \*\*(.+?)[.:]?\*\*    the eleven with ## Procedure
```

A skill matching neither shape is a failure, never a skip. *Why both shapes: the
three long skills carry prose under each stage and need headings; the eleven
compact ones would triple in length as headings for no gain. Both already exist
in the corpus, and the parser is smaller than the diff that would remove one.*

**Two skills are normalised into the second shape**, because they fit neither
and the alternative was a guard that stops looking at them
(`[[efforts/uniform-reporting/evidence/research/skill-shapes]]`):

| Skill | Was | Becomes |
| --- | --- | --- |
| `handoff` | no numbered steps at all — sections only | a `## Procedure` whose steps are the sections it already has, in the order it already has them |
| `tdd` | two numbered lists, `## The loop` and `## For a bug`, neither under `## Procedure` | `## The loop` is the stage list; `## For a bug` stays the alternate path it is, and is not read as extra stages |

*Why not exempt them: a rule that skips exactly the cases it could not handle
passes by not looking, which is the failure `[[rules/authoring]]` names. Why not
a frontmatter hint naming each skill's procedure heading: it is a second
statement of where the steps already are, and a skill pointing at the wrong
heading would still pass.*

# Technical Approach

Ordered so nothing cites a file that does not yet exist:

1. **The policy**, then the bootstrap invariant. The contract exists before
   anything points at it.
2. **`contract.mjs` and `validate.mjs`** — the field becomes legal before any
   skill declares it, so the tree never validates against a rule it predates.
3. **The seventeen skills** — frontmatter, bolded leads, and the absorption of
   what each already says on entry and exit.
4. **The template**, so a repository authoring a skill gets the field.
5. **`specs.md`** — normative statement, assertions, invariant.
6. **`verify.mjs`** — every guard written, then **each one fire-checked**: break
   the thing it checks, confirm it fails **by name**, and confirm the
   perturbation actually removed the subject rather than something travelling
   with it (`[[rules/authoring]]`).
7. **The notice, the adapter, the release, the reinstall.**

**What absorption means, precisely.** Entry and exit *narration* is absorbed;
*output* is untouched.

| Today | Becomes |
| --- | --- |
| `[[skills/implement]]` step 0 — the position report | the `Standing` slot's content. The script still runs; only the frame changes |
| `[[skills/specify]]` step 5 — stated understanding | prose in the run, with its unverified half in `Assuming` |
| `[[skills/specify]]` step 8 — the sizing floor | prose, and the floor lands in `Next` |
| `[[skills/review]]` `## Correctness` / `## Standards` | **unchanged.** Findings, not a preamble |
| `[[skills/tasks]]` step 7 — the graph | **unchanged.** Output, not a preamble |

# Testing Strategy

Every acceptance criterion gets a guard in a new `Reporting` section of the
suite, and the suite's own failure path is proved before any result it reports
is trusted.

| AC | Guard |
| --- | --- |
| 1 | exactly one payload artifact contains the whole label set; no `skills/*.md` contains it |
| 1a | the policy states the turn unit; `implement` says `review` and `commit` run as stages of its turn; `tdd` and `domain` say they open no report |
| 2 | the policy names the four opening slots in order, and states that a slot with nothing in it says so rather than being dropped |
| 2a | the set of skills invoking `position.mjs` is exactly `commit`, `implement`, `install` — pinned by name, so a fourth is a failure. `specify` reads `position/marker.json` directly and invokes no script, which is why it is not in the set |
| 3 | all seventeen declare `report:`; every value is legal; the fourteen that write, dispatch, or decide declare `full`; the policy defines the difference as the stage markers |
| 4 | for **every** `full` skill — fourteen, no exemptions — stage names extract cleanly from one of the two shapes, and the count is non-zero |
| 5 | the policy names all three closing slots and requires them of a turn that stops early |
| 6 | no shipped surface naming the contract contains `terminal`, `colour`/`color`, `ANSI`, a width, or a runtime name |
| 7 | the step lists of all seventeen skills, before and after, are identical — recorded in the ticket that makes the change |
| 8 | `node src/scripts/verify.mjs` passes, and each guard was watched to fail |
| 9 | the four absorbed surfaces each conform, or are named in the policy as declared extensions |

# Migration

**No tree migration.** Nothing moves, so `MOVES` gains no entry and no upgrade
rewrites a link.

**One notice**, filtered by the same predicate `MOVES` uses, so a tree at or past
the release is shown nothing. It tells a repository that its **own** skills now
need `report:`, names the two legal values, and says why the field is required:
a skill with no declared form has no defined report.

# Operational Considerations

- **A repository-owned skill without `report:` fails `validate.mjs`** after the
  upgrade. This is deliberate, and it is the loudest thing this change does to
  anyone else's tree. The mitigation is the notice, carrying the exact one-line
  fix. *Why a failure rather than a warning: the validator's output is binary by
  design, and a skill whose form is undefined reports in no defined shape —
  which is the state this effort exists to remove.*
- **Every consuming repository pays the labels per turn**, plus one marker per
  stage. Nothing in the suite can measure whether that was worth it.
- `index.md` regenerates unchanged. `report:` is not a field the index carries,
  and adding it would make the index a second home for the declaration.

# Technical Risks

- **The stage parser passes by not matching.** A skill written in a third shape
  must fail rather than be skipped — a guard that skips is exactly the failure
  `[[rules/authoring]]` names. This is the fire-check most worth doing
  carefully: remove a bolded lead and confirm the failure names *that skill*,
  rather than merely reporting that something changed.
- **The absorption diff is large and touches every skill.** Seventeen files
  edited for presentation is where an unnoticed behavioural change hides.
  Acceptance criterion 7 exists for this, and it is checked by reading the step
  lists rather than by trusting the diff to look presentational.
- **`report:` reaches every consuming repository's own skills.** Cheap to add and
  impossible to guess, which is why it is a notice rather than a silent
  requirement.
- **The invariant and the policy drift.** The bootstrap names the turn unit and
  the policy names it too. The AC1 guard pins the label set to exactly one
  payload artifact, so **the invariant must link rather than list** — or that
  guard fails on the bootstrap itself. Resolve it when writing the invariant,
  not at review.
