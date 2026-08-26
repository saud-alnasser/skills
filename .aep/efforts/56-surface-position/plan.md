---
use-when: "building a ticket in this effort and the approach is not obvious from the spec"
---

# Architecture

`scripts/scope.mjs` gains two computed fields, `surface` and `role`, beside the
claim and the isolation it already prints. Nothing is stored and nothing new is
invoked: every skill that needs the answer already calls this script at entry and
already quotes what it prints.

The derivation is a path comparison against the main checkout, which
`git worktree list --porcelain` already gives us as its first entry. Given the
current tree's toplevel and the main checkout's, one relative path decides
everything:

| The current tree is | `surface` | `role` |
| --- | --- | --- |
| the main checkout | `main` | `none` |
| `.aep/worktrees/<effort>/_run` | `run` | `orchestrator` |
| `.aep/worktrees/<effort>/<other>` | `ticket` | `implementer` |
| a linked worktree elsewhere | `runtime` | `orchestrator` |
| anything else | `unknown` | `unknown` |

`_run` is the discriminator and it is reserved: `[[skills/specify]]` creates that
exact path and `[[skills/implement]]` re-enters it, so every other directory under
an effort is a ticket surface. The last row exists so the table is total. A path
that matches nothing resolves to `unknown`, and every rule keyed on the role
declines to fire, which is the direction `resolveBase` in this same file already
established for a wrong answer.

`role: none` in the main checkout is not a gap. It is the signal that a run has
not yet taken a surface, which is precisely the condition
`[[policies/execution]]` already requires a run to act on before its first write.
So the field the derivation adds for the main checkout is the one that makes the
existing rule checkable.

## What lost

**`position.mjs` as the home for this.** The word "position" is where a reader
looks for where they are, and the marker is already per-surface. It lost on three
counts: the script's own header states that the marker carries no effort identity
by design and role implies an effort; `[[skills/prune]]`, `[[skills/survey]]` and
`[[skills/refine]]` read scope and not position, so each would gain a second call
to answer one question; and effort 51's `plan.md` already evaluated this exact
shape, as "a `scope` command on `position.mjs`", and rejected it for the reason
that it "invites the belief that scope is stored in the marker". Choosing it now
would re-open a decision this repository has already made twice.

**A separate `surface.mjs`.** One script per question is the cleanest separation
and it costs a third invocation at every skill entry, forever, plus a payload
entry, a manifest regeneration and a new verify section. The recurring failure it
invites is a skill that calls two of the three and quietly disagrees with itself.

**A script that refuses.** `scope.mjs` could exit non-zero when the act does not
match the surface. Declined, because effort 54 established the split this effort
follows: the script reports the isolation and `[[policies/execution]]` keys the
decision on it. A script that refuses is also one a run must be able to route
around when the derivation is wrong, and a documented route around a guard is not
a guard.

**A position step for `/domain`.** Carried in the spec's first draft and removed
here. `[[policies/reporting]]` names it a stage of the turn it is inside, and a
stage opens no report; it has no scope read either. See the spec's Out of Scope.

## Review's unit becomes the effort

The two reviewer agents move from `[[skills/implement]]`'s step 4, where they run
between integrating a child and landing that child's commit, to its close, where
they run once against the effort branch after converge finds no gap.

`[[skills/review]]` itself barely changes. Its step 1 already pins a merge-base
and already reviews the union of the committed range and the working tree, which
is exactly the shape an effort-level subject needs. Its step 2 already falls
through to "the effort's `spec.md`, for the claim read at step 1" when no ticket
is in hand, so removing the per-ticket caller promotes a path that already
exists rather than adding one. What changes is the caller, the moment, and the
first row of step 2's list.

**Three rules downstream of the move, and each has to be rewritten rather than
deleted.**

The **ticking rule** in `[[policies/execution]]` says a criterion is ticked by
`[[agents/reviewer-correctness]]` and that an author never ticks its own. With
reviewers at the effort, no non-author is present when a ticket lands. It narrows
to: the orchestrator ticks what it verified, carrying inline what verified it, and
a dispatched child still never ticks. The case given up is a wave of one, which
`[[skills/implement]]` builds inline, and the compensation is that the effort
review is now guaranteed to run over it.

