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

It reads **every guide the framework ships** — this is the command that writes the repository's own, and an audit run reads each back — which is why its declared guides are a wildcard rather than a list that would need updating whenever a guide is added.

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

**What is written outside the store is exactly what the harness finds by name, and nothing else.** Three surfaces, and the test is one test rather than a list to remember: `CLAUDE.md` at the repository root, `.claude/settings.json`, and the **unconditional standards** under `.claude/rules/` — those carrying no `paths:` frontmatter. The harness loads each of the three without being told to, from those paths and no others. Everything this step used to write as its own file is a **record** now: the guides, the postures, the tool references, the contexts, the decisions, the specs, the evidence. What each of them *says* is unchanged and is described below; where it lands is the store.

**A repository must be followable without the plugin, and that fixes the boundary.** A record is committed and readable, but *reaching* it is a pointer somebody follows, and a norm that fires only when the model chooses to look is the silent failure the tier model exists to prevent. So an unconditional standard stays a file the harness loads. **The framework's push skips what the harness already delivers** — pushing those as records too would deliver each twice, and two copies of a norm are two things to drift apart.

**What left is a directory, not a file.** The store is committed markdown in the same tree, so a teammate cloning without AEP reads the same records.

The shape being generated, so the tree reads as its own map — every category is a directory, and the one loose file is the router the entrypoint points at:

```
.claude/
├── protocol.md          the router — the only loose file this workflow owns
├── settings.json        the harness's, merged not replaced
├── knowledge/           the flat store — every record, whatever its type
├── rules/               the unconditional standards, and path-scoped pointers
├── tickets/             one directory per effort
├── scripts/             scripts serving this workflow's own process
├── position/            per-clone state — never committed
├── worktrees/           the harness's isolated child checkouts
└── .gitignore           what per-clone means, and the test for it
```

**A second loose file is a category nobody named.** When something does not fit a directory above, that is the finding — say so rather than dropping it at the root.

**The directories that left are named here so their absence is a decision rather than an omission**: `modes/`, `policies/`, `contexts/`, `decisions/`, `designs/`, `evidence/`, and `tools/`. Each held one type as whole files, and the store holds every type with the grouping as a declared field — a directory per type restates what a field already says. `rules/` survives on two different grounds: the unconditional standards stay files because the harness is the only channel reaching a clone without the plugin, and a path-scoped **pointer** stays because the harness is the only thing that can notice a covered file was touched — the norm it names is a record like every other.

**`.claude/knowledge/` is the one directory here nothing writes a file into directly.** The migration converts the corpus into it and the build mints the ids its records are addressed by; generation creates the directory and stops. It is named in full here because the always-on tier points at it, and a tier pointing somewhere this stage never produces is worse than the prose it replaced — the prose was at least there.

The two `settings` files are the harness's, not this workflow's: it reads them from those exact paths and would not find them anywhere else. They are still not one case. `settings.local.json` is per-clone, which is the exemption `.claude/.gitignore` states and the reason it cannot move under `position/`, and it appears in neither the tree above nor the canonical layout. `settings.json` is committed, so it is in both.

`worktrees/` is the harness's too, and it is a third case rather than a repeat of either — which is why being per-clone is not on its own what keeps something out of the layout. It is per-clone like `settings.local.json`, and named in both the tree and the canonical layout like `settings.json`. What separates it is that it is a **directory**: the layout names every category, and a category nothing names is one the ignore file is free to forget.

**`.claude/scripts/`, one copy per script [SCRIPTS.md](SCRIPTS.md) documents**, taken from the plugin byte for byte and given the same name. Read the set off that page rather than off a list here: a list is what goes stale when the page grows a section, and the failure it produces is a stage whose input nothing writes. Copy only the rows carried at this release — the page's `Since` and `Until` columns say which — and **stamp each copy with the release it came from, in the form [SCRIPTS.md](SCRIPTS.md) states**, which is what lets a later session report a copy an upgrade left behind. The release is the one in the plugin's manifest, read rather than asked for: a stage that asked would be asking the user to know something only the installation does.

**`.claude/position/framework-ledger.json`, copied from the plugin's prebuilt index, on the same terms as a script.** The store query answers over the framework store as well as this repository's — a norm cited by id from the other side of the boundary is one of the three cases it exists for — and a stage's shell cannot resolve the plugin's root, so the index arrives as a copy or not at all. It is derived and therefore ignored rather than committed, and it is stale exactly as a copied script is stale: the release stamp is what reports it.

