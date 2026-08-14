---
owner: repository
kind: prototypes
falsifies: [.claude/tickets/substrate/issues/08-whether-retrieval-actually-beats-an-exact-read.md, .claude/tickets/substrate/map.md]
---

# What reaches a stage when a preprocessing command fails, and what carries across a session boundary?

Executed 2026-08-14 against `4c2b085`, on this session's own harness — the **second run** of
item 1 of `substrate/08`, in the fresh session that
[`does-backtick-bang-preprocessing-actually-deliver`](2026-08-14-does-backtick-bang-preprocessing-actually-deliver.md)
ended by asking for. That write-up's account is frozen (`.claude/policies/evidence.md`,
"Declared fields, and the one index"), so this is a separate file rather than an amendment to
it; read the two together.

Verified against: the running Claude Code harness on Windows 11, 2026-08-14.
Conclusion: **Successful**, and it turns round 1's one piece of good news into the sharpest
finding on this item — **guarding a failing command converts a loud failure into a silent
one.**

Consumed: `.claude/tickets/substrate/issues/08-whether-retrieval-actually-beats-an-exact-read.md`,
"Item 1" — substrate/08; and `.claude/tickets/substrate/map.md`, "Not yet specified".

## Hypothesis

Round 1 confirmed ADR 0089's load-bearing sentence — preprocessing delivers, in position,
before the content — and closed with five things it could not settle. Three of them are the
questions this run was written for, and all three were unanswerable in round 1 for the same
reason: **every unguarded failure took the whole body with it**, so nothing about a
*surviving* failure could be observed.

1. **Is stderr text visible to the model, and is the exit code?** Round 1: *"Guarded failure
   was never observed."*
2. **Does a command that exists and exits non-zero abort the same way as one that does not
   exist?** Round 1: *"Non-zero exit and missing command are not distinguished."*
3. **Does a skill written mid-session, and a body edited mid-session, take effect at the next
   session?** Round 1 measured only the negative halves — `Unknown skill: probe-delta`, and an
   error quoting the pre-edit pattern.

The expectation, from round 1's fail-closed result, was that guarding would make failure
survivable and therefore **safe**. That expectation is what this run overturns.

## Method

The four probes from round 1, rewritten between sessions and invoked as user-typed slash
commands in this session, in the order `probe-alpha`, `probe-beta`, `probe-gamma`,
`probe-delta`. Each still ends by asking for its body back **verbatim rather than summarised**,
and each still carries static markers around the substitution points, because the sentinel's
position between them is the evidence that substitution happened before delivery.

The rewrite splits guarded from unguarded deliberately, so that one cannot mask the other:

```
probe-alpha  (all six guarded)
  Literal sentinel:      !`echo AEP-PROBE-ALPHA-7731`
  Bash-only clock:       !`date +%s 2>&1 || echo NO-BASH-DATE-7731`
  PowerShell direct:     !`Get-Date -Format o 2>&1 || echo NO-POWERSHELL-7731`
  PowerShell via pwsh:   !`pwsh -NoProfile -Command "Get-Date -Format o" 2>&1 || echo NO-PWSH-ON-PATH-7731`
  Preprocessor cwd:      !`pwd 2>&1 || echo NO-PWD-7731`
  Interpreter identity:  !`echo "$0 :: ${BASH_VERSION:-NO-BASH-VERSION-7731}"`
  (between MARKER-BEFORE-7731 and MARKER-AFTER-7731)

probe-beta  (guarded failures, each reporting its own exit code)
  Nonexistent command:   !`aep-no-such-command-8842 --please-fail 2>&1; echo "EXIT=$?"`
  Exit 3, both streams:  !`(echo OUT-8842; echo ERR-8842 1>&2; exit 3) 2>&1; echo "EXIT=$?"`
  Stderr alone:          !`echo ONLY-ERR-8842 1>&2; echo "EXIT=$?"`
  Sentinel after:        !`echo AEP-PROBE-BETA-SURVIVED-8842`
  (between MARKER-BEFORE-8842 and MARKER-AFTER-8842)

probe-gamma  (unguarded — a command that exists and exits 3)
  Exit 3, both streams:  !`echo OUT-9153; echo ERR-9153 1>&2; exit 3`
  Sentinel after:        !`echo AEP-PROBE-GAMMA-SURVIVED-9153`
  (between MARKER-BEFORE-9153 and MARKER-AFTER-9153)

probe-delta  (alpha's six, plus one guarded failure — the mid-session-written skill)
  ... as alpha, then:
  Nonexistent, guarded:  !`aep-no-such-command-4460 --please-fail 2>&1; echo "EXIT=$?"`
  Sentinel after:        !`echo AEP-PROBE-DELTA-SURVIVED-4460`
  (between MARKER-BEFORE-4460 and MARKER-AFTER-4460)
```

