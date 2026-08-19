---
aep: 2.6.0
owner: repository
date: 2026-08-19
kind: spec
status: accepted
---

# Problem

AEP governs the *shape* of what a turn tells the human and nothing about how it
reads. `[[policies/reporting]]` fixes four opening slots and three closing ones,
and says outright that it governs "what is stated and in what order". Below that
line the agent writes however it writes, which in practice means it writes like a
model: puffery, hedged claims, rule-of-three lists, sentences that name a feeling
instead of a mechanism. The human reads all of it.

The same gap runs through everything else the agent authors for a human. A commit
message, a pull request title, a code comment, and a line printed by a script are
each read by a person and each governed by nothing that says how to write it.
`[[rules/version-control]]` fixes the commit format and stops there.
`[[policies/engineering]]` governs writing code and says nothing about the prose
inside it.

The second half of the problem shows up only under sub-agents. Today
`[[policies/execution]]` requires the orchestrator to reconcile what each child
*claims* against what it actually changed. That is an honesty check, and it is
the only integration duty stated. Nothing requires the merged result to be
coherent: children build against their own tasks in their own worktrees, so
naming drifts between them, two of them write the same helper, and one of them
records a decision it may not make and stops. The parent then reports N summaries
stitched end to end. The human asked for one thing and receives evidence of the
machinery that produced it.

# Goal

Every text a human reads from an agent running AEP is written for that human, and
a fan-out of sub-agents arrives as one piece of work rather than as its parts.

# Scope

Two changes, one effort, because the second one ends in the first: the
orchestrator's reconciled output is itself governed text.

**Prose governance.** `[[policies/reporting]]` widens from the turn report to
every text whose reader is a human, and carries the requirement.
`skills/prose` ships as a new protocol-owned skill carrying the pattern
catalogue. The shipped surfaces under `src/` are brought into conformance, and
`verify.mjs` gains guards for the claims a script can check.

**Orchestrator reconciliation.** `[[policies/execution]]` gains what the
orchestrator owns once the last child returns, and `[[skills/implement]]` routes
to it from close-out.

# Requirements

## Prose governance

1. **`[[policies/reporting]]` governs every agent-authored text a human reads**,
   not only the turn report. Its title, `use-when`, and body widen. The file name
   does not change.

2. **The scoping test is who reads the text.** A human reads it, it is governed. A
   protocol agent reads it, it is exempt and is written for that agent instead.
   The policy states the test, then lists the worked cases that follow from it:
   governed are session output, commit messages, pull request titles and bodies,
   code comments, text a script prints to a human, and repository documentation
   such as a README, a changelog, or a docs page; exempt is prose inside `.aep/`
   artifacts, normative protocol text wherever it lives, a sub-agent brief, and
   data a script writes into an artifact an agent reads.

   **A normative protocol document is exempt even at the repository root.** It is
   `.aep/` prose that happens to sit elsewhere, its reader is the agent building
   the protocol, and it is the document that defines the vocabulary the catalogue
   would otherwise flag. In this repository that is `specs.md` and `AGENTS.md`,
   the second because it exists to be read by a runtime.

3. **The policy carries the requirement and the hard prohibitions; the skill
   carries the catalogue.** `specs.md` §16 forbids a skill from becoming
   governance, so every MUST lives in the policy and the skill links to it. The
   prohibitions the policy names are the ones a script can check: no em dashes, no
   curly quotes, no decorative emoji, no title-case headings.

4. **Em dashes are banned in governed text.** Where a thought needs separation the
   sentence ends or takes a comma. Substituting parentheses, en dashes, or a
   hyphen for the same job does not satisfy this.

5. **`skills/prose` ships as a protocol-owned skill** at `src/skills/prose.md`,
   carrying AEP frontmatter and reachable from inside any skill that emits
   governed text, the way `[[skills/tdd]]` and `[[skills/domain]]` are reached.
   Invoked directly it is the turn's outermost skill and reports like any other.
   No installer change is needed: `payload.mjs` installs `skills/` as a whole
   directory, so the file is picked up by existing behaviour, and nothing is being
   renamed or retired so no declared move applies.

   **It is named `prose` rather than `unslop`**, the name the draft arrived under.
   Every other skill is a plain noun or verb, an adapter publishes the name to
   every runtime, and slang dates faster than the catalogue it labels.

   **The draft at `.aep/skills/unslop.md` holds the only copy of the catalogue.**
   It sits in the output tree, where it ships nothing and fails `validate.mjs` on
   every run for want of AEP frontmatter. It is deleted **after** its content has
   been carried into `src/skills/prose.md` and never before, and until then the
   tree stays red on those four failures.

