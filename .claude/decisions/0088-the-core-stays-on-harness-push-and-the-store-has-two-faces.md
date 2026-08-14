---
owner: repository
status: accepted
load-when: where an always-on norm is delivered, or what happens when the store is unreachable, is in question
sources: [.claude/tickets/substrate/issues/05-what-stays-push-when-everything-else-becomes-pull.md, .claude/evidence/research/2026-08-13-what-a-plugin-hosted-tool-can-actually-do.md, .claude/evidence/prototypes/2026-08-14-what-a-stage-sees-when-a-tool-result-exceeds-the-harness-cap.md]
supersedes: []
superseded-by: []
---

# The core stays on harness push, and the store has two faces

Research established five delivery channels rather than two, differing on failure
rather than cost. **The always-on core stays on harness push** — the entrypoint
and unscoped rules — because it is the only channel documented to survive
compaction by re-injection from disk and the only one that cannot fail silently.
A stdio server is never reconnected once it dies, and a failed `mcp_tool` hook is
non-blocking with execution continuing past it, so a hook-delivered core could
leave a session running with no norms and nobody told: the failure shape this
effort exists to remove, reintroduced at the foundation. The accepted cost is
that **the core alone keeps the version stamps and byte-locking** that ADR 0084
dissolved everywhere else.

The core gains two members 1.x had no need for: **how to reach the store**, which
cannot ride the server's own instructions because those arrive only once the
server connects, and **what to do when the store is unreachable**.

**When the store is unreachable a stage rebuilds the index and continues**, which
forces the store to expose **two faces over one derived index** — an MCP server
for the fast path and a CLI for the fallback and for CI. What dies is the server
rather than the machine, so the rebuild is a derived script step whose output the
stage quotes, the shape ADR 0078 sanctions as computed rather than judged.

**The CLI face spills to a file before it can return a row, and this was measured.**
A tool result above roughly 30,000 characters is withheld from the model: the
harness persists it and returns a 2 KB preview plus a path inside an explicit
`persisted-output` wrapper. `/implement`'s row is 69,563 characters, and its
`fires-when`-filtered form is still 45,445 — **both well over**. So the fallback
does not hand a stage its row; it hands the stage a path the stage then reads.
That still works and it is **loud rather than silent** — the wrapper names the
size and says the output was too large, so nothing arrives quietly truncated —
but it is a second step this decision did not name, and the fallback is narrower
than "rebuild and continue" implies. The fast path is untouched: ADR 0089
delivers by `` !`command` `` preprocessing into skill content rather than as a
tool result, and whether that path carries its own cap is unrun on
`substrate/08` item 1.

**The path-scoped tier survives as a pointer only**: the rule carries nothing but
a pointer to query the store for norms whose `fires-when` is that path, leaving
the harness to do the one thing only it can — notice that a covered file was
touched. The compaction hole narrows without closing, since a path-scoped rule is
lost until a matching file is read again; that hole is not fixable from inside
AEP and is recorded rather than solved. The drift test survives unchanged, and
the 200-line entrypoint ceiling still binds.

## Considered Options

- **Move the core to the `UserPromptSubmit` hook** — rejected on the silent-failure
  path above, despite dissolving the copied-file apparatus completely.
- **Split a minimal harness core from hook-delivered bulk** — rejected: two
  delivery mechanisms for one tier turn every norm into a placement judgement.
- **Stop the stage when the store is unreachable** — rejected as a self-inflicted
  outage while every file it served sits readable on disk.
- **Degrade to whole-file reads without rebuilding** — rejected: it keeps two
  retrieval paths correct forever, and the degraded one is exercised too rarely
  to stay correct.
- **Dissolve the path-scoped tier into the store** — rejected: it restores judged
  selection exactly where the harness was doing the selecting for free.
- **Keep path-scoped rules carrying their norms** — rejected: the compaction hole
  would then swallow the norms themselves.