`probe-gamma` gave up round 1's sleep-8 latency test to take the unguarded-non-zero case;
round 1's 8-second result therefore stands unre-measured, and no new latency data was taken.

`disableSkillShellExecution` was again **not set** in `.claude/settings.json` or
`.claude/settings.local.json`, confirmed by reading both this session, so this run still
exercises the default.

## Result

### 1 — Delivery reconfirmed, and the environment measured from inside the preprocessor

`probe-alpha` returned its whole body with all six substitutions in place, between both
markers, with no `` !`…` `` text surviving:

```
Literal sentinel from a command: AEP-PROBE-ALPHA-7731

Bash-only clock: 1786660459

PowerShell-only clock, direct: /usr/bin/bash: line 1: Get-Date: command not found
NO-POWERSHELL-7731

PowerShell reached through pwsh: 2026-08-14T01:34:24.8749774+03:00

Working directory of the preprocessor: /c/Users/saud-alnasser/Documents/workspace/skills

Interpreter identity: /usr/bin/bash :: 5.3.15(1)-release
```

Round 1 inferred the interpreter from the harness's error text and measured `pwsh`
reachability and the working directory through the `Bash` tool — a different environment it
could not prove was the same one. **All three are now measured from inside the preprocessor
itself**, and they agree: bash 5.3.15 at `/usr/bin/bash`, cwd at the repository root,
`Get-Date` absent, and `pwsh -NoProfile -Command` returning an ISO timestamp. Round 1's
inference was right, and a `.ps1` row assembler is reachable as
`pwsh -NoProfile -File …` — one extra process per invocation, and one more thing that must
exist on the machine.

The harness also prepends a line the probes did not write:

```
Base directory for this skill: C:\Users\saud-alnasser\Documents\workspace\skills\.claude\skills\probe-alpha
```

**That path is Windows-shaped while the preprocessor's own `pwd` is MSYS-shaped** — an
assembler that composes the two gets `C:\…` and `/c/…` in one command line.

### 2 — Guarded failure survives, and arrives as data indistinguishable from data

`probe-beta` delivered its entire body. `AEP-PROBE-BETA-SURVIVED-8842` and
`MARKER-AFTER-8842` both arrived:

```
A command that does not exist, guarded: /usr/bin/bash: line 1: aep-no-such-command-8842: command not found
EXIT=127

A command exiting non-zero with output on both streams, guarded: OUT-8842
ERR-8842
EXIT=3

Stderr alone, guarded: ONLY-ERR-8842
EXIT=0

A sentinel AFTER the failures: AEP-PROBE-BETA-SURVIVED-8842
```

Three facts, in order of how much they cost:

**Stderr is inlined whether or not it is redirected.** The third command carries no `2>&1` —
`` !`echo ONLY-ERR-8842 1>&2; echo "EXIT=$?"` `` — and `ONLY-ERR-8842` arrived anyway, ahead
of the stdout line. The preprocessor merges both streams into the substituted text. Nothing
in the delivered row marks which stream a line came from.

**The exit code is not delivered.** `EXIT=127`, `EXIT=3` and `EXIT=0` are visible only
because the probe echoed them itself. And the third line shows the trap in doing that: the
guard's own `$?` is `0` while the failing command's is lost, so an assembler that reports its
exit code can report success over an error it just printed.

**Therefore a guarded assembler is a silent-failure surface.** A stage receiving
`/usr/bin/bash: line 1: …: command not found` in the middle of its row has no way to tell it
from a norm — it is prose in the right position, and round 1's protection (the harness
raising an error naming the failing pattern) does not fire, because as far as the harness is
concerned nothing failed. This inverts round 1's reading. Fail-closed is not a property of
the mechanism; **it is a property of leaving the command unguarded**, and the obvious fix for
"a failing assembler takes the stage offline" is exactly what removes it.

### 3 — An existing command exiting non-zero aborts identically to one that does not exist

`probe-gamma` produced **no body at all** — not the markers, not the sentinel after, not its
own instructions. What reached the session was the harness's error alone:

```
Error: Shell command failed for pattern "!`echo OUT-9153; echo ERR-9153 1>&2; exit 3`": [stderr]
OUT-9153
ERR-9153
```

