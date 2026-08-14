---
owner: repository
kind: research
falsifies: [.claude/tickets/conversion/issues/10-a-stage-s-row-is-assembled-and-delivered-before-its-content.md, .claude/decisions/0089-the-row-is-delivered-the-query-is-filters-and-a-miss-is-a-fact.md]
---

# What the reference settles about preprocessing suppression, the inline ceiling, and hook context

Researched 2026-08-15 against `f1110da`, while building `conversion/10` — the ticket holding
two declared `prototype` increments. **This is documentation, not a run.** Every prototype
finding beside it in the store opens with *Executed … against the running harness*; nothing
here was executed, and the two are not the same kind of evidence. What the reference buys
over a probe is that it is normative and version-current rather than one machine on one day;
what it cannot buy is confirmation that this machine behaves as documented.

Verified against: the Claude Code documentation at `code.claude.com/docs/en`, read
2026-08-15 — the skills page (`#inject-dynamic-context`), the tools reference
(`#output-limits`), and the hooks reference.

Conclusion: **Successful on all three questions**, and one of the answers overturns how the
assembler's failure mode has been framed since ADR 0089.

Consumed: `.claude/tickets/conversion/issues/10-a-stage-s-row-is-assembled-and-delivered-before-its-content.md`,
both entries under "Declared increments".

## 1 — Suppression does not fail the stage; it starts the stage wrong

> To disable this behavior for skills and custom commands from user, project, plugin, or
> additional-directory sources, set `"disableSkillShellExecution": true` in settings. **Each
> command is replaced with `[shell command execution disabled by policy]` instead of being
> run.** Bundled and managed skills are not affected. This setting is most useful in managed
> settings, where users cannot override it.

**The skill still renders.** The command is not run, no exit code is produced, and the
placeholder sits in the substitution's position as ordinary text. So a stage under this
setting starts — holding its own instructions, with one sentence where its entire row should
be.

That is the **guarded** outcome, and ADR 0089 chose against it. The choice does not reach
this branch: failing unguarded protects nothing when nothing runs and there is no status to
fail on. ADR 0089 named this setting as an accepted cost — *"row assembly can be switched off
by a setting AEP does not control"* — but recorded the failure mode as a two-branch fork whose
resolution *"belongs in the assembler's own design"*. **This branch is not in the assembler's
design and cannot be**, which is why the decision is declared falsified here rather than
merely extended.

Two adjacent cases produce literal text in the same position, from the same page: a skill
**synced from a claude.ai account** has its `` !`command` `` lines delivered verbatim rather
than executed, and a **Cowork session** substitutes the same policy placeholder for every one
of them.

**What defends against all three is the row's opening line**, which already names the stage
the row was assembled for. A delivered row not beginning with that header is not a row. The
check belongs to whatever inlines the assembler; the assembler, in these cases, never ran.

## 2 — The tool-result ceiling is the preprocessing ceiling, and no variable raises it

`2026-08-14-whether-a-stage-row-fits-through-preprocessing.md` bracketed the substitution cap
at (10,036, 30,036], later narrowed to (20,036, 30,036], and recorded that the ~30,000
tool-result cap *"does not transfer by assumption"*. **The reference transfers it.** The
skills page states the limit on an injected command's output as the Bash tool's own:

> **Output size**: output past the Bash tool's inline ceiling arrives as a file path plus a
> short preview, not truncated text.

And the tools reference pins that ceiling, for a valid result:

> Inline up to roughly 30,000 characters; past that, the path of a file saved to the session
> directory, truncated past 64 MiB, plus a short preview from the start

> `BASH_MAX_OUTPUT_LENGTH` sets how many characters of output Claude Code reads back from the
> working file into a command's result: 30,000 by default, up to a hard ceiling of 150,000. …
> **It does not raise the inline ceilings above**: a valid result over roughly 30,000
> characters arrives as a file path plus preview regardless of this variable.

So the empirical bracket's **upper bound was right**, the two paths share one ceiling, and
**no environment variable buys a larger substitution**. A failing command inlines only to
roughly 10,000 characters and gets a head-and-tail excerpt with no file path, which is a
second reason not to guard.

**The assembler stays at 20,000 regardless**, and the gap is now deliberate rather than
unpinned. "Roughly" is the reference's own hedge, and the two failures are not comparable:
overshooting costs a row silently replaced by a preview that reads like a row, undershooting
costs one more boundary at roughly 1.6 to 1.75 seconds. The ceiling is recorded as a bound,
not spent.

## 3 — A tool-call hook reaches context, and the boot tier stays where it is

`additionalContext` under `hookSpecificOutput` **does** reach the model, and it is the only
field that does: `systemMessage` reaches the user only, and a hook's plain stdout goes to the
debug log. The events carrying it include `PreToolUse` and `PostToolUse`. Plain stdout is
promoted to context on `UserPromptSubmit`, `UserPromptExpansion`, and `SessionStart` alone.

**So the channel exists, and the boot tier does not move to it.** A tool-call hook fires per
tool call; a boot tier must arrive once, before anything, whether or not a tool is ever
called. The disqualification is **cadence, not capability** — worth recording, because a
future reader finding that tool-call hooks can inject context would otherwise reasonably
wonder why the boot tier does not use them. `SessionStart` stays correct, and
`hooks/check-version.js` already uses it.

## Limitations

- **Nothing was executed.** Suppression in particular is asserted by the reference and unseen
  on this machine; a run would need a settings change and a restart, and has been deferred
  three times for that reason.
- **The placeholder's exact text is quoted from the documentation**, so anything keying on it
  as a string is keying on a documented constant rather than an observed one. The defence in
  §1 deliberately does not key on it — it keys on the row's header being absent.
- **"Roughly 30,000" stays approximate.** The reference hedges, and no run has pinned the
  boundary from above; the empirical bracket still ends at 30,036.
- **One documentation version, read on one day**, against a harness whose behaviour has
  already moved once during this effort.

## Conclusion

**Successful.** Both increments on `conversion/10` are answered, and the ticket is unblocked
without a run.

The finding that matters is §1. The assembler's failure mode has been described as a fork
with two branches and no safe one since ADR 0089, and there is a **third** branch that the
choice between the first two cannot reach, that produces the outcome the choice rejected, and
that a repository's own settings cannot always override. It is stated on the assembler's page
and in the script, and the only thing that detects it is the row header — which is a
*consumer's* check, not the assembler's, and nothing performs it yet.

Not promoted to Context. ADR 0089 declares `falsified-by` naming this file.
