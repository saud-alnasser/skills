---
use-when: "orienting in this repository for the first time in a session, or deciding whether a change belongs in src/ or .aep/"
---

# Context — this repository

This repository **builds AEP**. It is both the protocol's source and one of its
consumers, and almost every mistake made here comes from confusing the two.

## The distinction that matters

| Path | Is | Change it? |
| --- | --- | --- |
| `src/` | **source** — everything that ships | yes; this is the product |
| `.aep/` | **output** — this repository's own installation, produced by running the installer on `src/` | no; reinstall instead |

Editing `.aep/` directly changes nothing that ships, and the next install
overwrites it. The exception is this repository's own repository-owned artifacts
— this file, `[[rules/authoring]]`, the seeded references — which are ours and
survive an upgrade like anyone else's.

## Shape

| Directory | Holds |
| --- | --- |
| `src/protocol.md` | the bootstrap, installed as `.aep/protocol.md` |
| `src/policies/` `src/modes/` `src/skills/` `src/agents/` `src/templates/` | the protocol-owned payload |
| `src/seed/` | repository-owned starting points, installed where detected |
| `src/scripts/` | the scripts `.aep/` gets, plus install, adapters, manifest, release, and verify |
| `src/adapters/<runtime>/` | the committed runtime adapters — generated, never hand-edited. A tree is committed only where that directory is itself what a user registers |
| `specs.md` | the normative specification. It is not shipped |

## Vocabulary

| Term | Means here |
| --- | --- |
| **payload** | the protocol-owned artifacts a release installs verbatim |
| **seed** | a repository-owned starting point, installed once, gated on detection |
| **adapter** | runtime glue that points at `.aep/`; never a copy of it |
| **distribution** | the contents of `src/` |

## Where to look

| To understand | Start at |
| --- | --- |
| what the protocol requires | `specs.md` — normative, and the thing `verify` asserts against |
| what ships and what does not | `src/scripts/payload.mjs` |
| how an installed tree is judged | `src/scripts/validate.mjs` |
| how the shipped surfaces are judged | `src/scripts/verify.mjs` |
| how a runtime reaches AEP | `src/scripts/adapters.mjs` |
| how a release is cut, and where the version of record lives | `src/scripts/release.mjs` |

There is **no package manifest and no dependency**. Every script is
dependency-free ESM run by a bare Node runtime, named `.mjs` so that a consuming
repository's `package.json` cannot change how it parses.

## Related

`[[rules/authoring]]` — what this repository requires of a change to `src/`.
`[[references/build]]` — the commands that check it.
