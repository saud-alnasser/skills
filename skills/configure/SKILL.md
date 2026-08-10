---
name: configure
description: Make this repository's knowledge correct and complete — detect what is already here, generate what is missing, migrate another AI workflow onto AEP, and prune what nothing loads. Use when onboarding a repository, or to audit one already running AEP.
disable-model-invocation: true
metadata:
  mode: maintenance
  policies: ["*"]
---

# Configure

`/configure` has **one job: make repository knowledge correct and complete.** Onboarding and auditing are the same job against different starting states.

It reads **every guide in `.claude/policies/`** — this is the command that writes them, and an audit run reads each one back — which is why its declared guides are the whole directory rather than a list that would need updating whenever a guide is added.

Which branch runs is decided by **what it finds, never by a flag.** A flag lets the caller assert a starting state; detection discovers one.

| What is already here | What this run does |
| --- | --- |
| no AEP, no AI workflow | analyse, then generate |
| no AEP, another AI workflow present | the above, plus the migration in [MIGRATION.md](MIGRATION.md) |
| AEP already present | audit, and generate whatever is still missing |
| AEP present on a superseded layout | the above, plus the layout migration in [MIGRATION.md](MIGRATION.md) |

**Every run generates.** The third row audits *as well*, it does not audit *instead* — a first run interrupted halfway detects as "AEP already present" and would otherwise never be finished. The branch changes what is *found*, never which steps run.

## 0 — Verification

Open with the one-line verification report, exactly as every other skill does — including on a fresh repository, where it reads *"no AEP here — nothing to verify"*. The rule is in `.claude/protocol.md`, which on a fresh repository this run is about to write.

An audit run has Context to check and is the one case where this is real work. It still reports in one line; what it *finds* belongs to step 5.

## 1 — Detect

Nothing is generated before the repository has been looked at. Search for an existing AI workflow:

```
.claude/            CLAUDE.md            AGENTS.md
CONTEXT.md          CONTEXT-MAP.md       docs/agents/
docs/adr/           .scratch/            .ai/
.cursor/ .cursorrules                    .windsurfrules
.clinerules         .github/copilot-instructions.md

— AEP's own superseded layouts:
.claude/docs/       .claude/tenure.md    .claude/context.md
.claude/tracker.md  .claude/version-control.md
.claude/marker.json .claude/prototypes/
```

The second group is what a repository configured by an **earlier version of this workflow** looks like. Finding any of them selects the layout migration rather than the conversion one — the formats are correct and only the locations are wrong: mechanical work, whose risk is a reference left pointing where a file no longer is.

Then read the repository itself: languages, package manager, build, test, format, deploy, CI, source layout, **architectural style**, module boundaries, domains, and the conventions it already follows. **Read `CONTRIBUTING.md` and the recent `git log`** — those are how the repository documents and demonstrates its own conventions, and `CLAUDE.md`'s detect-before-asserting rule is what makes that a step rather than a courtesy.

**Find the knowledge that is already written down**, wherever it lives: architecture documents, onboarding and developer guides, design documents, decision records, standards, conventions. Ordinary documentation, usually under `docs/`, not detected by the list above — and the input the classification step works on. A migration that never found them silently generates from scratch what was already written.

Classify what kind of repository this is — library, CLI, service, monorepo, application — because it changes what domains exist and what tooling matters.

Read what you find. A `docs/adr/` directory is not proof that ADRs are in it — everything detection looks at is a path.

## 2 — Plan, confirm, apply

Present the **full move list before touching anything**: every file to be created, converted, moved, or deleted, with its destination. Apply only on approval.

**Nothing is deleted that did not appear in the confirmed plan.** `/configure` runs against repositories with years of documentation in them, and a wrong classification that deletes is not recoverable from the tree.

The user may strike any line. A struck line is not worked around: leave it as it is and say what that means for the rest.

## 3 — Migrate, where there is something to migrate

[MIGRATION.md](MIGRATION.md) has this branch, and step 1 decides whether to open it: another AI workflow found, or AEP found on a superseded layout, read it; greenfield, skip it entirely. Reading it on a repository with nothing to migrate costs context and answers nothing.

The two cases are different work and only one page: converting another workflow classifies prose, judgement all the way down; converting AEP's own superseded layout is mechanical, and its risk is the opposite one — a reference left pointing at a directory that no longer exists.

## 4 — Generate

