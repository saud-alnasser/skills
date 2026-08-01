# 01 — docs(skills): rename the expansion to the Agentic Engineering Protocol, and release the specification at 1.2.0

Status: resolved
Blocked by: —

## Problem

The framework's name expands to the **AI Engineering Protocol**. It should expand to
the **Agentic Engineering Protocol**. The acronym does not move: `AEP` stays `AEP`, so
the plugin id, the `/aep:` command namespace, every `.claude/` path, and the `aep/`
effort id are all unaffected. This is a change to three words of prose, not a
migration.

Two things make it more than a search-and-replace.

First, some of the occurrences are in **frozen records** — an accepted ADR and a
resolved effort's tickets. This repository's own rules forbid changing them: a
committed ADR's reasoning is frozen and only its status moves, and history is not
repaired. So the old expansion stays greppable forever, and without an explanation
and a guard the next person to grep it will read deliberate residue as a missed
occurrence and "finish the job".

Second, repositories already configured by AEP carry the old expansion in their
installed protocol file. Nothing routes on that sentence, so nothing will ever notice
it is stale.

## Outcome

The framework is called the Agentic Engineering Protocol everywhere it is currently
alive, the record of its two former names is readable from the README and the NOTICE,
and the frozen records that still carry the old expansion are protected by a test
rather than by intention. A `/configure` audit heals the name in a repository
configured before the rename. The specification leaves draft at 1.2.0 and the plugin
manifest states the same version.

## Acceptance

- Every live file that names the framework expands `AEP` as the Agentic Engineering
  Protocol. This includes the shipped plugin and marketplace manifests, the
  specification, the entrypoint, the protocol router, this repository's own Context,
  and the protocol template `/configure` installs.
- The acronym, the plugin id, the `/aep:` namespace, and every path are byte-identical
  to before. A reader who only had the acronym cannot tell the rename happened.
- Three frozen records still read "AI Engineering Protocol": ADR 0029, the `aep`
  effort's spec, and the `aep` effort's ticket 02.
- `README.md` and `NOTICE` name both former names in order, so a reader who lands on a
  frozen record can tell residue from drift without opening the history.
- The migration guide's account of the Tenure rename is true across both renames and
  needs no edit at the next one.
- Running `/configure` against a repository whose installed protocol file carries the
  old expansion reports it as an audit finding and heals it. A repository already on
  the new expansion reports nothing.
- `specs.md` states version 1.2.0 with no draft marker, and the plugin manifest states
  1.2.0.
- The suite fails if a live file regains the old expansion. Separately — a second
  assertion, because one guard covering both claims passes when either holds — it
  fails if any of the three frozen records loses it.
- The full suite passes.
