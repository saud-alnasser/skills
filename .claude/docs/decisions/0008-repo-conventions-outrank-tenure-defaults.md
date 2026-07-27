# Tenure's conventions are defaults; the repository's documented conventions win

Tenure carries opinions — Conventional Commits, label vocabularies, PR description shape, file layout. Every one of them is a **default that applies when the repository is silent**, never a mandate. Where `CONTRIBUTING.md`, a PR template, an existing label set, or the repository's own history documents a different convention, that convention wins and Tenure adopts it.

This follows from the truth hierarchy. The codebase is the source of truth, and a repository's conventions are part of what the codebase *is*. A workflow that overwrites them is doing the same thing as a workflow that overwrites documentation to match its own beliefs.

It also follows from instruction precedence (ADR 0007), where `CONTRIBUTING.md` outranks anything Tenure asserts on its own authority.

## What adopts, and what converts

The rule applies to the repository's own engineering. It does **not** apply to the AI workflow layer, which converts wholesale — that layer is what Tenure replaces, and leaving it in place produces two competing workflows rather than one.

| Converts to Tenure | Adopted as found |
| --- | --- |
| Agent instructions — `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurfrules`, `.clinerules`, `.ai/` | Source layout, module structure, naming |
| Repository knowledge — `CONTEXT.md`, `CONTEXT-MAP.md`, decision records wherever they live | Test layout and framework |
| Agent workflow config — `docs/agents/`, tracker and label configuration files | Build, CI, and release configuration |
| Agent ticket stores — `.scratch/` and equivalents | Commit style, label vocabulary, PR template |
| How work is done — the command pipeline, tiers, sync, knowledge ownership | Human documentation — `README.md`, `CONTRIBUTING.md`, `docs/` that is not agent config |

Where a file is both — decision records are human-facing history *and* Tenure's Decisions layer — it converts, because Tenure owns that layer. `/configure` leaves a pointer at the old path when anything still references it.

## Consequences

Every skill that applies a convention must **detect before asserting**. Conventional Commits is applied only after reading `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE*`, and recent `git log`. Labels are read before any is created. This costs a check per convention and is the price of not trampling repositories Tenure is a guest in.

The failure mode this prevents is the loud one: Tenure arriving in an established repository and reformatting its commit messages, inventing a parallel label vocabulary, or restructuring its source — all while believing it is improving things.

The opposite failure is quieter and now guarded against by the boundary above: Tenure being so deferential that it leaves the old AI workflow in place, and the repository ends up running two.

Where a repository's convention is genuinely worse, Tenure may say so once, with reasoning, and then follow it. Changing a repository's conventions is a decision for its maintainers, not a side effect of adopting a workflow.