**Write what is missing; check what is already there.** Both, on every run — a file that exists is checked against the repository it claims to describe, and one that does not is written. Neither is conditional on which branch step 1 selected.

The shape being generated, so the tree reads as its own map — every category is a directory, and the one loose file is the router the entrypoint points at:

```
.claude/
├── protocol.md          the router — the only loose file this workflow owns
├── settings.json        the harness's, merged not replaced
├── rules/               always-on and path-scoped standards
├── modes/               one reasoning posture per file
├── policies/            one guide per workflow concern
├── contexts/            map.md, repository.md, and the domains
├── decisions/           ADRs
├── designs/             specs
├── evidence/            research, prototypes, out-of-scope, discussions
├── tickets/             one directory per effort
├── tools/               one file per tool this repository uses
├── scripts/             scripts serving this workflow's own process
├── position/            per-clone state — never committed
├── worktrees/           the harness's isolated child checkouts
└── .gitignore           what per-clone means, and the test for it
```

**A second loose file is a category nobody named.** When something does not fit a directory above, that is the finding — say so rather than dropping it at the root.

The two `settings` files are the harness's, not this workflow's: it reads them from those exact paths and would not find them anywhere else. They are still not one case. `settings.local.json` is per-clone, which is the exemption `.claude/.gitignore` states and the reason it cannot move under `position/`, and it appears in neither the tree above nor the canonical layout. `settings.json` is committed, so it is in both.

`worktrees/` is the harness's too, and it is a third case rather than a repeat of either — which is why being per-clone is not on its own what keeps something out of the layout. It is per-clone like `settings.local.json`, and named in both the tree and the canonical layout like `settings.json`. What separates it is that it is a **directory**: the layout names every category, and a category nothing names is one the ignore file is free to forget.

**`.claude/scripts/`, one script per script [SCRIPTS.md](SCRIPTS.md) specifies**, each in the language this repository already uses — the index regenerator and the position report today, and whatever that page specifies tomorrow. Derive from the page rather than from a list here: a list is what goes stale when the page grows a section, and the failure it produces is a stage whose input nothing writes. That page also specifies one check that is *not* a script and gets no file here; it is the paragraph below.

Each section carries a fixture with exact expected output. **Run every derived script against its own fixture and report the result before running it against the repository**, because a freshly configured repository has nothing for a first run to be compared against — a mis-derived script produces a wrong-but-self-consistent answer that every later check agrees with. **A mismatch stops this stage**; it is not reported and passed. A script that fails its own fixture is a wrong derivation, and installing one puts a confident wrong answer exactly where a stage quotes it as authority.

Nothing ships a copy of AEP's own scripts, and nothing points into the plugin for one. `MIGRATION.md` carries no row for them: no earlier version of this workflow installed one, so there is nothing anywhere to convert.

**The regenerate-and-compare check**, which [SCRIPTS.md](SCRIPTS.md) specifies as a step rather than a script — it runs the index regenerator and fails on any difference git then reports. It is what turns *a generated index is never hand-edited* from a request into a rule, and the guides this run installs assert that rule in three places, so a repository that gets the guides and not the check carries an enforcement nothing performs. **Wire it into the CI workflow or check task step 1 found**, and run its fixture first, exactly as with a derived script — reporting the result, and stopping on a mismatch. Where this repository has nothing that fails a build, **say so and install nothing**: an unenforced prohibition that is reported is a gap somebody can close, and one that is quietly asserted is the state this step exists to end.

The rest of the tree — `.claude/decisions/`, `.claude/designs/`, `.claude/evidence/{research,prototypes,out-of-scope,discussions}/`, `.claude/tickets/`, `.claude/scripts/`, and `.claude/position/` — is **created lazily**, by whichever command first has something to put in it. `/configure` does not pre-create empty directories: an empty `evidence/research/` is a claim that research happened.

`worktrees/` is lazy in a stronger sense: **no command of this workflow ever creates it.** The harness does, the first time a stage dispatches an isolated child. It is in the tree because the tree is the shape of a conforming repository rather than a manifest of what this run writes — and because a directory the layout does not name is one the ignore file is free to forget, which is exactly what happened.

**`.claude/contexts/**`**, as three kinds of file: `.claude/contexts/map.md` holding the routing table alone, `.claude/contexts/repository.md` holding the vocabulary and boundaries that cross domains, and one file per domain that earns one. The format, the placement rule for a term, and the test a domain has to pass are in [policies/context.template.md](policies/context.template.md), which this run installs at `.claude/policies/context.md`; the compression test that gates every line is in `CLAUDE.md`.

