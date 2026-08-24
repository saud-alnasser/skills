# Changelog

## 3.0.0

Ownership stops being something an artifact claims about itself, frontmatter
shrinks to what decides whether to load a file, and `modes/` folds into the
skills that entered it.

### Changed

- **Ownership is a lookup, not a declaration.** `scripts/contract.mjs` carries
  the directory table and a generated manifest of the exact paths a release
  ships. The installer consults it to decide what it may write and what it must
  preserve, and the validator uses it to name a file standing in a protocol
  directory that this release does not ship. Nothing reads `owner:` any more,
  and the case the field could never catch, a file that simply omits it, is now
  the same case as any other.

- **Frontmatter is `use-when`, and `paths` where applicability follows the
  repository.** Seven fields are gone: `aep`, `date`, `kind`, `mode`, `report`,
  `owner`, and `part-of`. `kind` restated the directory, `date` was a freshness
  claim nothing checked, `report` chose between two shapes the reporting policy
  now fixes at one, `part-of` restated the effort directory a ticket is filed
  under, and the release is named once, in the bootstrap's `version:`, instead of
  on every shipped file.

  A tree you own is not edited by the upgrade, so your own rules and contexts
  keep whatever they carry. Validation rejects a retired field only on a path
  the protocol ships.

- **`use-when` is checked rather than trusted.** Four mechanical checks, since
  discovery now rests on this one field: it states an occasion rather than a
  topic, it is not a restatement of the heading, it is not the file or directory
  name, and it stays inside a word bound measured from the shipped corpus.

- **`modes/` is gone.** A mode stated a posture, its mindset and what that
  mindset gives up, and every one of those now sits inside the skill that used
  to enter it, read at the moment it applies rather than fetched. Delete
  `.aep/modes/`: the validator fails a tree that still has it. If you wrote a
  mode of your own, its content belongs in your own skill or rule.

### Added

- **`scripts/frontier.mjs`**, shipped and installed. It reads an effort's
  tickets and prints what is ready, what is blocked and on what, and what is
  parked. Exit 0 while work remains, 1 when nothing is unresolved, 2 when the
  graph cannot be read, so an unreadable effort never looks like a finished one.

- **`scripts/manifest.mjs`**, build-only. It regenerates the shipped-path
  manifest from the payload, and the suite fails when the committed one is
  stale. A stale manifest fails open: a new file would be treated as the
  repository's and never installed.

- **Two skills are gone, and one note moved.** `/commit` is no longer a command:
  landing a task is part of finishing it, so the mechanics run inline at the end
  of `/implement`, and the two judgements `/commit` made about a whole effort,
  whether the effort is implemented and whether the change falsified a context or
  a reference, are made once the effort has no unresolved task left.
  `skills/tasks/labels.md` is gone with its ladder and its approval gate; what
  replaces it asks which of your labels describe an effort rather than which
  label carries a grouping fact. `skills/commit/conflicts.md` is now
  `skills/implement/conflicts.md`, beside the skill that reads it.

- **One invocation runs the effort, not the wave.** `/implement` reads the
  frontier, builds every task on it, and reads it again, until nothing is
  unresolved. It stops on exactly three conditions and there is no fourth: a task
  that cannot be built as specified, a criterion the plan cannot satisfy, and a
  change that would widen the effort's scope. Everything else it decides and
  records.

- **An effort is one issue and one pull request.** The tracker carries the effort,
  not the tasks: tasks are files under `efforts/<effort>/tickets/` in the
  repository, and the pull request body is the run's durable memory, rewritten as
  the run proceeds so that a session that dies is resumed from it.

- **`plan.md` is back.** `spec.md` holds what is changing and why, `plan.md` holds
  how. 2.0 folded them into one file, and the fold made every reader of a change
  pay for its design. An effort whose approach is obvious still needs no plan.

- **A status is not written without the evidence it claims.** Two gates, one per
  level. The run that closes an effort stamps `spec.md` to `status: implemented`
  before it readies the pull request, which is the answer it just gave recorded
  in the file that asked for it; `/tasks`, `/prune`, and the validator all read
  that value and until now nothing set it. And a task cannot be `resolved` while
  one of its acceptance criteria is unticked, because the status is the claim
  that the work is done and the ticks are the evidence for it. Validation fails
  both by name.

  A criterion that cannot be met parks the task unresolved or marks it
  `obsolete`; ticking it is not one of the ways out. Efforts you have already
  landed are exempt from both checks: a merged effort is the record of what was
  reviewed, and this release does not rewrite it.