The **two-rejections rule** parks a ticket after a review rejects it twice. A
finding against the effort names no single ticket, so there is nothing to park. It
is replaced by the outcome discipline `[[skills/review]]` already carries: every
finding is fixed, ticketed, or accepted by the human, and one still open stops the
pull request being marked ready.

**The correction path is the loop the run already has, not a new mechanism.** The
orchestrator validates each finding and either fixes it or writes a ticket; the
ticket reaches the frontier; `/implement` schedules it like any other work. This
costs nothing extra because **nothing has left the run's reach**. The effort
branch is held in the orchestrator's own surface, the pull request is a draft, and
`main` is untouched, so every commit in the effort is still the run's to change.
`[[skills/review]]`'s outcome table already makes **Ticketed** available without
the human, since only **Accepted** is reserved to them.

What the replacement has to carry forward is the *bound*, not the parking. The old
rule stopped a ticket looping through fix-and-review forever; the new one stops the
effort doing it. Two rounds, then a surviving finding is recorded unresolved with
what the review said and the run stops. Without that, review-to-ticket-to-review is
a loop with no stated end, which is exactly what the rule being replaced existed to
prevent.

The **commit rule** in the specification says an agent must not commit work that
has failed review. Once review runs after every commit, nothing can satisfy that
as written, and a requirement nothing can satisfy is one every implementation
quietly ignores. It is restated against the handover rather than the commit.

## What lost, on review

**Reviewing per wave.** A middle position: review each wave rather than each
ticket or the whole effort. It sees more than a ticket and less than the effort,
and it reintroduces the question this change answers, which unit, without
answering it. The effort is the unit because it is the one a human is asked to
merge and the one the single pull request carries.

**Keeping per-ticket review and adding an effort pass.** Nothing is superseded and
the ticking rule survives intact, at the cost of dispatching reviewers roughly
twice as often. Declined: the per-ticket pass would then exist to tick boxes
rather than to judge, which is a review in name doing bookkeeping.

# Components

| Path | Becomes responsible for |
| --- | --- |
| `src/scripts/scope.mjs` | computing `surface` and `role`, rendering them in `read` and `--json`, and changing no exit code |
| `src/policies/execution.md` | what a run does about the role, stated where it already states what a run does about the isolation |
| `src/agents/implementer.md` | its existing constraints, keyed on the computed role rather than asserted in prose |
| `src/skills/implement.md` | the position check moving to after the surface is entered, and the orchestrator's acts keyed on the role |
| `src/skills/specify.md` | reading position by script rather than naming the marker file in prose |
| `src/skills/prune.md`, `src/skills/survey.md` | a position check on entry and a stamp at close |
| `src/policies/reporting.md` | a row per skill that reads position |
| `specs.md` sections 18 and 20 | defining the surface, the role, and one marker per surface |
| `src/skills/implement.md` | review moving from step 4 to the close, and the two-rejections rule going with it |
| `src/skills/review.md` | the first row of step 2's list, which currently names the ticket the caller holds |
| `src/policies/execution.md` | the ticking rule, narrowed, and the run log line that counts review attempts per ticket |
| `specs.md` sections 20 and 21 | review's unit and subject, and the commit rule restated against the handover |
| `src/scripts/verify.mjs` | the assertions, including the invoker set this change breaks by name |

# Interfaces

`scope.mjs read` gains two lines, using the existing `field()` renderer and the
existing eleven-column label width:

```
claim      56-surface-position
working    -
surface    run at .aep/worktrees/56-surface-position/_run
role       orchestrator of 56-surface-position
isolation  worktree, enforced, sibling of 6 at ...
base       origin/main
```

Placed above `isolation` because surface and role are what a reader acts on and
the isolation is what they are derived from. A child surface reads
`role  implementer on 03-the-ladder-as-a-value for 47-post-merge-labels`; the
main checkout reads `surface  main` and `role  none`.

The role is two lines rather than a clause on the `isolation` line. That line
already carries a kind, an enforcement, a sibling count and a path, and a fifth
clause makes it unreadable at exactly the moment a human is scanning for where
they are.

`scope.mjs read --json` gains:

```json
{
  "surface": { "kind": "run", "effort": "56-surface-position", "ticket": null, "path": "..." },
  "role": "orchestrator"
}
```

`kind` is one of `main`, `run`, `ticket`, `runtime`, `unknown`. `role` is one of
`none`, `orchestrator`, `implementer`, `unknown`. `effort` and `ticket` are null
where the kind does not carry one.

