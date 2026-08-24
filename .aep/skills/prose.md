---
use-when: "about to emit text a human will read, or editing text that reads as though nobody wrote it"
---

# /prose — make it read as though a person wrote it

A sub-skill. Reached from inside whichever skill is emitting text a human will
read, and reached that way it is **a stage of that turn**, opening no report of
its own (`[[policies/reporting]]`). Invoked directly on a file, it is the turn's
outermost skill and reports like any other.

**What is governed, and what the four prohibitions are, is
`[[policies/reporting]]`'s.** This file is the craft: the patterns that mark
writing as machine-made, how to spot each one, and what to do about it.

## Procedure

1. **Scan for the patterns below.** Work the groups in order. Content tells are
   the expensive ones because they survive a rewrite of the sentence they live
   in.
2. **Rewrite, preserving meaning.** Match the tone the text was aiming at. A pass
   that flattens an argument into neutrality has traded one failure for another.
3. **Give it a voice.** Removing patterns is half the job, and sterile is as
   obvious as slop. React to what you found instead of listing it. Vary the
   rhythm: short sentences, then ones that take their time. Say the awkward half
   of a finding, not only the clean half. Use *I* where it fits. Let the
   structure be slightly uneven, because perfect structure looks machine-made.
4. **Audit what is left.** Ask the one question that finds the rest: *what about
   this still reads as generated?* Fix what the answer names. Then check the
   prohibitions the policy fixes, because they are the four that a script will
   catch if you do not.

## The catalogue

### Content

**Puffery.** *Pivotal moment*, *testament to*, *evolving landscape*, *setting the
stage for*, *deeply rooted*. Cut it and state what happened.

**Superficial participles.** *Highlighting…*, *ensuring…*, *reflecting…*,
*showcasing…*, *fostering…* tacked onto a clause. Delete, or replace with the
thing that actually follows.

**Promotional adjectives.** *Vibrant*, *breathtaking*, *groundbreaking*,
*renowned*, *stunning*, *seamless*. Describe neutrally.

**Vague attribution.** *Experts believe*, *industry reports suggest*, *some argue*.
Name the source or cut the claim.

**Sources listed without contribution.** Four links, five file paths, or three
issue numbers in a row, with nothing saying what any of them established. Pick
the one that carried the point and say what it said.

**The formulaic concession.** *Despite challenges, X continues to thrive.* Replace
with the specific fact the sentence was standing in for.

### Language

**Model vocabulary.** *Additionally*, *crucial*, *delve*, *enhance*, *garner*,
*interplay*, *intricate*, *pivotal*, *showcase*, *underscore*, *tapestry*,
*testament*. Use the plain word.

**Elaborate ways to say *is*.** *Serves as*, *stands as*, *boasts*, *features*.
Say *is* or *has*.

**Not just X, but Y.** State the point directly.

**The rule of three.** Ideas forced into groups of three when the natural number
was two or five. Use the number the material has.

**Synonym cycling.** *Protagonist*, *main character*, *central figure*, *hero* in
one paragraph. Pick one and repeat it. Repetition reads as deliberate; rotation
reads as a thesaurus.

**False ranges.** *From X to Y* where X and Y are not ends of any scale. List the
things.

### Style

**Colons as connectors.** A colon before a list or an example is fine. A colon
propping up a mid-sentence comparison adds nothing: rewrite so the point stands
without the framing.

**Boldface on every proper noun.** Bold carries emphasis only while it is rare.

**Inline-header lists.** The tell is a bold label and colon that restates the
line it introduces, as in **Performance:** *performance improved*. Turn those
into prose. A bold lead-in that ends in a period, names the thing, and is
followed by genuinely new detail is not this.

### Communication artifacts

**Assistant phrases.** *I hope this helps*, *let me know if*, *of course*,
*certainly*, *found the smoking gun*. Cut them.

**Knowledge disclaimers.** *While specific details are limited…* Find the source
or drop the sentence.

**Sycophancy.** *Great question*, *you are absolutely right*. Answer the thing.

### Filler

**Filler phrases.** *In order to* becomes *to*. *Due to the fact that* becomes
*because*. *It is important to note that* gets deleted whole.

**Stacked hedges.** *Could potentially possibly be argued that it might* becomes
*may*. One hedge is a claim about confidence; four are a refusal to make one.

**Generic conclusions.** *The future looks bright.* State the plan or the fact.

### Jargon

**Abstract metaphor nouns, used more than the subject needs.** *Substrate*,
*wedge*, *vector*, *locus*, *nexus*, *bedrock*, *scaffolding*, *modality*,
*paradigm*, *flywheel*, *north star*, *ratchet*, *endgame*, *evacuate* for moving
code. Each usually has a plainer word: *substrate* is a *base*, *vector* is a
*way*, *ratchet* is *a limit that only tightens*, *evacuate* is *move out*. Prefer
the concrete word and keep the count low.

**But a word the domain defines is the domain's word.** Where a repository has
defined a term, that term is correct here however abstract it sounds, and
replacing it invents a translation layer everyone pays for
(`[[skills/domain]]`). Check what the domain defines before flagging a word as
jargon.

### Plain speech

**Say what it does, not how it feels.** *The database stays close at hand*, *SQL
you can read*, *types that follow your schema* all name a feeling. The fix names
a mechanism or a number: *`.toSQL()` returns the exact string sent to the
database*, *a column rename fails the build*. If you cannot restate a sentence as
an instruction, a fact, or a number, cut it. One more check: a sentence that
could appear unchanged in another project's documentation says nothing about this
one.

**One idea per sentence.** If the reader has to backtrack to parse it, split it
or drop a clause.

**Active voice, with the actor named.** *Queries are validated* becomes *the
compiler validates queries*. *The file is parsed by the loader* becomes *the
loader parses the file*. Passive is fine only where the actor is unknown or
genuinely does not matter.

**Adverbs propping up weak verbs.** *Runs quickly* becomes *is fast*, or the
number. *Significantly improves* becomes the measured delta. An adverb holding a
verb up means the verb is wrong.

**The plain word beats the formal one.** *Utilize* becomes *use*. *Leverage*
becomes *use*. *Facilitate* becomes *help*. *Numerous* becomes *many*. *In the
event that* becomes *if*.

## Repairing the four the policy prohibits

The rules are `[[policies/reporting]]`'s. The technique is here, because knowing
a dash is forbidden does not tell you what the sentence becomes.

| Tell | The repair |
| --- | --- |
| a clause set off by a long dash | end the sentence, or use a comma. Reaching for parentheses instead moves the tell rather than removing it |
| curly quotation marks | straight ones, usually an artifact of pasting rather than a choice |
| an emoji in a heading or beside a list item | delete it. Nothing replaces it |
| a heading in title case | sentence case, capitalising only what a sentence would |

## Constraints

- **Preserve the argument.** This pass changes how a text reads, never what it
  claims. A rewritten sentence that hedges something the original asserted has
  introduced an error.
- **Do not sand it flat.** Voiceless prose is a tell of its own, and the audit
  step exists because a scrubbed text and a written one are easy to confuse.
- **Do not apply this to text an agent reads.** A brief, a protocol artifact, and
  data written for a later run are exempt, and rewriting them for a reader they
  do not have spends effort to lose precision.

## Done when

Nothing in the text answers *what makes this read as generated?*, the argument it
carried is intact, and the four the policy prohibits are absent.
