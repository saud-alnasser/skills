---
title: feat(commit): the transaction boundary
status: resolved
blocked-by: [02, 04, 05]
---

## Problem

In `workflow.md`, `/commit` runs a full sync and re-validates the implementation. Both are rediscovery: `/implement` already ran the suite and wrote the knowledge, `/code-review` already checked conventions and boundaries. Repeating them is the error ADR 0010 removed from sync.

What is left is genuinely `/commit`'s, and only `/commit`'s — every item needs either the finished diff or the commit itself to exist.

## Outcome

`./skills/commit/` — model-invoked, because `/implement` closes out through it.

Ticketed work commits through `/implement`, which claims, builds, reviews, commits, and resolves in one invocation. `/commit` is invoked directly for work with no ticket — hand-written edits, or a change made outside the flow — and is the shared implementation both paths use.

### Confirm, don't repeat

Three cheap checks that the prior stages ran. Each is a **question about state**, not a re-execution:

- Were tests run and did they pass? If `/implement` never ran the suite, stop.
- Did `/code-review` run, and are its findings resolved or ticketed? An unresolved finding is a blocker or a ticket, never a silent pass.
- Is the work actually finished against its ticket or spec?

A failure here is **reported**, not fixed. `/commit` does not implement, review, or research — it refuses and says which stage is incomplete.

### The four things only `/commit` can do

**1 — Diff-vs-knowledge consistency.** Not rediscovery: a whole-diff question that no earlier stage could ask, because `/implement` sees one ticket at a time and `/commit` sees the change entire. Did this change move a boundary, retire a concept, or relocate something a Source Pointer names — and does `.claude/context.md` say so? Fix what the diff contradicts; add nothing that fails the compression test.

**2 — The message.** Conventional Commits `type(scope): summary` as the **default when the repository is silent** (ADR 0008). Detect first: `CONTRIBUTING.md`, then recent `git log`. Where the repo documents or demonstrates another convention, follow it. Scope names the engineering domain; reject `misc`, `stuff`, `update`. Say what capability changed and why — never a file-by-file account.

**3 — Mark the spec.** Acceptance criteria may span several commits, so only here is the last one known. When this commit completes them, set `status: implemented`. Only the status line moves; spec content is never rewritten.

**4 — The Marker.** After the commit exists, write its SHA to `.claude/marker.json`. This ordering is not a detail — a commit cannot contain its own SHA, which is why the Marker is machine-local and written last (ADR 0005, 0010).

## Acceptance

- `/commit` never runs tests, never reviews, never researches. It confirms those happened and refuses when they didn't.
- The Marker equals `HEAD` after a successful commit, so the next verification is a single `git` check and nothing more.
- A commit whose diff contradicts `.claude/context.md` is blocked until context is corrected.
- A validation failure names the incomplete stage rather than reporting a generic refusal.

## Comments

**The scope vocabulary is not restated here, against this ticket's own wording.**
Outcome item 2 says *"Scope names the engineering domain; reject `misc`, `stuff`,
`update`"*, and `skills/configure/CLAUDE.template.md:114` already carries that
sentence — for commit subjects, PR titles, and issue titles alike. ADR 0007 binds
harder than the ticket: a rule with two homes drifts as soon as one copy is
edited. `/commit` keeps only what is its own, which is the **detection**
procedure ADR 0008 requires, and points at `CLAUDE.md` for the convention itself.
The first draft restated it and shipped an assertion that *required* the breach
in order to pass; `verify.ps1` now guards the vocabulary in the single-home table
instead.

**ADR 0008 names three detection inputs; this ticket names two.** It says
*"Detect first: `CONTRIBUTING.md`, then recent `git log`"*; ADR 0008's
consequences read *"after reading `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE*`,
and recent `git log`"*. The ADR wins and all three are read.

**The steps are ordered so the commit is the last write except the Marker.**
This ticket numbers the message before the spec status. Both must precede the
commit, and the spec is a *tracked file* — marking it afterwards leaves the tree
dirty the instant the commit lands, which defeats the Marker's clean path on the
very next turn and undoes the point of advancing it. Order is: knowledge → spec
status → message → commit → Marker. Only the Marker comes after, because a
commit cannot contain its own SHA (ADR 0005).

**`/commit` heals Context; it does not author it.** ADR 0010 line 23 enumerates
the knowledge writers as `/design`, `/implement`, and `/configure` — `/commit` is
not among them, yet outcome item 1 gives it a corrective write. The enumeration's
point is *never CI*, and 0010's actual principle is *healing where the break is
found*. `/commit` is where the whole-diff break is found, so it repairs what the
diff falsified and authors nothing new. The boundary is stated in the skill and
asserted, because an unstated one erodes into authorship.

**`skills/design/SPEC-FORMAT.md` was edited — ticket 03's artifact.** It
enumerated `draft` / `accepted` / `superseded` and knew nothing of the status
this ticket makes `/commit` write. Decision 23 supplies the full set, so
`implemented`, `superseded by <path>`, and `abandoned` were added there and the
*only the status line moves* rule now lives in the format file rather than in the
actor. `verify.ps1` asserts the two agree, so the pair cannot drift apart again.

**Never-push and the amend are pointers, not restatements.** `tools/git.md` owns
both invocations and the never-push reasoning; `/implement` owns *one ticket
stays one commit*. What is left here is the prohibition itself — stated, not just
linked, because this is the file a reader opens to ask whether the commit skill
publishes — and the Marker's re-advance on amend, which ticket 04 line 123
delegates here explicitly.

**Review found four assertions that could not fail**, and both axes found the
same first two independently: an ungrouped alternation (`(never|not) a silent
pass|silent pass`) whose bare branch passed on *"a silent pass is fine"*; a
detection-ordering check that computed both indices and then never compared them;
an unnegated file-wide `file-by-file`; and an ordering guard that checked only one
of its two `.Success` flags, where a failed match yields index 0. All rewritten
and re-mutated. The single-home Marker pattern was also broadened from `==|matches`
to include `equals` — word choice was letting a restatement through — while
scoping it to the *decision procedure*, so a skill may still state the bare
postcondition it leaves behind.
