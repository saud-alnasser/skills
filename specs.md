# Agentic Engineering Protocol (AEP) — Specification

**Version:** 2.0.0
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

Ranks 2–5 are collectively **the Codebase**, and against knowledge they are absolute: a context that contradicts the repository is wrong, and is updated — never the reverse, and never explained away. This order resolves *knowledge* conflicts. Conflicts between *instructions* are resolved by precedence over records that **bind** — three ranks, computed from type, store, and firing breadth rather than declared (Part II); a user instruction overrides everything, and the AI says so when it does. A record that only describes has no rank and cannot lose an instruction conflict: it answers to the order above instead.

---

# Part II — Systems

AEP separates engineering into twelve systems. Each answers exactly one question. Sections 5–12 define the eight instruction systems; Part III defines the four artifact systems.

| System | Answers | Stability |
| --- | --- | --- |
| Protocol | how does engineering happen here? | stable |
| Rules | how should an engineer think? | nearly frozen |
| Policies | how is engineering performed in this repository? | framework law, two derived; departure is a declared edge |
| Contexts | what is true, and where is it found? | evolves with code |
| Modes | how should I think during this work? | stable |
| Workflows | what happens, in what order? | stable |
| Skills | what capability is being exercised? | stable |
| Tool guides | how does this repository use its tools? | evolves with tooling |

## The corpus is a store

The systems above are what AEP *distinguishes*. They are not how the corpus is *stored*: a system is not a directory, and a file is not the unit of loading. **The corpus is a flat store of typed, addressable records**, and the type is a declared field rather than a place in a tree.

**Three stores, and every record sits in exactly one.**

| Store | Backed by | Lives at | Holds |
| --- | --- | --- | --- |
| framework | the plugin, never written into a repository | the installed plugin package | `norm` |
| knowledge | files this repository owns | `.claude/knowledge/`, flat — except the boot tier, which stays files under `.claude/rules/` (§22) | `norm`, `context`, `decision`, `evidence`, `reference`, `spec` |
| tracker | files, or the forge | `.claude/tickets/`, or the forge | `ticket`, `map` |

**A type is admitted by write authority crossed with post-write mutability, and by whether the record binds or describes.** Two axes, applied consistently — which reproduced almost exactly the systems above, establishing that they are principled and that the simplification available is fewer *mechanisms* carrying the distinctions rather than fewer distinctions. Every type, and what admitted it:

- **`norm`** — binds. The store is what makes it law or local, which is why `norm` is the one type living on both sides of the framework boundary. A **`fires-when`** field replaces the rules/policies/modes split that the two axes cannot tell apart: `every-turn`, `path`, `stage`, `posture`. A policy is thereby *defined* rather than assumed — a norm whose firing condition is a stage — and a mode is a norm whose firing condition is a posture.
- **`context`** — healed, describes (§8).
- **`decision`** — frozen, binds (§16).
- **`evidence`** — frozen, describes; its five kinds were already a field (§17).
- **`reference`** — derived, describes. The tool guides (§12).
- **`spec`** — lifecycle, then frozen on accept, which is what separates it from evidence.
- **`ticket`** and **`map`** — lifecycle, and the tracker store's. Its backing is pluggable behind a fixed read-only interface, because a forge-backed repository has no ticket files and needs none.

**The `fires-when` vocabulary is closed, and the value it deliberately lacks is the point.** A firing condition the model judges is judged selection wearing a field's clothes — the mis-loading §22's delivery exists to remove — and an open vocabulary readmits it by accident. A value outside the set fails the build. (ADR 0084.)

**A norm firing on a stage names its stages in `stages`, a list field of its own.** The firing condition bounds the *kind* of condition and says nothing about which stages, so the two are separate fields: a norm four stages read is one record naming four, where a qualifier carrying one stage would be that rule copied four times. It is a list rather than a joined value because the store is reached by filters on declared fields (§8) — a list matches exactly, and a joined value would have to be searched inside, which is the loose match that turns a miss into a guess. A `stage` norm naming no stage fails the build, as does one naming a stage no router row carries, and as does `stages` declared beside any other firing condition. (ADR 0099.)

**A norm firing on a posture names its postures in `postures`, on the same terms, and the vocabulary comes from the store rather than from the router.** The two halves of the firing vocabulary are symmetric in shape and differ in where the values are checked, which is a fact about the router rather than an inconsistency: its stage table names every stage, so a stage outside it is refused, and it does **not** name every posture — a skill outside the table declares one too. So a mode record's `postures` entry **is** the definition of that posture, and what would be a refusal becomes a report from the router's side: a posture a row names that no record defines is counted and named, and only where the store holds a mode record at all, a store defining none having nothing to say about it. A `posture` norm naming no posture fails the build, as does `postures` declared beside any other firing condition.

