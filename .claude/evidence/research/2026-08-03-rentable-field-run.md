# AEP improvement brief

Date: 2026-08-03
Filed by: `/design` (the fieldwork effort), not `/research` — this is a field report carried in from a `/design` run on `saud-alnasser/rentable`, filed as research evidence because it shares the kind's property: external facts, true of the moment they were taken, never revalidated. What was durable graduated into ADRs 0035–0037 and the fieldwork spec.

Findings from one full `/design` run on a real repository, `saud-alnasser/rentable` — a Tauri 2 + SvelteKit desktop app configured with AEP at user scope. The run planned a full interface overhaul: three architectural forks settled through grilling, two ADRs written, a map produced, seven decision tickets created on GitHub and then closed again because they turned out to be structurally invalid.

**That last sentence is the headline.** AEP instructed the creation of seven tracker issues that the target repository's own conventions could not accept. Nothing caught it. The user caught it.

Everything below is evidence-backed from that session. Fixes are proposed, not prescribed — several have more than one reasonable shape.

---

## 1 — The root defect: `maps.md` never checks what a ticket *means* on the target tracker

**Severity: high. This is the one that produced visible damage.**

`maps.md` asserts, without qualification, that a map is worked as tracker tickets:

> A map finds the way. It is a shared artifact of **decision tickets**, worked one at a time until nothing is left to decide.

and

> The map lives beside the tickets, wherever `.claude/policies/tracker.md` says those are: `.claude/tickets/map.md` on a local-markdown tracker, a pinned issue on GitHub.

But this repository defines a ticket, in its own `.claude/policies/version-control.md`:

> One ticket becomes one `gt create`, which produces **one branch carrying exactly one commit**, which becomes one pull request.
>
> That is not a style preference — it is what makes the stack reviewable.

A decision ticket — "should infinite scroll survive server-side sort?" — produces no branch and no commit. It produces a paragraph in a design document. So on this repository, decision tickets **cannot be tickets**, and AEP had no step that compares its own assumption against the target's definition.