What is `/configure`'s is the *sourcing*: these are generated from the repository, so every concept written down was read out of the code, and a domain that only has a folder does not get a file. **Write `map.md` last**, once it is known which domains earned a file — a routing table written first is a list of intentions, and every row it names has to exist.

**`CLAUDE.md`** at the root, from [CLAUDE.template.md](CLAUDE.template.md). Fill the placeholders; do not rewrite the rules. **Preserve the user's existing sections** — a repository's `CLAUDE.md` usually already carries instructions somebody wrote deliberately, and replacing the file wholesale destroys them. Merge into it.

**`.claude/rules/precedence.md`**, **`.claude/rules/engineering.md`**, **`.claude/rules/placement.md`**, and **`.claude/rules/boundary.md`**, from [precedence.template.md](precedence.template.md), [engineering.template.md](engineering.template.md), [placement.template.md](placement.template.md) and [boundary.template.md](boundary.template.md), copied as-is — the workflow's standards, nothing to fill in. None carries `paths:` frontmatter, which is what makes the harness load them on every turn: these are the rules `CLAUDE.md` stopped stating so that it could stay a pointer.

`placement.md` is unconditional rather than scoped because it governs where a file is *created*, and a scoped rule arrives only once a covered file has been read — after the decision it exists to inform.

`boundary.md` is unconditional for the same reason one scope wider: it governs whether another repository may be *worked in at all*, and the first read there is already past the point a scoped rule would arrive.

**`.claude/protocol.md`**, from [protocol.template.md](protocol.template.md), copied as-is — `owner: framework`, its `aep-version` stamped correctly by construction because the template ships with the release that ships it. The only lines a repository may vary are the two extension points the file's own opening paragraph names. The router rather than a rule — the Marker, the drift reads, the verification report, and the table saying which guides each stage reads — so it is reached by pointer and a question turn does not pay for it.

**`.claude/modes/`**, from [modes/](modes/), copied as-is — one file per reasoning posture, seven in all. A stage reads exactly the one its `metadata.mode` field declares, which is why they are files rather than sections of the router.

**`.claude/policies/`**, one guide per workflow concern or repository aspect. Eight describe the workflow and are copied as-is from [policies/](policies/); two describe *this* repository and are derived, exactly as the tool references are — a copied guide would hand this repository somebody else's facts.

**Every installed instruction file declares its owner in frontmatter, and the install honours it.** A copied guide ships `owner: framework` and is installed **verbatim** — law, never edited or adapted per repository, and a later audit compares it against the release exactly. A derived guide ships describing `owner: repository`, and the repository's facts go into the **declared fields** its template names — the extension points — never into rewritten framework prose. **A repository variation with no declared point to enter through is recorded as a deviation**: a `## Deviations` section in `.claude/protocol.md`, one line per deviation — the file, the reason, and the release it was declared under — so every audit surfaces it without anyone remembering to look.

| Guide | Source | Covers |
| --- | --- | --- |
| `knowledge.md` | copied | how knowledge loads, what heals it, and when |
| `context.md` | copied | what belongs in Context, the routing table, the compression test |
| `decisions.md` | copied | when a Decision is worth recording, and the numbering |
| `tickets.md` | copied | the ticket format, the hierarchy, the edges, the lifecycle |
| `specs.md` | copied | the spec sections and the status vocabulary |
| `maps.md` | copied | the fog branch, worked before any spec exists |
| `evidence.md` | copied | gating, and how a finding graduates into knowledge |
| `sub-agents.md` | copied | what a dispatched child may use, what is closed to it, the brief and the change record |
| `tracker.md` | **derived** | which tracker, and the label vocabulary behind each role |
| `version-control.md` | **derived** | which model, the branch convention, how work lands |

The guides are what the workflow's stages read instead of restating; `.claude/protocol.md`'s routing table is the only index. A guide with no row is unreachable, so write the row in the same pass.

**Write the whole set or none of it.** The entrypoint points at the always-on files and the protocol's table at every guide, so a run that writes the entrypoint and stops leaves pointers going nowhere — worse than never having split the file, because the rules are now missing rather than merely expensive.

