# Agentic Engineering Protocol (AEP) — Specification

**Version:** 1.3.0
**Status:** Normative. This document is the canonical specification of the framework this repository builds.
**Supersedes:** the Tenure framing, and the streamline effort's spec as the description of the target architecture.

This specification is self-contained: a reader with only this file understands what AEP is, what its systems are, how they compose, and how the framework evolves. It is written like a language specification — it defines concepts and conformance, and everything shipped or configured is an implementation of it.

## How this specification evolves

The framework and this specification move together, by rule:

1. **Every change to the framework either conforms to this specification or amends it in the same change.** A change that does neither is drift, and drift is a defect.
2. Where the implementation and this specification disagree, that disagreement is either a defect in the implementation (fix the implementation) or an evolution this document has not caught up with (amend this document). **A human decides which.** Neither is resolved silently.
3. Amendments are recorded as Decisions (§16) referencing the section they amend, and the version above is bumped.

This is a different contract from the truth hierarchy that governs repository knowledge (§4). Contexts describe a codebase and the codebase wins; this specification *prescribes* a framework, so divergence is a decision point rather than an automatic loss.

---

# Part I — Foundations

## 1. Vision

AEP is an operating methodology for AI-assisted software engineering. Its purpose is not to make an AI smarter; it is to make an AI behave like a disciplined engineering organization.

Every engineering activity under AEP is repeatable, deterministic, traceable, explainable, maintainable, and collaborative. The AI is an engineer operating inside an engineering process, not a conversational assistant answering prompts.

Engineering behavior does not live inside prompts. It emerges from the composition of independent systems, each with a single responsibility. The task changes; the methodology does not. An AI under AEP does not ask *"what prompt should I execute?"* — it understands what engineering activity is taking place, how it should think, what knowledge it requires, what process governs the work, what artifacts must be produced, and how the results become part of the repository.

## 2. Core principles

**Single responsibility.** Every system has one purpose. Rules define principles. Policies define expectations. Contexts define knowledge. Workflows define execution. Modes define thinking. Skills define capabilities. No system performs another system's responsibility, and no instruction has two homes — a standard stated in two places drifts at one of them.

**Progressive knowledge.** Knowledge is never loaded because it exists. Only knowledge required for the current activity becomes active, selected by an observable mechanism (§22) rather than by discipline. Discovery is progressive: navigate, then load, then verify at the moment of use.

**Explicit dependencies.** Nothing is implicitly assumed. Every capability declares what it requires — which policies, which mode, which workflow — so that any conforming orchestrator can assemble identical behavior. Dependency declarations live where the only real reader reads them (§11); a manifest nothing executes is a second home waiting to drift.

**Repository memory.** Knowledge outlives conversations. Every meaningful discovery becomes a repository artifact; nothing important survives only in chat history. The repository is the long-term memory of the engineering organization.

**Human authority.** Humans remain the source of authority. The protocol assists engineering judgment and never replaces it. Concretely: the AI never pushes, never publishes, and never silently decides architecture — where more than one reasonable approach exists, the options go on the table, named, with costs and risks, and the human chooses.

## 3. Terminology and conformance

- **MUST / NEVER** mark requirements. A violation is a defect.
- **SHOULD** marks the default; departing from it requires a stated reason.
- **MAY** marks an option.
- An **activity** is a stable kind of engineering work (design, review, research…), independent of its subject. The activity is stable; the repository's contexts determine what it applies to.
- A **stage** is an activity as invoked — a skill running under its mode and workflow.
- An **artifact** is a file an activity produces (a discussion, a finding, a decision, a diff).
- The **spine** is the ordered set of stages that plan, build, and land a change. **Primitives** are capabilities the spine composes (§11).

## 4. Authority: the truth order

When sources disagree, the AI trusts, in order:

1. Explicit user instruction in this conversation
2. Source code
3. Repository configuration
4. Tests
5. Build scripts
6. Decisions (§16)
7. Repository documentation
8. Discussions and research (§13–14)
9. Context summaries (§8)
10. AI reasoning

Ranks 2–5 are collectively **the Codebase**, and against knowledge they are absolute: a context that contradicts the repository is wrong, and is updated — never the reverse, and never explained away. This order resolves *knowledge* conflicts. Conflicts between *instructions* (rules, policies, this spec) are resolved by the precedence policy each configured repository carries; a user instruction overrides everything, and the AI says so when it does.

---

# Part II — Systems

AEP separates engineering into twelve systems. Each answers exactly one question. Sections 5–12 define the eight instruction systems; Part III defines the four artifact systems.

