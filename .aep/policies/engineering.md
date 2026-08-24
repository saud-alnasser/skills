---
use-when: "writing code, or about to state anything about this repository you have not verified"
---

# Policy — engineering

How a claim is made, how a change is made, and what to do on finding that you do
not know.

## Claims

- **Inspect the source before any repository-specific claim.** A claim is either
  checked or a guess in the same words — and **names are not proof**, nor memory,
  nor a plausible API. Never infer an API from a filename: `src/auth/` is where
  to start reading, not evidence that an auth module exists there.
- **Never guess an API, and a CLI is an API.** Read the reference; never try a
  flag and see. `[[references]]` covers the tools this repository uses; an
  operation none of them covers is a gap — **say so** rather than inventing an
  invocation.
- **Separate what you verified from what you assume**, and say which is which.
  An assumption stated as a fact is indistinguishable from a finding by the time
  anyone acts on it.

## Change

- **Smallest sufficient change.** An improvement you notice outside the task is
  raised, not taken.
- **Read before modifying** — the whole of what you are about to change, not the
  part you expect to matter.
- **Preserve architectural consistency.** Match the surrounding code: its idiom,
  naming, error handling, and comment density. A correct diff that reads as
  foreign is still a maintenance cost.
- **Root cause, not workaround.** When you hit a limitation, find out why it
  exists before designing around it. Where a workaround genuinely is the answer,
  record **why it exists, what else was considered, and the condition under which
  it is removed** — without a removal condition, "temporary" is an intention
  rather than a state anything can leave.
- **Obeying a rule means letting its check fire.** Keeping the letter of a
  requirement while arranging that its check cannot run violates it more
  completely than defiance, which at least leaves a trace. Before satisfying one,
  ask what it would have caught and whether that is still reachable.

## What gets written

- **Code explains itself.** A comment explaining *what* marks code to improve,
  not to annotate. Comments say **why**.
- **A workaround needing a paragraph of justification is wrong code — fix the
  code.**
- **Document every public API.**
- **Name a file for the one thing it holds**; directories carry the qualifiers.
- **No abbreviations in names** unless the abbreviation is clearer or necessary.
- **Tests sit as near the code as the language and tooling allow** — the
  repository's own convention wins.

## Decisions

**Never silently decide architecture.** Where more than one reasonable approach
exists, put the options on the table — each named, with what it buys, what it
costs, what it risks, and what it means for maintenance — recommend one, and let
the human choose. **An alternative left unmentioned is a decision made silently.**

**A converge round is not a way around this.** Converge closes gaps below the
plan and raises anything above it (`[[policies/execution]]`). A requirement the
approach cannot satisfy is the plan being wrong, and a ticket appended against it
is this prohibition being evaded one round at a time — which reads as progress,
because a ticket got written.

## Publishing

Never push, never publish, never open a pull request unasked
(`[[rules/version-control]]` names exactly what that covers, and why the line
sits where it does).

## When you find that you do not know

Everything above governs how a claim is made at all. This is what to do once you
have found that you cannot make one.

**Climb only as far as the uncertainty warrants.**

```
known fact → repository inspection → existing context/evidence
→ research → prototype → grill
```

Use the **cheapest reliable** mechanism. Expensive investigation for trivial
uncertainty is its own defect — a config rename does not get a research phase.

Route by the *kind* of uncertainty, because the wrong instrument produces a
confident wrong answer:

| Uncertainty | Instrument |
| --- | --- |
| factual — what does this API actually do | `[[skills/research]]` |
| technical — will this approach work | `[[skills/prototype]]` |
| product, requirement, tradeoff, disagreement | grill, via `[[skills/refine]]` |

Argument cannot settle a factual question, and reading cannot settle whether an
interaction feels right.

## What gets recorded

Evidence lives at `efforts/<effort>/evidence/`, in `research/` or `prototypes/`.
Those are the only two kinds.

- **Research records findings, never decisions.** If a finding changes the
  design, change `spec.md` deliberately. *Why: research that quietly becomes a
  decision is an architecture chosen by whoever ran the search.*
- **Prototype code is disposable.** It MUST NOT automatically become production
  code; promotion is an explicit decision recorded in `spec.md`, and what is
  promoted is rewritten under `[[skills/implement]]`.
- **Grill is not evidence.** It is a mechanism; its conclusions land in the spec,
  a policy, a rule, a context, or an evidence file. There is no `grill/`
  directory.
- What you looked for and did **not** find is a finding. Record it.

## Graduation

Knowledge that outlives its effort moves into a `[[contexts]]`, a `[[rules]]`, or
a `[[references]]`. The evidence file stays where it is, as the record of how it
was learned.
