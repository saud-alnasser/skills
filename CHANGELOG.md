# Changelog

## 2.5.0

A monorepo can namespace its contexts by project.

### Added

- **`contexts/<project>/<area>.md`, beside `contexts/<area>.md`.** A monorepo has
  the same area in more than one project — auth in the web app, auth in the API —
  and a flat directory gave them one namespace to share. The project directory is
  where that name goes.

  *Why it needed saying rather than building: nesting already validated, already
  indexed, and already resolved as a wiki link. Nothing said so, so the capability
  was accidental — the template told authors to write `contexts/<area>.md`, the
  specification never mentioned placement, and contexts were walked rather than
  flat-listed only because nobody had passed a flag.*

- **The directory names; `paths:` scopes.** `web/auth` and `api/auth` can both be
  called `auth`, and a nested context still declares `paths:` — nothing derives
  applicability from a directory name. A guard now proves it behaviourally: a
  nested context with no `paths:` must acquire none.

- **One project directory deep, and no more.** `validate.mjs` rejects anything
  deeper, naming the file and both legal forms. It ships in the validator rather
  than the build suite because contexts are authored in the consuming repository,
  where the build suite never runs.

### Changed

- **The bound applies to contexts alone**, deliberately. `rules/` and
  `references/` are repository-wide — a reference is picked up by whoever needs
  the tool, and a rule scopes with `paths:` — so neither has a namespace two
  projects can collide in. A limit keyed by directory would advertise a nesting
  nothing wants.

### Upgrading

Nothing to do unless you have a context nested two or more levels deep, which
nothing ever told you was legal. If you do, move it up to
`contexts/<project>/<area>.md` or flatten it — the upgrade will not touch it,
because `contexts/` is yours.

## 2.4.0

What a turn tells the human stops being invented once per skill.

### Added

- **`policies/reporting` — one shape for every turn.** Four opening slots in a
  fixed order (standing, request, assumptions, stages) and three closing ones
  (state, next, unsettled-with-how-to-settle-it). The unit is **the turn**, not
  the skill entry: one thing the human asked for produces one opening report and
  one closing block, emitted by the outermost skill, so a skill reached from
  inside another is a stage of that run rather than a second preamble.

  *Why this was worth governing: `/implement` mandated a position report,
  `/specify` a stated understanding, `/review` two fixed headings, and eleven
  skills said nothing. Every shape was invented locally, so nothing could be
  found by position, and a routing decision taken on the human's behalf was
  usually invisible.*

- **A slot with nothing in it says so**, rather than being dropped. Silence is
  indistinguishable from a check that never ran, and an omissible slot destroys
  reading by position — which was the whole benefit.

- **The closing block is a lantern, not a map.** The near next step and what is
  unsettled, with how to settle it. A turn that **stops early** carries it too:
  an empty frontier or a surfaced conflict is where it is worth the most.

- **`report: full | short` on every skill**, assigned once when the skill is
  authored by one test — does it write to the repository, dispatch a sub-agent,
  or decide on the human's behalf? Never selected during a run, so the shape is
  known before the turn starts. The two forms differ in the **stage markers**:
  the preamble is paid once per turn and a marker is paid per stage, so that is
  where the only saving worth a second form lives.

### Changed

- **Stage names are read out of each skill's own procedure**, never declared a
  second time. Seventeen numbered steps that carried no bolded lead gained one;
  `handoff`, which had no numbered steps, now carries the two it always had in
  prose, and `tdd`'s stage list is its loop rather than its loop plus its bug
  path. Exempting the two that fitted no shape was rejected — a guard that skips
  what it cannot handle passes by not looking.

- **`/implement`'s position report, `/specify`'s stated understanding and sizing
  floor** now fill slots instead of rendering shapes of their own. Nothing they
  did changed: the position script still runs on every invocation, and *nothing
  to report is still reported* survives verbatim. `/review`'s two headings and
  `/tasks`' graph are untouched — they are output, not a preamble.

- **The standing slot is filled with whatever a skill already verifies**, never
  with a new check. Thirteen skills read no position and none of them started.

### Upgrading

