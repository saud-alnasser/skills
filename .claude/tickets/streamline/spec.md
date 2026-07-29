# refactor(skills): load instructions by mechanism, and cut the prose to what changes a decision

Status: draft
Sources: `CLAUDE.md`, `.claude/`, `skills/`, `scripts/verify.ps1`

## Problem

Claude arrives at every turn holding roughly 5.1k tokens of instruction it did not ask for, most of which does not apply to the request in front of it, and then re-derives its bearings anyway.

Three separate causes, measured rather than guessed:

**The always-on files carry conditional content.** `CLAUDE.md` is 8,739 chars across nine sections. On a turn that answers a question, "Conventions" (pull-request description format), "Writing knowledge", and "Requests that would change code" all load and none apply.

**A path-scoped rule is not actually path-scoped.** `.claude/rules/skills.md` is 3,405 chars and carries `Scope: skills/**` as *prose*. Claude Code supports `paths:` frontmatter that would make that scope mechanical; the file has no frontmatter at all, so it loads on every turn — including turns that never open `skills/`. The scope line is an obligation Claude must honour while paying full price for the file.

**The root Context is loaded whole, always.** `CLAUDE.md` instructs Claude to load `.claude/context.md` at session start. That is 8,437 chars and 25 glossary terms, most irrelevant to any given request. `Tier`, `Floor`, and `Gate` load when the work is a docs fix; `Assignment` and `Claim` load when nobody is claiming anything.

Underneath all three: rules are written as arguments rather than directives. Nearly every rule carries a paragraph defending itself. That defence pays for itself exactly once — on a rule that would look arbitrary without it. Everywhere else it is both a token cost and a *thinking* cost, because a defended rule invites re-evaluation instead of application. That is the mechanism behind the reported symptom of considering many tangled, unrelated things before acting.

Measured baseline, before any work begins:

| | raw chars | as loaded | loads because |
| --- | --- | --- | --- |
| `CLAUDE.md` | 8,739 | 7,726 | harness, mechanical |
| `.claude/rules/skills.md` | 3,405 | 3,348 | harness, mechanical — should be conditional |
| `.claude/context.md` | 8,437 | — | `CLAUDE.md` instructs it — behavioural |
| **harness-injected total** | **12,144** | **11,074** | |

**As loaded** is the column that matters, and it is the one to measure against: block-level HTML comments are stripped before injection, so a raw byte count charges the budget for maintainer notes that never reach Claude. Ticket 01 established the corrected figures before being partly reverted.

Everything shipped under `skills/` totals 232,430 chars. It is never loaded at once, but each skill re-establishes shared machinery in its own words, which is why the same understanding is rebuilt on every invocation.

## Goal

Instructions load because a mechanism selected them, not because they were written down somewhere. The always-on budget falls below 5k chars, each skill names the small set of guides it needs, and the prose that survives is the prose that changes a decision.

## Constraints

- **Claude Code's loading mechanics are fixed and must be designed around, not against.** Only `CLAUDE.md` and `.claude/rules/**` are loaded by the harness. Rules without `paths:` frontmatter load unconditionally; rules with it load when Claude reads a matching file. `@path` imports expand at launch and therefore save nothing — only a backticked pointer is lazy. Block-level HTML comments are stripped before injection and are free.
- **Nothing committed may assume Tenure is installed.** A teammate cloning without the plugin must still be able to follow every rule they are given. Reformulated rather than dropped — see ADR 0022.
- **The architecture does not change.** Spine, Primitives, knowledge layers, verification at use, healing in place, the Marker, and the Claim all survive intact. This changes where instructions live and how densely they are written, not what the workflow does.
- **`scripts/verify.ps1` is the only test.** There is no package manifest and no test runner. Its 354 assertions are the sole guard against a broken build.
- **A rule keeps exactly one home.** Redistribution must not become duplication; `$rulePattern` guards are the enforcement.

## Architecture

### Instructions load in three tiers, and the tier is a mechanism

The discriminator is *when the instruction fires*, expressed as a loading mechanism rather than as a topic. Nothing is placed by subject matter, so there is no judgement call at the edges.

| Tier | Loads | Selected by | Holds |
| --- | --- | --- | --- |
| `rules/` without `paths:` | every turn, by the harness | fires unconditionally | engineering standards, precedence |
| `rules/` with `paths:` | when Claude reads a matching file | the **file path** being touched | standards owned by part of the tree |
| `policies/` | by pointer, on demand | the **workflow stage** being run | one repository aspect or workflow concern each |

The third tier exists because `paths:` cannot express "when `/implement` runs". A stage is not a file pattern, so a stage-triggered guide cannot be a rule and must be reached by pointer.