**More `.claude/rules/*.md`** for standards discovered in *this* repository, each **path-scoped** where it applies to part of the tree: a standard about `packages/api/` says so in `paths:` frontmatter and is not paid for while working in `docs/`. A standard with no `paths:` is a permanent per-turn cost, so adding one is a decision rather than a default.

**`.claude/policies/tracker.md`**, from [policies/tracker.template.md](policies/tracker.template.md). Choose from the **remote**: GitHub when a remote points at GitHub, GitLab when one points at GitLab, local markdown otherwise — including when there is no remote, and when the remote is a host with no tracker AEP drives. **Ask when it is ambiguous** — several remotes, or a remote that does not match where work is actually tracked. The triage label vocabulary folds into the same file. So does **`What a ticket is`**: answer the detect test the template carries from `.claude/policies/version-control.md` — written after that file, for exactly this reason — and cite the line the answer came from. `.claude/policies/maps.md` places decision work by reading the declaration, so a missing one is not a blank to leave. So does **`Where a spec lives`**: **read it off the tree, never ask**, by the detect test the template carries — a repository is not consulted about a layout its own directories already answer. [SCRIPTS.md](SCRIPTS.md) sends the index regenerator to this declaration, so a file written without it hands a script an input nothing states.

**`.claude/policies/version-control.md`**, from [policies/version-control.template.md](policies/version-control.template.md). The tracker file's neighbour: that says where the tickets are, this says what happens to one once somebody builds it. **Which model applies is read off the repository, not asked about**, by the check the template itself carries — a stacking tool installed on the machine says nothing about this repository. The branch convention and commit discipline are *detected*, from the recent branches, `CONTRIBUTING.md`, and the log; asserting AEP's defaults over a repository that demonstrates its own is what the detect-before-asserting rule forbids.

**`.claude/tools/*.md`**, one file per tool this repository actually uses — the workflow's own (`git`, `gh`, `glab`, `gt`) *and* this repository's (package manager, test runner, typechecker, linter, formatter, build, deploy), in one directory with one format. [TOOLS.md](TOOLS.md) has the derivation rules and the format; it is the step where information is most easily lost, so read it before writing a tool file.

Take every repository-specific command from the manifest, scripts, or CI configuration, never from what the ecosystem usually does. The **single-file test command** is the one entry that must not be missing — the most-run command in the framework and the least guessable, and `tdd` says what happens without it.

**`.claude/.gitignore`**, written exactly as below. It is Position's definition, so it states the category and the test rather than listing entries — a per-clone file added later is covered by the rule instead of needing a new exception argued for:

```gitignore
# Position. Put a file under `position/` when it would be wrong in another clone
# — someone else's checkout, or this repository on another machine. A file that
# would be equally true everywhere is knowledge, and knowledge is committed.
#
# `.claude/protocol.md` says what depends on that being true.
#
# One directory rather than a list, so a per-clone file added later is covered
# by the rule instead of needing a new exception argued for. It also removes a
# hazard rather than guarding against one: throwaway prototype code and the
# write-ups that outlive it used to share a name and differ only by a leading
# slash, and they now sit under different parents.
#
# Two paths sit outside that directory, and both for the same reason: they are
# the harness's, not the workflow's. It writes each at exactly the path below
# and would not find it anywhere else, so neither can be moved under
# `position/`. `settings.local.json` is this clone's harness configuration;
# `worktrees/` is where the harness checks out an isolated child, which makes
# every dispatched sub-agent's workspace per-clone state by the test above.
#
# The leading slash is still load-bearing, and `worktrees/` is the case that
# proves it: unanchored, a pattern matches at every depth, and a child's
# workspace is a full checkout containing its own `.claude/`.

/position/
/worktrees/
settings.local.json
```

It goes inside `.claude/`, and **the repository's own root `.gitignore` is left alone** — that is what lets AEP be added or removed as one directory instead of leaking entries into a file the repository owns.

`worktrees/` is named in §21's layout as the harness's rather than this workflow's, which is what puts it inside the entry-for-entry comparison of this tree against the specification. `/configure` never creates it: the harness does, the first time a stage dispatches an isolated child.

**`.claude/settings.json`**, carrying the worktree base ref. A sub-agent given worktree isolation branches from the repository's **default branch, not the parent session's `HEAD`**. So a child working a portion of a claimed ticket builds against a tree that does not contain the work it is extending — and nothing reports it: the child succeeds, the integration reads as routine, and the result is wrong in a way no test on the child's side can reach. A sentence telling a caller to set this is not enough, because the caller who forgets produces no error.

