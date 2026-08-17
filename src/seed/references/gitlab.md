---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: reference
mode: [specify, plan, implement, review]
use-when: "reading or writing GitLab issues, merge requests, or pipelines for this repository"
---

# Reference — GitLab

**This file is yours.** Installed because a GitLab remote or CI configuration was
detected. Correct it where this repository differs.

Commands below were checked against the `glab` documentation. Confirm them
against your installed binary — `glab <command> --help` is the authority for the
version you have.

## Reading

```sh
glab issue view <id>
glab issue list --all
glab mr view <id>
glab ci status
```

Reading is always allowed; `[[policies/authority]]` still governs writing.

## Tasks as issues

Where this repository keeps AEP tasks in GitLab Issues rather than under the
effort, **use what GitLab already models** before introducing anything:

| The fact | Carried by | Note |
| --- | --- | --- |
| which effort this task belongs to | a **milestone** named for the effort | native, and directly queryable |
| open, resolved | the issue's **state** | native |
| what gates this task | **linked issues** — *is blocked by* | Premium and Ultimate only, and `glab` has no subcommand for it. See the gap below |
| obsolete, as distinct from resolved | **a label** | the one fact with no native carrier here |

```sh
glab issue create --title "<type(scope): summary>" --description "<text>" \
  --milestone "<effort>" --label <name>

glab issue update <id> --label <name>
glab issue update <id> --unlabel <name>
glab issue update <id> --milestone "<effort>"

glab issue close <id>
```

`--description` takes text rather than a path — read a file in with your shell
(`--description "$(cat <file>)"`) or use `--description -` to open an editor.

**Creating an issue publishes.** Write the whole set first — issues, and any
label or milestone the resolution needs created alongside them — show it, get it
approved, then create.

## Finding the effort, and the frontier

```sh
glab issue list --milestone "<effort>"          # open by default
glab issue list --milestone "<effort>" --all
glab issue list --label <name> --not-label <name>
```

The milestone query returns the effort's work. **The gating edges do not come
back with it** — see below — so on GitLab the frontier is the milestone query
plus whatever carries the edges. `[[policies/execution]]` still holds: the edges
are read, never inferred from which files a task looks like it touches.

## The dependency gap

Two separate limits, and they compound:

1. **`glab` has no subcommand for issue links at all.** The `issue` subcommands
   are `board`, `close`, `create`, `delete`, `list`, `note`, `reopen`,
   `subscribe`, `unsubscribe`, `update`, and `view`. Nothing links one issue to
   another.
2. **`blocks` and `is blocked by` are Premium and Ultimate.** On Free, only
   *relates to* exists, and it carries no direction — so it cannot express a
   gate even where it can be set.

So on GitLab the gating edge is recorded **in the issue description**, in a form
a person and an agent can both read, and maintained there. That is a real
degradation from GitHub, and writing it down is better than a `blocked-by-<n>`
label that nothing removes when the gate clears.

**Be exact about what that is.** GitLab parses no dependency out of a
description — `#123` in the text is a cross-reference and nothing more. The
written edge is a **convention this repository maintains by hand**, not a
mechanism, so it cannot be trusted the way `blockedBy` can on GitHub: it is only
as current as the last person who edited the description. Read it as a claim to
check, not as state.

Where this repository is on Premium or Ultimate, the links are worth setting in
the UI or through the API even though `glab` cannot — correct this section when
you do.

## Labels

A label is the last resort. Check whether GitLab models the fact natively (the
table above), then whether a label already serves it, and only then create one.

```sh
glab label list
glab label list --group <group>
glab label list --output json
glab label create --name <name> --color "#RRGGBB" --description "<text>"
```

**A new label matches the vocabulary already there** — separator, casing,
prefixing. Read the list before naming anything. Group labels are shared across
every project in the group, so creating one there reaches further than it looks.

## AEP tasks in this tracker

**Draft — this table is the part to correct.** It records what carries each fact
*here*, so no later session has to work it out again.

| Fact | Carried by | Kind |
| --- | --- | --- |
| effort membership | milestone named for the effort | native |
| status | open / closed | native |
| the gating edge | stated in the issue description | gap — `glab` cannot link |
| obsolete | a label, named in this project's style | derived |

## Referencing a task from a commit

```
Refs #123           references without closing
Closes #123         only where the commit reaches the default branch through
                    its own merge request
```

`[[rules/version-control]]` has the rule and the hazard behind it.

## Merge requests

Opening or merging is the **human's**. Prepare the description; do not submit.

## Failure handling

- `glab` unauthenticated reports the login command. Report it; do not attempt to
  authenticate.
- A flag rejected outright usually means the binary predates it. Report the
  version rather than falling back to a label silently.
- A feature refused on tier grounds is not a bug and not a gap in this file —
  report which tier it needs.
- An operation not listed here is a gap — say so rather than guessing a flag.