### Upgrading

- **Two mechanisms classify a tree, and the older one has a stated end.** `/update`
  reads the layout before the version, because a version field is a claim and the
  files are a fact. A tree carrying `owner:` on its artifacts was written under
  the contract where that field decided ownership, and is classified by it; a tree
  without one is classified by the manifest this release ships. The `owner:`
  branch goes when no repository the maintainer knows of still carries that
  layout, which is written in `skills/update.md` rather than left to judgement.

- **The upgrade names what it will not convert, and converts nothing on its own.**
  An artifact still carrying a retired field, and an effort still in flight whose
  `spec.md` holds a `# Architecture` section, are both reported and left. Dropping
  a field decides its content is really answered elsewhere, and splitting a spec
  decides what is WHAT and what is HOW: those are judgements, and a script that
  made them silently would have edited a file you own to do it. `/update` makes
  them with you.

- **An effort that has already landed is left alone.** Its spec is not split, and
  its issues and pull request are not reshaped. They are the record of what was
  built and reviewed, and rewriting them to match a layout the work was never done
  under loses the record and gains nothing.

## 2.7.0

What an agent writes for a human becomes governance, and an orchestrator owes one
account of the work its children did in parallel.

### Added

- **`policies/reporting` governs everything a human reads**, not only the turn
  report. Which texts it covers is decided by a test rather than a list: a human
  reads it, it is governed; a protocol agent reads it, it is exempt, and exempt
  means written for that reader instead, never written carelessly.

  Governed: session output, commit messages, pull request titles and bodies,
  comments and docstrings in source, what a script prints to a person, and a
  repository's own documentation. Exempt: prose inside `.aep/` artifacts, a brief
  written for a sub-agent, data a script writes for another agent to read, and
  normative protocol text wherever it lives, including a repository root.

  Four prohibitions sit in the policy rather than the catalogue, because a script
  can check them: no em dashes, no curly quotes, no decorative emoji, no
  title-case headings. The first of them rules out its own substitutes, since
  parentheses and an en dash trade one tell for another.

  *Why a test and not only a list: a list settles the cases somebody thought of,
  and every case it missed gets decided by whoever hits it first, differently each
  time.*

- **`skills/prose`, the eighteenth skill**, carries the craft the policy does not:
  the patterns that mark writing as machine-made, how to spot each one, and what
  to do about it. It is a sub-skill, reached from whichever skill is about to emit
  text a human will read.

  The split is deliberate. A skill carrying the prohibitions would be governance
  under another name, which the protocol forbids, and a policy carrying the whole
  catalogue would be thirty rules where four are checkable.

- **`policies/execution` states what the orchestrator owns once its last child
  returns.** Reconciling a claim against a diff is an honesty check and not the
  same as making the result coherent. Three things a child structurally could not
  do are the orchestrator's: the seams where children's diffs meet, every decision
  a child recorded and stopped on, and one account of the work written as though
  one agent had done it in sequence rather than each child's summary concatenated.

  **The seam pass is bounded at the surfaces the diffs share.** Anything else the
  orchestrator notices inside one child's work is raised, not taken, and returns
  to the frontier as a task. A bound read off `spec.md` cannot tell reconciling a
  seam from rebuilding a task a child already delivered, and the orchestrator is
  the one agent with no reviewer above it.

  The account describes the work rather than the workers, and sub-agent structure
  surfaces where it changed the outcome: a child that failed, a child that stopped
  on a decision the human must make, a task that returned to the frontier. That is
  not permission to suppress a failure. A fan-out that lost a task changed the
  outcome by definition.

  **A child writes its question plainly and the orchestrator presents it.** Wording
  may be reshaped and substance never is: what is being asked, and which options
  are offered, survive unchanged, and attribution names the source rather than the
  author of the words. This runs the opposite way to the answer, which still
  travels verbatim, because an answer carries the human's authority and a question
  does not.

- **Guards for all of it.** Thirty-four assertions, each broken once and watched
  to fail by name: every clause of the widened policy, each of the three
  obligations separately, both halves of the account clause, the substance clause
  without which the presentation clause licenses a rewritten question, and a scan
  for the prohibited character over every shipped script and this repository's own
  documentation.

### Changed