| System | Answers | Stability |
| --- | --- | --- |
| Protocol | how does engineering happen here? | stable |
| Rules | how should an engineer think? | nearly frozen |
| Policies | how is engineering performed in this repository? | evolves with process |
| Contexts | what is true, and where is it found? | evolves with code |
| Modes | how should I think during this work? | stable |
| Workflows | what happens, in what order? | stable |
| Skills | what capability is being exercised? | stable |
| Tool guides | how does this repository use its tools? | evolves with tooling |

## 5. The Protocol

The protocol is the operating system. It defines how engineering happens: initialization, dependency resolution, execution lifecycle, orchestration, context management, conflict resolution, and session management.

The protocol contains **no repository knowledge, no project documentation, and no implementation guidance.** It orchestrates those things; it never is them.

Every engineering activity begins with the protocol, and nothing bypasses it, with one bounded exception: the **boot tier**. The harness loads the repository entrypoint and the unconditional rules directly, before any protocol logic can run (§22). The protocol therefore governs everything *past boot* — every pointer followed, every policy loaded, every mode assumed, every artifact written. The boot tier is kept minimal precisely so that the governed surface is nearly everything.

For each task the protocol determines: the activity, the objective, the mode, the workflow, the applicable policies, the required contexts, the relevant tool guides, and the completion requirements. The concrete routing lives in one committed file per repository — the protocol file — holding the stage→dependency table and the verification machinery (§19), reached by pointer so a turn that only answers a question never pays for it.

## 6. Rules

Rules are universal engineering principles. They are intentionally difficult to change and apply across projects, languages, and repositories.

Rules include, at minimum: never assume facts; verify before implementation; read before modification; preserve architectural consistency; keep changes minimal; prefer understanding over guessing; separate facts from assumptions; communicate uncertainty; maintain traceability.

Rules NEVER describe project workflows or repository conventions — that is what policies are for. A rule is stated as a directive, not as an argument: one clause of rationale survives only where the rule would read as arbitrary without it, because a defended rule invites re-evaluation instead of application.

Rules split by **when they fire** (§22): unconditional rules load every turn and are kept few; scoped rules load only when a file they govern is touched.

## 7. Policies

Policies are the repository's operational agreements: how engineering work is performed *here*. Unlike rules they evolve with the project.

Each policy owns exactly one concern. The canonical set — extensible per repository — covers: version control, the tracker, tickets, specs, decisions, evidence, discussions, knowledge writing, context format, and code review. A testing policy says when tests are required; it does not explain the test framework (that is a tool guide's job). A policy defines expectations, never knowledge.

Policies are reached by pointer, selected by the stage being run — a stage reads its declared policies and stops. Reading another stage's policies is the cost the routing table exists to remove.

## 8. Contexts

Contexts are engineering knowledge — but they are **navigation, not documentation**. A context is a glossary and a map: which directories are responsible, which terminology is used, which decisions are relevant, which other contexts to consult. It reduces discovery cost; it never replaces the repository as the source of truth.

Contexts contain facts and NEVER instructions. They answer *what is true and where is it found* — never *what should be done*.

Structure: one **map** (the routing table, loaded at session start, small by design — it says which domain context a request touches), one **repository context** (cross-cutting vocabulary only), and **domain contexts** loaded only when the map routes to them. Loading them all defeats the point. Vocabulary that belongs to one stage lives in that stage's policy, not in a context.

A **source pointer** in a context says *start investigating here* — never what APIs or behavior exist there. Pointers are verified before use, always (§19).

## 9. Modes

A mode is mental behavior: it changes how the AI reasons, not what steps it executes. A mode establishes priorities and states them as tradeoffs — what this way of thinking is willing to give up. A mode that gives up nothing is not a mode.

The mode set:

- **Discussion** — explore possibilities. Delays conclusions deliberately; questions assumptions, generates alternatives, exposes uncertainty. Goal: understanding, not completion.
- **Research** — discover facts. Evidence over conclusions; inspects code, docs, and experiments before recommending. Produces confidence.
- **Prototype** — learn quickly. Assumes uncertainty; values experiment speed over maintainability. Prototype code exists to validate ideas, never to become production software.
- **Design** — transform knowledge into architecture. Converts research into an implementation strategy; the result is a specification, not code.
- **Implementation** — create production software. Follows approved designs; correctness over exploration.
- **Review** — evaluate work. Deliberately skeptical; assumes defects exist. Validation, not creation.
- **Maintenance** — preserve invariants. Smallest sufficient change; healing in place (§19).

A mode is shared across many activities — review mode applies equally to code, architecture, documentation, and tests. That sharing is why modes are a separate system rather than prose repeated inside each skill. Each skill declares exactly one mode; the mode's tradeoffs are stated once, in the mode.

## 10. Workflows

A workflow is procedural: what happens, when, and in what order. Workflows are deterministic and contain no engineering philosophy — that is the mode's job. Where a mode and a workflow would be the same text, the workflow is the one that exists and the mode it declares carries the thinking; a nominal split maintained in two files is drift by construction.

The spine's workflows, in landing order: **configure** (a repository joins the protocol), **design** (the whole planning surface: tickets, specs, decisions, discussions), **implement** (build one ticket end to end), **review** (two axes: does it implement what was asked, and does it follow this repository's standards), **commit** (turn finished work into a commit and advance the marker), with **research** and **prototype** available wherever evidence is missing.

