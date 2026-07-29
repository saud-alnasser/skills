---
name: configure
description: Make this repository's knowledge correct and complete — detect what is already here, generate what is missing, migrate another AI workflow onto Tenure, and prune what nothing loads. Use when onboarding a repository, or to audit one already running Tenure.
disable-model-invocation: true
---

# Configure

Policies: every guide in `.claude/policies/` — this is the command that writes them, and an audit run reads each one back.

`/configure` has **one job: make repository knowledge correct and complete.** Onboarding and auditing are not two responsibilities bolted together — they are the same job against different starting states, and a repository with no knowledge is the degenerate case of one whose knowledge is incomplete.

Which branch runs is decided by **what it finds, never by a flag.** A flag lets the caller assert a starting state; detection discovers one, and the caller is usually wrong about which repository they are standing in.

| What is already here | What this run does |
| --- | --- |
| no Tenure, no AI workflow | analyse, then generate |
| no Tenure, another AI workflow present | the above, plus the migration in [MIGRATION.md](MIGRATION.md) |
| Tenure already present | audit, and generate whatever is still missing |
| Tenure present on a superseded layout | the above, plus the layout migration in [MIGRATION.md](MIGRATION.md) |

**Every run generates.** The third row audits *as well*, it does not audit *instead* — a first run interrupted halfway leaves a repository with `context.md` and no `tracker.md`, which detects as "Tenure already present" and would otherwise never be finished. The branch changes what is *found*, never which steps run.

## 0 — Verification

Open with the one-line verification report, exactly as every other skill does — including on a fresh repository, where it reads *"no Tenure here — nothing to verify"*. The rule is in `.claude/protocol.md`, which on a fresh repository this run is about to write.

An audit run has Context to check and is the one case where this is real work. It still reports in one line; what it *finds* belongs to step 5.

## 1 — Detect

Nothing is generated before the repository has been looked at. Search for an existing AI workflow:

```
.claude/            CLAUDE.md            AGENTS.md
CONTEXT.md          CONTEXT-MAP.md       docs/agents/
docs/adr/           .scratch/            .ai/
.cursor/ .cursorrules                    .windsurfrules
.clinerules         .github/copilot-instructions.md

— Tenure's own superseded layouts:
.claude/docs/       .claude/tenure.md    .claude/context.md
.claude/tracker.md  .claude/version-control.md
.claude/marker.json .claude/prototypes/
```

The second group is what a repository configured by an **earlier version of this workflow** looks like. Finding any of them selects the layout migration rather than the conversion one — the file formats are already correct and only their locations are wrong, which makes it mechanical work with a mechanical risk: a reference left pointing where a file no longer is.

Then read the repository itself: languages, package manager, build, test, deploy, CI, source layout, **architectural style**, module boundaries, domains, and the conventions it already follows. **Read `CONTRIBUTING.md` and the recent `git log`** — those are how the repository documents and demonstrates its own conventions, and `CLAUDE.md`'s detect-before-asserting rule is what makes that a step rather than a courtesy.

**Find the knowledge that is already written down**, wherever it lives: architecture documents, onboarding and developer guides, design documents, decision records, engineering standards, coding conventions. These are not an AI workflow and are not detected by the list above — they are ordinary documentation, usually under `docs/`, and they are the input the classification step works on. A migration that never found them classifies nothing and silently generates a repository's knowledge from scratch when it was already written.

Classify what kind of repository this is — library, CLI, service, monorepo, application — because it changes what domains exist and what tooling matters.

Read what you find. A `docs/adr/` directory is not proof that ADRs are in it, and detection is the step where that failure is easiest to make, because everything it looks at is a path.

## 2 — Plan, confirm, apply

Present the **full move list before touching anything**: every file to be created, converted, moved, or deleted, with its destination. Apply only on approval.

**Nothing is deleted that did not appear in the confirmed plan.** This is the rule the whole step exists for — `/configure` runs against repositories with years of documentation in them, and a wrong classification that deletes is not recoverable from the tree.

The user may strike any line. A struck line is not worked around: leave it as it is and say what that means for the rest.

## 3 — Migrate, where there is something to migrate

[MIGRATION.md](MIGRATION.md) has this branch, and step 1 decides whether to open it: another AI workflow found, or Tenure found on a superseded layout, read it; greenfield, skip it entirely. Reading it on a repository with nothing to migrate costs context and answers nothing.

The two cases are different work and only one page. Converting another workflow classifies prose and reshapes it, so it is judgement all the way down. Converting Tenure's own superseded layout moves files whose format is already correct, so it is mechanical — and its risk is the opposite one: not a wrong classification, but a reference left pointing at a directory that no longer exists.

## 4 — Generate

