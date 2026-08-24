---

---

# Question

Through which native mechanisms do OpenCode and T3 Code load agent-facing
instructions, skills, and roles — and what would an adapter have to write for
each to reach AEP the way the Claude adapter does?

# Sources

Primary, read 2026-08-18 via the GitHub API:

- `anomalyco/opencode` @ `dev` — `packages/core/src/plugin/skill/customize-opencode.md`
  (a first-party customization reference that ships as a built-in skill),
  `packages/opencode/src/skill/index.ts`, `packages/opencode/src/command/index.ts`,
  and the repository's own `.opencode/` directory.
- `pingdotgg/t3code` @ `main` — `apps/server/src/provider/Drivers/ClaudeSkills.ts`,
  `docs/user/providers-claude.md`, `docs/user/`, `README.md`.

Secondary, read 2026-08-18:

- `opencode.ai/docs/{rules,agents,commands,skills}` — vendor documentation. Where
  it disagreed with the source, the source was taken.
- `code.claude.com/docs/en/skills` — Claude Code's discovery paths, for contrast.

# Findings

**source** — OpenCode reads `AGENTS.md` from the project root walking up, with
`CLAUDE.md` as a fallback, and `opencode.json`'s `instructions` array for extra
files (`opencode.ai/docs/rules`, and the `instructions` field in
`customize-opencode.md`).

*interpretation* — AEP's entrypoint seed already lands the file OpenCode reads.
Nothing about the entrypoint has to change for OpenCode.

**source** — OpenCode's skill loader (`packages/opencode/src/skill/index.ts:21-24`,
`:187-201`) scans, at project scope walking from the cwd up to the worktree root:
`.claude/skills/**/SKILL.md` (unless Claude-Code compatibility is disabled by
flag) and `.agents/skills/**/SKILL.md`; and, from each config directory,
`{skill,skills}/**/SKILL.md`. Global scope adds `~/.claude/skills`,
`~/.agents/skills`, and `~/.config/opencode/skill(s)`.

*interpretation* — a repository-shape Claude adapter at `.claude/skills/` is
already discovered by OpenCode today, but only while the compatibility flag is
left on. An OpenCode adapter that does not depend on that flag must write
`.opencode/skill(s)/` or `.agents/skills/`.

**source** — every discovered skill is also registered as a slash command
(`packages/opencode/src/command/index.ts:135-151`, `source: "skill"`).

*interpretation* — a skills surface is sufficient. A separate
`.opencode/command/` wrapper would publish a second entry point to the same
canonical file and buy nothing.

**observation** — the same registry installs built-in commands `init` and
`review` first (`:46-49`, `:70-84`), and the skill loop skips any name already
taken (`if (commands[item.name]) continue`). A skill named `review` therefore
never becomes `/review`.

*conclusion* — bare AEP skill names collide in OpenCode. `review` is shadowed
outright; `init` would be were AEP to have one.

**source** — OpenCode agents are markdown at `.opencode/agent(s)/<name>.md` with
frontmatter `description`, `mode: primary | subagent | all`, `model`,
`temperature`, `permission`, `hidden`, `disable`; the body becomes the prompt.
Allowed top-level keys are fixed and **any unknown key is silently routed into
`options`** (`customize-opencode.md`, "Agents").

*conclusion* — AEP's own frontmatter fields cannot ride along on an OpenCode
agent wrapper: there is no free-form map, and an unknown key is absorbed rather
than rejected. Skills do have one — `metadata`, a string-to-string map.

**observation** — the `.claude` compatibility in OpenCode is skills-only. Nothing
in the agent loader reads `.claude/agents/`.

*conclusion* — AEP's four agents do not reach OpenCode by any path that exists
today. This is the gap the Claude adapter does not cover.

**source** — T3 Code is a control surface: a Node server that wraps provider CLIs
(Claude Code, Codex, Cursor, Grok, OpenCode) and serves desktop, web, and mobile
clients (`README.md`, `docs/README.md`).

