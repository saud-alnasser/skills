# Tenure

## Problem

mattpocock's engineering skills are an excellent **execution pipeline**: idea → grill → spec → tickets → implement → review → ship. What they have no answer for is **memory**. `CONTEXT.md` is a glossary and nothing else; every session rediscovers the repository's architecture, boundaries, and conventions from scratch. Claude arrives as a capable stranger every time.

`workflow.md` in this repo specifies a system that fixes that, but it is a design document, not an implementation — and roughly half of it re-specifies capabilities matt's skills already implement more thoroughly.

## Goal

A skill framework where Claude is a **partner whose understanding of the repository compounds over time** — not a stateless generator. Built by vendoring matt's mature primitives and adding the knowledge layer they lack.

## Decisions

Resolved by grill; each ADR in `docs/adr/` carries the reasoning.

| # | Decision | ADR |
| --- | --- | --- |
| 1 | Vendor matt's skills into this repo and alter them, rather than rewrite from scratch or invoke in place | 0001 |
| 2 | `context.md` is repo-wide orientation; `contexts/*.md` are per-domain, earned not automatic | 0002 |
| 3 | Context loading routes through a **routing table** in `context.md`, not frontmatter tags | 0002 |
| 4 | Frontmatter is load-bearing only — no per-doc `version`, no `domain`, no `tags` | 0002 |
| 5 | `contexts/` holds *knowledge*; `.claude/rules/` is reserved for path-scoped *instructions* | 0003 |
| 6 | Drift has two sources — commits since the Marker, and uncommitted human edits | 0004 |
| 7 | Verification is scoped to what the request touches; drift elsewhere is left alone | 0004 |
| 8 | Tier is chosen **after** the Grill, as `max(Floor, Gates)` — classification only ever raises rigor | — |
| 9 | **There is no `/sync`.** Context is verified where it is used and healed where the break is found; the Marker is a cache-validity check | 0010 |
| 10 | Knowledge is owned **by type**: `/design` writes vocabulary + ADRs, `/implement` writes concepts + pointers, `/configure`'s re-run prunes | 0005, 0010 |
| 11 | The Marker lives machine-local in `.claude/marker.json` — a commit cannot contain its own SHA. An instance of **Position** (39) | 0005, 0012 |
| 12 | `.claude/` holds everything; root `CLAUDE.md` is the sole entrypoint, under 200 lines | 0006 |
| 13 | **Superseded by 42.** Review shipped as `/code-review` to preserve the built-in `/review`; a plugin namespace removes the collision | 0015 |
| 14 | Tenure owns the engineering rules; the global `CLAUDE.md` is trimmed to cede them. Each rule lives where it fires — always-on rules in `CLAUDE.md`, stage rules inside the skill that enforces them, repo-discovered standards in `.claude/rules/` | 0007 |
| 15 | Instruction precedence puts `CONTRIBUTING.md` above `README.md` | 0007 |
| 16 | Tenure's conventions are **defaults**; a repository's documented conventions win. Detect before asserting | 0008 |
| 17 | The tracker tracks work only. Tickets need an observable outcome; structure comes from `part of` / `blocks`, not ticket count. Labels are reused before any is created | 0014 |
| 18 | Prototype code is always deleted; the write-up is the artifact. Research and prototype findings are **Evidence** — nothing validates them afterwards, and durable findings graduate to context or an ADR | 0009 |
| 19 | ADRs use matt's strict 3-of-3 test and light format. Draft until committed, then reasoning frozen and only `status` moves | — |
| 20 | `/design` plans and never builds. `/implement` claims a **single** unblocked ticket, builds, reviews, applies fixes, then **asks** before committing and resolving. A *not yet* keeps the ticket claimed and the loop open | — |
| 29 | **`/implement` never pushes.** Post-commit changes **amend** rather than stack fix-ups, so one ticket stays one commit — which is only safe because nothing is pushed. The Marker re-advances on every amend | — |
| 30 | `/configure` has **one job** — make repository knowledge correct and complete. Onboarding and audit are the same job at different starting states, chosen by what it finds, never by a flag | — |
| 31 | Build tickets carry `obsolete` with a reason. Without it, a ticket an earlier one made unnecessary stays open and eventually gets built | — |
| 32 | **`/implement` never redesigns.** A plan that cannot be built as written is parked — unclaimed, annotated, working tree untouched — and handed back to `/design` | — |
| 33 | Every review finding is **fixed, ticketed, or accepted-and-recorded**. Without the third, the same finding is re-raised forever and reviews become noise | — |
| 34 | **Never guess a CLI.** Workflow tools (`git`, `gh`, `glab`) are documented in a model-invoked `tools` skill; repo tools in `.claude/tools/*.md` written by `/configure`. Each entry is task-to-command, with a docs URL and the condition for fetching it | — |
| 35 | Tracker config has one home — `.claude/tracker.md`. **GitHub and local markdown are both first-class**; triage labels fold into the same file | — |
| 36 | Multi-context is **grouping directories under `contexts/`** — repo-wide domains flat, per-project domains nested. Replaces matt's `CONTEXT-MAP.md`: structure carried by the filesystem rather than a map file that drifts | — |
| 37 | **Every ticket after the first declares `Part of:` or `Blocked by:`.** An edgeless non-root ticket is a booming symptom, and this is checkable by scanning the set | — |
| 38 | `workflow.md` is **removed** once the workflow is implemented and `/configure` has run here. Its content lives in the skills; the reasoning for every departure lives in the ADRs | — |
| 26 | **`/design` always leaves at least one ticket.** Nothing important lives only in the conversation, so context can be cleared between any two steps and `/implement` always has something to read | — |
| 27 | `/design` **states its understanding** before assessing scope — a stated position, not a question, so a wrong model is corrected while that is still free | — |
| 28 | Cold requests that would **change code** get a lightweight always-on path in `CLAUDE.md`: marker check, routing, verification, stated classification. Questions get context loading only. The compounding claim does not survive being opt-in | — |
| 21 | `/code-review` keeps two axes — Spec and Standards. Reviews are never persisted | — |
| 22 | Compression has one standard: high density, structure-first. "Caveman Compression" is dropped | — |
| 23 | **A document's reasoning is frozen; only its status moves.** Applies to ADRs (`superseded by NNNN`) and specs (`implemented`, `superseded by <path>`, `abandoned`). No status means current. `/commit` marks a spec implemented; `/configure`'s audit catches the ones it never saw | — |
| 24 | Released under Apache 2.0, Copyright 2026 Saud Alnasser. Upstream is MIT, so relicensing is permitted with matt's notice preserved in `NOTICE` | 0001 |
| 25 | **`/design` is the whole planning surface** — it absorbs `to-spec`, `to-tickets`, and `wayfinder`. Deliverable formats are progressively disclosed, which also hides them from the grill | 0011 |
| 39 | Knowledge is shared and committed; **Position** is per-clone and never committed — `.claude/.gitignore` is its definition. Root `CLAUDE.md` splits: universal rules stay, Tenure's own machinery moves behind a file only its skills read | 0012 |
| 40 | **Assignment** — which human owns delivery — is human-level and lives on the tracker. The **Claim** — which instance is building now — *is the branch*, enforced by git refusing one branch in two worktrees. Contention exists only within one Assignment, and a claim another instance holds is never taken | 0013 |
| 41 | Creating an issue is **publishing**. One `/design` run creates one root issue with sub-issues beneath it; the frontier is build tickets only; the **merge** resolves the ticket, not Tenure | 0014 |
| 42 | Tenure ships as a **plugin** installed at `local` scope — personal, per-project, gitignored. Typed skills take one-word names; model-invoked skills stay expressive, because the name is how they are selected. **Supersedes 13** | 0015 |
| 43 | On a repository using stacked changes, `Blocked by` means *stacked on*, and a ticket joins the frontier once its blockers are **committed** rather than merged. The Claim's unit becomes the stack | 0016 |