6. **The catalogue softens one item and keeps the rest.** The draft's ban on
   abstract metaphor nouns becomes a limit rather than a prohibition, with the
   carve-out that a word this repository's domain defines is the domain's word.
   This is what `[[skills/domain]]` already requires, and without it the skill
   would forbid `primitive`, `surface`, and `scaffolding`, which are AEP's own
   defined vocabulary.

7. **The shipped scripts conform.** Comments and human-facing strings under
   `src/**/*.mjs` carry no em dashes. The one legitimate remaining use is the
   empty-cell placeholder `index.mjs` writes into `.aep/index.md`, which is exempt
   under requirement 2 because an agent reads it.

   **This repository's own governed documentation conforms too**: `README.md` and
   `CHANGELOG.md`, which hold 16 and 67 em dashes. `specs.md` and `AGENTS.md` are
   exempt under requirement 2 and are not touched, leaving 166 of the 249 in root
   documentation deliberately in place.

8. **`verify.mjs` asserts every claim a script can check**, and each new guard is
   confirmed by breaking the thing it checks and watching it fail by name
   (`[[rules/authoring]]`).

9. **The specification is amended in the same change.** `specs.md` §16 admits an
   eighteenth skill and its grouping line moves from two sub-skills to three;
   §16.2 widens with the policy. `contract.mjs`'s `SKILLS` gains `prose`, and the
   committed adapters regenerate.

## Orchestrator reconciliation

10. **`[[policies/execution]]` states what the orchestrator owns once the last
    child returns.** Three things a child structurally could not do:

    - **the seams**, where children's diffs meet: naming that drifted between
      them, a helper two of them wrote, a pattern one followed and another did
      not. **The seam is the bound.** A surface two or more children touched, or a
      name one introduced and another consumed, is the orchestrator's to
      reconcile. Anything else it notices inside one child's work is **raised, not
      taken**, exactly as `[[skills/implement]]` already treats an improvement
      spotted mid-task, and it returns to the frontier as a task. *Why the bound
      is drawn at the diffs rather than at the effort: a bound read off spec.md
      cannot distinguish reconciling a seam from rebuilding a task a child already
      delivered, and the parent is the one agent with no reviewer above it.*
    - **every decision a child recorded and stopped on**, raised to the human by
      the orchestrator, since a child has no surface on which to ask;
    - **one account of the work**, written as though one agent had done it
      sequentially, rather than each child's summary concatenated.

    The third obligation governs the voice *and* what is said. The account
    describes **the work rather than the workers**, and sub-agent structure
    surfaces only where it changed the outcome: a child that failed, a child that
    stopped on a decision the human must make, a task that returned to the
    frontier. The existing closing block already has the slots those land in.
    **This is not a licence to suppress a failure** — a fan-out that lost a task
    changed the outcome by definition, and the reading under which the machinery
    is hidden unconditionally is the one this requirement rejects.

11. **That account is governed text**, so it passes requirement 1. This is where
    the two halves of this effort meet.

12. **`[[skills/implement]]`'s close-out routes to it**, so the obligation is
    reachable from the skill that dispatches rather than only from the policy.

13. **The child writes plainly and the orchestrator presents.** A child that stops
    on a decision it may not make records the question and its options in plain
    terms, under no obligation to the catalogue. The orchestrator applies the
    skill when it raises that question to the human. This is the general shape of
    the effort applied to one case: the child does the work it can do, and what it
    cannot do is the parent's.

    **The orchestrator may reshape the wording and never the substance.** What is
    being asked and which options are offered survive unchanged. A presentation
    that drops an option, merges two, or narrows the question is a different
    question wearing the child's name.

    **Attribution therefore names the source, not the author of the words.** The
    question is the child's and the task's; the phrasing the human reads is the
    orchestrator's. `[[policies/execution]]` already binds the answer verbatim on
    the way down, and that is untouched: an answer carries the human's authority
    and a question does not.

    A brief stays exempt in both directions. It is written by an orchestrator and
    read by an agent, which is the test in requirement 2 applied unchanged. No
    definition under `agents/` changes.