A skill you wrote yourself needs one new field: `report: full`, or
`report: short` if it neither writes, dispatches, nor decides. `validate.mjs`
fails a skill without one, and an upgrade never edits a file you own — so the
release declares a notice rather than changing it for you.

## 2.3.0

An effort's work is findable in the tracker that holds it, and AEP stops
inventing vocabulary a tracker already has.

### Added

- **An external task is attributable to its effort by a query the tracker
  answers natively.** Where tasks live in GitHub, GitLab, Jira, or anything
  else, exactly one fact has to be carried — which effort the task belongs to —
  and it has to be carried where the tracker can answer it, not in prose an agent
  reads issue by issue.

  *Why this was a hole: `policies/execution` computes the frontier from declared
  edges and forbids inferring independence from a guess. A repository whose work
  lives in a tracker had no way to ask which issues belong to an effort, so the
  rule stood with nothing behind it — and the cheapest way to satisfy it was to
  work serially and say nothing.*

- **`skills/tasks/labels`** — the procedure, reached from `/tasks` when the
  answer to *where do tasks live* is a tracker. It resolves one fact against one
  tracker, once, and records the answer so later sessions read it instead of
  working it out again.

- **Declared notices — what a release asks of the reader.** A release can now
  declare what must be *checked* when crossing it, and an upgrade reports exactly
  the notices for the releases actually being crossed. A tree already at the
  release is shown nothing; a dry run previews them; `/update` acts on each or
  reports it as outstanding.

  *Why: `MOVES` covers everything a release does to a tree, and nothing a release
  requires of the reader. That gap is not hypothetical — this very release has
  one. The reference section below is repository-owned, so an upgrade correctly
  refuses to write it, and without a notice every existing installation would get
  the new behaviour and never the section it writes into.*

  Gated by the same predicate as declared moves, so a notice and a move from one
  release cannot disagree about whether that release is being crossed. Relevance
  is two release numbers compared — never judged at runtime.

  **Not the changelog.** `CHANGELOG.md` is not payload, so a repository running
  an upgrade has never received one; shipping the whole history into every
  installation to deliver two lines is a poor trade for a filter that already
  existed. A notice is the narrow, actionable subset, and a release with nothing
  to ask of the reader declares none.

### Changed

- **`aep:` now means the release an artifact's content last changed in** — one
  meaning for both owners, and computed rather than typed. `date:` answers the
  same question by the same mechanism.

  It previously meant two things at once. Protocol-owned artifacts were swept to
  the new release every time, changed or not; repository-owned ones were left
  alone and so already recorded when they last changed. The specification
  described only the first, and nothing declared the split.

  *Why it was worth changing rather than automating: under a sweep the field said
  the same thing on every artifact, so it distinguished nothing — and an artifact
  edited without being restamped was undetectable, because a stale stamp and a
  current one were the same value. Only `protocol.md` is exempt, and it is exempt
  for a reason: it is the tree's release marker, read by the installer to decide
  which moves and notices apply.*

- **`node src/scripts/release.mjs <version>` cuts a release.** Version of record,
  stamps for what actually moved, the baseline in `src/stamps.json`, plugin
  manifest, and adapter — one command, so the steps cannot be performed in part.
  Running it twice changes nothing the second time.

  The baseline is a committed hash per shipped artifact rather than git tags:
  `verify.mjs` is the only thing that catches a broken build here, and making it
  depend on tags being present in whatever checkout runs it puts the suite at the
  mercy of how the repository was cloned.

  `verify.mjs` now compares every shipped artifact against that baseline, so
  **an edit that never got released fails by name** — the defect the old scheme
  could not see at all.

- **Native mechanism before label.** The resolution is a ladder: a first-class
  feature of the tracker, then an existing label that already serves the fact,
  then — only then — a new label, named in the style the tracker's own labels are
  named in. **A label is never created for a fact the tracker already models.**

  On a tracker that models milestones, dependencies and issue state itself, every
  fact lands on the first rung and **no label is created at all.** That is the
  intended outcome, not a degenerate one.

- **`status` and dependency edges are excluded, deliberately.** An issue's own
  state already carries open and resolved, and a second copy disagrees with the
  first as soon as somebody closes an issue from the tracker's interface. An edge
  is not set membership: a `blocked-by-42` marker has to be withdrawn when 42
  closes, and nothing in the tracker knows to do it — so it is wrong exactly when
  it matters.

