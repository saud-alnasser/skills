---
owner: repository
kind: prototypes
falsifies: []
---

# Does a `fires-when`-filtered row deliver everything `/implement` needs?

Built 2026-08-14 against `4c2b085`, PowerShell 7.6.3, git 2.55.0. Resolves item 6 of
`substrate/08`. The harness was throwaway and is gone; this is what it measured.

Verified against: `.claude/protocol.md` 1.20.0, `.claude/policies/tickets.md` 1.19.0,
`.claude/policies/context.md` 1.20.0, `.claude/policies/sub-agents.md` 1.19.0.
Conclusion: **Partially Successful** — the filter delivers a real token saving and does
not deliver the compliance benefit the composite bought it for.

## Hypothesis

Written before the run. ADR 0089 makes a stage's row a filter over norms rather than a
list of files. `substrate/08` predicted the saving as *"roughly a third of `tickets.md`
for `/implement`"*, and expected the dropped set to be small and unambiguous — every
member either correctly excluded or a mislabelling. The instruction-count question on
`13` assumed filtering would move the row's density materially, since ADR 0089's filter
was argued as an accuracy saving and not only a token one.

## Method

`/implement`'s row is ten files, read from `.claude/protocol.md`'s stage table: six
policies, `.claude/tools/git.md`, the forge reference, `.claude/contexts/repository.md`
(loaded by every stage), and `.claude/modes/implementation.md` (the mode column).

1. **Split into spans.** A markdown splitter cut each file at headings, the unit ADR 0085
   makes addressable. Frontmatter excluded, fenced code tracked so a template's example
   headings are not mistaken for records — that bug was in the first run and inflated the
   inventory from 69 spans to 81.
2. **Label each span by hand**, reading the source. Vocabulary per ADR 0084 — `always`,
   `path`, `stage:<x>`, `posture:<x>` — plus two labels the run had to invent, which is
   itself a result: `context` (not a norm, so no norm filter reaches it) and `reference`
   (a procedure a script performs). Genuinely ambiguous spans were labelled `contested`
   rather than forced, and the run reports both readings.