**A norm firing on a path names the globs it covers in `paths`, and the store matches a path against them.** A path-scoped norm is reached by query at the moment a covered file is opened, because no preprocessing runs there (§22) — so the patterns are a declared field rather than something the harness reads out of a file it happens to have open. **Coverage by a glob is the one match that is not equality, and it is not a search**: a path is a fact about the filesystem and membership in a pattern is exact, with no ranking and no near miss, where the pattern comes from the record and the path from the caller. The vocabulary is checked against nothing — a glob covering no file today covers one tomorrow — but a `path` norm naming no path fails the build, as does `paths` declared beside any other firing condition.

**The file is authored; the record is addressed.** Files stay the unit humans write, review, and diff. A record is the smallest span that is correct on its own, carried by a heading, with a short opaque id declared in frontmatter and bound to its span by anchor; a file with no headings is one record. The id is what makes a norm citable, supersedable, and checkable — it carries the fidelity floor. **The build mints ids**, and an unlabelled heading fails the build rather than being silently skipped. (ADRs 0085, 0090, 0096.)

**One instruction per record.** A record stating more than one imperative fails the build, which unifies instruction count with the span rule: the corpus shrinks rather than the row. The count is **reported, never thresholded** — a threshold cannot tell accumulation from regression, and the cheapest response to a crossing is to raise it, which erodes the guard (§24, ADR 0093).

**Nothing derived is committed.** Markdown is committed and diffed; the index over it is local, gitignored, and rebuildable, and a prebuilt ledger ships inside the published plugin package as a release artifact rather than as source. (ADR 0090.)

**Precedence orders binders only** — what the user said, then decisions, then norms by firing breadth. Three ranks, **computed from type, store, and `fires-when`, never declared**, so no record can carry a wrong rank. `context`, `evidence`, `reference`, and `spec` leave the ladder, because a record that never instructs cannot lose an instruction conflict; they answer to the truth order (§4) instead. **A decision outranks a norm and the conflict is productive** — the norm is amended in the same change rather than silently suppressed. A conflict is **returned with both records and their ranks**, never resolved into one, because resolving it silently is the diagnosed cause of settled questions being re-asked. (ADR 0086.)

**Every record declares its owner**, and the owner is read off that field, never inferred from where the record sits. `framework`-owned records are law: they ship in the plugin, are never copied into a repository, and are never edited, healed, or argued with in a session. `repository`-owned records are the repository's to heal exactly as §19 describes.

**The byte-lock apparatus dissolves with copying.** Per-file version stamps, template-versus-copy comparison, and the configuration audit's coverage sweep existed only because framework files were copied into a repository, and under 2.0 nothing is copied. What survives is **the core** — the entrypoint and the unconditional rules, which stay files because the harness loads them by name (§22) — and those keep their release stamps: each declares `version`, the release that last changed its content, a Declared Field that routes a reader's attention and settles nothing. (ADRs 0084, 0088.)

**A copied script keeps a stamp too, and its comparison is a session hook rather than a build.** Copying is the one thing 2.0 still does, so it is the one place the apparatus keeps a subject — and the comparison cannot run in the repository, whose build cannot resolve the plugin's root to find what it would compare against. So each copy declares the release it came from and the session-start hook, the only surface holding both sides, reports a mismatch once. **What that catches is a copy an upgrade left behind, and nothing else**: a hand-edited copy declaring the current release passes, because a hook that runs once a session is not a diffing tool. An undeclared release is unknown rather than stale, on the same terms as an unstamped core file.

**A repository norm contradicting a framework norm is not a precedence question.** It is a **declared deviation**, and under 2.0 it is a `deviates-from` edge on the record that departs rather than a paragraph in a file: allowed, carrying its reason and the release it was declared under, and reported by **every build** until the framework grows a point or the repository conforms. It is reported rather than resolved because its target sits in a store the repository's build cannot see (§24); what that build does catch is an edge declaring no record at all, which is wrong without reference to the other store and fails. Loud by construction, rather than loud to whoever opens the right file — and removing the edge removes the report with no other edit. Extension points remain census-derived, never invented: a point ships only where a committed **variation census** shows the variation is real. The deviation channel is load-bearing — without a loud escape hatch, fixed law pressures repositories to fork silently, which is worse than the disease. (ADRs 0073, 0078, 0095.)

**A framework-owned record states its norm as a checkable imperative or table carrying a one-line why.** The full rationale — history, what a rule does not mean, the failure stories — lives in the framework repository's specification and Decisions and is not shipped. Mechanism stays beside the norm when short and in a `reference` when long. Clarity is never traded for compression: the audience is the model alone, so human-comfortable prose may go, but a norm stays unambiguous and complete at any density — and a norm whose why cannot be stated in one line is not understood well enough to ship. (ADR 0074.)

## 5. The Protocol

The protocol is the operating system. It defines how engineering happens: initialization, dependency resolution, execution lifecycle, orchestration, context management, conflict resolution, and session management.

