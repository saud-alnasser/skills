# Migrating another AI workflow onto AEP

Everything below runs through `/configure`'s plan-and-confirm step. **Nothing is moved or deleted before the user has seen it in the confirmed plan**, and a line the user strikes stays as it is.

## What converts, and what is adopted as found

ADR 0008 draws the line, and `CLAUDE.md` carries the principle it rests on. In a migration: the repository's own engineering is **adopted as found**, and the AI workflow layer converts **wholesale** — that layer is what AEP replaces, and leaving it in place produces **two competing workflows**, each with its own idea of where knowledge lives.

| Converts to AEP | Adopted as found |
| --- | --- |
| agent instructions — `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurfrules`, `.clinerules`, `.ai/` | source layout, module structure, naming |
| repository knowledge — `CONTEXT.md`, `CONTEXT-MAP.md`, decision records wherever they live | test layout and framework |
| agent workflow config — `docs/agents/`, tracker and label configuration | build, CI, and release configuration |
| agent ticket stores — `.scratch/` and equivalents | commit style, label vocabulary, PR template |
| how work is done — the command pipeline, tiers, knowledge ownership | human documentation — `README.md`, `CONTRIBUTING.md`, and `docs/` that is not agent config |

A file that is both — decision records are human-facing history *and* AEP's Decisions layer — converts, because AEP owns that layer.

Changing a repository's conventions is a decision for its maintainers, not a side effect of adopting a workflow. `CLAUDE.md` says what to do when one of them looks wrong.

## The mattpocock migration

The case this will meet most often, since AEP is derived from those skills. Each row is a conversion, not a copy — the destination shape is different from the source shape, so read the target format before writing.

| From | To |
| --- | --- |
| `CONTEXT.md` | `.claude/contexts/repository.md`, reshaped to orientation; its routing table becomes `.claude/contexts/map.md` |
| `CONTEXT-MAP.md` | deleted — structure is carried by directories under `.claude/contexts/` |
| `docs/adr/*` | `.claude/decisions/`, unchanged in content |
| `docs/agents/*` | folded into `CLAUDE.md` and `.claude/policies/tracker.md`; the originals are removed |
| `.scratch/*` | `.claude/tickets/` |

`CONTEXT.md` is the only genuine rewrite: matt's is a glossary; AEP's is orientation with a routing table. The glossary's terms survive; the file's shape does not.

## The AEP layout migration

AEP once grouped decisions, designs, research, and prototype write-ups under `.claude/docs/`. ADR 0018 dissolved that level, so a repository configured before it needs carrying across. This is the one migration whose source *is* AEP — every other row on this page converts somebody else's workflow.

| From | To |
| --- | --- |
| `.claude/docs/decisions/*` | `.claude/decisions/`, unchanged in content |
| `.claude/docs/designs/*` | `.claude/designs/`, unchanged in content |
| `.claude/docs/research/*` | `.claude/evidence/research/`, unchanged in content |
| `.claude/docs/prototypes/*` | `.claude/evidence/prototypes/`, unchanged in content |
| `.claude/docs/out-of-scope/*` | `.claude/evidence/out-of-scope/`, unchanged in content |
| `.claude/docs/` itself | deleted, once empty |

**A file moves; it is never rewritten.** Nothing here changes shape — the whole change is which directory the file sits in. Classification does not apply and neither does the compression test: this content was already admitted to AEP once.

**ADRs keep their filenames.** The rule is in the numbering section of `.claude/policies/decisions.md`, and it governs this move exactly as it governs a migration in from somebody else's layout.

Then repair what pointed at the old paths — `CLAUDE.md`, `.claude/contexts/`, the Domain Contexts, tickets, and specs all name these locations. **Do not leave a pointer stub**: every reference here is inside AEP's reach, so the fix is to update it.

A repository that has never had `.claude/docs/` needs none of this. Say so and skip it; there is nothing to report but its absence.

## The guides-and-position migration

The second migration whose source is AEP. A repository configured before the workflow directory was reorganised has its guides loose at the root, its per-clone state beside them, and its entrypoint carrying rules that now load from `.claude/rules/`.

