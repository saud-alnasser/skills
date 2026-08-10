# Deriving `.claude/tools/`

One directory, one format, one place to look for how to type any command — the workflow's tools and this repository's, together and committed.

Committed is the point: the reference used to ship inside the plugin, so a teammate who cloned without AEP had none of it while still bound by the rule against guessing a CLI. Deriving into a file git tracks is what closes that.

## Write a file only for a tool the repository uses

Detection is off the repository, never off the list below.

| Ship a file for | When |
| --- | --- |
| `git` | there is a `.git/` — so, always |
| `gh` | a remote points at GitHub |
| `glab` | a remote points at GitLab |
| `gt` | Graphite is initialised here, which is not the same as `gt` being on the machine |
| the repository's own | the manifest, scripts, or CI name it |

A tool the repository does not use gets no file. A stacking reference in a repository with no stack is a page that answers a question nobody standing here can ask, and it will be read as permission to start.

**`gt` is the one worth checking carefully.** Graphite being installed says nothing about this repository; only `gt init` having been run here does. The check is in `graphite.md` — and read what that entry says about the check's own side effects before running it.

## Filter whole entries; never summarize

This is the load-bearing rule of the whole file.

A tool reference's value is concentrated in gotchas — the exact column layout of a porcelain read, a verb whose name lies about what it does, a flag that does not exist — precisely what a rewrite smooths away, because they read as noise until the day they don't.

So:

```
keep an entry   → carry it over intact, byte for byte
drop an entry   → drop the whole section, heading and all
summarize       → never
```

**Filtering loses whole entries, which is visible. Summarizing loses clauses, which is not.** A dropped section is one grep away from being noticed; a paragraph that lost its qualifier looks exactly like a paragraph.

Drop an entry when the operation cannot arise here — the GitLab entries in a GitHub repository, the stack entries where there is no stack. Keep it when you are unsure. An entry that is never read costs a screenful; an entry that was needed and is missing costs a guessed command.

## The heading is the entry's identity

A derived file names its source directly under the title:

```markdown
# git — version control

Derived from: aep/git.md
```

Every section kept from that source **keeps its heading exactly**, and its body byte-for-byte. That is what makes the rule checkable rather than a promise: the verifier pairs sections by heading and compares bodies, so a filtered entry passes by being absent and a summarized one fails by differing.

Entries newly written for this repository are ordinary sections with no counterpart upstream, and nothing compares them. Put them under their own heading in the same file — a repository's own `git` entries belong beside the workflow's, not in a second document.

## The format

Every file: `owner: repository` frontmatter — a derived reference is the repository's to heal, and the field is what the audit reads — then what it is for, the docs URL, **and the condition for fetching it** — a URL with no trigger is decoration.

```markdown
---
owner: repository
---

# <tool> — <what it is for here>

Docs: https://...
Fetch the docs when: <the condition>
```

Then task-to-command pairs under task-shaped headings. The question a reader arrives with is always *"how do I do X here"*, never *"what does `-n` mean"*. A flag catalogue is what the docs are for.

Leave out what is already certain. An entry for `git log` earns nothing; an entry for the exact `--porcelain` column layout earns its place. **Note the gotcha, not the syntax.**

## A missing entry is a configuration gap

When an operation is needed and no file has an entry for it, that is a gap in the configuration — **not licence to guess**.

Say so, naming `/configure` as what fills it, and re-run it to derive the entry. That remedy is all this file carries, because it is the half that means nothing without AEP installed.

What to do when the entry still is not there is the never-guess rule in `.claude/rules/engineering.md`. It lives there rather than here because it has to hold for someone working in this repository with no plugin at all.

## Refreshing a derived file

The relationship is a vendoring one: a fix AEP makes to its own reference does not reach an already-configured repository on its own.

**Downward**, `/configure`'s audit branch re-checks `.claude/tools/` against the repository — the file against the repository it describes, which is the check that matters day to day; a repository whose tooling has not changed does not need the shipped text's changes.

**Upward**, a repository that runs a command and finds the shipped entry wrong about the version it just ran writes that up as a record and hands it back. It does **not** edit the plugin: a finding about another repository leaves as a report, which is the always-on boundary rule and not a courtesy. The record carries the version it was checked against and what was actually observed, because a tool fact is true of a version and an entry that arrives without one cannot later be told from a fact that has merely gone stale.

That direction exists because the first one cannot reach the case where the *repository* is right and the plugin is wrong. It is not hypothetical: two entries here asserted that `gh` lacked capabilities it had had for releases, while the repositories that had actually run the command carried the correction and had nowhere to send it.

**One observation is not a version's behaviour.** Where two repositories report differently about the same version, the entry says the behaviour is configurable or unknown rather than picking the more recent report — a page that records the last thing somebody saw is a page that flips.
