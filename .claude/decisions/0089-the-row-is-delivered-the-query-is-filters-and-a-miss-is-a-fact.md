---
owner: repository
status: accepted
load-when: how a stage receives its guides, or how the store is queried, is in question
sources: [.claude/tickets/substrate/issues/04-how-a-stage-gets-its-set-without-judged-selection.md, .claude/evidence/research/2026-08-13-what-a-plugin-hosted-tool-can-actually-do.md, .claude/evidence/prototypes/2026-08-14-does-a-fires-when-filtered-row-deliver-what-implement-needs.md, .claude/evidence/prototypes/2026-08-14-does-backtick-bang-preprocessing-actually-deliver.md, .claude/evidence/prototypes/2026-08-14-what-reaches-a-stage-when-a-preprocessing-command-fails.md, .claude/evidence/prototypes/2026-08-14-whether-a-stage-row-fits-through-preprocessing.md, .claude/evidence/prototypes/2026-08-14-whether-chunked-substitution-carries-a-row.md, .claude/evidence/prototypes/2026-08-14-what-the-chunking-constraint-costs-at-chunk-count.md]
supersedes: []
superseded-by: []
falsified-by: [.claude/evidence/drift/2026-08-15-adr-0089-s-measured-saving-needs-a-per-span-label-the-format-does-not-carry.md, .claude/evidence/research/2026-08-15-what-the-reference-settles-about-preprocessing-suppression-the-inline-ceiling-and-hook-context.md]
---

# The row is delivered, the query is filters, and a miss is a fact

**A stage's row is delivered, never queried, and the row is a filter rather than
a list of files.** `` !`command` `` preprocessing assembles it and inlines it
before the skill content reaches the model — zero model round trips and no
judgement, leaving ADR 0075 untouched. **That sentence is now measured rather than
read**: the substitution arrives in position, before the content, executed at the
moment the stage is invoked, under `/usr/bin/bash` — so an assembler written as
`.ps1` is invoked as `pwsh -NoProfile -File …` and the interpreter is a stated
constraint rather than an assumption. The row is *every norm whose `fires-when`
matches this stage*, assembled from the norm records ADR 0085 made addressable,
so a norm that fires for one stage never reaches another even when the two live
in the same file.

**The zero-round-trip claim is confirmed at row scale, and it arrives with a
constraint on how the row is emitted.** Rounds 1 and 2 measured the mechanism on
payloads of about 60 bytes; round 3 put a whole row through it as **one**
substitution and it was withheld — replaced by a `persisted-output` wrapper
naming the size, a 2 KB preview, and a path, the same presentation ADR 0088's CLI
face meets on tool results. Round 4 then measured the question round 3 left:
**the cap is per substitution, not per assembled body.** Five commands of about
9,000 characters carried 45,180, a synthetic payload sized to the filtered row,
and eight carried 72,288 — past the unfiltered row's 69,563 — every chunk arriving
whole and inline, with no wrapper, no preview, and no path anywhere in the body.
The payloads stand in for rows rather than being them, which is what lets the
larger of the two exceed what it models. So the mechanism delivers
what this decision says it delivers, and **the assembler emits the row as several
commands, each under the cap, never as one** — a stated constraint beside the
`pwsh -NoProfile -File …` one above.

**The constraint binds at about 20,000 characters per command**, and that is now
the size proven in combination rather than a goal held at arm's length. Round 4
recorded ~20,000 as a **goal rather than a rule** on the express ground that
20,036 was proven only as a *single* substitution; round 6 put **four
substitutions of 20,057 characters — 80,228 total — through one body**, every
chunk whole and inline with no wrapper anywhere, so that ground is gone. The cap
itself is bracketed at (20,036, 30,036] characters and is still not pinned, which
is why the emitted size sits at ~20,000 rather than higher.

**The constraint's own cost is measured, and it is seconds.** The overhead is
**per command, not per byte**: a 20,057-character substitution and a 9,057-character
one each cost ~23 ms in-command, and each chunk boundary costs **~1.6–1.75
seconds** whatever the chunk carries. So an eight-chunk row costs ~12.4 s and a
four-chunk row ~4.9 s, and `/implement`'s unfiltered 69,563-character row fits in
**four** chunks. Round 5 measured an eight-chunk body at 112,499 ms and read the
cost as ~1.9 minutes at every stage entry; **round 6 re-ran that probe unchanged
and got 12,449 ms — nine times faster — so the minute figure is an unreproduced
outlier and is not what this decision carries.** The delivery half is not in
question on cost: it lands on the seconds side of the threshold the question was
framed around.