Every row is **mechanical except one**, and the exception is called out because treating it as a move loses half the file.

| From | To |
| --- | --- |
| `.claude/tenure.md` | `.claude/protocol.md` — renamed, and gains the routing table |
| `.claude/tracker.md` | `.claude/policies/tracker.md` |
| `.claude/version-control.md` | `.claude/policies/version-control.md` |
| `.claude/context.md` | **split** — see below |
| `.claude/marker.json` | `.claude/position/marker.json` |
| `.claude/prototypes/` | `.claude/position/prototypes/` |
| — | `.claude/rules/{precedence,engineering}.md`, written from their templates |
| — | the seven copied guides, written into `.claude/policies/` |
| `.claude/.gitignore` | rewritten: `/position/`, `/worktrees/`, and `settings.local.json` |

**`.claude/context.md` is the one that splits.** Its routing table becomes `.claude/contexts/map.md`; everything else — the vocabulary, the boundaries, the constraints — becomes `.claude/contexts/repository.md`. The Domain Contexts under `.claude/contexts/` do not move and do not change. Add a row for `repository.md` to the new map, because the file that is being created is the one nobody remembers to route to.

**The entrypoint loses what now loads from elsewhere.** The precedence ladder and the engineering standards move into `.claude/rules/`, still always-on — the tier changed, not their availability. What is left in `CLAUDE.md` is what this repository is, and pointers. **Preserve anything the user wrote**, exactly as a first-time run does.

**A term that belongs to one workflow stage moves out of the vocabulary** and into that stage's guide — `.claude/policies/context.md` has the rule that decides which. This is the only row that is judgement rather than mechanics, and it is judgement about the repository's own terms, so it is worth showing in the plan term by term rather than as a count.

Then repair the references, as above and for the same reason. These paths are named from `CLAUDE.md`, from the Domain Contexts, from tickets and specs, and from `.claude/tools/` entries — a tool reference that names the old Marker location is as broken as a Source Pointer that names a deleted directory.

**Including inside the files that just moved** — a file that has been carried across looks handled. The vocabulary names the Marker's path, the version-control guide names its neighbour's old home, and the protocol file's own comment says where it was installed. Sweep the destinations as well as the untouched files, or the migration repairs everything except what it touched.

**Frozen records are history, not pointers.** A Decision's reasoning is frozen once committed, and a resolved ticket is a record of what happened. Both will go on naming paths that no longer exist, correctly — the alternative is editing a decision to say something it did not say. Repair live pointers; leave the record alone, and say in the plan that you are.

### Recognising a repository already on it

**By content, not by presence.** `.claude/policies/tracker.md` existing proves nothing: a repository half-way through a previous run has the file and an entrypoint still carrying the rules. Check three things, and report a repository as converted only when all three hold:

- the superseded paths are **gone**, not merely duplicated — a `tracker.md` at both locations is a run that copied instead of moving
- `CLAUDE.md` states no rule that `.claude/rules/` now carries, and `.claude/contexts/map.md` carries routing and nothing else
- every row in the map resolves, and every file under `contexts/` has one

The second of those is worth running even when the moves obviously succeeded: reshaping the entrypoint is the only row with no file to move, so it is the row a run completes without noticing it has not.

A repository that fails any of these is **converted, not re-converted**: finish what is missing and leave what is already right. A run that appends instead of recognising makes the repository worse every time it is maintained.

## The pre-modes protocol file

Two older shapes exist, and recognition is by content in both. A repository converted before the modes shipped has a `.claude/protocol.md` whose routing table carries no mode column and no `.claude/modes/` directory. One release later the modes existed but lived *inside* the router, as `### Mode:` sections of the protocol file — that is the interim shape, whatever else the file looks like.

The conversion brings either to the current layout: `.claude/modes/` is installed from the templates, one file per posture; any `### Mode:` sections found in the protocol file are removed in the same pass, because the directory is now their single home; and the routing table gains the mode column with the template's stage-to-mode assignments. Repository-specific rows — extra guides a row names, stages the repository added — are preserved, because they are the part the template cannot know. A file already on the current shape is current, and a re-run changes nothing.

