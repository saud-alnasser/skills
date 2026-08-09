---
title: 'feat(protocol): the protocol records the version it was configured at'
status: resolved
blocked-by: []
part-of: axis
---

## Problem

A configured repository's protocol file is written by one version of the
workflow and then keeps running against whatever version is installed later.
Nothing compares the two. A repository configured two releases ago behaves as
though it is current, and the audit that would find out is a command nobody has
a reason to run — because nothing told them the tree had fallen behind.

## Outcome

The protocol file records the version that wrote it. When a stage runs against a
workflow whose version differs, the user is told, in one line, and told that
configuring repairs it.

The check belongs where the marker check already sits: inside a running stage,
not in the always-on tier. A question turn does not pay for it, and a stage
running already implies the workflow is installed.

## Comments

**The block was lifted by research, and one of its three routes was wrong.**
`.claude/evidence/research/2026-08-09-reading-the-plugin-version-from-a-running-stage.md`
has the finding. The harness substitutes `${CLAUDE_PLUGIN_ROOT}` in skill and
agent content and exports it to hook processes; what it does not do is put it in
a stage's shell, which is where the original check looked. The other two routes
held: the CLI still reports nothing for a directory source, and ADR 0060 still
forbids the protocol pointing into the plugin.

**It is a hook, not a step in a stage.** Both readings were open once the
mechanism existed. A stage could be told to read the manifest, and that would
need the same sentence in every stage that should warn — the single-home failure
the framework exists to prevent. A hook has both paths without being told them,
runs before any stage, and leaves no plugin-dependent instruction in a committed
file, so ADR 0060 is satisfied by construction rather than by argument. This is
AEP's first hook.

**The stamping variant the ticket imagined is not needed.** Putting the release
in every shipped skill's frontmatter was the fallback when nothing could read
the manifest. Something can, so the fallback has no motivation left and the
Decision it would have required is not written.

**Exec form with `node`, verified.** The documented cross-platform spawn, since
shell form resolves to `sh -c` on Unix and Git Bash *or* PowerShell on Windows
and no one script serves both. `node v24.18.0` is on PATH here. All four
branches were run directly against the script before anything depended on it:
silent with no field, silent when equal, one line when different, silent outside
an AEP repository.

## Acceptance

- The protocol file declares the version that wrote it, as a field.
- A stage running against a different version says so once, names configuring as
  the repair, and does not stop the work.
- A stage running against a matching version says nothing.
- A protocol file with no version declared is treated as unknown rather than as
  stale, and the absence is not an error.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
