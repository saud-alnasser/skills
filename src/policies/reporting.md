---
use-when: "about to write anything a person or another agent will read: session output, an option set, a brief, a commit message, a pull request, a code comment, a README; or a turn's report does not take the shape it should"
---

# Policy — registers and the report

## Who reads it decides

**The reader picks the register.** Exempt means written for that reader, never
carelessly. A case on no row is settled by asking who reads it.

| Reader | Register | Worked cases |
| --- | --- | --- |
| a person reading cold, outside the session | public | a README, a docs page, an API reference, user-interface text, a changelog, a code comment, a docstring |
| the developer, in a session or in review | controlled | session output, the turn report, an option set, a commit message, a pull request title or body |
| another agent, or a reviewer of an effort | controlled | a brief, a child's return, a relayed question; a new spec, plan, ticket, evidence file, or `log.md` cell |
| an agent, through shipped protocol text | exempt | protocol text, wherever it lives; data a script writes for an agent |

Public text takes the craft in `[[skills/prose]]`. The four prohibitions are in
the protocol, and hold in both registers a human reads.

## How controlled text reads

Its craft is in `[[skills/plain]]`. Three steps, in order, per
sentence:

1. **The core principles.** One topic per sentence. Active voice, the actor
   named. Twenty words for an instruction and 25 for a description, as a
   target. One meaning per word.
2. **The vocabulary.** An ASD-STE100 approved word first; an outside word where
   it carries the meaning better.
3. **The test.** Direct, easy to read, and no knowledge lost.

This is 80% adherence. The 20% leaves the strict standard where it would cost
readability or knowledge, and **never drops a core principle**. A reviewer
judges by step 3.

**A domain term is a technical name**: a term this repository's domain or AEP
defines is kept exactly and never counted against adherence.

## Sketches and option sets

**Structure shown to the developer is drawn**: a flow, a hierarchy, a sequence
of states, a before-and-after, or a comparison. The sketch is characters in a
fenced block, in Excalidraw style, within a few hundred tokens. A larger
structure is split.

**An option set is explained, illustrated, and recommended**: each option
explained, illustrated where options differ in structure, one marked
recommended with its reason. It goes through the runtime's option picker where
there is one, else as text: a letter per option, then a line asking for a
letter. The options, their words, and their order are the same either way.

## The turn report

**One request, one report**, emitted once, at the end of the turn, by the
outermost skill. A skill entered from inside another (`[[skills/review]]` at
the close, `[[skills/tdd]]`, `[[skills/domain]]`, `[[skills/prose]]`,
`[[skills/plain]]`) is a stage of that run and reports nothing of its own. The
shape does not vary by skill, runtime, or size.

The work (findings, diffs, graphs, the ledger) comes first, uncut. Then nine
lines, one each, in this order:

```
Doing           what this turn was asked to do
Lane            quick | standard | full, or "none" outside an effort
Position        the `summary` aep printed, or what the skill verified on entry
Assuming        what was proceeded on unverified
Done            what changed, with commits
Stopped on      the stop and its reason, or "nothing"
Needs you       the human's decisions, or "nothing"
Outside writes  "none", or each path outside the project and why
Next            the next step, and what would clear a stop
```

- **A slot with nothing to say says so.** It is never dropped.
- **One line each.** A slot that will not fit is carrying the work; the work goes
  above.
- **`Position` holds only what the skill already verifies**, never a new check,
  and no skill reads position just to fill it:

  | Skill | Position holds |
  | --- | --- |
  | `[[skills/implement]]`, `[[skills/tasks]]` | the `summary` `aep start` printed, and the marker's answer |
  | `[[skills/specify]]`, `[[skills/prune]]`, `[[skills/survey]]` | the claim, isolation, and marker of the surface invoked in; prune adds what the validator printed, survey the bound it took |
  | `[[skills/review]]` | the claim, isolation, pinned merge-base, and that the subject is non-empty |
  | `[[skills/install]]` | *nothing to verify*: this run writes the first marker |
  | a skill that reads no repository state | *nothing to verify* |
- **A stop names its remedy in `Next`**: an empty frontier, a refused
  permission, a request that routes elsewhere, a conflict surfaced rather than
  resolved.
- **`Needs you` is what `aep status` shows the human.** Record each item with
  `aep record <effort> --needs-you` as well as reporting it.

## The ledger

One line per unit of work, written by `aep land` into the effort's `log.md`
`## Ledger` as it is crossed. The report shows the same lines, in the same
order, with the commit beside each, read from git and never stored:

```
[x] 04 modes-folded   4/4   4b207bf
[ ] 10 runner-loop    0/7
```

A resumed run reads the log copy. Its labels, columns, and order stay stable
enough to parse; inside a cell, it takes the controlled register.

## Not covered here

How a runtime renders the report; the shape of a child's return
(`[[policies/execution]]`); how much output a skill produces.