**Exit codes do not move.** `read` still exits 0 on a non-empty claim and 1 on
`unscoped`, and `check` is untouched. A caller reading the exit code sees no
change, which is what keeps requirement 8 checkable: the same fixture with an
unresolvable role exits identically.

# Technical Approach

The order, and why it is this order:

1. **`scope.mjs` computes and renders the fields.** Everything else consumes
   them, so nothing can be written against them until they exist.
2. **`specs.md` sections 18 and 20.** The normative text has to say what is
   computed and what is done with it before the shipped surfaces can be asserted
   against it, since `verify.mjs` asserts against `specs.md`.
3. **`policies/execution` states the rule.** It is where the isolation rule
   already lives, and every skill below cites it rather than restating it.
4. **The skills and the agent**, which can then be written in any order:
   `implement` (check moves, acts keyed on role), `specify` (script rather than
   prose), `prune` and `survey` (check and stamp), `agents/implementer`
   (constraints keyed on role), `policies/reporting` (the table).
5. **`verify.mjs` last for the assertions that pin prose**, and alongside step 1
   for the assertions that pin behaviour. The invoker-set assertion moves in the
   same commit as the skill that breaks it, never after, or the tree sits broken
   between two tickets.
6. **Reinstall into `.aep/`.** `src/` is the source and `.aep/` is output
   (`[[contexts/repository]]`), so the dogfood tree is regenerated rather than
   hand-edited.

Steps 1 and 2 gate everything. Steps 3 and 4 are the wide part of the work and
have no edges between them once 3 has landed.

**The review change runs as its own strand of the same shape**, and joins at step
6. Its normative text lands first, in the specification's sections 20 and 21,
because the same rule applies: `verify.mjs` asserts the shipped surfaces against
the specification, so the surfaces cannot be asserted before it says what they
must contain. Then `[[skills/implement]]` and `[[skills/review]]` together, and
`[[policies/execution]]`'s ticking rule.

The two strands touch two files in common. `skills/implement.md` is edited by the
position-check move and by the review move; `policies/execution.md` by the role
rule and by the ticking rule. Those edges are declared on the tickets rather than
left to be discovered at integration, and they are the reason the review strand is
not simply parallel.

## The path comparison, and the hazard it inherits

`resolveScope` carries a comment earned the hard way: on Windows one spelling of
a path can arrive as an 8.3 short name, which `path.relative` cannot reconcile,
and what it returns then matches nothing while reading as though it worked.

The derivation is subject to the same hazard, and the mitigation is the one the
file already uses. Both paths come from git rather than from Node: the current
tree from `git rev-parse --show-toplevel`, which `resolveScope` already reads, and
the main checkout from the first entry of `git worktree list --porcelain`, which
`parseWorktrees` already returns. Git guarantees the main worktree is listed
first. Normalise both to forward slashes before comparing, which is what
`effortOf` already does and for the same reason.

**Never build either side with `path.resolve` against `process.cwd()`.** That is
the specific move the existing comment warns about.

## Where `.aep/` is not at the repository root

`resolveScope` already handles a nested `.aep/` by reading `--show-prefix` from
the directory holding it. The worktrees directory is a sibling of `efforts/`
under that same root, so the comparison is built from `path.dirname(root)`
relative to the main checkout, not from a hardcoded `.aep/worktrees`.

# Integration

- **`[[policies/reporting]]`'s table** gains a row per skill that reads position.
  A new assertion fails when a skill invokes `position.mjs` and has no row, so the
  table cannot drift from the skills again.
- **`[[rules/authoring]]`'s citation rule** binds every file under `src/`: shipped
  text may not name `specs.md` or a section number. The section numbers in this
  plan and in the spec stay in `.aep/efforts/`.
- **The `working surface` section of `verify.mjs`** already builds real worktrees
  in a temp directory and already asserts git's refusals. The fixtures for
  requirement 2 extend the `scope` section's existing harness, which already
  creates a linked worktree outside `.aep/worktrees/` for the isolation
  assertion. That existing worktree is the `runtime` row of the table, so three of
  the four rows need new fixtures and the fourth is already built.

# Migration