**Nothing is proved on a fixture here.** Under the model this replaces, each repository wrote its own implementation and had to prove it on arrival — a wrong one is self-consistent, so every later check agrees with it. A copy cannot be wrong that way, and the fixtures are now tests where the code is written. This stage runs none of them.

Nothing points into the plugin for a script: the harness exports the plugin's root to a hook process and to skill content, never to a stage's shell, so a repository file naming that path could not resolve it. `MIGRATION.md` carries no row for the scripts: no earlier version of this workflow installed one, so there is nothing anywhere to convert.

**No regenerate-and-compare check is wired, and it is gone rather than forgotten.** It ran the index regenerator and failed on any difference git then reported, which is what turned *a generated index is never hand-edited* into a rule. [SCRIPTS.md](SCRIPTS.md) carries that script with an `Until` of this release: the four committed indexes it wrote are queries over declared fields now, so there is no generated file to regenerate and nothing to compare one against. The prohibition has no subject left, and a check wired for it would fail on the first repository that had nothing to check.

The rest of the tree — `.claude/knowledge/`, `.claude/tickets/`, `.claude/scripts/`, and `.claude/position/` — is **created lazily**, by whichever command first has something to put in it. `/configure` does not pre-create empty directories: an empty store is a claim that a corpus exists.

**The kinds that used to be directories are declared fields now**, and the list is unchanged by the move: a decision, a design, and the four evidence kinds — `{research,prototypes,out-of-scope,discussions}` — each name themselves on the record rather than by the directory holding them. Nothing is pre-created for a kind either, which is the same rule one level down. A `research` record that does not exist is a claim nobody made, where an empty `evidence/research/` was a claim that research happened.

`worktrees/` is lazy in a stronger sense: **no command of this workflow ever creates it.** The harness does, the first time a stage dispatches an isolated child. It is in the tree because the tree is the shape of a conforming repository rather than a manifest of what this run writes — and because a directory the layout does not name is one the ignore file is free to forget, which is exactly what happened.

**Context records in the store**, as two kinds: one holding the vocabulary and boundaries that cross domains, and one per domain that earns one — each declaring `type: context`. The routing table that used to sit beside them is a query over the same declared fields, so nothing is written for it. The format, the placement rule for a term, and the test a domain has to pass are the framework's context guide; the compression test that gates every line is in `CLAUDE.md`.

What is `/configure`'s is the *sourcing*: these are generated from the repository, so every concept written down was read out of the code, and a domain that only has a folder does not get a record.

**`CLAUDE.md`** at the root, from [CLAUDE.template.md](CLAUDE.template.md). Fill the placeholders; do not rewrite the rules. **Preserve the user's existing sections** — a repository's `CLAUDE.md` usually already carries instructions somebody wrote deliberately, and replacing the file wholesale destroys them. Merge into it.

**`.claude/rules/precedence.md`**, **`.claude/rules/engineering.md`**, **`.claude/rules/placement.md`**, and **`.claude/rules/boundary.md`**, from [precedence.template.md](precedence.template.md), [engineering.template.md](engineering.template.md), [placement.template.md](placement.template.md) and [boundary.template.md](boundary.template.md), copied as-is — the workflow's standards, nothing to fill in. None carries `paths:` frontmatter, which is what makes the harness load them on every turn: these are the rules `CLAUDE.md` stopped stating so that it could stay a pointer.

`placement.md` is unconditional rather than scoped because it governs where a file is *created*, and a scoped rule arrives only once a covered file has been read — after the decision it exists to inform.

`boundary.md` is unconditional for the same reason one scope wider: it governs whether another repository may be *worked in at all*, and the first read there is already past the point a scoped rule would arrive.

**`.claude/protocol.md`**, from [protocol.template.md](protocol.template.md), copied as-is — `owner: framework`, its `version` stamped correctly by construction because the template ships with the release that ships it. The only lines a repository may vary are the extension point the file's own opening paragraph names. The router rather than a rule — the Marker, the drift reads, the verification report, and the table saying which guides each stage reads — so it is reached by pointer and a question turn does not pay for it.

**The framework's own guides are not installed at all.** Eight describe the workflow and ship as `framework`-owned records in the framework store, delivered onto a stage's row rather than copied into a tree; the seven reasoning postures ship the same way, one record each. What this run writes is the part that describes *this* repository: two derived guides and the record format, in the repository's own store, exactly as the tool references are — a copied guide would hand this repository somebody else's facts.

