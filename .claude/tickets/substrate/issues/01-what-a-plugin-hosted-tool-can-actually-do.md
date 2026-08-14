---
owner: repository
title: "docs(evidence): establish what a plugin-hosted tool can actually do"
status: resolved
blocked-by: []
part-of: substrate
type: research
---

## Question

What are the real capabilities and costs of serving AEP's corpus to the model
through a tool a Claude Code plugin ships?

Every other decision on this map rests on the answer, and none of it is
established in this repository today. Against primary sources — Anthropic's
plugin and MCP documentation, the harness's own behaviour — settle:

- Can a plugin ship an MCP server, and what does a repository have to do to get
  it running? What happens in a session where it fails to start?
- What loads before any tool is reachable, and in what order — entrypoint,
  rules, skills, tool schemas. This bounds what may ever leave the boot tier.
- What a tool call costs against reading a file of the same size: round trips,
  latency, whether results are cached across turns within a session, and
  whether a tool result is charged to context the same way a file read is.
- Whether tool schemas themselves are charged per turn, and what a large schema
  surface costs before a single call is made.
- What a tool may return — size limits, structure, whether it can stream — and
  whether the harness can be made to call one without the model choosing to.

The last is the one that decides whether the push/pull boundary in `05` has any
give in it at all.

## Answer

`.claude/evidence/research/2026-08-13-what-a-plugin-hosted-tool-can-actually-do.md`,
verified against Claude Code 2.1.231 and the documentation fetched 2026-08-13.

**The boundary has give, and it is narrow.** An `mcp_tool` hook on
`UserPromptSubmit` calls a named tool on a plugin's own server before Claude
processes the prompt, and its text output is added as context — so a norm firing
on every user prompt *can* sit behind a tool call. It cannot on a turn the user
did not start, and `SessionStart` and `Setup` typically fire before servers
connect. Separately, `` !`command` `` preprocessing in skill content runs before
the skill reaches Claude, which is the closest thing to pull with guaranteed
delivery: **a stage skill can fetch its records at invoke time without the model
deciding to.** That bears directly on `04`.

**The costs are not where this ticket assumed.** A tool result is charged to
context exactly as a file read is, because in Claude Code a file read *is* a tool
call, so round trips are equal; the only structural penalty is one extra turn the
first time a deferred tool is discovered, paid once. Schemas are not charged per
turn by default — MCP tools are deferred, costing tool names plus up to 2 KB of
server instructions at session start — though deferral is absent under some
configurations, so a budget resting on it is conditional. Results cap at 25,000
tokens and spill to a file reference above the persist threshold; there is no
streaming.

**Three operational facts that constrain the design rather than inform it.** A
plugin cannot ship an allow rule for its own tool — its `settings.json` supports
only `agent` and `subagentStatusLine` — so first use prompts unless a stage
skill's `allowed-tools` grants it. A stdio server that dies is **not**
reconnected, which is the shape a plugin-shipped local server takes. And
path-scoped rules are lost across compaction until a matching file is read again,
where the entrypoint and unscoped rules are re-injected — which bears on `05`.

**This falsified the map's standing note** that a norm firing unconditionally can
never sit behind a tool call; the note was narrowed in the same change, and the
finding carries its consumption line.

**Held against it:** nothing was executed. Every claim is documentation read on
2026-08-13, and the finding names §4 and §6 as its least durable sections and
lists the three cheapest confirmations. `08` is where they get paid for.