## Scope

**Spine — user-invoked** (typed by the human, zero context load):
`/configure` `/design`

**Spine — model-invoked** (reachable by other skills; still typeable, since model-invocation includes user reach):
`/research` `/prototype` `/implement` `/code-review` `/commit`

`/commit` is model-invoked because `/implement` closes out through it. Typed directly, it handles work with no ticket.

Seven, not eight — `/sync` dissolved into a discipline (0010), and `/design` absorbed `to-spec`, `to-tickets`, and `wayfinder` (0011).

**On-ramps** — situations that generate work, vendored with paths rewritten:
`/triage` `/diagnosing-bugs` `/handoff` `/resolving-merge-conflicts` `/improve-codebase-architecture`

**Primitives** — model-invoked, composed by the spine:
`grilling` `tdd` `codebase-design` `domain-modeling` `tools`

**Reference:** `writing-great-skills`. **Router:** replaces `ask-matt`.

## Method — what is authoritative, what is reference

**Authoritative — what to build:** this spec, the tickets, and the ADRs in `docs/adr/`. Where any of them conflicts with matt's, they win; that conflict is usually a decision we made deliberately and recorded.

**Reference — how to build it well:** matt's skills, and `writing-great-skills` for the craft.

Each skill is **written** to fit Tenure, informed by matt's rather than copied and patched. Read the original first — it carries real learning, and starting from a blank file throws that away. But the output answers to the tickets, not to the original's structure.

Which of matt's to read for each:

