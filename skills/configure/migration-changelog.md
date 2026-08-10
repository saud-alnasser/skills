# Migration changelog

Every repair a repository needs because of **which release configured it**, grouped by the release that introduced the shape being repaired.

<!--
  Read by `/configure`'s audit before it is read by a human. It answers one
  question — which repairs does *this* repository still need — and the answer is
  the releases newer than the one `.claude/protocol.md` declares.

  This is not [MIGRATION.md](MIGRATION.md). That page converts a shape that was
  never AEP's, or was AEP's own directory layout, and it fires when detection
  finds the shape. This one fires on a version. The two were one page until the
  dated half was found spread across it and the audit list with no release on
  any entry, so nothing could tell which still applied.

  A release entry is frozen once written. That is what makes a hand-maintained
  file safe here where a hand-maintained index would not be: an index over a
  directory rots because the directory moves underneath it, and a shipped
  release cannot change.

  A repair filed under a release *later* than the one that caused it never fires
  again on the repositories that need it, and reports success while not firing.
  The evidence behind each assignment is recorded where it resolves — in the
  repository that builds AEP, on the effort that made the assignment — rather
  than here, where a record number or a commit hash points at nothing.
-->

## How the audit reads this

```
.claude/protocol.md declares aep-version: X
  → consider every repair below from a release newer than X

it declares no version
  → consider all of them
```

**An absent field means the opposite here to what it means to the release hook.** The hook stays silent on a repository declaring no version, because calling it stale on no evidence is worse than saying nothing. The audit considers everything, because a repository with no field was configured before the field existed — that is what its absence proves. Silence costs a notification; a skipped repair costs the repository.

**The cursor narrows what is considered, never what is verified.** Every repair below still recognises its shape by content before touching anything, so a repair considered against a repository that never had the shape is a no-op rather than a mistake.

**The field arrived in 1.13.0.** Every repository configured before that declares nothing and receives all of these regardless of how they are filed, so the assignments below govern repositories configured from 1.13.0 onward.

---

## 1.16.0

**Look at:** `.claude/rules/`, `CLAUDE.md`, `.claude/protocol.md`, `.claude/scripts/`, and the derived tool references.

### A fourth always-on rule, which a repository configured earlier does not have

`boundary.md` is new. It governs work belonging to a repository other than the one the session stands in: which acts are permitted there, which are not, and why permission to do a piece of work does not by itself settle where that work happens. A repository configured before this release has no such file, and its `CLAUDE.md` names three unconditional rules where four now load.

The rule's own wording is not repeated here, and that is deliberate rather than terse: each of its clauses has exactly one home, and a changelog quoting them would become a second one.

**Repaired**, both halves. A missing always-on rule is *absent* rather than declining — there is no repository-specific version to weigh against the template — so the audit installs it and adds it to the entrypoint's always-on list. The list is prose beside a set that is computed, which is exactly how it went wrong here; check the two against each other rather than reading the sentence.

### The engineering standards gained two clauses

One names the failure where a rule is satisfied in wording while the thing it existed to catch has been arranged out of reach. The other reaches a skill the user is meant to trigger, whose output gets produced by hand instead. Their wording lives in the engineering rules and is not repeated here, for the single-home reason given above.

Both are **additive** — nothing installed became wrong — so they are **reported, not rewritten**. Do not re-derive an installed rules file to pick them up: a whole-file replacement reverts every standard that repository discovered for itself, and those are the point of the directory.

### The router gained a stage-table row and a second judged line

The routing table's first row now refuses a request that would change another repository, and it is first because every row beneath it matches such a request perfectly. The verification report's judgement half leads with which repository governs. A repository configured earlier routes such a request straight into `/design` and never asks the question.

**Reported**, naming both sections, because a protocol file carries per-repository routing that a replacement would discard.

### The generated-index prohibition gained something that enforces it

Three installed policy files say a generated index is never hand-edited and that the prohibition is *enforced*. Until this release nothing in a configured repository enforced it. `SCRIPTS.md` now specifies a **regenerate-and-compare check** — a step in whatever already fails the build, not a third script, because `.claude/scripts/` holds only what that page specifies.

**Repaired** by the audit's own re-check, which wires it in and runs its fixture first. Where the repository has nothing that fails a build, **say so and install nothing**: a gap somebody can see is better than a prohibition quietly asserted and enforced nowhere.

### The index regenerator changed, and it is derived

The evidence index's `Falsifies` cell now distinguishes a **waiting** finding from a **consumed** one, read off the finding's own mark and never inferred. **Re-derive the regenerator** from the page and regenerate; until then the committed index differs from what a regeneration produces, which the check above will report as drift rather than as the backfill it is.

### Two derived tool references carried false facts

The GitHub reference denied sub-issue and blocking flags that `gh` has had for releases. The stacking reference claimed a non-interactive submit opens pull requests as drafts, which `gt submit --help` does not say.

**Reported.** These are derived per repository and are exactly where a repository keeps corrections that can be ahead of what ships, so refresh them **upward** through the refresh path rather than replacing them downward.