# Acceptance Criteria

1. `policies/reporting.md`'s heading and `use-when` name every human-read text
   rather than the turn report, and `index.md` regenerates showing the new
   trigger.
2. The policy states the reader test in one sentence and lists both the governed
   and the exempt cases beneath it. Checked against two cases on neither list: an
   inline review comment the agent posts to a pull request resolves to governed,
   and a `position/marker.json` a script writes for a later run resolves to
   exempt. A policy from which either case cannot be resolved has failed this
   criterion, whatever its lists contain.
3. `verify.mjs` fails when the policy stops naming `skills/prose`.
4. `verify.mjs` fails when any of the four hard prohibitions is absent from the
   policy, by name.
5. Counting em dashes over comments and string literals in `src/**/*.mjs` returns
   zero, excluding the single named placeholder constant in `index.mjs`. The guard
   that asserts this was confirmed by reintroducing one em dash into a comment and
   watching it fail with that file's name.
6. `src/skills/prose.md` exists, declares `kind: skill`, `owner: protocol`,
   `report:`, and a `use-when` naming its trigger, and passes `validate.mjs`.
7. `contract.mjs`'s `SKILLS` holds eighteen names and `verify.mjs`'s on-disk
   comparison passes.
8. `specs.md` §16 names eighteen skills, its sub-skill grouping reads three, and
   `verify.mjs`'s spec-to-surface comparison passes.
9. `node src/scripts/adapters.mjs` leaves the committed adapters unchanged, and
   every adapter exposes `prose`.
10. `README.md` and `CHANGELOG.md` carry no em dashes. `specs.md` and `AGENTS.md`
    are unchanged, and a diff touching either has misread requirement 2.
11. `policies/execution.md` states all three orchestrator obligations, and
    `verify.mjs` fails when any one of them is removed.
12. The policy bounds the seam pass at the surfaces children's diffs share and
    sends anything else to the frontier. `verify.mjs` fails when the bound is
    absent, because an unbounded seam pass and a bounded one read identically
    until a parent uses the difference.
13. The policy states both halves of the third obligation: that the account
    describes the work rather than the workers, and that structure surfaces where
    it changed the outcome. A version carrying only the first half is the failing
    version, because it reads as permission to hide a lost task.
14. `policies/execution.md` states that the orchestrator presents a child's
    recorded question in governed form and that what is asked and which options
    are offered survive unchanged. `verify.mjs` fails when the substance clause is
    removed and the presentation clause left standing, which is the version that
    licenses a rewritten question. Nothing under `src/agents/` changes, and a diff
    touching those four files has exceeded requirement 13.
15. `skills/implement.md` links to the reconciliation section from its close-out,
    and `verify.mjs` asserts the link.
16. `node src/scripts/verify.mjs` and `node .aep/scripts/validate.mjs` both exit
    zero after reinstalling.

# Constraints

- **`src/` is source and `.aep/` is output.** Every change lands in `src/` and
  reaches `.aep/` by reinstalling (`[[contexts/repository]]`). Editing the
  installed copy ships nothing.
- **A skill MUST NOT become governance** (`specs.md` §16). Every MUST belongs to
  the policy; the skill links to it. This constraint decides the whole shape of
  requirement 3, and violating it would put the same claim in two files that then
  disagree.
- **Shipped text cites only what resolves where it is read** (`[[rules/authoring]]`).
  `src/skills/prose.md` may name `[[policies/reporting]]`; it may not name
  `specs.md` or a section number.
- **A checkable claim without an assertion is untested by construction**
  (`[[rules/authoring]]`). Each new guard is broken deliberately once.
- **No hand restamping.** `release.mjs` sets versions and stamps only what
  changed.
- **The catalogue is craft, not law.** The skill describes how to detect and
  repair a tell. It does not restate the policy's prohibitions as its own rules.

# Out of Scope

- **Prose inside `.aep/` artifacts.** Policies, skills, modes, templates, specs,
  tickets, contexts, and the protocol itself keep the voice they are written in.
  Their reader is an agent, and the em dash carries load in that prose. This is a
  deliberate boundary, not an oversight, and requirement 2 is what makes it
  principled rather than convenient.
- **This spec and this effort's tickets.** Artifact prose, and therefore exempt by
  the same test. A spec written to a ban its own subject exempts would be the
  first thing to confuse a later reader.
