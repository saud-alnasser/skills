# AEP — the Agentic Engineering Protocol

A Claude Code skill framework that makes Claude a partner whose understanding of a repository compounds over time, rather than a stateless execution pipeline. It derives from [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering) and adds a persistent repository-knowledge layer on top. The framework's canonical definition is [`specs.md`](specs.md); it was named **Tenure** first and the **AI Engineering Protocol** after that, so records written under either name still say so.

## Install

AEP ships as a plugin published from this repository, and installs at **`local` scope** — recorded in that project's `.claude/settings.local.json`, which is gitignored. It is therefore personal but not global: enabled in the projects you choose, absent everywhere else, and copied into neither.

From inside the project you want it in:

```
/plugin marketplace add saud-alnasser/skills
/plugin install aep@aep-marketplace
/reload-plugins
```

`marketplace add` also takes a git URL or a path to a local checkout — use the
path when you want the project to track your working copy rather than what is
pushed.

Choose **local** when the install prompt asks for a scope. The other scopes do not express what AEP wants: `user` enables it in every project, and `project` commits the choice for the whole team.

Then, once per repository:

```
/aep:configure
```

`/aep:configure` writes the repository's knowledge and machinery — the root `CLAUDE.md`, `.claude/protocol.md`, `.claude/rules/`, `.claude/policies/`, `.claude/contexts/`, and `.claude/tools/`. Nothing else works properly until it has run.

To see what to reach for and when, `/aep:help`.

## What a teammate without the plugin sees

A repository AEP has configured stays useful to them. `CLAUDE.md` and `.claude/rules/` are committed and carry only rules that hold with or without the plugin — precedence, the knowledge layers, verifying before claiming, healing documentation where it has gone stale. The harness loads both whether or not AEP is installed. The protocol itself is in `.claude/protocol.md`, reached by pointer, and nothing committed assumes an AEP command exists.

## Repository layout

```
specs.md                 the AEP specification — the framework's canonical definition
.claude-plugin/          the plugin manifest and the marketplace that publishes it
skills/                  the plugin's skills — the whole framework
scripts/verify.ps1       asserts the build tickets' acceptance criteria against ./skills
.claude/                 this repository's own knowledge, written by AEP
├── decisions/           the decisions behind the framework
└── tickets/<effort>/    each effort's spec and build tickets
```

This repository is itself configured by AEP, so `.claude/` here is an example of the output as well as the input to it. `skills/` is what ships; `.claude/` is what this repository runs on.

There is no package manifest and no test runner. `scripts/verify.ps1` stands in for one:

```
pwsh -NoProfile -File scripts/verify.ps1                    # all tickets
pwsh -NoProfile -File scripts/verify.ps1 -Ticket tenure/20  # one, as <effort>/NN
```

Ticket identifiers keep their historical effort names — `tenure/`, `layout/`, `streamline/`, `aep/` — because the tickets are the build record.

## Licence

See [LICENSE](LICENSE) and [NOTICE](NOTICE).
