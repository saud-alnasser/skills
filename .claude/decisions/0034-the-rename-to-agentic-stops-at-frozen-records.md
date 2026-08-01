# The rename to Agentic stops at frozen records

AEP's expansion became the **Agentic Engineering Protocol**; the acronym, the plugin
id, and the `/aep:` namespace did not move, so unlike the Tenure rename this is prose
and not a migration. Live prose was renamed and frozen records were not — ADR 0029 and
the resolved `aep` effort's tickets keep "AI Engineering Protocol", because a committed
ADR's reasoning is frozen and history is not repaired.

The consequence is that the old expansion stays greppable forever, which reads exactly
like an incomplete rename. Two things answer that: `README.md` and `NOTICE` name both
former names, so the residue has a live explanation; and `scripts/verify.ps1` pins both
sides, so neither a live file regaining the old name nor a frozen record losing it can
land silently.

## Considered Options

Renaming the frozen records too would have made the sweep complete and left nothing to
explain or guard. It was rejected because it rewrites an accepted ADR's committed prose
— the one edit `.claude/policies/decisions.md` forbids outright — and erases the record
that the framework was ever called the AI Engineering Protocol, which is the fact a
reader of the `aep` effort most needs.

Healing already-configured repositories was placed in `/configure`'s audit branch
rather than in `MIGRATION.md` beside the Tenure section. The migration guide is only
opened when another AI workflow is found or AEP is on a superseded layout; a repository
on the current layout carrying a stale word is neither, so a row there would have been
written and never reached.
