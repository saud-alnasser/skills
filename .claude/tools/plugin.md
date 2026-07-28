# claude plugin — Tenure's own distribution

This repository *is* the plugin: `.claude-plugin/plugin.json` sits at the root and `marketplace.json` publishes it with `"source": "./"`. So the tree you are editing and the Tenure that is running are two different things, and the whole point of this file is the gap between them.

Docs: https://code.claude.com/docs/en/plugin-marketplaces and https://code.claude.com/docs/en/plugins. **Fetch them when an operation below is missing**, not to re-read what is here — the CLI's own `--help` is faster and is what the entries below were taken from.

## Editing `skills/` does not change the running Tenure

An installed Tenure runs from a **cache pinned to a commit**, never from this working directory — whichever source the marketplace was added from. So a fix written into `skills/` here does not reach the running plugin until it is committed, published to that source, and the installed copy updated. `CLAUDE.md` makes publishing the human's call. Expect the edit to appear to do nothing until then; that is the design, not a fault.

Where a given clone's Tenure came from is **Position** — per-machine, and recorded in the gitignored `settings.local.json` rather than here. Read it with:

```
claude plugin list
claude plugin marketplace list
```

`list` prints the pinned version, which is the commit the running skills actually come from. Compare it against `git rev-parse HEAD` before concluding that a change to `skills/` has taken effect.

## Test a `skills/` change without pushing

```
claude --plugin-dir .
```

Loads this directory as the plugin for that session. A `--plugin-dir` plugin **takes precedence over an installed marketplace plugin of the same name**, so this overrides the installed Tenure rather than colliding with it — which is what makes it the working loop for fixing a framework bug found mid-ticket, with nothing published and nothing to undo.

```
/reload-plugins
```

Picks up further edits in the same session, without a restart.

## Refresh the installed copy after a push

Two commands, and the first alone does nothing visible:

```
claude plugin marketplace update tenure-marketplace
claude plugin update tenure@tenure-marketplace --scope local
```

The marketplace update refreshes the **catalog**; the installed plugin stays pinned to its old commit until the second command runs. `claude plugin list` reports the pin, so it is how you tell the two apart. A restart applies the change.

**The second command needs both the qualified id and the scope, and lies when it does not get them.** `claude plugin update tenure` fails with `Plugin "tenure" not found` — not because it is missing, but because the bare name misses and `--scope` defaults to `user` while Tenure is installed at `local`. Adding only the scope fails identically. Read that error as *wrong id or wrong scope*, never as *not installed*; check `claude plugin list` before believing it.

The marketplace name is optional — omitting it updates every configured marketplace.

## Validate before publishing

```
claude plugin validate . --strict
```

Takes the path to a plugin **or** a marketplace manifest and detects which it is — pointed at this repository's root it validates `marketplace.json` and the plugin entry beneath it. `--strict` promotes warnings to a failure.

Bare `claude plugin validate .` tolerates what `--strict` rejects, so a clean run without the flag proves less than it appears to.

## Gotchas

**`plugin` and `plugins` are the same command**, as are `install`/`i`, `uninstall`/`remove`, and `marketplace remove`/`rm`. Nothing distinguishes them; do not read meaning into which one a transcript used.

**Everything except `plugin.json` lives at the plugin root, never inside `.claude-plugin/`.** `skills/` is at the repository root here for that reason — it is not a stylistic choice, and moving it under `.claude-plugin/` would silently ship a plugin with no skills.

**Without a `version` in `plugin.json`, the commit SHA is the version** and every commit counts as a new release for anyone who has it installed.
