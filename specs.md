# Agentic Engineering Protocol (AEP) — Specification

**Version:** 1.14.0
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

**The entry stage is determined before anything is touched, stated, and then entered.** A request naming no command still has an activity, and the AI never answers one by telling the human which command to type. Which stage a request enters is mostly *read* rather than judged — whether a claim is held, whether a ticket exists, whether the work arrived from outside — and the judgement that remains is telling a question from a change. The route is stated in the classification line rather than gated on approval, because stating it is what makes a wrong route cost a correction instead of a stage.

**The obligation lives in the boot tier and nowhere else** (§22); the table it routes from lives in the protocol file, with the rest of the routing. The failure being corrected is a stage *not being selected*, and anything that must itself be selected — a router skill above all — cannot correct it, which is what fixes the obligation to the tier that loads unconditionally. The table is not in that tier for the opposite reason: it is a lookup rather than a duty, it names commands, and nothing committed may assume those exist (§22). Consequently a stage the table can name MUST be reachable without being typed, and a stage whose invocation is itself the deliberate act is not a route destination (§11, ADR 0061).

**The table is this repository's actual dependency set**, and that is what distinguishes it from the defaults each skill declares (§11). A skill ships in the framework and cannot know any repository's local guides; the table is written where the repository is, so where the two differ the **table governs**. It is derived by the configuration stage from the skill defaults plus whatever is local, and every stage has exactly one row. A guide a skill declares and its row omits is a defect unless the row records the omission — so dropping one stays possible and stops being silent.

**The table cannot be dropped in favour of the skills' own declarations**, however redundant it looks from inside a session. In a configured repository the skills ship with the framework and are absent from the tree, so the protocol file is the only committed place that can answer what a stage reads — and nothing committed may assume the framework is installed (§22).

## 6. Rules

Rules are universal engineering principles. They are intentionally difficult to change and apply across projects, languages, and repositories.

Rules include, at minimum: never assume facts; verify before implementation; read before modification; preserve architectural consistency; keep changes minimal; prefer understanding over guessing; separate facts from assumptions; communicate uncertainty; maintain traceability.

Rules NEVER describe project workflows or repository conventions — that is what policies are for. A rule is stated as a directive, not as an argument: one clause of rationale survives only where the rule would read as arbitrary without it, because a defended rule invites re-evaluation instead of application.

Rules split by **when they fire** (§22): unconditional rules load every turn and are kept few; scoped rules load only when a file they govern is touched.

## 7. Policies

Policies are the repository's operational agreements: how engineering work is performed *here*. Unlike rules they evolve with the project.