**Nothing migrates.** The marker's shape is unchanged, so no installed tree is
rewritten and none needs to be. A tree running an older release keeps working:
the fields are additive to `scope.mjs`'s output, and a skill that does not read
them is unaffected.

**The trees that cannot be edited.** This clone holds two efforts in flight, 47
and 48, with agents running in their surfaces. They are not retrofitted, per the
spec, and this effort's own work happens in its own surface. No ticket in this
effort reads git state in another effort's surface.

# Testing Strategy

Every acceptance criterion, and what checks it:

| Criterion | Check |
| --- | --- |
| 1 | the `scope` section's `fieldOf` helper against `read`, and `JSON.parse` against `read --json`, in each of the four shapes |
| 2 | new fixtures in the `scope` section: worktrees at `.aep/worktrees/40-alpha/_run` and `.aep/worktrees/40-alpha/03-thing`, plus the existing `linked` worktree for the runtime row and the fixture root itself for main |
| 3 | the existing marker shape assertion, unchanged, plus one that rejects a fourth key |
| 4 | an ordering assertion over `skills/implement.md`: the index of the surface step is less than the index of `position.mjs check` |
| 5 | `skills/specify.md` matches `position\.mjs` and does not match `position/marker\.json` |
| 6 | the assertion at `verify.mjs:1977`, rewritten to the five-member set, plus a fixture running `prune`'s stamp and comparing the marker's `head` to the tree it read |
| 7 | assertions over `agents/implementer.md` and `policies/execution.md` that each constraint names what it is keyed on, not merely that the constraint is present |
| 8 | one fixture, run twice: once where the role resolves and once where it does not, asserting identical exit codes |
| 9 | a cross-check that the set of skills invoking `position.mjs` equals the set of rows in `policies/reporting`'s table |
| 10 | `node src/scripts/verify.mjs`, and the perturbation discipline below |
| 12 | two assertions over `skills/implement.md`, one that review is named after converge and one that it is absent from the per-ticket landing sequence. Either alone passes on a document that reviews twice |
| 13 | an assertion that the narrowed ticking sentence is present **and** that the unqualified one is absent |
| 14 | a tree-wide search for the parking rule, asserting it survives nowhere, plus an assertion that an open finding is stated as blocking the ready mark |
| 15 | assertions reading the specification's text for review's subject, the absence of "per ticket", and the restated commit rule |
| 16 | two assertions over `skills/implement.md`, one that the correction path is stated and one that the two-round bound is stated with it. The second is the one that matters: a path without a bound is the failure the replaced rule prevented |

## Each new assertion is seen to fail first

`[[rules/authoring]]` names the recurring failure: a guard that matches something
travelling *with* the thing it checks rather than the thing itself, so it passes
while what it existed to catch sits in the tree. Every assertion added here is
written, then the thing it checks is deliberately removed, and the assertion is
watched to fail **with the right name**.

This matters most for criterion 7. "The constraint names what it is keyed on" is
exactly the kind of claim a regex can satisfy by matching the surrounding
sentence. The perturbation for it is to delete the keying clause while leaving the
constraint, and confirm the assertion goes red.

# Technical Risks

- **The invoker-set assertion is loosened rather than rewritten.** It is the one
  assertion this change is guaranteed to break, and the cheap way past it is to
  stop asserting the set. It would show up as a diff that deletes the assertion or
  replaces the equality with a subset test, and it would remove the check that
  made this problem visible. The reviewer's specific instruction is to read that
  hunk.
- **The path comparison is right on this machine and wrong on another.** The 8.3
  hazard is a Windows-only failure that a POSIX developer cannot reproduce, and
  its signature is `surface: unknown` in a tree that plainly has one. Mitigated by
  building both sides from git output, and it would first show up as a fixture
  passing here and failing in a checkout reached through a shortened path.
- **A runtime places its worktrees under `.aep/worktrees/`.** Then a runtime
  surface reads as a ticket surface, and its occupant would refuse to integrate.
  Recorded as an assumption in the spec. It would show up as a run reporting
  `role: implementer` while holding an effort branch rather than a ticket branch,
  which is a mismatch the orchestrator's own acts would surface immediately.
- **The role is computed but nothing keys on it.** The failure mode where
  requirement 1 lands and requirement 7 quietly does not, leaving a field nobody
  reads. Criterion 7 is the guard, and it is the criterion most likely to be
  called satisfied by prose that mentions the role without depending on it.
