# AEP, the Agentic Engineering Protocol

An **agent-agnostic, filesystem-first engineering protocol** for AI-assisted
software work. All of its state is plain Markdown under `.aep/`. No runtime, no
database, no resident process. Claude Code, Codex, Cursor, Gemini, and unassisted
humans are all consumers; what a runtime provides is an *adapter*, never AEP.

The guiding principle: **make correct engineering behaviour easy to discover,
hard to violate, and cheap for an agent to understand.**

`specs.md` is the normative specification.

## The model

```
policies    what MUST be done. AEP's, protocol-owned, never edited here
rules       what MUST be done here. Yours, and an upgrade preserves them
references  how a tool is operated here
contexts    what to know about an area, and where to look
evidence    what has been discovered: research, prototypes
efforts     what change is being made; spec.md is its truth
tasks       executable work derived from the spec
modes       how to think during an activity
agents      who does the work, in what role
skills      reusable capabilities
worktrees   isolated execution, never knowledge
position    lightweight operational state, never truth
```

Every artifact declares **when it applies** (`use-when`, `paths`, `mode`), so
knowledge loads by relevance rather than by stage. Nothing tells an agent to read
the whole governance layer before starting. A policy is rigid in authority, not
in when it loads.

## The workflow

```
/specify → /refine? → /plan? → /tasks → /implement → /review → /commit
```

`research`, `prototype`, `survey`, and grill are **capabilities, not stages**.
Pick the smallest process that produces a reliable result.

## Install

AEP ships as a Claude Code plugin published from this repository:

```
/plugin marketplace add saud-alnasser/skills
/plugin install aep@aep-marketplace
/reload-plugins
```

Then, once per repository:

```
/aep:install
```

That writes `.aep/`, seeds the repository-owned starting points its setup calls
for, a version-control rule and references for the tools it actually detects,
and points the entrypoint at `.aep/protocol.md`.

**Already running AEP 1.x?** Run `/aep:update` instead. `/aep:install` and the
installer both refuse a 1.x repository, because 1.x has no `.aep/` and a fresh
install would land beside the live tree and orphan everything in it.

**Without the plugin**, run the installer directly; nothing about AEP requires it:

```
node <checkout>/src/scripts/install.mjs --into <repository> --adapters claude
```

## Layout of this repository

```
specs.md                  the normative specification
AGENTS.md                 the entrypoint, pointing at .aep/protocol.md
src/                      everything that ships
├── protocol.md           the bootstrap installed as .aep/protocol.md
├── policies/ skills/ agents/ templates/         protocol-owned payload
│   └── skills/<skill>/    depth read only when that skill branches to it
├── seed/                 repository-owned starting points, installed on detection
├── scripts/              install, verify, and the scripts .aep/ gets
├── gitignore             becomes .aep/.gitignore
└── adapters/<runtime>/   the committed adapters: pointers, never copies, and
                          the Claude plugin itself, its manifest and its skills
.claude-plugin/           the marketplace that publishes that adapter
.aep/                     this repository's own installation
```

## Checks

```
node src/scripts/verify.mjs        # shipped surfaces against specs.md, plus a fixture install
node src/scripts/adapters.mjs      # regenerate every committed adapter
node .aep/scripts/validate.mjs     # any installed tree against the artifact contract
node .aep/scripts/index.mjs        # regenerate the discovery index
```

There is no package manifest and no dependency. Every script is dependency-free
ESM run by a bare Node runtime.

## Prior work

AEP 2.0 takes the **specify → plan → tasks → implement** spine from
[GitHub's Spec Kit](https://github.com/github/spec-kit) and the **composable
skill** shape from [mattpocock/skills](https://github.com/mattpocock/skills). It
depends on neither and requires neither installed.

What it adds to both: applicability metadata on every artifact, so knowledge
loads by relevance rather than by stage; a declared ownership boundary, so an
upgrade cannot eat repository knowledge; and evidence bound to the effort that
motivated it, so investigation survives the conversation.

**What is taken from each is a shape, not text.** AEP 2.0 vendors no code or
prose from either project, because every shipped file was written for this
protocol, so no third-party licence condition attaches to it.

AEP 1.x was a Claude Code skill framework rooted in `.claude/`. 2.0 is a rewrite
of the framework, so none of it upgrades in place. `specs.md` §33 lists what was
removed and what replaced it. A 1.x repository's **own** knowledge does move
across: `/update` detects the old layout and runs a carry-across that installs
2.0 fresh, re-homes the contexts, tool guides, specs, tickets, and evidence, and
reports every assumption it made on your behalf.

## Licence

Apache 2.0. See [LICENSE](LICENSE).