## A repository configured before orchestration existed

A repository configured by an earlier release has `.claude/policies/` and no `sub-agents.md`, and a router whose table names no stage as dispatching. Recognition is by content and needs both halves, because either alone is an interrupted run rather than an older layout: the policies directory is populated, and `.claude/policies/sub-agents.md` is absent.

The conversion is what the generate step writes anyway — the policy, and the routing rows for the stages that dispatch — so this row exists to *name* the case rather than to add work: a reader auditing an old repository should find the gap described, not infer it from a file that is merely missing.

**The shipped roles are not part of it.** `agents/` belongs to the plugin, not to the configured repository, so a repository on an old release gains the roles by updating the plugin and nothing here installs them.

## Orchestration without its isolation setting

A repository configured before the worktree base ref was written has the sub-agent policy and no `worktree.baseRef`. That is the gap the generate step describes, already live in a repository rather than about to be prevented in one. Recognition is by content and needs both halves: `.claude/policies/sub-agents.md` present, and `.claude/settings.json` either absent, missing the key, or setting it to `"fresh"`.

**This row repairs rather than reports.** The repair is one merged key — small enough that handing it back as a plan item costs more than doing it, and what it prevents is not something the next run would catch. The value goes in as `/configure` writes it; an existing `settings.json` is merged into, never replaced.

A repository with no sub-agent policy is not on this row: it is a repository the current `/configure` has never finished, and the generate step writes both.

## The first axis without the second

A repository configured while orchestration had only one axis carries `.claude/policies/sub-agents.md` describing a child that works a *portion*, and nothing about one that works a whole ticket. Recognition is by content and needs both halves, because a policy that is merely absent is an unfinished run rather than an older layout: the policy is present, and it admits no whole-ticket child — no decline rule for a fan-out the child cannot itself run, and no closed menu of what a child may request.

**This row repairs rather than reports**, and costs nothing extra by doing so: the policy is installed by copy, so the generate step replaces it with the current template entire and there is no repository-specific text in it to preserve. The row exists so that a reader auditing an old repository finds the gap named, rather than inferring it from a file that merely reads shorter than the one they know.

**The build stage is not part of it**, for the reason the shipped roles above are not. What a migration can reach is the contract the children read; the stage that dispatches them arrives with the plugin.

## Knowledge that predates declared fields

A repository configured before Contexts and Decisions declared their own fields has a
hand-written routing table, Domain Contexts carrying a prose `Sources:` line, and a decisions
directory with no index at all. Recognition is by content and needs **both halves**, because
either alone is an unfinished run rather than an older shape: `.claude/decisions/` is populated,
and its files declare no frontmatter fields.

Nothing else reaches this. The generate step passes over every one of those files — they exist,
and under the shape they were written for they are correct — and a repository configured once
does not run generation again on its own. Without this row an existing repository stays on the
old shape indefinitely while the framework ships the new one.

**The existing routing table is the conversion's input, not its casualty.** Its trigger
sentences were written for exactly this purpose: carry each onto the file it describes as that
file's `load-when`, and carry the Sources column onto the same file. Only where no such sentence
exists anywhere — every Decision, since Decisions were never routed — is one being authored.

**That authoring is judgement, and it is the one output nothing can check.** A load condition
that describes what a file is *about* passes every assertion this shape adds and silently
reintroduces what ADR 0002 rejected. So this row goes through the plan **file by file, with the
sentences visible**, never as a count — a human reading them is the only check there is. It is
the same reason the term-placement row above is shown term by term.

Supersession is converted from wherever it is stated today and made symmetric at both ends.
**Prose that discusses supersession without claiming it** — "supersedes one consequence of
`0025`", "supersedes the layout stated in `0006`" — is **reported, never promoted**: reading it
as a claim is a guess about what its author meant, and a partial supersession is not a
supersession. Where a claim is partial, say so in the plan rather than rounding it.

Filenames and numbers do not move. The numbering section of `.claude/policies/decisions.md`
already governs that, and it governs this conversion exactly as it governs a move.

