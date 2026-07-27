# feat(configure): initialize or migrate a repository onto Tenure

Status: resolved
Blocked by: 02, 03, 13

## Problem

`/configure` is how a repository joins Tenure. It must handle a greenfield repo, a repo with existing AI tooling, and — the case we will actually run first — a repo already using mattpocock's conventions.

## Outcome

`./skills/configure/` — user-invoked.

**One job: make repository knowledge correct and complete.** Onboarding and auditing are not two responsibilities bolted together — they are the same job against different starting states, and a repo with no knowledge is the degenerate case of one whose knowledge is incomplete. The behaviour is chosen by what it finds, never by a flag:

| Starting state | What it does |
| --- | --- |
| No Tenure, no AI workflow | Analyse, generate `context.md` + contexts + `CLAUDE.md` |
| No Tenure, another AI workflow present | The above, plus the migration below |
| Tenure already present | Audit — prune what nothing references, validate the routing table, re-check pointers, mark specs reality already satisfies |

The audit branch exists because verification-at-use structurally cannot reach knowledge **nothing loads**: unused context is never checked, because nobody checks what they don't read.

**Detect.** Search for existing AI workflows: `.claude/`, `CLAUDE.md`, `AGENTS.md`, `docs/agents/`, `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, `.scratch/`, `.cursor/`, `.github/copilot-instructions.md`, `.windsurf*`, `.clinerules`, `.ai/`.

**Plan, confirm, apply.** Present the full move list before touching anything; apply on approval. The mattpocock migration:

| From | To |
| --- | --- |
| `CONTEXT.md` | `.claude/context.md`, reshaped to orientation + routing table |
| `docs/adr/*` | `.claude/docs/decisions/` |
| `docs/agents/*` | folded into `CLAUDE.md` and `.claude/`, originals removed |
| `.scratch/*` | `.claude/tickets/` |

**Classify, never copy.** Existing documentation is sorted, not duplicated: implementation explanations stay in source; principles become context; historical reasoning becomes decisions; developer instructions become `CLAUDE.md`; temporary notes are discarded.

**Adopt the engineering, convert the workflow** (ADR 0008). `/configure` inherits the repository's own conventions — commit style, label vocabulary, source and test layout, human docs — rather than replacing them with Tenure's defaults. It may name a convention it thinks is worse, once, with reasoning, and then follow it.

The AI workflow layer is the exception and converts wholesale: agent instruction files, repository knowledge, agent workflow config, agent ticket stores, and the way work is done. Leaving any of it in place produces two competing workflows. Where a converted file is still referenced from `README.md`, `CONTRIBUTING.md`, or source comments, leave a pointer at the old path rather than a broken link.

**Analyse and generate.** Languages, build, test, deploy, architectural style, module boundaries, domains. Write `.claude/context.md` with the routing table, and a `contexts/*.md` only where a domain has its own vocabulary, principles, or ownership — never because a folder exists.

**Write `CLAUDE.md`** as the entrypoint from the template in ticket 13: under 200 lines, routing plus always-on rules, no knowledge. Preserve the user's existing sections. Emit repo-discovered standards as path-scoped `.claude/rules/*.md`.

**Write `.claude/tracker.md`** — which tracker this repo uses and how to drive it. GitHub when a remote points there, local markdown otherwise; ask when it's ambiguous. Triage labels fold into the same file.

**Write `.claude/tools/*.md`** — the repo's own tooling in the ticket 15 format: package manager, test runner, typechecker, linter, build, deploy. Task-to-command, with docs URLs and the condition for fetching them. This is what stops `/implement` and `tdd` guessing how to run a single test file.

**Validate.** Every Source Pointer resolves; every file in `contexts/` appears in the routing table; no implementation duplication; `.claude/.gitignore` exists covering `marker.json` and `prototypes/`, so the workflow stays self-contained and the repo's root ignore file is left alone.

## Acceptance

- Running it twice produces no duplication and reports what already exists.
- No documentation is deleted without appearing in the confirmed plan.
- Fresh repo and mattpocock-repo paths both work.

## Comments

**The branch table was wrong on the first pass, and the acceptance criterion
depended on it.** `Tenure already present → audit` reads as three pipelines,
so a first run interrupted halfway — `context.md` written, `tracker.md` not —
detects as *already present*, audits, and never finishes. The audit row now
reads *"audit, and generate whatever is still missing"*, and step 4 writes what
is absent and checks what is present on **every** branch. What detection
selects is what is *found*, never which steps run. This is a deviation from the
ticket's table wording (`Audit —` only) and the operative half of *"running it
twice ... reports what already exists"*: idempotence that stops early is
idempotent and also wrong.

**`.claude/`'s remaining directories are created lazily, which the ticket does
not say.** ADR 0006's layout includes `docs/{designs,research,prototypes}/`,
`tickets/`, and `prototypes/`, and `/configure` creates none of them.
`domain-modeling` already requires files to be created only when there is
something to write, and an empty `docs/research/` is a claim that research
happened. The layout is named with who fills it instead.

**Ticket 01's legacy-path guard needed an exemption, and the first one was a
hole.** `/configure` cannot detect or convert `CONTEXT.md`, `docs/adr/`, or
`.scratch/` without naming them. The exemption was first written as the prefix
`configure*`, which also exempted `CLAUDE.template.md` and
`tracker.template.md` — files installed into the *user's* repository, and
previously guarded like any other. Now two named files, and the assertion that
makes it safe is a **sweep**, not a checklist: every legacy path either file
names must have a conversion row saying where it goes. The first version
checked four known conversions exist somewhere, which says nothing about a
fifth reference that is simply stale.

**Three rules had a second home here and lost it.** The compression test was
attributed to `domain-modeling`, which ticket 13 moved to `CLAUDE.md`. ADR
0008's *"say so once, with reasoning"* escape clause was restated in
`MIGRATION.md`. And *"a stale command is worse than no command"* appeared
verbatim in both `configure/SKILL.md` and `tools/SKILL.md`. All three now have
`$singleHome` entries.

**A fourth was already in four places before this ticket touched it.** The
reason a guessed test command wrecks the loop — *"turns into a full-suite run
per cycle"* — was in `tdd`, `/implement`, `tools/SKILL.md`, and the first draft
of `/configure`. `tdd` owns the loop, so it keeps the reason; the other three
point. Guarded now, so it cannot spread again.

**Two additions the ticket does not ask for.** `MIGRATION.md`'s *"when the
migration is only partly possible"* — a wrong classification is invisible
afterwards, because nothing in the target layout records that a file arrived
there by assumption. And `/configure`'s closing note that it neither plans work
nor commits: ADR 0011 makes `/design` the planning surface, and without the
line the skill that has just read a whole repository is the obvious place to
start planning against it.

**Spec decision numbers were cited and then removed.** `(decision 23)` and
`(decision 36)` point at `.scratch/tenure/spec.md`, which does not ship with
the skill — and is the ticket store `/configure` migrates away. ADR citations
have precedent in shipped skills; spec decision numbers do not resolve in a
host repository.

**`verify.ps1` gained two helpers and lost a portability bug.** `Get-Section`
scopes an assertion to the step that owns the rule — nine of the first
seventeen mutations survived because a file-wide pattern matched unrelated
prose. It masks fenced code by index rather than stripping it, because
`/configure`'s detection list *is* a fenced block. `Test-UserInvoked` replaces
nine unanchored frontmatter regexes: unanchored, a commented-out line passes,
and for the primitives the check runs in the negative direction where a false
positive is silent. The exemption list also hardcoded `\`, which fails every
ticket-01 assertion on a non-Windows machine.

294 assertions, 57 mutations. Two earlier harnesses had stale find-strings
against `/commit` and `/implement` and were repaired; a mutation harness killed
by a timeout leaves the tree mutated, which is worth knowing before running one
under a deadline.