3. **Filter and diff** the result against the whole-file row, measured in spans,
   characters, and norm-shaped imperatives (lines opening in bold, ADR 0074's form).

Labelling is the weak joint and is deliberately visible: the dropped set is the finding,
and a wrong label is exactly the silent failure the ticket named.

### A mislabelling the run found by inspecting its own dropped set

The first pass labelled four `sub-agents.md` spans `role:child` — 4,295 characters — on
the reasoning that they bind the dispatched child rather than the dispatching stage, and
reported a gap in ADR 0084's closed vocabulary. **Walking the dropped set span by span
falsified it.** The parent needs all four: *A child arrives bound* stops it quoting
pointer material into a brief; *What a child may use* shapes what the brief may name;
*What is closed to it* is what stops the parent asking for a closed thing and tells it
who claims and commits; *What a child may ask for* is what the parent **performs**, and
the next span — *Carrying a question is not answering it*, always labelled for the
parent — is incoherent without it.

`fires-when` is a **delivery** condition; the first pass had labelled by **who a norm
binds**, which is a different question. No `role:` axis is needed and none is proposed.
All numbers below are the corrected ones, and the correction moved the headline saving by
six points — which is the measure of how much this experiment rests on its labelling.

## Result

The row measures **69 spans, 69,563 characters** — the ticket's "roughly 62 KB" is now
72,073 on disk, 69,563 of body text.

| `fires-when` | Spans | Chars | Share |
| --- | --- | --- | --- |
| `stage:implement` | 36 | 33,728 | 48.5% |
| `context` | 4 | 10,205 | 14.7% |
| `contested` | 6 | 7,143 | 10.3% |
| `reference` | 4 | 5,902 | 8.5% |
| `stage:design` | 9 | 5,702 | 8.2% |
| `stage:configure` | 1 | 1,893 | 2.7% |
| `always` | 3 | 1,512 | 2.2% |
| `stage:commit` | 3 | 1,504 | 2.2% |
| `stage:review` | 1 | 1,108 | 1.6% |
| `stage:triage` | 2 | 866 | 1.2% |

**Under half the row — 48.5% — is labelled for the stage that loads it.**

| Reading | Row | Dropped | Saving |
| --- | --- | --- | --- |
| strict — contested dropped | 45,445 chars (~11.4k tokens) | 24,118 | **34.7%** |
| generous — contested kept | 52,588 chars (~13.1k tokens) | 16,975 | **24.4%** |

Per file, strict:

| File | Total | Dropped | Saving |
| --- | --- | --- | --- |
| `tools/github.md` | 1,504 | 1,504 | **100.0%** |
| `policies/tickets.md` | 15,034 | 10,527 | **70.0%** |
| `tools/git.md` | 13,807 | 7,963 | 57.7% |
| `policies/context.md` | 6,401 | 1,893 | 29.6% |
| `policies/version-control.md` | 6,571 | 1,365 | 20.8% |
| `policies/tracker.md` | 4,328 | 866 | 20.0% |
| `contexts/repository.md` | 10,205 | 0 | 0.0% |
| `policies/sub-agents.md` | 9,365 | 0 | 0.0% |
| `policies/knowledge.md` | 1,992 | 0 | 0.0% |
| `modes/implementation.md` | 356 | 0 | 0.0% |

Five results, in the order they matter.

**1 — The filter does not get the row out of the density band. This is the finding.**
Norm-shaped imperatives fall from **168 to 122, 27.4% fewer** — against 34.7% of
characters. `substrate/13` records the current row at an estimated 100–115 simultaneous
instructions; the filtered row is **122**, which is not below the band it started in.
The filter cuts prose faster than it cuts instructions, because the prose it removes is
disproportionately the *why* clauses and examples rather than the imperatives themselves.
ADR 0089's filter was argued as an accuracy saving as well as a token one; on this row
**it is a token saving that leaves compliance where it found it**. For `13`'s open
question of whether the answer is a smaller row or a smaller corpus: on this row a
smaller row was measured and was not sufficient.

**2 — The ticket's estimate was measuring the labeller, not the filter.**
`tickets.md` drops **37.9%** if the six contested spans are kept and **70.0%** if they
are not. "Roughly a third" is exactly the generous reading of that one file. The entire
distance between the prediction and double it is the ambiguous set — so the estimate was
never a property of the filter.

**3 — 23.2% of the row carries text no norm filter can reach.**

- **`context`, 14.7%.** `contexts/repository.md` is Context, not norms. ADR 0089's filter
  is over norms, so it cannot touch this — and it is the second-largest file in the row,
  with a single 7,675-character `Language` span. The token goal has to account for a
  seventh of `/implement`'s row being outside the mechanism entirely.
- **`reference`, 8.5%.** `tools/git.md`'s four Marker sections. The file says so itself:
  *"The next three sections are one command, and a stage that opens with verification
  runs that rather than making their reads by hand."* The stage runs
  `report-position.ps1`; those spans exist for *"a reader without the script"*. This is
  the one genuine vocabulary gap — a norm that fires only in a degraded mode — and it is
  the same shape as ADR 0088's second face, so it should be named there rather than
  invented as a new axis.

**4 — The forge reference is 100% dead on this row, by this repository's own declared
facts.** `.claude/protocol.md` puts "the forge reference" on `/implement`'s row
generically. Here `tracker: local-markdown`, the GitHub remote is *"a code remote only"*
with issues *"enabled there and empty"*, and `/implement` never pushes or opens a pull
request. All three `github.md` spans drop. A row entry justified at framework level can
be entirely inert in a specific repository, and nothing today reports it.

**5 — Span granularity, not the filter, bounds the saving in three files.**
`knowledge.md` is 1,992 characters under one heading; `modes/implementation.md` is 356
under one; `repository.md :: Language` is 7,675 under one. A span-level filter is
all-or-nothing on these. Separately, `tickets.md` carried **two spans with the same
heading text** before the fence fix — independent confirmation of why ADR 0085 chose
opaque ids over heading-text identity.

### The dropped set, in full

The code is deleted; this is the part worth arguing with. Twenty-six spans, 24,118
characters, strict reading. Every row is either correctly excluded or a mislabelling —
one already was.

| `fires-when` | Span | File | Chars | Why it was labelled so |
| --- | --- | --- | --- | --- |
| `contested` | Edges | `policies/tickets.md` | 1,849 | declaring is design's; implement reads the frontier and defines it |
| `contested` | Declared fan-out | `policies/tickets.md` | 1,578 | declaration is design's, action is implement's own skill |
| `contested` | How work lands | `policies/version-control.md` | 1,365 | PR and squash-merge are the human's and `/commit`'s |
| `contested` | Bisect to the first bad commit | `tools/git.md` | 953 | `diagnosing-bugs` builds the harness; implement may run it |
| `contested` | Declared increments | `policies/tickets.md` | 878 | design-time only; what implement does "is that skill's to state" |
| `contested` | Tickets | `policies/tickets.md` | 520 | design writes them; implement needs "one per file, claimed one at a time" |
| `reference` | Fingerprint the working tree | `tools/git.md` | 2,594 | `report-position.ps1` does this |
| `reference` | Check the Marker | `tools/git.md` | 1,721 | "the next three sections are one command" |
| `reference` | Read uncommitted drift | `tools/git.md` | 863 | `report-position.ps1` does this |
| `reference` | Read the Marker diff | `tools/git.md` | 724 | `report-position.ps1` does this |
| `stage:commit` | gh — GitHub CLI | `tools/github.md` | 992 | tracker is local-markdown; issues empty by declaration |
| `stage:commit` | Open a pull request | `tools/github.md` | 324 | implement never pushes or opens a PR |
| `stage:commit` | Check availability and auth | `tools/github.md` | 188 | no `gh` operation exists in implement here |
| `stage:configure` | `contexts/map.md` | `policies/context.md` | 1,893 | generated, never hand-edited — implement never authors it |
| `stage:design` | A shared tracker never carries protocol-only work | `policies/tickets.md` | 1,609 | binds ticket creation |
| `stage:design` | One ticket, one observable outcome | `policies/tickets.md` | 905 | "/design has the procedure for creating them" |
| `stage:design` | Wide refactors are the exception | `policies/tickets.md` | 814 | sequencing a ticket set |
| `stage:design` | Above Express — slicing | `policies/tickets.md` | 631 | how to slice a set |
| `stage:design` | A ticket tracks work — nothing else | `policies/tickets.md` | 564 | binds whoever writes a ticket body |
| `stage:design` | No file paths, no code | `policies/tickets.md` | 412 | binds ticket writing |
| `stage:design` | Scanning for booming | `policies/tickets.md` | 305 | "scan the set when the tickets are cut" |
| `stage:design` | Acceptance criteria state observable outcomes | `policies/tickets.md` | 305 | how to write a criterion, not how to meet one |
| `stage:design` | Marking a ticket obsolete | `policies/tickets.md` | 157 | re-planning marks obsolete |
| `stage:review` | Read a review diff | `tools/git.md` | 1,108 | "`/review` has the rules" |
| `stage:triage` | Roles | `policies/tracker.md` | 692 | "these are triage roles"; every label is *unused* here |
| `stage:triage` | External pull requests | `policies/tracker.md` | 174 | no external request surface exists here |

## Limitations

- **The labelling is one person's and it is the load-bearing input.** One mislabelling
  was found and corrected mid-run, worth six points of the headline. Six spans remain
  `contested`, a 7,143-character spread. A second labeller would move the number again.
- **One stage, one repository.** `/implement` is the largest row; `/design`, `/review`,
  and `/commit` were not measured, and every share above is specific to this corpus.
- **Tokens are estimated at 4 characters each**, not counted with a tokenizer. The
  character figures are exact; the token figures are not.
- **The imperative count is a heuristic** — lines opening in bold. It matches ADR 0074's
  norm form but counts a span holding three imperatives in one bolded line as one, which
  is the fidelity-floor question `13` already circles. It is also the number result 1
  rests on, so result 1 is only as good as it.
- **Domain Contexts were excluded.** They already load by routing rather than by row, so
  including them would measure the routing table, not the filter.
- **Nothing about delivery was executed.** This measures what a filter would produce, not
  whether `` !`command` `` preprocessing delivers it. Items 1–5 of `08` remain open and
  items 1–2 still decide whether 2.0 is buildable at all.

## Conclusion

**Partially Successful.** The filter works and the token half of ADR 0089 is confirmed on
real data: 34.7% strict, 24.4% generous. That is a genuine saving and it is smaller than
the effort had been assuming, because the effort's one estimate was a reading of the
ambiguous spans rather than a measurement.

The compliance half is not confirmed and should stop being claimed. 168 imperatives
become 122, which leaves the row inside the density band `13` was opened about, so
**filtering the row cannot be the answer to F6 on its own**. `13` should be settled
knowing that cutting the row was measured and was not enough, which promotes its
row-versus-corpus sub-question from open to load-bearing.

Two things the design has no place for, both surfaced by running it rather than by
argument: **a seventh of the row is Context, which no norm filter reaches**, and **a row
entry can be 100% inert in a repository while correct at framework level**, with no
detector for it. Neither falsifies an accepted decision, because every relevant ADR is
still `proposed`; both are cheap to fold in now and expensive after a spec is written.

The run also demonstrated its own method working: the one vocabulary gap it first
reported — `role:child` — was killed by inspecting the dropped set it came from.

Not promoted. No code survives.