**One consequence reaches the filter.** Chunking carries the *unfiltered* row, so
`fires-when` is not what makes a row fit — it buys tokens and nothing else. Round
3's arithmetic, that reaching the proven-safe floor needed a 77.9% cut of the
filtered row against the 34.7% the filter buys, described a constraint that no
longer exists. Any argument for the filter resting on delivery is withdrawn; the
token argument below is untouched.

**The filter, not the delivery, is what meets the token goal.** Round trips are
not tokens: an earlier draft of this decision assembled the same file list and
claimed a context saving it did not produce. **The saving is now measured on the
whole row rather than estimated on one file.** `/implement`'s row is 69,563
characters over 69 spans, of which **only 48.5% is labelled for the stage that
loads it**; filtering drops **34.7%**, or 24.4% if six genuinely ambiguous spans
are kept. The earlier 34%-of-`tickets.md` estimate survives as the generous
reading of that file (37.9%, against 70.0% strict). **The query serves
only what the row deliberately excludes**: path-scoped norms on a covered file,
cross-store norms cited by id, and the mid-turn lookup for a question the row does
not settle. Disjoint jobs, so neither path can quietly substitute for the other.

**The filter is a token mechanism, and the accuracy claim did not survive
measurement.** It has been argued here and in the composite as an accuracy saving
too, on the ground that F6 makes coherent topically-adjacent prose the worst
distractor class. Measured, norm-shaped imperatives fall only **168 to 122 —
27.4%, against 34.7% of characters** — because what the filter removes is
disproportionately the one-line *why* clauses ADR 0074 requires rather than the
imperatives themselves. The filtered row stays inside the 100–115 band
`substrate/13` was opened about. The token claim stands; **the compliance claim is
withdrawn**, and `13` is the live question rather than a refinement of this one.

**Two parts of a row lie outside the mechanism entirely, 23.2% of this one.**
`.claude/contexts/repository.md` is Context rather than norms, so a norm filter
cannot reach it — 14.7% of the row, including a single 7,675-character span. And
four `.claude/tools/git.md` sections describe reads the position script performs,
existing for a reader without it: a norm that fires only in a degraded mode, which
is ADR 0088's second face and is recorded there rather than admitted as a new
`fires-when` axis.

**There is no search, only filters over declared fields** — `type`, `fires-when`,
`id`, and a declared subject vocabulary. This is the decision the rest rests on: it
makes a miss **a true statement about the store rather than a failed search**, so a
caller never has to distinguish *nothing governs this* from *my query was wrong* —
a distinction invisible at the call site, and the one that would let a stage decide
something the store already settled. Completeness is asserted rather than trusted:
the suite round-trips every norm through at least one filter.

**Conflicts are returned, never resolved.** ADR 0086 made a decision-versus-norm
conflict productive — the norm is amended in the same change — so applying the
computed rank and returning one record would suppress that obligation. The tool
returns both with their ranks and labels the conflict kind: a declared deviation
across stores, an undeclared defect within one.

Four costs are accepted. The field vocabulary becomes load-bearing, so a caller
who does not know the right value gets an honest empty answer to the wrong
question. `disableSkillShellExecution: true` disables preprocessing wholesale, so
row assembly can be switched off by a setting AEP does not control. **The
assembler's failure mode is a fork with no safe branch**, measured: left
unguarded, any non-zero exit aborts the whole skill and the stage receives
nothing at all — not the row, not its own instructions — which is loud but takes
the stage offline; guarded, the row arrives with the shell's error text inlined
as prose in position, stderr included whether or not it is redirected and the
exit code not delivered, which keeps the stage alive and makes the row silently
wrong. Nothing on this path degrades gracefully, and the choice belongs in the
assembler's own design rather than here. And
**`fires-when` becomes a silent-failure surface**: a norm labelled for the wrong
stage simply stops arriving, with nothing to report it. The suite can assert the
field is present and drawn from the declared vocabulary; it cannot assert the
value is right, which puts this in the same class as ADR 0085's *smallest correct
span* — an authoring judgement no mechanism checks. A file's preamble is itself a
record and declares its own `fires-when`, so orientation needed by several stages
is delivered to each rather than inherited implicitly.

## Considered Options

- **The query replaces the row** — rejected: judged selection restored in full,
  which ADR 0075 removed because mis-loads caused settled questions to be re-asked.
- **No retrieval at all, delivery only** — the smallest system, rejected because a
  path-scoped pointer has no preprocessing available and ADR 0088 would reopen.
- **Report the searched scope and require the stage to say a miss aloud** —
  rejected: a guard the model must obey rather than a mechanism, and the recorded
  discussion on cost asymmetry says that shape fails exactly when context is tight.
- **A miss stops the stage** — rejected: most misses are genuinely *nothing governs
  this*, so the common path would become a halt.
