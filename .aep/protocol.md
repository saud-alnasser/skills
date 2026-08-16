---
aep: 2.1.0
owner: protocol
date: 2026-08-16
kind: protocol
use-when: "at the start of every session, before doing anything else in a repository that has a .aep/ directory"
---

# AEP — the Agentic Engineering Protocol

The bootstrap. It orients you and gets out of the way. It does not govern —
governance is `[[rules]]`.

## What AEP is

A **filesystem protocol** for engineering work. Its state is plain files under
`.aep/` — no runtime, no database, no resident process. It is agent-agnostic:
whatever runtime you are, you read the same files.

**The repository is authoritative.** Every AEP artifact describes it and loses
to it.

## The primitives

| Primitive | Answers | Lives in |
| --- | --- | --- |
| **Rules** | what MUST be done | `rules/` |
| **References** | how a tool or procedure is operated here | `references/` |
| **Contexts** | what to know about an area, and where to look | `contexts/` |
| **Evidence** | what has been discovered | `efforts/<e>/evidence/` |
| **Efforts** | what change is being made | `efforts/<e>/spec.md` |
| **Tasks** | executable work derived from an effort | tickets, local or external |
| **Agents** | who performs work, in what role | `agents/` |
| **Skills** | reusable capabilities | `skills/` |
| **Modes** | how to think during an activity | `modes/` |
| **Worktrees** | isolated execution environments | `worktrees/` |
| **Position** | lightweight operational state | `position/` |

Never substitute one for another. A requirement is a rule, not a reference. An
orientation is a context, not a rule. A discovery is evidence, not a decision.

## Where state is

```
.aep/
├── protocol.md    this file
├── index.md       derived discovery index — regenerate, never edit
├── agents/  contexts/  modes/  references/  rules/  scripts/  skills/
├── templates/     skeletons for authoring a new artifact
├── efforts/<effort>/{spec.md, evidence/{research,prototypes}/, tickets/}
├── position/      per-clone, gitignored
└── worktrees/     isolated checkouts, gitignored
```

Before writing any new artifact, copy its shape from `templates/` — one
`<kind>.template.md` per artifact kind, listed in `index.md`.

## How to discover what matters

**Load by applicability, never by existence.** Never read all rules, all
contexts, or all references before starting. Each artifact declares when it
applies:

- `use-when:` — the trigger that makes it relevant
- `paths:` — the repository paths it covers
- `mode:` — the ways of working it is relevant to
- wiki links — explicit relationships from what you already loaded

```
repository state → index.md → current effort → applicable rules
→ relevant contexts → required references → relevant evidence → task → work
```

`mode:` on an artifact is applicability, not state. **Your** mode is set by the
skill you are running.

Links between AEP files are double-bracketed, relative to `.aep/`, without the
`.md` — as in `[[rules/artifacts]]`, which is one. A link that does not resolve
is repaired or reported, **never invented**.

## The workflow

```
/specify → /refine? → /plan? → /tasks → /implement → /review → /commit
```

`refine` runs when ambiguity or tradeoffs remain; `plan` when the approach is
not obvious. Everything else — `research`, `prototype`, `survey`, grill — is a
**capability, not a stage**: reach for one when uncertainty warrants it.

`index.md` lists every skill against the trigger that calls for it, and
`[[skills/help]]` answers *what do I reach for*. `[[skills/tdd]]` and
`[[skills/domain]]` are sub-skills, reached from inside another skill. A skill
may keep depth beside it in `skills/<skill>/` — read one only when that skill
sends you there.

**Pick the smallest process that produces a reliable result.** Not every change
needs research, a prototype, a grill, sub-agents, or worktrees. A one-line fix
goes `/specify → /tasks → /implement → /review → /commit`, and even that is more
than some changes deserve.

## The invariants

These hold on every turn, in every skill.

**Repository wins.** Source, config, and tests outrank every AEP artifact. Where
an artifact contradicts the repository the artifact is wrong — correct it where
you find it, in the same breath.

**Spec outranks tasks.** `spec.md` is the effort's source of truth. A task that
conflicts with it means: stop, surface the conflict, change no architecture
silently.

**Return to plan.** Evidence found during `/implement` or `/review` that
invalidates the technical plan: stop → record evidence → `/plan` → update
`spec.md` → update tasks → continue. Implementation is never a design process.

**Don't guess.** When uncertainty is material, climb only as far as it warrants:
known fact → repository inspection → existing context/evidence → research →
prototype → grill.

**Humans decide.** Never push. Never publish. Never silently choose between two
reasonable architectures — put both on the table with costs and risks, and let
the human choose. A sub-agent that reaches a decision it may not make records it
and stops; the orchestrator raises it.

**Ownership is declared.** `owner: protocol` is AEP's — installed verbatim,
replaced by upgrades, never edited here. `owner: repository` is yours — evolve it
freely; an upgrade preserves it. Variation with nowhere to enter is a **declared
deviation**: record it in a repository rule, with its reason, loudly — never by
quietly editing protocol-owned text.

**No hidden memory.** Durable knowledge is explicit — in rules, contexts,
evidence, specs, or the source. Never in session state, task descriptions,
worktree metadata, or position.

**Nothing is invented.** Where an artifact already defines protocol state, use
it. Where a script can compute an answer, run it and quote the output:
`scripts/index.mjs` regenerates `index.md`, `scripts/validate.mjs` checks the
tree, `scripts/position.mjs` reads and stamps the marker.

## Rules that load when they apply

The invariants above hold always, which is why they are here. Everything else
AEP governs is a rule you load when its trigger fires — read the `use-when:` and
decide before opening it. Your repository's own rules sit beside these.

| Load when | Rule |
| --- | --- |
| two sources disagree | `[[rules/precedence]]` |
| writing code, or claiming anything about this repository | `[[rules/engineering]]` |
| an effort is in progress | `[[rules/change-control]]` |
| you are about to guess | `[[rules/evidence]]` |
| dispatching sub-agents, or being one | `[[rules/sub-agents]]` |
| committing or branching | `[[rules/version-control]]` |
| changing anything under `.aep/` | `[[rules/ownership]]` |
| writing a `.aep/` artifact | `[[rules/artifacts]]` |
| deciding where a new file belongs | `[[rules/placement]]` |
| the work touches another repository | `[[rules/boundary]]` |
