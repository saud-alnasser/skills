# Tenure owns the engineering rules, and places each where it fires

`workflow.md`'s nineteen Engineering Principles overlap heavily with the user's global `~/.claude/CLAUDE.md` — eight are near-verbatim duplicates. Rather than have Tenure skip rules the global file already states, the global file is trimmed and **Tenure becomes the single source of truth**. The rules then travel with the workflow into any repository instead of depending on one machine's personal configuration.

Placement follows where a rule actually bites, so context is not spent restating it on turns where it cannot apply:

- **Root `CLAUDE.md`** — rules that must hold on every turn, including turns with no skill invoked: the truth hierarchy, verify-before-claiming, the compression test, and that Claude never silently decides architecture. Plus the instruction precedence chain.
- **The skill that enforces it** — "never guess APIs" in `/research` and `/implement`; naming and file-structure rules in `codebase-design` and `/implement`; comment and public-API rules in `/implement` and `/code-review`; test layout in `tdd`; root-cause-over-workaround in `/design`'s grill.
- **`.claude/rules/`** — standards `/configure` discovers in the repository itself, path-scoped where they apply to only part of the tree. These belong to the repo, not to Tenure.

Of the nineteen, three are definitions rather than rules and live in `context.md`'s glossary; two ("synchronize understanding", "scale process with risk") are embodied by the verification discipline and the tier gates, so stating them separately is duplication; and two ("architecture over convenience", "leave the repository better") are too vague to change behaviour and are cut unless they can be made checkable.

Instruction precedence resolves a conflict between the two sources: `CONTRIBUTING.md` ranks **above** `README.md`. CONTRIBUTING describes how the repository is worked on; README describes what it is.

## Consequences

The user's global `~/.claude/CLAUDE.md` must be trimmed when Tenure is installed, or the duplication simply moves rather than resolving. This is a manual step and easy to forget — it belongs in the install ticket, not in `/configure`, because `/configure` operates on a repository and the global file is outside any repository.

A rule placed inside a skill only fires when that skill runs. Any rule that must hold unconditionally therefore has to be in `CLAUDE.md`, and misplacing one there is a silent failure — the rule simply never applies.