- **This repository's own governed text lost its em dashes.** All 177 across the
  ten shipped scripts, 16 in `README.md`, and 67 in `CHANGELOG.md`. Comments and
  the strings a person reads were rewritten rather than deleted: where a dash was
  carrying a clause, the sentence ends or takes a comma.

  `specs.md` and `AGENTS.md` keep theirs, and the suite asserts they are not in
  the swept list and that they still carry the character. Their reader is the
  agent building the protocol, which is exactly what the test exempts, and it is
  where the vocabulary is defined that a catalogue of tells would otherwise flag.

  The places that still have to produce or match the character write it as a
  Unicode escape, so the guard is a flat scan with no whitelist. `index.mjs`'s
  empty-cell placeholder became one named constant, and the index it renders is
  byte-identical.

- **`specs.md` 16.2 is now *What the human reads*.** It opens with the reader
  test, the worked lists, and the exemption, then keeps everything it already
  fixed about slots, forms, and stage names. The skill set is eighteen and the
  sub-skills are three, in 16, 16.1, 29, and the conformance list.

- **The bootstrap says who a text is written for.** The `Every turn reports`
  invariant carries one clause pointing at the policy, and the governance table's
  trigger widens to agree with it. `skills/implement`'s close-out routes to the
  reconciliation section, so the obligation is reachable from the skill that
  dispatches rather than only from the policy that states it.

### Fixed

- **`skills/help` did not know about the eighteenth skill.** A skill could ship,
  be wrapped by every adapter, be named in the specification, and still be missing
  from the one artifact whose job is answering what to reach for.

  Nothing in the suite asserted anything about `help.md` at all. Something does
  now, derived from the shipped skill set rather than from a second hand-written
  list, which would be the same failure one level up with nothing catching it
  either.

## 2.6.0

AEP reaches OpenCode, and a repository driven through T3 Code knows why it
behaves the way it does.

### Added

- **An OpenCode adapter.** `--adapters opencode` writes `.opencode/skills/` and
  `.opencode/agents/`. OpenCode already found AEP's skills through its
  Claude-compatibility scan, but only while that flag was left on, and **skills
  only**. Its agents load from a config directory or from nowhere, so the four
  AEP agents reached it by no path that existed.

  Names carry an `aep-` prefix. OpenCode registers `init` and `review` as
  built-in commands before skills, and a skill whose name is already taken never
  becomes a command, so an unprefixed `review` would have been silently
  unreachable, which reads exactly like a skill nobody invoked.

- **A runtime-neutral `.agents` adapter.** `--adapters agents` writes
  `.agents/skills/`, the one location read by more than one runtime: OpenCode
  scans it, and T3 Code's picker scans it for whichever provider it is driving.

  **It is an alternative to `opencode`, not a companion.** OpenCode reads both
  locations, so asking for both loads every skill twice under one name and the
  loader keeps whichever finished first. The installer warns and writes both,
  because a repository driven through a harness with another provider can
  genuinely want it; the install skill offers one.

- **Seeds for OpenCode and T3 Code**, detected by `opencode.json` /
  `opencode.jsonc` and by `t3.json`, never by `.opencode/`, which AEP's own
  adapter creates and which would make an installation the evidence that the
  repository uses OpenCode.

  The T3 Code reference records what T3 Code is: a control surface over provider
  CLIs, defining no format of its own, so what a session gets is whatever the
  provider loads.

### Changed

- **`--adapters` takes a list.** It compared its whole value against the string
  `claude`, so every other name was silently a no-op. A user asking for a
  runtime saw a successful install and got nothing. Names now resolve before the
  first write, so a typo in the third cannot leave a half-installed tree, and
  each adapter is named in the report with its wrapper count instead of
  disappearing into a total.

- **A runtime is a row in a table rather than a function of its own.** One
  renderer walks the payload for every target. The alternative, a render
  function per runtime, would have stated the pointer contract once per
  runtime, and a stale adapter is mechanically detectable while three wordings
  of one rule drifting apart is not.

  §29.1 of the specification defines targets and shapes, including that a
  rendered tree is committed exactly where that directory is itself what a user
  registers, and that a distribution shape's reach is derived from where the
  wrapper sits rather than written out.

### Fixed