**Write what is missing; check what is already there.** Both, on every run — a file that exists is checked against the repository it claims to describe, and one that does not is written. Neither is conditional on which branch step 1 selected.

The shape being generated, so the tree reads as its own map — every category is a directory, and the one loose file is the router the entrypoint points at:

```
.claude/
├── protocol.md          the router — the only file loose here
├── rules/               always-on and path-scoped standards
├── policies/            one guide per workflow concern
├── contexts/            map.md, repository.md, and the domains
├── decisions/           ADRs
├── designs/             specs
├── evidence/            research, prototypes, out-of-scope
├── tickets/             one directory per effort
├── tools/               one file per tool this repository uses
├── position/            per-clone state — never committed
└── .gitignore           what per-clone means, and the test for it
```

**A second loose file is a category nobody named.** When something does not fit a directory above, that is the finding — say so rather than dropping it at the root.

The rest of the tree — `.claude/decisions/`, `.claude/designs/`, `.claude/evidence/{research,prototypes,out-of-scope}/`, `.claude/tickets/`, and `.claude/position/` — is **created lazily**, by whichever command first has something to put in it. `/configure` does not pre-create empty directories: an empty `evidence/research/` is a claim that research happened.

**`.claude/contexts/**`**, as three kinds of file: `.claude/contexts/map.md` holding the routing table alone, `.claude/contexts/repository.md` holding the vocabulary and boundaries that cross domains, and one file per domain that earns one. The format, the placement rule for a term, and the test a domain has to pass are in [policies/context.template.md](policies/context.template.md), which this run installs at `.claude/policies/context.md`; the compression test that gates every line is in `CLAUDE.md`.

What is `/configure`'s is the *sourcing*: these are generated from the repository, so every concept written down was read out of the code, and a domain that only has a folder does not get a file. **Write `map.md` last**, once it is known which domains earned a file — a routing table written first is a list of intentions, and every row it names has to exist.

**`CLAUDE.md`** at the root, from [CLAUDE.template.md](CLAUDE.template.md). Fill the placeholders; do not rewrite the rules. **Preserve the user's existing sections** — a repository's `CLAUDE.md` usually already carries instructions somebody wrote deliberately, and replacing the file wholesale destroys them. Merge into it.

**`.claude/rules/precedence.md`** and **`.claude/rules/engineering.md`**, from [precedence.template.md](precedence.template.md) and [engineering.template.md](engineering.template.md), copied as-is — they describe the workflow's standards, not this repository, so there is nothing to fill in. Neither carries `paths:` frontmatter, which is what makes the harness load them on every turn: these are the rules `CLAUDE.md` stopped stating so that it could stay a pointer, and a rule reachable only through a pointer fires only when something follows it.

**`.claude/protocol.md`**, from [protocol.template.md](protocol.template.md), copied as-is for the same reason. It is the router rather than a rule — the Marker, the drift reads, the verification report, and the table saying which guides each stage reads — so it is reached by pointer and a turn that answers a question does not pay for it.

**`.claude/policies/`**, one guide per workflow concern or repository aspect. Seven describe the workflow and are copied as-is from [policies/](policies/); two describe *this* repository and are derived, exactly as the tool references are (ADR 0019) — a copied guide would hand this repository somebody else's facts.

| Guide | Source | Covers |
| --- | --- | --- |
| `knowledge.md` | copied | how knowledge loads, what heals it, and when |
| `context.md` | copied | what belongs in Context, the routing table, the compression test |
| `decisions.md` | copied | when a Decision is worth recording, and the numbering |
| `tickets.md` | copied | the ticket format, the hierarchy, the edges, the lifecycle |
| `specs.md` | copied | the spec sections and the status vocabulary |
| `maps.md` | copied | the fog branch, worked before any spec exists |
| `evidence.md` | copied | gating, and how a finding graduates into knowledge |
| `tracker.md` | **derived** | which tracker, and the label vocabulary behind each role |
| `version-control.md` | **derived** | which model, the branch convention, how work lands |

The guides are what the workflow's stages read instead of restating; `.claude/protocol.md`'s routing table says which stage reads which, and is the only index. A guide with no row is unreachable, so write the row in the same pass.

**Write the whole set or none of it.** The entrypoint is a pointer at the always-on files, and the protocol's table is a pointer at every guide, so a run that writes the entrypoint and stops leaves those pointers going nowhere — which is worse than never having split the file, because the rules are now missing rather than merely expensive.

**More `.claude/rules/*.md`** for standards discovered in *this* repository. Each is **path-scoped** where it applies to part of the tree: a standard about `packages/api/` says so in `paths:` frontmatter and is not paid for while working in `docs/`. A standard with no `paths:` is a permanent cost on every turn, so adding one is a decision rather than a default — the two written above are the baseline, not the beginning of a collection.

