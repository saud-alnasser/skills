---
owner: repository
status: implemented
sources:
  - .claude/evidence/research/2026-08-03-rentable-field-run.md
  - skills/configure/policies/maps.template.md
  - skills/configure/policies/tickets.template.md
  - skills/configure/policies/tracker.template.md
  - skills/configure/tools/github.md
  - skills/configure/tools/git.md
  - skills/design/SKILL.md
  - skills/implement/SKILL.md
---

# feat(skills): place work by checked facts — findings from the first external field run

## Problem

One full `/design` run on an external repository — GitHub tracker, stacked one-commit branches — produced seven decision tickets that the target's own version-control policy could not accept: a decision produces no branch, and there a ticket *is* a branch. Nothing in AEP compared its own assumption against the target's definition; the user caught it after the issues were published.

The field run surfaced eight further defects sharing one root or exposed beside it: the map template contradicts the ticket format it cites; the build lifecycle has no stated GitHub form at all, so a correct implementation is not derivable; two numbering systems coexist with no stated relationship; blocking edges silently change meaning on stacking repositories; the forge reference is missing two calls the map workflow itself requires; the design document's fate after map creation is unstated; and the Marker's path, carried by memory, produced a confident false verification report.

Beneath the two structural findings is one pattern: **AEP asserts where work lives instead of checking** — a decision belongs on the tracker (without checking what the tracker means by a ticket), and a decision belongs before implementation (without checking whether it can be answered before implementation exists).

## Goal

A map run on any configured repository produces only artifacts its tracker can accept; a build ticket can declare, at design time, the decision that only code can answer; and the lifecycle, numbering, and invocations an agent needs on GitHub are stated rather than improvised.

## Constraints

- **Single home.** Every placement decision lands in exactly one file, and the suite's duplication guards move in the same pass as every shipped change.
- **Conform or amend** (ADR 0029): the declared-increments change amends the specification's workflow section; the amendment ships with ADR 0037 at design capture, so the build tickets conform rather than diverge.
- **Ship first, adopt second** (ADR 0025): every ticket but the last changes the shipped tree; this repository's installed copies move in one closing ticket.
- **No new labels on shared trackers.** Chosen in the grill: a configured repository's label vocabulary is not extended by AEP.
- **The guardrail lands in the same edit as declared increments, never after** — without it the mechanism is a scope-creep vector.

## Architecture

**What a ticket is becomes a declared tracker fact.** The tracker policy gains one declaration — *branch-bound* (one ticket, one branch, one commit, one pull request) or *tracked intent* — written by `/configure` at detect time from the repository's version-control policy, re-checked by the audit. The maps policy stops asserting and reads it: branch-bound routes decision work into the design document, resolved in place, with only the map itself on the tracker; tracked intent keeps decision tickets as they are. The mechanical detect test lives once, in the tracker template, as the fallback for repositories configured before the field. (ADR 0035.)

**The build lifecycle rides GitHub's native issue state.** Open is open; blocked stays open with its reason in the body, where the edges already live; resolved is closed-as-completed by the merge, as already specified; obsolete is closed-as-not-planned with a mandatory reason comment. Zero new labels, nothing duplicating a native signal. (ADR 0036.)

**A build ticket may declare a design increment.** An optional section, written only at design time, names the step, the question, and the type — AFK types (`research`, `task`) the implement stage resolves inline where the fact becomes measurable; HITL types (`grilling`, `prototype`) stop the build at a point the human scheduled, holding the claim, because the plan is right and only the human is absent — which is not `blocked`. An undeclared decision discovered mid-build is still `blocked`, exactly as today. The map's exit condition relaxes to match: every decision settled *or* declared as a scoped increment. (ADR 0037, amending the specification.)

**Repairs at the single home of each fact.** The decision-ticket title rule stated as a third difference with its rationale (the commit it writes is the ADR's, usually `docs:`); ticket numbering deferred to the tracker where the tracker assigns ids; decision edges stated answer-gating always, never a stacking instruction; the design document declared superseded by the map it proposed; the Marker's path named once at the invocation home every skill already points to; the forge reference completed with pinning (its at-cap behaviour recorded as untested, not guessed) and sub-issue removal.

## Approach

Order follows the brief's priority: the tracker declaration first, because three other findings are downstream of it and their final shape depends on its text; the map-template repairs on top of it; lifecycle, forge, and Marker repairs independently in parallel; declared increments after the declaration lands, since its map exit condition and ticket placement build on the new routing; adoption last, so the migration has a before-state to prove against.

Rejected, so review does not propose them again:

- **A routing step inside the maps policy** re-deriving the branch-bound test per run — the same at-use inference the tracker policy's "read rather than inferred" rule exists to prevent, and silently wrong on an unusually phrased version-control policy.
- **Lifecycle labels** — queryable, but `/configure` would mutate every configured repository's shared vocabulary, and closed-as-not-planned exists natively regardless, leaving two homes for one state.
- **Cutting tickets at decision points** instead of declared increments — keeps the implement stage fully decision-free, but forces ticket boundaries by decision rather than by demoable slice, and turns every inline-resolvable fact into a full ticket cycle.

## Acceptance criteria

- A map run against a branch-bound tracker declaration places decision work in the design document and creates no decision issue; against tracked intent, behaviour is unchanged.
- On GitHub, all four build-lifecycle states have a stated, invocable form requiring zero new labels.
- A ticket can carry declared increments; the implement stage resolves AFK ones inline, stops at HITL ones holding the claim, and still hands back `blocked` on any undeclared decision.
- A map may exit with every remaining decision either settled or declared.
- The forge and git references cover every invocation the map workflow and the Marker check require, with untested behaviour marked untested.
- Every shipped change carries its suite assertion, and the suite passes.

## Risks

- **Increments become routine rather than exceptional**, hollowing the phase split. Detected by designs declaring increments on work whose decisions were answerable up front; the shipped text names the smell and the tier gate.
- **The declaration is mis-detected at configure time**, mechanically routing decision work to the wrong place. Detected by the audit re-reading the version-control policy; the declaration cites its source so a human can check it in one hop.
- **Blocked tickets are invisible in GitHub list views** under closure semantics. Accepted: the frontier read already parses bodies for edges, so nothing new is paid; if re-planning is observed missing blocked tickets, the hybrid (one `blocked` label) is the recorded fallback.

## Out of scope

- Re-configuring `rentable` or any already-configured repository — each heals on its next `/configure` run.
- GitLab parity for the lifecycle mapping and the two new forge calls — the shape transfers, but only the GitHub reference is in evidence; noted in the tickets policy as forge-specific.
- The triage vocabulary — untouched on both trackers.