`CLAUDE.md` shrinks to a pointer: what this repository is, and where the machinery lives. `.claude/protocol.md` — renamed from `tenure.md` — becomes the router, holding the Marker, the two drift reads, the verification report, and the table mapping each stage to the policies it reads. It is pointer-read, so a turn that answers a question never pays for it.

### Knowledge splits from routing

`.claude/context.md` becomes `contexts/map.md` — the routing table alone, read first and small — and `contexts/repository.md`, holding only cross-cutting vocabulary. Terms that belong to one stage move to the guide that uses them: `Tier`, `Floor`, and `Gate` to the tickets policy; `Assignment` and `Claim` to the version-control policy; `Spine`, `Primitive`, and `Vendored Skill` to the skill-authoring context.

Evidence keeps its grouping directory. `research`, `prototypes`, and `out-of-scope` share a property nothing else under `.claude/` has — they record what was verified and when, and nothing revalidates them afterwards — which is what makes "graduates out of evidence into Context" name a real move rather than a metaphor.

### Compression keeps the surprising why

Rhetorical amplification goes everywhere. One clause of rationale stays only where the rule would read as arbitrary without it. `verify.ps1` is what makes this checkable rather than tasteful: its assertions are concept-anchored with alternations rather than literal-phrase matches, so a green suite after a rewrite is mechanical evidence that no load-bearing claim was lost.

That guard has a hole worth naming: it only covers claims someone chose to assert. Prose no assertion reaches can be compressed away silently, which is why coverage is audited and closed *before* any compression lands.

### One friction point removed

`/implement` commits after `/review` instead of asking. One ticket is one commit and further changes amend it, so "not yet" and "commit, then amend" already converge on the same tree — the prompt was buying nothing. The push prohibition is what keeps this safe and is unchanged.

## Approach

**Ship first, adopt once, compress last** — enforced by ticket edges rather than by separate efforts. Ticket numbers restart per effort and the branch convention does not encode the effort, so two efforts in flight would collide on `01-`; one effort ordered by edges avoids inventing a problem the repository has documented.

Every structural ticket changes `skills/` only. This repository moves onto the new layout in one ticket, by running the migration rather than by being edited into shape — see ADR 0025. The deciding argument is that the migration has exactly one repository available to prove itself against, and editing this tree as the effort goes leaves that ticket nothing to convert.

```
02  entrypoint points, protocol routes
03  guides ship, one per concern             07  commit follows review
04  context format splits routing            06  skills declare their guides
05  the generated layout
08  the migration converts the old shape     → proven against a fixture
16  adopt here, by running that migration
09  re-anchor the suite, close coverage      → asserts against a tree that exists
10–13  compress, sliced one per context window
14  confirm the budget

17  discussions are evidence                 → after 03, independent of the rest
18  each stage states its posture            → after 06, so skills are rewritten once
```

Tickets 17 and 18 were added after the effort was under way, from a proposed "v2" reframing of the whole repository. Most of that proposal was already built or already scheduled here; what it contributed that was new is these two, and the rejected list below records the rest so the same ideas are not re-argued from scratch. They are appended rather than renumbered, because the branch convention encodes the ticket number and two of these branches are already committed.

Two placements carry the risk and both are deliberate. **Ticket 09 sits before every compression ticket**, because compressing first would leave the suite red across four tickets with no way to distinguish an intended rewrite from a lost claim. **Ticket 16 sits before ticket 09**, so the layout the suite is re-anchored to is one that exists rather than one that is planned.

Ticket 01 landed under the earlier ordering and is left where it is. It reached the shape ADR 0021 targets, so this repository holds part of the new layout early; ticket 16 recognises that rather than duplicating or reverting it.

**Rejected: repository-first, with the templates catching up at the end.** This is how the effort was originally cut, and ticket 01 was built that way. It reverse-engineers the templates from wherever this tree happened to land, and defers every error to somebody else's repository. Reversed by ADR 0025.

**Rejected: reverting ticket 01 to give the migration a clean before-state.** Cut as ticket 15 and dropped. The premise — that this repository is the only tree the migration can be proven against — is false, because the pre-effort tree is recoverable from history. A fixture beats it on repeatability, on coverage, and on not writing a revert-then-redo pair into a history that is this framework's build record. See ADR 0026.

**Rejected: a protocol kernel that mediates all loading.** Proposed as the centre of an "operating system" reframing — `CLAUDE.md` boots a `protocol/` directory, and no component loads anything except through it. There is no mechanism that can enforce it. The harness auto-loads `CLAUDE.md` and `.claude/rules/**` and nothing else, so "do not load until directed" is an honour system, and this repository has already paid for exactly that: `.claude/rules/skills.md` announced `Scope: skills/**` in prose and was charged on every turn until ticket 01 made the scope `paths:` frontmatter. ADR 0021 is the generalisation — placement is by loading mechanism because a mechanism is observable and a discipline is not. A resolver layer is a discipline with a directory.

