# Agentic Engineering Protocol (AEP) — Specification

**Version:** 2.3.0
**Status:** Normative. This document is the canonical specification of the protocol this repository builds.
**Supersedes:** AEP 1.x in full. The 1.x architecture — `.claude/` as the canonical location, policies, decisions, the stage→dependency table, the boot-tier budget — is **retired, not converted**. Where a 1.x concept survives, it survives because it earned its place again under this model, not because it existed. A 1.x repository's own knowledge does cross, by a defined carry-across (§31.1); its copy of the framework does not.

This specification is self-contained: a reader with only this file understands what AEP is, what its primitives are, how they compose, how an agent runtime consumes it, and how the protocol evolves. It is written like a language specification — it defines concepts and conformance, and everything shipped or installed is an implementation of it.

AEP 2.0 derives from two lines of prior work, acknowledged because it is true rather than because anything compels it: [GitHub's Spec Kit](https://github.com/github/spec-kit), from which the specify → plan → tasks → implement spine is taken, and [mattpocock/skills](https://github.com/mattpocock/skills), from which the composable-skill shape is taken. **What is taken from each is a shape, not text** — 2.0 vendors no code or prose from either, so no third-party licence condition attaches to it (§34). AEP depends on neither, requires neither installed, and defines itself as an extension of neither.

## How this specification evolves

The protocol and this specification move together, by rule:

1. **Every change to the protocol either conforms to this specification or amends it in the same change.** A change that does neither is drift, and drift is a defect.
2. Where the implementation and this specification disagree, that disagreement is either a defect in the implementation (fix the implementation) or an evolution this document has not caught up with (amend this document). **A human decides which.** Neither is resolved silently.
3. Amendments bump the version above, and the release stamps every protocol-owned artifact it changes (§7).

This is a different contract from the authority order that governs a repository's own knowledge (§4). Contexts describe a codebase and the codebase wins; this specification *prescribes* a protocol, so divergence is a decision point rather than an automatic loss.

---

# Part I — Foundations

## 1. Vision

AEP is an operating protocol for AI-assisted software engineering. Its purpose is not to make an agent smarter; it is to make engineering behaviour **easy to discover, difficult to violate, and cheap to understand.**

AEP is a **filesystem protocol**, not a framework. Its entire state is plain files in one directory, readable by any tool that reads Markdown, and its behaviour emerges from those files plus the applicability metadata on them — not from a runtime, a database, or a resident process.

AEP does **not** replace Git, a forge, project documentation, or any runtime's native skill system. It is the common engineering protocol underneath them.

## 2. Core principles

**Agent-agnostic.** AEP MUST NOT assume any particular agent runtime. Claude Code, Codex, Cursor, Gemini, bespoke agents, and unassisted humans are all consumers. What a runtime provides is an **adapter** (§29), never AEP itself.

**One canonical location.** All AEP state lives under `.aep/`. A runtime-specific directory — `.claude/`, `.cursor/`, `.codex/` — MUST NEVER hold canonical AEP state, and a repository MUST NEVER carry separate AEP states per agent.

**Separate primitives.** Each primitive (§3) answers exactly one question. Primitives are not merged because they are related, and one is never used as a substitute for another.

**Progressive discovery.** Knowledge is loaded because it is *applicable*, never because it exists. Every artifact declares when it applies; agents combine those declarations with the current path, effort, task, and mode to select what to read. No conforming instruction ever tells an agent to read all rules, all contexts, or all references before beginning work.

**Repository authority.** The repository is authoritative. AEP artifacts describe it and MUST NEVER contradict it; where they disagree, the repository wins and the artifact is corrected.

**Human authority.** Humans remain the source of authority. An agent under AEP NEVER pushes, NEVER publishes, and NEVER silently decides architecture — where more than one reasonable approach exists, the options go on the table with costs and risks, and the human chooses.

**No hidden memory.** AEP MUST NOT become an agent memory system. Durable knowledge is explicit in rules, contexts, evidence, efforts, specs, or the repository itself. It is NEVER hidden in session state, task descriptions, worktree metadata, or position.

**No mandatory ceremony.** The smallest process capable of producing a reliable result is the correct process. Research, prototyping, refinement, sub-agents, and worktrees are capabilities, NEVER required stages.

## 3. Primitives and terminology

AEP defines twelve primitives:

| Primitive | Answers | Lives in |
| --- | --- | --- |
| **Policies** | what MUST be done, in every repository AEP governs | `.aep/policies/` |
| **Rules** | what MUST be done **here** | `.aep/rules/` |
| **References** | how a tool or procedure is operated here | `.aep/references/` |
| **Contexts** | what to know about an area, and where to look | `.aep/contexts/` |
| **Evidence** | what has been discovered | `.aep/efforts/<effort>/evidence/` |
| **Efforts** | what change is being made | `.aep/efforts/<effort>/` |
| **Tasks** | executable work derived from an effort | tickets, local or external |
| **Agents** | who performs work, and in what role | `.aep/agents/` |
| **Skills** | reusable capabilities | `.aep/skills/` |
| **Modes** | how to think during an activity | `.aep/modes/` |
| **Worktrees** | isolated execution environments | `.aep/worktrees/` |
| **Position** | lightweight operational state | `.aep/position/` |

Conformance vocabulary:

- **MUST / MUST NOT / NEVER** mark requirements. A violation is a defect.
- **SHOULD** marks the default; departing from it requires a stated reason.
- **MAY** marks an option.
- An **artifact** is a file under `.aep/` governed by the frontmatter contract (§8).
- The **payload** is the set of protocol-owned artifacts a release installs (§30).
- An **adapter** is runtime-specific glue that exposes AEP through a runtime's native mechanism (§29).

## 4. Authority order

When sources disagree, an agent trusts, in order:

1. Explicit human instruction in this conversation
2. Source code, configuration, tests, and build scripts — **the repository**
3. Git history and external systems the repository explicitly designates authoritative
4. The effort's `spec.md`, for the change in progress
5. Policies
6. Rules
7. References
8. Contexts
9. Evidence
10. Derived indexes (§27) and position (§25)
11. Agent reasoning

Ranks 2–3 are absolute against every AEP artifact: an artifact that contradicts the repository is wrong and is corrected — never the reverse, and never explained away.

Three orderings inside this one are load-bearing and stated separately because they are the ones violated in practice:

- **The spec outranks tasks** (§22). A task that conflicts with `spec.md` is a defect in the task, and the conflict is surfaced rather than resolved by editing the architecture.
- **Policies outrank rules.** A rule MAY tighten or extend a policy; it MUST NOT soften one, contradict one, or opt out of one. A repository that must differ from a policy records a declared deviation (§7) rather than resolving the conflict in passing.
- **Governance outranks references and contexts.** A reference explains how to operate something; it NEVER grants permission to do it. A context orients; it NEVER instructs.

Conflicts within the governance hierarchy are resolved by it (§10), and conflicts the hierarchy cannot resolve are **surfaced to the human**, never resolved silently.

---

# Part II — The filesystem

## 5. Canonical layout

A conforming repository:

```
.aep/
├── protocol.md              the bootstrap — protocol-owned, cheap, stable
├── index.md                 derived discovery index (§27)
├── agents/                  agent role definitions
├── contexts/                navigational knowledge, repository-owned
├── efforts/
│   └── <effort>/
│       ├── spec.md          the durable definition of one change
│       ├── evidence/
│       │   ├── research/
│       │   └── prototypes/
│       └── tickets/         optional; local tickets only
├── modes/                   ways of working
├── policies/                governance AEP defines — protocol-owned
├── position/                per-clone operational state — gitignored
├── references/              procedural/operational knowledge
├── rules/                   governance this repository defines — repository-owned
├── scripts/                 protocol scripts
├── skills/
│   ├── <skill>.md           the skill — the whole of what it always does
│   └── <skill>/<note>.md    depth, loaded only on the branch that needs it (§16.1)
├── templates/               skeletons for authoring a new artifact
├── worktrees/               isolated checkouts — gitignored
└── .gitignore               defines what per-clone means
```

`.aep/.gitignore` MUST exclude `position/` and `worktrees/`. Everything else under `.aep/` is committed.

Additional directories MUST NOT be introduced unless this specification names them. `.aep/` MUST NOT contain a `decisions/` directory, a `tools/` directory, or a mandatory `grill/` directory — each was a 1.x concept and each is retired (§33). `policies/` is named here and is **not** the 1.x directory of that name; §33 records what changed.

## 6. The bootstrap

`.aep/protocol.md` is the single entry point. It is protocol-owned, small by design, and answers exactly six questions:

1. What is AEP?
2. What are its primitives?
3. Where is AEP state?
4. How does an agent discover what is relevant?
5. What is the workflow spine?
6. What are the invariants that hold on every turn?

`protocol.md` is **not** a second rules system, a policy database, a decision database, or a replacement for rules, contexts, or specs. It routes; it never governs. Governance is rules (§10).

`protocol.md` MUST be cheap enough to load at the start of every session. A conforming release keeps it **under 8 KB**, asserted by the verification suite (§32) — a bootstrap that costs what it saves is not a bootstrap.

**`protocol.md` also declares which release a tree is running.** Every release stamps its `aep` field, whether or not the prose moved, and it is the one artifact of which that is true (§8): the index derives the installation's version from it (§27), and an upgrade decides whether a repository is behind by reading it (§31). Left at whichever release last edited the text, a current installation would report itself as an old one and an upgrade would offer to redo work already done.

A runtime's own entrypoint — `AGENTS.md`, `CLAUDE.md`, or the runtime's equivalent — MUST point at `.aep/protocol.md` and MUST NOT restate its content. Restating it creates a second home that drifts at one of them.

## 7. Ownership

Every artifact declares an owner, and the owner is read off the declaration — never inferred from a directory.

**`owner: protocol`** — the artifact defines AEP itself. It is installed verbatim from the release, MAY be replaced or migrated by an upgrade, and MUST NOT be edited in a repository. Its `aep` field is the release it ships in — **every release stamps every protocol-owned artifact it ships**, not only the ones it changed — and an upgrade compares it. *Why the whole tree moves together: the question an upgrade asks is whether an installed artifact came from the release the tree declares, and a field carrying per-artifact provenance answers a different question at the cost of the one being asked. Provenance is what the changelog and the history are for.*

**`owner: repository`** — the artifact describes this repository. It evolves with the repository, and an upgrade MUST preserve it unless an explicit migration applies. A protocol upgrade MUST NEVER silently overwrite repository-owned governance.

Which primitives are which:

| Directory | Owner |
| --- | --- |
| `protocol.md`, `policies/`, `modes/`, `skills/`, `agents/`, `templates/`, `scripts/` | `protocol` |
| `rules/`, `contexts/`, `references/`, `efforts/` | `repository` |
| `index.md` | `repository`, and **generated** — regenerated, never hand-edited (§27) |

`policies/` and `rules/` each admit **exactly one owner**, and an implementation MUST reject an artifact declaring the other (§32). This is the one place a directory constrains ownership, and it does not weaken the rule that ownership is read off the declared field: an installer still decides what it may overwrite by reading `owner`, so a repository-owned file standing in `policies/` is **preserved and then reported**, never silently corrected. *Why constrain these two at all: the split exists so that an agent reading a directory listing can tell AEP's law from local convention. A directory that admits either owner communicates nothing, and the change would be a rename.*

### 7.1 Seeds

A **seed** is a repository-owned artifact the release ships as a **starting
point**. It is installed as `owner: repository`, written **once**, and never
reconsidered by any later run (§31).

Seeds exist because some artifacts are necessarily repository-specific — how work
lands, how a tool is invoked here — and a repository starting from nothing writes
them badly or not at all. Shipping a draft is only safe under two conditions,
both of which MUST hold:

1. **Installation is gated on evidence.** A reference for a tool installs only
   where the repository shows it uses that tool — a lockfile, a remote host, a
   configuration file. A seed with no detector installs always, and only two do:
   the version-control rule and a repository context.
2. **The draft says it is a draft.** Every seed opens by stating that it is a
   starting point to be corrected, not a description that is already true. *Why:
   a seeded command the repository does not have is worse than no reference at
   all, because it will be trusted.*

Seeds are why version control arrives as `rules/version-control.md` rather than
as a policy: how a commit references a task, whether `blocked-by` means *wait* or
*stack*, and what a branch is called are facts about a repository, not about
AEP. It is the exemplar of the rule primitive — shipped as a draft, owned by the
repository from the moment it lands, and free to diverge.

**Exactly one seed targets the repository root rather than `.aep/`: the entrypoint** (§6). The harness loads it by name, so it cannot live inside the tree. Being outside `.aep/`, it carries **no frontmatter** — it is the repository's own file from the moment it is written, and an implementation MUST NOT install it as though it were an AEP artifact. Like every seed it is written only where absent: an entrypoint that already exists may carry instructions predating AEP, and overwriting it would destroy them.

Repository variation enters a protocol-owned artifact only where that artifact names an extension point. Variation with nowhere to enter is a **declared deviation**: allowed, recorded in the repository's own rules with its reason and the release it was declared under, and reported by every `update` run until the protocol grows the point or the repository conforms. The escape hatch is load-bearing — without a loud one, fixed protocol text pressures repositories to fork silently, which is worse.

## 8. Frontmatter contract

Every Markdown artifact under `.aep/` MUST carry YAML frontmatter delimited by `---`:

```yaml
---
aep: 2.0.0
owner: protocol | repository
date: YYYY-MM-DD
kind: agent | context | spec | prototype | research | reference | policy | rule | skill | ticket | protocol | mode
mode: [specify, plan, refine, implement, research, prototype, review, test]
paths:
  - path/to/*.example.{md,txt}
status: draft | accepted | implemented | open | resolved | obsolete
blocked-by: [<ticket-id>, ...]
part-of: <effort>
use-when: "when you need to do something"
---
```

Field contract:

| Field | Required | Contract |
| --- | --- | --- |
| `aep` | **yes** | The release in which this artifact's content **last changed** — one meaning, both owners. A release that does not change a file MUST NOT restamp it, so most artifacts in a current tree legitimately declare an older release; that is the field carrying information rather than repeating `protocol.md`. A stamp **ahead** of the release being built names a release that does not exist and is illegal. **`protocol.md` is the exception** and always declares the current release (§6). |
| `owner` | **yes** | Exactly `protocol` or `repository`. No other value is legal. Under `policies/` it MUST be `protocol`; under `rules/` it MUST be `repository` (§7). |
| `date` | **yes** | The date that content last changed, as `YYYY-MM-DD`. No other format is legal. Same question as `aep`, and it MUST be maintained by the same mechanism — two fields answering one question by two mechanisms is one field that drifts. |
| `kind` | situational | One of the listed values. Omitted only where the directory makes it redundant. |
| `mode` | situational | A YAML **array** of mode names (§14). Applicability, never state. |
| `paths` | optional | Glob patterns for which repository paths make the artifact applicable. |
| `status` | situational | Required on an effort `spec.md` (`draft`/`accepted`/`implemented`) and on a local ticket (`open`/`resolved`/`obsolete`). Illegal elsewhere. |
| `blocked-by` | optional | Ticket identifiers this ticket waits on. Tickets only. |
| `part-of` | optional | The effort a ticket belongs to. Tickets only. |
| `use-when` | **required on policies, rules, references, and contexts**; optional elsewhere | One sentence describing **when to load this**. |

**`aep` and `date` MUST be computed, never typed.** An implementation that distributes a payload MUST determine, per artifact, whether its content changed since the last release, and stamp only those that did. It MUST be able to detect **an artifact whose content changed without its stamp changing** — the defect a scheme that restamps everything every release cannot see, because under it a stale stamp and a current one are the same value.

*Why this is normative rather than tooling advice: a stamp maintained by hand is a claim nobody verifies, and a field that says the same thing on every artifact distinguishes nothing. Making it computed is what turns it from ceremony into an answer.*

Three contracts are stated separately because they are the ones that fail:

**`use-when` describes a trigger, never a topic.** "Working with database schema or migrations" is a trigger. "Database documentation" is a topic, satisfies every mechanical check, and is the one failure this shape can still produce. A policy, rule, reference, or context without a real `use-when` cannot participate in progressive discovery and is therefore either loaded always or never — both defeat the mechanism.

**`mode` is applicability, not state.** `mode: [implement, review]` says *this artifact is relevant while implementing or reviewing*. It does NOT say the agent is in that mode. The agent's current mode is set by the skill it is running (§15).

An implementation MUST validate this contract and MUST reject malformed artifacts where practical (§32).

## 9. Wiki links

Within Markdown prose, a reference to another AEP artifact MUST use Obsidian-style `[[...]]` syntax, resolved relative to `.aep/`, with the `.md` extension omitted:

```
[[rules/security]]
[[references/github]]
[[contexts/authentication]]
[[efforts/authentication/spec]]
[[modes/implement]]
[[skills/implement]]
```

Links form a lightweight filesystem knowledge graph without a database. They are **relationships, not a second source of truth** — the referenced artifact remains authoritative, and a link MUST NEVER be accompanied by a summary of what it says.

Frontmatter `paths:` is a matching field and is NOT a substitute for a link. An implementation SHOULD validate that every `[[...]]` resolves, and an agent MUST NEVER invent protocol state to satisfy a broken one — a link that cannot be resolved is repaired or reported, never guessed at.

---

# Part III — Primitives

## 10. Policies and rules

Governance is two primitives, separated by **whose it is**. Both answer *what must the agent do?*; they differ in who decided, and therefore in who may change it.

- A **policy** is AEP's law. It is protocol-owned, installed verbatim, and MUST NOT be edited in a repository (§7).
- A **rule** is this repository's. It is repository-owned, evolves freely, and is preserved by every upgrade.

Governance covers constraints such as architecture, coding standards, security, testing, version control, dependency management, deployment, documentation, and repository conventions. Which layer a given constraint belongs to is decided by one question: **is this true of AEP, or true of this repository?** How a commit references a task is the repository's; that a task never splits across sub-agents is AEP's.

The hierarchy is:

```
policies  →  rules  →  effort rules  →  ticket constraints
```

A lower level MUST NOT silently violate a higher one. A rule MAY tighten or extend a policy and MUST NOT soften, contradict, or opt out of one; where a repository must genuinely differ, that is a declared deviation (§7). A conflict the hierarchy cannot resolve is **surfaced to the human**, never resolved by an agent picking a side.

Every policy and every rule MUST declare `use-when`. **Rigidity is authority, not loading**: a policy is selected by its trigger exactly as any other conditional artifact is, and no conforming instruction loads the policy set because it exists (§24). An agent discovers, determines relevance, loads what applies, and executes.

A policy or rule states a checkable imperative and carries its one-line reason. The reason is a floor, not an opening argument: a defended requirement invites re-evaluation instead of application, and an unreasoned one is misapplied at exactly the edges the reason would have caught.

Governance is NEVER procedure. "Use TDD for payment code" is governance; *how* to run the test runner is a reference (§11), and the requirement links to it.

**The shipped policy set is at most five, and is currently four.** Each loads on its own trigger rather than always:

| Policy | Absorbs | Loads when |
| --- | --- | --- |
| `authority` | precedence, boundary | two sources disagree, or the work reaches another repository |
| `engineering` | engineering, evidence | writing code, or about to state something unverified |
| `execution` | change-control, sub-agents | an effort is in progress |
| `artifacts` | artifacts, ownership, placement | creating, changing, or removing anything under `.aep/` |

The count is capped because governance is the layer least able to afford sprawl: it is what an agent must find without already knowing it is there, and a set that grows a file per concern turns every session into nine discovery decisions. The grouping is by **the moment an artifact is needed**, never by subject — which is why `evidence` sits with `engineering` rather than in a file of its own, and why an implementation MUST NOT merge two triggers whose union can only be stated as a subject area.

**A repository MUST NOT author a policy.** However non-negotiable a local constraint is, it is a rule; `policies/` holds only what AEP itself defines. *Why: the directory is the signal. The moment it can hold either owner, reading it tells an agent nothing, and the two words collapse back into one.*

**Version control is deliberately not a policy** — it ships as a seed (§7.1), because how work lands is a fact about a repository. **What holds on every turn is neither** — it lives in `protocol.md` (§6), which is the only thing loaded unconditionally. The split is by loading mechanism — always-on in the bootstrap, conditional in `policies/` and `rules/` — so no norm has two homes.

## 11. References

A reference provides **procedural and operational knowledge** — how something is operated in this repository. References replace the 1.x `tools/` concept and widen it beyond CLIs.

References may describe Git, a forge, Graphite, a package manager, Docker, a repository CLI, a deployment system, an internal command, or an infrastructure system.

A reference SHOULD state, where applicable: purpose, when to use it, prerequisites, procedure, commands or interfaces, expected output, verification, and failure handling.

**A reference is not governance.** It describes how to do a thing; it NEVER requires that the thing be done. A requirement is a rule.

**References describe *this repository's* usage, never an ecosystem in the abstract.** A reference MUST NOT be created merely to represent an engineering practice: `tdd.md` does not exist because TDD exists. If TDD is required, that is a rule, and the rule may link to repository-specific procedural material through `[[references/...]]`.

A CLI is an API. An operation no reference covers is a gap, said out loud — NEVER a guessed flag.

References declare `use-when` whenever applicability is situational, which is nearly always.

## 12. Contexts

Contexts are **navigation and orientation**, not documentation. A context answers: *what should I know about this area, and where should I look?*

A context describes concepts, architecture, vocabulary, important locations, relationships, repository areas, and relevant documentation. It points at the source of truth rather than duplicating it.

Contexts contain **facts and never instructions**. They answer *what is true and where is it found* — never *what should be done*. An instruction in a context is a rule in the wrong file.

Contexts are NOT authoritative over the repository (§4). A context contradicted by source is corrected in the same breath as the contradiction is discovered.

Every context MUST declare `use-when`, and contexts are loaded progressively. A conforming instruction NEVER requires an agent to read all contexts before beginning work.

## 13. Evidence

Evidence records what was discovered while resolving uncertainty, so that discoveries do not disappear into a conversation. There are exactly two kinds:

- **`research/`** — answers *what is true?*
- **`prototypes/`** — answers *can this work?*

Evidence is scoped to an effort and lives at `.aep/efforts/<effort>/evidence/`. There is no repository-wide evidence directory, because evidence exists to inform one change; knowledge that outlives its effort **graduates** into a context, a rule, or a reference, and the evidence file stays where it is as the record of how it was learned.

**Grill is not evidence** (§17). It is a reasoning mechanism, and its conclusions land in a spec, a rule, a context, or an evidence file.

### 13.1 Research

Research records: **question, sources, findings, conclusion.**

It MUST distinguish source, observation, interpretation, and conclusion — collapsing them is how a guess acquires a citation. Every claim carries its citation; a claim that cannot be traced to a source is reported as an open question, never rounded up to a finding. What was looked for and not found is itself a finding.

Research concludes with findings, NEVER with decisions. **Research MUST NOT silently become a rule or an architectural decision** — if a conclusion changes the design, the effort's `spec.md` is updated deliberately.

### 13.2 Prototypes

A prototype records: **hypothesis, experiment, observation, result, conclusion.**

Prototype implementation is **disposable by default**, and prototype code MUST NOT automatically become production code. Promotion into production requires an explicit decision recorded through the effort's `spec.md` — an explicitness that exists because the value of a prototype was the answer, and keeping the code silently converts a learning tool into a liability.

Prototypes MAY be used during specify, plan, or implement, whenever technical uncertainty justifies the cost.

## 14. Modes

A mode describes **how to think during an activity** — priorities and tradeoffs, not steps. A mode that gives up nothing is not a mode.

The canonical modes are exactly eight:

| Mode | Objective |
| --- | --- |
| `specify` | establish what is changing and why, before how |
| `plan` | turn a settled what into a technical approach |
| `refine` | attack a specification until ambiguity and tradeoffs are resolved |
| `implement` | build production software against an approved plan |
| `research` | establish facts from primary sources |
| `prototype` | learn quickly by building something disposable |
| `review` | evaluate work skeptically, assuming defects exist |
| `test` | establish that behaviour holds, and that its absence would be caught |

A mode file SHOULD state its objective, mindset, relevant inputs, expected outputs, constraints, and the capabilities and references it typically reaches for.

**Modes are not workflow stages.** The spine is skills (§16, §18). A mode is entered *by* a skill, an agent, or an adapter. The `mode:` field on any other artifact is an applicability signal (§8).

## 15. Efforts, specs, and tasks

### 15.1 Effort

An **effort** is the central unit of engineering change. It answers: *what change are we making?* One effort describes one coherent change, and its durable definition is `spec.md`.

```
.aep/efforts/<effort>/
├── spec.md
├── evidence/{research,prototypes}/   optional
└── tickets/                          optional, local only
```

`evidence/` and `tickets/` are optional and MUST NOT be created empty.

### 15.2 Spec

`spec.md` describes **a change**. It is NOT a task list, NOT a task execution log, and NOT merely a product requirements document.

Minimum structure:

```
# Problem
# Goal
# Scope
# Requirements
# Acceptance Criteria
# Constraints
# Out of Scope
```

Optional from the start: `# Assumptions`, `# Open Questions`, `# Risks`.

After planning, **the same file** gains: `# Architecture`, `# Components`, `# Interfaces`, `# Data Model`, `# Technical Approach`, `# Integration`, `# Migration`, `# Testing Strategy`, `# Operational Considerations`, `# Technical Risks`.

**There is no `plan.md`.** A conforming implementation MUST NOT create one. The same `spec.md` evolves from WHAT/WHY to WHAT/WHY/HOW, because a plan in a second file is a second answer to "what are we building" and the two diverge on the first surprise.

A spec declares `status:` — `draft`, `accepted`, or `implemented`.

### 15.3 Tasks

Tasks are a **map of the work** required to implement an effort. They are derived from `spec.md` and map to its requirements, acceptance criteria, and technical components.

A task MUST be independently understandable and executable, and MUST expose: scope, dependencies, acceptance criteria, relevant files or areas, and implementation constraints.

Tasks **reference** the specification rather than copying large portions of it. A task that restates the architecture becomes a second place it can change.

**Tasks are not the source of truth.** The hierarchy is `spec → tasks → implementation`. A task that conflicts with the spec means: **stop, surface the conflict, and do not silently modify the architecture.**

### 15.4 Ticketing

AEP MUST NOT require a local ticket system. Tickets may live in GitHub Issues, Jira, Linear, Plane, or any external system, and the effort references them.

If local tickets are used they live at `.aep/efforts/<effort>/tickets/`, declare `status`, and MAY declare `blocked-by` and `part-of`.

AEP MUST NOT duplicate an external ticket system for protocol completeness. A local mirror of an external ticket is exactly the hidden database §2 forbids.

**Where tasks live in an external system, that task MUST be attributable to its effort by a query the system answers natively.** Listing every open issue and judging from prose does not satisfy this. *Why: the frontier is computed from declared edges (§20.2), and an implementation that cannot ask which issues belong to an effort has no graph to read — so the prohibition on inferring independence has nothing behind it.*

Exactly one fact is required: **which effort the task belongs to.** `status` MUST NOT be carried separately, because the issue's own state already carries it and a second copy disagrees with the first as soon as the issue is closed outside the tool. A dependency edge MUST NOT be carried as set membership, because a marker that must be withdrawn when the gate clears is wrong precisely when it matters.

**A conforming implementation MUST NOT create a label for a fact the tracker already models.** Where a first-class feature of the system answers the fact — a milestone, an epic, a parent, a dependency — that feature answers it. What is native differs per system, so it is established per system and never assumed; the resolution is recorded in the repository's reference for that tool (§11) rather than rederived per session.

None of this is mirroring: the fact is held by the tracker in the tracker's own mechanism, and nothing about the task is written into `.aep/`.

## 16. Skills

Skills are reusable capabilities — the executable interface through which agents perform protocol operations. The canonical skill is `.aep/skills/<name>.md`; a runtime's copy is an adapter (§29).

Every skill MUST carry the frontmatter contract (§8). **A skill that enters a mode MUST declare it** in `mode:`, and SHOULD enter the mode matching the operation it performs — `[[skills/specify]]` enters `[[modes/specify]]`. Exactly two skills enter no mode and therefore declare none: `help`, which explains the protocol, and `handoff`, which records session state. Both are named here rather than left to judgement, so the verification suite can require a declared mode of every other skill.

**A skill MUST NOT become governance.** It operates under `[[rules]]` and consumes contexts, references, evidence, efforts, and modes. Where a skill and a rule would say the same thing, the rule is the one that exists and the skill links to it.

A skill MAY invoke another skill without collapsing their responsibilities.

The conforming skill set is exactly seventeen:

**Spine (7)** — `specify`, `refine`, `plan`, `tasks`, `implement`, `review`, `commit`
**Adaptive (3)** — `research`, `prototype`, `survey`
**Lifecycle (5)** — `install`, `update`, `prune`, `handoff`, `help`
**Sub-skills (2)** — `tdd`, `domain`

| Skill | Purpose |
| --- | --- |
| `specify` | initially specify an effort — WHAT and WHY |
| `refine` | grill a specification until ambiguity and tradeoffs resolve |
| `plan` | add technical detail to the same spec — HOW |
| `tasks` | derive executable work from the spec |
| `implement` | implement task(s), with sub-agents and worktrees where useful |
| `review` | review implementation against the effort and applicable rules |
| `commit` | commit a change that resolves task(s) |
| `research` | research a topic for an effort |
| `prototype` | prototype an idea for an effort; may be promoted explicitly |
| `survey` | survey a codebase for opportunities; produces a report that feeds `specify` |
| `install` | first-time AEP installation |
| `update` | update AEP version and structure |
| `prune` | prune stale or invalid AEP structure and files |
| `handoff` | hand off this session to another session |
| `help` | explain AEP usage and available operations |
| `tdd` | test-driven development — used by `implement` and `prototype` |
| `domain` | domain-model development — used by `specify` and `refine` |

`tdd` and `domain` are sub-skills: reached from inside another skill rather than started on their own.

### 16.1 Skill depth

A skill's own file states what it does **on every invocation**. Knowledge needed only when the run takes a particular branch lives beside it, at `.aep/skills/<skill>/<note>.md`, and is reached by an ordinary link from the skill that owns it.

The split exists because the two have different costs. The skill file is paid for on every invocation, so what is not always true does not belong in it; a branch's depth is paid for only by the run that takes the branch, so it can afford to be as long as the subject actually is. **Folding depth into the skill would tax every run for knowledge most runs do not use, and cutting it instead would lose it** — the note is the only shape that loses neither.

A note:

- **MUST carry the frontmatter contract (§8)**, with `kind: skill` and a `use-when` naming **the branch it is for**, not its topic — it is selected on exactly the terms every other conditionally-loaded artifact is;
- **MUST be reachable from its own skill**, which is what makes it a branch of that skill rather than a loose file. A note nothing links to is unreachable, and unreachable is indistinguishable from deleted;
- **MUST NOT govern** (§16) and MUST NOT restate a rule. Depth is procedure — how to do the thing well once you are doing it;
- **MAY omit `mode:`.** The skill that reaches it has already entered the mode.

A note is **not** a skill. It is not one of the seventeen, it is not invoked, and no runtime adapter (§29) exposes it — the only way in is through the skill that owns it.

**A repository MAY add its own note beside a shipped skill**, declaring `owner: repository`. Ownership is read off the field rather than the path (§7), so an upgrade preserves it exactly as it preserves any other repository-owned file. This is the extension point that keeps *this is how we prototype here* out of a protocol-owned file, and a repository-owned note is reached from a repository-owned rule or context — because the shipped skill cannot link to a file that does not exist in every installation.

## 17. Grill

Grill is structured adversarial discussion, used when uncertainty is **product ambiguity, requirement ambiguity, tradeoff ambiguity, architectural disagreement, or a missing decision** — the classes that reading code and running experiments cannot settle.

Grill is a mechanism, not an artifact type. There is **no `grill/` directory**, and a conforming implementation MUST NOT create one. Conclusions land in the spec, a rule, a context, or evidence.

Grill is delivered by `[[skills/refine]]`, and any skill MAY grill when it hits one of those uncertainty classes.

## 18. Agents

An agent definition describes a **role**: name, purpose, responsibilities, capabilities, constraints, expected inputs, and expected outputs.

Agents live at `.aep/agents/<name>.md` and carry the frontmatter contract.

**An agent MUST NOT gain authority beyond its defined role.** Two consequences hold on every runtime that supports sub-agents:

- **Human authority is never delegated downward.** A sub-agent has no surface on which to ask a human, and no agent's message is another agent's consent. A child that reaches a decision it may not make **records it and stops**; the orchestrator raises it.
- **The orchestrator is the only integrator.** A child works in isolation and returns a result; merging is the parent's.

## 19. Worktrees

Worktrees provide isolated execution environments, used for implementation, parallel implementation, experiments, prototypes, repository-modifying research, and sub-agent work.

Worktrees are **infrastructure and never knowledge storage**. Permanent knowledge returns to rules, contexts, evidence, efforts, specs, or repository source. Worktree state MUST NOT be treated as protocol state, and `.aep/worktrees/` is gitignored.

## 20. Parallelism

### 20.1 The unit is a whole task

**A task MUST NEVER be split across sub-agents.** One child builds one whole task against that task's own acceptance criteria, or no child is dispatched. There is no mechanism for dividing a single task into portions worked concurrently, and a conforming implementation MUST NOT provide one.

*Why: a task divided into portions has to be divided by something — file ownership, layer, guesswork — and none of those is a promise the task graph made. The portions must then be integrated by a parent holding partial work from several contexts, where one child failing means nothing lands at all. A whole task is the smallest unit that already has acceptance criteria, already has a branch, and already fails alone.*

A task too large for one child is **too large**: it returns to `tasks` (§15.3) and is split into real tasks with real acceptance criteria — never divided at dispatch time.

### 20.2 Independence is read, never inferred

Parallelism MUST be based on **explicit independence declared in the task graph**.

```
A → B            MUST NOT run concurrently — B declares blocked-by A

A ──┐
    ├──→ C       A and B MAY run concurrently
B ──┘
```

The set of tasks to dispatch is **computed from the declared edges, never chosen**: the frontier tasks that gate none of each other. Computing a set from a declaration is not making one, and the set is exactly what the edges permit — never widened, never reordered.

An implementation MUST NOT infer independence from a guess about which files will be touched. An edge gates work and says nothing about files; two independent tasks may still collide on one path. Where isolation cannot be guaranteed, serial execution is correct.

**The branch is the claim, and the parent creates every branch in the set before dispatching anything** — so a child claims nothing, and a claim is never made after the race it existed to win.

Sub-agents MAY receive separate worktrees. Parallelism MUST NOT compromise rules, the specification, repository integrity, or acceptance criteria.

## 21. Position

Position is lightweight operational state, per-clone and never committed. `.aep/position/marker.json`:

```json
{
  "tree": "...",
  "head": "...",
  "sessions": []
}
```

`tree` is the working-tree state the last read was made against, `head` the Git HEAD it was made against, `sessions` the active or relevant AEP sessions.

Position MAY additionally record **untracked** operational facts — state not represented by tracked artifacts. This MUST remain lightweight and MUST NOT become a hidden database (§2).

**Position is NOT** Git, architecture, memory, context, a decision record, or a source of truth. **If position conflicts with repository state, repository state wins**, and position is re-derived rather than trusted.

---

# Part IV — Operation

## 22. The workflow spine

```
/specify → /refine? → /plan? → /tasks → /implement → /review → /commit
```

`refine` and `plan` are conditional: `refine` when ambiguity or tradeoffs remain, `plan` when technical planning is needed. `research`, `prototype`, `grill`, and `survey` are **supporting capabilities, never lifecycle stages.**

| Stage | Establishes | Writes |
| --- | --- | --- |
| `specify` | WHAT and WHY | `spec.md` |
| `refine` | ambiguity resolved | the same `spec.md` |
| `plan` | HOW | the same `spec.md` |
| `tasks` | executable work | tickets, local or external |
| `implement` | working code | repository source |
| `review` | it satisfies the change | findings |
| `commit` | it lands | a commit |

**`/specify`** inspects the repository and position, loads the index, identifies applicable rules and relevant contexts, understands the request, identifies uncertainty, resolves what is material, and writes `spec.md`. Uncertainty routes by kind: factual → research, technical → prototype, requirement or product → grill.

**`/refine`** reads the spec, enters refine mode, and attacks it: ambiguous requirements, missing constraints, weak acceptance criteria, unresolved tradeoffs. It MAY repeat, and MUST NOT silently expand product scope.

**`/plan`** adds technical detail to the same spec. It MUST NOT create `plan.md` (§15.2) and MUST NOT silently expand product scope — technical discovery that exposes a product-level change **stops and surfaces it**.

**`/tasks`** converts the planned effort into executable work that derives from the spec, maps to acceptance criteria, exposes dependencies, is bounded, and does not redefine architecture.

**`/implement`** loads the task, applicable rules, relevant contexts, and required references; inspects the code; builds; uses TDD where rules require it; and verifies acceptance criteria. It stays bounded by the effort and MUST NOT silently redesign it.

**`/review`** verifies requirements, acceptance criteria, tests, architecture, applicable rules, regressions, security requirements, and documentation requirements. Where the runtime supports sub-agents, `/review` MUST use **two independent passes** — one on correctness and behaviour, one on style, standards, and governance — and MUST reconcile their findings before the effort is review-complete. Review is not *does it compile*; it is *does the implementation satisfy the defined change*.

**`/commit`** creates the repository change after successful review. An agent MUST NOT commit work that has failed review, and MUST NEVER push or publish (§2).

## 23. The return-to-plan invariant

If evidence discovered during `/implement` or `/review` invalidates the technical plan, the agent MUST NOT silently modify the architecture. Instead:

```
stop → record evidence → return to /plan → update spec.md → update tasks → continue
```

This is what keeps implementation from becoming an uncontrolled design process, and it is the invariant most often violated by an agent that is *nearly* done.

## 24. Applicability-first loading

Before reading an artifact, an agent determines whether it is relevant, combining:

- `use-when` — the trigger the artifact declares
- `paths` — the repository paths it applies to
- `mode` — the ways of working it is relevant to
- `[[...]]` links — explicit relationships from what is already loaded
- the current repository path, effort, and task

The discovery order is:

```
repository state → index → current effort → applicable rules
→ relevant contexts → required references → relevant evidence → task → work
```

A conforming instruction MUST NOT direct an agent to load all rules, all contexts, all references, all efforts, or all skills before a task.

## 25. Evidence before guessing

When uncertainty is material, an agent MUST NOT silently guess. It uses the cheapest reliable mechanism:

```
known fact → repository inspection → existing context/evidence → research → prototype → grill
```

Expensive investigation for trivial uncertainty is itself a defect: the ladder is climbed only as far as the uncertainty warrants.

## 26. Determinism

Determinism does NOT mean forcing every task through an identical process. It comes from explicit artifacts, explicit ownership, explicit applicability, explicit acceptance criteria, explicit dependencies, repository authority, and reproducible procedures.

**An agent MUST NOT invent protocol state where an artifact already defines it.** Where a script can compute an answer, the script computes it and the agent quotes the output; judgement states its inputs and its one question.

## 27. Derived indexes

`.aep/index.md` is a derived discovery index over the AEP filesystem, listing artifacts with the applicability fields an agent selects on, so that discovery does not require reading every file.

The index:

- **MUST be generated**, by `.aep/scripts/index.mjs`, and MUST NOT be hand-edited.
- **MUST be regenerable at any time**, and regeneration MUST be byte-identical for an unchanged tree.
- **MUST NOT replace the filesystem.** It is derived state; the files remain authoritative.

A generated index cannot disagree with its directory, which is the whole reason it is generated: a file added without frontmatter cannot appear in one, so the obligation to audit a hand-written index for missing rows never arises.

The index carries the fields relevance is decided on — `use-when`, `mode`, `paths`, `owner` — and **no summaries**: a summary would be a second statement of what an artifact says, and it would drift first.

**The index lists skills, not skill notes (§16.1).** A note is reached from the skill that owns it, and listing it as though it were separately invocable would advertise an entry point that does not exist.

**Where a repository keeps local tickets (§15.4), the index MUST carry a section for them**, listing each with its effort, `status`, and `blocked-by` — the fields that answer *what can be worked right now*, which is a cross-effort question. **Where there are none the section MUST be absent entirely**, rather than present and empty: a repository whose work lives in an external tracker would otherwise read as a repository with no work.

## 28. Separation of concerns

| Primitive | Is | Is not |
| --- | --- | --- |
| Policy | a requirement AEP places on every repository | a repository's own decision |
| Rule | a requirement this repository places on itself | a procedure, or a way to soften a policy |
| Reference | a procedure for performing something | a permission |
| Context | orientation and navigation | documentation, or an instruction |
| Evidence | discovered knowledge | a decision |
| Spec | the description of an intended change | a task list |
| Task | executable work derived from a spec | the source of truth |
| Skill | a reusable capability | governance |
| Agent | a defined role | unbounded authority |
| Mode | a way of working | a workflow stage |
| Worktree | an isolated execution environment | knowledge storage |
| Position | lightweight operational state | a source of truth |

A primitive MUST NOT be used as a substitute for another.

---

# Part V — Distribution

## 29. Runtime adapters

A runtime MAY expose AEP through its native mechanism — commands, skills, prompts, plugins, extensions, CLI commands, or instruction files. These are **adapters**.

An adapter MUST:

- reference `.aep/` as the source of truth,
- expose AEP operations and skills faithfully,
- preserve AEP semantics.

An adapter MUST NOT:

- become the source of truth,
- hold an independent copy of AEP state that can drift,
- define behaviour the canonical artifact does not.

Concretely, a runtime skill wrapper carries only what the runtime needs to route — its own frontmatter and a pointer — and the body it executes is the canonical `.aep/skills/<name>.md`. A wrapper that restates the skill is a second home (§6).

**An adapter wraps the seventeen skills and nothing else.** Skill notes (§16.1) are reached by link from the skill, so wrapping one would publish an entry point the protocol does not have.

Where a runtime's frontmatter schema and AEP's contract (§8) collide, the runtime's schema wins **in the adapter file only**, and AEP's fields move under whatever free-form map that runtime reserves. The canonical artifact keeps AEP's contract unchanged.

## 30. Installation

Installing AEP into a repository creates `.aep/` and the protocol-owned payload. Installation:

1. creates the canonical layout (§5) and `.aep/.gitignore`,
2. installs protocol-owned artifacts — `protocol.md`, `rules/`, `modes/`, `skills/`, `agents/`, `templates/`, `scripts/` — verbatim,
3. installs the seeds (§7.1) whose detectors match, as repository-owned starting points,
4. initializes position (§21),
5. generates the index (§27),
6. optionally installs runtime adapters (§29),
7. writes the repository's entrypoint from the entrypoint seed (§7.1) where it has none, and otherwise leaves it alone — either way it **points at** `protocol.md` and never restates it (§6),
8. **reports what was assumed on the repository's behalf** — every seed installed, so a human can correct it.

**Installation MUST preserve existing repository-owned artifacts**, and it MUST decide by each existing file's declared `owner` rather than by its path. A repository is entitled to a rule whose filename matches a shipped one, and overwriting it on the strength of the path is exactly the silent overwrite §7 forbids.

An install over an existing `.aep/` MUST refuse unless it was explicitly invoked as an upgrade (§31).

## 31. Upgrade

An upgrade:

1. identifies protocol-owned artifacts by their declared `owner`,
2. replaces them with the release's versions,
3. **preserves repository-owned artifacts**, including every seed (§7.1),
4. **never re-seeds.** A starting point the repository has since corrected is its own file; a newer release's version of it is not an improvement to be applied. Where a seed has changed materially the upgrade reports it and stops,
5. reports protocol-owned artifacts present in the repository but no longer shipped — **retired, never deleted**: deciding a file is obsolete is a human's call,
6. **applies the release's declared moves**, described below,
7. detects compatibility problems and declared deviations (§7),
8. **never silently overwrites repository-owned governance.**

**A move is not a retirement.** Where a release relocates a protocol-owned artifact, the old path is not merely unshipped — its content now lives elsewhere, and leaving the file in place would govern the repository with two copies of one text, both of which resolve. So a release **declares its moves**, as source, destination, and the release that made the move, and an upgrade:

- removes a protocol-owned artifact standing at a declared source, and reports it;
- **preserves a repository-owned artifact standing there**, reporting the collision instead — the repository wrote its own file under a name the protocol has since vacated, which is legal and is a human's to resolve;
- rewrites links to a vacated source inside **repository-owned** artifacts, and reports every file it touched. This is the one circumstance in which an upgrade writes into a repository-owned file, and it MUST be confined to the declared targets: a link is rewritten only where the source path is now vacant, only the link's target changes, no anchor is ever constructed, and a link inside a fenced block is left alone — it is syntax being shown rather than a reference being made, which is why link validation ignores it too (§9). A file so repaired has its `date` updated, because `date` is the last-modified date and nothing checks it — a repair that leaves it behind leaves a false claim about freshness in a file the repository owns. *Why the repair is made at all rather than reported: it has exactly one correct answer, and leaving it undone breaks every repository's tree on upgrade day.*

**A move MUST apply only to a tree that predates it**, compared against the release the tree declared on arrival (§6). A tree declaring nothing predates everything, since unknown is not current and the move only ever removes a protocol-owned file whose content exists at the target. *Why the bound is required rather than merely tidy: the source path is vacant afterwards, and a repository is entitled to write its own artifact there (§30). Without the bound that artifact is reported as a collision on every upgrade it ever runs.*

A declared move MAY be dropped from a release once no supported tree predates it.

**Some releases require something of the reader that no upgrade can do for them** — most often a change to a repository-owned artifact, which an upgrade correctly refuses to touch. A release therefore MAY **declare notices**, each carrying the release it applies from and one statement of what to check and why.

An upgrade MUST report exactly the notices whose release the installed tree precedes, using the **same** comparison that gates declared moves, so a notice and a move declared by one release cannot disagree about whether that release is being crossed. A tree at or past the release MUST be shown nothing. A dry run MUST preview them as a real run reports them.

A notice is an instruction, never a changelog entry, and **a release with nothing to ask of the reader declares none.** Relevance is decided by comparing two releases and MUST NOT be judged at runtime. A conforming runtime **acts** on each notice or reports it as outstanding; reporting it is not handling it.

*Why this is a declaration rather than a document: a changelog is not payload, so a repository running an upgrade has never received one, and shipping the whole history into every installation to deliver two lines is a poor trade for a filter that already exists.*

A repository declares its installed release through the `aep` field on `protocol.md`. A runtime MAY compare that against the running release and say so when they differ; a repository that declares nothing is *unknown*, never *stale*.

### 31.1 Migration from 1.x

A 1.x repository — `.claude/protocol.md`, `policies/`, `decisions/`, `designs/`, `tickets/`, and a `map.md` in every directory — cannot be upgraded, because the steps above replace files in place and 1.x has no file 2.0 replaces. It is **migrated**: 2.0 is installed fresh, and the repository's own knowledge is carried across into the shape 2.0 gives it.

Migration is defined by five rules.

**1. Everything with a 2.0 representation is converted.** Each 1.x artifact resolves to exactly one of three outcomes, and the test is *what does this file hold, and does 2.0 have somewhere to put it* — **never who owned it**:

| Outcome | When | What happens |
| --- | --- | --- |
| **converted** | 2.0 has a representation for what the file holds | it is rewritten into that shape, with every derivable field derived (rule 3) |
| **superseded** | the file *is* framework text, and this release ships the thing it was | dropped — keeping it means two copies of one governance layer, and the installed copy is the newer |
| **unrepresented** | 2.0 retired the concept and there is no target | reported and left in place (rule 2) |

**A file MUST NOT be treated as superseded merely because it declared `owner: framework`.** 1.x installed framework-owned files carrying repository content at named extension points — a declared deviation inside the protocol file, a policy derived per repository, an entrypoint describing the repository itself. That content **is** the repository's, it has a 2.0 representation, and discarding it on the strength of an owner field is the single largest way a migration can silently lose knowledge: the file it was in was framework text, and the thing inside it never was.

**2. Nothing is deleted, and nothing lands unreviewed.** The 1.x tree stays where it is until a human removes it, and every artifact is reported with its outcome and where it landed. One exception is mandatory rather than advisory: **1.x governance that a runtime auto-loads MUST NOT be left auto-loading**, because a repository running both layers at once is governed by two documents that disagree and has no way to notice. Those files are moved, not left.

**3. Every derivable field is derived; only what cannot be derived is proposed.** A conversion that asks a human to retype what the migration could compute is a conversion that will not be finished. `date` comes from the file's own history, `kind` from where it lands, `mode` from the 1.x stage it declared, `status` from the defined state mapping, and `paths` carries unchanged.

`use-when` is the exception, and the only one: 1.x selected knowledge by stage and path, so most artifacts have no trigger to convert, and a trigger is exactly the field §8 forbids an implementation to guess at. The migration proposes one from the artifact's content, **marks it unconfirmed, and lists every proposal in its report.**

**4. Where 2.0 narrowed a structure, the human chooses.** 1.x kept specifications in two places and evidence in one global directory; 2.0 has one spec per effort and evidence under the effort that produced it. Where two 1.x files map onto one 2.0 file, or where a piece of evidence names no effort, the migration **reports the collision and stops on it** rather than picking.

**5. A converted artifact satisfies this specification or it has not been converted.** The migrated tree passes the same validation any other `.aep/` does — no exemption, no grace period. A conversion that leaves an artifact failing the contract has produced a file that looks migrated and cannot participate in discovery.

The mapping itself — every 1.x directory, every field, what each becomes and what is dropped — belongs to `[[skills/update]]`, not here: it is the procedure for one release boundary, and this specification defines the shape it arrives at.

## 32. Verification

### 32.1 The distribution

Everything the protocol ships lives under one directory in the repository that builds it:

```
specs.md                  this specification — normative, never shipped
AGENTS.md                 the entrypoint, pointing at .aep/protocol.md
src/
├── protocol.md           installed as .aep/protocol.md
├── rules/ modes/ skills/ agents/ templates/   the protocol-owned payload
├── seed/                 repository-owned starting points (§7.1)
├── scripts/              the payload's scripts, plus install and verify
├── gitignore             installed as .aep/.gitignore
└── adapters/<runtime>/   runtime adapters (§29)
.aep/                     the building repository's own installation
```

**`src/` is source; `.aep/` is output.** In the repository that builds AEP, `.aep/` is produced by running the installer on `src/`, and editing it changes nothing that ships.

Two consequences are normative. **This specification is never installed** — it defines the protocol and is not part of it, which is why no shipped artifact may cite it (§32.3). And **`.aep/.gitignore` ships as a file rather than being generated by a script**, so what per-clone means is a reviewable artifact rather than a string in a program.

### 32.2 The suite

The protocol repository MUST ship a verification suite that asserts the **shipped public surfaces** — `src/skills/`, `src/agents/`, `src/scripts/`, and the rest of the distribution — against this specification. It is the fidelity floor: every mechanically checkable requirement here has an assertion, and a change that adds a checkable claim without an assertion is untested by construction.

The suite MUST also prove **its own failure path fires** before any result it reports is trusted — a check that cannot fail reads exactly like a check that passed.

The suite MUST assert at least:

- the frontmatter contract (§8) on every payload artifact — required fields present, `owner` in its two legal values, `date` well-formed, `mode` an array of legal modes, `kind` a legal value, `status` legal and only where permitted;
- `aep` on every payload artifact and seed is **exactly the release being built**, `protocol.md` included (§8). *A stamp ahead of the release names something that does not exist, and a stamp behind it makes a shipped artifact look like one an installation is missing — both break the single comparison an upgrade makes (§7).*
- `use-when` present on every policy, rule, reference, and context;
- the shipped policy set is at most five, each declaring `kind: policy`, `owner: protocol`, and a `use-when`; `rules/` ships nothing, and an install leaves it holding only repository-owned files (§10);
- every artifact under `policies/` declares `owner: protocol` and every artifact under `rules/` declares `owner: repository`, each demonstrated by a tree that fails validation (§7);
- every declared move (§31) names a destination the release ships and a source it does not;
- an upgrade from a release predating a move removes the protocol-owned source, rewrites the links that pointed at it inside repository-owned artifacts, updates the `date` of each file it repairs, preserves a repository-owned file standing at the source path, and reports all three; and an upgrade of a tree that already declares the release applies no move at all (§31);
- a dry run previews the same repairs a real run would perform — a preview that understates the change is worse than none;
- every `[[...]]` link resolves (§9);
- the skill set is exactly the seventeen of §16, each declaring a legal mode except `help` and `handoff`, which MUST declare none;
- every skill note (§16.1) sits under a directory named for a real skill, declares `kind: skill` and a `use-when`, is linked from the skill that owns it, and is wrapped by no adapter;
- the mode set is exactly the eight of §14;
- `protocol.md` exists and is within its size budget (§6);
- the forbidden structures are absent — no `decisions/`, `tools/`, `grill/`, or `plan.md` (§5, §15.2, §17);
- every seed declares `owner: repository`, targets a repository-owned directory, and states that it is a starting point — except the entrypoint seed, which targets the root and carries no frontmatter (§7.1);
- the index gains a tickets section exactly when local tickets exist, and lacks one when they do not (§27);
- every runtime adapter is **current** — regenerating it from the payload reproduces the committed files byte-for-byte — and every wrapper is a pointer rather than a copy (§29);
- an **install fixture**: installing into a temporary repository produces a tree that passes every check above, regenerating the index over it is byte-identical (§27), an upgrade preserves a repository-owned file standing where a shipped one would land, an upgrade replaces a protocol-owned file that was edited locally, and an upgrade does not re-seed a corrected starting point (§31).

Scripts MUST be JavaScript, executable by a bare Node runtime with **no dependencies and no package manifest required**, and named so that a consuming repository's `package.json` cannot change how they are parsed.

### 32.3 What shipped text may cite

**A shipped artifact may cite only what resolves where it is read.** Files under `src/` are read inside whatever repository AEP is installed in, so a citation of this specification, of a section number, or of a record that exists only in the building repository is worse than a dead link there — it is indistinguishable from a reference to something of theirs.

Where a citation was carrying a reason the surrounding prose does not state, **state the reason** rather than deleting it silently: a citation doing real work leaves a hole when it goes, and the hole is invisible because the sentence still reads well.

A link to an external project — upstream provenance, a specification, a vendor's documentation — is exempt: it resolves everywhere, and it is not navigation within the tree.

### 32.4 Scope

Verification covers what ships. It does NOT audit the protocol repository's own installed `.aep/` as though it were a shipped surface — that tree is an installation, checked by the same tools any repository uses.

## 33. What 2.0 removes

Named explicitly, because a retired concept that is merely unmentioned grows back:

| Removed | Replaced by |
| --- | --- |
| `.claude/` as canonical state | `.aep/`, with `.claude/` demoted to an adapter (§29) |
| Policies, as a repository derived them | policies as **protocol law** (§10), and rules as the repository's own |
| `decisions/` (ADRs) | the effort's `spec.md` and its evidence (§15.2) |
| `tools/` | references, widened beyond CLIs (§11) |
| The stage→dependency table | applicability metadata on each artifact (§24) |
| The boot tier and its budget | one cheap bootstrap, `protocol.md` (§6) |
| Discussions as an artifact kind | grill as a mechanism (§17) |
| Mandatory local tickets | optional local, or external (§15.4) |
| `plan.md` | the same `spec.md`, extended (§15.2) |
| Per-repository derived policies | repository-owned rules, references, contexts (§7) |

Each row is also a conversion target: where an existing repository holds the removed thing, §31.1 says what becomes of it. **Removed from the protocol does not mean discarded from a repository** — only the rows whose replacement this release *ships* are dropped, and the rest are converted or reported.

### 33.1 The policy row, reversed in 2.2

The word `policy` returned in 2.2, and it returned **inverted**. This is recorded rather than quietly restored, because a row that changes meaning without saying so is worse than one that was never written.

| | 1.x policy | 2.2 policy |
| --- | --- | --- |
| Whose | the repository's, derived per repository | AEP's, identical everywhere |
| Editable in a repository | yes, that was the point | **never** |
| Replaced by an upgrade | no | yes, verbatim |

What 2.0 retired was **a second governance layer the repository owned**, sitting beside rules the repository also owned — two homes for one kind of knowledge. That is still retired, and §33's row for it still stands.

What 2.2 introduced is the **other** distinction: 2.0's `rules/` already held two layers, protocol-owned and repository-owned, separated only by a field inside each file. Naming them apart is what the directory now does. The hierarchy in §10 is unchanged in substance — it was already `protocol rules → repository rules`.

The practical consequence is a migration hazard, not a philosophical one: **a 1.x `policies/<concern>.md` converts to a repository rule, never to a policy** (§31.1). The names collide and the meanings are opposite.

## 34. Relationship to prior work

AEP takes the **specify → plan → tasks → implement** spine from [Spec Kit](https://github.com/github/spec-kit) and the **composable skill** shape from [mattpocock/skills](https://github.com/mattpocock/skills). It improves on both in three specific ways, and the claim is narrow enough to check: applicability metadata on every artifact so knowledge loads by relevance rather than by stage; a declared ownership boundary so a protocol upgrade cannot eat repository knowledge; and evidence bound to the effort that motivated it, so investigation survives the conversation.

AEP MUST NOT depend on either, MUST NOT require either installed, and MUST NOT define itself as an extension of either. They are engineering references, not architectural dependencies.

**Nothing in AEP 2.0 is vendored.** Every shipped file was written for this protocol, so no upstream licence condition reaches it and the distribution carries no third-party notice. That is a statement about the current release, not a permanent one: **the moment text is copied in from another project, its licence binds** — the copy carries its attribution in the file, and whatever notice the licence requires ships beside it. Asserting an obligation that does not exist misstates a licence exactly as omitting a required one does, which is why this is stated in both directions.

AEP supports adapting external skills into `.aep/skills/`, and MUST NOT assume any particular skill collection. AEP provides the environment in which skills operate.

---

# Part VI — Conformance

## 35. Invariants

A conforming implementation preserves all of the following:

1. `.aep/` is the canonical AEP location.
2. AEP is agent-runtime independent.
3. Runtime adapters are not AEP state and never hold a drifting copy of it.
4. Governance is policies and rules, and nothing else governs. A policy is AEP's and is never edited in a repository; a rule is the repository's and is never overwritten by an upgrade.
5. A policy outranks a rule. A rule may tighten a policy and may never soften, contradict, or opt out of one.
6. `policies/` holds only `owner: protocol` and `rules/` only `owner: repository`; a repository never authors a policy, and a misplaced file is preserved and reported rather than silently corrected.
7. Policies are selected by their trigger like every other conditional artifact; rigidity is authority, not loading.
8. References provide procedural knowledge and never govern.
9. Contexts orient and never instruct.
10. Evidence records discoveries and never decides.
11. Efforts describe changes; the effort is the unit of change.
12. `spec.md` is independent of tasks and is the effort's source of truth.
13. Tasks derive from the specification and never redefine it.
14. Agents execute bounded work and gain no authority beyond their role.
15. Skills provide capabilities and never become governance.
16. A skill note is depth reached from its own skill: never invoked, never adapted, never governance.
17. Modes describe ways of working; `mode:` expresses applicability, not state.
18. Worktrees isolate execution and store no knowledge.
19. Position is operational state, never a source of truth.
20. Research is optional. Prototyping is optional. Refinement and grill are optional.
21. No `plan.md` exists.
22. No `decisions/` database exists.
23. No `tools/` or mandatory `grill/` directory exists.
24. No mandatory local ticketing system exists; local tickets, if used, live under the effort, and external tickets stay external.
25. Every Markdown artifact under `.aep/` satisfies the frontmatter contract (§8).
26. `owner` is exactly `protocol` or `repository`; `date` is `YYYY-MM-DD`; `mode` is an array of the eight legal modes; `kind` and `status` use only defined values.
27. `use-when` is present on every policy, rule, reference, and context, and states a trigger rather than a topic.
28. `[[...]]` is the canonical relationship syntax, and every link resolves.
29. Indexes are derived, generated, never hand-edited, and regenerable byte-identically.
30. Repository state is authoritative over every AEP artifact.
31. Context is loaded progressively; no instruction loads the whole protocol by default.
32. Evidence that invalidates the plan returns work to planning rather than silently redesigning the effort.
33. Protocol-owned artifacts are installed verbatim and never edited in a repository; variation enters through a named extension point or is a declared deviation.
34. An upgrade preserves repository-owned artifacts, decides ownership by the declared field rather than by path, and never silently overwrites repository-owned governance.
35. An upgrade applies the release's declared moves, and only to a tree that predates them: it removes a protocol-owned artifact at a vacated source, preserves and reports a repository-owned one standing there, repairs links to vacated sources inside repository-owned artifacts and updates their `date`, and reports every removal, repair, and collision (§31).
36. Migration from 1.x converts everything 2.x has a representation for — including repository content held inside framework-owned files — drops only what this release ships a replacement for, deletes nothing, derives every derivable field and proposes the one that is not, stops on a structure 2.x narrowed, and leaves a tree that validates. A 1.x policy converts to a repository rule, never to a policy.
37. Seeds install once, only where detected, and are never re-seeded; each states that it is a starting point rather than a description.
38. A task is never split across sub-agents; independence is read off declared edges, never inferred.
39. `protocol.md` is the single bootstrap, is within its size budget, and is pointed at rather than restated by every runtime entrypoint.
40. Scripts are dependency-free JavaScript runnable by a bare Node runtime, and everything that ships lives under `src/`.
41. Every mechanically checkable requirement in this specification has an assertion in the verification suite, and the suite proves its own failure path fires.
42. Shipped text cites only what resolves where it is read.
43. An agent never pushes, never publishes, and never silently decides architecture.
44. Conflicts the governance hierarchy cannot resolve are surfaced to the human, never resolved silently.
45. An external task is attributable to its effort by a query its tracker answers natively, and no label is created for a fact the tracker already models.
46. An upgrade reports the declared notices for exactly the releases it crosses, shows none to a tree already at the release, previews them in a dry run, and acts on each rather than merely printing it.
47. `aep` and `date` record when an artifact's content last changed, are computed rather than typed, and an artifact whose content changed without its stamp changing is detected.

---

*End of specification. Amendments bump the version above and stamp the artifacts they change.*
