---
status: accepted
load-when: how AEP is installed or distributed is in question
sources: [.claude-plugin/]
supersedes: []
superseded-by: []
---

# Tenure ships as a plugin, installed per project

Tenure is distributed as a Claude Code plugin published from this repository, and installed at **`local` scope** — recorded in `.claude/settings.local.json`, which is gitignored. It is therefore personal but not global: enabled in the projects chosen for it, absent everywhere else.

The alternative locations do not express that. `~/.claude/skills/tenure/` with a plugin manifest loads as a skills-directory plugin with no install step at all, but that location is *personal scope*, which means every project. `.claude/settings.json` is committed, which means the whole team. Only `local` is per-project and per-person, and it installs from a marketplace — so this repository gains a `.claude-plugin/marketplace.json`.

Plugin skills are namespaced, so every command becomes `/tenure:<name>`. That prefix changes what a good skill name is.

**Short names are for the keyboard; descriptive names are for the model.** A skill the user types wants one word, because the prefix is already there. A skill only Claude invokes wants an expressive name, because the name is part of how it gets selected, and shortening it trades accuracy for brevity nobody ever types. Of the eighteen skills, eleven are typed and seven are model-invoked only.

Three renames follow, all forced by a real problem rather than by tidiness:

| Before | After | Why |
| --- | --- | --- |
| `tenure` | `/tenure:help` | `/tenure:tenure` is unusable |
| `code-review` | `/tenure:review` | decision 13's collision does not exist inside a namespace |
| `improve-codebase-architecture` | `/tenure:survey` | its own description: *survey a codebase for deepening opportunities* |

**This supersedes decision 13**, which chose `/code-review` to preserve the built-in `/review`. A namespaced `/tenure:review` does not shadow it.

## Considered Options

- **A marketplace declared in the repository's `.claude/settings.json`.** The correct end state for a team, and the only way a repository's knowledge layer can rely on a command existing for everyone who clones it. Deferred rather than rejected — the artifact is the same, only the scope flag differs.
- **Vendoring Tenure into each repository's `.claude/skills/`.** Rejected: N copies to update, and it puts the framework inside the repositories it is meant to be independent of.

## Consequences

A teammate without the plugin clones a repository whose committed knowledge is still useful, because `CLAUDE.md` carries only what applies to any Claude (ADR 0012). Nothing committed may assume a Tenure command exists.

Every command name in every skill, template, and assertion moves. `scripts/verify.ps1` changes with them.

The model-invoked primitives keep their names, so the rule has to be stated as a rule — otherwise the next skill added gets shortened for consistency and loses the signal that selects it.
