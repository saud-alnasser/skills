---
owner: repository
kind: research
falsifies: [.claude/tickets/substrate/map.md]
---

# What can a plugin-hosted tool actually do?

Consumed: `.claude/tickets/substrate/map.md`, the second standing finding under "Notes" — substrate/01

Verified against: Claude Code **2.1.231** (local `claude --version`, 2026-08-13);
Claude Code documentation at `code.claude.com/docs/en` — pages `plugins-reference`,
`mcp`, `hooks`, `skills`, `memory`, `context-window`, `permissions`,
`tools-reference` — fetched 2026-08-13; Claude API documentation at
`platform.claude.com/docs/en` — `tool-use/overview`, `tool-use/tool-search-tool`,
`build-with-claude/prompt-caching` — fetched 2026-08-13; Model Context Protocol
specification **2025-06-18**, `server/tools`. AEP at 1.20.0, installed
user-scope from `aep@aep-marketplace`.

Status: six sub-questions answered. Open: whether a plugin can ship an `env` or
permission default (documented field list says no, but the semantics of a
plugin's `settings.json` are documented only as a one-line table row); whether
`hookSpecificOutput.additionalContext` is accepted on `UserPromptSubmit` as well
as `SessionStart`; no behaviour below was executed — every claim is read, not
observed, except the three marked **observed**.

## Answer

A plugin can ship an MCP server and a repository need do nothing to run it, as
long as the plugin is installed at user scope: servers start automatically when
the plugin is enabled. The interesting costs are not where the ticket assumed
they were. **Tool schemas are not charged per turn by default** — Claude Code
defers MCP tool definitions and loads them on demand, so a large schema surface
costs only tool names plus up to 2 KB of server instructions at session start.
**A tool result is charged to context exactly as a file read is**, because in
Claude Code a file read *is* a tool call; the round-trip count is identical, and
the only structural penalty is one extra model turn the first time a deferred
tool is discovered. The real ceilings are on the result: 25,000 tokens by
default, and anything over the persist-to-disk threshold is replaced by a file
reference.

**And the load-bearing one is a yes.** The harness can be made to call a tool
without the model choosing to: an `mcp_tool` hook on `UserPromptSubmit` calls a
named tool on a plugin's own server before Claude processes the prompt, and its
text output is treated as that hook's stdout, which on that event is added as
context Claude can see. The boundary therefore has give in it — but a narrow,
specific give: it fires per **user prompt**, not per assistant turn, and it is
unavailable on `SessionStart`, which typically fires before servers finish
connecting. Everything a norm must do on a turn the user did not start is still
push.

## Findings

### 1 — Getting a plugin-shipped server running, and what failure looks like

- A plugin declares servers in `.mcp.json` at the plugin root or inline in `plugin.json`'s `mcpServers` — *"**Location**: `.mcp.json` in plugin root, or inline in plugin.json"* — [plugins-reference](https://code.claude.com/docs/en/plugins-reference), *MCP servers*.
- *"Plugin MCP servers start automatically when the plugin is enabled"* and *"Servers appear as standard MCP tools in Claude's toolkit"* — [plugins-reference](https://code.claude.com/docs/en/plugins-reference), *MCP servers*, Integration behavior. So for a user-scope install, **the repository does nothing**.
- The repository does something only when the plugin is project-scope, i.e. checked into the tree: *"MCP servers it declares go through the same per-server approval as a project `.mcp.json`"*, and the whole plugin *"loads only after the same trust gate that governs `.claude/settings.json`"*; *"Personal-scope plugins have none of these restrictions."* — [plugins-reference](https://code.claude.com/docs/en/plugins-reference), *Choose where the plugin loads from*.
- A cloned repository cannot approve its own servers: *"`enableAllProjectMcpServers` or `enabledMcpjsonServers` committed to the project's `.claude/settings.json` is ignored in an untrusted folder, and the server stays at `⏸ Pending approval`"* (as of v2.1.196) — [mcp](https://code.claude.com/docs/en/mcp), *Project server approvals and workspace trust*.
- Tool names are scoped: a hook matcher or `if` field takes `mcp__plugin_<plugin-name>_<server-name>__<tool>`, and an `mcp_tool` hook's `server` field takes `plugin:<plugin-name>:<server-name>`; *"A matcher written against the bare server key never fires."* — [plugins-reference](https://code.claude.com/docs/en/plugins-reference), *Hooks*.
- Startup is non-blocking by default: *"Other servers connect in the background by default; set `MCP_CONNECTION_NONBLOCKING=0` to make startup wait for them too."* Startup timeout is configured by `MCP_TIMEOUT`; the connect timeout referenced for `alwaysLoad` is *"the standard 5-second connect timeout"* — [mcp](https://code.claude.com/docs/en/mcp), *Exempt a server from deferral* and Tips.
- **On failure, the session is told.** *"When a configured server fails to connect, Claude Code tells Claude which server failed and its connection error, including in `ToolSearch` results that find no matching tool, so Claude reports the connection failure in its response. Requires tool search, which is enabled by default."* Before v2.1.205 it did not, and *"Claude could respond as if the failed server's tools were never configured."* — [mcp](https://code.claude.com/docs/en/mcp), *Automatic reconnection*.
- The user sees it in `/mcp` and `claude mcp list`: statuses `✔ Connected`, `! Needs authentication`, `✘ Failed to connect`, with the failure detail appended and shown on an `Issue:` line (v2.1.219+) — [mcp](https://code.claude.com/docs/en/mcp), *Server status* and *Server status detail*.
- **A stdio server that dies is not recovered.** Automatic reconnection with backoff applies to HTTP and SSE; *"Stdio servers are local processes and are not reconnected automatically."* — [mcp](https://code.claude.com/docs/en/mcp), *Automatic reconnection*. A plugin-shipped local server is the stdio case.
- **First use prompts.** The `default` permission mode is *"Standard behavior: prompts for permission on first use of each tool"* — [permissions](https://code.claude.com/docs/en/permissions), *Permission modes*. MCP rules take the form `mcp__<server>`, `mcp__<server>__*`, `mcp__<server>__<tool>`, and *"Allow rules accept tool-name globs only after a literal `mcp__<server>__` prefix"* — [permissions](https://code.claude.com/docs/en/permissions), *MCP* and *Tool name wildcards*.
- **A plugin cannot pre-approve its own tool.** Its `settings.json` is *"Default configuration applied when the plugin is enabled. Only the `agent` and `subagentStatusLine` keys are supported"* — [plugins-reference](https://code.claude.com/docs/en/plugins-reference), component locations table. The available escape is skill frontmatter: `allowed-tools` gives *"Tools Claude can use without asking permission during the turn that invokes this skill. The grant clears when you send your next message."* — [skills](https://code.claude.com/docs/en/skills), Frontmatter reference.
- **Observed, local:** AEP 1.20.0 ships no `.mcp.json` — a `find` over `~/.claude/plugins/cache` for `.mcp.json` returned nothing across all four installed plugins, and `claude mcp list` printed `No MCP servers configured.` So none of the above is currently exercised in this installation.
- `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, and `${CLAUDE_PROJECT_DIR}` resolve in a stdio server's `command`, `args`, and `env` — already established in [`2026-08-09-reading-the-plugin-version-from-a-running-stage`](2026-08-09-reading-the-plugin-version-from-a-running-stage.md), re-confirmed in the same table today.

### 2 — What loads before any tool is reachable, and in what order

The `context-window` page publishes the startup sequence as an ordered timeline.
**Its token figures are explicitly representative** — *"The visualization uses
representative numbers"* — so the order is the finding and the numbers are
illustration.

| # | What loads | Illustrative tokens |
| --- | --- | --- |
| 1 | System prompt — *"Always loaded first"*; also carries output style and `--append-system-prompt` | 4,200 |
| 2 | Auto memory `MEMORY.md` — first 200 lines or 25 KB | 680 |
| 3 | Environment info | 280 |
| 4 | **MCP tool names (deferred)** — *"MCP tool names listed so Claude knows what is available"* | 120 |
| 5 | Skill descriptions — *"Full skill content loads only when Claude actually uses one"* | 450 |
| 6 | `~/.claude/CLAUDE.md` | 320 |
| 7 | Project `CLAUDE.md` | 1,800 |
| 8 | The user's prompt | — |

— [context-window](https://code.claude.com/docs/en/context-window), the `EVENTS` timeline and *What the timeline shows*.

- Unconditional rules rank with the project entrypoint: *"Rules without `paths` frontmatter are loaded at launch with the same priority as `.claude/CLAUDE.md`."* — [memory](https://code.claude.com/docs/en/memory), *Set up rules*.
- Path-scoped rules are **not** boot-tier: *"Path-scoped rules trigger when Claude reads files matching the pattern, not on every tool use."* The timeline shows one arriving mid-session after a matching Read — [memory](https://code.claude.com/docs/en/memory), *Path-specific rules*; [context-window](https://code.claude.com/docs/en/context-window).
- The always-on skill cost is capped per skill: *"the combined `description` and `when_to_use` text is truncated at 1,536 characters in the skill listing to reduce context usage"* — [skills](https://code.claude.com/docs/en/skills), Frontmatter reference. A skill with `disable-model-invocation: true` costs nothing at all: *"Skills with `disable-model-invocation: true` are not in this list. They stay completely out of context until you invoke them with `/name`."* — [context-window](https://code.claude.com/docs/en/context-window).
- **There is one push channel that belongs to the server rather than the repository.** With tool search on, *"Only tool names and server instructions load at session start"*, and *"Claude Code truncates tool descriptions and server instructions at 2KB each."* — [mcp](https://code.claude.com/docs/en/mcp), *Scale with MCP tool search* and *For MCP server authors*. That is up to 2 KB of unconditional text a plugin can put in front of the model without any repository file.
- Compaction is not symmetric, and this bounds what may leave the boot tier: project-root `CLAUDE.md` and unscoped rules are *"Re-injected from disk"*; rules with `paths:` are *"Lost until a matching file is read again"*; invoked skill bodies are *"Re-injected, capped at 5,000 tokens per skill and 25,000 tokens total; oldest dropped first"*; and the skill-description listing *"is not re-injected after `/compact`. Only skills you actually invoked get preserved."* — [context-window](https://code.claude.com/docs/en/context-window), *What survives compaction*.
- `CLAUDE.md` is not part of the system prompt: *"CLAUDE.md content is delivered as a user message after the system prompt, not as part of the system prompt itself."* — [memory](https://code.claude.com/docs/en/memory), *Claude isn't following my CLAUDE.md*.

### 3 — What a tool call costs against reading a file of the same size

- **Round trips are equal, because a file read is already a tool call.** `Read` is a built-in tool with permission rules and hook matchers like any other — [tools-reference](https://code.claude.com/docs/en/tools-reference). Every client tool costs one extra model round trip: Claude returns `stop_reason: "tool_use"` with a `tool_use` block, the client executes, *"a second request sends the result back in a `tool_result` block so Claude can reply"* — [tool-use/overview](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview), *How tool use works*.
- **The one asymmetry: discovery.** A deferred MCP tool must be found first — *"Claude uses a search tool to discover relevant ones when a task needs them"* — costing an additional assistant turn containing `server_tool_use` + `tool_search_tool_result` before the real call. It is paid once: *"The API expands `tool_reference` blocks throughout the conversation history, so Claude can reuse discovered tools in later turns without re-searching."* — [tool-search-tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool), *How tool search works*, *Continuing the conversation*.
- **Charged the same way.** Additional tool-use tokens come from *"The `tools` parameter in API requests… `tool_use` content blocks in API requests and responses… `tool_result` content blocks in API requests"* — [tool-use/overview](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview), *Pricing*. A `tool_result` carrying 3 KB of records and a `Read` result carrying 3 KB of file are the same kind of block in the same position.
- **Results are cached across turns, at 10% of input price, not free.** Conversation history grows the cached prefix each turn, and *"Tool results and thinking blocks are cached as part of assistant turns when passed back in subsequent requests"*; cache reads cost 0.1× base input — [prompt-caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching). **Caching is a price mechanism, not a context mechanism**: a cached tool result still occupies its full share of the context window on every subsequent turn.
- Cache TTL defaults to 5 minutes, *"measured from the start of the request that writes or reads the cache entry, not from the end of its response"* — [prompt-caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching). An idle session loses the prefix and re-pays a write.
- **Result ceilings differ, and this is where the two diverge.** MCP output warns above 10,000 tokens and is capped at 25,000 by default via `MAX_MCP_OUTPUT_TOKENS`; *"results that exceed the default threshold are persisted to disk and replaced with a file reference in the conversation"*, and a server may raise its own tool's threshold with `_meta["anthropic/maxResultSizeChars"]` *"up to a hard ceiling of 500,000 characters"* — [mcp](https://code.claude.com/docs/en/mcp), *MCP output limits and warnings*. By comparison `Read` returns a `PARTIAL view` notice with `offset`/`limit` guidance when a whole-file read exceeds its token limit (the reference does not quantify that limit) — [tools-reference](https://code.claude.com/docs/en/tools-reference), *Read tool behavior*; and Bash returns inline *"up to roughly 30,000 characters"* before spilling to a file path.
- Latency bounds: a per-server `timeout` is *"a hard wall-clock limit per tool call"*; an idle window aborts a silent call, defaulting to 30 minutes for stdio; and *"An MCP tool call in the main conversation that is still running after two minutes moves to a background task instead of blocking the session"* (v2.1.212+), which does **not** apply to subagent calls — [mcp](https://code.claude.com/docs/en/mcp), Tips, *Automatic backgrounding of long tool calls*.

### 4 — Whether tool schemas are charged per turn

- **In principle yes, in Claude Code's default configuration no.** Tool definitions sit in the `tools` parameter and are billed as input tokens on every request; the tool-use system prompt adds a fixed overhead — for **Claude Opus 5**, 286 tokens at `tool_choice` `auto`/`none` and 406 at `any`/`tool` — [tool-use/overview](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview), *Pricing*.
- But *"Tool search is enabled by default. MCP tools are deferred rather than loaded into context upfront… Only the tools Claude actually uses enter context."* — [mcp](https://code.claude.com/docs/en/mcp), *How it works*. And *"Claude Code doesn't impose a fixed per-server tool cap; the practical limit is your context window budget."*
- The mechanism preserves caching, which matters because tools are the outermost cache level: *"Internally, the API excludes deferred tools from the system-prompt prefix. When Claude discovers a deferred tool through tool search, the API appends a `tool_reference` block inline in the conversation… The prefix is untouched, so prompt caching is preserved."* — [tool-search-tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool), *Deferred tool loading*.
- Without deferral the cost is real. Anthropic's own figure: *"A typical multiserver setup (GitHub, Slack, Sentry, Grafana, and Splunk) can consume ~55k tokens in definitions before Claude does any work."* And selection degrades: *"Claude's ability to pick the right tool degrades once you exceed 30–50 available tools."* — [tool-search-tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool).
- **Changing the tool surface invalidates the entire cache.** Cache prefixes are built `tools` → `system` → `messages`, and a change to tool definitions invalidates all three — [prompt-caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching). Claude Code supports MCP `list_changed`, so a server that varies its tool list mid-session pays for it — [mcp](https://code.claude.com/docs/en/mcp), *Dynamic tool updates*.
- **Deferral is defeatable in both directions.** Per server: *"If a server's tools should always be visible to Claude without a search step, set `alwaysLoad` to `true`… Every tool from that server then loads into context at session start"*, and *"Setting `alwaysLoad: true` also makes startup wait for the server's tools, capped at the standard 5-second connect timeout."* Per tool: `"anthropic/alwaysLoad": true` in the tool's `_meta`. Globally: `ENABLE_TOOL_SEARCH=false` loads everything upfront, `auto` uses a 10%-of-window threshold — [mcp](https://code.claude.com/docs/en/mcp), *Exempt a server from deferral*, *Configure tool search*.
- Tool search is **not universal**: it is off when `ANTHROPIC_BASE_URL` points at a non-first-party host, off under `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS`, rejected server-side on Microsoft Foundry deployments hosted on Azure, and unavailable on pre-4.5-generation models — [mcp](https://code.claude.com/docs/en/mcp), *Configure tool search*. **A design that relies on deferral for its context budget has a configuration in which that budget is not there.**

### 5 — What a tool may return

- The protocol allows a `content` array mixing text, image, audio, `resource_link`, and embedded resource blocks, plus a separate `structuredContent` JSON object, an optional `outputSchema` the server **MUST** conform to, and `isError` for execution failures distinct from JSON-RPC protocol errors — [MCP specification 2025-06-18, `server/tools`](https://modelcontextprotocol.io/specification/2025-06-18/server/tools), *Tool Result*, *Error Handling*.
- **The specification sets no size limit on a result.** Its only bounds are `tools/list` pagination via `cursor`/`nextCursor` and the `listChanged` notification — same page, *Protocol Messages*. Every size limit that exists is Claude Code's, listed in §3.
- **There is no result streaming.** A result is one `tools/call` response. The observable partial-progress mechanism in Claude Code is progress notifications, and their role is negative: *"A tool call to an MCP server that sends no response and no progress notification for the idle window aborts"*, while *"progress notifications from the server don't extend"* the wall-clock timeout — [mcp](https://code.claude.com/docs/en/mcp), Tips. **A tool cannot deliver a corpus incrementally; it delivers once, whole, under the cap.**
- Claude Code rewrites an input schema with a root-level `anyOf`/`oneOf`/`allOf` into a flat object with a prepended description sentence (v2.1.195+), and skips that one tool where it cannot — [mcp](https://code.claude.com/docs/en/mcp), *Tool input schemas with a root-level combinator*.
- **Descriptions and server instructions are hard-truncated at 2 KB each** — [mcp](https://code.claude.com/docs/en/mcp), *For MCP server authors*. That is the ceiling on any always-on framing a served corpus can carry.

### 6 — Whether the harness can call a tool without the model choosing to

**Yes — five mechanisms, in descending order of how close they come to "a tool
call the model did not choose".**

1. **An `mcp_tool` hook.** A hook handler of `type: "mcp_tool"` names a `server`, a `tool`, and an `input`, where *"String values support `${path}` substitution from the hook's JSON input"*. For a plugin-bundled server the `server` field is `plugin:<plugin-name>:<server-name>`, and *"The server must already be connected; the hook never triggers an OAuth or connection flow."* Its output is handled as stdout: *"The tool's text content is treated like command-hook stdout: if it parses as valid JSON output it is processed as a decision, otherwise it is treated as plain stdout."* Combined with the exit-0 rule — *"The exceptions are `UserPromptSubmit`, `UserPromptExpansion`, and `SessionStart`, where stdout is added as context that Claude can see and act on"* — a plugin can make a tool call and put its result in front of the model on every user prompt. — [hooks](https://code.claude.com/docs/en/hooks), *MCP tool hook fields*, *Hook handler fields*, exit codes.
   - **Limits that make this narrow.** *"`SessionStart` and `Setup` typically fire before servers finish connecting, so hooks on those events should expect the 'not connected' error on first run."* A failure is soft: *"If the named server is not connected, or the tool returns `isError: true`, the hook produces a non-blocking error and execution continues."* The default `timeout` on `UserPromptSubmit` drops to 30 seconds. And the event fires **when a user submits a prompt** — there is no equivalent that adds context before each assistant turn within a turn-loop.
2. **A `command` hook on `SessionStart` or `UserPromptSubmit`.** Not a tool call, but the same injection point, and it does not depend on a server being connected. `${CLAUDE_PLUGIN_ROOT}` resolves in hook commands, and the three plugin variables are exported to the hook process — [plugins-reference](https://code.claude.com/docs/en/plugins-reference), *Environment variables*; `SessionStart`'s `hookSpecificOutput.additionalContext` was established in [`2026-08-09-reading-the-plugin-version-from-a-running-stage`](2026-08-09-reading-the-plugin-version-from-a-running-stage.md).
3. **`!`command`` in skill content.** *"The `` !`<command>` `` syntax runs shell commands before the skill content is sent to Claude. The command output replaces the placeholder… This is preprocessing, not something Claude executes. Claude only sees the final result."* Deterministic once the skill is invoked; substitution runs once and output is not re-scanned. Disabled wholesale by `"disableSkillShellExecution": true` in settings, which replaces each command with a placeholder — [skills](https://code.claude.com/docs/en/skills), *Inject dynamic context*. **This is the closest thing to pull-with-guaranteed-delivery: a stage skill can fetch its records at invoke time without the model deciding to.**
4. **Server instructions.** Up to 2 KB pushed at session start, per §2.
5. **Channels.** *"An MCP server can also push messages directly into your session so Claude can react to external events… your server declares the `claude/channel` capability and you opt it in with the `--channels` flag at startup."* — [mcp](https://code.claude.com/docs/en/mcp), *Push messages with channels*. Requires a startup flag, so it is not something a plugin can arrange alone.

## What was looked for and not found

Recording these so the next investigation does not spend a window on them.

- **No way to force `tool_choice` from Claude Code.** The API supports forcing a tool call (`tool_choice` of `any`/`tool`, priced in the overhead table), but nothing in `settings`, `env-vars` as cited from the pages read, `skills`, or `mcp` exposes it. Searched `permissions`, `skills`, `mcp`, `hooks`, `plugins-reference`. **The forcing mechanism available to a plugin is the hook, not the model parameter.**
- **No hook event whose stdout reaches the model on an assistant turn.** `PostToolBatch` fires *"After a full batch of parallel tool calls resolves, before the next model call"*, which is the right moment — but it is not in the three-event exception list, so its stdout goes to the debug log. An `mcp_tool` hook there can act; it cannot speak.
- **No documented plugin-shipped permission or `env` default.** A plugin's `settings.json` supports only `agent` and `subagentStatusLine`. A plugin therefore cannot ship an allow rule for its own tool, nor raise `MAX_MCP_OUTPUT_TOKENS` for itself.
- **No documented number for the `Read` tool's token limit**, nor for the MCP persist-to-disk default threshold; both are described only relative to themselves.
- **No `alwaysLoad` equivalent for skills.** A skill's body cannot be made always-on; only its ≤1,536-character description is.

## What this falsifies

`.claude/tickets/substrate/map.md`, *Notes*, second standing finding:

> **A tool is pull; the boot tier is push.** The harness loads the entrypoint and
> unconditional rules before any protocol logic runs, so a norm that must fire
> unconditionally can never sit behind a tool call — the router-skill failure
> `specs.md` §5 rejects, one layer down.

The first clause and the load-order claim are confirmed exactly (§2). **The
"never" is false as written**: an `mcp_tool` hook on `UserPromptSubmit` places a
tool call ahead of the model's decision and its result in the model's context,
so a norm that must fire on every user prompt *can* sit behind a tool call. What
survives is a weaker and still useful statement — a norm that must fire on a
turn the user did not start, or before servers have connected, cannot. Healing
belongs to whoever owns the map; this file only records the contradiction.

## Limitations

- **Nothing here was executed.** No MCP server was written, started, or failed on purpose; no hook was fired. Every claim except the three marked **observed** is documentation read on 2026-08-13, and this repository has been wrong before about the gap between a documented behaviour and an observed one — recorded as such in the 2026-08-09 finding's *Untested* section. The cheap confirmations, in order of what they would de-risk: an `mcp_tool` hook on `UserPromptSubmit` actually reaching context; the deferred-schema startup cost as `/context` reports it; a >25,000-token result becoming a file reference.
- **The startup token figures are the documentation's own illustration**, labelled as representative. Only the *order* should be treated as a fact.
- **Version-bound and moving fast.** Fourteen distinct behaviours cited above carry a "before v2.1.NNN" clause, several within twenty patch versions of the 2.1.231 installed here. Tool search in particular is described as beta-gated (`CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS` disables it and `ENABLE_TOOL_SEARCH` cannot override that), so §4's answer is the least durable thing in this file. Re-verify §4 and §6 before either is built on.
- **The MCP specification pinned here is 2025-06-18**, the version the fetched specification page serves; Claude Code's client behaviour was read from Anthropic's pages rather than inferred from the specification, and where the two speak to the same thing — result size, streaming — Claude Code's limits are the binding ones.
- **Not investigated:** LSP servers as a delivery route; `workflows`; background `monitors`; the Agent SDK's `mcpSetServers`; `MCP_DISCOVERY_CACHE` and the `cached` server status, which applies only to remote servers and so not to a stdio server a plugin would ship; and what `roots/list` gives a server about the session's working directories.
