---
owner: repository
kind: prototypes
falsifies: [.claude/tickets/substrate/issues/08-whether-retrieval-actually-beats-an-exact-read.md, .claude/tickets/substrate/map.md]
---

# Does `` !`command` `` preprocessing actually deliver into skill content?

Executed 2026-08-14 against `4c2b085`, on this session's own harness. Resolves the stated
questions of item 1 of `substrate/08`. Code was three — later four — throwaway skills under
`.claude/skills/`, reproduced below and deleted per `/prototype` step 5 once the second run
lands.

Verified against: the running Claude Code harness on Windows 11, 2026-08-14.
Conclusion: **Partially Successful.** The mechanism ADR 0089 rests on is confirmed by
execution for the first time. Three constraints it did not anticipate came with it, and
one planned sub-question still needs a second run.

Consumed: `.claude/tickets/substrate/issues/08-whether-retrieval-actually-beats-an-exact-read.md`,
"Item 1" — substrate/08; and `.claude/tickets/substrate/map.md`, "Not yet specified".

## Hypothesis

ADR 0089 states it without hedging: *"`` !`command` `` preprocessing assembles it and inlines
it before the skill content reaches the model — zero model round trips and no judgement."*
The decision's entire delivery half rests on that sentence, and the research it stands on —
`.claude/evidence/research/2026-08-13-what-a-plugin-hosted-tool-can-actually-do.md` — says
plainly that **nothing was executed**. The expectation was therefore: command output reaches
the model, substituted in place, before the surrounding content; failure and latency
behaviour unknown.

Item 1 asks four things: does the output reach the model, does it run before the content is
read, what happens when the command fails, and what happens when it is slow. It also asks
what `disableSkillShellExecution: true` does, always planned as a second run — testing both
at once cannot distinguish a setting that suppresses execution from a mechanism that never
worked.

## Method

Three skills, isolated so one failure mode could not mask another, each ending by asking for
its body back **verbatim rather than summarised** — a summary cannot distinguish substituted
output from an unsubstituted `` !`…` `` left sitting in the text, which is the failure being
tested for. Each carries static markers around the substitution points, because **the
sentinel's position between them is the evidence** that substitution happened before
delivery rather than after.

As written at session start, and as executed:

```
probe-alpha
  Literal sentinel from a command: !`echo AEP-PROBE-ALPHA-7731`
  Bash-only clock: !`date +%s`
  PowerShell-only clock: !`Get-Date -Format o`
  (between MARKER-BEFORE-7731 and MARKER-AFTER-7731)

probe-beta
  A command that does not exist: !`aep-no-such-command-8842 --please-fail`
  A command that exits non-zero with output on both streams: !`echo OUT-8842; echo ERR-8842 1>&2; exit 3`
  A sentinel AFTER the failures: !`echo AEP-PROBE-BETA-SURVIVED-8842`
  (between MARKER-BEFORE-8842 and MARKER-AFTER-8842)

probe-gamma
  A command that takes about eight seconds: !`sleep 8; echo AEP-PROBE-GAMMA-SLEPT-9153`
  (between MARKER-BEFORE-9153 and MARKER-AFTER-9153)
```

`disableSkillShellExecution` was **not set** in `.claude/settings.json` or
`.claude/settings.local.json`, so these exercise the default.

Invocations: `probe-alpha` twice and `probe-beta` once as user-typed slash commands;
`probe-gamma` once the same way. A fourth skill, `probe-delta`, was written mid-session to
separate two readings of the caching result, and `pwsh` reachability was checked directly
through the `Bash` tool.

## Result

### 1 — The mechanism works, and the position proves the ordering

`probe-gamma` returned its body with the substitution in place:

```
MARKER-BEFORE-9153

A command that takes about eight seconds: AEP-PROBE-GAMMA-SLEPT-9153

MARKER-AFTER-9153
```

The sentinel sits exactly where `` !`sleep 8; echo AEP-PROBE-GAMMA-SLEPT-9153` `` was
written, between both static markers, with no `` !`…` `` text surviving anywhere.
**Preprocessing ran before the content was delivered, the output reached the model, and
nothing around the substitution was dropped.** ADR 0089's delivery half is confirmed by
execution for the first time on this map.

**Eight seconds is inside the tolerance.** No truncation marker, no timeout notice, no error.

### 2 — The shell is bash, on Windows

`probe-alpha` aborted, and the harness's own error text names the interpreter:

```
Error: Shell command failed for pattern "!`Get-Date -Format o`": [stderr]
/usr/bin/bash: line 1: Get-Date: command not found
```

This is direct evidence rather than inference: the harness reports `/usr/bin/bash`. The
error names the *third* pattern, so `` !`echo …` `` and the bash-only `` !`date +%s` ``
before it did not fail. Had the interpreter been PowerShell, `date +%s` would have failed
first.

**Every AEP script in this repository is `.ps1`, and a row assembler invoked through a bash
preprocessor on Windows is a portability constraint nothing on the map had accounted for.**
Checked directly through the `Bash` tool, the constraint is satisfiable:

```
shell: /usr/bin/bash :: 5.3.15(1)-release
pwd: /c/Users/saud-alnasser/Documents/workspace/skills
/c/Program Files/PowerShell/7/pwsh
2026-08-14T01:32:36.2425208+03:00
```

`pwsh` is on `PATH` and runs from bash, so a `.ps1` assembler is reachable as
`pwsh -NoProfile -File …`. It is one more process per invocation and one more thing that
must exist on the machine.