- **The GitHub and GitLab references, rewritten against primary sources.** Both
  now say what the tracker models natively, which commands reach it, and where
  the gaps are.

  GitHub carries every fact itself — an effort is an issue and its tasks are that
  issue's sub-issues, gates are issue dependencies, state carries a close reason,
  and types are native — so the frontier is *computed*: one query returns the
  effort's open issues with `blockedBy` attached.

  Two gaps are stated rather than smoothed over. There is no `gh milestone`
  command, which is what makes the hierarchy the default and the milestone the
  alternative — creating a parent issue is `gh issue create`, creating a milestone
  is a drop to the REST API. And there is no `--parent` filter on `gh issue
  list`: `parent` comes back in `--json` and is narrowed client-side with `--jq`,
  *after* `gh` has truncated the page. The reference says plainly what that costs
  — a truncated page filters to a short list that reads as a complete answer.

  GitLab has neither. `glab` has no subcommand for issue links at all, and
  `blocks` / `is blocked by` are Premium and Ultimate, so the edge is carried in
  the issue description — named in the reference as a **hand-maintained
  convention rather than state**, because that is what it is. GitLab also has no
  close reason, which makes `obsolete` the one fact on either tracker with no
  native carrier, and the single place a derived label is genuinely the answer.

- **What body text does, and does not do** is now written down on the GitHub
  side. Only the closing keywords in a pull request body drive anything;
  `Blocked by #123` in a body does **nothing at all**, and `- [ ] #123` is a
  checklist item rather than a relationship.

  *Why it earned a table: it fails silently. The sentence reads correctly to
  every human who sees it, the tracker holds nothing, and the frontier query
  returns that task as ready to start.*

### Fixed

- The GitLab reference had been shipping `--description-file`, which is not among
  `glab issue create`'s flags. A seeded command the repository does not have is
  worse than no reference at all, because it will be trusted.

## 2.2.0

Governance splits into two named primitives, and the nine shipped rules become
four policies.

### Added

- **Policies — `.aep/policies/`.** AEP's own governance, protocol-owned,
  installed verbatim, and never edited in a repository. Four ship: `authority`
  (which source wins, and which repository is yours to act on), `engineering`
  (how a claim is made, and what to do on finding you cannot make one),
  `execution` (an effort from accepted spec to landed change, sub-agents
  included), and `artifacts` (whose a file is, where it goes, what shape it
  takes).

  *Why a second directory when `owner:` already said this: `rules/` already held
  two layers — the shipped nine and whatever the repository added — separated
  only by a field inside each file. An agent listing the directory could not tell
  AEP's law from local convention without opening every file. The hierarchy in
  §10 has not changed; it was already `protocol rules → repository rules`. What
  changed is that you can now see it.*

- **Declared moves.** A release states which protocol-owned artifacts it
  relocated, and an upgrade applies them: it removes the old file, repairs links
  that pointed at it inside repository-owned artifacts, and reports every
  removal, repair, and collision. A move is not a retirement — the content still
  exists, and leaving the old file would govern a repository with two copies of
  one text, both of which resolve.

  This is the **only** circumstance in which an upgrade writes into a file the
  repository owns. It is confined to the declared targets, only where the source
  path is now vacant, and only the link target changes.

### Changed

- **Rules are now repository-owned, exclusively.** `rules/` ships nothing and
  arrives holding only the version-control seed. `policies/` admits only
  `owner: protocol` and `rules/` only `owner: repository` — the one place a
  directory constrains ownership, and it does not weaken the rule that ownership
  is read off the declared field: an installer still reads the field before
  overwriting anything, so a misplaced file is **preserved and then reported**,
  never silently corrected.

- **A repository cannot author a policy.** However non-negotiable a local
  constraint is, it is a rule. The moment the directory admits either owner,
  reading it tells an agent nothing.

- **Rigidity is authority, not loading.** A policy outranks every rule and cannot
  be edited, but it is selected by its `use-when` exactly like any other
  conditional artifact. Nothing became always-on.