**`.claude/policies/tracker.md`**, from [policies/tracker.template.md](policies/tracker.template.md). Choose from the **remote**: GitHub when a remote points at GitHub, GitLab when one points at GitLab, local markdown otherwise — including when there is no remote, and when the remote is a host with no tracker Tenure drives. **Ask when it is ambiguous** — several remotes, or a remote that does not match where work is actually tracked. The triage label vocabulary folds into the same file.

**`.claude/policies/version-control.md`**, from [policies/version-control.template.md](policies/version-control.template.md). The tracker file's neighbour: it says where the tickets are, this says what happens to one once somebody builds it. **Which model applies is read off the repository, not asked about**, by the check the template itself carries — a stacking tool being installed on the machine says nothing about this repository. The branch convention and the commit discipline are *detected* the same way everything else in step 1 was, from the recent branches and `CONTRIBUTING.md` and the log; asserting Tenure's defaults over a repository that demonstrates its own is what ADR 0008 forbids.

**`.claude/tools/*.md`**, one file per tool this repository actually uses — the workflow's own (`git`, `gh`, `glab`, `gt`) *and* this repository's (package manager, test runner, typechecker, linter, build, deploy), in one directory with one format. [TOOLS.md](TOOLS.md) has the derivation rules and the format; it is the step where information is most easily lost, so read it before writing a tool file.

Take every repository-specific command from the manifest, scripts, or CI configuration, never from what the ecosystem usually does. The **single-file test command** is the one entry that must not be missing — the most-run command in the framework and the least guessable, and `tdd` says what happens without it.

**`.claude/.gitignore`**, written exactly as below. It is Position's definition (ADR 0012), so it states the category and the test rather than listing entries — a per-clone file added later is covered by the rule instead of needing a new exception argued for:

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
# `settings.local.json` is separate because it is not the workflow's. The
# harness writes it at exactly that path and would not find it anywhere else,
# so it is the one per-clone file that cannot be moved under `position/`.
#
# The leading slash is still load-bearing: unanchored, `position/` would match
# at every depth and swallow any directory of that name in the repository.

/position/
settings.local.json
```

It goes inside `.claude/`, and **the repository's own root `.gitignore` is left alone** (ADR 0006) — that is what lets Tenure be added or removed as one directory instead of leaking entries into a file the repository owns.

## 5 — Audit, where Tenure is already here

The audit branch exists because **verification at use structurally cannot reach knowledge nothing loads.** Verification fires when a statement is about to be relied on; a context file nobody references is never relied on, so nobody ever checks it. It does not decay loudly — it just sits there being wrong.

So this pass reaches what the routing table does not:

- **Prune what nothing references.** A Domain Context absent from the routing table, or one whose domain no longer exists, is removed. Say what was removed and why.
- **Validate the routing table** — every file under `contexts/` has exactly one row in `map.md`, including `repository.md`, and every row points at a file that exists.
- **Check `map.md` carries routing and nothing else.** Orientation prose that drifted into it is charged to every session, which is the cost the split removed.
- **Re-check Source Pointers**, including the ones no recent work touched.
- **Re-check `.claude/tools/`.** A repository's tooling changes, and a stale command is worse than no command: no command asks, a wrong one runs.
- **Mark specs reality already satisfies.** `/commit` marks a spec `implemented` when it lands the last criterion; a spec finished outside that path stays `accepted` forever. This pass catches those.

Pruning deletes, so it goes through step 2's plan like everything else.

## 6 — Validate

Before reporting complete:

- Every **Source Pointer** resolves, and a broken one is handled the way `CLAUDE.md` requires.
- Every file under `contexts/` appears in the **routing table**, exactly once.
- No **implementation** was written into Context — no API shapes, no function names, no file inventories.
- Every file the always-on set points at exists: `CLAUDE.md`, `.claude/protocol.md`, and the two rules under `.claude/rules/`. **Nothing committed depends on a file `.claude/.gitignore` matches** — read `CLAUDE.md` as a Claude without the plugin would, follow every pointer, and confirm each rule it reaches is followable.
- `.claude/.gitignore` exists and states the category, not a list.

Report what was written, what was moved, and what was left alone.

## Running it again

`/configure` is **idempotent**: a second run reports what already exists rather than duplicating it. That is not a nicety — the audit branch means re-running is the *intended* way to use it, so a run that appended instead of recognising would make the repository worse every time it was maintained.

Recognition is by content, not by presence. A `context.md` that exists but describes a structure the repository no longer has is not "already done" — it is the audit's first finding.

## What stays with the caller

`/configure` **does not plan work and does not write code.** It finds a repository that needs designing and hands back; `/design` is the entry point for that, and taking it here would skip the grill (ADR 0011).

It never commits. What it wrote is left in the working tree for the user to read, and `/commit` handles it from there.