- **Localisation, register, and personality.** The contract is English, and this
  effort governs tells rather than the agent's manner. Whether the agent is terse
  or warm is untouched.
- **Runtime rendering.** Colour, boxes, spinners, and Markdown dialect belong to
  the runtime, exactly as `[[policies/reporting]]` already says.
- **Splitting a task across sub-agents.** Requirement 10 gives the orchestrator
  work after children return. It does not weaken the rule that one child builds
  one whole task, and no part of reconciliation is delegated downward.
- **A second review axis.** The orchestrator's seam pass is integration, not
  review. `[[skills/review]]`'s two axes are unchanged and still run.
- **Rewriting git history.** Existing commit messages stand. The ban applies to
  messages written from here.

# Assumptions

- **Two boundaries drawn by `uniform-reporting` are superseded here rather than
  respected.** That effort's Out of Scope declined "a conversational register for
  the agent generally", and separately declined restyling script output. Both are
  reversed deliberately, and both reversals are named in this spec so the next
  reader finds the newer decision rather than the older one.
- **The counts were measured on `HEAD` at `92cca17` and move if those files move
  first.** 171 em dashes across 168 lines of `src/**/*.mjs`, split roughly 93
  comment lines to 75 others; 249 in root documentation, of which 83 are governed
  and 166 are not.

# Open Questions

- **Does `prose` declare `mode:` or is it modeless?** `specs.md` §16 currently
  says exactly two skills enter no mode, and names them, so the suite can require
  a mode of every other skill. A skill applicable in all eight modes and entering
  none of them fits neither shape cleanly. Either the sentence admits a third name
  or the skill declares all eight.
- **Does this release owe an upgrade notice?** Widening a policy changes what an
  installed repository's agent is required to do, which is the kind of thing a
  notice exists for. Whether it rises to one is decided by comparing releases
  rather than at runtime.
- **How does the guard distinguish a comment or a human-facing string from the
  exempt placeholder?** Naming the constant and allowing the em dash only in its
  declaration is the obvious answer, but it is a plan decision and the alternative
  is a comment-and-string-literal parse.

# Risks

- **The skill and the policy drift into saying the same thing.** The catalogue
  reads like a list of rules, so the pull toward restating the prohibitions inside
  it is constant. It shows up as a later edit changing one file and not the other,
  and the guard for requirement 3 is the only thing that would catch it.
- **The em dash ban leaks into artifact prose by habit.** An agent that has just
  been told em dashes are banned will apply it everywhere, including the files
  this effort exempts. It shows up as a quiet rewrite of protocol-owned prose in
  an unrelated commit.
- **The seam pass is bounded on paper and judged by the party it binds.**
  Requirement 10 draws the bound at the surfaces children's diffs share, which is
  readable off the diffs, but the orchestrator is the one agent with no reviewer
  above it and it decides its own compliance. It shows up as a parent's diff
  larger than the children's it integrated.
- **The catalogue is judged, not checked, and so are the hard prohibitions in the
  place they matter most.** `verify.mjs` sees shipped surfaces. It never sees a
  line of session output, so the em dash ban is enforceable in `src/` and advisory
  in the very text this effort exists for. Twenty-odd catalogue patterns cannot be
  asserted anywhere at all. The guards cover the mechanical minority of one half,
  and a spec that implied otherwise would be claiming a check that never runs.

# Architecture

One policy widens, one skill ships, and the bootstrap points at both. Nothing new
is created in the governance layer, and the reason is mechanical rather than
aesthetic: `verify.mjs` asserts that the shipped governance layer stays small and
throws above five policies. Five ship today. A sixth would fail the suite, so
`policies/prose.md` was never available as an option and the widen was forced.

**How the obligation reaches the agent.** Policies load by applicability, and
`reporting`'s trigger fires today when a report is being authored or audited. An
agent writing a commit message has no reason to load it, so the requirement would
be invisible at the moment it binds.

| | Advantages | Disadvantages | Risks | Maintenance |
| --- | --- | --- | --- | --- |
| **A. Bootstrap invariant, plus a widened trigger** *(chosen)* | read at every session start, so the obligation is known before the first line is written; the invariants list exists for exactly this | spends part of 441 bytes of bootstrap headroom | a later invariant has nowhere to go and the budget guard fails a release | one clause in one file |
| **B. Policy trigger only** | cheapest; nothing outside the policy changes | relies on an agent deciding that writing a commit message is a reason to load a policy about reports | the policy ships and changes no behaviour, which reads as conformance | none |
| **C. Every skill links the catalogue** | reaches the agent inside whatever it is running; cannot be missed | seventeen copies of one pointer, each needing its own guard | the second-home pattern this repository has rejected twice | seventeen files, forever |