The protocol contains **no repository knowledge, no project documentation, and no implementation guidance.** It orchestrates those things; it never is them.

Every engineering activity begins with the protocol, and nothing bypasses it, with one bounded exception: the **boot tier**. The harness loads the repository entrypoint and the unconditional rules directly, before any protocol logic can run (§22). The protocol therefore governs everything *past boot* — every pointer followed, every policy loaded, every mode assumed, every artifact written. The boot tier is kept minimal precisely so that the governed surface is nearly everything.

For each task the protocol determines: the activity, the objective, the mode, the workflow, the applicable policies, the required contexts, the relevant tool guides, and the completion requirements. The concrete routing lives in one committed file per repository — the protocol file — holding the stage→dependency table and the verification machinery (§19), reached by pointer so a turn that only answers a question never pays for it.

**The entry stage is determined before anything is touched, stated, and then entered.** A request naming no command still has an activity, and the AI never answers one by telling the human which command to type. Which stage a request enters is mostly *read* rather than judged — whether a claim is held, whether a ticket exists, whether the work arrived from outside — and the judgement that remains is telling a question from a change. The route is stated in the classification line rather than gated on approval, because stating it is what makes a wrong route cost a correction instead of a stage.

**The obligation lives in the boot tier and nowhere else** (§22), and the entry table it routes from lives beside it in that tier, in norm form (ADR 0075). The failure being corrected is a stage *not being selected*, and anything that must itself be selected — a router skill above all — cannot correct it; a table behind a pointer is consulted only by the turn that already routed, which is the same failure one layer down. The table names **activities, never commands** — an activity is the stable thing and a command is one surface for reaching it, so a table written in commands would have to be rewritten every time an invocation moved: the classification line states the stage, and the protocol file states how each stage is reached. The entry table has one home, the tier; the protocol file carries the stage→dependency table and does not restate the entry rows. A stage the table can name MUST be reachable without being typed, and a stage whose invocation is itself the deliberate act is not a route destination (§11, ADR 0061).

**The table is the framework's, and it still governs where a skill's own dependency line differs** (§11) — the skill lines are the plugin's defaults, and the table is the one statement the row assembler resolves against, so a disagreement is settled by what delivery actually reads. Every stage has exactly one row, the rows move only with the release, and a repository whose needs differ from a row records a deviation rather than editing one; a guide a skill declares and its row omits is a defect in the release, not a local repair. (ADR 0079, superseding the per-repository derivation ADR 0054 described.)

**A row is mandatory and exact.** A stage receives its whole row and nothing in the corpus instructs a stage to choose among its guides: judged selection is the mis-load being removed. A row that cannot be afforded whole is a row that is too big, and the fix is cutting the corpus, never restoring selection. (ADRs 0075, 0093.)

**A row is a filter over norms, not a list of files, and it is delivered rather than queried.** The row is *every norm whose `fires-when` matches this stage*, arriving in the computed precedence order of Part II. **Two conditions match a stage and they are not one fact**: a `stage` norm naming it, and a `posture` norm naming the posture that stage runs under — a mode is delivered when a stage declaring it starts (§9), so the mode arrives with the row or nowhere, and a row therefore names a posture. A stage's declared row size counts both, because a figure counting only the first would report a row smaller than the one delivered. Preprocessing assembles it and inlines it before the skill's content reaches the model — zero model round trips and no judgement at any point. A query cannot serve this: a query is judged selection by construction, which is the failure the row exists to prevent. What the query does serve is stated in §8. (ADR 0089.)

**Delivery is bounded by measured harness limits, never assumed ones.** A single substitution above the measured cap is withheld and replaced by a preview and a path, but the cap is **per substitution rather than per assembled body** — so the assembler emits a row as several commands each under it, and the whole row arrives inline. The cost is per command rather than per byte, which is why the emitted size is as large as the proven floor allows and the chunk count as small.

**The table cannot be dropped in favour of the skills' own declarations**, however redundant it looks from inside a session. The row assembler resolves a stage against the table, so it is the one statement of what a stage reads that the delivery path itself depends on; a skill's own line is a default the framework ships (§11).

## 6. Rules

Rules are universal engineering principles. They are intentionally difficult to change and apply across projects, languages, and repositories.

Rules include, at minimum: never assume facts; verify before implementation; read before modification; preserve architectural consistency; keep changes minimal; prefer understanding over guessing; separate facts from assumptions; communicate uncertainty; maintain traceability.

Rules NEVER describe project workflows or repository conventions — that is what policies are for. A rule is stated as a norm (Part II): a checkable directive carrying its one-line why. The why is a floor, not an opening argument — a defended rule invites re-evaluation instead of application, and an unreasoned one is misapplied at exactly the edges the reason would have caught.