**source** — its only project-level discovery of agent-facing files is
`ClaudeSkills.ts`, which scans the provider config directory's `skills`, then
`<workspace>/.agents/skills`, then `<workspace>/.claude/skills`, later root
winning on a name collision, to populate the composer's `$` picker
(`docs/user/providers-claude.md`, "Where Claude Skills Are Loaded").

*interpretation* — T3 Code defines no prompt, skill, agent, or command format of
its own. It discovers the provider's.

*conclusion* — there is nothing in T3 Code for an adapter to target. AEP reaches
it through whichever provider adapter is already on disk, and `.agents/skills/`
is the one path both T3 Code and OpenCode read.

**observation** — Claude Code's own documented discovery paths are
`~/.claude/skills/<name>/SKILL.md`, `.claude/skills/<name>/SKILL.md`, nested
`.claude/skills/` below the cwd, and plugin skills. `.agents/skills` is not among
them.

*conclusion* — `.agents/skills/` is neutral in practice rather than universal: it
serves OpenCode and T3 Code's picker, and is invisible to Claude Code.

# Conclusion

Two surfaces, and they are not the same surface:

- **OpenCode** needs `.opencode/skill(s)/<name>/SKILL.md` for the skills and
  `.opencode/agent(s)/<name>.md` for the agents — the second having no
  substitute. Both spellings are accepted by the loader; OpenCode's own
  repository carries `.opencode/skills/`, `.opencode/agent/`, `.opencode/command/`,
  and `.opencode/plugins/`, so upstream is itself inconsistent and its
  documentation shows the plural for both. Which one AEP writes is a choice the
  spec makes, not a fact this evidence settles.
- **`.agents/skills/<name>/SKILL.md`** serves OpenCode and T3 Code's picker for
  every provider T3 Code drives, and carries skills only.

Names must be prefixed to survive OpenCode's built-in `review`.

T3 Code takes no adapter, because it exposes no mechanism to adapt to.

# Not checked

- Whether OpenCode's released binary matches `dev` — everything above was read
  from the `dev` branch on 2026-08-18.
- Codex, Cursor, and Grok discovery paths, which T3 Code also drives.
- OpenCode's npm plugin distribution as a way to publish AEP before `.aep/`
  exists — the equivalent of the Claude marketplace entry. Not investigated.
- Whether T3 Code passes a picked skill to the provider as a path or as inlined
  content.

# Findings added while settling the open questions

**source** — `pingdotgg/t3code`, `packages/contracts/src/t3ProjectFile.ts`: "File
name of the checked-in T3 project file, resolved at the workspace root",
`T3_PROJECT_FILE_NAME = "t3.json"`, with a published schema at
`https://t3.codes/schema/t3.json`. It carries project scripts, `previewUrl`,
`runOnWorktreeCreate`, and `defaultThreadEnvMode`, and is read by the server
(`apps/server/src/project/T3ProjectFileLoader.ts`), the web client, and mobile.

**observation** — the other two `.t3` paths in that repository are
`~/.t3` (`apps/server/src/os-jank.ts`, home state) and a worktree-local `.t3`
(`packages/shared/src/devHome.ts`), which is T3 Code's own dev runner rather than
anything it writes into a user's repository.

*conclusion* — `t3.json` is the only per-repository evidence that a repository
uses T3 Code, and it is checked in and team-facing rather than personal.

**source** — OpenCode prepends a base-directory preamble to every skill it loads,
on both paths it can be reached by: `packages/core/src/tool/skill.ts:36-44`
("Base directory for this skill: … Relative paths in this skill … are relative to
this base directory") and `packages/opencode/src/command/index.ts:137-148`.

**source** — `customize-opencode.md`: skills registered through `skills.paths`
are "scanned recursively for `**/SKILL.md`".

*conclusion* — a wrapper installed outside a repository can express its fallback
as a path relative to its own directory and the agent can resolve it, provided
the wrapper is registered where it sits rather than copied. This is the
equivalent of the Claude adapter's `${CLAUDE_PLUGIN_ROOT}` fallback, and it
closes the bootstrap gap without an npm package.

*interpretation* — the same does not extend to the neutral `.agents/skills`
location: nothing that reads it takes a configured path, so a wrapper there can
only be copied, and a copy breaks a relative fallback.
