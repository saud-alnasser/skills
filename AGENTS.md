# AEP — the repository that builds it

This repository builds the **Agentic Engineering Protocol**: an agent-agnostic,
filesystem-first engineering protocol whose canonical state is plain files under
`.aep/`.

## Start here

**Read `.aep/protocol.md`.** It is the bootstrap — the primitives, where state
lives, how to discover what is relevant, the workflow, and the invariants that
hold on every turn. Everything else loads when its `use-when` fires.

Nothing about the protocol is restated here. A summary in an entrypoint is a
second home for the rules, and it is the copy that drifts.

## What is different about this repository

It is both the protocol's source and one of its consumers.

| Path | Is |
| --- | --- |
| `specs.md` | the **normative specification**. It defines the protocol; the implementation conforms to it or amends it in the same change |
| `src/` | what ships: the payload, the seeds, the templates, the scripts, and the committed runtime adapters |
| `.aep/` | this repository's own installation, produced by running the installer on `src/` |
| `.claude-plugin/` | the marketplace, publishing the adapter in `src/` as the plugin |

**`src/` is the source; `.aep/` is output.** Change the protocol in `src/`, then
reinstall. Editing `.aep/` directly changes nothing that ships, and the next
install overwrites it.

## Before committing anything under `src/`

```
node src/scripts/verify.mjs
```

It asserts the shipped surfaces against `specs.md` and installs into a temporary
repository to prove the result validates. **A change that adds a checkable claim
without an assertion is untested by construction** — move the suite in the same
pass.

Regenerate the runtime adapters whenever a skill or agent changes:

```
node src/scripts/adapters.mjs
```

It writes every committed target. `TARGETS` in that file is the list, and
`--target <runtime>` narrows it to one.

Cutting a release is one command, and it stamps only what changed:

```
node src/scripts/release.mjs <version>
```

**What changed is decided by `src/stamps.json`, one content hash per shipped
artifact.** Never hand-edit it. The `aep:` frontmatter field this used to work
through was retired in 3.0.0, so an artifact no longer carries the release it
last changed in; the baseline does.