Rules split by **when they fire** (§22): unconditional rules load every turn and are kept few; scoped rules load only when a file they govern is touched. Rules the framework installs declare `framework` ownership; a standard the repository discovered in its own tree is repository-owned and stays so.

## 7. Policies

Policies are the framework's operational law: how engineering work is performed under the protocol. **A policy is a norm whose firing condition is a stage** (Part II) — the definition rather than a description, which is what lets policies stop being a separate mechanism. A policy describing the workflow is `framework`-owned and served from the framework store, so it is never copied into a repository and never varies there. Two canonical policies describe the *repository* instead — the tracker and version control — and are derived: `repository`-owned records in the knowledge store, their machine-read facts declared as fields, their prose elaborating those fields in the repository's own terms. Reasoned departures enter through Decisions, and anything else is a `deviates-from` edge. A policy the repository adds beyond the canonical set is repository-owned.

Each policy owns exactly one concern. The canonical set — extensible per repository — covers: version control, the tracker, tickets, specs, decisions, evidence, discussions, knowledge writing, context format, code review, and the sub-agent contract (§20). A testing policy says when tests are required; it does not explain the test framework (that is a tool guide's job). A policy defines expectations, never knowledge.

The sub-agent contract is a policy rather than a second protocol file, because a dispatched child inherits the boot tier and therefore reaches it through the same pointer chain a session uses (§22). A second router would be a second place to look before knowing which one to read (ADR 0040).

A stage receives the policies its row's filter selects (§5) and stops — reading another stage's policies is the cost the row exists to remove.

## 8. Contexts

Contexts are engineering knowledge — but they are **navigation, not documentation**. A context is a glossary and a map: which directories are responsible, which terminology is used, which decisions are relevant, which other contexts to consult. It reduces discovery cost; it never replaces the repository as the source of truth.

Contexts contain facts and NEVER instructions. They answer *what is true and where is it found* — never *what should be done*.

A context is a `context` record in the knowledge store (Part II). One holds cross-cutting vocabulary and the rest hold one engineering domain each; they are reached by the query below rather than by a hand-maintained index, and loading them all defeats the point. Vocabulary that belongs to one stage lives in that stage's policy, not in a context.

A **source pointer** says *start investigating here* — never what APIs or behavior exist there. Pointers are verified before use, always (§19). **A pointer is declared on the file and inherited by every record in it, overridable per record.** The asymmetry with a declared edge is deliberate and not an oversight: an edge names an id, a pointer names a path, because a pointer targets the Codebase and the Codebase has no ids. (ADR 0094.)

**The routing table is a query, not a file.** What a hand-written index could get wrong — a row pointing at nothing, a file added without a row — a generated table already could not; a query removes the artifact entirely, and with it the regeneration that every knowledge change used to carry. Records declare the fields the query filters on, and the store answers.

**The query serves only what the row deliberately excludes** (§5): a path-scoped norm on a file being read, a cross-store norm cited by id, and the mid-turn lookup for a question the row does not settle. Everything a stage needs for its own work arrives by delivery, so the query is the exception rather than the entry point.

**There is no free-text search, only filters over declared fields.** That is what makes a miss **a true statement about the store rather than a failed search** — a query for a field value no record carries returns an empty result distinguishable from an error, where a search that found nothing is indistinguishable from a search phrased wrong. Enumerating a field's distinct values is a filter like any other, so the vocabulary is discoverable rather than remembered. (ADR 0089.)

**A query returns the declared-edge closure of its match, computed by the store in one call.** Returning edge ids for the caller to fetch makes each hop a model decision, and makes *not following* an edge indistinguishable from there being nothing to follow. **Depth is a property of the edge type, declared once in the store and never a query parameter** — a global depth is too large for one edge and too small for another, so each number is a fact about what that edge means rather than a figure somebody tuned. It is declared by **one record per edge type**, so the depths are reachable through the surface they govern rather than carried in the script, which would be a second home free to disagree with the one a reader edits; an edge no record declares a depth for is refused rather than walked at a default. Distance is counted per edge type rather than over the walk, which is what makes each number a statement about its own edge. (ADR 0092.)

**The query reads one derived index per store, and a repository that cites across the boundary holds a copy of the other.** A stage's shell cannot resolve the plugin's root, so the framework store's prebuilt index is copied in at configuration exactly as a script is, and is stale on the same terms — the wall that makes a `deviates-from` edge reported rather than resolved (§24), met from the other side. Every record declares which store it belongs to, so the two never blur, and an answer states what each store contributed: a repository that never copied the index and a citation that genuinely matches nothing would otherwise return the same empty result, and only one of those is a configuration fault.

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

A mode is shared across many activities — review mode applies equally to code, architecture, documentation, and tests. That sharing is why a mode is stated once rather than repeated inside each skill. Each skill declares exactly one mode; the mode's tradeoffs are stated once, in the mode.

**A mode is a `norm` whose firing condition is a posture** (Part II), naming that posture in `postures` and delivered when a stage declaring it starts. Placement carries nothing: the two fields say when a mode fires and which posture it is, so the directory that used to say both has no work left to do. (ADR 0084, superseding ADR 0032.)

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

A skill NEVER restates what a policy, mode, or guide already owns; it points. Mode and dependency declarations are **fields** under the frontmatter `metadata:` map the harness reserves for third-party data — read by the configuration stage's derivation and asserted by the verification suite, not a parallel manifest. The mode is one posture name and the dependencies are bare record subjects, and **both resolve against the store rather than against a directory** — a posture is whatever a mode record declares in `postures`, a dependency is a norm the store carries, and `*` means every norm a stage can receive. The declarations themselves did not move when the directories did, because a name that never carried a path had nothing to correct. Both were prose lines in the body until the harness was found to document that map (ADR 0055); the reason to move was that a prose line is matched in running text and survives only until the paragraph around it is reflowed.

**A skill's declaration is the framework's default, and the protocol table is the instance** (§5). These are two homes for related facts, which single-home would otherwise forbid, and what makes it survivable is that **each can state something the other cannot**: a skill shipping in the framework cannot know a repository's local guides, and a repository cannot ship into the framework. Where that asymmetry is absent, a second home is duplication and this is not a precedent for it. The instance governs on conflict, and the containment runs one way: the table carries at least what the skill declares.

Skills divide into four groups, separated by **direction of reach** rather than by subject. The **spine** is the seven workflow stages. **Primitives** are reached from inside a running stage and composed by it — grilling a plan, test-driven development, codebase design vocabulary, domain modeling. **On-ramps** carry work that arrived outside a plan and end by handing it to a stage — triage, bug diagnosis, merge-conflict resolution, survey, handoff. The **router** is the single skill that explains the workflow rather than performing any part of it. Derived skills carry their upstream attribution; that is a license obligation and survives every rewrite.

A skill is either **selectable**, chosen by the model from its description — which is then the entire basis of selection — or **typed**, reached only when a human names it. Typed is the exception, and it is held by one test rather than by a list: **the skill's subject is not the repository.** Configuring acts on the framework's own installation and handing off on the conversation, so neither can be implied by a description of a repository problem. Every stage a request MAY enter under §5 MUST be selectable; a destination the model cannot select is one the routing rule cannot enter, which reduces that row to the round trip the rule exists to remove (ADR 0063).

## 12. Tool guides

Tool guides state how *this repository* uses external software — Git, the forge, the package manager, the test runner. They never replace official documentation; they record the invocations, flags, and conventions this repository has settled on, derived from the repository rather than from ecosystem convention. A tool guide is a `reference` record in the knowledge store (Part II) — derived, and describing rather than binding. Derivation filters whole entries; it never summarizes.

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

**Decisions are reached by the query, on the same mechanism contexts use (§8)**: each declares its load condition and its sources, and the store filters on them. This is the layer that grows without bound, and under a whole-file index the cost was monotonic — each accepted decision enlarged a read every stage paid and nothing ever shrank it. A query is what breaks that: an added decision changes the store's contents and not any stage's row.

A decision additionally declares **supersession at both ends**: what it supersedes, and what supersedes it. Both are written in the same change, so the relationship reads from either end. A claim made at one end and absent at the other is a defect, not a stylistic preference — and under 2.0 it is a defect **the build catches**. Two checks, and the second is not implied by the first: every declared edge is **resolved**, failing when its target is an id no record carries; and the supersession pair is checked for **symmetry**, failing when one end names a record that does not name it back. Resolution alone passes an asymmetric pair — a `superseded-by` pointing at a record that exists resolves perfectly well while that record says nothing in return, which is exactly the half-written supersession the rule exists for. The closure a query returns (§8) depends on both: a closure over a broken edge returns a quietly smaller set. **A decision a finding falsifies declares `falsified-by` naming it, on exactly these terms.** The pair is symmetric, written in the same change, and checked in both directions, because it carries the one thing a frozen record cannot carry itself: a correction. An ADR's prose freezes on commit, so a wrong clause in a sound argument has nowhere to go — and supersession is the wrong instrument for it, retiring a live decision so that one sentence can change. The edge is what makes the correction reachable from the record it corrects rather than only from the index, and the reader it exists for is the one who opened the record. **Reach for it where the argument holds and a clause is wrong; reach for supersession where the decision itself is.** (ADR 0103.)

Its **status** is declared too, and it moves after commit alongside the two edges above; the reasoning is frozen. **The three that move are pointers rather than reasoning**, which is what admits them — saying that a record is retired, replaced, or contradicted changes nothing about what it decided.

## 17. The knowledge lifecycle

Knowledge flows through predictable stages, and each transition is a real move between artifact kinds:

```
Question → Discussion → Research → Prototype (optional) → Design
        → Implementation → Review → Decision → Context update
        → Repository knowledge
```

Evidence — discussions, research, prototype write-ups, out-of-scope records, and drift findings — shares one property nothing else has: it records what was verified and when, and nothing revalidates it afterwards. A **drift finding** records a knowledge statement checked in passing and found false — what was checked, against which commit, what it falsifies — written by whoever finds it; a falsified decision is the one drift never healed inline, and the finding waits in evidence until a design run heals it. (ADR 0039.)

Every evidence record **declares its kind and what it falsifies as fields**, and the five kinds are reached by one filter over the store rather than by an index per kind: the obligation it serves — read what exists before producing more — is cross-kind, which is what makes the kind carry information rather than restate a path. **`falsifies` names an id**, so the build resolves it and a finding cannot point at knowledge that has moved (§16, ADR 0094). Knowledge that proves durable **graduates out of evidence into context**, and that graduation is stated once, in the evidence policy. This is what makes the lifecycle traceable from the original question to the final implementation.

Maintenance is incremental, never repository-wide: when knowledge changes, only affected artifacts are updated. There is no synchronization pass (§19).

---

# Part IV — Operation

## 18. Composition

Every engineering task is assembled from the systems, never from one monolithic document:

```
norm  fires-when: every-turn  → philosophy       (pushed; every turn)
norm  fires-when: posture     → reasoning        (the mode the skill declares)
norm  fires-when: stage       → expectations     (the policies of the skill's row)
norm  fires-when: path        → scoped standards (reached when a covered file is read)
workflow                      → execution order  (the skill's own procedure)
context / reference / spec    → knowledge        (reached by query, on demand)
skill                         → the entry point the row is assembled for
```

**Composition happens before the stage reads anything.** The four `fires-when` values are the whole of what selects a norm, and the row assembler resolves them for the stage being entered (§5) — so the assembly is computed rather than performed by a model deciding what it needs. No single document contains the methodology; it emerges from composition. A skill that inlines a policy, a norm that restates another norm, a context that gives an instruction — each is a conformance defect.

## 19. Verification and healing

**Verification at use — never a scan, never a phase.** There is no synchronization stage. At the moment a context statement is about to be relied on, it is checked against the Codebase. Scope is what the work touches; drift elsewhere is not this request's problem.

**The marker.** Each clone keeps per-clone **position** state — never committed, never depended on by anything shared. The marker records **two facts**: the commit drift was last read against, and a fingerprint of the working tree it was read against. Both are compared, and there is no third condition — a fingerprint of a dirty tree is the same kind of value as a fingerprint of a clean one, so the rule carries no clean-versus-dirty branch.

**What a match licenses is bounded, and the bound is the point.** A match means the drift reads may be skipped: some earlier run already read this exact tree's drift and dealt with what it found. It does **not** mean any knowledge is correct. Verification at use is unaffected by the marker in every case — a statement about to be relied on is checked against the Codebase whether the marker matched or not, and a marker that matched has never been a reason to skip that check. Where the facts differ, drift is read from two sources (what commits changed; what the human changed uncommitted) and only the statements about to be relied on are verified.

**Who writes which fact.** The commit stage writes both, together, so the pair is never half-fresh. Any stage that reads drift and **deals with what it found** — heals it, or discounts it as outside what the work touches and says which — may re-stamp the tree fact alone, leaving the commit fact untouched. The permission is conditional on the dealing, never on the reading: a stage that read drift and neither healed nor discounted it has established nothing and re-stamps nothing. That narrow claim is what makes a second writer safe, because re-stamping asserts only what the re-stamping stage actually did.

**An absent tree fact means the tree is unknown**, and the check falls back to comparing the commit against `HEAD` and reading the tree live. No repository needs converting, and a clone that never gains the second fact loses a shortcut and nothing else.

**Reported, every time.** Every stage that relies on context opens with a one-line verification report — including when there was nothing to verify. Silence is indistinguishable from the check never having run.

**Healing in place.** Fix what you find where you find it: a stale pointer is repaired in the same breath as discovering it; a moved boundary is corrected then and there. No queue, no deferred pass. This is not best-effort — nothing else catches a lapse. A pointer that cannot be recovered by searching for where the concept moved is reported broken, never guessed at. Healing reaches only what the repository owns: a framework-owned file that differs from its release is a defect to reinstall, never drift to heal (Part II).

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
  rules/                     the only norms that stay files, because the harness
                             is the only thing that loads them: unconditional
                             (no paths:), and scoped (paths:) pointers naming
                             the record that carries the norm (§22)
  knowledge/                 the flat store of addressable records (§8) — every
                             type: the postures, the policies, the contexts, the
                             decisions, the designs, the evidence, the tool
                             guides, each declaring its `type` as a field. The
                             evidence kinds are unchanged by the move, and stay
                             a field on the `evidence` type:
                             discussions  research  prototypes  out-of-scope  drift
  scripts/                   scripts serving the workflow's own process, copied
                             from the plugin byte for byte
  tickets/                   the tracker store, where files back it
    <effort>/                spec.md + issues/NN-*.md + map.md, per effort —
                             the per-effort map is authored, not generated
  position/                  per-clone state — gitignored, never depended on,
                             and where every derived artifact lands: the marker,
                             the receipt, the store's ledger
  worktrees/                 the harness's isolated child checkouts — gitignored
  .gitignore                 what per-clone means, and the membership test
```

**Type is a field, so the tree no longer carries the taxonomy** (Part II). The four generated indexes that used to sit beside the directories they described are queries, and nothing derived is committed: what a build produces lands under `position/`, which is the one category the ignore file defines and the reason no new ignore exception is argued for. Per-clone state stays structurally separated, and that separation is now what tells authored content from derived.

**Everything the workflow owns sits in the plugin or under `.claude/`, and `CLAUDE.md` is the only entry it adds at the repository root.** The plugin holds what ships; `.claude/` holds what a repository runs on, including executable content — a script serving the workflow's own process lives in `.claude/scripts/`, while a script that builds or tests what the repository exists to produce is the repository's and stays where that repository keeps it. The test is whose process the file serves, never what it is made of. The always-on rules carry it, so the answer is available on the turn a file is created rather than the turn after.

**An artefact is placed by its scope.** What is per-effort — a spec, its issues, and the fog map that charts it — lives in that effort's directory; what spans every effort lives at the root of `tickets/`. The layout names both, because a layout that named neither is what let two artefacts arrive at one path with nobody noticing (ADR 0059).

## 22. Harness binding — Claude Code

This section binds AEP's concepts to the harness that runs it. Portability to other harnesses is explicitly a non-goal where it would cost the mechanism: any tool that reads markdown can read every file above; what is harness-specific is the *cheapness*.

Claude Code auto-loads exactly two things: `CLAUDE.md` and `.claude/rules/**`. Everything else arrives because the framework put it there — delivered by preprocessing or fetched by query — never because a file happened to be opened. Therefore:

- **Boot tier** = `CLAUDE.md` + rules without `paths:` frontmatter. Loaded every turn; kept under a measured, asserted budget — adding to it is a permanent per-turn tax. Membership is selected by one test: **would this norm's absence on a turn cause behavioral drift.** By it the tier carries, in norm form: the **entry table** (§5); the **no-ask rule** — a loaded norm that settles a question is acted on, citing the line; asking is for genuine forks; the **fixed-owner rule** — a framework-owned file is followed as written, never healed or debated, variation entering only through declared points and anything else a loud declared deviation; and the **verification core** (§19). (ADR 0075.)
- **Scoped tier** = rules with `paths:` frontmatter, loaded when a covered file is read. A scope announced in prose but not in frontmatter is paid for on every turn and enforced on none — the defect class this binding exists to prevent. Under 2.0 this tier **survives as a pointer only**: a `norm` declaring `fires-when: path` is reached by query when a covered file is read, because no preprocessing runs at the moment a file is opened.
- **Store tier** = everything else: policies, contexts, decisions, evidence, references, specs. It arrives two ways and never by a stage deciding which — **delivered** as the stage's row, assembled and inlined by preprocessing before the skill's content reaches the model (§5), or **pulled** by the query for the three cases the row excludes (§8). Nothing here is loaded by opening a file the model chose.

**Delivery is push; retrieval is pull; neither substitutes for the other.** The boot tier stays on harness push because it is the only channel documented to survive compaction and unable to fail silently — a norm that must fire on a turn the user did not start, or before servers have connected, cannot sit behind a tool call. Everything else reaches the store through **two faces, an MCP tool and a CLI**, so an unreachable store leaves a stage **degraded rather than dead**: it still starts, and it says that it is degraded. (ADR 0088.)

**A sub-agent inherits the boot tier and none of the conversation.** A dispatched child receives the entrypoint hierarchy the parent loaded — including the unconditional rules — alongside its own system prompt and the brief. It does not receive the parent's conversation, tool results, or system prompt. So the three tiers above describe a child as well as a session, and a child arrives already bound by the boot tier: the sub-agent contract (§20) narrows what it may do rather than bootstrapping what it knows (ADR 0040). Two consequences the tiers alone do not give. Anything a child needs from the *conversation* is written into the brief, because the brief is the only parent-to-child channel. And pointer-tier material is reached by the child rather than quoted into the brief, because a child can read — quoting it spends the parent's window to buy nothing.

Placement is by loading mechanism, never by topic — a mechanism is observable, a discipline is not. The framework ships as a plugin (`aep`), and slash commands are the skills.

**AEP 2.0 requires the plugin, and the readability promise ends with it.** Through 1.x nothing committed assumed AEP was installed: a reader without it followed the same pointers and read the same files, and only invoking the stages needed the plugin. That guarantee was the constraint shaping the delivery mechanism, and the delivery mechanism is what 2.0 exists to change — a corpus served through a tool is a plugin dependency by construction. So **a repository's engineering norms may be unreadable without running the framework**, the framework store never lands in a repository at all, and **migration from 1.x is a requirement of 2.0 rather than a courtesy** (§21). This reverses a rejection the earlier decision made explicitly, on the argument that a framework whose own installation cannot be read without the framework makes its users a promise it does not keep itself. That argument is not answered here; it is outranked, deliberately and with the cost stated. (ADR 0083, superseding ADR 0022.)

**The release a repository declares is also a cursor.** The configuration stage's audit performs two kinds of work that read alike and are not alike: **standing checks**, true of every conforming repository on every run, and **dated repairs**, true only of repositories left in one historical shape. Dated repairs are grouped by the release that produced the shape each repairs, and an audit considers only those newer than the release the repository declares — every one still recognising its shape by content before acting, so the cursor narrows what is *considered* and never what is *verified*. A repository declaring no release has all of them considered, which is the opposite of what the same absence means to the hook below, and deliberately: absence proves the repository predates the field, silence costs a notification, and a skipped repair costs the repository (ADR 0065).

**One behaviour binds to a harness event rather than to a file.** The protocol file declares the release that wrote it, and a `SessionStart` hook the plugin ships compares that against the running release, saying one line when they differ and nothing when they match. It is a hook because the running release is reachable only from shipped content — the harness exports the plugin's own root to a hook process and to skill content, never to a stage's shell — and because the alternative states the same sentence in every stage that should warn. A protocol file declaring no release is **unknown rather than stale** — absence is not evidence of drift, and treating it as such would warn every repository that predates the field.

## 23. Conventions

The protocol's conventions are defaults for when the repository is silent, never mandates. Where the repository documents or demonstrates its own convention, that convention wins — detect before asserting. Defaults: Conventional Commits (`type(scope): summary`) for commits, PR titles, and issue titles; PR descriptions cover problem, solution, architectural impact, testing, related issues, and breaking changes — never a commit-by-commit account.

## 24. Quality gates

- **The compression test**, before anything is written into knowledge: *will this improve a future engineering decision?* If not, it is not written. Capture is not a license to accumulate.
- **Single home**, mechanically guarded: when a rule is placed, a duplication guard is added, and the guard is confirmed to fail against a deliberate reintroduction before it is trusted.
- **The verification suite is the fidelity floor for what ships**: every mechanically checkable acceptance criterion has an assertion; a change that adds a checkable claim without an assertion is untested by construction. **A record's id is the fidelity floor for a norm** (Part II) — the two are different floors under one name, and each is stated with its subject rather than left to context: the suite catches a shipped claim nothing checks, the id catches a norm that was lost.
- **A span nothing can address fails the build** (Part II) — the unlabelled heading is named with its file, the multi-imperative record with its count.
- **A declared edge resolves, or the build fails**, naming the citing record, the field, and the id — `supersedes`, `superseded-by`, `part-of`, `blocked-by`, `falsifies`, and `falsified-by` alike. **`sources` is not an edge**: a pointer names a path because it targets the Codebase, which has no ids to name (§8), and `deviates-from` names a record in the framework store this build cannot see, so it is reported on every run rather than resolved — with the one exception that an edge declaring no record fails, a fault needing nothing from the other store to be visible. **Two pairs are additionally checked for symmetry** (§16) — supersession, and falsification — which resolution does not imply. An unreferenced record is **reported, never failed**: only a human can tell an orphan from a root.
- **The boot budget is asserted**, not estimated — exceeding it fails the build, and it is reported as a figure of its own, because the tier is paid on every turn where a row is paid once.
- **Authored size and generated size are separate figures, per row**, so that **adding a decision moves no authored figure**. A single total mixes prose that should not grow with derived content that must, and the regression a bound exists to catch then reads exactly like ordinary accumulation.
- **The corpus's instruction count is reported and never thresholded** (Part II) — and the effort that raises the figure is the one that answers for it.
- **A fixed-core procedure is computed, or it names its judgement**: whatever a script can compute ships as a derived script step whose output the stage quotes, and an irreducible judgement states its inputs and its one question — no procedure instructs unstructured judgement. (ADR 0078.)
- **Conversion is manifest-driven**: a normative file is rewritten only against a numbered inventory of its norms, every row gains a fire-checked suite guard, and the mechanism is proven by a seeded deletion — the guard watched failing with that norm's name — before any further conversion relies on it.
- **Extension points are census-derived**: a point ships only tracing to a row in the committed variation census (Part II); a point with no row does not ship.
- **Deviation age is computed**, from the release the deviation declares (Part II) — one release without a disposition fails the audit.

---

*End of specification. Amendments are decisions (§16) referencing the section they amend.*