A design MAY declare, on a build ticket and at design time only, a **design increment**: a scoped decision that only partial code can answer, typed by whether it needs the human present. Implementation resolves a declared increment by invoking the design activity scoped to that increment alone — inline where no human is needed, stopping for the human where one is. Implementation NEVER invents an increment; a decision discovered undeclared blocks the ticket, exactly as before. (ADR 0037.) Additional workflows (release, incident, migration) MAY be added under the same contract: declare a mode, declare dependencies, produce artifacts.

## 11. Skills

A skill is a lightweight entry point to a capability. It contains very little shared methodology — it declares, and the protocol supplies:

- its **purpose** and expected result,
- its **mode** (§9),
- its **dependencies**: the policies, contexts, and tool guides it reads,
- its **constraints** and completion criteria.

A skill NEVER restates what a policy, mode, or guide already owns; it points. Dependency declarations are prose lines in the skill body — read by the only reader there is, and asserted by the verification suite — not a parallel manifest.

Skills divide into the **spine** (the seven workflow stages), the **primitives** composed by spine stages (test-driven development, bug diagnosis, merge-conflict resolution, codebase design vocabulary), and **on-ramps** (grilling a plan, domain modeling, triage, survey, handoff, help). Derived skills carry their upstream attribution; that is a license obligation and survives every rewrite.

## 12. Tool guides

Tool guides state how *this repository* uses external software — Git, the forge, the package manager, the test runner. They never replace official documentation; they record the invocations, flags, and conventions this repository has settled on, derived from the repository rather than from ecosystem convention.

A CLI is an API: an operation no guide covers is a configuration gap, said out loud — never a guessed flag.

---

# Part III — Artifacts and the knowledge lifecycle

## 13. Discussions

A discussion captures engineering thinking that has not yet earned a decision: the problem, the questions, the assumptions, the alternatives, the tradeoffs, the risks, and — required, not optional — **what stayed open**. A discussion with nothing open is a decision that has not been written down yet, and says so.

Discussions are records, not living documents. Nothing revalidates them; they are filed as evidence with a date. The stage that plans writes them, and the same stage promotes a discussion into a decision when it later resolves. A maintained discussion would be a fourth knowledge layer with no rank in the truth order — that is why maintenance is prohibited.

## 14. Research

Research captures investigation: answers to questions, grounded in documentation, existing implementation, benchmarks, experiments, and external references — each finding cited. Research concludes with findings, never with decisions. It is filed as evidence.

## 15. Prototypes

A prototype validates an assumption by building. It records: the hypothesis, the experiment, the observations, the outcome, the recommendation. The write-up is kept as evidence; **the code is always deleted.** Prototype code never becomes production code — the value was the answer, and keeping the code converts a learning tool into a liability.

## 16. Decisions

A decision converts temporary thinking into permanent knowledge: the problem, the chosen solution, the rejected alternatives, the reasoning, the expected consequences. Decisions are authoritative (§4) and append-only — a reversed decision is recorded as a new decision, preserving history. Contexts summarize decisions; decisions preserve the reasoning.

## 17. The knowledge lifecycle

Knowledge flows through predictable stages, and each transition is a real move between artifact kinds:

```
Question → Discussion → Research → Prototype (optional) → Design
        → Implementation → Review → Decision → Context update
        → Repository knowledge
```

Evidence — discussions, research, prototype write-ups, and out-of-scope records — shares one property nothing else has: it records what was verified and when, and nothing revalidates it afterwards. Knowledge that proves durable **graduates out of evidence into context**, and that graduation is stated once, in the evidence policy. This is what makes the lifecycle traceable from the original question to the final implementation.

Maintenance is incremental, never repository-wide: when knowledge changes, only affected artifacts are updated. There is no synchronization pass (§19).

---

# Part IV — Operation

## 18. Composition

Every engineering task is assembled from the systems, never from one monolithic document:

```
rules        → philosophy          (always on, or scoped to the files touched)
mode         → reasoning           (declared by the skill)
workflow     → execution order     (the skill's procedure)
policies     → expectations        (the skill's declared dependencies)
contexts     → knowledge           (routed by the map, loaded on demand)
tool guides  → repository usage    (reached when an operation needs one)
skill        → the entry point that names all of the above
```

No single document contains the methodology; it emerges from composition. A skill that inlines a policy, a policy that states a rule, a context that gives an instruction — each is a conformance defect.

## 19. Verification and healing