## 1.15.0

**Look at:** the tracker policy, `.claude/policies/evidence.md`, and `.claude/policies/specs.md`.

### A tracker policy that predates the spec-layout declaration

The regenerator was already told that a repository's tracker policy declares which of the two spec layouts applies, and until this release nothing wrote that section — no template gave the tracker policy one and no step derived one, so the instruction pointed at a declaration nothing produced. A repository configured before this release has a tracker policy with no such section.

**Repaired, not reported**, and the repair already has a home: the audit's own `Where a spec lives` check detects the layout from the tree and writes the section. This entry exists so a repository that skips straight past that bullet still reaches it from the cursor — and so a reader can tell that a missing section is *absent* rather than *declaring the other layout*, which is a finding rather than a backfill.

### Policy files that gained content this release

The evidence and specification policies gained text a repository configured earlier does not have: what a consumed finding records, and where a spec's status may move. Both are **additive** — nothing that was installed became wrong — so they are reported rather than rewritten.

**Do not re-derive an installed policy to pick them up.** A whole-file replacement reverts every repository-specific derivation in the same stroke, and those derivations are the point of the directory. Report the difference, name the file, and let a human decide.

## 1.14.0

**Look at:** nothing in a configured repository.

No repair. This release moved the dated repairs into this file and taught the audit to read it; what changed is the plugin's own shape, and a repository gains it by updating the plugin.

## 1.13.0

**Look at:** `.claude/protocol.md`'s frontmatter.

### The protocol declares no release

A protocol file with no `aep-version` field gains one, set to the release running the audit. The field is the only thing in that file an audit changes without the change being a repair. Left absent, the session hook cannot report anything and this cursor has nothing to read.

## 1.11.0

**Look at:** `.claude/contexts/`, `.claude/decisions/`, and whether either has a generated index.

### Knowledge that predates declared fields

A repository configured before Contexts and Decisions declared their own fields has a hand-written routing table, Domain Contexts carrying a prose `Sources:` line, and a decisions directory with no index at all. Recognition is by content and needs **both halves**, because either alone is an unfinished run rather than an older shape: `.claude/decisions/` is populated, and its files declare no frontmatter fields.

Nothing else reaches this. The generate step passes over every one of those files — they exist, and under the shape they were written for they are correct — and a repository configured once does not run generation again on its own. Without this row an existing repository stays on the old shape indefinitely while the framework ships the new one.

**The existing routing table is the conversion's input, not its casualty.** Its trigger sentences were written for exactly this purpose: carry each onto the file it describes as that file's `load-when`, and carry the Sources column onto the same file. Only where no such sentence exists anywhere — every Decision, since Decisions were never routed — is one being authored.

**That authoring is judgement, and it is the one output nothing can check.** A load condition that describes what a file is *about* passes every assertion this shape adds and silently reintroduces the failure a routing table exists to prevent. So this repair goes through the plan **file by file, with the sentences visible**, never as a count — a human reading them is the only check there is.

Supersession is converted from wherever it is stated today and made symmetric at both ends. **Prose that discusses supersession without claiming it** — "supersedes one consequence of `0025`", "supersedes the layout stated in `0006`" — is **reported, never promoted**: reading it as a claim is a guess about what its author meant, and a partial supersession is not a supersession. Where a claim is partial, say so in the plan rather than rounding it.

Filenames and numbers do not move. The numbering section of `.claude/policies/decisions.md` already governs that, and it governs this conversion exactly as it governs a move.

Then generate both indexes from the fields. A repository already declaring fields is **current**: say so and change nothing.

## 1.9.0

**Look at:** the router's stage table, `.claude/evidence/drift/`, and `.claude/position/marker.json`.

### Mechanics a configured repository does not get by generation

Three of AEP's later mechanics land in files a repository already has, so the generate step passes over all three. They are **not the same kind of work**, and a run that treats them alike will repair the one that should have been reported.

**The stage table is repaired** — a stage table that predates the precedence rule. The table is *derived* — from the defaults each skill declares, plus whatever guides are local to this repository — and a table written before that was stated may be missing guides its own skills name. Re-derive it, and **preserve the repository-specific rows**: extra guides a row names, stages the repository added. Those are the part the template cannot know, and the same reason the mode-column row preserves them. A guide a skill declares and its row omits is **surfaced in the plan, never added silently** — the omission may have been deliberate, and the rule wants it recorded as such rather than undone.

**Drift findings are reported, never repaired.** A repository whose `.claude/evidence/drift/` entries carry no `Consumed:` line has findings whose disposal is unknown. Whether any one of them was healed is a question about knowledge elsewhere in that repository, and answering it by inference is precisely the guess the finding format exists to stop. **Leave every unmarked finding unmarked** — that reads as waiting, which is the safe direction and the behaviour the repository already has — and list them in the plan so a human knows they are unresolved.

