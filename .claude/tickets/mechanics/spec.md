---
owner: repository
status: implemented
sources:
  - specs.md §5, §8, §9, §11, §19, §22, §24
  - .claude/protocol.md
  - .claude/position/marker.json
  - skills/configure/SKILL.md
  - skills/configure/MIGRATION.md
  - skills/configure/protocol.template.md
  - skills/configure/tools/git.md
  - skills/configure/policies/context.template.md
  - skills/configure/policies/decisions.template.md
  - skills/configure/policies/evidence.template.md
  - agents/
  - scripts/verify.ps1
  - .claude/decisions/0002, 0021, 0025, 0051
---

# feat(skills): the mechanics declare what they know, and indexes stop being hand-written

## Problem

Four mechanics carry less than they know, and each one pays for it in the same currency: a reader has to open files to recover a fact that was already established and never written down.

**The Marker throws away half its answer.** Its check is `commit == HEAD AND tree clean`. The first half is an identity test; the second is a liveness test, and that asymmetry is the defect. Any dirty tree — one edit the human is sitting on, a scratch file, a local settings change — invalidates the cache, and it does not recover until a commit lands. On a repository where work in progress is normal the Marker is off more often than it is on, so every stage pays two drift reads forever, over drift that the previous stage already read and dealt with.

**Decisions are unrouted and growing.** Fifty-one ADRs, roughly a hundred kilobytes, and the review stage's row names the directory. Contexts were given a routing table for exactly this reason; Decisions never were. The cost is monotonic — every accepted ADR makes the unrouted read larger — and there is no point at which it self-corrects.

**Two files state which guides a stage reads, and they have already drifted.** The protocol's stage table names the tool guides and the forge reference; the skills' own dependency lines do not. Nothing reconciles them, and nothing said which was authoritative, so the divergence was invisible until it was looked for.

**Evidence cannot say it has been consumed.** A drift finding that has been healed sits beside one still waiting, in the same directory, in the same shape. The discovery step of every future design run reads both and re-derives which is which. This was demonstrated during the grill that produced this spec: the one finding on disk had already been healed in the policy it falsified, and proving that cost two file reads and a question that should never have been asked.

Underneath all four is one shape. A fact was established — this tree's drift was read; this ADR governs that area; this table is the authoritative one; this finding is spent — and the mechanism had nowhere to put it, so the next reader pays to establish it again.

## Goal

Each of the four mechanics records what it already knows, in a field something acts on. The Marker survives a dirty tree. Decisions load on demand through an index nothing maintains by hand. The stage-dependency set has a stated precedence rather than two silent copies. A spent drift finding says so.

## Constraints

- **Load-bearing frontmatter.** A field exists only if something acts on it. This repository deleted `tags` rather than maintain them, and every field this spec adds must name its reader or not be added.
- **ADR 0002 is not being reversed.** It rejected frontmatter tags for context loading because tags say what a file is *about* while the agent's question is *when to load it*, and because a table sits where the agent already is. Both hold. What changes is only the table's authorship.
- **Verification at use is untouched.** Nothing here widens what the Marker licenses. It stays a cache-validity test over the drift read, never a substitute for checking a statement against the Codebase at the moment of reliance.
- **Nothing committed may assume the plugin.** In every repository but this one, `skills/` ships in the plugin and is absent from the tree, so the protocol file is the only committed place that can answer what a stage reads.
- **Templates change before this repository adopts them** (ADR 0025). The shipped surface and the installed copies move in separate tickets, and the suite's installed-matches-template assertions belong to the adoption tickets.
- **One effort, one commit** (ADR 0051). No ticket here gets its own branch, and no dispatched set runs.

## Architecture

**The Marker gains a tree fingerprint, and its claim is narrowed to what it earned.** The file becomes `{ commit, tree }`. A match on both licenses exactly one thing: skipping the two drift reads. It does not mean context is correct — it means a previous run already read this tree's drift and either healed it or judged it irrelevant. That narrowing is what makes a second writer safe: any stage that finishes a drift read and deals with what it found may re-stamp `tree`, leaving `commit` alone, because re-stamping asserts only what that stage actually did. The commit stage still writes both.

The fingerprint is a real git tree object, built through an index seeded from the repository's own so the stat cache carries over and only changed files are re-hashed. A clean tree and a dirty tree take the same path and both produce a sha, so the rule is one comparison with no clean-versus-dirty branch anywhere in it. A marker with no `tree` key falls back to the live clean test, so nothing needs migrating.