Round 1 could not distinguish *command not found* from *command ran and exited non-zero*.
They are the same: **the abort is on the exit status, not on the command's existence**, and it
is total. Note also that the harness labels the captured text `[stderr]` while `OUT-9153` was
written to stdout — the same stream-merging seen in §2, here mislabelled in the error report.

### 4 — The session boundary carries both a new skill and an edited body

`probe-delta` was written mid-session in the previous session and rejected then with
`Unknown skill: probe-delta`. In this session it ran, and it ran its **current** body — the
guarded rewrite, including the `probe-delta`-numbered sentinels that did not exist when it
was first attempted:

```
Literal sentinel from a command: AEP-PROBE-DELTA-4460
...
A nonexistent command, guarded: /usr/bin/bash: line 1: aep-no-such-command-4460: command not found
EXIT=127

A sentinel AFTER the failure: AEP-PROBE-DELTA-SURVIVED-4460
```

All four probes ran rewritten bodies this session, `probe-gamma`'s rewrite included — round 1
observed only that an edit does *not* take within the session it was made. **Both halves are
now measured: a new skill and an edited body take effect at the next session boundary, and
not before.**

### 5 — Substitution runs at invoke time, which corrects an inference in round 1

Round 1 concluded *"substitution runs once per session, not once per invocation"*, reasoning
from a re-invocation that returned "already loaded above; instructions unchanged". The clocks
here separate the two claims:

| Probe | `date +%s` | `pwsh` ISO timestamp |
| --- | --- | --- |
| `probe-alpha`, invoked first | `1786660459` | `2026-08-14T01:34:24.8749774+03:00` |
| `probe-delta`, invoked fourth | `1786660504` | `2026-08-14T01:35:09.1380718+03:00` |

45 seconds apart on both clocks, matching the wall-clock gap between the two invocations.
**The commands execute when the skill is invoked, not when the session starts.** What round 1
observed on re-invocation is the harness declining to re-deliver an already-loaded skill,
which is a caching fact about delivery rather than about substitution. For 2.0 this is the
better of the two: a row is assembled at the moment its stage is entered, so it reflects the
store as of that moment — bounded only by §4, which fixes the assembler *script* at the
session boundary.

## Limitations

- **The substituted-output size cap is still untested**, and it remains the one that could
  still hurt: a stage row is 45,445–69,563 characters (item 6), and the largest payload any
  probe has ever put through this path is about 60 bytes. The ~30,000-character cap that
  `2026-08-14-what-a-stage-sees-when-a-tool-result-exceeds-the-harness-cap.md` found on
  *tool results* is a different path and does not transfer by assumption.
- **`disableSkillShellExecution: true` is still untested**, as planned since round 1. It needs
  a settings change and a further restart.
- **No new latency data.** `probe-gamma` was re-aimed at the unguarded-exit case, so round 1's
  single 8-second observation is all there is and the ceiling stays unbracketed.
- **Re-invocation within a session was not re-run**, so §5 separates *when commands execute*
  from *whether delivery is cached*, but does not measure what a second invocation of the same
  skill in the same session would substitute.
- **Only bash-visible failure modes were exercised** — a missing command and non-zero exits. A
  command that hangs, one killed by a signal, and one writing megabytes were not.
- **One harness, one version, one operating system**, on one repository's `.claude/skills/`.
  The plugin-hosted case — a skill shipped in a marketplace plugin rather than sitting in the
  repository — was not tested, and that is how AEP actually ships.

## Conclusion

**Successful.** Every question this run was written for is answered, and the three that round
1 left open are closed: stderr is visible and the exit code is not, a non-zero exit aborts
exactly as a missing command does, and both a new skill and an edited body take effect at the
next session boundary.

The finding that matters is the one nobody asked for. Round 1 recorded fail-closed-and-total
as *"the better of the two directions: a stage never receives a quietly shortened row."* That
reading holds only while assembler commands are unguarded. **Guarded, the row is delivered
with the error text sitting in it as prose, in position, with the harness reporting nothing** —
and `substrate/08` was re-aimed specifically to hunt silent-failure surfaces. The two
behaviours are not a spectrum with a safe middle; they are a fork the assembler's author takes
by writing or omitting `2>&1`, and the safer-looking branch is the unsafe one.

Nothing here supersedes ADR 0089. Its delivery half stands, better measured than before, and
gains a fourth accepted cost beside the three already named. What is not settled is the size
cap — untested twice now, and the only remaining result that could still take the delivery
half down. **The probes are kept for a third run** on that and on
`disableSkillShellExecution: true`; `/prototype` step 5 fires when the question is settled, and
one sub-question of item 1 is not.

Not promoted. No code outside `.claude/skills/probe-*` was written.
