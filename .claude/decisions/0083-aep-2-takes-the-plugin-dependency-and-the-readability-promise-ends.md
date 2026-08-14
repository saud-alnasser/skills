---
owner: repository
status: accepted
load-when: plugin independence, or what a reader without AEP installed can follow, is in question
sources: [specs.md, CLAUDE.md, .claude/tickets/substrate/map.md]
supersedes: [0022]
superseded-by: []
---

# AEP 2.0 takes the plugin dependency, and the readability promise ends

The `substrate` effort was scoped on the premise that AEP's corpus is served to
the model through a tool rather than read as files, so that a stage spends its
context on the work rather than on the protocol. A tool is a plugin dependency,
which the constraint in ADR 0022 and `specs.md` §22 forbids: nothing committed
may assume AEP is installed. The user, holding the three options and their
costs, chose to drop it — 2.0 requires the plugin, a repository's engineering
norms may be unreadable without running software, and migration from 1.x is a
requirement of 2.0 rather than a courtesy.

This reverses a rejection ADR 0022 made explicitly. That decision considered
"dropping plugin independence entirely" and refused it on a product argument
rather than a technical one: *a framework whose own installation cannot be read
without the framework makes a promise to its users that it does not keep
itself.* The argument is not answered here, it is outranked — the readability
promise was the constraint shaping the delivery mechanism, and the delivery
mechanism is what 2.0 exists to change. Whether the promise can be partly
recovered by a committed export is `substrate/06`'s to settle, not this
decision's to assume.

**Status is `proposed`, deliberately.** The constraint still governs 1.x, which
is the live framework, and marking ADR 0022 superseded today would make an
operative rule read as dead to anyone building against it next week. The
supersession is written at both ends when 2.0's spec is accepted.

## Considered Options

- **Tool accelerates, files remain** — every norm stays committed markdown and
  the tool is a fast path over the same records, droppable without loss.
  Rejected: two doors to one room, both of which must stay correct, and the
  file-reading path keeps shaping what a norm may be.
- **Tool is the door, a generated export is committed** — rejected as the
  primary shape for now, but not closed: it survives as an open question on
  `substrate/06`, because an export that cannot disagree with its source is a
  different thing from a second copy.