- **Every agent wrapper sent its sub-agent to a file that does not exist.** They
  said *"Then read `.aep/rules/sub-agents.md`, which binds you"*. That artifact
  moved into `policies/execution` in 2.2.0, and the installer has declared the move
  ever since. The wrappers went on naming the old path for four releases,
  so every dispatched agent was told to read nothing.

  A role definition already states what binds it, so the wrapper now names the
  role definition and nothing else.

  *Why it survived four releases: nothing compared wrapper text against an
  installed tree. The guard that now does is the point of the fix: every
  `.aep/` path a wrapper names, in prose and in frontmatter alike, must exist in
  an install.*

### Upgrading

Nothing to do. No artifact moves, no installed tree changes shape, and a
repository that never asks for a new adapter is untouched.

To pick one up: `/aep:update`, and ask for the adapter your runtime reads.
Regenerate a Claude adapter you already have, because the agent wrappers changed.

## 2.5.1

### Fixed

- **`policies/artifacts` said the opposite of what a release does.** It claimed
  every release stamps every protocol-owned artifact, and that an upgrade
  compares that field to decide whether a file came from the release. Both were
  wrong: `release.mjs` stamps only what changed, nothing anywhere reads an
  individual artifact's `aep:` for provenance, and `/update` detects a locally
  edited file by comparing content against the release it declares.

  The policy now says what is true. `aep:` is the release an artifact's content
  last changed in, `protocol.md` alone is stamped every release because the
  tree's version is read from it, and provenance is established by comparing
  content. §7 of the specification carried the same error and is corrected with
  it; §6 and §8 already said this.

  *Why it mattered: acting on the policy meant sweeping every artifact to the
  current release, which destroys the only thing the field says per artifact and
  makes the suite's stale-stamp guard true by construction.*

- **A section of the verification suite was aborting silently.** A helper was
  declared below a section that used it, so `policies` threw before its
  assertions ran, and an aborted section skips everything after the throw. It
  was hiding **14** checks. The helper moved up with the others, and the comment
  there now says why that position is not a style preference.

## 2.5.0

A monorepo can namespace its contexts by project.

### Added

- **`contexts/<project>/<area>.md`, beside `contexts/<area>.md`.** A monorepo has
  the same area in more than one project, auth in the web app and auth in the API,
  and a flat directory gave them one namespace to share. The project directory is
  where that name goes.

  *Why it needed saying rather than building: nesting already validated, already
  indexed, and already resolved as a wiki link. Nothing said so, so the capability
  was accidental. The template told authors to write `contexts/<area>.md`, the
  specification never mentioned placement, and contexts were walked rather than
  flat-listed only because nobody had passed a flag.*

- **The directory names; `paths:` scopes.** `web/auth` and `api/auth` can both be
  called `auth`, and a nested context still declares `paths:`, and nothing derives
  applicability from a directory name. A guard now proves it behaviourally: a
  nested context with no `paths:` must acquire none.

- **One project directory deep, and no more.** `validate.mjs` rejects anything
  deeper, naming the file and both legal forms. It ships in the validator rather
  than the build suite because contexts are authored in the consuming repository,
  where the build suite never runs.

### Changed

- **The bound applies to contexts alone**, deliberately. `rules/` and
  `references/` are repository-wide. A reference is picked up by whoever needs
  the tool, and a rule scopes with `paths:`, so neither has a namespace two
  projects can collide in. A limit keyed by directory would advertise a nesting
  nothing wants.

### Upgrading

Nothing to do unless you have a context nested two or more levels deep, which
nothing ever told you was legal. If you do, move it up to
`contexts/<project>/<area>.md` or flatten it. The upgrade will not touch it,
because `contexts/` is yours.

## 2.4.0

What a turn tells the human stops being invented once per skill.

### Added

- **`policies/reporting`, one shape for every turn.** Four opening slots in a
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
  reading by position, which was the whole benefit.

- **The closing block is a lantern, not a map.** The near next step and what is
  unsettled, with how to settle it. A turn that **stops early** carries it too:
  an empty frontier or a surfaced conflict is where it is worth the most.

- **`report: full | short` on every skill**, assigned once when the skill is
  authored by one test: does it write to the repository, dispatch a sub-agent,
  or decide on the human's behalf? Never selected during a run, so the shape is
  known before the turn starts. The two forms differ in the **stage markers**:
  the preamble is paid once per turn and a marker is paid per stage, so that is
  where the only saving worth a second form lives.

### Changed