**Declared fields, with the index derived from them.** Contexts and Decisions each gain frontmatter carrying the two things a router needs — *when to load this* and *where its subject lives* — and the routing table is generated from those fields rather than written by hand. This is the shape ADR 0002 did not weigh: it compared a hand-written table against tags *instead of* a table, and chose the table on the strength of the trigger sentence. The trigger sentence survives here unchanged; only the hand disappears. In exchange, the drift ADR 0002 accepted as a consequence — a table that goes stale when a file is added without a row — becomes impossible rather than audited.

Decisions carry a supersession pair as well, which makes a graph the suite can check for symmetry. Today two ADRs claim to be superseded and nothing verifies that the superseding file agrees.

**The stage-dependency set has two homes with a declared winner.** They are not duplicates once each is named: a skill's dependency line is the workflow's default, shipped in a plugin that cannot know any repository's customisations; the protocol table is *this* repository's actual set, written by configure from those defaults plus whatever is local. The table wins where they differ. The alternative — deleting one — was rejected in both directions: deleting the table breaks the plugin-independence guarantee, and deleting the skill line leaves a repository mid-configure with no dependency set at all.

**A consumed drift finding records its consumption.** Evidence already distinguishes findings that graduated from findings that have not; the drift directory could not express it. The record names where the healing landed, which is a pointer a later reader follows instead of re-deriving.

**Existing repositories reach all of this through the configuration stage, and it is the only thing that can reach them.** Every mechanic here lands in a file a configured repository already has, so the generate step passes over all of it — the files exist and read as complete under the shape they were written for. A repository configured once never runs generation again on its own, which makes the migration page and the audit step the only surfaces that touch a live repository, and an unwritten row the difference between shipping a mechanic and shipping it to nobody.

The five mechanics are **four different kinds of work**, and conflating them is how a run repairs something it should have reported:

- **Converted, with judgement** — declared fields. The existing hand-written routing table's trigger sentences are the input rather than something discarded, and a decision with no such sentence needs one written. A load condition that describes subject matter passes every mechanical check and is wrong, so this row is shown in the plan file by file, exactly as the existing row for a stage-owned term is shown term by term.
- **Repaired** — the stage table, derived from the skill defaults plus what the repository added, with repository-specific rows preserved. A guide a skill declares and a row omits is surfaced rather than added, because the new precedence rule wants a deliberate omission recorded as one.
- **Reported, never repaired** — drift findings. Whether one was healed is a question about knowledge elsewhere in the repository, and answering it by inference is the guess the finding format exists to stop. Unmarked reads as waiting, which is the safe default and today's behaviour.
- **Nothing to do, said out loud** — the marker, whose missing tree fact is a defined state with a defined fallback and which corrects itself the first time a stage advances it; and the shipped roles, which belong to the plugin. Both are named so a reader auditing an old repository finds the case described rather than inferring it from a file that reads shorter than the one they know.

The configuration stage does not stamp a tree fact. Stamping asserts that a drift read happened and was dealt with, and that stage did neither — the same conditional obligation that governs every other writer.

## Approach

Three independent tracks, deliberately not serialised behind each other:

1. **The Marker**, from the specification outward — the rule, then the recipe in the tool guide that makes it executable, then the protocol template, then the stage that writes it. The tool guide comes early because the fingerprint recipe was a configuration gap found during this design: nothing documented how to build a tree fingerprint, and the rule is unimplementable until it does.
2. **Declared fields**, from the specification outward — the shape once, then Decisions and Contexts adopting it in parallel, then the generator and the assertions.
3. **The small ones** — the dependency precedence, agent modes, and consumed findings — each self-contained and each blocking nothing.

Adoption lands last and in two tickets rather than one, because migrating fifty-one Decisions and three Contexts to declared fields is its own context window and has nothing to do with adopting a marker rule.

**Reaching other repositories lands after adoption and splits on risk, not on surface.** The declared-field conversion is its own ticket because it is the only judgement-heavy row and the only one that can produce a complete, valid, wrong result; everything else configure carries is mechanical or is a sentence saying nothing is needed. Splitting them the other way — one ticket per configure file — would put the row that can silently fail beside four that cannot.

**Rejected, with reasons, so they are not proposed again:**

