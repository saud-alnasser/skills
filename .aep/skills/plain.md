---
use-when: "writing session text, a commit message, a pull request, a brief, a return, or an effort artifact; drawing a sketch or putting an option set to the developer; or checking that text reads as the controlled register"
---

# /plain — say it so it reads in one pass

The craft of the controlled register. The law is `[[policies/reporting]]`'s:
which texts take this register, the order of the three steps, the sketch rule,
and the option-set rule. The four prohibitions are `[[protocol]]`'s. This file
is how to do it well, with worked examples. Reached from inside another skill it
is **a stage of that turn**, with no report of its own; invoked on a text, it
reports like any other.

The register is based on ASD-STE100, Simplified Technical English, which ASD
publishes and gives away free. AEP ships none of it: no rule text and no word
list. Read the standard from ASD for the approved vocabulary.

**Posture.** Clarity over voice. The developer reads session text mid-task,
often in a second language, and needs the fact, the decision, and the next step
on the first read. **What this gives up** is voice: the text reads flat, and no
rhythm or style carries the reader. Public text keeps its voice in
`[[skills/prose]]`, and that is where voice belongs.

## Procedure

1. **Sort the sentences.** Find the actor and the action in each. A sentence
   with two actions becomes two sentences.
2. **Apply the policy's three steps to each sentence**
   (`[[policies/reporting]]`). The sections below show each step at work.
3. **Draw what has shape.** Put the sketch below the sentence that needs it.
4. **Read it once, as the developer.** Ask: *what would I have to read twice?*
   Fix what the answer names.

## Sentences

| Draft | Controlled |
| --- | --- |
| The marker was found to be stale and was re-stamped. | The marker was stale. I stamped it again. |
| Ticket 03 is blocked, and its edits overlap 02, so it waits and then the orchestrator merges both. | Ticket 03 waits for 02. Both tickets edit one file. The orchestrator merges them in order. |
| It should be noted that the push may possibly fail. | The push can fail. |

In the first row the actor was hidden, so the fix names it. In the second row
one sentence carried three topics, so the fix splits it. The third row had
filler and two hedges, so the fix removes them.

## Words

**A swap that loses nothing.** *Prior to* becomes *before*. *Ensure* becomes
*make sure*. *Commence* becomes *start*. Each approved word carries the whole
meaning.

**A word kept because no approved word carries it.** *The index is stale.* The
plain swaps are *old* and *not current*. *Old* loses the cause: the index was
correct once, and the source moved after it was written. *Not current* loses the
point that the old content is now wrong. So *stale* stays.

**A technical name, kept exactly.** *Another surface holds the claim.* An
approved-word pass turns this into *another area holds the right*, and the
developer can no longer look either word up. *Claim* and *surface* are AEP
terms. A repository's domain words work the same way: where its domain defines
*tenant*, write *tenant*, never *customer*.

## Sketches

Draw with box-drawing characters. Use rounded corners, an arrow with a label on
it, and space between the parts, as a whiteboard sketch would. Put the sketch
directly below the sentence it supports, and keep the sentence true without it.

**A flow:**

```
  ╭──────────╮   lands   ╭──────────╮   all landed   ╭──────────╮
  │  build   │ ────────▶ │ converge │ ─────────────▶ │  review  │
  ╰──────────╯           ╰────┬─────╯                ╰──────────╯
        ▲                     │ gap found
        ╰─────────────────────╯
```

**A before-and-after:**

```
  before                          after
  ╭────────────────────╮          ╭────────────────────╮
  │ Governed | Exempt  │   ──▶    │ public             │
  │ (two outcomes)     │          │ controlled         │
  ╰────────────────────╯          │ exempt             │
                                  ╰────────────────────╯
```

A sketch that grows past the policy's limit usually has two subjects. Draw each
one, and give each its own sentence.

## Option sets

Write each option as a label of a few words, then one or two sentences that say
what happens if it is chosen and what it costs. Give the reason for the
recommendation in one sentence. Where the options differ in structure, draw
each one with the same frame, so the difference is the only thing that changes.

**In a picker.** Put the mark in the recommended option's label, the
explanation in each option's description, and the sketch in its preview where
the picker has one.

**As text:**

```
Where does the controlled register's craft live?

a. A sub-skill (recommended). The policy keeps the law. plain.md keeps the
   examples and loads only when a turn needs them.
   Cost: a second file to keep in step with the policy.
   Recommended: the hot path carries the core and nothing more.

     policy ──law──▶ every turn        plain ──craft──▶ on demand

b. One file. The policy holds the law and the examples.
   Cost: every turn pays for the examples.

     policy ──law + craft──▶ every turn

Answer with a letter.
```

## Briefs and returns

A brief is the only channel from parent to child, so a sentence the child can
read two ways is a defect nobody can fix later.

**A brief:**

```
Build ticket 04 in the surface you were given. Do not commit.
Change dispatch.md, parallel.md, and the four agent files.
Stop and return if a criterion contradicts the spec.
Return: done, failed, stopped, or waiting; the path to your change record;
and a summary of at most 150 words.
```

**A return:**

```
done. Change record: .aep/efforts/60-session-register/evidence/04.md.
I added the register link to six files. Each assertion failed once with its
subject removed. Criterion 3 is unverified: the suite does not reach agents/.
```

## A turn report

The slots are the policy's. Only the words inside them change:

| Slot | Draft | Controlled |
| --- | --- | --- |
| `Done` | Successfully landed the first ticket, laying the groundwork for the wave. | Landed 01 as 46f2985. |
| `Stopped on` | Ran into a snag with the push. | The force push was refused. |
| `Next` | Continue with the remaining work. | Build 02 to 05, then 06 and 07. |

## Constraints

- **Govern nothing.** Every rule for this register is in
  `[[policies/reporting]]`. Where this file and the policy disagree, the policy
  is correct and this file is the bug.
- **Ship nothing from ASD-STE100.** Name it as the source. Quote no rule and
  list no vocabulary beyond the few words a worked example needs.
- **Obey the policy in every example.** A worked example that breaks the rule it
  shows teaches the break.
- **Leave public text to `[[skills/prose]]`.** A README written in this register
  reads as a form.

## Done when

The developer can act on the text after one read, every technical name is
intact, and nothing the text had to carry was lost.