- **Stage names are read out of each skill's own procedure**, never declared a
  second time. Seventeen numbered steps that carried no bolded lead gained one;
  `handoff`, which had no numbered steps, now carries the two it always had in
  prose, and `tdd`'s stage list is its loop rather than its loop plus its bug
  path. Exempting the two that fitted no shape was rejected. A guard that skips
  what it cannot handle passes by not looking.

- **`/implement`'s position report, `/specify`'s stated understanding and sizing
  floor** now fill slots instead of rendering shapes of their own. Nothing they
  did changed: the position script still runs on every invocation, and *nothing
  to report is still reported* survives verbatim. `/review`'s two headings and
  `/tasks`' graph are untouched, since they are output rather than a preamble.

- **The standing slot is filled with whatever a skill already verifies**, never
  with a new check. Thirteen skills read no position and none of them started.

### Upgrading

A skill you wrote yourself needs one new field: `report: full`, or
`report: short` if it neither writes, dispatches, nor decides. `validate.mjs`
fails a skill without one, and an upgrade never edits a file you own, so the
release declares a notice rather than changing it for you.

## 2.3.0

An effort's work is findable in the tracker that holds it, and AEP stops
inventing vocabulary a tracker already has.

### Added

- **An external task is attributable to its effort by a query the tracker
  answers natively.** Where tasks live in GitHub, GitLab, Jira, or anything
  else, exactly one fact has to be carried, which effort the task belongs to,
  and it has to be carried where the tracker can answer it, not in prose an agent
  reads issue by issue.

  *Why this was a hole: `policies/execution` computes the frontier from declared
  edges and forbids inferring independence from a guess. A repository whose work
  lives in a tracker had no way to ask which issues belong to an effort, so the
  rule stood with nothing behind it, and the cheapest way to satisfy it was to
  work serially and say nothing.*

- **`skills/tasks/labels`**, the procedure, reached from `/tasks` when the
  answer to *where do tasks live* is a tracker. It resolves one fact against one
  tracker, once, and records the answer so later sessions read it instead of
  working it out again.

- **Declared notices: what a release asks of the reader.** A release can now
  declare what must be *checked* when crossing it, and an upgrade reports exactly
  the notices for the releases actually being crossed. A tree already at the
  release is shown nothing; a dry run previews them; `/update` acts on each or
  reports it as outstanding.

  *Why: `MOVES` covers everything a release does to a tree, and nothing a release
  requires of the reader. That gap is not hypothetical. This very release has
  one. The reference section below is repository-owned, so an upgrade correctly
  refuses to write it, and without a notice every existing installation would get
  the new behaviour and never the section it writes into.*

  Gated by the same predicate as declared moves, so a notice and a move from one
  release cannot disagree about whether that release is being crossed. Relevance
  is two release numbers compared, never judged at runtime.

  **Not the changelog.** `CHANGELOG.md` is not payload, so a repository running
  an upgrade has never received one; shipping the whole history into every
  installation to deliver two lines is a poor trade for a filter that already
  existed. A notice is the narrow, actionable subset, and a release with nothing
  to ask of the reader declares none.

### Changed

- **`aep:` now means the release an artifact's content last changed in**, one
  meaning for both owners, and computed rather than typed. `date:` answers the
  same question by the same mechanism.

  It previously meant two things at once. Protocol-owned artifacts were swept to
  the new release every time, changed or not; repository-owned ones were left
  alone and so already recorded when they last changed. The specification
  described only the first, and nothing declared the split.

  *Why it was worth changing rather than automating: under a sweep the field said
  the same thing on every artifact, so it distinguished nothing, and an artifact
  edited without being restamped was undetectable, because a stale stamp and a
  current one were the same value. Only `protocol.md` is exempt, and it is exempt
  for a reason: it is the tree's release marker, read by the installer to decide
  which moves and notices apply.*

- **`node src/scripts/release.mjs <version>` cuts a release.** Version of record,
  stamps for what actually moved, the baseline in `src/stamps.json`, plugin
  manifest, and adapter, one command, so the steps cannot be performed in part.
  Running it twice changes nothing the second time.

  The baseline is a committed hash per shipped artifact rather than git tags:
  `verify.mjs` is the only thing that catches a broken build here, and making it
  depend on tags being present in whatever checkout runs it puts the suite at the
  mercy of how the repository was cloned.

  `verify.mjs` now compares every shipped artifact against that baseline, so
  **an edit that never got released fails by name**, the defect the old scheme
  could not see at all.

