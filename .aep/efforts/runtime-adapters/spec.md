---
aep: 2.5.1
owner: repository
date: 2026-08-18
kind: spec
status: accepted
---

# Problem

AEP ships one adapter, and the generator that builds it is shaped around the one
runtime it serves: `renderClaudeAdapter`, `writeClaudeAdapter`, an `--adapters
claude` flag that takes a single value, and a verification section that asserts
"the adapter" in the singular.

Two runtimes outside that shape are in use, and each reaches AEP incompletely or
not at all.

**OpenCode** discovers `.claude/skills/` at project scope, so a repository-shape
Claude adapter is picked up today — but only while OpenCode's Claude-Code
compatibility flag is left on, and **skills only**. Its agent loader reads
`.opencode/agent(s)/` and nothing else, so AEP's four agents reach it by no path
that exists. Its command registry also installs a built-in `review` before skills
are registered and skips any name already taken, so an AEP skill named `review`
is silently unreachable as a command.

**T3 Code** is a control surface over provider CLIs rather than a runtime. It
defines no format of its own; it discovers the provider's skills from the
provider config directory, `<workspace>/.agents/skills`, and
`<workspace>/.claude/skills`. Nothing tells anyone operating AEP under it which
of those paths is doing the work, or that the behaviour they get is the
provider's rather than T3 Code's.

The cost is silent: a user on either runtime sees some AEP skills work, no AEP
agents at all, and `/review` resolve to something that is not AEP.

# Goal

AEP ships adapters for OpenCode and for the runtime-neutral `.agents/skills/`
location, neither depending on the Claude adapter, both produced by one generator
that is no longer named for a single runtime — and a repository operating AEP
under T3 Code gets a starting point that says how it actually works there.

They are **alternatives inside OpenCode rather than a pair**, because OpenCode
reads both locations; which one a repository wants is a question the install asks
rather than one it answers for them.

# Scope

- `src/scripts/adapters.mjs` — generalized from one Claude renderer to a renderer
  per runtime target, over the same payload.
- `src/adapters/opencode/` — the committed, generated distribution shape. The
  `agents` target commits nothing; it renders at install time only.
- `src/scripts/install.mjs` — `--adapters` accepts more than one runtime.
- `src/skills/install.md` — its step 7 hard-names `--adapters claude` and
  describes only the Claude adapter's two shapes, so it cannot offer what this
  change ships. **Found during `/refine`**; the change is not complete without
  it, and no product scope moved.
- `src/scripts/release.mjs` — regenerates every adapter rather than the Claude
  one.
- `src/scripts/verify.mjs` — assertions read over every adapter.
- `src/scripts/payload.mjs` and `src/seed/references/` — seed references for
  OpenCode and for T3 Code.
- `specs.md` — §29, §32.1, and §32.2 amended in the same change.

# Requirements

1. The generator renders adapter files for a named runtime target, and the Claude
   adapter is one such target rather than the shape the code is built around.
   Descriptions stay derived from each canonical artifact's own heading and
   `use-when`; no wrapper carries hand-written prose.
2. An **OpenCode adapter** stands alone without Claude-Code compatibility: one
   wrapper per skill at `.opencode/skills/<name>/SKILL.md`, and one per agent at
   `.opencode/agents/<name>.md`.
3. An **`.agents` adapter** renders one wrapper per skill at
   `.agents/skills/<name>/SKILL.md`, and carries skills only, because that is all
   the location is read for. It does not depend on the Claude adapter — but it is
   **not immune to being switched off**: OpenCode gates `.claude` and `.agents`
   together behind one external-skills flag, and only a config directory such as
   `.opencode/skills/` is unconditional. The spec claims no more for it than
   that.
4. Every wrapper the two new adapters render is named `aep-<skill>` or
   `aep-<agent>`, and a skill wrapper's directory carries the same name as the
   wrapper.
5. Each new wrapper satisfies its runtime's own frontmatter schema, and AEP's own
   fields ride only in a free-form map that runtime reserves — `metadata` for a
   skill, and **nowhere** on an OpenCode agent, whose schema absorbs an unknown
   key silently instead of rejecting it.
6. Each wrapper is a pointer: it names the canonical `.aep/` file, states what to
   do when that file is absent, and restates no part of the skill.
7. `install.mjs --adapters` accepts a comma-separated list of runtimes, installs
   each into the directory that runtime reads, and names each in its report. An
   unknown runtime fails loudly rather than quietly installing nothing.
