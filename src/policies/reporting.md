---
use-when: "about to write anything a human will read: session output, a commit message, a pull request, a code comment, a README; or a turn's report does not take the shape it should"
---

# Policy — what the human reads

## Who reads it decides

**A human reads it: governed. A protocol agent reads it: exempt**, which means
written for that reader, never carelessly. A case on neither list is settled by
asking who reads it.

| Governed | Exempt |
| --- | --- |
| session output, at every point in a turn | prose inside `.aep/` artifacts |
| a commit message, a pull request title or body | normative protocol text, wherever it lives, even at a repository root |
| a comment or docstring in source | a brief written for a sub-agent |
| what a script prints to a person | data a script writes into an artifact an agent reads |
| repository documentation: a README, a changelog, a docs page | |

## How it reads

Write for the person reading it: say what happened, name the mechanism rather
than the feeling, and cut what would read the same in any other repository. The
four prohibitions are in the protocol. Load `[[skills/prose]]` only when writing
a README, a pull request body, a changelog, or docs, or when text you are
editing reads as though nobody wrote it.

## The turn report

**One request, one report**, emitted once, at the end of the turn, by the
outermost skill. A skill entered from inside another (`[[skills/review]]` at
the close, `[[skills/tdd]]`, `[[skills/domain]]`, `[[skills/prose]]`) is a
stage of that run and reports nothing of its own. The shape does not vary by
skill, runtime, or size.

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
  | `[[skills/specify]]` | the claim, isolation, and marker of the surface it was invoked in |
  | `[[skills/prune]]` | the claim, isolation, marker, and what the validator printed |
  | `[[skills/survey]]` | the claim, isolation, marker, and the bound the survey took |
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
enough to parse; inside a cell, it reads as a person wrote it.

## Not covered here

How a runtime renders the report; what a child returns to its orchestrator
(`[[policies/execution]]`); the agent's register; and how much output a skill
produces.