- **Native mechanism before label.** The resolution is a ladder: a first-class
  feature of the tracker, then an existing label that already serves the fact,
  then, only then, a new label, named in the style the tracker's own labels are
  named in. **A label is never created for a fact the tracker already models.**

  On a tracker that models milestones, dependencies and issue state itself, every
  fact lands on the first rung and **no label is created at all.** That is the
  intended outcome, not a degenerate one.

- **`status` and dependency edges are excluded, deliberately.** An issue's own
  state already carries open and resolved, and a second copy disagrees with the
  first as soon as somebody closes an issue from the tracker's interface. An edge
  is not set membership: a `blocked-by-42` marker has to be withdrawn when 42
  closes, and nothing in the tracker knows to do it, so it is wrong exactly when
  it matters.

- **The GitHub and GitLab references, rewritten against primary sources.** Both
  now say what the tracker models natively, which commands reach it, and where
  the gaps are.

  GitHub carries every fact itself. An effort is an issue and its tasks are that
  issue's sub-issues, gates are issue dependencies, state carries a close reason,
  and types are native, so the frontier is *computed*: one query returns the
  effort's open issues with `blockedBy` attached.

  Two gaps are stated rather than smoothed over. There is no `gh milestone`
  command, which is what makes the hierarchy the default and the milestone the
  alternative: creating a parent issue is `gh issue create`, creating a milestone
  is a drop to the REST API. And there is no `--parent` filter on `gh issue
  list`: `parent` comes back in `--json` and is narrowed client-side with `--jq`,
  *after* `gh` has truncated the page. The reference says plainly what that costs:
  a truncated page filters to a short list that reads as a complete answer.

  GitLab has neither. `glab` has no subcommand for issue links at all, and
  `blocks` / `is blocked by` are Premium and Ultimate, so the edge is carried in
  the issue description, named in the reference as a **hand-maintained
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

- **Policies, at `.aep/policies/`.** AEP's own governance, protocol-owned,
  installed verbatim, and never edited in a repository. Four ship: `authority`
  (which source wins, and which repository is yours to act on), `engineering`
  (how a claim is made, and what to do on finding you cannot make one),
  `execution` (an effort from accepted spec to landed change, sub-agents
  included), and `artifacts` (whose a file is, where it goes, what shape it
  takes).

  *Why a second directory when `owner:` already said this: `rules/` already held
  two layers, the shipped nine and whatever the repository added, separated
  only by a field inside each file. An agent listing the directory could not tell
  AEP's law from local convention without opening every file. The hierarchy in
  §10 has not changed; it was already `protocol rules → repository rules`. What
  changed is that you can now see it.*

- **Declared moves.** A release states which protocol-owned artifacts it
  relocated, and an upgrade applies them: it removes the old file, repairs links
  that pointed at it inside repository-owned artifacts, and reports every
  removal, repair, and collision. A move is not a retirement. The content still
  exists, and leaving the old file would govern a repository with two copies of
  one text, both of which resolve.

  This is the **only** circumstance in which an upgrade writes into a file the
  repository owns. It is confined to the declared targets, only where the source
  path is now vacant, and only the link target changes.

### Changed

- **Rules are now repository-owned, exclusively.** `rules/` ships nothing and
  arrives holding only the version-control seed. `policies/` admits only
  `owner: protocol` and `rules/` only `owner: repository`, the one place a
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

Existing 2.1.x trees upgrade in place. The nine rule files are removed, links
are repaired, and anything the repository owns is untouched. Read the report.

**`policy` means the opposite of what it meant in 1.x.** A 1.x policy was the
repository's, derived per repository; an AEP policy is protocol law, identical
everywhere. So a 1.x `policies/<concern>.md` converts to a **rule**, never to a
policy, because converting one the other way would hand the repository's own decisions
to the protocol, and the next upgrade would overwrite them. 1.x detection stays
scoped to the runtime's own directory, so `.aep/policies/` never reads as 1.x.

## 2.1.1

A link that only resolved on the machine that wrote it, and one field that now
answers one question.

### Changed