8. **`opencode` and `agents` are alternatives inside OpenCode, and the install
   says so.** `[[skills/install]]` offers one of them for an OpenCode repository
   rather than both; passing both to `install.mjs` writes both and **warns
   loudly**, naming the reason — OpenCode reads both locations, so every skill
   loads twice under one name and which file wins is decided by a race in the
   loader. It is a warning and not a refusal, because a repository driven through
   T3 Code with a non-OpenCode provider has a real use for `.agents/` beside
   `.opencode/`.
9. `release.mjs` regenerates every committed adapter.
10. `verify.mjs` asserts, for every adapter and not only Claude's: it is current
    byte-for-byte against the generator, every wrapper is a pointer rather than a
    copy, no skill note is published as a command, and the committed tree holds
    no generated file the generator does not produce.
11. A seed reference for **OpenCode** and one for **T3 Code** ship, each stating
    in its own first paragraph that it is a starting point. OpenCode is detected
    by `opencode.json` or `opencode.jsonc` — **never by `.opencode/`**, which
    the OpenCode adapter itself creates, so detecting on it would make AEP's own
    output the evidence that the repository uses OpenCode. T3 Code is detected
    by `t3.json`, the checked-in project file resolved at the workspace root —
    the only per-repository evidence T3 Code leaves.
12. The OpenCode adapter renders in **two shapes**, as the Claude adapter does:
    `repository`, written by an install into a repository that has `.aep/`; and
    `distribution`, whose fallback is a path **relative to the wrapper's own
    directory**, so `/aep-install` works in a repository where AEP does not exist
    yet. The distribution shape renders **skills only**: OpenCode registers extra
    skills from `skills.paths` and reads them where they sit, so they track the
    clone, while an agent can only be reached by copying a file into a config
    directory — and a copied wrapper is a generated artifact going stale in a
    user's home directory, which no suite can see. Agents therefore reach
    OpenCode only through the repository shape, written by an install. The
    `.agents` adapter renders the repository shape only.
13. `specs.md` is amended in the same change: §29 states that a runtime target is
    a named renderer rather than one runtime, §32.1's layout shows more than one
    adapter directory, and §32.2's assertions read over every adapter.

# Acceptance Criteria

1. `node src/scripts/adapters.mjs` regenerates every committed adapter, and a
   second run leaves the tree unchanged. No exported name in `adapters.mjs` makes
   Claude the general case.
2. `src/adapters/opencode/` holds the **distribution** shape: one
   `skills/aep-<name>/SKILL.md` per shipped skill, no agent wrapper, and no other
   generated file. A committed tree exists for a target exactly when that
   directory is itself what a user registers.
3. **No `src/adapters/agents/` is committed** — the `agents` target renders only
   into a repository, at install time. That it renders one
   `skills/aep-<name>/SKILL.md` per shipped skill and nothing else is asserted
   from the render, as is the OpenCode repository shape's skills-and-agents
   output.
4. Every rendered name matches `^aep-[a-z0-9]+(-[a-z0-9]+)*$`, and every skill
   wrapper's `name:` field equals its own directory name.
5. Every skill wrapper in the OpenCode **and** `.agents` adapters carries
   `name`, `description`, and `metadata` and nothing else — the same three,
   because both locations are parsed by readers that take exactly that shape.
   Every OpenCode agent wrapper carries `description` and `mode: subagent` and
   nothing else. Asserted by the suite, and each assertion demonstrated to fire
   by breaking a wrapper deliberately.
6. Each wrapper names its canonical path and contains no sentence from the
   canonical skill body; the suite's pointer assertion runs over the new adapters
   as it does over Claude's.
7. `install.mjs --into <tmp> --adapters claude,opencode,agents` writes `.claude/`,
   `.opencode/`, and `.agents/` into the repository and lists all three in its
   report; `--adapters nope` exits non-zero with
   the unknown name in the message.
8. `install.mjs --into <tmp> --adapters opencode,agents` writes both trees and
   emits a warning naming the duplication and the race; passing either one alone
   emits no warning. `[[skills/install]]` presents the two as alternatives rather
   than offering both.
9. `release.mjs <version>` leaves every committed adapter current — `verify.mjs`
   run immediately after passes the currency assertion for each.
10. `node src/scripts/verify.mjs` passes, and every new assertion is confirmed to
   fire by removing the thing it checks and watching it fail by name.