- **Nine rules became four policies**, grouped by the moment they fire rather
  than by subject. Two of the merges were already visible in the old text:
  `evidence` opened by conceding that *how a claim is made at all* belonged to
  `engineering`, and `ownership` closed by handing the reader to `artifacts`. A
  rule that must point at another rule to be complete is one file split in two.

  The cost, recorded because it was priced rather than missed: merging drops
  `mode:` from all four, since each union covered six or seven of the eight. It
  is honest for `engineering`, whose trigger already fired in modes its `mode:`
  did not list, and least honest for `execution`, whose sub-agent half is
  genuinely narrow.

### Migration

Existing 2.1.x trees upgrade in place — the nine rule files are removed, links
are repaired, and anything the repository owns is untouched. Read the report.

**`policy` means the opposite of what it meant in 1.x.** A 1.x policy was the
repository's, derived per repository; an AEP policy is protocol law, identical
everywhere. So a 1.x `policies/<concern>.md` converts to a **rule**, never to a
policy — converting one the other way would hand the repository's own decisions
to the protocol, and the next upgrade would overwrite them. 1.x detection stays
scoped to the runtime's own directory, so `.aep/policies/` never reads as 1.x.

## 2.1.1

A link that only resolved on the machine that wrote it, and one field that now
answers one question.

### Changed

- **`aep:` is the release an artifact ships in, and every release stamps every
  protocol-owned artifact** — reversing the 2.1.0 decision below, which made the
  field the release that *last changed* the artifact. Both readings cannot hold
  at once, so this supersedes it rather than sitting beside it.

  The comparison an upgrade actually makes is *did this artifact come from the
  release the tree declares* — one question, answered by equality. Per-artifact
  provenance answered a different question and made the first one unanswerable,
  since a legitimately old stamp and a file the installation never received were
  the same value. Provenance is what this changelog and the git history are for.

  `verify.mjs` enforces it as equality rather than a range: a stamp behind the
  release now fails exactly as a stamp ahead of it always did. Confirmed to fire
  before landing.

### Fixed

- **The prototype skill and mode no longer link to `worktrees/`.** It was the one
  link in the distribution pointing at a gitignored, per-clone directory, so it
  resolved wherever an install had created the empty directory and resolved to
  nothing in every fresh clone — passing locally and failing in CI. The path is
  stated as text; there was nothing to link to, and creating something to satisfy
  a link is what a dangling link must never cause.

## 2.1.0

A repository is met by a reference for every tool it actually runs.

### Added

- **A wide reference catalogue.** Fifty-three tools join the ten 2.0.0 shipped,
  each gated on that tool's own evidence — the JavaScript and TypeScript
  toolchain, test runners, bundlers, monorepo orchestration, application
  frameworks, desktop and mobile shells, the Rust, Go, Python, Ruby, PHP, JVM,
  .NET and Nix toolchains, database and schema tooling, containers,
  infrastructure and deployment targets, release automation, task runners, and
  git hooks.

  Ten references left most repositories with a nearly empty `references/`, which
  is where an agent starts guessing invocations — the failure references exist to
  prevent. Breadth is safe because the detector decides: a repository receives a
  starting point only for what it demonstrably runs, and each still opens by
  saying it is a draft.

  Each leads with the hazard that tool actually presents rather than its feature
  list — a cached task that ran nothing, a `--remote` flag one word from real
  data, a generated migration that drops a column, a `--fix` that rewrites files
  nobody reviewed.

### Changed

- **The seed manifest takes a `reference` helper**, so a seed is one line and
  the catalogue reads as a catalogue.
- **`aep:` is enforced as the release that last changed an artifact**, rather
  than as the current one. Every payload artifact and seed must declare a real
  release no newer than the one being built; only what a release touches is
  restamped. A blanket stamp would make every artifact look changed on every
  release, which destroys the comparison an upgrade makes.
- **`protocol.md` is the exception, and is now specified as one.** Every release
  stamps it, because it is what an installed tree declares its release *as* —
  the index reads the version from there and `/update` compares it. The suite
  asserts both halves.
- **`/update`'s field mapping no longer names a literal release.** A migration
  stamps converted artifacts with the release it just installed, read from the
  `protocol.md` it wrote.

### Fixed