- **`aep:` is the release an artifact ships in, and every release stamps every
  protocol-owned artifact**, reversing the 2.1.0 decision below, which made the
  field the release that *last changed* the artifact. Both readings cannot hold
  at once, so this supersedes it rather than sitting beside it.

  The comparison an upgrade actually makes is *did this artifact come from the
  release the tree declares*, one question, answered by equality. Per-artifact
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
  nothing in every fresh clone, passing locally and failing in CI. The path is
  stated as text; there was nothing to link to, and creating something to satisfy
  a link is what a dangling link must never cause.

## 2.1.0

A repository is met by a reference for every tool it actually runs.

### Added

- **A wide reference catalogue.** Fifty-three tools join the ten 2.0.0 shipped,
  each gated on that tool's own evidence: the JavaScript and TypeScript
  toolchain, test runners, bundlers, monorepo orchestration, application
  frameworks, desktop and mobile shells, the Rust, Go, Python, Ruby, PHP, JVM,
  .NET and Nix toolchains, database and schema tooling, containers,
  infrastructure and deployment targets, release automation, task runners, and
  git hooks.

  Ten references left most repositories with a nearly empty `references/`, which
  is where an agent starts guessing invocations, the failure references exist to
  prevent. Breadth is safe because the detector decides: a repository receives a
  starting point only for what it demonstrably runs, and each still opens by
  saying it is a draft.

  Each leads with the hazard that tool actually presents rather than its feature
  list: a cached task that ran nothing, a `--remote` flag one word from real
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
  stamps it, because it is what an installed tree declares its release *as*. The
  index reads the version from there and `/update` compares it. The suite
  asserts both halves.
- **`/update`'s field mapping no longer names a literal release.** A migration
  stamps converted artifacts with the release it just installed, read from the
  `protocol.md` it wrote.

### Fixed

- **Three gaps in the verification suite**, each confirmed to fire before
  landing: a seed file the manifest declares nowhere, shipped and installed
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
guides, specs, tickets and their states, evidence, repository-authored rules,
and the repository content 1.x kept *inside* framework-owned files, which is the
part a migration loses most easily. A file is dropped only where this release
ships the thing it was, never for having declared `owner: framework`.

Every derivable field is derived, including `date` from the file's own history;
`use-when` is proposed and flagged, because it is the one field nothing can
compute. Nothing is deleted, every collision stops, and the result passes
`validate.mjs` with no exemption. `skills/update/migration.md` has the mapping.

### Added

- **`.aep/` as the single canonical location.** Every runtime, whether Claude Code,
  Codex, Cursor, or another, reaches the same files through an adapter. A
  repository never carries one AEP state per agent.
- **Applicability metadata on every artifact.** `use-when`, `paths`, and `mode`
  decide what loads, so knowledge is selected by relevance rather than by stage.
- **A declared ownership boundary.** `owner: protocol` installs verbatim and is
  replaced by upgrades; `owner: repository` is preserved. Ownership is read off
  the declared field, never inferred from a path.
- **Seeds**, repository-owned starting points installed once, only where their
  evidence is detected: a version-control rule, a repository context, an
  entrypoint, and references for git, GitHub, GitLab, Graphite, pnpm, npm, yarn,
  Bun, Docker, and Make.
- **Templates** for every artifact kind, so a new rule, reference, context,
  spec, ticket, or role starts from the shape it must hold.
- **Skill notes**, depth at `skills/<skill>/<note>.md`, reached by link from the
  skill that owns it and paid for only by the run that takes that branch. The
  skill file stays what is true on every invocation; UI and logic prototyping,
  test and mocking judgement, the fallback smell vocabulary, module depth and
  designing twice, bug diagnosis, brief writing, conflict resolution, declining a
  request, the survey report, and the 1.x migration all live there.
- **A derived index**, regenerable byte-identically, gaining a tickets section
  exactly when local tickets exist.
- **A verification suite** asserting the shipped surfaces against `specs.md`,
  including a fixture install that proves the produced tree validates, and a
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

- `.claude/` as canonical state, demoted to an adapter.
- Policies, the decisions database, `tools/`, the stage→dependency table, the
  boot-tier budget, discussions as an artifact kind, mandatory local tickets, and
  `plan.md`. `specs.md` §33 lists each with what replaced it.
- **Sub-agent fan-out.** A task is never split across children; independence is
  read off declared edges, never inferred. A task too large for one child is too
  large, and returns to `/tasks`.
- The third-party `NOTICE`. 2.0 vendors no upstream text, so no licence
  condition attaches to it. See `specs.md` §34, which also states what happens
  the moment that stops being true.