11. Installing into a fixture holding `opencode.json` seeds
    `references/opencode.md` and one without it does not; installing into a
    fixture holding `t3.json` seeds `references/t3code.md` and one without it
    does not.
12. Every distribution-shape OpenCode wrapper's fallback path, resolved from the
    committed wrapper's own directory, lands on a payload file that exists —
    asserted by the suite the way the Claude adapter's `${CLAUDE_PLUGIN_ROOT}`
    fallback already is, and confirmed to fire by pointing one at a file that is
    not there. The distribution shape renders no agent wrapper at all, and no
    `.agents` wrapper carries a fallback.
13. `verify.mjs` asserts §29, §32.1, and §32.2 as amended, and no shipped file
    under `src/` cites `specs.md` or a section number.

# Constraints

- **A wrapper is a pointer, never a copy.** The whole risk an adapter carries is
  a second home for a skill that then drifts from the canonical one, which is why
  descriptions are derived rather than written.
- **Adapters are generated and never hand-edited.** The committed tree is output,
  and the suite fails when it is stale.
- **Shipped text cites only what resolves where it is read.** A file under `src/`
  is read inside a consuming repository, so it may cite neither `specs.md` nor a
  section number.
- Scripts stay dependency-free ESM named `.mjs`.
- The two new adapters must each work **alone**: neither may assume the Claude
  adapter is installed, and the OpenCode one may not assume Claude-Code
  compatibility is enabled.
- `.aep/` here is output. Every change lands in `src/`, and the tree is
  reinstalled rather than edited.

# Out of Scope

- **A T3 Code adapter directory.** T3 Code exposes no mechanism to adapt to, so a
  directory of wrappers under a T3-specific path would duplicate the neutral one
  and drift from it. It gets a reference, which is what its behaviour actually
  needs recorded.
- **`.opencode/command/` wrappers.** OpenCode registers every discovered skill as
  a slash command already, so a command file would publish a second entry point
  onto the same canonical file.
- **An OpenCode plugin package on npm.** The bootstrap it would buy is bought
  instead by the distribution shape (requirement 11), which needs no publishing
  pipeline and no second distribution channel to keep in step with releases.
- **A user-scope shape for the `.agents` adapter.** Nothing that reads
  `.agents/skills` takes a configured path, so a wrapper there can only be
  copied, and copying breaks a fallback expressed relative to the wrapper.
- **Cursor, Codex, Gemini, and Grok adapters**, and any change to how the Claude
  adapter names its wrappers in repository shape.
- Changing what any skill or agent says. This change moves no canonical text.

# Assumptions

- OpenCode's `dev` branch as read on 2026-08-18 reflects released behaviour. The
  loader accepts both spellings — `{skill,skills}` and `agent(s)` — and the
  adapter writes the **plural** of each: `skills/` is what OpenCode's own
  repository uses and what its documentation shows, and `agents/` is what the
  documentation shows. That upstream's repository happens to use `agent/`
  singular is not a reason to split the two apart.
- Claude Code does not read `.agents/skills/`, so the neutral adapter does not
  double-publish AEP's skills under Claude Code beside the Claude adapter.
- A canonical artifact's name and the name a runtime knows it by may differ, and
  nothing breaks when they do. The Claude plugin already publishes `implementer`
  as `aep:implementer`, and an orchestrator selects an agent by the description
  the wrapper carries rather than by matching the canonical filename. `aep-`
  prefixing rests on that being true of OpenCode too.
- The payload's current skill and agent sets are what the adapters wrap; the
  count is read from the payload rather than fixed in the generator.
- A user running the distribution shape **registers the directory where it sits**
  — `skills.paths` pointed at the distribution's adapter directory — rather than
  copying the wrappers elsewhere. A copy severs the relative fallback, and
  nothing in the adapter can detect that it was copied.
- `t3.json` is present in a repository whose team uses T3 Code. A team that uses
  it without checking the file in receives no reference, which is the same trade
  every detected seed makes.

# Risks

- OpenCode moves fast, and both directory spellings are accepted today. If one is
  dropped, the adapter writes to a path nothing reads — and it fails silently,
  because a skill that was never discovered looks exactly like a skill nobody
  invoked. The suite cannot catch this; only re-reading the loader can.
