# `CLAUDE.md` becomes a pointer, and plugin independence is restated as a property of the files

`CLAUDE.md` drops to roughly 25 lines: what this repository is, the precedence ladder's location, and a pointer to `.claude/protocol.md`. The protocol file — renamed from `tenure.md` — becomes the router, holding the Marker, the drift reads, the verification report, and the table mapping each workflow stage to the policies it reads.

The constraint that nothing committed may assume Tenure is installed is **kept, and restated**. It never meant "`CLAUDE.md` must contain everything". Every guide is a committed markdown file, so a teammate without the plugin can follow `CLAUDE.md`'s pointer to `protocol.md` and read on exactly as Claude does. Only the slash commands need the plugin; nothing that carries a *rule* does.

## Considered Options

**Keeping `CLAUDE.md` self-sufficient at its current size** was the status quo and was rejected because it is what makes the always-on budget 8,739 chars — pull-request description conventions load on turns that answer a question.

**Dropping plugin independence entirely** and letting `CLAUDE.md` become a 15-line stub with everything behind Tenure-only machinery was rejected on a product argument rather than a repository one: this repository ships Tenure, and a framework whose own installation cannot be read without the framework makes a promise to its users that it does not keep itself.

**Making `protocol.md` a rule** so the harness loads it unconditionally — which would satisfy the original request that it load in every prompt — was rejected. It is stage machinery, and a turn that answers a question should not pay for the router. Being pointer-read is the property that makes it cheap.

## Consequences

"Loaded in every prompt" is not achievable for `protocol.md`, because only `CLAUDE.md` and `.claude/rules/**` are harness-loaded. It is reached by pointer on the turns that need it, which is cheaper than what was asked for and gives the same result.

Precedence and the engineering rules move to `.claude/rules/`, where the harness loads them unconditionally. They are therefore still always-on — the tier changed, not their availability.

The rename from `tenure.md` to `protocol.md` breaks inbound references from every skill and from `/configure`'s templates, all of which move in the same effort.
