# Where a skill or agent may carry AEP's own fields

Date: 2026-08-05
Filed by: `/design`, resolving the gated assumption in the declared-fields effort — whether AEP may add its own keys to the frontmatter of what it ships.

The question was load-bearing: the design moves `Mode:` and `Policies:` out of skill bodies and into frontmatter so `.claude/protocol.md`'s stage table can be generated from them. If the harness rejects an unlisted key, the fields have nowhere to go and the design changes shape.

## Skills: there is a sanctioned namespace, and a bare key is not it

Claude Code's skills reference enumerates every accepted `SKILL.md` frontmatter field and states the closed-set rule directly — *"Claude Code accepts every field in the table above"* ([skills reference, "Using skill frontmatter outside Claude Code"](https://code.claude.com/docs/en/skills)). The table has nineteen rows; `mode` and `policies` are not among them.

One row is the extension point ([same table, `metadata`](https://code.claude.com/docs/en/skills)):

> `metadata` — Free-form YAML map for your own key-value data, such as entitlement or catalog fields, read by your own tooling from `SKILL.md`. Claude Code doesn't act on its contents, and drops a value that isn't a map. Don't reuse frontmatter field names such as `paths` as keys.

Three consequences, all from that sentence. Custom data has a documented home, so AEP needs no undocumented behaviour. The map must be a map — a scalar is dropped silently, which is the failure mode an assertion has to catch rather than a reader. And the key names inside it must avoid the nineteen reserved names, `paths` above all — which this repository uses for a different purpose in `.claude/rules/`, so the collision is live rather than theoretical.

Two rows adjacent to it show the same pattern for spec-defined fields Claude Code tolerates without acting on: `license` and `compatibility` are *"accepted"* but the harness *"doesn't act on"* them ([same table](https://code.claude.com/docs/en/skills)).

## Agents: no such namespace is documented, and AEP already relies on that gap

The subagent reference lists sixteen fields — `name`, `description`, `tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `effort`, `isolation`, `color`, `initialPrompt` ([subagents reference, frontmatter table](https://code.claude.com/docs/en/sub-agents)). There is **no `metadata` row and no `mode` row**, and the page makes no statement about unknown keys in either direction.

All five files in `agents/` carry `mode:` at the top level of their frontmatter today. Nothing observably breaks — the agents load and their `tools` lists are honoured — so the key is tolerated in practice at the version in use. But it is tolerated, not documented: **AEP currently depends on undocumented harness behaviour for the one fact its orchestration reads off an agent.** That is the finding this run did not expect, and it is true whether or not the declared-fields design ships.

## What this does not say

Nothing here says the harness *rejects* an unlisted top-level key on a skill; the docs state which fields are accepted, not what becomes of the rest. Establishing rejection would take an experiment against a specific version, and the design does not need one — `metadata` removes the question for skills entirely. For agents the question stays open, and the design has to choose whether to keep depending on the gap or route around it.

Versions: read 2026-08-05 against the live documentation, which names Claude Code v2.1.218 as current for the newest fields it describes. A finding about a product's accepted-field table is true of the version that published it.
