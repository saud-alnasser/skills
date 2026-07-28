# refactor(configure): derive tool references per repository, and delete the tools skill

Status: ready-for-agent
Blocked by: —

## Problem

Workflow tools are documented in a shipped, model-invoked skill and repository tools in `.claude/tools/`, so someone about to run a command must know which tier owns it before they can look it up. The shipped tier exists only where the plugin is installed, so a teammate who clones without Tenure has no reference for `git` or `gh` while still being bound by the rule forbidding them to guess a CLI — and the always-on entrypoint says so in the same sentence as the rule.

## Outcome

`/configure` detects which tools the repository uses and writes one file per tool into `.claude/tools/`, shaped for that repository and committed. There is one place to look for how to type any command. The model-invoked tool skill no longer exists, and every skill that reached for it reaches for the repository's own directory instead.

Derivation filters whole entries and never summarizes: `/configure` chooses which tools and which entries apply, and carries every entry it keeps over intact.

## Acceptance

- A repository configured from scratch has a tool file for each tool it is detected to use, and none for tools it does not — a repository with no stacking tool initialised gets no stacking reference.
- Every entry in a derived file is either identical to the shipped entry it came from, or newly derived from this repository's own manifest, scripts, or CI.
- The single-file test command is present, as it is today.
- No skill that ships references a tool file outside `.claude/tools/`, and the model-invoked tool skill is absent.
- The always-on template no longer says the workflow tool reference depends on the plugin being installed.
- A tool operation with no entry is reported as a configuration gap naming `/configure`, never guessed.
- The verifier asserts each of the above, including that a derived entry matching its source is checked mechanically rather than trusted.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