```json
{
  "worktree": {
    "baseRef": "head"
  }
}
```

`"head"` branches from the current local `HEAD`; the default, `"fresh"`, branches from the default branch on the remote. **Merge into an existing `settings.json` rather than replacing it** — the file is the harness's, and a repository may already keep hooks, permissions, or environment there.

**Whatever formats this repository is made to skip `.claude/`.** A formatter that reaches it rewrites knowledge on the formatter's schedule — prose reflowed, tables realigned, list markers renormalized — and a knowledge file whose diff is unreadable has lost the thing it was for.

Which formatters those are comes from step 1's read of the repository, never from a list here, and only the ones whose reach actually includes `.claude/` need anything. Make each one skip it **through its own ignore mechanism**, which its file in `.claude/tools/` describes — a formatter this repository runs earns a tool file like every other tool it runs, and **no entry there is a configuration gap**, not licence to guess a filename.

That mechanism is the formatter's, so it is usually a file the repository owns, which is what the ignore rule above deliberately does not touch. **What `/configure` writes outside `.claude/` and `CLAUDE.md` is a bound, not a count**: only what the workflow's specification names for the running release — today the formatter exclusions and the regenerate-and-compare wiring — each write planned in step 2 and listed in the report, and the audit asserts the written set equals the specified set. A count is re-falsified by every legitimate addition; the bound survives them and still catches the unplanned write.

## 5 — Audit, where AEP is already here

The audit branch exists because **verification at use structurally cannot reach knowledge nothing loads**: a context file nobody references is never relied on, so nobody ever checks it — it just sits there being wrong.

So this pass reaches what the routing table does not:

- **Prune what nothing references.** A Domain Context absent from the routing table, or one whose domain no longer exists, is removed. Say what was removed and why.
- **Validate the routing table** — every file under `contexts/` has exactly one row in `map.md`, including `repository.md`, and every row points at a file that exists.
- **Check `map.md` carries routing and nothing else.** Orientation prose that drifted into it is charged to every session, which is the cost the split removed.
- **Re-check Source Pointers**, including the ones no recent work touched.
- **Re-check `.claude/tools/`.** A repository's tooling changes, and a stale command is worse than no command: no command asks, a wrong one runs.
- **Re-check `What a ticket is`** in the tracker policy against the version-control policy — the declaration drifts when the branching model moves, and a tracker file written before the declaration existed gets it backfilled here, which is the repair `.claude/policies/maps.md` sends a stale repository back for.
- **Re-check `Where a spec lives`** in the tracker policy against the tree. A policy declaring the layout the tree holds is right, and this reports nothing. A policy with no such section declares nothing at all — so detect the layout and write the section, rather than leaving an answer other stages were told to read. A policy declaring one layout while the tree holds the other is a finding, because the tree is what a stage opening a spec will actually be run against.
- **Mark specs reality already satisfies.** `/commit` marks a spec `implemented` when it lands the last criterion; a spec finished outside that path stays `accepted` forever. This pass catches those.
- **Apply the repairs this repository has not had.** [migration-changelog.md](migration-changelog.md) holds every repair that fires because of *which release* configured a repository, grouped by the release that caused it. Read `aep-version` from `.claude/protocol.md` and consider only entries newer than it; a repository declaring no version predates the field and gets all of them. Each entry still recognises its shape by content before acting, so one considered against a repository that never had that shape is a no-op rather than a mistake. **Say which releases were skipped** — an audit that considered three of ten reads exactly like one that found nothing. Then set the field to the release running this audit, so the next run's cursor is right and the session hook stops reporting a repository this run brought current.
- **Re-check `.claude/scripts/` against [SCRIPTS.md](SCRIPTS.md)**, in both directions: every script the page specifies exists, and nothing sits there that it does not specify. A repository configured by an earlier release has only the scripts that release named, so a missing one is a stage whose input nothing produces — and it fails at the moment that stage runs, not here, unless this pass looks. Run each against its fixture, exactly as a first configuration does; a derivation that has drifted from the page passes every other check in this list.
- **Re-check the regenerate-and-compare check.** It lives in a file the repository owns rather than under `.claude/`, so a rewritten workflow drops it without anything noticing — confirm the build still runs it, and run its fixture. A check nobody runs leaves the prohibition asserted in the guides this stage installs and enforced nowhere, which is the state it exists to end.
- **Regenerate the routing tables.** Both are generated from declared fields, so a hand edit and a file added without fields both show up as an index that no longer matches its directory. Compare against a regeneration rather than reading the table for plausibility.
- **Re-check every installed instruction file against its owner's contract** — the rules, the modes, every policy, and the protocol file. **A file declaring `owner: framework` is compared against the release's template exactly, and the comparison is computed, never eyeballed** — for the protocol file, after setting aside the two extension points its own opening paragraph names, which are the repository's and survive both reinstall and upgrade: materialise both sides, normalise line endings, and quote the output of a real comparison command (`fc`, `diff`, or a hash pair) — then any remaining difference is a **defect to reinstall, never drift to heal**: verbatim replacement, no healing language, no ask, because framework law carries no local corrections to preserve. (A derived comparison *script* is not the shape here, deliberately: the templates live in the plugin, whose root the harness exposes to skill content and hooks but not to a stage's shell — so the stage materialises and compares at use instead.) **A repository-owned file** — the derived guides, the tool references — is where the ask-branch below still holds.
- **Surface every deviation, on every run.** Read `.claude/protocol.md`'s `## Deviations` section and print each entry — the file, the reason, the release it was declared under. **Each deviation's age is computed, never judged** — the declared release against the running one, the arithmetic quoted beside the entry — **and a deviation one release old or more with no disposition fails the audit**: the disposition is the human's — the framework grew the point, the repository conformed, or the deviation is re-declared under the current release with its reason re-affirmed.
- **The upgrade path replaces framework-owned files verbatim and leaves extensions untouched** — the declared fields, the repository-owned guides, and the deviations survive an upgrade byte-for-byte; only the law moves.