- **Three gaps in the verification suite**, each confirmed to fire before
  landing: a seed file the manifest declares nowhere — shipped, installed
  nowhere, and invisible because the tree looks complete; a detector whose
  `paths` are empty, which reads as gated and behaves as retired; and any
  reference installing into a repository that shows no evidence of its tool. The
  last replaces a hand-written check naming two references, which would not have
  scaled past them.

## 2.0.0

A rewrite of the framework. AEP 1.x was a Claude Code skill framework rooted in
`.claude/`; 2.0 is an agent-agnostic filesystem protocol rooted in `.aep/`. The
framework is replaced; a repository's own knowledge is converted across.

**No 1.x file upgrades in place, and this is deliberate.** The two architectures
disagree about where state lives, what governs, and how knowledge is selected, so
converting 1.x's framework files would have carried its shape into a design that
exists because that shape was wrong.

What does move is everything 2.0 has a representation for. `/update` recognises a
1.x layout by content, installs 2.0 fresh, and **converts**: contexts, tool
guides, specs, tickets and their states, evidence, repository-authored rules —
and the repository content 1.x kept *inside* framework-owned files, which is the
part a migration loses most easily. A file is dropped only where this release
ships the thing it was, never for having declared `owner: framework`.

Every derivable field is derived, including `date` from the file's own history;
`use-when` is proposed and flagged, because it is the one field nothing can
compute. Nothing is deleted, every collision stops, and the result passes
`validate.mjs` with no exemption. `skills/update/migration.md` has the mapping.

### Added

- **`.aep/` as the single canonical location.** Every runtime — Claude Code,
  Codex, Cursor, or another — reaches the same files through an adapter. A
  repository never carries one AEP state per agent.
- **Applicability metadata on every artifact.** `use-when`, `paths`, and `mode`
  decide what loads, so knowledge is selected by relevance rather than by stage.
- **A declared ownership boundary.** `owner: protocol` installs verbatim and is
  replaced by upgrades; `owner: repository` is preserved. Ownership is read off
  the declared field, never inferred from a path.
- **Seeds** — repository-owned starting points installed once, only where their
  evidence is detected: a version-control rule, a repository context, an
  entrypoint, and references for git, GitHub, GitLab, Graphite, pnpm, npm, yarn,
  Bun, Docker, and Make.
- **Templates** for every artifact kind, so a new rule, reference, context,
  spec, ticket, or role starts from the shape it must hold.
- **Skill notes** — depth at `skills/<skill>/<note>.md`, reached by link from the
  skill that owns it and paid for only by the run that takes that branch. The
  skill file stays what is true on every invocation; UI and logic prototyping,
  test and mocking judgement, the fallback smell vocabulary, module depth and
  designing twice, bug diagnosis, brief writing, conflict resolution, declining a
  request, the survey report, and the 1.x migration all live there.
- **A derived index**, regenerable byte-identically, gaining a tickets section
  exactly when local tickets exist.
- **A verification suite** asserting the shipped surfaces against `specs.md`,
  including a fixture install that proves the produced tree validates — and a
  seeded failure proving the harness can still fail.

### Changed

- **One governance layer.** Policies are gone; rules are the only one, each
  loading on its own trigger. What holds on every turn lives in the bootstrap
  instead, so no norm has two homes.
- **One spec file per effort.** `spec.md` evolves from WHAT/WHY to WHAT/WHY/HOW.
- **Scripts are JavaScript**, dependency-free ESM named `.mjs` so a consuming
  repository's `package.json` cannot change how they parse. `verify.ps1` is
  retired, and verification now covers the shipped surfaces only.
- **Everything that ships lives under `src/`.**

### Removed

- `.claude/` as canonical state — demoted to an adapter.
- Policies, the decisions database, `tools/`, the stage→dependency table, the
  boot-tier budget, discussions as an artifact kind, mandatory local tickets, and
  `plan.md`. `specs.md` §33 lists each with what replaced it.
- **Sub-agent fan-out.** A task is never split across children; independence is
  read off declared edges, never inferred. A task too large for one child is too
  large, and returns to `/tasks`.
- The third-party `NOTICE`. 2.0 vendors no upstream text, so no licence
  condition attaches to it — see `specs.md` §34, which also states what happens
  the moment that stops being true.
