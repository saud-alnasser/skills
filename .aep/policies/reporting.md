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

A skill entered from inside another — `[[skills/review]]` from
`[[skills/implement]]`'s close-out, `[[skills/tdd]]`, `[[skills/domain]]`,
and `[[skills/prose]]` as sub-skills — is a **stage of the run it is inside**. It
opens no report of its own. Everything it produces is unaffected; only the
preamble is not repeated.

*Why: one request can enter four skills, and four preambles for one request is
ceremony — and ceremony is skipped, which makes this policy advisory in fact.*

## The turn report

**Four slots, one line each**, and a ledger between them:

| Slot | States |
| --- | --- |
| **Position** | the state this skill establishes on entry, verified |
| **Assuming** | what is being proceeded on without verification |
| **State** | where the work now stands |
| **Next** | the near next step, and what would clear a stop |

The first two open the turn and the last two close it, with everything the run
produced in between:

```
Position   ...
Assuming   ...

  the work: findings, diffs, graphs, whatever the skill produces
  the ledger

State      ...
Next       ...
```

**One line each is the whole constraint.** A slot that will not fit in a line is
a slot carrying the work rather than framing it, and the work goes between them
where nothing shortens it.

*Why four and not seven: a run over a whole effort emits this once and a ledger
line per ticket, so every line spent on the frame is paid against the thing the
human is actually reading. Three of the old slots restated what the ledger and
the skill's own output already said.*

**A slot with nothing to put in it says so.** It is never dropped, and the report
is never three slots long.

*Why: silence is indistinguishable from a check that never ran, and a slot that
may be omitted is where uniformity leaks away, because the human stops reading by
position and starts reading by label.*

### `Position` is filled with what the skill already verifies

**Never with a new check.** Each skill puts in it whatever state it establishes
on entry anyway:

| Skill | Position holds |
| --- | --- |
| `[[skills/implement]]` | the position marker against `HEAD` and the working tree |
| `[[skills/review]]` | the pinned merge-base, and that the subject is non-empty |
| a skill that reads no repository state | *nothing to verify*, said plainly |

*Why the slot is fixed but its content is not: making every skill read the
position would buy uniformity with a behavioural change nobody asked for, and
most skills have no position to read.*

### `Next` carries what would clear a stop

**A turn that stops early closes with the same four slots**, and names in `Next`
what would clear it. An empty frontier, a refused permission, a request that
routes elsewhere, a conflict surfaced rather than resolved: each ends the turn,
and each is a stop the reader can act on only if it says what to do.

*Why in `Next` rather than a slot of its own: a stop with nothing to act on is
the failure, and putting the remedy anywhere but the slot the reader looks at for
what happens next is how it gets missed.*

## The ledger

**One line per unit of work, marked as it is crossed.** Each carries the unit,
how many of its acceptance criteria are verified, and the commit it landed as:

```
[x] 04 modes-folded        4/4   4b207bf
[x] 05 skills-cut          6/6   9c1e2aa
[ ] 10 runner-loop         0/7
```

A run that crosses one unit emits one line. A run that crosses ten emits ten, and
still four slots.

### It is written for two readers at once

The human reads it as progress. **The run that wrote it re-reads its own lines to
recover where it is**, which is what lets a long run survive a session boundary
without a separate record of state.

So it is governed twice over, and both at the same time: it reads as a person
wrote it, **and** its labels, columns, and order are stable enough to be parsed
by the run that emitted them. Where the two pull against each other, stability
wins on the structure and the prose wins inside a cell.

**This is the one narrowing of the exemption above.** Text a protocol agent reads
is otherwise exempt from how governed text reads, because it is written for that
reader instead. The ledger has two readers, so it forfeits the exemption without
losing the stability the machine reader needs.

*Why not two artifacts: a ledger for the human and a state file for the run
disagree the moment one is written and the other is not, and the disagreement is
invisible until a resumed run acts on the stale one.*

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