B loses because discovery by trigger only works when the trigger fires, and this
one does not fire where the text is written. C loses on the same ground the slot
set is pinned to one artifact: a pointer in seventeen files is seventeen things
to keep agreeing.

# Components

| File | Gains |
| --- | --- |
| `src/policies/reporting.md` | the reader test, the governed and exempt lists, the four hard prohibitions, a link to the skill; title and `use-when` widen |
| `src/policies/execution.md` | the orchestrator's three post-dispatch obligations, the seam bound, and the present-the-question clause |
| `src/protocol.md` | one clause on the `Every turn reports` invariant, and a widened trigger in the governance table |
| `src/skills/prose.md` | **new**, the pattern catalogue written as procedure |
| `src/skills/implement.md` | a link from close-out to the reconciliation section |
| `src/scripts/contract.mjs` | `prose` in `SKILLS`, and the count in its doc comment |
| `src/scripts/index.mjs` | the empty-cell placeholder becomes a named constant written as an escape |
| `src/scripts/payload.mjs` | a `2.7.0` entry in `NOTICES` |
| `src/scripts/verify.mjs` | the new guards, and the count in its skill-set assertion |
| `src/**/*.mjs` | 168 lines lose their em dashes |
| `README.md`, `CHANGELOG.md` | 83 em dashes rewritten |
| `specs.md` | §16 admits an eighteenth skill and a third sub-skill; §16.2 widens; §29 and the conformance list follow the count |
| `src/adapters/**` | regenerated, three trees, one command |

# Technical Approach

## The policy's spine is the reader test

The test is one sentence and the lists are worked examples under it, never the
definition. A case on neither list resolves from the test alone, which is what
acceptance criterion 2 checks with two cases nobody enumerated.

The four hard prohibitions sit in the policy because a script can check them and
because they are MUSTs. Everything else about how text reads is craft, and craft
lives in the skill. `specs.md` §16 forbids a skill from becoming governance, so
this split is not a preference either.

**The policy may not name a rendering.** `verify.mjs` already fails
`reporting.md` and `protocol.md` on a word list covering `terminal`, `colour`,
`ANSI`, and four runtime names. The widened prose stays clear of it.

## The skill

```yaml
kind: skill
owner: protocol
mode: [specify, plan, refine, implement, research, prototype, review, test]
report: full
use-when: "about to emit text a human will read, or editing text that reads as machine-written"
```

**All eight modes rather than modeless.** `mode:` is applicability, and this
applies in every mode. Declaring it modeless would mean amending `specs.md` §16's
*exactly two skills enter no mode* sentence, which names `help` and `handoff`
explicitly so the suite can require a mode of everything else. Widening that
exemption to buy nothing is the worse trade.

**`report: full`.** The authoring test asks whether the skill writes to the
repository, dispatches, or decides on the human's behalf. Invoked directly on a
README it writes, so the answer is yes. `tdd` is the precedent: a sub-skill that
declares `full`. The mechanical consequence is that `verify.mjs` extracts stage
names from the procedure, so the procedure is written as numbered steps with
bolded names, in the shape `stageNames()` already reads.

The catalogue stays in the skill file rather than moving to a note under
`skills/prose/`. A note is for knowledge a run needs only when it takes a
particular branch; every run of this skill uses the whole catalogue, so splitting
it would pay the note's indirection on every invocation and save nothing.

## The em dash sweep, and why no exemption is needed

`index.mjs` writes the em dash into `.aep/index.md` as its empty-cell
placeholder, in three literals. That output is artifact prose an agent reads, so
it is exempt, but a guard cannot read intent.

**The placeholder becomes one named constant written as a Unicode escape**, with
a comment saying why. The character then appears nowhere in `src/**/*.mjs`, the
guard is a flat scan for U+2014 with no whitelist, and the open question about
telling comments from strings from data does not need answering. A future
legitimate use writes the escape too, and the guard's failure message says so.

