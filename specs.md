# Agentic Engineering Protocol (AEP) — Specification

**Version:** 3.5.0
**Status:** Normative. This document is the canonical specification of the protocol this repository builds.
**Supersedes:** AEP 1.x in full. The 1.x architecture — `.claude/` as the canonical location, policies, decisions, the stage→dependency table, the boot-tier budget — is **retired, not converted**. Where a 1.x concept survives, it survives because it earned its place again under this model, not because it existed. A 1.x repository's own knowledge does cross, by a defined carry-across (§30.2); its copy of the framework does not.

This specification is self-contained: a reader with only this file understands what AEP is, what its primitives are, how they compose, how an agent runtime consumes it, and how the protocol evolves. It is written like a language specification — it defines concepts and conformance, and everything shipped or installed is an implementation of it.

AEP derives from two lines of prior work, acknowledged because it is true rather than because anything compels it: [GitHub's Spec Kit](https://github.com/github/spec-kit), from which the specify → plan → tasks → implement spine is taken, and [mattpocock/skills](https://github.com/mattpocock/skills), from which the composable-skill shape is taken. **What is taken from each is a shape, not text** — AEP vendors no code or prose from either, so no third-party licence condition attaches to it (§33). AEP depends on neither, requires neither installed, and defines itself as an extension of neither.

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

**Agent-agnostic.** AEP MUST NOT assume any particular agent runtime. Claude Code, Codex, Cursor, Gemini, bespoke agents, and unassisted humans are all consumers. What a runtime provides is an **adapter** (§28), never AEP itself.

**One canonical location.** All AEP state lives under `.aep/`. A runtime-specific directory — `.claude/`, `.cursor/`, `.codex/` — MUST NEVER hold canonical AEP state, and a repository MUST NEVER carry separate AEP states per agent.

**Separate primitives.** Each primitive (§3) answers exactly one question. Primitives are not merged because they are related, and one is never used as a substitute for another.

**Progressive discovery.** Knowledge is loaded because it is *applicable*, never because it exists. Every artifact declares when it applies; agents combine those declarations with the current path, effort, and task to select what to read. No conforming instruction ever tells an agent to read all rules, all contexts, or all references before beginning work.

**Repository authority.** The repository is authoritative. AEP artifacts describe it and MUST NEVER contradict it; where they disagree, the repository wins and the artifact is corrected.

**Human authority.** Humans remain the source of authority. An agent under AEP NEVER pushes, NEVER publishes, and NEVER silently decides architecture — where more than one reasonable approach exists, the options go on the table with costs and risks, and the human chooses.

**No hidden memory.** AEP MUST NOT become an agent memory system. Durable knowledge is explicit in rules, contexts, evidence, efforts, specs, or the repository itself. It is NEVER hidden in session state, task descriptions, worktree metadata, or position.

**No mandatory ceremony.** The smallest process capable of producing a reliable result is the correct process. Research, prototyping, refinement, sub-agents, and worktrees are capabilities, NEVER required stages.

## 3. Primitives and terminology

AEP defines seven primitives:

| Primitive | Answers | Lives in |
| --- | --- | --- |
| **Policies** | what MUST be done, in every repository AEP governs | `.aep/policies/` |
| **Rules** | what MUST be done **here** | `.aep/rules/` |
| **References** | how a tool or procedure is operated here | `.aep/references/` |
| **Contexts** | what to know about an area, and where to look | `.aep/contexts/` |
| **Efforts** | what change is being made | `.aep/efforts/<effort>/` |
| **Agents** | who performs work, and in what role | `.aep/agents/` |
| **Skills** | reusable capabilities | `.aep/skills/` |

**An effort holds its own parts rather than standing beside them.** Its `spec.md`, the `evidence/` that produced it, and its tasks as tickets under `tickets/` are the effort, not three further primitives (§14). Worktrees (§18) and the position marker (§20) are mechanisms and are specified where they are used; naming them primitives implied a reader had to learn them before starting, and neither is reached until a run needs it.

*Why the set is stated as a count: a primitive list nobody counts grows by one every time a mechanism wants status, and each addition is individually defensible. The bootstrap names the same seven, so a reader who has loaded only that file has the whole set.*

Conformance vocabulary:

- **MUST / MUST NOT / NEVER** mark requirements. A violation is a defect.
- **SHOULD** marks the default; departing from it requires a stated reason.
- **MAY** marks an option.
- An **artifact** is a file under `.aep/` governed by the frontmatter contract (§8).
- The **payload** is the set of protocol-owned artifacts a release installs (§29).
- An **adapter** is runtime-specific glue that exposes AEP through a runtime's native mechanism (§28).

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
10. Derived indexes (§26) and position (§24)
11. Agent reasoning

Ranks 2–3 are absolute against every AEP artifact: an artifact that contradicts the repository is wrong and is corrected — never the reverse, and never explained away.

Three orderings inside this one are load-bearing and stated separately because they are the ones violated in practice:

- **The spec outranks tasks** (§21). A task that conflicts with `spec.md` is a defect in the task, and the conflict is surfaced rather than resolved by editing the architecture.
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
├── index.md                 derived discovery index (§26)
├── agents/                  agent role definitions
├── contexts/                navigational knowledge, repository-owned
│   ├── <area>.md            spans the repository
│   └── <project>/<area>.md  one project of a monorepo (§12)
├── efforts/
│   └── <effort>/
│       ├── spec.md          the durable definition of one change
│       ├── plan.md          the technical approach, where one is needed
│       ├── evidence/
│       │   ├── research/
│       │   └── prototypes/
│       └── tickets/         the effort's tasks (§14.4)
├── policies/                governance AEP defines — protocol-owned
├── position/                per-working-tree operational state — gitignored
├── references/              procedural/operational knowledge
├── rules/                   governance this repository defines — repository-owned
├── scripts/                 protocol scripts
├── skills/
│   ├── <skill>.md           the skill — the whole of what it always does
│   └── <skill>/<note>.md    depth, loaded only on the branch that needs it (§15.1)
├── templates/               skeletons for authoring a new artifact
├── worktrees/               isolated checkouts — gitignored
└── .gitignore               defines what is never committed
```

`.aep/.gitignore` MUST exclude `position/` and `worktrees/`. Everything else under `.aep/` is committed.

Additional directories MUST NOT be introduced unless this specification names them. `.aep/` MUST NOT contain a `decisions/` directory, a `tools/` directory, a `grill/` directory, or a `modes/` directory — the first three were 1.x concepts and the fourth was 2.x's, and each is retired (§32). `policies/` is named here and is **not** the 1.x directory of that name; §32 records what changed.

### 5.1 An artifact outside the tree

**An AEP artifact written outside `.aep/` is a defect, and an implementation MUST report it** (§31.2). Until it does, a walk that starts at the root cannot represent the case at all: an artifact written outside is not wrong to such a walk, it is absent, and absent is indistinguishable from never having existed. A whole effort can sit at a repository root, unindexed, unvalidated, and owned by nobody, while the command that exists to judge the tree reports no failures.

Three things bound the check, and each of them is what keeps it usable:

- **Recognition is by the contract, never by the directory's name.** A repository may legitimately keep its own `templates/`, `references/`, or `contexts/`, and a check firing on those is worse than the defect it catches, because it teaches people the validator is noise and after that it catches nothing at all. A directory is a finding only where something inside it satisfies the contract this specification defines: a child effort whose `spec.md` declares a legal `status` (§8), an artifact carrying a `use-when` at a depth this layout allows for its kind, or a script byte-identical to the installed copy of the one this release ships, at the path the manifest names (§7). **Every one of those reads content.** Matching a path against the manifest reads a name, and the name is one a repository's own `scripts/index.mjs` already has, so reporting it would send its author to a protocol-owned path that the next upgrade overwrites.
- **The location is reported as found, relative to the repository root.** Every other location a validator reports is relative to `.aep/`, and a stray's whole problem is that it is not there, so a tree-relative path would name the correct location while reporting the incorrect one.
- **It reports and MUST NOT move anything.** Relocating a repository's files is a write nobody requested, and the correct destination is not always inferable.

*Why the scan stops at the repository root's immediate children rather than walking the repository: a deeper walk trades a bounded cost and a bounded false-positive surface for an exclusion list that grows once per consuming repository. It misses a stray buried under `docs/`, which is the cheaper of the two failures.*

## 6. The bootstrap

`.aep/protocol.md` is the single entry point. It is protocol-owned, small by design, and answers exactly seven questions:

1. What is AEP?
2. What are its primitives?
3. Where is AEP state?
4. How does an agent discover what is relevant?
5. What is the workflow spine?
6. **Which files are AEP's and which are the repository's?**
7. What are the invariants that hold on every turn?

The sixth is new in 3.0 and is there because nothing declares ownership on itself any more (§7). A reader learns it once, from the one file every session loads, rather than from a field on every artifact.

`protocol.md` is **not** a second rules system, a policy database, a decision database, or a replacement for rules, contexts, or specs. It routes; it never governs. Governance is rules (§10).

`protocol.md` MUST be cheap enough to load at the start of every session. A conforming release keeps it **under 8 KB**, asserted by the verification suite (§31) — a bootstrap that costs what it saves is not a bootstrap.

**`protocol.md` also declares which release a tree is running**, in a `version:` field, and it is **the only artifact that declares a release at all**. Every protocol-owned artifact is at that release by construction, because an upgrade replaces all of them together; a repository-owned artifact has no release, because the repository edits it freely and no upgrade touches it. The index derives the installation's version from this one field (§26), and an upgrade decides whether a repository is behind by reading it (§30).

*Why one field rather than one per artifact: a per-artifact stamp answers "when did this last change", and git answers that without being maintained. What the stamp was actually guarding — an artifact edited without being restamped — is caught by comparing content against the manifest (§7), which is the comparison an upgrade already makes.*

A runtime's own entrypoint — `AGENTS.md`, `CLAUDE.md`, or the runtime's equivalent — MUST point at `.aep/protocol.md` and MUST NOT restate its content. Restating it creates a second home that drifts at one of them.

## 7. Ownership

**Ownership is where a file sits.** Nothing declares it, and nothing infers it from a file's contents. The rule is a lookup, stated once in `protocol.md` (§6) and carried in machine-readable form by the payload's own contract module (§31.1):

| Directory or file | Owner |
| --- | --- |
| `protocol.md`, `policies/`, `skills/`, `agents/`, `templates/`, `scripts/` | **the protocol's** |
| `rules/`, `contexts/`, `references/`, `efforts/` | **the repository's** |
| `index.md` | the repository's, and **generated** — regenerated, never hand-edited (§26) |

**A protocol-owned artifact** defines AEP itself. It is installed verbatim from the release, MAY be replaced or migrated by an upgrade, and MUST NOT be edited in a repository.

**A repository-owned artifact** describes this repository. It evolves with the repository, and an upgrade MUST preserve it unless an explicit migration applies. A protocol upgrade MUST NEVER silently overwrite repository-owned governance.

**The directory rule is not the whole guard, because a directory is a set and a release ships a list.** A release therefore carries an **exact manifest**: every path the payload installs, generated from the payload rather than maintained beside it. Two checks rest on it, and neither is available to a declaration:

- **a file inside a protocol-owned directory that the manifest does not name fails validation by name** (§31). Under a declared field the same file simply claimed to be the repository's and was believed;
- **an upgrade establishes provenance by comparing content against the manifest**: a protocol-owned artifact that differs from what this release ships is reported (§30). This is what catches an artifact edited in place, and it is the comparison an upgrade already makes.

*Why a manifest rather than a field on each file: a declaration is a per-file claim checked against nothing, and it is trivially wrong — a file copied from `policies/` into `rules/` carries the wrong owner and is believed. The manifest is the list the installer and the upgrade already act on, so the guard and the mechanism cannot disagree.*

*What is given up: a reader opening one artifact can no longer see whose it is from the file itself. That is answered instead by the bootstrap, which every session loads and which states the rule in one table — one read for the whole tree rather than one line per file.*

`policies/` and `rules/` remain the sharpest case: `policies/` holds only what the release ships and `rules/` holds only what the repository writes, and the release ships nothing into `rules/` beyond seeds it hands over on arrival (§7.1). A repository file standing in `policies/` is **preserved and then reported**, never silently corrected. *Why constrain these two at all: the split exists so that an agent reading a directory listing can tell AEP's law from local convention. A directory that admits either owner communicates nothing, and the change would be a rename.*

### 7.1 Seeds

A **seed** is a repository-owned artifact the release ships as a **starting
point**. It lands in a repository-owned directory, is written **once**, and is
never reconsidered by any later run (§30). It is not on the manifest: the
manifest names what an upgrade replaces, and a seed is precisely what an upgrade
must not touch.

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

Repository variation enters a protocol-owned artifact only where that artifact names an extension point. Variation with nowhere to enter is a **declared deviation**: allowed, recorded in the repository's own rules with its reason and the release it was declared under, and reported by every `update` run until the protocol grows the point or the repository conforms. The mechanism rests on the concept of ownership, not on a field, and is unchanged by ownership becoming a lookup. The escape hatch is load-bearing — without a loud one, fixed protocol text pressures repositories to fork silently, which is worse.

## 8. Frontmatter contract

Every Markdown artifact under `.aep/` MUST carry YAML frontmatter delimited by `---`. **For most artifacts it is one field:**

```yaml
---
use-when: "when you need to do something"
---
```

The whole contract is four fields, and two of them are legal only on an effort's own artifacts:

| Field | Required | Contract |
| --- | --- | --- |
| `use-when` | **required on policies, rules, references, and contexts**; optional elsewhere | One sentence describing **when to load this**. Checked mechanically, below. |
| `paths` | optional | A YAML array of glob patterns for which repository paths make the artifact applicable. |
| `status` | situational | Required on an effort `spec.md` (`draft`/`accepted`/`implemented`) and on a ticket (`open`/`resolved`/`obsolete`). Illegal elsewhere. |
| `blocked-by` | optional | Ticket identifiers this ticket waits on. Tickets only. |

No other field is legal on a protocol-owned artifact, and an implementation MUST reject one that carries a retired field by name (§31). A repository's own rules and contexts were written under an older contract and an upgrade never edits them, so a retired field is **tolerated outside the manifest** and rejected on it — failing a tree for carrying exactly what AEP handed it and then refused to touch would be a defect in the check, not in the tree.

*Why the contract is this small: every field it lost was answering a question something else already answers, and a field that repeats an answer is a second copy that drifts. §32 records each one and where its answer went.*

**`paths` stays and is not the same case as the fields that went.** It is a glob, so it answers *does this apply to the file I am about to edit* exactly, where prose can only approximate. It is on two artifacts and costs nothing.

### 8.1 `use-when` is checked mechanically

`use-when` is the whole of progressive discovery (§23) resting on one field, so the field is checked rather than trusted. **Four checks, each a hard failure naming the file:**

1. **It names an occasion.** It begins with a gerund, or contains `when`, `while`, `before`, or `after`.
2. **It is not a bare noun phrase.**
3. **It does not restate the artifact's own heading**, which is how a topic gets written by accident.
4. **It is within a stated length bound**, because a `use-when` that runs to three lines is a summary rather than a trigger.

**`use-when` describes a trigger, never a topic.** "Working with database schema or migrations" is a trigger. "Database documentation" is a topic. A policy, rule, reference, or context without a real `use-when` cannot participate in progressive discovery and is therefore either loaded always or never — both defeat the mechanism.

*Why proxies rather than an honest admission: a trigger can satisfy all four checks and still name the wrong occasion, so the checks cannot be complete. They catch the common instance, which is worth more than catching none — and the admission narrows to what they do not cover rather than disappearing.*

An implementation MUST validate this contract and MUST reject malformed artifacts where practical (§31).

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

### 9.1 Filesystem paths in prose

A link is a relationship between artifacts. A path inside backticks, in an instruction to write or read a file, is not one, and the rule above does not reach it.

A filesystem path naming an AEP artifact, written in the prose of a shipped or entrypoint artifact, MUST carry the `.aep/` root where it has two segments or more. A single-segment area name — `policies/`, `efforts/` — MUST NOT carry it.

*Why the split rather than a uniform prefix: a path with a second segment is a destination somebody acts on, and one written bare is resolved against the repository root, which is how a protocol artifact comes to be created outside the tree, where §26 does not index it, §31 does not validate it, and §7 gives it no owner. A single name is a directory rather than a destination and nobody writes a file to one. A leading-slash sigil is rejected because it reads as filesystem-absolute, which is a further wrong answer than a bare path; a sentence fixing the root at the top of each file is rejected because an artifact is loaded by applicability (§23) and read from the middle.*

An implementation MUST verify this over the surfaces it ships (§31.2).

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

A lower level MUST NOT silently violate a higher one. A rule MAY tighten or extend a policy and MUST NOT soften, contradict, or opt out of one; where a repository must genuinely differ, that is a declared deviation (§7). That judgement holds against the release the rule was written under, and an upgrade rechecks it against the release being installed (§30). A conflict the hierarchy cannot resolve is **surfaced to the human**, never resolved by an agent picking a side.

Every policy and every rule MUST declare `use-when`. **Rigidity is authority, not loading**: a policy is selected by its trigger exactly as any other conditional artifact is, and no conforming instruction loads the policy set because it exists (§23). An agent discovers, determines relevance, loads what applies, and executes.

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

### 12.1 Where a context lives

A context sits at one of exactly two places:

```
contexts/<area>.md              an area that spans the repository
contexts/<project>/<area>.md    an area belonging to one project of a monorepo
```

**One project directory deep, and no more.** `contexts/<project>/<x>/<area>.md` is illegal and an implementation MUST reject it, naming the file and the legal forms. *Why bounded rather than free: a monorepo of monorepos is a shape AEP declines to model, and saying so costs one rule where not saying it costs every reader a guess about how deep the convention goes.*

The nested form exists because a monorepo has the same area in more than one project — auth in the web app and auth in the API — and a flat directory gives them one namespace to share. Without it the project has to be encoded in the filename and nothing governs how, so the convention is invented per repository and per author.

**The directory names; `paths:` scopes.** These answer different questions and neither is derived from the other:

| Mechanism | Answers |
| --- | --- |
| the `<project>/` directory | what this context is **called**, so `web/auth` and `api/auth` can both be `auth` |
| `paths:` (§8) | when this context **applies**, so it loads for work under those paths |

A nested context normally still declares `paths:`, and an implementation MUST NOT derive applicability — or anything else — from a directory name. *Why: a directory that silently scoped would make `paths:` optional in one position and required in another, and the author who assumed the first would write a context that loads everywhere.*

**`<project>` is the repository's word, not AEP's.** AEP does not define what a project is, does not require the directory to correspond to a path in the repository, and MUST NOT check that it does — monorepo layouts disagree (`apps/web`, `packages/web`, `services/web`), and a rule that guessed would be wrong in most of them.

Both shapes are legal in any repository. A flat tree is not a deficiency to migrate, and **nothing may move a context on the repository's behalf**: `contexts/` is repository-owned (§7). This bound applies to contexts alone — `rules/` and `references/` are repository-wide, so neither has a namespace two projects can collide in.

## 13. Evidence

Evidence records what was discovered while resolving uncertainty, so that discoveries do not disappear into a conversation. There are exactly two kinds:

- **`research/`** — answers *what is true?*
- **`prototypes/`** — answers *can this work?*

Evidence is scoped to an effort and lives at `.aep/efforts/<effort>/evidence/`. There is no repository-wide evidence directory, because evidence exists to inform one change; knowledge that outlives its effort **graduates** into a context, a rule, or a reference, and the evidence file stays where it is as the record of how it was learned.

**Grill is not evidence** (§16). It is a reasoning mechanism, and its conclusions land in a spec, a rule, a context, or an evidence file.

### 13.1 Research

Research records: **question, sources, findings, conclusion.**

It MUST distinguish source, observation, interpretation, and conclusion — collapsing them is how a guess acquires a citation. Every claim carries its citation; a claim that cannot be traced to a source is reported as an open question, never rounded up to a finding. What was looked for and not found is itself a finding.

Research concludes with findings, NEVER with decisions. **Research MUST NOT silently become a rule or an architectural decision** — if a conclusion changes the design, the effort's `spec.md` is updated deliberately.

### 13.2 Prototypes

A prototype records: **hypothesis, experiment, observation, result, conclusion.**

Prototype implementation is **disposable by default**, and prototype code MUST NOT automatically become production code. Promotion into production requires an explicit decision recorded through the effort's `spec.md` — an explicitness that exists because the value of a prototype was the answer, and keeping the code silently converts a learning tool into a liability.

Prototypes MAY be used during specify, plan, or implement, whenever technical uncertainty justifies the cost.

## 14. Efforts, specs, and tasks

### 14.1 Effort

An **effort** is the central unit of engineering change. It answers: *what change are we making?* One effort describes one coherent change, and its durable definition is `spec.md`.

```
.aep/efforts/<effort>/
├── spec.md
├── plan.md                           where the approach is not obvious
├── evidence/{research,prototypes}/   optional
└── tickets/                          the effort's tasks
```

`plan.md`, `evidence/`, and `tickets/` MUST NOT be created empty.

**An effort is opened once, and the same way whatever its size**: the tracker issue is created from `spec.md`, the directory is renamed from its `xxxx-<slug>` placeholder to `<number>-<slug>` **before the first commit** so the rename never enters history, a branch is created, the artifacts land as one `docs` commit, and a **draft** pull request is opened. A one-line fix and a fifteen-ticket feature produce the same three objects; only `plan.md` differs, and it is absent on the small one.

**Opening publishes, so it is the one moment an implementation asks.** It proposes the whole set with exact strings, and a refusal leaves the effort local and unopened rather than sliding to whatever the agent is permitted to do unasked (§2).

### 14.2 Spec

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

**`spec.md` holds no HOW.** The technical approach lives beside it in **`plan.md`**: `# Architecture`, `# Components`, `# Interfaces`, `# Data Model`, `# Technical Approach`, `# Integration`, `# Migration`, `# Testing Strategy`, `# Operational Considerations`, `# Technical Risks`.

*Why two files rather than one that grows: the spec is the issue body, read by everyone who touches the effort, and the plan is read by whoever builds it. Folding the approach into the spec made every reader of the change pay for the design, and it made the one artifact a human approves change shape halfway through. The risk two files carry — a second answer to "what are we building" — is answered by the hierarchy: `spec.md` is the source of truth, `plan.md` serves it, and a plan that cannot satisfy a requirement stops on the return-to-plan invariant (§22) rather than quietly restating the requirement.*

**A plan is written where the approach is not obvious, and skipped where it is.** An effort with no `plan.md` is not an incomplete effort.

A spec declares `status:` — `draft`, `accepted`, or `implemented`.

### 14.3 Tasks

Tasks are a **map of the work** required to implement an effort. They are derived from `spec.md` and map to its requirements, acceptance criteria, and technical components.

A task MUST be independently understandable and executable, and MUST expose: scope, dependencies, acceptance criteria, relevant files or areas, and implementation constraints.

Tasks **reference** the specification rather than copying large portions of it. A task that restates the architecture becomes a second place it can change.

**Tasks are not the source of truth.** The hierarchy is `spec → tasks → implementation`. A task that conflicts with the spec means: **stop, surface the conflict, and do not silently modify the architecture.**

### 14.4 Ticketing

**An effort's tasks are files in this repository**, at `.aep/efforts/<effort>/tickets/`. A ticket declares `status` and MAY declare `blocked-by`, and nothing else: the effort it belongs to is the directory it sits in.

**A ticket is never an object in a tracker**, and the dependency graph never leaves the repository. *Why: the graph is read on every scheduling pass (§19.2), and a graph held in a tracker has to be fetched, paginated, and interpreted before a frontier can be computed. Local, it is a field a script reads. The tracker gains nothing by holding it, because nobody schedules by hand.*

**Exactly two tracker objects exist per effort** — one issue, whose body is `spec.md`, and one pull request, carrying the approach, the tickets, and the run's memory. An implementation MUST NOT create a third, per ticket or otherwise. *Why one issue rather than one per ticket: an effort is what a human agreed to, and it is the unit they review and merge. Fifteen issues for one change is fifteen things to close and one thing nobody can see the shape of.*

**Where the repository has a tracker, both objects are REQUIRED**, and each MUST link to the effort in both directions: the effort directory is named for the issue number, and both bodies name the effort's path. An implementation finding a tracker and an effort short of either object MUST open what is missing and report it. *Why this is stated rather than implied: having no tracker is a posture with its own procedure below, and an implied requirement makes that posture reachable by not asking — an implementation that never looked lands in the smaller shape with nothing to contradict it.*

**Where the repository has no tracker, the effort is a branch and merging it is the human's.** No issue, no pull request, and no tracker call is made. The effort's number comes from a local counter (§14.1), and the run's durable record is the repository: the commits on the effort branch say which tasks landed, the ticked criteria in the ticket files say what is verified, and `spec.md`'s `status` says whether the effort closed. The close is the close of §21 with its tracker half absent — `spec.md` is stamped `implemented` and the run stops, there being no draft to mark ready and no label to move. **A conforming implementation MUST NOT merge**, with a tracker or without.

*Why the absence needs a procedure of its own: every step that closes an effort is written against a pull request, so a repository without one loses not a projection but the run's memory. It has one only because tasks are files here — the ticks are already in the repository, and the pull request was projecting them rather than storing them.*

**The tracker is read and never mirrored into `.aep/`.** A local copy of a tracker object is exactly the hidden database §2 forbids, and it disagrees with the original the moment one is written and the other is not. The direction that is permitted is the reverse: a label projects what a file says, and the file wins when they disagree.

**A conforming implementation MUST NOT create a label for a fact the tracker already models.** Where a first-class feature answers the fact — a milestone, an epic, a parent, a dependency — that feature answers it. What is native differs per system, so it is established per system and never assumed; the resolution is recorded in the repository's reference for that tool (§11) rather than rederived per session.

**The one exception is the terminal value of a `status:` family AEP maintains.** Merged and closed are modelled natively by every forge, and the terminal value is kept anyway, for two reasons that are about the family rather than about the fact: a family with a hole in it cannot be filtered on, so a list scoped to `status:` would silently omit every effort that ever finished; and the value is a projection of the effort's own state rather than a second copy of the forge's, so it is written from the file the effort lives in and corrected against that file whenever the two disagree. *This narrows the prohibition rather than lifting it: outside a family AEP maintains, a label for a natively modelled fact stays forbidden, and nothing here licenses a second label standing beside a native feature.*

## 15. Skills

Skills are reusable capabilities — the executable interface through which agents perform protocol operations. The canonical skill is `.aep/skills/<name>.md`; a runtime's copy is an adapter (§28).

**A skill's frontmatter is `use-when` and nothing else** (§8). The working posture a skill takes — what it optimises for, and **what it gives up** — is stated in the skill's own text, where the agent running it reads it, rather than named by a field pointing at a separate artifact. A posture that gives up nothing is not a posture, and a skill that states none has not thought about the question.

**A skill MUST NOT become governance.** It operates under `[[rules]]` and consumes contexts, references, evidence, efforts, and modes. Where a skill and a rule would say the same thing, the rule is the one that exists and the skill links to it.

A skill MAY invoke another skill without collapsing their responsibilities.

The conforming skill set is exactly seventeen:

**Spine (6)** — `specify`, `refine`, `plan`, `tasks`, `implement`, `review`
**Adaptive (3)** — `research`, `prototype`, `survey`
**Lifecycle (5)** — `install`, `update`, `prune`, `handoff`, `help`
**Sub-skills (3)** — `tdd`, `domain`, `prose`

**Four of them are commands a human types** — `specify`, `plan`, `tasks`, `implement` — and the rest are reached from inside a run. `refine`, `research`, and `review` are **stages**: a skill runs one where its own procedure calls for it, inside the same invocation, and opens no report of its own (§15.2). `prototype`, `survey`, and `prune` are capabilities, reached when uncertainty or the codebase warrants one.

*Why the distinction is normative rather than a matter of taste: a stage a human has to type is an interruption at the point where the run knows most and the human knows least. The whole spine exists to move the human's attention to the idea and off the execution.*

| Skill | Purpose |
| --- | --- |
| `specify` | initially specify an effort — WHAT and WHY |
| `refine` | grill a specification until ambiguity and tradeoffs resolve |
| `plan` | establish the technical approach beside the spec — HOW |
| `tasks` | derive executable work from the spec |
| `implement` | implement task(s), with sub-agents and worktrees where useful |
| `review` | review implementation against the effort and applicable rules |
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
| `prose` | make a text read as though a person wrote it — used wherever an agent writes for a human |

`tdd`, `domain`, and `prose` are sub-skills: reached from inside another skill rather than started on their own.

### 15.1 Skill depth

A skill's own file states what it does **on every invocation**. Knowledge needed only when the run takes a particular branch lives beside it, at `.aep/skills/<skill>/<note>.md`, and is reached by an ordinary link from the skill that owns it.

The split exists because the two have different costs. The skill file is paid for on every invocation, so what is not always true does not belong in it; a branch's depth is paid for only by the run that takes the branch, so it can afford to be as long as the subject actually is. **Folding depth into the skill would tax every run for knowledge most runs do not use, and cutting it instead would lose it** — the note is the only shape that loses neither.

A note:

- **MUST carry the frontmatter contract (§8)**, with a `use-when` naming **the branch it is for**, not its topic — it is selected on exactly the terms every other conditionally-loaded artifact is;
- **MUST be reachable from its own skill**, which is what makes it a branch of that skill rather than a loose file. A note nothing links to is unreachable, and unreachable is indistinguishable from deleted;
- **MUST NOT govern** (§15) and MUST NOT restate a rule. Depth is procedure — how to do the thing well once you are doing it.

A note is **not** a skill. It is not one of the seventeen, it is not invoked, and no runtime adapter (§28) exposes it — the only way in is through the skill that owns it.

**A repository MAY add its own note beside a shipped skill.** Ownership is a lookup on the path (§7), and a note the release does not ship is not on the manifest, so an upgrade preserves it exactly as it preserves any other repository-owned file. This is the extension point that keeps *this is how we prototype here* out of a protocol-owned file, and a repository-owned note is reached from a repository-owned rule or context — because the shipped skill cannot link to a file that does not exist in every installation.

### 15.2 What the human reads

Everything an agent writes for a human is governed here. **Who reads a text decides whether it is governed: a human reads it, it is governed; a protocol agent reads it, it is exempt** — and exempt means written *for that reader* instead, never written carelessly. Session output, a commit message, a pull request title or body, a comment or docstring in source, what a script prints to a person, and a repository's own documentation are governed. Prose inside `.aep/` artifacts, a brief written for a sub-agent, and data a script writes into an artifact an agent reads are not.

**Normative protocol text is exempt wherever it lives, including a repository root.** It is `.aep/` prose that happens to sit elsewhere, its reader is the agent building against it, and it is where the vocabulary is defined that a catalogue of tells would otherwise flag. This document is one.

**How a governed text reads** is fixed for all of it and stated in exactly one shipped artifact, which also carries the prohibitions a script can check. **What shape it takes** is fixed for the turn report, which the rest of this section defines.

Every turn reports, in one shape, whichever skill is running. **The unit is the turn, not the skill entry:** one thing the human asked for produces exactly one opening report and one closing block, emitted by the outermost skill. A skill entered from inside another — `review` from `implement`'s close-out, `refine` or `research` from `specify`, or any sub-skill — is a stage of that run and opens no report of its own.

The opening report carries four slots in order — **standing**, the state the skill establishes on entry, verified; **classification and routing**, what the request was judged to be and which skill is therefore running; **assumptions in force**, held apart from what was checked; and **the stages ahead**. The closing block carries three — **state**, **next**, and **what is unsettled together with how to settle it** — and a turn that stops early carries them too, because that is where the third is worth the most.

**A slot with nothing in it says so.** It is never omitted: silence is indistinguishable from a check that never ran, and an omissible slot destroys reading by position, which is the whole benefit.

**The standing slot is filled with what the skill already verifies, never with a new check.** Most skills read no position, and requiring one of them would buy uniformity with a behavioural change nobody asked for. A skill with nothing to verify states that it has nothing to verify.

**There is one form, and every turn takes it.** No field selects a shape, because a field that has to be read before the shape is known is a field answering a question the contract can answer for every turn at once. A skill lists its stages and marks each as it is crossed.

**Stage names are read from the skill's own procedure and MUST NOT be declared separately** — a second list of stages is a second statement of what the procedure already says, and the two diverge on the first edit to either. An implementation MUST be able to extract them mechanically from every full-form skill, and a skill whose procedure yields none is a failure rather than an exemption: a rule that skips what it cannot handle passes by not looking.

The contract governs **what is stated and in what order**. It MUST NOT assume a runtime, a rendering, or any presentation one agent can produce and another cannot. It is distinct from the sub-agent return contract (§19), which is not human-facing and is unaffected.

## 16. Grill

Grill is structured adversarial discussion, used when uncertainty is **product ambiguity, requirement ambiguity, tradeoff ambiguity, architectural disagreement, or a missing decision** — the classes that reading code and running experiments cannot settle.

Grill is a mechanism, not an artifact type. There is **no `grill/` directory**, and a conforming implementation MUST NOT create one. Conclusions land in the spec, a rule, a context, or evidence.

Grill is delivered by `[[skills/refine]]`, and any skill MAY grill when it hits one of those uncertainty classes.

## 17. Agents

An agent definition describes a **role**: name, purpose, responsibilities, capabilities, constraints, expected inputs, and expected outputs.

Agents live at `.aep/agents/<name>.md` and carry the frontmatter contract.

**An agent MUST NOT gain authority beyond its defined role.** Two consequences hold on every runtime that supports sub-agents:

- **Human authority is never delegated downward.** A sub-agent has no surface on which to ask a human, and no agent's message is another agent's consent. A child that reaches a decision it may not make **records it and stops**; the orchestrator raises it.
- **The orchestrator is the only integrator.** A child works in isolation and returns a result; merging is the parent's.

## 18. Worktrees

Worktrees provide isolated execution environments, used for implementation, parallel implementation, experiments, prototypes, repository-modifying research, and sub-agent work.

Worktrees are **infrastructure and never knowledge storage**. Permanent knowledge returns to rules, contexts, evidence, efforts, specs, or repository source. Worktree state MUST NOT be treated as protocol state, and `.aep/worktrees/` is gitignored.

### 18.1 The isolation in force is detected, never required

A runtime MAY place each of its threads in a worktree of its own, and some do. **A conforming implementation MUST NOT require worktrees, and MUST NOT create, name, or remove one the runtime owns.** It detects what is in force and reports it: a linked worktree is distinguished from a main checkout by `git rev-parse --git-dir` differing from `--git-common-dir`, and the sibling worktrees with the branch each holds are read from `git worktree list --porcelain`. AEP's own `.aep/worktrees/`, above, is unaffected by this — the orchestrator creates those for sub-agent isolation and removes them with it.

What the detection establishes is the **strength of the claim** (§19.2), and a run MUST report which of the two it has. Inside one clone, git refuses a second worktree on a branch already checked out and the refusal names where the claim is held, so the claim is **enforced**. Across clones nothing refuses anything, so the claim is **advisory**, and a run whose checkout is not isolated says so rather than implying a guarantee nothing performs.

*Why detected rather than required: a worktree per thread is the runtime's choice, and AEP under a runtime that provides none MUST behave identically apart from the strength of the claim it reports. Requiring them would make the protocol unrunnable where they are not on offer, and assuming them would have every run report an enforcement that, between two clones, does not exist.*

### 18.2 A run holds the surface it writes through

Detection above establishes what is in force. **What a run does about it is fixed by the isolation's kind, and never by its enforcement.**

A run whose checkout is already a linked worktree holds a surface of its own, and MUST NOT take a second. A run whose checkout is **not** isolated MUST take a worktree of AEP's own, under `.aep/worktrees/`, and **create its effort branch into it before its first write** (§19.2). Creating the branch and the worktree in one act is what leaves no window in which the branch exists unheld.

*Why the kind and not the enforcement: enforcement answers whether a claim inside this clone can be taken twice, which is a fact about the clone rather than about this checkout. A run keying on it would decline to take a surface in precisely the case that most needs one — a main checkout two agents are sharing, where the presence of other worktrees elsewhere already reads as enforced.*

**A surface MUST be removed and not merely released**, and the removal is performed from outside that directory, because a process cannot remove the one it stands in. **A run removes only its own surface**: a directory a stopped run kept deliberately and one an abandoned run left behind are indistinguishable from outside, so nothing reaps another run's. *Why this is normative rather than housekeeping: leaving surfaces behind is the observed steady state of worktree-per-run implementations, at gigabytes each, and a guard that fills a disk is one somebody turns off.*

**Releasing the claim and removing the surface are separate acts.** A run releases its effort branch by detaching the worktree holding it, which frees the branch at once, and removes the directory separately. A surface kept after a failure therefore holds no branch, and a run that died cannot lock an effort against its own resumption.

**The exclusion is git's, and it stops at the porcelain.** Git refuses a second worktree on a held branch, refuses a checkout switching to it, and refuses `git branch -f` against it. It does not refuse `git update-ref`, and it reaches no further than the clone. A conforming implementation MUST NOT describe the surface as though either hole were closed.

### 18.3 The surface a run stands in, and the role it carries

§18.1 detects what isolation is in force, and §18.2 fixes what a run does about it. Neither answers **which** surface a run is standing in, and that is the question the rules binding it turn on: an orchestrator holding an effort and a child building one of its tickets report the same claim, the same isolation and the same marker state, while being bound by opposite rules.

**A conforming implementation MUST compute, from Git and the path of the tree it is standing in, which surface that is and what role the surface carries**, and MUST report both wherever it reports the isolation. Every surface kind, and the role each carries:

| The tree is | Surface | Role |
| --- | --- | --- |
| the main checkout | `main` | `none` |
| `.aep/worktrees/<effort>/_run` | `run` | `orchestrator` |
| `.aep/worktrees/<effort>/<name not starting with an underscore>` | `ticket` | `implementer` |
| a linked worktree outside `.aep/worktrees/` | `runtime` | `orchestrator` |
| anything else | `unknown` | `unknown` |

A **leading underscore is reserved**, and it is the whole of the discriminator. `_run` is the directory a run creates its effort branch into (§18.2); any other underscored name is a surface AEP made for something that is not a ticket, a prototype among them, and resolves to `unknown` so that nothing keyed on the role fires at it. Every sibling whose name does not start with an underscore is a ticket surface, and no ticket name has to be matched. The derivation reads the path and never the branch name, because what a branch is called belongs to the repository and, under a runtime that generates one per thread, to the runtime (§19.3).

Because the path decides the role, **a conforming implementation MUST create every surface it makes under the main checkout's `.aep/worktrees/`**, resolved from there rather than from the directory the creating run happens to stand in. A surface created relative to a run's own surface nests inside it and resolves to `unknown`; one created outside `.aep/worktrees/` altogether resolves to `runtime`, whose occupant is an orchestrator, and a child placed there would compute permissions it must not have. *Why this is normative rather than an implementation detail: the derivation is sound only if the paths it reads are the ones AEP said it would create, so the anchor is part of the contract rather than a convenience.*

A `runtime` surface carries `orchestrator` because a run handed one takes no second (§18.2), so nothing put it there on some other run's behalf. `main` carries **no** role rather than a missing one: it is the state of a run that has not yet taken a surface, which is exactly the condition §18.2 requires it to act on before its first write.

**The comparison MUST be built from Git's own output** — the current tree from `git rev-parse --show-toplevel`, the main checkout from the first entry of `git worktree list --porcelain`, which Git lists first — and never resolved against the process's working directory. One path spelled two ways reconciles against nothing while reading as though it worked.

**The table is total, and an unresolved surface refuses nothing.** Where the path matches no row above, both the surface and the role are `unknown`, every rule keyed on the role declines to fire, and the run proceeds as it would have. *Why it fails open, as detection does above: the worst outcome of a wrong answer that narrows is correct work blocked in a tree that plainly has a role, and a run has no way to tell that refusal from a real one.*

**What is computed here refuses nothing by itself.** A conforming implementation reports the surface and the role, and MUST NOT exit differently on account of either. What a run *does* about the role — a run holding `implementer` neither integrating nor dispatching, a run holding `orchestrator` integrating only in the surface it holds (§19.2) — is stated by the rules that bind that role, exactly as §18.2 states what a run does about the isolation §18.1 reports. *Why the split: a detection that refuses is one a run must be able to route around when the derivation is wrong, and a documented route around a guard is not a guard.*

## 19. Parallelism

### 19.1 The unit is a whole task

**A task MUST NEVER be split across sub-agents.** One child builds one whole task against that task's own acceptance criteria, or no child is dispatched. There is no mechanism for dividing a single task into portions worked concurrently, and a conforming implementation MUST NOT provide one.

*Why: a task divided into portions has to be divided by something — file ownership, layer, guesswork — and none of those is a promise the task graph made. The portions must then be integrated by a parent holding partial work from several contexts, where one child failing means nothing lands at all. A whole task is the smallest unit that already has acceptance criteria, already has a branch, and already fails alone.*

A task too large for one child is **too large**: it returns to `tasks` (§14.3) and is split into real tasks with real acceptance criteria — never divided at dispatch time.

### 19.2 Independence is read, never inferred

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

**A run claims the working surface it writes through as well as the branch it is on**, and a worktree is how it holds one (§18.2). The two are not one guarantee: a branch names what a run owns, and a worktree is what stops a second run from writing through the same tree. An implementation with the first and not the second identifies its work correctly and can still have another run move the checkout under it between a read and a write. **The orchestrator integrates in the surface it holds**, never in a checkout another run can move.

Sub-agents MAY receive separate worktrees. Parallelism MUST NOT compromise rules, the specification, repository integrity, or acceptance criteria.

### 19.3 Scope: the claim, and the working set

**An invocation that acts on an effort MUST establish which efforts it is inside before it acts.** The answer is **computed and quoted, never judged** — derived from the branch and reported as read — and a conforming instruction MUST NOT direct an agent to infer it from a branch name in prose. What a branch is called belongs to the repository (§7.1) and, under a runtime that generates one per thread, to the runtime, so the name is the one signal that may say nothing.

Two questions sit behind the answer, and holding them apart is what this subsection is for:

| | Is |
| --- | --- |
| **the claim** | the set of efforts whose directories the branch's **own commits** touch, measured against the default branch |
| **the working set** | the set of efforts the tree is touching **now** — staged, unstaged, or untracked |

**Confinement is the working set measured against the claim.** A scoped run MUST NOT write a file belonging to an effort outside its claim, and MUST NOT take a ticket of one. Reading is unrestricted, and source outside the efforts is untouched by the rule, since changing it is what an effort exists to do.

*Why the claim is read from the commits and never from the tree: a scope computed from the working tree can never fire a guard, because the first illegal write enlarges the scope that was supposed to catch it. Read from the commits, the claim is a fact the run cannot edit by misbehaving.*

**A claim is a set, usually of one.** An **empty claim is unscoped and permits any effort**: it is the ordinary state of the default branch, and of a branch carrying no commits of its own, which is the state an effort is opened in — the first commit fixes the claim for every turn after it. A claim of more than one is what a branch carrying a chain of efforts holds, and is not by itself an error.

**A run that must act on a single effort, holding a claim of more than one and given none to act on, MUST end the turn listing the set rather than choose from it.** That is the only place ambiguity stops a run: at the point where one effort has to be picked, and nothing is guessed.

**A ticket branch is a build claim and MUST be released once its work reaches the effort branch.** It exists so that git refuses a second run the same ticket, and it holds nothing once the orchestrator has integrated it, so the step that lands the work deletes it. Deleting one whose work is still outside the effort branch is data loss and MUST NOT happen; a parked or failed ticket keeps its branch, because nothing was integrated. *Why specified rather than left to taste: an implementation that keeps them leaves one branch per ticket whose every commit is already in the effort branch, and the effort branch is the reviewable unit, since exactly one pull request exists per effort (§16) and a branch integrated rather than merged is not a level of anything.*

**A ticket branch name MUST be unique across efforts.** Ticket ids restart per effort, a ticket being a file under its own effort (§14.4), so two efforts each holding a ticket `03` would otherwise produce one branch name for two claims, and the second run to reach it takes a claim another already holds. **How uniqueness is achieved is the repository's to state** in its own version-control rule; that it holds is this specification's.

## 20. Position

Position is lightweight operational state, per working tree and never committed. `.aep/position/marker.json`:

```json
{
  "tree": "...",
  "head": "...",
  "sessions": []
}
```

`tree` is the working-tree state the last read was made against, `head` the Git HEAD it was made against, `sessions` the active or relevant AEP sessions.

`sessions` holds identifiers **the runtime supplied**, with when each stamped. An implementation MUST NOT invent one: a session's identity is known to the agent because its harness generated it, and no script can discover it agent-agnostically. Where a runtime supplies none the field stays empty, and every other guarantee in this specification is unaffected.

**It is a diagnostic and never a claim, and a conforming implementation MUST NOT read it to decide whether to proceed.** A session identifier carries no liveness: it cannot be distinguished from the same identifier left behind by a process that was killed, so a run gating on one would block on the leavings of every abnormal exit. Exclusion is git's (§18.2) and needs no liveness, because it is not a lease. What the field buys is that a checkout being shared says so to whoever reads it afterwards.

**Nothing AEP writes adds a key beyond `tree`, `head`, and `sessions`.** The effort a run is inside is computed from the branch (§19.3) and the working surface is the tree the marker already sits in, so either would be a second copy of a fact already derivable. The permission below to record further untracked operational facts is the consuming repository's, and is not a licence for the protocol to spend.

Position MAY additionally record **untracked** operational facts — state not represented by tracked artifacts. This MUST remain lightweight and MUST NOT become a hidden database (§2).

Position is gitignored, so it is **per working tree rather than per clone**: two linked worktrees of one clone hold two markers, and two agents sharing one checkout hold one between them — the opposite of a claim in both directions. **Position therefore MUST NOT carry which effort a run is inside.** That is computed from the branch (§19.3), and a copy of it here would be a second source of truth, able to disagree with the first and gitignored where nobody would see it do so.

**A marker belongs to the surface it sits in, and describes that surface alone.** Its `tree` and `head` are that tree's, so a marker read in one surface answers nothing about another, and a run that enters a surface (§18.3) leaves behind whatever marker it read on the way in. **A conforming implementation MUST NOT check one surface's marker while stamping another's**: an invocation that does both MUST make both against the surface it does its work in, which means the check follows the entry rather than preceding it. An invocation that **stamps nothing** cannot violate that, and reads the surface it is standing in at the time; `/specify` is the worked example, since at the moment it orients it has neither an effort nor a surface to check. *Why this is normative rather than an ordering detail: the two acts read as one guarantee and are quietly two files. A run checking before it enters reports drift for a tree it is about to leave and stamps a tree it never compared, so the answer it quotes is true of nowhere and nothing about it looks wrong.*

**Which surface that is, and what role it carries, are computed and never recorded here** (§18.3). Both are derived from Git and the path on every read, for the same reason the effort is: a copy kept in a gitignored file is a second source of truth, free to disagree with the first where nobody would see it do so. The three keys above stay the whole of what AEP writes.

**Position is NOT** Git, architecture, memory, context, a decision record, or a source of truth. **If position conflicts with repository state, repository state wins**, and position is re-derived rather than trusted.

---

# Part IV — Operation

## 21. The workflow spine

```
/specify → /plan? → /tasks → /implement
```

**Four commands, and nothing else a human types.** `plan` is conditional: it runs where the approach is not obvious, and a bug fix skips it. Everything else the protocol does is reached from inside one of the four.

| Stage | Establishes | Writes | Reached |
| --- | --- | --- | --- |
| `specify` | WHAT and WHY | `spec.md` | typed |
| `refine` | ambiguity resolved | the same `spec.md` | from `specify` or `plan` |
| `research` | a fact established from primary sources | `evidence/research/` | from `specify` or `plan` |
| `plan` | HOW | `plan.md` | typed, when the approach is not obvious |
| `tasks` | executable work | tickets under the effort | typed |
| `implement` | working code, committed | repository source | typed |
| `review` | the effort's diff satisfies the defined change | findings | from `implement`, once at the close |
| `converge` | the effort satisfies the spec | further tickets, or completion | from `implement`, when the tickets run out |

`prototype`, `survey`, and `prune` are **capabilities, never lifecycle stages**, reached when uncertainty or the codebase warrants one.

**`/specify`** inspects the repository and position, loads the index, identifies applicable rules and relevant contexts, understands the request, and **resolves what is material inside the same invocation** — factual uncertainty by `research`, product uncertainty or an unresolved tradeoff by `refine`, technical uncertainty by `prototype`. It writes `spec.md` and opens the effort: one issue, one branch, one draft pull request (§14.1). A turn that ends by naming a command has renamed the uncertainty rather than resolved it.

**`/plan`** establishes the technical approach as `plan.md`, beside the spec it plans. It MUST NOT silently expand product scope — technical discovery that exposes a product-level change **stops and surfaces it**.

**`/tasks`** converts the planned effort into tickets that derive from the spec, map to acceptance criteria, expose dependencies as `blocked-by`, are bounded, and do not redefine architecture. Every ticket traces to a requirement or an acceptance criterion, and an implementation MUST check it (§14.4).

**`/implement`** takes **the effort, not one wave**. It computes the frontier from the tickets' declared edges, builds what is ready, commits each, and schedules again, until converge finds no gap or a trip-wire fires. It then reviews the effort once, before the work is handed over. **An exhausted ticket list is not the end of the run**: tickets exhausted and the spec satisfied are different claims, and only the second ends it.

**`review`** is a stage of `implement`, and **its unit is the effort**. Its subject is the effort branch, the diff a human is asked to merge, and it runs once at the close of the run, after converge finds no gap. It verifies requirements, acceptance criteria, tests, architecture, applicable rules, regressions, security, and documentation. Where the runtime supports sub-agents it MUST use **two independent passes** — one on correctness and behaviour, one on style, standards, and governance — and MUST reconcile their findings. Review is not *does it compile*; it is *does the implementation satisfy the defined change*. *Why the effort and not one ticket: a reviewer holding a single ticket's diff cannot see a defect that lives between two of them, and the effort branch is the unit a human is asked to merge, since exactly one pull request carries it (§14.4).*

**`converge`** is the effort's termination condition and runs when no unresolved ticket remains. It asks whether the spec is satisfied, and it **appends tickets rather than editing the spec or the plan**: work that was not built becomes further tickets, and an approach that cannot satisfy a requirement stops on the return-to-plan invariant (§22). It runs at most twice; a second round finding a gap the first round created is a signal about the plan, not an invitation to a third.

**An agent MUST NOT hand work to a human while a review finding against it is open.** A finding is closed by being fixed, by becoming a ticket the run schedules, or by the human accepting it, and a pull request MUST NOT be marked ready while one is still open. *Why the handover rather than the commit: review's subject is the effort branch, so every commit in it exists before the review that judges it, and a rule forbidding the commit would forbid the only order in which the work can happen. What the protocol protects is that unjudged work never reaches a human, and that is a property of the handover.* An agent MUST NEVER merge, publish, or push a tag (§2). What it MAY push is fixed by the repository's own rule, not by this specification.

## 22. The return-to-plan invariant

If evidence discovered during `/implement` or `/review` invalidates the technical plan, the agent MUST NOT silently modify the architecture. Instead:

```
stop → record evidence → return to /plan → update spec.md → update tasks → continue
```

This is what keeps implementation from becoming an uncontrolled design process, and it is the invariant most often violated by an agent that is *nearly* done.

## 23. Applicability-first loading

Before reading an artifact, an agent determines whether it is relevant, combining:

- `use-when` — the trigger the artifact declares
- `paths` — the repository paths it applies to
- `[[...]]` links — explicit relationships from what is already loaded
- the current repository path, effort, and task

The discovery order is:

```
repository state → index → current effort → applicable rules
→ relevant contexts → required references → relevant evidence → task → work
```

A conforming instruction MUST NOT direct an agent to load all rules, all contexts, all references, all efforts, or all skills before a task.

## 24. Evidence before guessing

When uncertainty is material, an agent MUST NOT silently guess. It uses the cheapest reliable mechanism:

```
known fact → repository inspection → existing context/evidence → research → prototype → grill
```

Expensive investigation for trivial uncertainty is itself a defect: the ladder is climbed only as far as the uncertainty warrants.

## 25. Determinism

Determinism does NOT mean forcing every task through an identical process. It comes from explicit artifacts, explicit ownership, explicit applicability, explicit acceptance criteria, explicit dependencies, repository authority, and reproducible procedures.

**An agent MUST NOT invent protocol state where an artifact already defines it.** Where a script can compute an answer, the script computes it and the agent quotes the output; judgement states its inputs and its one question.

## 26. Derived indexes

`.aep/index.md` is a derived discovery index over the AEP filesystem, listing artifacts with the applicability fields an agent selects on, so that discovery does not require reading every file.

The index:

- **MUST be generated**, by `.aep/scripts/index.mjs`, and MUST NOT be hand-edited.
- **MUST be regenerable at any time**, and regeneration MUST be byte-identical for an unchanged tree.
- **MUST NOT replace the filesystem.** It is derived state; the files remain authoritative.

A generated index cannot disagree with its directory, which is the whole reason it is generated: a file added without frontmatter cannot appear in one, so the obligation to audit a hand-written index for missing rows never arises.

The index carries the fields relevance is decided on — `use-when` and `paths` — and **no summaries**: a summary would be a second statement of what an artifact says, and it would drift first. It does not carry ownership, because ownership is the directory the row is already filed under (§7).

**The index lists skills, not skill notes (§15.1).** A note is reached from the skill that owns it, and listing it as though it were separately invocable would advertise an entry point that does not exist.

**Where any effort has tickets (§14.4), the index MUST carry a section for them**, listing each with its effort, `status`, and `blocked-by` — the fields that answer *what can be worked right now*, which is a cross-effort question. **Where there are none the section MUST be absent entirely**, rather than present and empty: a repository between efforts would otherwise read as one with work it cannot find.

## 27. Separation of concerns

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
| Worktree | an isolated execution environment | knowledge storage |
| Position | lightweight operational state | a source of truth |

A primitive MUST NOT be used as a substitute for another.

---

# Part V — Distribution

## 28. Runtime adapters

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

**An adapter wraps the seventeen skills and nothing else.** Skill notes (§15.1) are reached by link from the skill, so wrapping one would publish an entry point the protocol does not have. A runtime whose agents load from a location of their own MAY also wrap the agents (§17); where it has no such location, the agents do not reach it and the adapter says nothing about them.

Where a runtime's frontmatter schema and AEP's contract (§8) collide, the runtime's schema wins **in the adapter file only**, and AEP's fields move under whatever free-form map that runtime reserves. The canonical artifact keeps AEP's contract unchanged. Where a runtime reserves no such map for a kind of artifact, AEP's fields are **omitted rather than smuggled in** — a runtime that silently absorbs an unknown key turns a typo into behaviour nobody can see.

### 28.1 Targets and shapes

AEP renders for more than one runtime, so a **target** is a declaration rather than a program: where each wrapper lands, what name the runtime knows it by, which frontmatter that runtime's schema admits, and how a wrapper behaves when the canonical file is absent. One renderer walks the payload for every target. *Why declarations rather than a renderer per runtime: the pointer contract would otherwise be stated once per runtime, and a stale adapter is mechanically detectable while three wordings of one rule drifting apart is not.*

A target MAY prefix the names it publishes, and MUST where the runtime's own built-in commands would otherwise shadow a skill. **A name a runtime shadows is not an error anywhere** — the skill simply never runs, which is indistinguishable from nobody invoking it.

A target renders one or more **shapes**, distinguished only by what a wrapper does when `.aep/` is absent:

| Shape | Ships | On absence |
| --- | --- | --- |
| `repository` | written into a repository by an install (§29) | says AEP is not installed here, and stops |
| distribution shapes | travel outside a repository — a plugin, or a directory a runtime is pointed at | reach the payload they shipped beside, so `/install` works before `.aep/` exists |

A distribution shape's reach MUST be **derived from where the wrapper sits**, never written out, so moving a wrapper moves its reach with it.

**A target's rendered tree is committed to the protocol repository exactly when that directory is itself what a user registers** — a published plugin, or a directory named in a runtime's configuration. A shape that only ever renders into a repository at install time is not committed: a checked-in copy would have no reader, and the currency check that justifies committing a generated tree would be guarding an artifact nobody loads.

Every path a wrapper names MUST exist in an installed tree. *This is the requirement that a moved artifact breaks silently: the wrapper still reads well, and the agent it sends is simply reading nothing.*

## 29. Installation

Installing AEP into a repository creates `.aep/` and the protocol-owned payload. Installation:

1. creates the canonical layout (§5) and `.aep/.gitignore`,
2. installs protocol-owned artifacts — `protocol.md`, `policies/`, `skills/`, `agents/`, `templates/`, `scripts/` — verbatim, every one of them named by the manifest (§7),
3. installs the seeds (§7.1) whose detectors match, as repository-owned starting points,
4. initializes position (§20),
5. generates the index (§26),
6. optionally installs runtime adapters (§28),
7. writes the repository's entrypoint from the entrypoint seed (§7.1) where it has none, and otherwise leaves it alone — either way it **points at** `protocol.md` and never restates it (§6),
8. **reports what was assumed on the repository's behalf** — every seed installed, so a human can correct it.

**Installation MUST preserve existing repository-owned artifacts**, and it decides by the manifest: a path the release does not ship belongs to the repository, whatever the file contains and whether or not it has frontmatter at all (§7).

Where a file **does** stand at a path the manifest names, the install writes it — the path is the protocol's — but MUST NOT do so silently where the content differs: somebody edited a shipped artifact, or wrote their own where one lands, and either way they are told rather than finding out later.

An install over an existing `.aep/` MUST refuse unless it was explicitly invoked as an upgrade (§30).

## 30. Upgrade

An upgrade:

1. identifies protocol-owned artifacts by the manifest the release carries (§7),
2. replaces them with the release's versions,
3. **preserves repository-owned artifacts**, including every seed (§7.1),
4. **never re-seeds.** A starting point the repository has since corrected is its own file; a newer release's version of it is not an improvement to be applied. Where a seed has changed materially the upgrade reports it and stops,
5. reports protocol-owned artifacts present in the repository but no longer shipped — **retired, never deleted**: deciding a file is obsolete is a human's call,
6. **applies the release's declared moves**, described below,
7. detects compatibility problems and declared deviations (§7),
8. **reconciles rules against the policies the crossed releases changed**, described below,
9. **never silently overwrites repository-owned governance.**

**A move is not a retirement.** Where a release relocates a protocol-owned artifact, the old path is not merely unshipped — its content now lives elsewhere, and leaving the file in place would govern the repository with two copies of one text, both of which resolve. So a release **declares its moves**, as source, destination, and the release that made the move, and an upgrade:

- removes a protocol-owned artifact standing at a declared source, and reports it;
- **preserves a repository-owned artifact standing there**, reporting the collision instead — the repository wrote its own file under a name the protocol has since vacated, which is legal and is a human's to resolve;
- rewrites links to a vacated source inside **repository-owned** artifacts, and reports every file it touched. This is the one circumstance in which an upgrade writes into a repository-owned file, and it MUST be confined to the declared targets: a link is rewritten only where the source path is now vacant, only the link's target changes, no anchor is ever constructed, and a link inside a fenced block is left alone — it is syntax being shown rather than a reference being made, which is why link validation ignores it too (§9). *Why the repair is made at all rather than reported: it has exactly one correct answer, and leaving it undone breaks every repository's tree on upgrade day.*

**A move MUST apply only to a tree that predates it**, compared against the release the tree declared on arrival (§6). A tree declaring nothing predates everything, since unknown is not current and the move only ever removes a protocol-owned file whose content exists at the target. *Why the bound is required rather than merely tidy: the source path is vacant afterwards, and a repository is entitled to write its own artifact there (§29). Without the bound that artifact is reported as a collision on every upgrade it ever runs.*

A declared move MAY be dropped from a release once no supported tree predates it.

**A rule is legal against the release it was written under, and an upgrade is where that is rechecked.** A rule MAY tighten or extend a policy and MUST NOT soften, contradict, or opt out of one (§10) — a judgement made against one release, which a later release can invalidate without touching the rule. An upgrade therefore MUST, for every rule citing a policy whose text changed between the declared release and the running one:

- **compute the candidates rather than judge them.** The rule's own citations select it, so the same tree raises the same list;
- classify each as **restating** law the release changed, **contradicting** it, or **tightening a policy the release did not touch** — and write nothing for the third;
- rewrite a restatement to cite the policy, and rewrite a contradiction to the new law or record it as a declared deviation (§7) where the repository means to differ;
- **show every edit as exact before-and-after strings, as one set, before the first is made, and write nothing at all on a refusal.** This is a write into governance the repository owns, and it passes the gate a tracker write passes;
- **never delete a rule.** A contradiction the repository means to keep becomes a deviation that says so.

*Why an upgrade and not validation: a rule and the policy under it can only disagree across a release boundary, and validation runs against a single release and sees two files that agree. The upgrade is the one step standing on both sides of one.*

**Some releases require something of the reader that no upgrade can do for them** — most often a change to a repository-owned artifact, which an upgrade correctly refuses to touch. A release therefore MAY **declare notices**, each carrying the release it applies from and one statement of what to check and why.

An upgrade MUST report exactly the notices whose release the installed tree precedes, using the **same** comparison that gates declared moves, so a notice and a move declared by one release cannot disagree about whether that release is being crossed. A tree at or past the release MUST be shown nothing. A dry run MUST preview them as a real run reports them.

A notice is an instruction, never a changelog entry, and **a release with nothing to ask of the reader declares none.** Relevance is decided by comparing two releases and MUST NOT be judged at runtime. A conforming runtime **acts** on each notice or reports it as outstanding; reporting it is not handling it.

*Why this is a declaration rather than a document: a changelog is not payload, so a repository running an upgrade has never received one, and shipping the whole history into every installation to deliver two lines is a poor trade for a filter that already exists.*

A repository declares its installed release through the `version:` field on `protocol.md`, the one artifact that declares a release at all (§6). A runtime MAY compare that against the running release and say so when they differ; a repository that declares nothing is *unknown*, never *stale*.

### 30.1 Recognising which layout a tree is in

An upgrade meets trees written under more than one contract, so it **classifies by content before it replaces anything**. Two mechanisms, and the older one exists only for as long as trees written under it do:

| The tree carries | Classified by |
| --- | --- |
| an `owner:` field on its artifacts | **that field**, which is what it was for |
| no `owner:` field | **the manifest** (§7), which is the list this release ships |

The `owner:` branch reads ownership off the tree it is replacing, writes the new layout without the field, and carries across what the shrinking contract left behind — a `spec.md` holding `# Architecture` splits into `spec.md` and `plan.md` (§14.2), and every retired field is dropped rather than converted, because §32 records that each one's answer already lives somewhere else.

**The removal condition is stated rather than left to judgement: the branch goes when no repository the maintainer knows of still declares the older layout.** A compatibility branch with no stated end is one nobody ever removes, and it is read on every upgrade forever.

### 30.2 Migration from 1.x

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

**3. Every derivable field is derived; only what cannot be derived is proposed.** A conversion that asks a human to retype what the migration could compute is a conversion that will not be finished. `status` comes from the defined state mapping, and `paths` carries unchanged. A field the current contract does not have is not derived at all — it is dropped, and §32 records where its answer went.

`use-when` is the exception, and the only one: 1.x selected knowledge by stage and path, so most artifacts have no trigger to convert, and a trigger is exactly the field §8 forbids an implementation to guess at. The migration proposes one from the artifact's content, **marks it unconfirmed, and lists every proposal in its report.**

**4. Where 2.0 narrowed a structure, the human chooses.** 1.x kept specifications in two places and evidence in one global directory; 2.0 has one spec per effort and evidence under the effort that produced it. Where two 1.x files map onto one 2.0 file, or where a piece of evidence names no effort, the migration **reports the collision and stops on it** rather than picking.

**5. A converted artifact satisfies this specification or it has not been converted.** The migrated tree passes the same validation any other `.aep/` does — no exemption, no grace period. A conversion that leaves an artifact failing the contract has produced a file that looks migrated and cannot participate in discovery.

The mapping itself — every 1.x directory, every field, what each becomes and what is dropped — belongs to `[[skills/update]]`, not here: it is the procedure for one release boundary, and this specification defines the shape it arrives at.

## 31. Verification

### 31.1 The distribution

Everything the protocol ships lives under one directory in the repository that builds it:

```
specs.md                  this specification — normative, never shipped
AGENTS.md                 the entrypoint, pointing at .aep/protocol.md
src/
├── protocol.md           installed as .aep/protocol.md
├── policies/ skills/ agents/ templates/   the protocol-owned payload
├── seed/                 repository-owned starting points (§7.1)
├── scripts/              the payload's scripts, plus install and verify
├── gitignore             installed as .aep/.gitignore
└── adapters/<runtime>/   runtime adapters, one directory per committed target (§28.1)
.aep/                     the building repository's own installation
```

**`src/` is source; `.aep/` is output.** In the repository that builds AEP, `.aep/` is produced by running the installer on `src/`, and editing it changes nothing that ships.

**The manifest is generated from `src/`, never maintained beside it** (§7). It ships to installed trees inside the payload's own contract module, which is what lets an installed tree answer *is this file the protocol's* without the release being present.

Two consequences are normative. **This specification is never installed** — it defines the protocol and is not part of it, which is why no shipped artifact may cite it (§31.3). And **`.aep/.gitignore` ships as a file rather than being generated by a script**, so what is never committed is a reviewable artifact rather than a string in a program.

### 31.2 The suite

The protocol repository MUST ship a verification suite that asserts the **shipped public surfaces** — `src/skills/`, `src/agents/`, `src/scripts/`, and the rest of the distribution — against this specification. It is the fidelity floor: every mechanically checkable requirement here has an assertion, and a change that adds a checkable claim without an assertion is untested by construction.

The suite MUST also prove **its own failure path fires** before any result it reports is trusted — a check that cannot fail reads exactly like a check that passed.

The suite MUST assert at least:

- the frontmatter contract (SS8) on every payload artifact — `use-when` where required, `paths` an array where present, `status` legal and only where permitted, `blocked-by` on tickets only, and **no retired field on any path the manifest names**;
- the four `use-when` checks (SS8.1), each demonstrated by a `use-when` that fails it;
- **the manifest matches the payload**: every path it names ships, every shipped path is named, and a file standing inside a protocol-owned directory that the manifest does not name fails validation by name (SS7);
- `protocol.md` states the ownership rule as a table naming every protocol-owned and every repository-owned directory, and it is the only artifact declaring a release (SS6);
- the shipped policy set is at most five, each with a `use-when`; `policies/` ships only what the manifest names, and an install leaves `rules/` holding only repository-owned files (SS10);
- every declared move (SS30) names a destination the release ships and a source it does not;
- an upgrade from a release predating a move removes the protocol-owned source, rewrites the links that pointed at it inside repository-owned artifacts, preserves a repository-owned file standing at the source path, and reports all three; and an upgrade of a tree that already declares the release applies no move at all (SS30);
- a dry run previews the same repairs a real run would perform — a preview that understates the change is worse than none;
- every `[[...]]` link resolves (SS9);
- the skill set is exactly the seventeen of SS15, and each states a posture with something it gives up;
- **the four typed commands are the four of SS21**, and every other skill is reached from inside a run rather than named as a command in its own heading;
- `help` links every shipped skill but itself — the one artifact whose job is answering *what do I reach for* is the one place a new skill must not go missing, and it is reachable from no other;
- every skill note (SS15.1) sits under a directory named for a real skill, carries a `use-when`, is linked from the skill that owns it, and is wrapped by no adapter;
- a context is accepted at `contexts/<area>.md` and at `contexts/<project>/<area>.md`, and **rejected deeper**, with the failure naming the legal forms — checked at all three depths, because a guard proven only on the rejection can still reject what it should accept (SS12.1);
- the index lists a nested context by its full wiki-link and the Contexts section is **not** flat-listed, so the nested form cannot be dropped from discovery by a later change (SS26);
- nothing in the distribution derives applicability from a context's directory name (SS12.1);
- the context template gives both shapes and the rule for choosing between them;
- the report contract (SS15.2) is stated in exactly one shipped artifact — its slots, their order, the turn as the unit, the nested-entry rule, the no-empty-slot rule, and the early-stop requirement — and no skill carries a second copy of it;
- **stage names extract mechanically from every skill**, non-empty, with every numbered step of its procedure named — a skill matching no known shape fails rather than being skipped;
- no shipped surface stating the report contract names a terminal, a colour, a display size, or a runtime;
- `protocol.md` exists and is within its size budget (SS6);
- the forbidden structures are absent — no `decisions/`, `tools/`, `grill/`, or `modes/` (SS5, SS16);
- **an AEP artifact written outside `.aep/` fails validation** (§5.1), recognised by the contract its content satisfies rather than by the name of the directory holding it, named at its path relative to the repository root, and left exactly where it was found — checked with a stray present, with the same stray removed, and against a repository's own directory of ordinary files sharing one of the names, because a check that fires on everything is indistinguishable from a working one on the failing run alone;
- **a filesystem path naming an AEP artifact carries the `.aep/` root where it has two segments or more** (§9.1), over every shipped and entrypoint surface, with a single-segment area name left alone and a path inside a fenced block ignored — checked with a fixture for each shape the rule turns on, including one the guard must not report, because a guard that has quietly stopped matching is indistinguishable from a corpus that is clean;
- **no shipped or entrypoint surface describes a retired field (§32) as one an artifact carries**, driven from the list of retired fields rather than from any field's name, so a release that retires an eighth is covered by the edit it already makes — checked with a fixture per retired field, in both directions, because passing on the one field that failed is indistinguishable from a check written around it;
- **a skill's declared output is what §21 assigns it**, read from that table rather than from a list maintained beside it, and the parse MUST assert a minimum row count before asserting anything about rows, and a minimum count of the stages the two tables share: a parse matching nothing passes every row it does not have, and so does a comparison that quietly skips a stage one table stopped naming;
- **a repository's own note validates beside a shipped skill, and nothing wider does** (§15.1) — checked with the note accepted, with a skill outside the manifest still refused, with a note answering to no shipped skill refused, with depth below a note refused, and against a second protocol directory, because a permission that reached every one of them would pass on the directory that happened to be checked;
- **an entrypoint's factual claims are checked against what they describe** — every path it names exists, every command it shows names a script that exists, and every flag it documents is one that command accepts — and an entrypoint is exempt from prose prohibitions only, never from having its claims read;
- **every ticket traces to a requirement or an acceptance criterion of its own effort**, and a ticket citing a number no requirement carries fails by name (SS14.4);
- **the effort opening is one issue, one branch, one draft pull request**, in an order that could run, with the rename preceding the first commit; the ask happens once and a refusal stops it (SS14.1);
- **converge is stated as the effort's termination condition**, appends rather than edits, and is bounded (SS21);
- every seed targets a repository-owned directory and states that it is a starting point — except the entrypoint seed, which targets the root and carries no frontmatter (SS7.1);
- the index gains a tickets section exactly when tickets exist, and lacks one when they do not (SS26);
- every committed runtime adapter is **current** — regenerating it from the payload reproduces the committed files byte-for-byte — and every wrapper is a pointer rather than a copy (SS28);
- **for every target and every shape it renders**, and not for one runtime: the wrapper set covers each shipped skill, and each shipped agent where that target wraps agents; a target that renders nothing fails rather than passing vacuously; every published name matches the target's declared prefix and, for a skill, equals the directory holding it; the frontmatter keys are exactly what that runtime's schema admits, compared as a set; and **every path any wrapper names resolves in an installed tree**, checked in prose and in frontmatter alike (SS28.1);
- a distribution shape's reach resolves onto a payload file that exists, and a shape declaring none carries none (SS28.1);
- an install writes each adapter it was asked for into the directory that runtime reads, names each in its report, refuses an unknown runtime **before writing anything**, and warns where two requested targets are read by one runtime (SS29);
- an **install fixture**: installing into a temporary repository produces a tree that passes every check above, regenerating the index over it is byte-identical (SS26), an upgrade preserves a repository-owned file standing where a shipped one would land, an upgrade replaces a protocol-owned file that was edited locally, and an upgrade does not re-seed a corrected starting point (SS30).

**Every section reference this specification makes MUST resolve to a section that exists.** It is the cheapest check in the suite and it guards the failure this document is most prone to: a section renumbered by an edit somewhere else, leaving every citation of it pointing at the wrong text while still reading correctly.

Scripts MUST be JavaScript, executable by a bare Node runtime with **no dependencies and no package manifest required**, and named so that a consuming repository's `package.json` cannot change how they are parsed.

### 31.3 What shipped text may cite

**A shipped artifact may cite only what resolves where it is read.** Files under `src/` are read inside whatever repository AEP is installed in, so a citation of this specification, of a section number, or of a record that exists only in the building repository is worse than a dead link there — it is indistinguishable from a reference to something of theirs.

Where a citation was carrying a reason the surrounding prose does not state, **state the reason** rather than deleting it silently: a citation doing real work leaves a hole when it goes, and the hole is invisible because the sentence still reads well.

A link to an external project — upstream provenance, a specification, a vendor's documentation — is exempt: it resolves everywhere, and it is not navigation within the tree.

### 31.4 Scope

Verification covers what ships. It does NOT audit the protocol repository's own installed `.aep/` as though it were a shipped surface — that tree is an installation, checked by the same tools any repository uses.

## 32. What each release removes

Named explicitly, because a retired concept that is merely unmentioned grows back.

### 32.1 What 3.0 removes

Nothing here loses a function. **Each row moves to where the answer already was**, which is why it could go:

| Removed | Where its answer lives now |
| --- | --- |
| **Modes** as a primitive, `modes/`, and `mode:` | the posture is stated in the skill that takes it (§15); applicability is `use-when` and `paths` (§8) |
| `owner:` | ownership is the directory, stated once in the bootstrap and carried as a manifest (§7) |
| `aep:` and `date:` on every artifact | `protocol.md`'s `version:` for the release (§6); git for when a file last changed; the manifest comparison for an artifact edited without being restamped |
| `kind:` | the directory, and the heading the artifact already carries |
| `report:` | one report shape for every turn (§15.2) |
| `part-of` | the path `efforts/<effort>/tickets/`, which already says it |
| `commit` as a skill | committing is a step of `implement`, per ticket (§21) |
| **Tickets in an external tracker** | tickets are files under the effort; the tracker holds one issue and one pull request (§14.4) |
| **`refine`, `research`, and `review` as commands** | stages, run from inside the skill whose procedure calls for one (§15) |
| Evidence, Tasks, Worktrees, and Position as **primitives** | parts of an effort, and mechanisms specified where used (§3) |

Two rows reverse a 2.x decision rather than retiring an idea, and both are recorded as reversals:

- **`plan.md` returns** (§14.2). 2.0 removed it so that one file would answer *what are we building*; 3.0 reinstates it because the spec became the issue body, and a design folded into the thing a human approves changes shape after they approve it. The hazard 2.0 named is real and is answered by hierarchy instead: the spec is the source of truth and the plan serves it.
- **The primitive count falls rather than grows.** Every earlier release added one; this is the first to state the set as a count so that the next addition has to argue against a number.

### 32.2 What 2.0 removed

| Removed | Replaced by |
| --- | --- |
| `.claude/` as canonical state | `.aep/`, with `.claude/` demoted to an adapter (§28) |
| Policies, as a repository derived them | policies as **protocol law** (§10), and rules as the repository's own |
| `decisions/` (ADRs) | the effort's `spec.md` and its evidence (§14.2) |
| `tools/` | references, widened beyond CLIs (§11) |
| The stage→dependency table | applicability metadata on each artifact (§23) |
| The boot tier and its budget | one cheap bootstrap, `protocol.md` (§6) |
| Discussions as an artifact kind | grill as a mechanism (§16) |
| Mandatory local tickets | optional local, or external — **narrowed in 3.0** to local only (§14.4) |
| `plan.md` | the same `spec.md`, extended — **reversed in 3.0** (§32.1) |
| Per-repository derived policies | repository-owned rules, references, contexts (§7) |

Each row below is also a conversion target: where an existing repository holds the removed thing, §30.2 says what becomes of it. **Removed from the protocol does not mean discarded from a repository** — only the rows whose replacement this release *ships* are dropped, and the rest are converted or reported.

### 32.3 The policy row, reversed in 2.2

The word `policy` returned in 2.2, and it returned **inverted**. This is recorded rather than quietly restored, because a row that changes meaning without saying so is worse than one that was never written.

| | 1.x policy | 2.2 policy |
| --- | --- | --- |
| Whose | the repository's, derived per repository | AEP's, identical everywhere |
| Editable in a repository | yes, that was the point | **never** |
| Replaced by an upgrade | no | yes, verbatim |

What 2.0 retired was **a second governance layer the repository owned**, sitting beside rules the repository also owned — two homes for one kind of knowledge. That is still retired, and §32's row for it still stands.

What 2.2 introduced is the **other** distinction: 2.0's `rules/` already held two layers, protocol-owned and repository-owned, separated only by a field inside each file. Naming them apart is what the directory now does. The hierarchy in §10 is unchanged in substance — it was already `protocol rules → repository rules`.

The practical consequence is a migration hazard, not a philosophical one: **a 1.x `policies/<concern>.md` converts to a repository rule, never to a policy** (§30.2). The names collide and the meanings are opposite.

## 33. Relationship to prior work

AEP takes the **specify → plan → tasks → implement** spine from [Spec Kit](https://github.com/github/spec-kit) and the **composable skill** shape from [mattpocock/skills](https://github.com/mattpocock/skills). It improves on both in three specific ways, and the claim is narrow enough to check: applicability metadata on every artifact so knowledge loads by relevance rather than by stage; a declared ownership boundary so a protocol upgrade cannot eat repository knowledge; and evidence bound to the effort that motivated it, so investigation survives the conversation.

AEP MUST NOT depend on either, MUST NOT require either installed, and MUST NOT define itself as an extension of either. They are engineering references, not architectural dependencies.

**Nothing in AEP is vendored.** Every shipped file was written for this protocol, so no upstream licence condition reaches it and the distribution carries no third-party notice. That is a statement about the current release, not a permanent one: **the moment text is copied in from another project, its licence binds** — the copy carries its attribution in the file, and whatever notice the licence requires ships beside it. Asserting an obligation that does not exist misstates a licence exactly as omitting a required one does, which is why this is stated in both directions.

AEP supports adapting external skills into `.aep/skills/`, and MUST NOT assume any particular skill collection. AEP provides the environment in which skills operate.

---

# Part VI — Conformance

## 34. Invariants

A conforming implementation preserves all of the following:

1. `.aep/` is the canonical AEP location.
2. AEP is agent-runtime independent.
3. Runtime adapters are not AEP state and never hold a drifting copy of it.
4. Governance is policies and rules, and nothing else governs. A policy is AEP's and is never edited in a repository; a rule is the repository's and is never overwritten by an upgrade.
5. A policy outranks a rule. A rule may tighten a policy and may never soften, contradict, or opt out of one.
6. Ownership is the directory a file sits in, stated once in the bootstrap and carried as a generated manifest; nothing declares it and nothing infers it from contents. A repository never authors a policy, and a misplaced file is preserved and reported rather than silently corrected.
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
17. A skill states the posture it takes and what that posture gives up; no artifact and no field carries a posture on a skill's behalf.
18. Worktrees isolate execution and store no knowledge.
19. Position is operational state, never a source of truth.
20. Research is optional. Prototyping is optional. Refinement and grill are optional.
21. `spec.md` holds WHAT and WHY and `plan.md` holds HOW; the spec is the source of truth and the plan serves it.
22. No `decisions/` database exists.
23. No `tools/`, `grill/`, or `modes/` directory exists.
24. An effort's tickets are files under that effort, and a ticket is never a tracker object; exactly one issue and one pull request exist per effort.
25. Every Markdown artifact under `.aep/` satisfies the frontmatter contract (§8), which is `use-when`, `paths`, `status`, and `blocked-by` and nothing else.
26. `status` and `blocked-by` appear only on an effort's own artifacts, and `paths` is an array where present.
27. `use-when` is present on every policy, rule, reference, and context, states a trigger rather than a topic, and is checked by four mechanical checks (§8.1).
28. `[[...]]` is the canonical relationship syntax, and every link resolves.
29. Indexes are derived, generated, never hand-edited, and regenerable byte-identically.
30. Repository state is authoritative over every AEP artifact.
31. Context is loaded progressively; no instruction loads the whole protocol by default.
32. Evidence that invalidates the plan returns work to planning rather than silently redesigning the effort.
33. Protocol-owned artifacts are installed verbatim and never edited in a repository; variation enters through a named extension point or is a declared deviation.
34. An upgrade preserves repository-owned artifacts, decides ownership by the declared field rather than by path, and never silently overwrites repository-owned governance.
35. An upgrade applies the release's declared moves, and only to a tree that predates them: it removes a protocol-owned artifact at a vacated source, preserves and reports a repository-owned one standing there, repairs links to vacated sources inside repository-owned artifacts and updates their `date`, and reports every removal, repair, and collision (§30).
36. Migration from 1.x converts everything 2.x has a representation for — including repository content held inside framework-owned files — drops only what this release ships a replacement for, deletes nothing, derives every derivable field and proposes the one that is not, stops on a structure 2.x narrowed, and leaves a tree that validates. A 1.x policy converts to a repository rule, never to a policy.
37. Seeds install once, only where detected, and are never re-seeded; each states that it is a starting point rather than a description.
38. A task is never split across sub-agents; independence is read off declared edges, never inferred.
39. `protocol.md` is the single bootstrap, is within its size budget, and is pointed at rather than restated by every runtime entrypoint.
40. Scripts are dependency-free JavaScript runnable by a bare Node runtime, and everything that ships lives under `src/`.
41. Every mechanically checkable requirement in this specification has an assertion in the verification suite, and the suite proves its own failure path fires.
42. Shipped text cites only what resolves where it is read.
43. An agent never pushes, never publishes, and never silently decides architecture.
44. Conflicts the governance hierarchy cannot resolve are surfaced to the human, never resolved silently.
45. The frontier is computed from the tickets' own declared edges without consulting a tracker, and no label is created for a fact the tracker already models, save the terminal value of a `status:` family AEP maintains (§14).
46. An upgrade reports the declared notices for exactly the releases it crosses, shows none to a tree already at the release, previews them in a dry run, and acts on each rather than merely printing it.
47. `protocol.md`'s `version:` is the single release of record, and an artifact edited without being restamped is detected by comparing content against the manifest rather than by a field.
48. Every turn opens with one report and closes with one block, in one shape defined in exactly one place; a nested skill entry is a stage rather than a second report; no slot is omitted; and a skill's stage names are read from its own procedure rather than declared a second time.
49. A context sits at `contexts/<area>.md` or `contexts/<project>/<area>.md` and no deeper; the directory names it while `paths:` scopes it; and nothing derives applicability from a directory name.
50. Four commands are typed and no others; every remaining skill is reached from inside a run.
51. An effort opens as one issue, one branch, and one draft pull request, in that order, with the directory renamed before the first commit; the opening asks once, and a refusal stops it rather than degrading to something quieter.
52. Every ticket traces to a requirement or an acceptance criterion of its own effort.
53. An invocation of `implement` takes the effort rather than one wave, and the run ends when converge finds no gap — never merely because the tickets ran out.
54. Converge appends tickets and never edits the spec or the plan; an approach that cannot satisfy a requirement stops on the return-to-plan invariant.
55. The run's durable memory is the pull request, so a resumed run reconstructs its position from what was written rather than from what it remembers.
56. A run's scope is the claim its branch's own commits make rather than what its working tree is touching; an empty claim is unscoped, a claim of more than one stops a run that must act on one, and the isolation in force is detected and reported rather than required.
57. A run claims the working surface it writes through as well as the branch it is on: where its checkout is not isolated it takes a worktree of AEP's own and creates its effort branch into it before the first write, keyed on the isolation's kind and never on its enforcement, and it releases that claim by detaching before it removes the surface.
58. A ticket branch is a build claim released when its work reaches the effort branch, deleted by the step that lands it and never before; a parked or failed ticket keeps its branch.
59. Position records the sessions that stamped it, supplied by the runtime and never invented, as a diagnostic that nothing reads to decide whether to proceed; and nothing AEP writes adds a key to the marker beyond `tree`, `head`, and `sessions`.

---

*End of specification. Amendments bump the version above and stamp the artifacts they change.*
