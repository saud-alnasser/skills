# Tenure

A Claude Code skill framework that makes Claude a partner whose understanding of a repository compounds over time, rather than a stateless execution pipeline. It derives from [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering) and adds a persistent repository-knowledge layer on top.

## Install

Tenure ships as a plugin published from this repository, and installs at **`local` scope** — recorded in that project's `.claude/settings.local.json`, which is gitignored. It is therefore personal but not global: enabled in the projects you choose, absent everywhere else, and copied into neither.

From inside the project you want it in:

```
/plugin marketplace add saud-alnasser/skills
/plugin install tenure@tenure-marketplace
/reload-plugins
```

`marketplace add` also takes a git URL or a path to a local checkout — use the
path when you want the project to track your working copy rather than what is
pushed.

Choose **local** when the install prompt asks for a scope. The other scopes do not express what Tenure wants: `user` enables it in every project, and `project` commits the choice for the whole team.

Then, once per repository:

```
/tenure:configure
```

`/tenure:configure` writes the repository's knowledge layer — `.claude/context.md`, `.claude/tracker.md`, `.claude/tools/`, the root `CLAUDE.md`, and `.claude/tenure.md`. Nothing else works properly until it has run.

To see what to reach for and when, `/tenure:help`.

## What a teammate without the plugin sees

A repository Tenure has configured stays useful to them. `CLAUDE.md` and `.claude/rules/` are committed and carry only rules that hold with or without the plugin — precedence, the knowledge layers, verifying before claiming, healing documentation where it has gone stale. The harness loads both whether or not Tenure is installed. Tenure's own protocol is in `.claude/tenure.md`, which only Tenure's skills open, and nothing committed assumes a Tenure command exists.

## Repository layout

```
.claude-plugin/          the plugin manifest and the marketplace that publishes it
skills/                  the plugin's skills — the whole framework
scripts/verify.ps1       asserts the build tickets' acceptance criteria against ./skills
.claude/                 this repository's own knowledge, written by Tenure
├── decisions/           the decisions behind the framework
└── tickets/<effort>/    each effort's spec and build tickets
```

This repository is itself configured by Tenure, so `.claude/` here is an example of the output as well as the input to it. `skills/` is what ships; `.claude/` is what this repository runs on.

There is no package manifest and no test runner. `scripts/verify.ps1` stands in for one:

```
pwsh -NoProfile -File scripts/verify.ps1                    # all tickets
pwsh -NoProfile -File scripts/verify.ps1 -Ticket tenure/20  # one, as <effort>/NN
```

## Licence

See [LICENSE](LICENSE) and [NOTICE](NOTICE).