**Every record declares its owner in frontmatter, and the derivation honours it.** A framework record declares `owner: framework` and is never copied into a repository at all — law, delivered rather than installed, so there is no installed copy to diff and none to heal. A derived record declares `owner: repository`, and the repository's facts go into the **declared fields** its template names — the extension points — never into rewritten framework prose. **A repository variation with no declared point to enter through is recorded as a deviation**, and a deviation is a **declared edge, never a paragraph**: the departing record declares `deviates-from` naming the framework record it departs from, with its reason and the release it was declared under as declared fields beside it. The build reports every one of them on every run until it is removed — so it is loud by construction, and **removing the edge removes the report with no other edit**. The prose section this used to be could only be surfaced by an audit that remembered to open the right file, which is exactly the class of check that stops running.

| Guide | Store | Covers |
| --- | --- | --- |
| `knowledge.md` | framework | how knowledge loads, what heals it, and when |
| `context.md` | framework | what belongs in Context, and the compression test |
| `decisions.md` | framework | when a Decision is worth recording, and the numbering |
| `tickets.md` | framework | the ticket format, the hierarchy, the edges, the lifecycle |
| `specs.md` | framework | the spec sections and the status vocabulary |
| `maps.md` | framework | the fog branch, worked before any spec exists |
| `evidence.md` | framework | gating, and how a finding graduates into knowledge |
| `sub-agents.md` | framework | what a dispatched child may use, what is closed to it, the brief and the change record |
| `records.md` | **this repository's** | the record format every other record here is written to |
| `tracker.md` | **this repository's, derived** | which tracker, and the label vocabulary behind each role |
| `version-control.md` | **this repository's, derived** | which model, the branch convention, how work lands |

The guides are what the workflow's stages read instead of restating, and each reaches a stage by naming it in `stages`. A guide naming no stage is unreachable, so declare it in the same pass.

**Write the whole set or none of it.** The entrypoint points at the always-on files and the protocol's table at every guide, so a run that writes the entrypoint and stops leaves pointers going nowhere — worse than never having split the file, because the rules are now missing rather than merely expensive.

**More `.claude/rules/*.md`** for standards discovered in *this* repository, each declaring `owner: repository` — a discovered standard is the repository's to heal, and the declaration is what the audit's coverage sweep reads — and each **path-scoped** where it applies to part of the tree: a standard about `packages/api/` says so in `paths:` frontmatter and is not paid for while working in `docs/`. A standard with no `paths:` is a permanent per-turn cost, so adding one is a decision rather than a default.

**`.claude/knowledge/tracker.md`**, from [policies/tracker.template.md](policies/tracker.template.md). Choose from the **remote**: GitHub when a remote points at GitHub, GitLab when one points at GitLab, local markdown otherwise — including when there is no remote, and when the remote is a host with no tracker AEP drives. **Ask when it is ambiguous** — several remotes, or a remote that does not match where work is actually tracked. The triage label vocabulary folds into the same file. So does **`What a ticket is`**: answer the detect test the template carries from `version-control.md` — written after that record, for exactly this reason — and cite the line the answer came from. The maps guide places decision work by reading the declaration, so a missing one is not a blank to leave. So does **`Where a spec lives`**: **read it off the tree, never ask**, by the detect test the template carries — a repository is not consulted about a layout its own directories already answer. [SCRIPTS.md](SCRIPTS.md) sends the index regenerator to this declaration, so a file written without it hands a script an input nothing states.

**`.claude/knowledge/version-control.md`**, from [policies/version-control.template.md](policies/version-control.template.md). The tracker record's neighbour: that says where the tickets are, this says what happens to one once somebody builds it. **Which model applies is read off the repository, not asked about**, by the check the template itself carries — a stacking tool installed on the machine says nothing about this repository. The branch convention and commit discipline are *detected*, from the recent branches, `CONTRIBUTING.md`, and the log; asserting AEP's defaults over a repository that demonstrates its own is what the detect-before-asserting rule forbids.

**`.claude/knowledge/records.md`**, from [policies/records.template.md](policies/records.template.md) — the format every other record in this store is written to. It carries no repository fact and so is not derived, and it declares `owner: repository` because a repository's own store is the repository's to heal.

**One `reference` record per tool this repository actually uses** — the workflow's own (`git`, `gh`, `glab`, `gt`) *and* this repository's (package manager, test runner, typechecker, linter, formatter, build, deploy), in the store with one format. [TOOLS.md](TOOLS.md) has the derivation rules and the format; it is the step where information is most easily lost, so read it before writing one.