The seven issues were created (#212–218), then closed as `not planned` with the reason recorded, and their sub-issue links removed. The map issue #211 survives because it *will* parent real build tickets.

**Three separate symptoms all trace to this single missing check** — they are listed below as items 2, 3 and 4, but fixing this one may dissolve them.

### Proposed fix

Add a routing step to `maps.md`, before any ticket is created:

> **Where decision work lives depends on what a ticket is here.** Read the tracker's own definition. Where a ticket is branch-bound — one ticket becomes one branch, one commit, one pull request — decision work does **not** go on the tracker: it lives as sections in the design document under `.claude/designs/`, resolved in place, each resolution landing as a `docs:` commit. Only the map itself goes on the tracker, because only the map survives into build tickets.
>
> Where a ticket is just a unit of tracked intent, decision tickets are tickets and the rest of this file applies as written.

The test is cheap and mechanical: does the repository's version-control policy tie a ticket to a branch?

---

## 2 — `maps.md`'s prose and its own template contradict each other on titles

**Severity: medium. Directly caused a wrong judgement call.**

The prose says decision tickets differ from ordinary tickets in exactly two ways:

> Same file and format as any other ticket (see `.claude/policies/tickets.md`), with **two differences**: the body is a question, and the ticket carries a type.

The template immediately below makes a **third** change it never mentions:

```markdown
# <NN> — <the question, as a title>
```

`tickets.md` is unambiguous that a title is a Conventional Commit subject:

```markdown
# <NN> — type(scope): summary
```

> The title is a Conventional Commit subject, so the ticket's commit writes itself.

I followed the template and wrote bare questions as issue titles. The user pushed back and was right to. Worse: I resolved the conflict silently instead of surfacing it, which is its own failure — but AEP created the conflict.

There is a real reason the conflict exists. `tickets.md` justifies the Conventional title with *"the ticket's commit writes itself"* — and a grilling ticket has no code commit. But it is not commitless either: a decision resolves into an ADR, which *is* committed as `docs:`. So the rule still applies; it just needs saying.

### Proposed fix

Either say "three differences" and state the title rule explicitly, or delete the title line from the template so `tickets.md` governs unopposed. Prefer the former, with the rationale:

> The title stays a Conventional Commit subject. A decision ticket's commit is the ADR or design-document change that records the answer — usually `docs:`.

---

## 3 — Build tickets have no lifecycle vocabulary on a GitHub tracker

**Severity: medium. Currently unresolvable as written.**

`tickets.md` states the mapping:

> `Status:` and the edge lines are the **local-markdown form**. On GitHub the same states are labels.

But `tracker.md`'s label table maps only **triage** roles — `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. And `tickets.md` then explicitly forbids build tickets from carrying any of them:

> **This is not the triage vocabulary.** … A build ticket `/design` created is agent-ready by construction and never carries one.

So the four build-ticket states — `open`, `blocked`, `resolved`, `obsolete` — have **no GitHub representation at all**. `obsolete` is the one that breaks hardest, because `tickets.md` demands:

> Set `Status: obsolete` and add a one-line reason. **Never delete it** — the reason it existed is part of the record.

On GitHub there is no third state. Closing reads as delivered; leaving it open means someone will eventually claim it. In this session I closed the seven with `--reason "not planned"` plus an explanatory comment, which is a reasonable convention — but I invented it.

### Proposed fix

State the GitHub form for the build lifecycle explicitly. Options worth weighing:

- **Closure semantics** — `open` is open; `resolved` is closed-as-completed by the merge; `obsolete` is closed-as-`not planned` with a mandatory comment giving the reason; `blocked` stays open with the reason in the body. Needs no new labels, which fits repositories with an established vocabulary they do not want extended.
- **Explicit labels** — define the four, accept that `/configure` must create them.

The first is likely better for exactly the reason `tracker.md` already gives about not inventing labels — but AEP has to *say* which, because right now a correct implementation is not derivable.

---

## 4 — Dual numbering when the tracker assigns its own numbers

**Severity: low, but it makes maps hard to read.**

`maps.md` numbers decision tickets `01`, `02`, … and `tickets.md` numbers all tickets from `01` in dependency order. GitHub then assigns its own. In this session, map ticket `03` became issue `#214`, and edges must reference GitHub numbers, so issue #215 — titled `04 — …` — carried `Blocked by: #214`.

A reader has to look up #214 to discover it is `03`. Two numbering systems for one set of tickets, with no stated relationship.

### Proposed fix

State it either way, but state it: drop the `NN` prefix when the tracker assigns numbers (the tracker's number *is* the id), or require edges to use map numbers with the tracker number in parentheses. The first is simpler and loses nothing — dependency order can be read from the edges.

---

## 5 — `Blocked by:` is redefined per repository, and `maps.md` does not account for it

**Severity: medium. Produces silently wrong semantics.**

`tickets.md` defines the edge as a gate:

> `Blocked by: 02, 05`  # this cannot start until those are delivered

This repository redefines it, because it is stacked:

> Because the model is stacked, **`Blocked by: 01` in a ticket means _stack on top of 01_**, not _wait until 01 is resolved_. Waiting is the thing the tool exists to remove.

For a decision ticket with no branch, "stack on top of" is meaningless — but the edge still reads that way to anyone following the repository's own policy. I had to write a disclaimer into two issue bodies to disambiguate, which is a smell.

### Proposed fix

`maps.md` should state that a decision ticket's edge is always answer-gating and never a stacking instruction, regardless of what the repository's version-control policy makes the edge mean for build tickets. Or — better, and consistent with fix 1 — this evaporates entirely once decision work stops being tickets on branch-bound trackers.

---

## 6 — `aep/github.md` is missing two calls the map workflow requires

**Severity: medium. One of them is required by `maps.md` itself.**

**`gh issue pin` / `gh issue unpin`.** `maps.md` requires the map to live as *"a pinned issue on GitHub"*, and the reference has no entry for pinning. I verified `gh issue pin <number>` exists via `gh issue --help`, added the entry to this repository's copy, and deliberately marked the at-cap behaviour as untested rather than asserting it — GitHub caps pinned issues per repository and `--help` does not document whether `pin` refuses or evicts.

**Sub-issue removal.** The reference documents attaching a sub-issue and mentions in passing that *"the removal path is singular — `DELETE .../sub_issue`, not `sub_issues`"* — but gives no invocation. This is needed the moment a decision ticket turns out not to be a ticket, which is exactly what happened. Verified from GitHub's docs this session:

```
gh api --method DELETE repos/{owner}/{repo}/issues/<parent>/sub_issue \
  -F sub_issue_id=<id>
```

Same `id`-not-`number` trap as the attach call, and same `-F`-not-`-f` integer-typing trap.

### Proposed fix

Add both to `aep/github.md`. The pin entry should carry the untested-at-cap caveat rather than a guess.

---

## 7 — `maps.md` does not say what becomes of the design document once the map issue exists

**Severity: low.**

`/design`'s approval gate requires the ticket set be written into the design document first, shown, and approved before creation. `maps.md` then puts the map on the tracker. Nothing says what the design document becomes afterwards — a duplicate, an archive, or the working copy.

I invented: *"Until it is approved and created as a pinned issue, this file is the map. Once created, the pinned issue is the map and this file is superseded by it."* That reads well but is my invention, not AEP's.

Relatedly, the two files brush against each other: `/design` says *"write the set into the design document — every ticket, with its edges"*, while `maps.md` says *"Open tickets are **not** listed [on the map] … a list of them on the map is a second copy that goes stale."* They are compatible — the design document holds the proposal, the map does not mirror it — but it takes a beat to see, and one clarifying sentence would remove the beat.

---

## 8 — The Marker path is easy to get wrong, and getting it wrong produces a confident false report

**Severity: low, but it corrupts the one artifact that proves the discipline ran.**

`protocol.md` states the path as `.claude/position/marker.json`. In this session I checked `.claude/marker`, found nothing, and opened with *"no marker file — nothing trusted as-is."*

A marker **did** exist. The conclusion happened to survive — the marker was not an ancestor of `HEAD`, so nothing would have been trusted anyway — but that was luck, not correctness. The verification report is described as *"the only evidence the discipline ran"*, and mine was wrong.

### Proposed fix

Have the skills that open with a verification report name the exact path in the check step rather than relying on the reader to carry it from `protocol.md`. Cheap, and it removes a failure mode that is invisible when it fires.

---

## 9 — Design and construction cannot always be separated, and AEP has no way to say so

**Severity: high. This is a capability gap rather than a defect — the workflow is correct as written and still cannot express a real and common situation.**

AEP's phase split assumes every decision can be resolved before code exists. `/design` resolves everything, `/implement` builds and decides nothing. The map exists precisely because decisions sometimes cannot all be front-loaded, but its exit condition keeps the same assumption:

> When nothing is left to decide, the map is done.

For interface work that condition is frequently unsatisfiable. Two of the seven open questions on this map are examples, and neither is unusual:

- **Surface separation without blur.** Whether a border-and-value-only surface reads as raised is not answerable against a mock. It needs real rows, real density, real content lengths.
- **Data table behaviour in Arabic.** A description tells you nothing. A populated table in both locales tells you everything.

Today the options for such a question are: guess and record it as settled, or build a throwaway prototype that is most of the real component and then delete it. Both are waste, and the first is the dangerous one because it produces a map that *claims* to be resolved.

### The correction that matters to the mechanism

The obvious fix — let a build ticket declare a decision that `/implement` resolves by calling `/design` — is right in shape but wrong in one important detail.

`maps.md` types decisions HITL or AFK and is blunt about the distinction:

> An agent that answers its own grilling questions has not resolved the ticket; **it has skipped it.**

`grilling` and `prototype` are both HITL. So an agent reaching a declared prototype increment mid-build **cannot resolve it** — it needs the human present. Which means, for those types, "calls `/design`" and "hands back blocked" are the same event.

**So the value of this proposal is not a new control-flow path. It is predictability.** A ticket that declares *"there is a prototype decision at step 3"* lets the human schedule the session and be there. A ticket that discovers the same decision mid-build hands back as blocked and the run is lost. Identical stop, very different cost.

`research` and `task` are the genuinely AFK types, and those an agent can resolve inline.

### Proposed shape

**1. `tickets.md` gains an optional section**, written at design time:

```markdown
## Design increments

- **step 3 — elevation for the sticky table header** · prototype · HITL
  Whether the header reads as raised using border and value alone is not
  decidable before real rows exist. Scoped to this ticket; affects no other.

- **step 5 — column min-widths at the 640px floor** · research · AFK
  Resolvable from measured content widths; /implement resolves inline.
```

**2. `/implement` gains a rule.** On reaching a declared increment, invoke `/design` **scoped to that increment only**, never widening. AFK types resolve inline and land in the same commit. HITL types stop — but the stop was on the calendar.

**3. The guardrail, which is the load-bearing part.** Without it this becomes a scope-creep vector, because a ticket that may declare "design happens here" invites every ticket to:

> An increment must be **declared at design time**. `/implement` may not invent one. A decision discovered that was not declared is still `blocked`, exactly as today.

This preserves the discipline that makes the split valuable — `/implement` still does not get to redesign — while removing the surprise.

**4. `maps.md`'s exit condition changes.** From *"when nothing is left to decide"* to:

> The map is done when every remaining decision is either **settled**, or **declared as a scoped increment on a build ticket**.

That is the change that lets a map complete honestly instead of stalling on questions that need code to answer.

### Why this is worth the complexity

The alternative already exists and is worse: `/implement` hits an unresolved choice and has two options, both bad — decide silently, which puts an unrecorded architectural decision inside a build commit, or hand back as `blocked`, which is heavyweight and unplanned. A declared increment is the missing third path, and it is the only one of the three where the decision gets recorded *and* the human is not ambushed.

---

## What worked, and should not be "fixed"

Listed so a refactor does not damage the parts that earned their keep.

- **The grill → options → user-chooses loop is excellent.** Three architectural forks were surfaced, each with advantages, costs, risks and maintenance impact, and the user chose all three. Every one of them changed the plan materially. The rule that Claude never silently decides architecture is doing real work.
- **The fog gate correctly refused to write a spec.** The request ("rethink all pages") genuinely was not scopeable, and being forced to produce a map instead of a confident-sounding spec was the right outcome.
- **Verification-at-use found the actual root cause.** The user asked for a faster UI; reading source rather than trusting names revealed the cost was in the router — a search that loads every contract and every payment to filter in TypeScript, because status and payment aggregates are derived at read time. That reframed the entire effort and produced ADR 0006.
- **Path-scoped rules prevented real damage.** The repository's own `frontend.md` warns that regenerating shadcn primitives silently strips i18n and RTL wiring across eighteen families. The user explicitly asked to "add any missing or updated primitives"; without that rule loaded, the obvious action would have shipped a silently English, silently LTR Arabic build. **This is the system working exactly as designed** and is the strongest argument for the whole path-scoped-rules mechanism.
- **"Never guess an API, and a CLI is an API"** caught two real traps in one session: the sub-issue `id`-vs-`number` distinction, and `-F` vs `-f` integer typing. Both would have failed silently or destructively.

---

## Suggested priority

**Two of these are structural and the rest are repairs.** Findings 1 and 9 both say the same thing from opposite ends: AEP decides where work lives by asserting rather than by checking. Finding 1 asserts that a decision belongs on the tracker without checking what the tracker means by a ticket; finding 9 asserts that a decision belongs before implementation without checking whether it can be answered before implementation exists. Fixing either one in isolation leaves the other half of the pattern in place.

1. **Fix 1** — the tracker-definition check. The only finding that produced published damage, and findings 2, 4 and 5 are downstream of it.
2. **Fix 9** — declared design increments. The largest change proposed here, and the one that removes the most waste. Land the guardrail in the same edit as the feature, never after: without it this is a scope-creep vector.
3. **Fix 3** — the GitHub lifecycle vocabulary. Currently has no correct implementation at all, so any agent working a GitHub tracker is improvising.
4. **Fix 2** — the prose/template contradiction. Trivial edit, removes a documented trap.
5. **Fix 6** — the two missing `gh` calls. Mechanical.
6. Fixes 4, 5, 7, 8 — polish, worth doing while the files are open.

Findings 4 and 5 may disappear entirely once fix 1 lands, so re-read them after rather than before.