| Writing | Read first |
| --- | --- |
| `/design` | `grill-with-docs`, `grilling`, `to-spec`, `to-tickets`, `wayfinder` |
| `/implement` | `implement`, `tdd` |
| `/code-review` | `code-review` |
| `/configure` | `setup-matt-pocock-skills`, `domain-modeling` |
| `/research`, `/prototype` | `research`, `prototype` |
| `/tenure` router | `ask-matt` |
| primitives | the same-named originals |
| on-ramps | the same-named originals |

The result is derivative work either way — `NOTICE` covers the attribution regardless of how much text survives.

### Alteration checklist

Applied to every vendored skill, without exception:

1. **Paths** → `.claude/context.md`, `.claude/contexts/`, `.claude/docs/decisions/`, `.claude/tickets/`. No `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, `.scratch/`.
2. **Vocabulary** → the terms in `context.md`. Context, Domain Context, Source Pointer, Marker, Evidence, Healing, Tier, Floor, Gate. Do not leave two words for one concept.
3. **Invocation axis** → per the Scope section. A skill another skill must reach is model-invoked; a skill only the human types is user-invoked.
4. **Tool commands** → reference `tools/*.md` (ticket 15) rather than inlining a guessed flag.
5. **Prune what Tenure supersedes** — a vendored skill carrying its own version of a rule Tenure now owns is duplication, and the vendored copy is the one to cut.
6. **Attribution** stays intact; `NOTICE` covers it.

## Build order

Tenure is built **using Tenure**, as early as possible. The alternative — write eighteen skills, then find out — defers every discovery to the end, which is the failure `diagnosing-bugs` refuses to accept in code and which should not be designed into the plan that builds it.

```
PHASE 1  bootstrap by hand
  01  vendor primitives
  15  tools          ← git.md first; 02 and 03 both
                       drive git, and writing those
                       commands inline then extracting
                       them later is duplication
  02  verification & healing discipline
  03  /design

PHASE 2  dogfood checkpoint  ← the point of the ordering
  run /design on ticket 07 in this repo.
  it has real drift, real contexts, nine real ADRs.
  watch for:
    does the marker check fire and report?
    does it route to the right contexts?
    does it state its understanding before scoping?
    does the tier come out sane?
  fix what breaks before writing anything else.

PHASE 3  build the rest through /design + /implement
  04 /implement   05 /code-review   06 /commit
  07 research + prototype           08 /configure
  09 on-ramps     13 rules          14 tracker
  10 router

PHASE 4  install and migrate
  11 install (+ context load count)
  12 /configure this repo
```

Phase 2 is the whole reason for the ordering. A red loop on day one beats a red loop after eighteen skills, and every skill built in phase 3 is written by a system whose failures are already known.

## Target layout in a Tenure repository

```
CLAUDE.md                     entrypoint, auto-loaded, <200 lines
.claude/
  .gitignore                  keeps the workflow self-contained
  context.md                  orientation + routing table
  contexts/
    auth.md                   repo-wide domains, flat
    database.md
    web/routing.md            per-project domains, grouped
    api/handlers.md
  tracker.md                  which tracker, how to drive it
  tools/*.md                  this repo's tooling, task→command
  docs/
    decisions/                ADRs
    designs/                  specs
    research/                 cited findings          } evidence
    prototypes/               write-ups               }
  prototypes/                 throwaway code — gitignored
  tickets/                    local planning
  skills/                     Tenure itself
  rules/                      path-scoped instructions (optional)
  marker.json             the Marker — gitignored, machine-local
```

`.claude/.gitignore` carries `marker.json` and `prototypes/`, so the workflow stays addable and removable as one directory rather than leaking entries into the repo's root ignore file.

No `reviews/` — reviews are never persisted. No `workflows/` — the skills are the command specifications.

## Acceptance criteria

- Every skill in `./skills` follows `writing-great-skills`: correct invocation axis, no duplication, checkable completion criteria, progressive disclosure where a branch earns it.
- No vendored skill still references `CONTEXT.md`, `docs/adr/`, or `.scratch/` — all rewritten to the Tenure layout.
- `/design` cannot select a Tier before the Grill has run, and its deliverable formats stay behind context pointers.
- No skill performs a startup scan; the clean path costs one `git` check.
- `/configure` is idempotent — a second run reports "already migrated" rather than duplicating.
- Running `/configure` in **this** repo migrates `CONTEXT.md`, `docs/adr/`, `docs/agents/`, and `.scratch/` into the target layout, with real content to convert.

## Out of scope

- Building this repo's own `.claude/` tree by hand. Tenure is built using matt's conventions deliberately, so `/configure` has a genuine migration to perform (see ADR 0006).
- Publishing as a plugin/marketplace. Installation is a copy into `~/.claude/skills/`.
- CI configuration. `workflow.md`'s CI section is guidance for Tenure *users*, not a deliverable here.
