---
title: refactor(configure): derive tool references per repository, and delete the tools skill
status: resolved
blocked-by: []
---

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

## Comments

**Two decisions were the user's.** The shipped reference lives at `skills/configure/tools/` rather than as flat `*.template.md` files — it groups the four and keeps `configure/`'s root readable, at the cost of differing slightly from the existing template naming. And provenance is carried by the heading rather than per-entry marker comments: a derived file declares `Derived from: tenure/<file>`, and sections are paired by heading and compared byte-for-byte. That keeps markers out of a document humans read, and reuses the fact that `verify.ps1` already treats a `## ` section as an entry.

**Criterion 7 was proved, not just written.** The comparison would otherwise run over zero files until ticket 04 derives this repository's own, and a check over zero files is trusted rather than mechanical. It was exercised twice: a fixture inside the assertion, and a real file on disk carrying a genuine summarization of `git.md`'s `--porcelain` entry — the column-layout gotcha removed, which is precisely what ADR 0019 says filtering exists to protect. Caught and named. The same entry carried over verbatim passed.

**The Graphite probe was wrong and is corrected in place.** `tools/graphite.md` documented `gt log --stack` as the check for whether a repository uses Graphite. On gt 1.8.6 it initialises the repository — writing four files into `.git/` — and exits `0`, so a probe keyed on a non-zero exit reads an uninitialised repository as initialised, having just made that true. Nothing lands in the tracked tree, so `git status` stays clean and the change is invisible where anyone would look. Discovered by running the documented check during ticket 02 and having to undo it. The entry now reads `.git/.graphite_repo_config` instead. This is the one moved file whose *content* changed, and it changed because `TOOLS.md` now points at that entry for detection.

**Three homes for the configuration-gap rule, reduced to two.** The reader's half must hold with no plugin installed, so it stays in the always-on template; the half naming `/configure` as the remedy is meaningless without Tenure, so it lives with the derivation rules. That is a split by when the rule fires, which is the documented test. The router was restating both and is now a pointer. A `$rulePattern` guard added in the same pass then caught `TOOLS.md` restating the docs-fallback sentence too — found by the guard, not by reading.

**`tenure/15`'s section narrowed rather than being deleted.** ADR 0019 reversed that ticket's two-tier model, so its assertions about the shipping shape moved here; what it asserted about the reference's *content* still holds, because 0019 did not touch the text. The section says so, so it does not read as having quietly lost coverage.

Ticket 04 derives this repository's own files and repairs its `CLAUDE.md`, which still carries the plugin-conditional wording. That is not stale yet: an installed Tenure runs from the 1.0.0 plugin cache, which still contains `skills/tools/`, so editing this working tree does not change the running workflow until it is published.
