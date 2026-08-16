---
aep: 2.0.0
owner: protocol
date: 2026-08-16
use-when: "writing or extending a runtime's entrypoint, so it reaches AEP without restating it"
---

# Template — the runtime entrypoint

Every runtime loads one file by name before anything else: `AGENTS.md` for the
agent-agnostic convention, `CLAUDE.md` for Claude Code, and whatever equivalent
another runtime defines. **That file's only job is to point at `[[protocol]]`.**

`/install` writes `AGENTS.md` from this shape when the repository has none, and
leaves an existing one alone — an entrypoint that already exists is the
repository's, and may be carrying instructions AEP knows nothing about.

## The shape

The entrypoint sits at the repository root, **outside `.aep/`**, so it carries no
AEP frontmatter — it is the repository's file, not an AEP artifact.

```markdown
# <repository name>

<One or two lines: what this repository is.>

## Start here

Read `.aep/protocol.md`. It is the bootstrap — the primitives, where state
lives, how to discover what is relevant, the workflow, and the invariants that
hold on every turn. Everything else loads when its `use-when` fires.

## <Anything this repository needs said on every turn>

<Optional. Keep it to what genuinely cannot wait for a rule to load.>
```

For a second runtime, the file is one line:

```markdown
# <repository name>

Read `AGENTS.md` in this directory. It is the entrypoint, and it is not
specific to any runtime.
```

## The one rule

**Point; never restate.** Do not summarise the primitives, the workflow, the
invariants, or any rule into the entrypoint.

*Why: a summary in the entrypoint is a second home for something that already
has one, and it is the copy that drifts — it is the file people edit when they
want to "just add one thing", and nothing checks it against the protocol.*

If something must be true on every turn and is not in `[[protocol]]`, that is a
finding about the protocol, or it is a repository rule with a `use-when`. It is
not a paragraph in the entrypoint.

## Extending one that already exists

Add the **Start here** section and change nothing else. A repository's existing
entrypoint predates AEP and its instructions still hold — where one genuinely
contradicts a protocol rule, that is a declared deviation
(`[[rules/ownership]]`), raised with the human rather than resolved by editing
either file.