The comparison for repository-owned files — and any other read of an installed file against what AEP ships — is made one way. **Compare content, never raw bytes** — strip carriage returns from both sides before comparing, and ignore trailing whitespace: a repository that pins `eol=lf` and a plugin checked out on a Windows default differ on every line while being identical, the ordinary case on Windows.

**Drift reported across every file at once is a fault in the comparison until proven otherwise**, and it is checked before it is acted on. Re-deriving a repository-owned file discards whatever the repository put there, and the derived tool references are exactly where a repository keeps corrections verified against its own tooling — corrections that can be *ahead of* what AEP ships ([TOOLS.md](TOOLS.md)'s upward refresh path). So for repository-owned files a genuine difference is **reported with the file named**: a file nobody touched on purpose is re-derived, and one carrying a deliberate local correction is left alone with the difference stated — the two are not distinguishable from the diff, which is why this asks rather than decides. Framework-owned files take none of this — their disposition is the reinstall above.

Pruning deletes, so it goes through step 2's plan like everything else.

## 6 — Validate

Before reporting complete:

- Every **Source Pointer** resolves, and a broken one is handled the way `CLAUDE.md` requires.
- Every file under `contexts/` appears in the **routing table**, exactly once.
- No **implementation** was written into Context — no API shapes, no function names, no file inventories.
- Every file the always-on set points at exists: `CLAUDE.md`, `.claude/protocol.md`, and every rule under `.claude/rules/` that carries no `paths:` frontmatter. **Count them from the install step above rather than from a number written here** — this line said "the two rules" while that step installed three, and was wrong from the release that added the third until somebody read the two together. **Nothing committed depends on a file `.claude/.gitignore` matches** — read `CLAUDE.md` as a Claude without the plugin would, follow every pointer, and confirm each rule it reaches is followable.
- `.claude/.gitignore` exists and states the category, not a list.
- **Nothing that formats this repository reaches `.claude/`.** The outcome, not the edit — a formatter whose ignore file was written but whose config overrides it is still reformatting knowledge.

Report what was written, what was moved, and what was left alone.

## Running it again

`/configure` is **idempotent**: a second run reports what already exists rather than duplicating it. The audit branch makes re-running the *intended* way to use it, so a run that appended instead of recognising would make the repository worse every time it was maintained.

Recognition is by content, not by presence. A file that exists but describes a structure the repository no longer has is not "already done" — it is the audit's first finding.

## What stays with the caller

`/configure` **does not plan work and does not write code.** It finds a repository that needs designing and hands back; `/design` is the entry point for that, and taking it here would skip the grill.

It never commits. What it wrote is left in the working tree for the user to read, and `/commit` handles it from there.