- A repository that installs `opencode` and `agents` together loads every skill
  twice under one name, and OpenCode resolves the collision by whichever load
  finishes first. The wrappers are content-identical, so what the race decides is
  which path is reported as the skill's location — invisible until something
  depends on that location, which the distribution shape's relative fallback
  does. The warning is what stands between this and a silent surprise.
- Three adapters over one payload triples what a change to a skill's heading or
  `use-when` regenerates. A stale commit is caught by the suite, so the failure
  mode is a failing build rather than a drifting wrapper.

# Architecture

**One renderer over a table of runtime targets.**

`adapters.mjs` gains a `TARGETS` record. Each entry declares everything that
differs between runtimes — the directory an install writes it into, the name
prefix, where a wrapper of each kind lands, which shapes the target renders,
which shape is committed, the frontmatter keys that runtime's schema admits, and
how a fallback is expressed. A single `renderAdapter(distributionRoot, target,
shape)` walks the payload once and asks the target for the rest.

`describe()` is untouched: a wrapper's description stays derived from the
canonical artifact's own heading and `use-when`, which is the mechanism that
keeps the text a runtime matches on from disagreeing with the protocol.

**The alternative that lost: one render function per runtime**, sharing helpers,
with a registry mapping name to `{ render, dir }`. It reads better per runtime —
each one's quirks stay local, and no entry in a table has holes in it. It loses
on the thing this repository is most afraid of: the pointer contract — name the
canonical file, say what to do when it is absent, restate nothing — would be
stated three times, and the suite catches a *stale* adapter but not three
wordings of one contract drifting apart. A table with holes is legible; three
paraphrases of one rule are not.

**A target commits a tree exactly when that directory is itself what a user
registers.** `claude/` is committed because the marketplace publishes that
directory as the plugin. `opencode/` is committed in its distribution shape
because that is the directory a user names in `skills.paths`. The `agents` target
commits nothing, because nothing consumes a checked-in copy of it — it renders
into a repository at install time and nowhere else. Committing it would add
wrappers with no reader that churn on every `use-when` edit, and the currency
assertion that justifies a committed tree would be guarding an artifact nobody
loads.

# Components

| File | Change |
| --- | --- |
| `src/scripts/adapters.mjs` | `TARGETS`; `renderAdapter`/`writeAdapter` replace the Claude-named pair; the CLI regenerates every committed target |
| `src/scripts/install.mjs` | `--adapters` parses a list, resolves each through `TARGETS`, warns on the overlapping pair, exits on an unknown name |
| `src/skills/install.md` | step 7 rewritten: offer by runtime, name the alternatives, drop the hard-coded `--adapters claude` |
| `src/scripts/verify.mjs` | the `adapter` section loops over targets; the plugin-manifest, hook, and marketplace assertions stay Claude's alone |
| `src/scripts/payload.mjs` | two `reference(...)` rows |
| `src/seed/references/opencode.md` | new seed |
| `src/seed/references/t3code.md` | new seed |
| `specs.md` | §29, §32.1, §32.2 |

`release.mjs` needs no edit: it already shells out to `adapters.mjs`, so
regenerating every committed target follows from the generator's CLI.

# Interfaces

```js
const TARGETS = {
  claude: {
    dir: '.claude',
    prefix: '',
    committed: 'plugin',
    shapes: ['plugin', 'repository'],
    path(kind, name, shape),        // relative path, or null when this target
    frontmatter(kind, name, desc),  //   wraps no artifact of that kind in that shape
    fallback(kind, name, shape),    // lines, or null
  },
  opencode: { dir: '.opencode', prefix: 'aep-', committed: 'distribution',
              shapes: ['distribution', 'repository'], ... },
  agents:   { dir: '.agents',   prefix: 'aep-', committed: null,
              shapes: ['repository'], ... },
};

renderAdapter(distributionRoot, target, shape) -> [{ relativePath, contents }]
writeAdapter(distributionRoot, target, targetDir, shape) -> [relativePath]
```

`path()` returning `null` is how a target declines a kind: the OpenCode target
returns `null` for an agent under the `distribution` shape, and the `agents`
target returns `null` for an agent under every shape. That is the single place
the skills-only rule lives.

The CLI is unchanged in spirit and widened in reach:

```
node src/scripts/adapters.mjs [--target <name>] [--shape <shape>] [--to <dir>]
```

With no arguments it regenerates every target whose `committed` is non-null, into
`src/adapters/<name>/`, in that shape.