- **`git stash create` as the fingerprint.** One command, and its usage line takes no `-u` — it cannot see untracked files. A newly added file would leave the fingerprint unchanged, which is false trust in precisely the case the drift read exists to catch.
- **Hashing `git status --porcelain` output.** Cheapest sound-looking option and it is not sound: the output records which files changed, never what they now contain, so editing an already-dirty file a second time leaves the digest identical.
- **Hashing only the dirty set.** Genuinely sound and cheaper, but it is an AEP-defined digest with a special case for the clean tree and a third command to capture staged blobs. Rejected for uniformity: a real tree object has no special cases.
- **Contexts naming their own Decisions**, as a pure reading of §8. Covers a minority of the weight — most ADRs here are about the protocol rather than a domain, and this repository has two Domain Contexts to hang them on.
- **A hand-written decisions map**, mirroring the contexts map exactly. Consistent, and it reintroduces by hand the drift that ADR 0002 recorded as its own cost.
- **Strict single home for the dependency set**, in either direction. Both break something stated in the specification; see Architecture.
- **A per-stage pointer-tier budget, asserted like the boot budget.** Raised during the grill and deliberately excluded. Named here because it is the obvious next proposal and its exclusion was a choice.

## Acceptance criteria

- A dirty working tree that has not changed since a stage last read its drift no longer triggers a second drift read, and the same tree changed by one byte does.
- The tree fingerprint is derived from file contents, covers untracked files, and leaves the repository's own index unmodified.
- A marker file carrying only a commit behaves exactly as it does today.
- Re-stamping the tree is permitted only to a stage that dealt with the drift it read, and the specification says so in those terms.
- Which ADRs govern a given area is answerable without reading the decisions directory.
- The decisions index cannot disagree with the directory, and the suite proves it rather than an audit finding it.
- Every supersession claim is symmetric, and a one-sided one fails the build.
- Every declared source path in a context resolves, and one that does not fails the build.
- A reader with no plugin installed can still learn what each stage reads, from a committed file.
- Where a skill's dependency line and the protocol table disagree, which one governs is stated, not inferred.
- Every shipped agent role runs under a named mode, and a mode naming no mode file fails the build.
- A healed drift finding is distinguishable from a waiting one without opening the policy it falsified.
- A repository configured by an earlier release reaches every mechanic here without anyone hand-editing it, and a repository already carrying them is recognised as current rather than converted again.
- Each thing the configuration stage does about this effort is labelled as converting, repairing, reporting, or needing nothing — and no two are described in the same terms.
- A drift finding whose consumption is unknown stays unmarked, and the migration says why marking it would require knowing something it does not.
- Every rule this effort places carries a single-home guard, and each guard is confirmed to fail against a reworded restatement before it is trusted.
- The suite passes.

## Risks

- **The re-stamp permission is the one place false trust can enter.** A stage that re-stamps without having dealt with what it read would hand the next stage a cache claiming more than anyone earned. Detection: the permission is stated as a conditional obligation rather than a capability, and the guard is written against the inversion — presence of the affirmative is symmetric with its negation, which this repository has already been burned by.
- **The seeded index recipe reads differently in PowerShell and in bash**, and it ships to both. Detection: it goes in the tool guide with both forms, and the tool guide is the file the engineering rules already forbid guessing around.
- **Fifty-one mechanical frontmatter edits is exactly the shape that gets done inattentively.** Detection: the generated index is derived from those fields, so a wrong or missing field surfaces as an index that does not match the directory rather than as silence.
- **A generated file invites hand-editing.** Detection: the assertion compares it against a regeneration, so a hand edit fails the build in the same pass that introduced it.
- **The migration's load conditions are the one output nothing can check.** A converted repository can hold a complete, regenerating, entirely subject-describing index and pass every assertion this effort writes — the failure the earlier routing decision turned on, reintroduced at a scale no one repository would produce by hand. Detection: the row goes through the plan file by file rather than as a count, which is the only surface where a human sees the sentences before they land. Named as a risk rather than solved, because nothing mechanical distinguishes a trigger from a topic.

## Out of scope

- The three loading tiers. They are sound and nothing here touches them.
- Skill frontmatter. `Mode:` and `Policies:` stay prose lines: §11 mandates it, the suite already parses them, and moving them buys nothing the harness would read.
- Splitting the ticket format policy for progressive disclosure. It is read whole for an Express run, which is worth fixing once something measures it; nothing here measures it.
- Indexes for the tickets and evidence directories.
- A per-stage pointer-tier budget assertion.
- The path contradiction between the spec-format policy, which writes specs to a designs directory, and the tracker policy, which is the declared authority on where they go and names the effort directory instead. Found during this design, unhealed because it is a policy declaration rather than a readable fact, and worth its own decision.