Take every repository-specific command from the manifest, scripts, or CI configuration, never from what the ecosystem usually does. The **single-file test command** is the one entry that must not be missing — the most-run command in the framework and the least guessable, and `tdd` says what happens without it. What a derivation that cannot find it does instead is [TOOLS.md](TOOLS.md)'s.

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

The canonical layout names `worktrees/` as the harness's rather than this workflow's, which is what puts it inside the entry-for-entry comparison of this tree against that layout. `/configure` never creates it: the harness does, the first time a stage dispatches an isolated child.

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

Which formatters those are comes from step 1's read of the repository, never from a list here, and only the ones whose reach actually includes `.claude/` need anything. Make each one skip it **through its own ignore mechanism**, which its reference record describes — a formatter this repository runs earns one like every other tool it runs, and **no entry for it is a configuration gap**, not licence to guess a filename.

That mechanism is the formatter's, so it is usually a file the repository owns, which is what the ignore rule above deliberately does not touch. **What `/configure` writes outside `.claude/` and `CLAUDE.md` is a bound, not a count**: only what the workflow's specification names for the running release — today the formatter exclusions, and nothing else — each write planned in step 2 and listed in the report, and the audit asserts the written set equals the specified set. A count is re-falsified by every legitimate addition; the bound survives them and still catches the unplanned write.

## 5 — Audit, where AEP is already here

The audit branch exists because **verification at use structurally cannot reach knowledge nothing loads**: a context record nobody references is never relied on, so nobody ever checks it — it just sits there being wrong.

**This pass runs the build and reports what it said.** One move rather than a list: a check living in a stage fires when somebody remembers to run the stage, and a check living in the build fires on every commit whoever made it. What is left here is what a build cannot know.

**A check that moved and a check that vanished must never look the same**, and the table is what keeps them apart. Every check the 1.x audit performed has a row, and every row's disposition is one of four words:

| Disposition | What it means |
| --- | --- |
| **build** | the store builder performs it, on every run, failing or reporting under its own name |
| **generation** | step 4 performs it, on every run, against the repository the file claims to describe |
| **here** | this stage still performs it, because a build cannot know it |
| **removed** | nothing performs it, and the row says why nothing needs to |

| The 1.x check | | Because |
| --- | --- | --- |
| Prune what nothing references | **here** | the build reports a record nothing cites; only a human can tell an orphan from a root, and this is the pass that deletes |
| Validate the routing table | **removed** | the table is a query over declared fields, so there is no committed index left to disagree with the directory it described |
| Check `map.md` carries routing and nothing else | **removed** | with the table it was about |
| Re-check Source Pointers | **build** | every pointer that no longer resolves is counted and named, including the ones no recent work touched |
| Re-check the tool references | **generation** | a file that exists is checked against the repository it describes, which is where a stale command surfaces |
| Re-check `What a ticket is` | **generation** | the detect test travels with the tracker record, and step 4 writes that record on every run |
| Re-check `Where a spec lives` | **generation** | the same test on the same run, answered from the tree |
| Mark specs reality already satisfies | **here** | whether a last acceptance criterion is met is a judgement, and no build makes one |
| Apply the repairs this repository has not had | **here** | only a configuration run knows which release a repository came from |
| Re-check `.claude/scripts/` against [SCRIPTS.md](SCRIPTS.md) | **here** | which scripts a clone holds is a fact about that clone, and the build reads what ships |
| Re-check the regenerate-and-compare check | **removed** | the check itself is gone — its script retires at this release, and the indexes it wrote are queries |
| Regenerate the routing tables | **removed** | with the indexes |
| Sweep every committed file and classify it | **removed** | the sweep existed because framework files were copied into a repository, and nothing is copied |
| Quote the enumeration and the counts | **removed** | with the sweep that produced them |
| A committed file fitting no category is a finding | **removed** | with the sweep |
| Exempt exactly the per-clone set | **removed** | with the sweep |
| A governed file declaring no owner is a finding | **build** | `owner` is a closed vocabulary and absence is refused rather than defaulted — the one half of the sweep whose subject survived it |
| Re-check every installed file against its owner's contract | **removed** | nothing is installed, so there is no copy to compare against a template |
| The `version` stamp routes attention and settles nothing | **removed** | with the comparison it routed attention to; the core files keep their stamps and the session hook reads them |
| Surface every deviation | **build** | every `deviates-from` is reported on every run until somebody removes it |
| The upgrade path replaces framework files verbatim | **removed** | an upgrade moves no file in a repository, because no file of the framework's is in one |