`install.mjs --adapters <a,b,c>` resolves every name through `TARGETS` **before
writing anything**, so an unknown runtime fails with nothing half-written.

# Technical Approach

1. **Table first, Claude through it.** Move the Claude adapter onto `TARGETS`
   with no change to its output — the existing byte-for-byte currency assertion
   is the proof, and it must pass before anything new is added.
2. **Generalize the wrapper builders.** `skillWrapper` and `agentWrapper` take
   the target and the shape rather than assuming Claude's frontmatter and
   fallback. The pointer body — canonical path, what to do when it is absent —
   stays one string built in one place, which is the whole reason the table won.
3. **Add the OpenCode target.** A skill's frontmatter is `name`, `description`,
   `metadata`; an agent's is `description` and `mode: subagent` and nothing else,
   because OpenCode routes an unknown key silently into `options` instead of
   rejecting it — a typo there is invisible rather than loud.
4. **Express the distribution fallback as a derived relative path.** The payload
   sits two levels above an adapter's own root and a skill wrapper sits two
   levels inside it, so the fallback is `'../'.repeat(depth) + 'skills/<name>.md'`
   with the depth **computed from the path template** rather than written out. A
   layout change then moves the fallback with it instead of silently breaking it.
   The wrapper says the path resolves from the skill's own directory, which is
   the base OpenCode announces to the agent when it loads a skill.
5. **Add the `agents` target**, which is the OpenCode target minus agents and
   minus the distribution shape.
6. **Widen `install.mjs`**, then rewrite step 7 of `[[skills/install]]` to match:
   offer by runtime, state that `opencode` and `agents` are alternatives, and
   keep the existing plugin-versus-committed reasoning for Claude.
7. **Move the suite.** Every assertion added is broken deliberately once and
   watched to fail by name, per `[[rules/authoring]]`.
8. **Seeds, then the specification, then the release.**

# Integration

`verify.mjs` fails any shipped artifact absent from `stamps.json` — *it has never
been released* — and the two seed references are shipped artifacts. The suite
therefore does not pass until `release.mjs` runs, so cutting the release is the
last ticket of this effort rather than a follow-up. The version is a feature
addition over 2.5.1 with no removal and no behaviour change for an existing
installation: **2.6.0**, with a `CHANGELOG.md` entry.

Nothing migrates. No installed tree changes shape, no artifact moves, and a
repository that never asks for a new adapter is untouched by this release.

# Testing Strategy

| Criterion | Checked by | Perturbation that proves the guard fires |
| --- | --- | --- |
| 1 | render each committed target, compare byte-for-byte against disk | edit one committed wrapper |
| 2, 3 | render the target, assert the exact set of relative paths | make the OpenCode target return a path for an agent under `distribution` |
| 4 | regex over every rendered name; a skill's `name:` equals its directory | drop the prefix from one target |
| 5 | parse each wrapper's frontmatter, compare the key set exactly | add a stray key to one wrapper |
| 6 | the existing pointer assertion, looped over targets | paste a sentence of the canonical skill into a wrapper |
| 7, 8 | install into a temporary repository with each `--adapters` value | pass an unknown name; pass the overlapping pair |
| 9 | `release.mjs --dry-run`, then the currency assertion | leave a committed adapter stale |
| 10 | the suite's own run | — |
| 11 | install fixtures with and without each detector's evidence | add `.opencode/` to a fixture and assert the OpenCode seed does **not** install |
| 12 | resolve each rendered fallback against the committed wrapper's directory | point one at a file that does not exist |
| 13 | the existing citation guard, plus assertions quoting the amended sections | — |

The install fixture already exists and is extended rather than replaced.

# Technical Risks

- **A table can express a target that renders nothing.** `path()` returning
  `null` is meaningful, so a target whose every call returns `null` renders an
  empty adapter and passes every per-file assertion vacuously. The suite asserts
  that each target renders one wrapper per shipped skill, which is the check that
  cannot pass vacuously.
- **The note assertion is Claude-shaped.** *No adapter publishes a note as a
  command* builds `skills/<name>/SKILL.md` by hand; under a prefix it would
  compare against a path no target produces, and pass while a note is published.
  It must ask the target for the path rather than construct one.
- **Moving Claude onto the table is the risky step**, not adding the new targets:
  it is the only one that can change an artifact that already ships. It lands
  first and alone, with the currency assertion unchanged, so the diff proves it
  inert.