Each policy owns exactly one concern. The canonical set — extensible per repository — covers: version control, the tracker, tickets, specs, decisions, evidence, discussions, knowledge writing, context format, code review, and the sub-agent contract (§20). A testing policy says when tests are required; it does not explain the test framework (that is a tool guide's job). A policy defines expectations, never knowledge.

The sub-agent contract is a policy rather than a second protocol file, because a dispatched child inherits the boot tier and therefore reaches it through the same pointer chain a session uses (§22). A second router would be a second place to look before knowing which one to read (ADR 0040).

Policies are reached by pointer, selected by the stage being run — a stage reads its declared policies and stops. Reading another stage's policies is the cost the routing table exists to remove.

## 8. Contexts

Contexts are engineering knowledge — but they are **navigation, not documentation**. A context is a glossary and a map: which directories are responsible, which terminology is used, which decisions are relevant, which other contexts to consult. It reduces discovery cost; it never replaces the repository as the source of truth.

Contexts contain facts and NEVER instructions. They answer *what is true and where is it found* — never *what should be done*.

Structure: one **map** (the routing table, loaded at session start, small by design — it says which domain context a request touches), one **repository context** (cross-cutting vocabulary only), and **domain contexts** loaded only when the map routes to them. Loading them all defeats the point. Vocabulary that belongs to one stage lives in that stage's policy, not in a context.

A **source pointer** in a context says *start investigating here* — never what APIs or behavior exist there. Pointers are verified before use, always (§19).

**A routing table is generated from fields the routed files declare, never written by hand.** Each routed file declares exactly two things, and they are the table's own columns: its **load condition** — when to load this file — and its **sources**, where its subject lives. The table is rolled up from them.

The load condition is a **sentence about when to load**, never a description of what the file is about. That distinction is the whole mechanism: subject matter answers a question nobody asked, and a keyword list answers it worse. A condition that describes a topic satisfies every mechanical check and is the one failure this shape can still produce.

What generation buys is not brevity. **A generated table cannot disagree with its directory**, because it is not a second statement of the directory's contents — so a file added without fields cannot appear in one, and the obligation to audit a hand-written index for missing rows does not arise rather than being discharged. **A generated file is never hand-edited, and the prohibition is enforced** by comparing it against a regeneration rather than requested of whoever opens it.

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

A design MAY declare, on a build ticket and at design time only, a **design increment**: a scoped decision that only partial code can answer, typed by whether it needs the human present. Implementation resolves a declared increment by invoking the design activity scoped to that increment alone — inline where no human is needed, stopping for the human where one is. Implementation NEVER invents an increment; a decision discovered undeclared blocks the ticket, exactly as before. (ADR 0037.)

**An invocation that named no ticket runs on past the one it delivered**, to the next the declared edges leave unblocked, and stops where the plan already said a human is needed — a declared increment of a type requiring one, a ticket blocked, a decision discovered undeclared, a failure, or no unblocked work left. It invents no bound of its own: the stopping points were chosen at design time, on the tickets, by whoever approved them. An invocation that *named* a ticket delivers that one and ends, because taking another would be choosing work it was not given. Every ticket in a continued run is verified, built, reviewed, and closed out on its own terms; continuation governs what follows a delivery and nothing about how one is produced (ADR 0062).

Additional workflows (release, incident, migration) MAY be added under the same contract: declare a mode, declare dependencies, produce artifacts.

## 11. Skills

A skill is a lightweight entry point to a capability. It contains very little shared methodology — it declares, and the protocol supplies:

- its **purpose** and expected result,
- its **mode** (§9),
- its **dependencies**: the policies, contexts, and tool guides it reads,
- its **constraints** and completion criteria.

A skill NEVER restates what a policy, mode, or guide already owns; it points. Mode and dependency declarations are **fields** under the frontmatter `metadata:` map the harness reserves for third-party data — read by the configuration stage's derivation and asserted by the verification suite, not a parallel manifest. The mode is one posture name, resolving against the modes directory; the dependencies are bare guide names resolving against the policies directory, with `*` meaning the whole of it. Both were prose lines in the body until the harness was found to document that map (ADR 0055); the reason to move was that a prose line is matched in running text and survives only until the paragraph around it is reflowed.

**A skill's declaration is the framework's default, and the protocol table is the instance** (§5). These are two homes for related facts, which single-home would otherwise forbid, and what makes it survivable is that **each can state something the other cannot**: a skill shipping in the framework cannot know a repository's local guides, and a repository cannot ship into the framework. Where that asymmetry is absent, a second home is duplication and this is not a precedent for it. The instance governs on conflict, and the containment runs one way: the table carries at least what the skill declares.

Skills divide into four groups, separated by **direction of reach** rather than by subject. The **spine** is the seven workflow stages. **Primitives** are reached from inside a running stage and composed by it — grilling a plan, test-driven development, codebase design vocabulary, domain modeling. **On-ramps** carry work that arrived outside a plan and end by handing it to a stage — triage, bug diagnosis, merge-conflict resolution, survey, handoff. The **router** is the single skill that explains the workflow rather than performing any part of it. Derived skills carry their upstream attribution; that is a license obligation and survives every rewrite.

A skill is either **selectable**, chosen by the model from its description — which is then the entire basis of selection — or **typed**, reached only when a human names it. Typed is the exception, and it is held by one test rather than by a list: **the skill's subject is not the repository.** Configuring acts on the framework's own installation and handing off on the conversation, so neither can be implied by a description of a repository problem. Every stage a request MAY enter under §5 MUST be selectable; a destination the model cannot select is one the routing rule cannot enter, which reduces that row to the round trip the rule exists to remove (ADR 0063).

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

**Decisions are routed, on the same mechanism contexts use (§8)**: each declares its load condition and its sources, and the index is generated from them. Without it the layer that grows without bound is the one every stage reads whole, and the cost is monotonic — each accepted decision enlarges the unrouted read and nothing ever shrinks it.

A decision additionally declares **supersession at both ends**: what it supersedes, and what supersedes it. Both are written in the same change, so the relationship reads from either end and can be checked from either end. A claim made at one end and absent at the other is a defect, not a stylistic preference — and it is what makes the graph checkable at all. Its **status** is declared too, and remains the one thing that moves after a decision is committed; the reasoning is frozen.

## 17. The knowledge lifecycle

Knowledge flows through predictable stages, and each transition is a real move between artifact kinds:

```
Question → Discussion → Research → Prototype (optional) → Design
        → Implementation → Review → Decision → Context update
        → Repository knowledge
```

Evidence — discussions, research, prototype write-ups, out-of-scope records, and drift findings — shares one property nothing else has: it records what was verified and when, and nothing revalidates it afterwards. A **drift finding** records a knowledge statement checked in passing and found false — what was checked, against which commit, what it falsifies — written by whoever finds it; a falsified decision is the one drift never healed inline, and the finding waits in evidence until a design run heals it. (ADR 0039.)

Every evidence file **declares its kind and what it falsifies as fields**, and the five kinds share **one generated index at the family root** rather than one beneath each: the obligation it serves — read the directory before producing more — is cross-kind, which is what makes the kind column carry information rather than restate the path (ADR 0056). A kind earns its directory when it has a file, so an index is generated over the kinds present and never over a fixed list. Knowledge that proves durable **graduates out of evidence into context**, and that graduation is stated once, in the evidence policy. This is what makes the lifecycle traceable from the original question to the final implementation.

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

**The marker.** Each clone keeps per-clone **position** state — never committed, never depended on by anything shared. The marker records **two facts**: the commit drift was last read against, and a fingerprint of the working tree it was read against. Both are compared, and there is no third condition — a fingerprint of a dirty tree is the same kind of value as a fingerprint of a clean one, so the rule carries no clean-versus-dirty branch.

**What a match licenses is bounded, and the bound is the point.** A match means the drift reads may be skipped: some earlier run already read this exact tree's drift and dealt with what it found. It does **not** mean any knowledge is correct. Verification at use is unaffected by the marker in every case — a statement about to be relied on is checked against the Codebase whether the marker matched or not, and a marker that matched has never been a reason to skip that check. Where the facts differ, drift is read from two sources (what commits changed; what the human changed uncommitted) and only the statements about to be relied on are verified.

**Who writes which fact.** The commit stage writes both, together, so the pair is never half-fresh. Any stage that reads drift and **deals with what it found** — heals it, or discounts it as outside what the work touches and says which — may re-stamp the tree fact alone, leaving the commit fact untouched. The permission is conditional on the dealing, never on the reading: a stage that read drift and neither healed nor discounted it has established nothing and re-stamps nothing. That narrow claim is what makes a second writer safe, because re-stamping asserts only what the re-stamping stage actually did.

**An absent tree fact means the tree is unknown**, and the check falls back to comparing the commit against `HEAD` and reading the tree live. No repository needs converting, and a clone that never gains the second fact loses a shortcut and nothing else.

**Reported, every time.** Every stage that relies on context opens with a one-line verification report — including when there was nothing to verify. Silence is indistinguishable from the check never having run.

**Healing in place.** Fix what you find where you find it: a stale pointer is repaired in the same breath as discovering it; a moved boundary is corrected then and there. No queue, no deferred pass. This is not best-effort — nothing else catches a lapse. A pointer that cannot be recovered by searching for where the concept moved is reported broken, never guessed at.

## 20. Multi-agent engineering

AEP assumes engineering may involve multiple agents — human or AI. Every agent follows the same protocol; agents differ only in objective, mode, loaded contexts, and activity. One agent may research while another designs and a third reviews, and collaboration stays consistent because the protocol is shared.

Coordination is by **assignment and claim, with the branch as the lock**: a ticket is claimed by the clone working it, the claim is visible in the tracker, and shared state never depends on any clone's position files. What may be written to a tracker other people read is bounded by the tracker policy.

**Orchestration is the second relationship, and it is not the first.** Assignment and claim arbitrate between *peers* — instances that dispatch nobody. Orchestration is a stage dispatching sub-agents and integrating what they return, which introduces a direction the peer model has no vocabulary for. Both may hold at once, and how depends on the axis: a claim holds one ticket while children work portions of it, and the unit widens to cover them; a set is claimed ticket by ticket, all of them by the parent, before anything is dispatched. The contract is a policy (ADR 0040).

**Orchestration has two axes, and they invert each other.** A **fan-out** divides one ticket into portions; a **dispatched set** runs several whole tickets that gate none of each other. The words are not interchangeable and no rule crosses between them without being restated, because the answers differ at every point that matters (ADR 0046):

| | Fan-out | Dispatched set |
| --- | --- | --- |
| unit | a portion of one ticket | one whole ticket |
| lands as | one commit for all portions | one commit each, on that ticket's branch |
| on one child failing | nothing integrates | siblings land; that ticket returns to the frontier |
| disjointness | declared, as file ownership | none — edges gate work, not files |
| review | once, in the parent, after integration | requested by each child, findings returned to it |

A dispatching stage works through three artifacts:

- A **brief** — the instruction set for one child: objective, inputs given as paths rather than pasted content, what that child owns — the files, for a portion; the ticket, for a set member — the return shape, done-criteria, and a cap.
- A **role** — a shipped agent definition a brief names. Identity is the definition's name, so an orchestrator holds a name rather than a path or an import; that is what lets an existing capability be dispatched without being rewritten (ADR 0043).
- A **change record** — the manifest a child writes and the orchestrator integrates by, of which the child returns only a path and a compressed summary. It is per-clone position and never evidence, because its subject is a diff about to be integrated (ADR 0042).

Decomposition is declared, never inferred. A build ticket MAY declare a **fan-out** naming the roles that run and the files each owns; a stage NEVER invents one, for the same reason it never invents a design increment (§10, ADR 0043).

A **dispatched set is computed rather than declared**, and that is not the same licence. Its members are the frontier tickets that gate none of each other, read off the declared edges — reading a declaration is not making one. The stage states the set before dispatching. **The parent creates every branch in the set before dispatching anything**, which is how a child still claims nothing: creating the branch is the claim, and the parent makes all of them (ADR 0047). A ticket in a set that declares a fan-out of its own is **built alone by its child, which records that it declined** — one layer is one layer, and the declaration is not honoured recursively (ADR 0046).

A child works an isolated worktree — branched from the claim for a portion, and from that ticket's own branch for a set member — and **the orchestrator is the only integrator** — enforced by the harness rather than assumed, since an isolated child's version-control commands fail if they reach the main checkout. Integration reconciles the record against the child's actual diff before anything lands. For a fan-out, a mismatch stops the whole fan-out: a manifest that cannot be trusted still reads as a check that happened (ADR 0044).

For a set, the failure that has no analogue in a fan-out is a **collision** — two children writing one path, which the declared edges never promised against, because an edge gates work and says nothing about files. **Resolving it belongs to the orchestrator**, by the mechanism its own version-control model provides, and it is resolved rather than refused: the orchestrator holds both change records, so it knows what each child believed it was doing rather than only what each hunk says (ADR 0048).

**Human authority is never delegated downward.** A sub-agent has no surface on which to ask a human — the question tool and plan mode are withheld from it, and no agent's message is another agent's consent. So a child that reaches a decision records it and stops, and the orchestrator raises it: a decision a child cannot make is the same event as a decision discovered undeclared, and blocks the same way. Where the orchestrator can broker the question, stopping means **stopping pending an answer** rather than ending the run — the amendment ADR 0049 makes to this consequence, leaving the principle above it untouched. No increment needing a human is ever assigned to a child (§2, ADR 0041).

**The orchestrator brokers what a child may not do itself**, which is what makes one layer survivable. A child cannot dispatch, so it cannot run any capability that fans out; it requests, the orchestrator performs, and the result returns to the requester, which resumes. The capability is still dispatched **at depth one, from the orchestrator**, so nothing about the bound is bent. **The menu is closed** — a capability that requires dispatch, and a question put to the human — and anything else is refused without being weighed, because an open channel would make every prohibition on a child advisory. A request spends the brief's cap, so a child that keeps asking runs out as one that keeps working does (ADR 0049).

Brokering moves nothing about who answers. The chain is child, orchestrator, human, orchestrator, child: the question travels **attributed** to a child and a ticket, the answer travels **verbatim**, and an orchestrator that cannot relay faithfully stops the child rather than reinterpreting for it — a paraphrase is the orchestrator's answer wearing the human's authority, and it fails silently because the child cannot tell. So a child's return has four outcomes rather than three: done, failed, stopped, and **waiting** (ADR 0049).

Protocol scaffolding is never its own unit of work on a shared surface: no tracker item and no pull request the workflow creates has its entire effect under the protocol directory, except the **design PR** — one per design run, whose entire diff is protocol-only and whose approval is approval of the plan. Everything else rides its consumer: evidence gating a map decision lands in that session's design PR, evidence gating a build ships as a declared increment with the code it unblocked, and drift found in passing is filed as evidence and indexed on the live effort's map, never as a tracker item. The rule reads the diff, never the commit type, and does not bind what humans file. (ADRs 0038, 0039.)

## 21. Repository layout

A conforming repository:

```
CLAUDE.md                    entrypoint: what this is, where machinery lives (boot tier)
specs.md                     this specification (framework repository only)
.claude/
  protocol.md                the protocol file: marker, drift reads, stage→dependency table
  settings.json              harness configuration the workflow depends on (§22)
  rules/                     unconditional (no paths:) and scoped (paths:) rules
  modes/                     one reasoning posture per file, declared by skills (§9)
  policies/                  one file per concern
  contexts/
    map.md                   the routing table — loaded at session start
    repository.md            cross-cutting vocabulary
    <domain>.md              loaded only when routed to
  decisions/                 append-only decision records
  designs/
    map.md                   the design index, where specs are flat
    <slug>.md                specs written by the planning stage
  evidence/
    map.md                   the evidence index — one row per finding, every kind
    discussions/  research/  prototypes/  out-of-scope/  drift/
  tools/                     tool guides, derived per repository
  scripts/                   scripts serving the workflow's own process, derived
  tickets/
    map.md                   the design index — one row per effort's spec
    <effort>/                spec.md + issues/NN-*.md + map.md, per effort
  position/                  per-clone state — gitignored, never depended on
  worktrees/                 the harness's isolated child checkouts — gitignored
  .gitignore                 what per-clone means, and the membership test
```

Knowledge layers are visible in the tree; per-clone state is structurally separated; every category is a directory rather than a naming convention.

**Everything the workflow owns sits in the plugin or under `.claude/`, and `CLAUDE.md` is the only entry it adds at the repository root.** The plugin holds what ships; `.claude/` holds what a repository runs on, including executable content — a script serving the workflow's own process lives in `.claude/scripts/`, while a script that builds or tests what the repository exists to produce is the repository's and stays where that repository keeps it. The test is whose process the file serves, never what it is made of. The always-on rules carry it, so the answer is available on the turn a file is created rather than the turn after.

**An artefact is placed by its scope.** What is per-effort — a spec, its issues, and the fog map that charts it — lives in that effort's directory; what spans every effort lives at the root of `tickets/`. The layout names both, because a layout that named neither is what let two artefacts arrive at one path with nobody noticing (ADR 0059).

## 22. Harness binding — Claude Code

This section binds AEP's concepts to the harness that runs it. Portability to other harnesses is explicitly a non-goal where it would cost the mechanism: any tool that reads markdown can read every file above; what is harness-specific is the *cheapness*.

Claude Code auto-loads exactly two things: `CLAUDE.md` and `.claude/rules/**`. Everything else loads by pointer. Therefore:

- **Boot tier** = `CLAUDE.md` + rules without `paths:` frontmatter. Loaded every turn; kept under a measured, asserted budget. Adding to it is a permanent per-turn tax.
- **Scoped tier** = rules with `paths:` frontmatter, loaded when a covered file is read. A scope announced in prose but not in frontmatter is paid for on every turn and enforced on none — the defect class this binding exists to prevent.
- **Pointer tier** = everything else: the protocol file, policies, contexts, modes, workflows, tool guides, artifacts. The protocol governs this tier; the routing tables are its instrument.

**A sub-agent inherits the boot tier and none of the conversation.** A dispatched child receives the entrypoint hierarchy the parent loaded — including the unconditional rules — alongside its own system prompt and the brief. It does not receive the parent's conversation, tool results, or system prompt. So the three tiers above describe a child as well as a session, and a child arrives already bound by the boot tier: the sub-agent contract (§20) narrows what it may do rather than bootstrapping what it knows (ADR 0040). Two consequences the tiers alone do not give. Anything a child needs from the *conversation* is written into the brief, because the brief is the only parent-to-child channel. And pointer-tier material is reached by the child rather than quoted into the brief, because a child can read — quoting it spends the parent's window to buy nothing.

Placement is by loading mechanism, never by topic — a mechanism is observable, a discipline is not. The framework ships as a plugin (`aep`); slash commands are the skills; nothing *committed* requires the plugin — a reader without it follows the same pointers and reads the same files. Only invoking the stages needs it.

**The release a repository declares is also a cursor.** The configuration stage's audit performs two kinds of work that read alike and are not alike: **standing checks**, true of every conforming repository on every run, and **dated repairs**, true only of repositories left in one historical shape. Dated repairs are grouped by the release that produced the shape each repairs, and an audit considers only those newer than the release the repository declares — every one still recognising its shape by content before acting, so the cursor narrows what is *considered* and never what is *verified*. A repository declaring no release has all of them considered, which is the opposite of what the same absence means to the hook below, and deliberately: absence proves the repository predates the field, silence costs a notification, and a skipped repair costs the repository (ADR 0065).

**One behaviour binds to a harness event rather than to a file.** The protocol file declares the release that wrote it, and a `SessionStart` hook the plugin ships compares that against the running release, saying one line when they differ and nothing when they match. It is a hook because the running release is reachable only from shipped content — the harness exports the plugin's own root to a hook process and to skill content, never to a stage's shell — and because the alternative states the same sentence in every stage that should warn. The property above survives it: a repository without the plugin loses a notification, not a rule, and a protocol file declaring no release is unknown rather than stale.

## 23. Conventions

The protocol's conventions are defaults for when the repository is silent, never mandates. Where the repository documents or demonstrates its own convention, that convention wins — detect before asserting. Defaults: Conventional Commits (`type(scope): summary`) for commits, PR titles, and issue titles; PR descriptions cover problem, solution, architectural impact, testing, related issues, and breaking changes — never a commit-by-commit account.

## 24. Quality gates

- **The compression test**, before anything is written into knowledge: *will this improve a future engineering decision?* If not, it is not written. Capture is not a license to accumulate.
- **Single home**, mechanically guarded: when a rule is placed, a duplication guard is added, and the guard is confirmed to fail against a deliberate reintroduction before it is trusted.
- **The verification suite is the fidelity floor**: every mechanically checkable acceptance criterion has an assertion; a change that adds a checkable claim without an assertion is untested by construction.
- **The boot budget is asserted**, not estimated — exceeding it fails the build.

---

*End of specification. Amendments are decisions (§16) referencing the section they amend.*
