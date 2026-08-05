# Orchestration is a system, and the sub-agent contract is a policy

The `aep` effort ruled multi-agent orchestration beyond assignment and claim out of scope, on the ground that ADR 0013 already implemented the coordination floor. That floor coordinates **peers** — two instances racing for one ticket. It says nothing about a parent dispatching children, which four shipped skills already do: `/review`'s two axes, `/research`'s dispatch, `codebase-design`'s design-it-twice fan-out, and `/survey`'s use of `Explore`. Each restates its own dispatch rules, and four homes for one rule is the failure this framework exists to prevent — one of the four is already falsified by the harness. So orchestration becomes a system rather than a technique repeated per skill.

Its contract is a **policy**, because Policies own how engineering is performed here, and because a sub-agent inherits the whole `CLAUDE.md` hierarchy the parent loaded — so a child reaches the policy by the same pointer chain the parent uses, with nothing new to bootstrap.

## Considered Options

- **The `Workflow` tool as the substrate.** It is the only first-party surface with schema-validated returns, resume, and budget accounting. Rejected: workflow sub-agents always run in `acceptEdits` regardless of the session's permission mode, and there is no mid-run human checkpoint — the documentation's own workaround is to split a run into one workflow per stage. AEP's human authority survives only where the session's permission mode still holds, so the substrate is plain `Agent` calls.
- **A thirteenth system with its own directory.** Rejected: the twelve systems already have a home for each half — Policies for the contract, Skills for the dispatch — and a directory holding one file is a category invented for symmetry.
- **A second protocol file, parallel to `protocol.md`.** Rejected: spec §5 already assigns orchestration to the Protocol, and a second router is a second place to look before knowing which one to read.
- **Leaving it as a technique each skill restates.** Rejected: that is the current state, and it has already drifted.

## Consequences

The `aep` effort's out-of-scope line is superseded by this decision, and specification §20 is amended in the same change rather than left to disagree.

Because AEP ships as a plugin, and plugin agent definitions silently ignore `hooks`, `mcpServers`, and `permissionMode`, a shipped role can constrain itself only through `tools` and `disallowedTools`. Any constraint that needs one of the ignored three is not enforceable in what ships and must be stated in the policy as an obligation instead.