Then generate both indexes from the fields. A repository already declaring fields is **current**:
say so and change nothing.

## Mechanics a configured repository does not get by generation

Three of AEP's later mechanics land in files a repository already has, so the generate step
passes over all three. They are **not the same kind of work**, and a run that treats them alike
will repair the one that should have been reported.

**The stage table is repaired**, and that repair is the audit's — see `SKILL.md`.

**Drift findings are reported, never repaired.** A repository whose `.claude/evidence/drift/`
entries carry no `Consumed:` line has findings whose disposal is unknown. Whether any one of them
was healed is a question about knowledge elsewhere in that repository, and answering it by
inference is precisely the guess the finding format exists to stop. **Leave every unmarked
finding unmarked** — that reads as waiting, which is the safe direction and the behaviour the
repository already has — and list them in the plan so a human knows they are unresolved.

**The Marker needs no conversion, and this row exists to say so** rather than leave a reader
hunting for one. A marker carrying only a commit means the tree is unknown: `.claude/protocol.md`
defines that state and its fallback, and it corrects itself the first time a stage advances the
marker. `/configure` does **not** write a tree fact — stamping one asserts that a drift read
happened and was dealt with, and this stage did neither.

**The shipped roles arrive with the plugin**, for the reason already recorded twice above:
`agents/` belongs to the plugin rather than to the configured repository, so a role gaining a
declared mode reaches a repository by updating the plugin and nothing here installs it.

## The Tenure → AEP rename

The framework was called **Tenure** before it became AEP, and a repository configured under that name carries it in prose: the entrypoint, the protocol file, the policies, and the tool references say Tenure and name `/tenure:` commands. The layout may already be current — the name is a conversion of its own, and it applies on top of whichever layout migration the repository also needs.

The conversion is textual and complete: in every **live** file under `.claude/` and in the entrypoint, `Tenure` becomes `AEP` and `/tenure:` becomes `/aep:`, including possessives and the namespaced command list the entrypoint or help text may carry. Frozen records — Decisions, resolved tickets — keep the old name, under the same rule as old paths: history is not repaired, and a Decision that argued about Tenure argued about Tenure.

Recognition is by content: a live file naming Tenure or a `/tenure:` command is a finding, whatever the layout looks like. A repository with no such reference needs nothing from this section, and the plan says so rather than staying silent.

## Classify, never copy

Existing documentation is **sorted**, not duplicated. Copying is how a repository ends up with the same fact in three places, drifting independently.

| What it is | Where it goes |
| --- | --- |
| implementation explanations — how a thing works | stays in source; nothing is written down |
| repository principles, vocabulary, boundaries | becomes Context |
| historical reasoning — why an approach was chosen | becomes a Decision |
| developer instructions — how to work here | becomes `CLAUDE.md` |
| temporary notes, stale TODOs, superseded plans | discarded, and named in the plan first |

Only Context and Decisions are AEP's to hold. A guide that explains how to use the library is the README's, and moving it into Context loses its audience and fails the compression test. Apply that test — it is in `CLAUDE.md` — to everything before it is written: a migration is the largest opportunity this framework has to accumulate sediment, because all the existing prose looks like it was worth writing once.

## Leave a pointer where something still references the old path

Where a converted file is still referenced from `README.md`, `CONTRIBUTING.md`, a CI job, or a source comment, leave a **pointer at the old path** rather than a broken link:

```markdown
Moved to `.claude/contexts/repository.md`.
```

Two things this is not: a copy — the content lives at the destination and only there — and permanent: it exists because something outside AEP's reach still points at the old location, so name those references in the plan, and where the user updates them, delete the pointer instead of writing one. A converted file that nothing references leaves nothing behind; a stub for every moved file is sediment.

## When the migration is only partly possible

A repository may carry an AI workflow whose knowledge cannot be classified with confidence — undated notes, a `CONTEXT.md` describing a structure that no longer exists, ADRs with no reasoning in them.

**Say so and leave it.** Report what could not be classified and where it still is. Guessing a destination is worse than leaving the file findable, because a wrong classification is invisible afterwards: nothing records that a file arrived by assumption.
