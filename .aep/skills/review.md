---
use-when: "work is finished and about to land, or a diff needs judging against what was asked"
---

# /review — judge the work against the change

Two questions about one diff, asked **independently**:

- **Correctness** — does this implement what was asked, and does it work?
- **Standards** — does it follow this repository's own rules and conventions?

They are separate because a change can pass either while failing the other —
every convention followed on the wrong thing, or exactly what was asked in a
style this repository rejects. **Report them together and the stronger axis hides
the weaker one.**

**Two axes. There is no third** — architecture folds into Standards.

**Posture.** Deliberately skeptical — assume defects exist and that you have
not found them yet. The question is never *does it compile*, it is *does this
satisfy the change that was specified*, which is as much a question about the
spec as about the diff. **What this gives up** is charity toward the author,
and speed: a review that agrees quickly has usually only read quickly.

## 1 — Pin the fixed point

**Scope first** — `node .aep/scripts/scope.mjs read`, quoted. A non-empty claim
confines the run to the efforts it names (`[[policies/execution]]`), and it is
what row 1 of the next step resolves to. The claim and the isolation go in the
`Position` of the turn this is a stage of, beside the pinned merge-base and the
non-empty subject below (`[[policies/reporting]]`).

Everything downstream is a function of one ref. Take what the caller supplied — a
SHA, a branch, a tag, `main` — or ask.

**The subject is the working tree, not only what is committed.** A caller can
reach this with the change still uncommitted — a human asking mid-change, a fix
applied and not yet landed — and a commit-range diff is empty then. Pin both and
review their union: the committed range, plus staged, unstaged, and untracked.
An effort's whole branch is the committed half of exactly that union, so the same
pinning serves it without a second procedure.

Compare against the **merge-base**, not the raw ref, so commits that landed on the
base since this work started are not attributed to it. `[[references]]` has the
invocations.

**Then prove it here, before dispatching anything:** the ref resolves, and the
subject is **non-empty**. A bad ref inside a sub-agent comes back as a confident
report on no content.

## 2 — Find what was asked for

In order, stopping at the first that answers:

1. the effort's `spec.md`, for the claim read at step 1
2. task references in the commit messages
3. a path the human passed

**Row 1 is what an effort-level review resolves to, and that is the ordinary
case.** `[[skills/implement]]` calls this once, at the close, over the whole
effort branch — a subject that spans every task in the effort, so no single task
defines it and the spec the effort was built against is what it was asked for.
Leading with a task the caller happens to be holding would narrow the question to
one slice of a diff that is deliberately wider than any of them.

If none answers, **ask**. If there is genuinely no spec, the Correctness axis
reports **no spec available** for the requirements half and says so.

**Never invent, guess, or infer the requirements from the code being reviewed.**
A spec derived from the diff agrees with the diff by construction — that turns
the axis into a rubber stamp while still producing something that reads like a
review.

## 3 — Find what this repository requires

`[[policies]]` and `[[rules]]` selected by `use-when` and `paths` for the files
in the diff, then
`[[contexts]]` for the areas touched, then `CONTRIBUTING.md` and whatever else
this repository documents.

**Skip anything a linter, formatter, or type-checker already enforces.** A
finding a machine will make thirty seconds later is noise.

Where a real design problem is covered by nothing this repository documents,
`[[skills/review/smells]]` is the fallback vocabulary — reported as judgement,
never as breach.

## 4 — Run both axes

**In parallel, as two sub-agents**, dispatched in one message:
`[[agents/reviewer-correctness]]` and `[[agents/reviewer-standards]]`.

Parallel is for latency; **separate contexts are for correctness** — an axis that
can see the other's findings starts agreeing with them, and that pollution is
invisible in the output. Each gets the subject — the fixed point, both diff
invocations, and where the spec is — and reads everything else itself
(`[[policies/execution]]`).

Where the runtime has no sub-agents, run both passes yourself, separately, and
**do not carry conclusions between them.**

Cap each report. Two axes reporting at length produce a review nobody finishes,
and the second half is where the findings that mattered go to be skimmed.

## 5 — Report

Both reports, under `## Correctness` and `## Standards`. **Never merge them and
never rerank across them** — reranking is exactly the collapse the two axes exist
to prevent, and it favours whichever axis produced *more* findings rather than
worse ones.

Close with one line per axis: how many findings, and the worst one **within that
axis**. No single winner across the two.

## 6 — Every finding gets an outcome

A finding with no outcome is a finding that will be raised again next review.

| Outcome | Where it goes |
| --- | --- |
| **Fixed** | the code |
| **Ticketed** | a new task — real, but out of scope for this diff |
| **Accepted** | recorded on the task or in the spec, with the reason |

The third is the one that gets skipped. *"That's fine, leave it"* is a deliberate
trade-off and it needs a home — one nobody wrote down is re-discovered,
re-argued, and re-accepted on every future review.

**Accepting is the human's call, never the reviewer's.** A reviewer that accepts
its own findings has reviewed nothing.

## Reviews are not artifacts

There is no reviews directory. A review is about a diff, and once that diff lands
its subject no longer exists. Everything durable graduates out: a fix into the
code, a boundary into a `[[contexts]]`, an accepted trade-off into the spec, an
unfixed problem into a task. What is left is genuinely disposable.

## Done when

Both axes have run, findings are reconciled without being merged, and each one is
fixed, ticketed, or accepted, and **accepting is the only one of the three that
is the human's**.
