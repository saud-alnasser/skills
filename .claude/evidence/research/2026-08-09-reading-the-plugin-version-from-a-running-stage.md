---
kind: research
falsifies: [.claude/tickets/axis/issues/04-the-protocol-records-its-version.md]
---

# Reading the plugin's own version from a running stage

Consumed: `.claude/tickets/axis/issues/04-the-protocol-records-its-version.md`, the blocked note this falsified — axis/04

Taken 2026-08-09 against the Claude Code documentation at `code.claude.com/docs/en`, pages `plugins`, `plugins-reference`, and `hooks`, plus two local checks. AEP was at 1.13.0, running from a `directory` marketplace source.

## The question

`.claude/tickets/axis/issues/04` was blocked on this: a stage that wants to warn *"this repository was configured at an older version"* has to know what version is running. It recorded three dead routes and stopped. One of the three was wrong.

## What is true

**`${CLAUDE_PLUGIN_ROOT}` resolves inside skill and agent content.** The reference's *Environment variables* table is explicit about which components substitute placeholders, and skill content is the first row:

| Plugin component | Fields where placeholders resolve |
| --- | --- |
| Skill and agent content | Anywhere the placeholder appears |
| Hook and monitor commands | Anywhere the placeholder appears |
| MCP `stdio` servers | `command`, `args`, `env` |

So a stage *can* be told to read `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`. The blocked note's claim that no route exists is false, and it was false because the check that produced it looked in the wrong place.

**The three variables are `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, and `${CLAUDE_PROJECT_DIR}`.** All three are exported as environment variables to hook processes and to MCP and LSP subprocesses — *"so a script can read `process.env.CLAUDE_PLUGIN_ROOT` regardless of how it was launched."*

**The manifest's `version` is the running version, for AEP.** Version resolution takes the first that is set: `plugin.json`'s `version`, then the marketplace entry's, then the source commit SHA, then an archive digest, then `unknown`. AEP always sets an explicit `version`, and the suite asserts it matches `specs.md`, so route one always answers.

**`SessionStart` is the strongest hook event for this.** It fires once when a session begins or resumes, and its stdout is *added as context Claude can see and act on* — one of only three events where that is true, alongside `UserPromptSubmit` and `UserPromptExpansion`. It also accepts a structured `hookSpecificOutput.additionalContext` string, delivered *"at the start of the conversation, before the first prompt."* Exit 2 is a non-blocking error whose stderr reaches the user but not Claude, and the session proceeds regardless.

**Exec form is the portable way to spawn it.** With an `args` array present, the command is resolved on `PATH` and spawned directly with no shell. The documentation names the cross-platform pattern outright: *"The `node` plus script-path pattern works on every platform because `node.exe` is a real binary."*

## What is false, and what stays true

The blocked note listed three routes. Re-checked:

| Route | Verdict |
| --- | --- |
| the environment exposes no plugin root to a tool call | **true, and irrelevant.** `env` in a Bash tool call carries no plugin variables; the export is to hook and server subprocesses, not to the agent's shell |
| `claude plugin list` reports nothing for a directory source | **true.** It printed `No plugins installed` while four plugins were loaded. Not a usable read |
| ADR 0060 forbids the protocol pointing into the plugin | **true, and it still binds.** Nothing here changes it |

The third is what shapes the answer. `.claude/protocol.md` is read by a stage as an ordinary file, so a placeholder written into it arrives literally — the substitution applies to what the *plugin* ships, not to what a repository holds. The protocol may therefore declare its own version and nothing more; the comparison has to live in shipped content.

## What this leaves

Two shapes, and the choice is a single-home question rather than a capability one.

**A `SessionStart` hook** puts the comparison in one place. It has both paths without being told them, runs before any stage, costs nothing when the versions match, and needs no instruction in any committed file — which keeps ADR 0060 satisfied without an argument. It would be AEP's first hook.

**An instruction in skill content** needs no new plugin component, and needs the same sentence in every stage that should warn. That is the single-home failure the framework exists to prevent, and the stamped-version variant the blocked note imagined — one fact in seventeen frontmatters — is the same failure with a release script attached. Research removes its only motivation: a stage that can read the manifest never needed the fact copied to it.

## Untested

**The substitution has not been observed in skill content**, only read in the reference. Testing it costs a placeholder in a `SKILL.md`, `/reload-plugins`, and one invocation — worth doing before anything depends on it, because a documented behaviour and an observed one are not the same claim and this repository has been wrong about that distinction before.

**`node` on `PATH` is assumed by the exec-form pattern.** The documentation treats it as universal, and Claude Code is a Node application, but a native-installer environment that keeps its runtime private would break the hook rather than degrade it. Shell form is the fallback and is worse: it resolves to `sh -c` on Unix and to Git Bash *or PowerShell* on Windows, so one script cannot serve both without pinning `shell`.