**One half of the deviation report is specified and performed by nothing.** A deviation one release old with no disposition is specified to fail, and nothing computes an age: the fields carrying a deviation's reason and the release it was declared under have no names anywhere to read them from. It is named here for the reason the table exists — a check nobody wrote and a check somebody removed must not read the same — and it is not a 1.x check, so it has no row above.

**Byte comparison against what AEP ships is gone with the copying.** The templates live in the plugin, whose root the harness exposes to skill content and to a hook but never to a stage's shell, so a repository has nothing to compare against even where something would be worth comparing. What replaces it for the one thing still copied is the release each script declares, read on the one surface holding both releases at once.

### What this stage still does

**Run the build, and quote what it said.** The figures and the findings are the build's; repeating them in this stage's own words is how two accounts of one run start to differ.

**Prune what nothing references.** The build reports a record nothing cites and never fails on one. Removing it is a judgement — an orphan and a root read alike — so it happens here, it says what went and why, and it goes through step 2's plan like everything else that deletes.

**Mark specs reality already satisfies.** `/commit` marks a spec `implemented` when it lands the last criterion; a spec finished outside that path stays `accepted` forever. This pass catches those.

**Apply the repairs this repository has not had.** [migration-changelog.md](migration-changelog.md) holds every repair that fires because of *which release* configured a repository, grouped by the release that caused it. Read `version` from `.claude/protocol.md` — falling back to the legacy field as that page states — and consider only entries newer than it; a repository declaring no version at all predates both fields and gets all of them. Each entry still recognises its shape by content before acting, so one considered against a repository that never had that shape is a no-op rather than a mistake. **Say which releases were skipped** — an audit that considered three of ten reads exactly like one that found nothing. Replacing the protocol file verbatim leaves the field at the release running this audit, so the next run's cursor is right and the session hook stops reporting a repository this run brought current.

**Re-check `.claude/scripts/` against [SCRIPTS.md](SCRIPTS.md)**, in both directions: every script the page specifies for this release exists, and nothing sits there that it does not specify. A repository configured by an earlier release has only the scripts that release named, so a missing one is a stage whose input nothing produces — and it fails at the moment that stage runs, not here, unless this pass looks.

**A repository-owned record whose facts no longer match the repository is reported with the record named, never silently re-derived.** A record nobody touched on purpose is re-derived; one carrying a deliberate local correction is left alone with the difference stated. The two are not distinguishable from the content, which is why this asks rather than decides — and the tool references are exactly where a repository keeps corrections verified against its own tooling, corrections that can be *ahead of* what AEP ships ([TOOLS.md](TOOLS.md)'s upward refresh path).

## 6 — Validate

Before reporting complete:

- **The build ran, and every figure in its report is accounted for** — a pointer that no longer resolves, a record nothing cites, a declared deviation. A figure quoted and left alone reads exactly like a figure nobody read, and a broken pointer is handled the way `CLAUDE.md` requires.
- No **implementation** was written into Context — no API shapes, no function names, no file inventories.
- Every file the always-on set points at exists: `CLAUDE.md`, `.claude/protocol.md`, and every rule under `.claude/rules/` that carries no `paths:` frontmatter — plus every record the framework pushes beside them. **Count them from the install step above rather than from a number written here** — this line said "the two rules" while that step installed three, and was wrong from the release that added the third until somebody read the two together. **Nothing committed depends on a file `.claude/.gitignore` matches** — read `CLAUDE.md` as a Claude without the plugin would, follow every pointer, and confirm each rule it reaches is followable.
- `.claude/.gitignore` exists and states the category, not a list.
- **Nothing that formats this repository reaches `.claude/`.** The outcome, not the edit — a formatter whose ignore file was written but whose config overrides it is still reformatting knowledge.

Report what was written, what was moved, and what was left alone.

## Running it again

`/configure` is **idempotent**: a second run reports what already exists rather than duplicating it. The audit branch makes re-running the *intended* way to use it, so a run that appended instead of recognising would make the repository worse every time it was maintained.

Recognition is by content, not by presence. A file that exists but describes a structure the repository no longer has is not "already done" — it is the audit's first finding.

## What stays with the caller

`/configure` **does not plan work and does not write code.** It finds a repository that needs designing and hands back; `/design` is the entry point for that, and taking it here would skip the grill.

It never commits. What it wrote is left in the working tree for the user to read, and `/commit` handles it from there.