### 3 — A failing command aborts the whole skill, and the model receives nothing

`probe-beta` aborted on its *first* pattern:

```
Error: Shell command failed for pattern "!`aep-no-such-command-8842 --please-fail`": [stderr]
/usr/bin/bash: line 1: aep-no-such-command-8842: command not found
```

**The sentinel after the failures did not arrive, because nothing arrived.** No part of the
body reached the model — not the markers, not the later commands, not the skill's own
instructions. The same happened to `probe-alpha`, three times, on a command sitting *after*
two that had already succeeded.

Against `substrate/08`'s framing this is **not a silent-failure surface — it is fail-closed
and loud**, surfaced to the user as an error naming the exact failing pattern. That is the
better of the two directions: a stage never receives a quietly shortened row.

The cost is the other half. **A failing assembler does not degrade a stage, it removes the
stage entirely** — the skill's own instructions never load, so there is nothing left to
notice the absence and no degraded mode to fall back into. ADR 0088's second face exists for
an unreachable store; it does not cover an assembler that takes its own stage offline.

### 4 — The body is fixed for the session, and an edit does not take

Rewriting `probe-alpha` to guard the failing command and re-invoking it produced the error
quoting the **pre-edit** pattern, `` !`Get-Date -Format o` ``, not the rewritten
`` !`Get-Date -Format o 2>&1 || echo NO-POWERSHELL-7731` ``. The body that executes is the
one from session start.

`probe-delta`, written mid-session, was rejected outright:

```
Unknown skill: probe-delta. Did you mean probe-beta?
```

— reproducing exactly what a prior session saw against `probe-alpha` at the moment it was
written. And re-invoking an already-loaded skill returned *"already loaded above;
instructions unchanged"* rather than re-running anything, so **substitution runs once per
session, not once per invocation.**

Three separate observations, all pointing one way: **`` !`command` `` content is not
hot-swappable within a session.** A changed row assembler, a newly installed stage, and a
re-assembled row all wait for the next session.

## Limitations

- **The prior session's contrary observation is a report, not a re-measurement.** The claim
  on `08` and the map — *the harness fixes its skill listing at session start* — was written
  after `probe-alpha` returned `Unknown skill`, then undercut when the probes appeared in the
  listing later in that same session without a restart. This session cannot re-measure that:
  the probes already existed when it began. What is measured here is narrower and firmer —
  a skill written mid-session is not invocable, and an edited body does not take — while the
  refresh *schedule* remains unmeasured.
- **Caching cannot be attributed precisely.** All three probes had been invoked before they
  were edited, so "fixed at session start" and "fixed at first invocation" are not separated.
  `probe-delta` was meant to separate them and was never listed.
- **Guarded failure was never observed.** Whether stderr text and exit codes are visible to
  the model when a command is guarded is unanswered — every unguarded failure took the body
  with it, and the guarded rewrites could not run.
- **Non-zero exit and missing command are not distinguished.** Both are non-zero exits; that
  a *command exiting 3 with output* aborts identically to one that does not exist was not
  observed.
- **The preprocessor's own working directory and `pwsh` reachability are inferred.** Both
  were measured through the `Bash` tool, whose `/usr/bin/bash` matches the error text but is
  not proven to be the same environment.
- **`disableSkillShellExecution: true` is untested**, as always planned.
- **The latency ceiling is unbracketed** — 8 s passes; where it stops is unknown.
- **The substituted-output size cap is untested.** `probe-gamma` emitted about 30 bytes. The
  cap that `2026-08-14-what-a-stage-sees-when-a-tool-result-exceeds-the-harness-cap.md`
  found on *tool results* does not necessarily apply here, and a row is 45–70 KB.
- **One harness, one version, one operating system.** A fact about the build running on
  2026-08-14, not a guarantee.

## Conclusion

**Partially Successful.** The load-bearing sentence in ADR 0089 is true: preprocessing
delivers, in position, before the content, at zero model round trips, and eight seconds of
latency costs nothing. Six ADRs stood on a research file that had executed nothing; the one
that matters most now stands on a measurement.

The three constraints that came with it are all new to the map, and none of them supersedes
the decision:

**The shell is bash.** A `.ps1` row assembler is reachable through `pwsh -NoProfile -File`,
so this is a constraint on how the assembler is invoked rather than a refutation — but it is
a cross-platform assumption the map had never stated, and ADR 0089 should say which it is.

**Failure is fail-closed and total.** The good news is that a stage cannot receive a
half-assembled row. The bad news is that it receives nothing at all, including its own
instructions, so the failure mode of the delivery path is *stage does not exist* rather than
*stage runs degraded*. That belongs in ADR 0089's accepted costs beside
`disableSkillShellExecution`, which has the same shape and is already named there.

**Nothing is hot-swappable within a session.** The sharpest of the three for how 2.0 ships:
an assembler change, a new stage, and a re-assembled row all take effect at the next session
boundary. The row is assembled once per session and cannot reflect anything that changes
after it.

What is not yet answered is the second run — `disableSkillShellExecution: true`, guarded
failure visibility, and the substituted-output size cap, which is the one that could still
hurt: a row is 45–70 KB and no cap on this path has been measured. **The probes are
therefore kept, not deleted** — `/prototype` step 5 fires when the question is settled, and
this one is not. They are rewritten and waiting for the restart that makes them runnable.

Not promoted. No code outside `.claude/skills/probe-*` was written.