**Verification at use — never a scan, never a phase.** There is no synchronization stage. At the moment a context statement is about to be relied on, it is checked against the Codebase. Scope is what the work touches; drift elsewhere is not this request's problem.

**The marker.** Each clone keeps per-clone **position** state — never committed, never depended on by anything shared. The marker records the commit knowledge was last verified against. When the marker matches `HEAD` and the tree is clean, context is trusted with no reading at all — the check is a cache-validity test, not a task. Otherwise drift is read from two sources (what commits changed; what the human changed uncommitted), and only the statements about to be relied on are verified. Only the commit stage advances the marker.

**Reported, every time.** Every stage that relies on context opens with a one-line verification report — including when there was nothing to verify. Silence is indistinguishable from the check never having run.

**Healing in place.** Fix what you find where you find it: a stale pointer is repaired in the same breath as discovering it; a moved boundary is corrected then and there. No queue, no deferred pass. This is not best-effort — nothing else catches a lapse. A pointer that cannot be recovered by searching for where the concept moved is reported broken, never guessed at.

## 20. Multi-agent engineering

AEP assumes engineering may involve multiple agents — human or AI. Every agent follows the same protocol; agents differ only in objective, mode, loaded contexts, and activity. One agent may research while another designs and a third reviews, and collaboration stays consistent because the protocol is shared.

Coordination is by **assignment and claim, with the branch as the lock**: a ticket is claimed by the clone working it, the claim is visible in the tracker, and shared state never depends on any clone's position files. What may be written to a tracker other people read is bounded by the tracker policy.

## 21. Repository layout

A conforming repository:

```
CLAUDE.md                    entrypoint: what this is, where machinery lives (boot tier)
specs.md                     this specification (framework repository only)
.claude/
  protocol.md                the protocol file: marker, drift reads, stage→dependency table
  rules/                     unconditional (no paths:) and scoped (paths:) rules
  modes/                     one reasoning posture per file, declared by skills (§9)
  policies/                  one file per concern
  contexts/
    map.md                   the routing table — loaded at session start
    repository.md            cross-cutting vocabulary
    <domain>.md              loaded only when routed to
  decisions/                 append-only decision records
  designs/                   specs written by the planning stage
  evidence/
    discussions/  research/  prototypes/  out-of-scope/
  tools/                     tool guides, derived per repository
  tickets/<effort>/          spec.md + issues/NN-*.md per effort
  position/                  per-clone state — gitignored, never depended on
  .gitignore                 what per-clone means, and the membership test
```

Knowledge layers are visible in the tree; per-clone state is structurally separated; every category is a directory rather than a naming convention.

## 22. Harness binding — Claude Code

This section binds AEP's concepts to the harness that runs it. Portability to other harnesses is explicitly a non-goal where it would cost the mechanism: any tool that reads markdown can read every file above; what is harness-specific is the *cheapness*.

Claude Code auto-loads exactly two things: `CLAUDE.md` and `.claude/rules/**`. Everything else loads by pointer. Therefore:

- **Boot tier** = `CLAUDE.md` + rules without `paths:` frontmatter. Loaded every turn; kept under a measured, asserted budget. Adding to it is a permanent per-turn tax.
- **Scoped tier** = rules with `paths:` frontmatter, loaded when a covered file is read. A scope announced in prose but not in frontmatter is paid for on every turn and enforced on none — the defect class this binding exists to prevent.
- **Pointer tier** = everything else: the protocol file, policies, contexts, modes, workflows, tool guides, artifacts. The protocol governs this tier; the routing tables are its instrument.

Placement is by loading mechanism, never by topic — a mechanism is observable, a discipline is not. The framework ships as a plugin (`aep`); slash commands are the skills; nothing *committed* requires the plugin — a reader without it follows the same pointers and reads the same files. Only invoking the stages needs it.

## 23. Conventions

The protocol's conventions are defaults for when the repository is silent, never mandates. Where the repository documents or demonstrates its own convention, that convention wins — detect before asserting. Defaults: Conventional Commits (`type(scope): summary`) for commits, PR titles, and issue titles; PR descriptions cover problem, solution, architectural impact, testing, related issues, and breaking changes — never a commit-by-commit account.

## 24. Quality gates

- **The compression test**, before anything is written into knowledge: *will this improve a future engineering decision?* If not, it is not written. Capture is not a license to accumulate.
- **Single home**, mechanically guarded: when a rule is placed, a duplication guard is added, and the guard is confirmed to fail against a deliberate reintroduction before it is trusted.
- **The verification suite is the fidelity floor**: every mechanically checkable acceptance criterion has an assertion; a change that adds a checkable claim without an assertion is untested by construction.
- **The boot budget is asserted**, not estimated — exceeding it fails the build.

---

*End of specification. Amendments are decisions (§16) referencing the section they amend.*