**Rejected: `modes/` and `workflows/` as separate directories.** Seven of the ten proposed modes had identically-named workflows, which is the signal that the split is nominal rather than real. Rejected for the reason subject-based placement was rejected above: it is a judgement call at every edge, and two directories holding one concept means every future instruction needs an argument about which it is. The useful half — that a stage has a posture nobody has written down — is kept, as ticket 18 (ADR 0028).

**Rejected: a `dependencies.yaml` per skill.** The same rejection as the `policies:` frontmatter field below, arrived at from a different direction. Nothing in any harness reads it, so it would be a second manifest of the pointers already in the prose, free to drift from them. Ticket 06's `Policies:` line is read by the only reader there is and `verify.ps1` asserts every path it names.

**Rejected: designing for vendor portability now.** Conditional loading here rests on `paths:` frontmatter, which other tools either implement differently or not at all. Portable means lowest-common-denominator — "read this file" — which discards the one property ADR 0021 was built on. The committed guides are already readable by any tool that can open a markdown file; what is not portable is the *cheapness*, and paying for portability by giving up the mechanism inverts the trade.

**Rejected: compress first, then restructure.** Every compressed line may land in a different file afterwards, so the same content is reviewed twice and the compression has no settled structure to compress toward.

**Rejected: one pass per area, restructuring and compressing together.** Fewest passes, but between any two tickets the tree is half-migrated and `verify.ps1` must accept both layouts — which weakens the guard at exactly the moment it is carrying the most risk.

**Rejected: splitting `rules/` and `policies/` by subject matter.** It reads naturally to a human and it is a judgement call at every edge, and it contradicts the placement rule this repository already holds — that when a rule fires decides where it lives, and topic similarity is not a placement argument.

**Rejected: uniform caveman compression.** Strips the rationale from surprising rules too. Cheaper in tokens and more expensive in thought, because an arbitrary-looking rule gets re-evaluated on every encounter — the exact failure this spec exists to remove.

**Rejected: a `policies:` frontmatter field on each skill.** Nothing in the harness acts on it, which is the Load-Bearing Frontmatter rule this repository already holds and the reason `tags` was deleted. A `Policies:` line in the body is read by the only reader there is, and `verify.ps1` can assert every path it names.

**Rejected: flattening `evidence/` to `research/` and `prototypes/` at the root.** Fewer levels, but it costs the vocabulary a real referent.

## Acceptance criteria

- The always-on load — every file the harness injects without a pointer being followed — is under 5,000 chars, asserted rather than estimated.
- A rule scoped to part of the tree carries `paths:` frontmatter and does not load when Claude works outside that scope.
- `CLAUDE.md` names no machinery that requires the plugin, and every guide it points at is committed and readable without Tenure installed.
- Each skill states the policies it reads, and every policy named by any skill exists.
- No instruction is stated in two places; `$rulePattern` covers each rule that moved.
- The full set of `verify.ps1` assertions passes after the compression tickets, with coverage audited beforehand so a green run means fidelity was kept rather than untested.
- `/implement` commits after `/review` without asking, and still never pushes.
- Every workflow stage that exists today still exists and still does what it did.

## Risks

- **Compression silently drops a claim no assertion covers.** Likely without mitigation, since `verify.ps1` covers what someone chose to assert and nothing more. Detected by ticket 09's coverage audit, which runs before any compression and closes gaps per file rather than in aggregate.
- **A redistributed rule quietly acquires a second home.** The rules and policies split moves a lot of text between files, and restating a rule where it reads well is the failure this framework exists to prevent. Detected by extending `$rulePattern` in the same ticket as each move, and by confirming each new guard fails against a deliberate reintroduction before it is trusted.
- **`paths:` frontmatter behaves differently across Claude Code versions.** The docs record several behaviour changes in this area within recent versions. Detected by the `InstructionsLoaded` hook, which logs exactly which instruction files loaded and why; ticket 01 uses it to confirm the scoping works rather than assuming it.
- **The compressed prose reads worse to a human maintainer.** Accepted deliberately — the user's stated trade. Bounded by keeping the surprising why, so the files stay auditable even where they stop being pleasant.
- **Ticket 08 has the widest blast radius**, since `/configure`'s templates must match the new layout exactly or a freshly configured repository is born broken. Detected by `verify.ps1`'s existing template assertions, extended to the new file set.

## Out of scope

- Changing what any workflow stage does. The Spine keeps its seven commands and the Primitives keep their four.
- The Marker, drift model, Claim, and healing semantics. They move file; they do not change.
- Adding new skills or removing existing ones.
- Anything about publishing — push, pull requests, and stack submission stay the human's call.
- Re-deriving `.claude/tools/`. The tool references are correct and only their path changes.
