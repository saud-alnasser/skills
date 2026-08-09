---
status: accepted
load-when: something needs a fact only the running framework holds, or a new plugin component is proposed
sources: [hooks/hooks.json, hooks/check-version.js, .claude/protocol.md, .claude/evidence/research/2026-08-09-reading-the-plugin-version-from-a-running-stage.md, .claude/decisions/0060-the-regenerator-is-derived-from-a-behavioural-specification.md]
supersedes: []
superseded-by: []
---

# The release check is a hook, because only shipped content knows the release

A configured repository declares the release that wrote its protocol file, and a `SessionStart` hook the plugin ships compares that against the release now running, saying one line when they differ. This is AEP's first hook and its first shipped executable.

The placement is forced rather than preferred. Two facts have to meet, and they live on opposite sides of a boundary the framework depends on: the configured release is in the repository, and the running release is in the plugin. ADR 0060 forbids the repository's side reaching across — a configured repository stays useful to someone who never installed AEP — so the meeting has to happen in shipped content. Within shipped content, a stage-level check needs the same sentence in every stage that should warn, which is the single-home failure the framework exists to prevent. A hook is the only home that is both shipped and singular.

Research settled the mechanism before any of this was designed: the harness exports `CLAUDE_PLUGIN_ROOT` and `CLAUDE_PROJECT_DIR` to a spawned hook process, so the hook holds both paths without being told either.

## Considered Options

- **A step in each stage's verification.** Rejected on single-home: eight stages, one sentence, and the first one reworded is the one that stops matching. It also puts a plugin-dependent instruction into a committed file, which ADR 0060 spent its whole argument avoiding.
- **The release stamped into every shipped skill's frontmatter**, compared by whichever stage is running. This was the fallback while nothing could read the manifest. Rejected once research removed its motivation: it gives one fact seventeen homes and needs a release script and a cross-file agreement assertion to hold them together.
- **No check at all**, leaving `/configure`'s audit to find staleness. Rejected because the audit is a command nobody runs without a reason, and the reason is exactly what is missing — a repository two releases behind reports as current and nothing suggests otherwise.
- **Shell form rather than exec form.** Rejected on portability, and it is not close: shell form resolves to `sh -c` on Unix and to Git Bash *or* PowerShell on Windows, so one script cannot serve both. Exec form with `node` and a script path is the documented cross-platform spawn.

## Consequences

**AEP acquires a plugin component it has never had, and a second language.** The hook is JavaScript because `node` is the one interpreter the harness's own documentation treats as universally present; this repository's other scripts are PowerShell and stay that way. Nothing is installed into a configured repository — the script lives in the plugin, so ADR 0060's line is untouched.

**Silence is the design.** The hook says nothing when the versions match, when the repository does not run AEP, and when the protocol declares no release. An undeclared release is unknown, never stale: a repository configured before this field existed must not start warning about itself.

**The field becomes something `/configure` owns and must re-stamp.** An audit that brings a repository current and leaves the field behind makes the hook report a repository it just repaired, and a warning that is routinely wrong is a warning that is routinely ignored.

**One residual risk, accepted and recorded.** The exec-form pattern assumes `node` on `PATH`. The harness is a Node application and its documentation names this as the portable pattern, but an installation that keeps its runtime private would break the hook rather than degrade it — and a broken `SessionStart` hook is a non-blocking error, so the session proceeds and the cost is the notification alone.
