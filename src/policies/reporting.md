---
use-when: "about to write anything a human will read — session output, a commit message, a pull request, a code comment, a README — or a turn's opening or closing block does not take the shape it should"
---

# Policy — what the human reads

Everything an agent writes for a human is governed here. **How it reads** is
fixed for all of it. **What shape it takes** is fixed for the turn report, which
the second half of this policy defines.

## Who reads it decides whether it is governed

**A human reads it, it is governed. A protocol agent reads it, it is exempt** —
and exempt means written for that reader instead, never written carelessly.

The two lists are worked examples of that test rather than the definition of it.
A case on neither list is settled by asking who reads it.

| Governed | Exempt |
| --- | --- |
| session output, at every point in a turn | prose inside `.aep/` artifacts |
| a commit message, a pull request title or body | normative protocol text, wherever it lives |
| a comment or docstring in source | a brief written for a sub-agent |
| what a script prints to a person | data a script writes into an artifact an agent reads |
| repository documentation — a README, a changelog, a docs page | |

**A normative protocol document is exempt even at a repository root.** It is
`.aep/` prose that happens to sit elsewhere, its reader is the agent building
against it, and it is where the vocabulary is defined that a catalogue of tells
would otherwise flag.

*Why a test and not only a list: a list settles the cases somebody thought of,
and every case it missed gets decided by whoever hits it first, differently each
time. The test decides the ones nobody enumerated — which is most of them.*

## How it reads

Governed text is written for the person reading it. Say what happened, name the
mechanism rather than the feeling, and cut what would read the same in any other
repository.

**Four prohibitions, and they are here rather than in the catalogue because a
script can check them:**

- **No em dashes.** Where a thought needs separation, the sentence ends or takes
  a comma. Parentheses, an en dash, and a hyphen standing in for one do not
  satisfy this: they trade one tell for another.
- **No curly quotes.** Straight quotes, both kinds.
- **No decorative emoji**, in a heading or beside a list item.
- **No title-case headings.** Sentence case.

Everything else about how text reads is craft rather than law, and craft lives in
`[[skills/prose]]` — the patterns that mark writing as machine-made, how to spot
each one, and what to do about it. Reach for it whenever you are about to emit
governed text, and whenever text you are editing reads as though nobody wrote it.

*Why the split: a skill that carried the prohibitions would be governance under
another name, which the protocol forbids, and a policy that carried the whole
catalogue would be thirty rules where four are checkable.*

## Every turn reports, in one shape

Every turn reports, in one shape, whichever skill is running. The shape does not
vary by skill, by runtime, or by how large the work turned out to be.

*Why one shape: a human who has to read every output from the top cannot find
anything by position, and the first thing they stop reading is the line that
would have told them the run went somewhere they did not intend.*

## The unit is the turn

**One thing the human asked for produces one opening report and one closing
block**, emitted by the outermost skill.

A skill entered from inside another — `[[skills/review]]` and `[[skills/commit]]`
from `[[skills/implement]]`'s close-out, `[[skills/tdd]]`, `[[skills/domain]]`,
and `[[skills/prose]]` as sub-skills — is a **stage of the run it is inside**. It
opens no report of its own. Everything it produces is unaffected; only the
preamble is not repeated.

*Why: one request can enter four skills, and four preambles for one request is
ceremony — and ceremony is skipped, which makes this policy advisory in fact.*

## The opening report

Four slots, in this order:

| Slot | States |
| --- | --- |
| **Standing** | the state this skill establishes on entry, verified |
| **Request** | what kind of request this was judged to be, which skill is therefore running, and why |
| **Assuming** | what is being proceeded on without verification, held apart from what was checked |
| **Stages** | the steps this run will cross, named |

**A slot with nothing to put in it says so.** It is never dropped, and the report
is never three slots long.

*Why: silence is indistinguishable from a check that never ran — and a slot that
may be omitted is where uniformity leaks away, because the human stops reading
by position and starts reading by label.*

### `Standing` is filled with what the skill already verifies

**Never with a new check.** Each skill puts in it whatever state it establishes
on entry anyway:

| Skill | Standing holds |
| --- | --- |
| `[[skills/implement]]` | the position marker against `HEAD` and the working tree |
| `[[skills/review]]` | the pinned merge-base, and that the subject is non-empty |
| `[[skills/commit]]` | that the stages ran — position, tests, review outcomes |
| a skill that reads no repository state | *nothing to verify*, said plainly |

*Why the slot is fixed but its content is not: making every skill read the
position would buy uniformity with a behavioural change nobody asked for, and
most skills have no position to read.*

## The closing block

Three slots, in this order:

| Slot | States |
| --- | --- |
| **State** | where the work now stands |
| **Next** | the near next step, as a suggestion |
| **Unsettled** | what should be settled before continuing, and how to settle each |

**It is a lantern, not a map.** The near objects only — the step after this one,
not the route to the end.

**A turn that stops early closes with the same three slots.** An empty frontier,
a refused permission, a request that routes elsewhere, a conflict surfaced rather
than resolved: each ends the turn, and each is where `Unsettled` is worth the
most.

*Why: a run that stopped because something is unsettled, and then closed
silently, has failed at the one thing the block exists for.*

## Two forms, and the form belongs to the skill

**Every skill declares `report: full | short`.** The declaration is made once,
when the skill is authored, by one test:

> Does this skill write to the repository, dispatch a sub-agent, or decide on the
> human's behalf?

Yes to any of them is `full`. **The form is never selected during a run**, so the
human knows which shape they will get before it starts.

| Form | Difference |
| --- | --- |
| **full** | `Stages` lists every stage, and each is marked as it is crossed |
| **short** | `Stages` names one stage, and no stage markers are emitted |

Both forms carry all four opening slots and all three closing ones. **Short is
not a shorter list of slots** — the difference is the markers, because the
preamble is paid once per turn and a marker is paid per stage.

### Stage names come from the skill's own procedure

They are read off the steps the skill already declares, and **never declared a
second time**. A stage in the run that the opening report did not name is a
defect in one of the two.

*Why: a separate list of stages is a second statement of what the procedure
already says, and the two diverge on the first edit to either.*

## What this policy is not

- **Not a rendering.** It governs what is stated, in what order, and how it
  reads. How a runtime paints it is the runtime's business, and this policy names
  no runtime.
- **Not the sub-agent contract.** What a child returns to its orchestrator —
  done, failed, stopped, waiting — is `[[policies/execution]]`'s, is not
  human-facing, and is untouched here. The question a child records for a human
  is the exception, and that policy says how it reaches one.
- **Not a register.** Whether the agent is terse or warm is its own business.
  This governs the tells, not the manner.
- **Not a cap on output.** Findings, graphs, diffs, and reports a skill produces
  are its output. They sit between the opening report and the closing block, and
  nothing here shortens them.
