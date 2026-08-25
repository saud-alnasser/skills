---
status: resolved
blocked-by: [12]
---

# fix(protocol): the narrowed ticking rule reaches every file that states it

## Outcome

Two shipped files still say a criterion is ticked only by
`[[agents/reviewer-correctness]]`, which ticket 12 made false. They are corrected
to match `[[policies/execution]]`, so the protocol states one ticking rule rather
than three that disagree.

## Where this came from

Raised by ticket 12's builder, which found both while working and correctly
declined to fix either: neither file was in its relevant areas, and no ticket in
this effort named them. Appended rather than absorbed, because a ticket that
quietly widens its own scope hides the widening somewhere nobody reviews it.

It is the same defect criterion 13 exists to catch, one and two files over: two
rules that disagree are worse than the weaker one alone.

## Acceptance Criteria

- [x] Criterion 13 extended: the sweep walks every `.md` under `src/`, flattens
      each file, and tests four **named** shapes, so a failure says which claim it
      found rather than that something matched. The builder added it **before**
      correcting the prose, so its first red was the real defect naming both real
      files, not a simulation. Independently re-checked at integration by planting
      a named shape, wrapped mid-phrase, in a file the sweep was never written
      against: `the exclusive ticking rule survives in skills/survey.md (the
      orchestrator is written out of ticking)`.
- [x] The heading is now `## You tick what you verify`, and the body keeps the
      tick discipline: at the moment it is verified, carrying inline what verified
      it, never for code you wrote. A new paragraph names the orchestrator's tick
      and closes with `What is yours is what you verified.`
- [x] The resuming section reads that a tick was made by whoever verified that
      criterion and never by the agent that wrote the code, since a dispatched
      child never ticks its own. That names the surviving carrier of the
      resumption guarantee instead of dropping it.

**Recorded, not acted on: what this sweep does not catch.** It matches four
declared shapes, not the claim's meaning. I planted a paraphrase outside all four,
"ticked by the correctness reviewer and by nobody else", and it passed. That is
inherent to a regex sweep over prose rather than a defect in this one, and the
named-shape design is what makes the limit visible instead of hidden. Worth
knowing before anyone treats a green sweep as proof the claim is absent.

**One existing assertion changed, and the builder said why.** `the correctness
reviewer keeps its own tick discipline` pinned the literal exclusive heading, so
keeping it passing and satisfying this criterion were mutually exclusive. Only the
clause pinning exclusivity moved; the two clauses pinning the discipline stayed.
What the removed clause protected is now covered by a stronger pair, the tree-wide
sweep and an assertion that fails if the file merely goes quiet about the
orchestrator rather than naming its tick.

## Relevant areas

- `src/agents/reviewer-correctness.md`, the heading `## You tick the criteria,
  and only you` and the paragraphs under it.
- `src/skills/implement.md`, in `## Resuming after losing context`: "A tick was
  made by `[[agents/reviewer-correctness]]` and never by the agent that wrote the
  code, which is what makes it safe to resume on."
- `src/scripts/verify.mjs`.

## Constraints

- **The resumption guarantee survives, restated.** What makes a tick safe to
  resume on is that its author did not write the code it judges, and that is
  still true under the narrowed rule for a dispatched child. The orchestrator
  ticking what it verified is the case that changed. Do not delete the
  guarantee; say which claim now carries it.
- **`reviewer-correctness` still ticks when it runs.** The effort review ticks
  what it judges. What is false is only "and only you". Narrow the claim; do not
  remove the reviewer's tick discipline.
- The existing assertion `the correctness reviewer keeps its own tick discipline`
  is watching that file. Keep it passing, or say why it had to change.
- Shipped text may not cite `specs.md` ([[rules/authoring]]).
- No em dash in shipped text.
- **Seen to fail first.** Note the trap this effort hit three times: a red result
  proves nothing until you confirm the perturbation removed only what you meant,
  and a check can be wrong in the same way its subject is.

## Notes

Ticket 09 is blocked on this. The baseline re-cut has to come after every content
change, or it stamps a tree that is about to move again.