This is better than either option the spec left open. A whitelist by constant
name is a hole that grows, and a comment-and-string-literal parse is a parser
nobody asked for.

## What the orchestrator's clauses say

Three obligations, the seam bound at the surfaces children's diffs share, and the
account that describes the work rather than the workers. The present-the-question
clause reshapes wording and never substance, and `policies/execution`'s existing
*the answer travels verbatim* sits untouched directly above it.

`skills/implement`'s close-out gains one link. Nothing under `src/agents/`
changes, and requirement 13 says a diff touching those four files has overshot.

# Integration

The skill count is stated in eight places outside the payload directory:
`contract.mjs`'s doc comment, `install.mjs`'s comment, `verify.mjs`'s skill-set
assertion, `skills/install.md`, and `specs.md` at §16, §16.1, §29, and the
conformance list. Each moves from seventeen to eighteen, and §16's grouping line
moves from two sub-skills to three. `specs.md` §16.2's *either sub-skill* becomes
a phrasing that admits three.

Adapters regenerate with `node src/scripts/adapters.mjs` and are committed. The
release is `node src/scripts/release.mjs 2.7.0`, which stamps only what changed,
and a reinstall brings `.aep/` forward.

**The notice.** `NOTICES` gains a `2.7.0` entry. What it asks the reader to check
is that a repository with its own prose conventions now sits under a policy: a
rule may tighten a policy and never soften it, so a house convention that
contradicts the ban has to be reconciled rather than left standing. The notice
text is itself printed to a human, so it is governed by the policy it announces.

# Testing Strategy

| Criterion | Checked by |
| --- | --- |
| 1 heading and trigger widened | `index.md` regeneration, plus a guard on the policy's `use-when` |
| 2 reader test resolves unlisted cases | guards pinning the test sentence and both lists by phrase |
| 3 policy names the skill | guard, and it fails when the link goes |
| 4 four prohibitions named | one guard per prohibition, by name |
| 5 no em dashes in scripts | flat U+2014 scan over `src/**/*.mjs` |
| 6 skill frontmatter | `validate.mjs`, plus the existing per-skill assertions |
| 7 `SKILLS` holds eighteen | the existing on-disk comparison, which fails on any mismatch |
| 8 specification amended | the existing spec-to-surface comparison |
| 9 adapters current | the existing staleness guard |
| 10 governed documentation swept | U+2014 scan over `README.md` and `CHANGELOG.md`, and an assertion that `specs.md` and `AGENTS.md` are **not** scanned |
| 11 three obligations | one guard each |
| 12 seam bound present | guard on the bound's phrase |
| 13 both halves of the account clause | guard that fails the first-half-only version |
| 14 present, never rewrite | guard on the substance clause |
| 15 close-out links | guard on the link |
| 16 suite and validator green | the run itself |

Every new guard is broken deliberately once, and the perturbation must remove the
subject rather than something travelling with it (`[[rules/authoring]]`). For the
U+2014 scan that means reintroducing one em dash into a comment and confirming
the failure names that file.

**The guard needing the most care is criterion 10's negative half.** A scan that
walked every Markdown file at the root would pass while quietly governing
`specs.md`, which requirement 2 exempts. The assertion therefore pins the file
list rather than deriving it, and a `specs.md` full of em dashes is the fixture
that proves it.

# Operational Considerations

`protocol.md` has 441 bytes under the budget and `verify.mjs` fails a release
that exceeds it. The invariant clause and the governance-table trigger are the
only additions, and both are measured before the release rather than after.

`validate.mjs` stays red on four failures for as long as `.aep/skills/unslop.md`
sits in the output tree. It is deleted in the same task that lands
`src/skills/prose.md`, never before, because it holds the only copy of the
catalogue.

# Technical Risks

- **The bootstrap budget.** Two additions to a file with 441 bytes of headroom.
  It shows up as a failed release rather than as a silent problem, which is the
  good kind, but it forecloses the next invariant.
- **The sweep touches ten scripts and two documents in one effort.** Several of
  those files are read by guards elsewhere in the suite, and a rewrite that
  changes a pinned phrase breaks an assertion unrelated to this effort. Phrases
  are pinned with `\s+` between words precisely because the payload rewraps, so a
  reflowed line is safe and a reworded one is not.
- **The eighteenth skill is stated in eight places.** Missing one leaves the suite
  green in some sections and red in another, and the failure names a count rather
  than the file that is stale.