**The Marker needs no conversion, and this row exists to say so** rather than leave a reader hunting for one. This is here to say so, rather than leave a reader hunting for a conversion. A marker carrying only a commit means the tree is unknown: `.claude/protocol.md` defines that state and its fallback, and it corrects itself the first time a stage advances the marker. `/configure` does **not** write a tree fact — stamping one asserts that a drift read happened and was dealt with, and this stage did neither.

**The shipped roles arrive with the plugin**, for the reason already recorded twice above: `agents/` belongs to the plugin rather than to the configured repository, so a role gaining a declared mode reaches a repository by updating the plugin and nothing here installs it.

## 1.8.0

**Look at:** `.claude/.gitignore`.

### An ignore file that predates the child-workspace rule

An installed `.claude/.gitignore` covering `/position/` and `settings.local.json` but not `/worktrees/` was written before orchestration shipped, and the repository has been accumulating untracked child checkouts ever since. Recognition is by content, and the ignore file is **repaired rather than reported** — a repository configured once does not run the generate branch again on its own, so the audit is the only thing that reaches it.

## 1.7.0

**Look at:** `.claude/policies/sub-agents.md`, `.claude/settings.json`, and whether the router names any stage as dispatching.

### A repository configured before orchestration existed

A repository configured by an earlier release has `.claude/policies/` and no `sub-agents.md`, and a router whose table names no stage as dispatching. Recognition is by content and needs both halves, because either alone is an interrupted run rather than an older layout: the policies directory is populated, and `.claude/policies/sub-agents.md` is absent. The conversion is what the generate step writes anyway — the policy, and the routing rows for the stages that dispatch — so this exists to *name* the case rather than to add work.

**The shipped roles are not part of it.** `agents/` belongs to the plugin, not to the configured repository, so a repository on an old release gains the roles by updating the plugin and nothing here installs them.

### Orchestration without its isolation setting

A repository configured before the worktree base ref was written has the sub-agent policy and no `worktree.baseRef`. Recognition is by content and needs both halves: `.claude/policies/sub-agents.md` present, and `.claude/settings.json` either absent, missing the key, or setting it to `"fresh"`. This repairs rather than reports — one merged key, small enough that handing it back as a plan item costs more than doing it, and what it prevents is not something the next run would catch. An existing `settings.json` is merged into, never replaced. A repository with no sub-agent policy is not on this row: it is one the current `/configure` has never finished, and the generate step writes both.

### The first axis without the second

A repository configured while orchestration had only one axis carries `.claude/policies/sub-agents.md` describing a child that works a *portion*, and nothing about one that works a whole ticket. Recognition is by content and needs both halves, because a policy that is merely absent is an unfinished run rather than an older layout: the policy is present, and it admits no whole-ticket child — no decline rule for a fan-out the child cannot itself run, and no closed menu of what a child may request. This repairs rather than reports, and costs nothing extra by doing so: the policy is installed by copy, so the generate step replaces it with the current template entire and there is no repository-specific text in it to preserve.

**The build stage is not part of it**, for the reason the shipped roles above are not. What a migration can reach is the contract the children read; the stage that dispatches them arrives with the plugin.

## 1.2.0

**Look at:** how `.claude/protocol.md` expands the acronym.

### Heal the framework's name

A protocol file expanding AEP as the *AI* Engineering Protocol was installed before the rename to *Agentic*. The acronym never moved, so nothing is broken and nothing routes on the sentence — which is why only the audit reaches it. One sentence, not a migration.

## 1.0.0

**Look at:** every live file under `.claude/`, and the entrypoint.

### The Tenure → AEP rename

The framework was called **Tenure** before it became AEP, and a repository configured under that name carries it in prose: the entrypoint, the protocol file, the policies, and the tool references say Tenure and name `/tenure:` commands. The layout may already be current — the name is a conversion of its own, and it applies on top of whichever layout migration the repository also needs.

The conversion is textual and complete: in every **live** file under `.claude/` and in the entrypoint, `Tenure` becomes `AEP` and `/tenure:` becomes `/aep:`, including possessives and the namespaced command list the entrypoint or help text may carry. Frozen records — Decisions, resolved tickets — keep the old name, under the same rule as old paths: history is not repaired, and a Decision that argued about Tenure argued about Tenure.

Recognition is by content: a live file naming Tenure or a `/tenure:` command is a finding, whatever the layout looks like. A repository with no such reference needs nothing from this section, and the plan says so rather than staying silent.

### The pre-modes protocol file

Two older shapes exist, and recognition is by content in both. A repository converted before the modes shipped has a `.claude/protocol.md` whose routing table carries no mode column and no `.claude/modes/` directory. One release later the modes existed but lived *inside* the router, as `### Mode:` sections of the protocol file — that is the interim shape, whatever else the file looks like.

The conversion brings either to the current layout: `.claude/modes/` is installed from the templates, one file per posture; any `### Mode:` sections found in the protocol file are removed in the same pass, because the directory is now their single home; and the routing table gains the mode column with the template's stage-to-mode assignments. Repository-specific rows — extra guides a row names, stages the repository added — are preserved, because they are the part the template cannot know. A file already on the current shape is current, and a re-run changes nothing.

