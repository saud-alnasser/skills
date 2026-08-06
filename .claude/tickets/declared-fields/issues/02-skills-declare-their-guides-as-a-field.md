# refactor(skills): every skill declares its guides as a field, not a body line

Status: open
Blocked by: 01
Part of: declared-fields

## Problem

Nine skills declare the guides they read as a `Policies:` prose line. ADR 0054 established that this line is *the workflow's default* and the router's stage table is *this repository's actual set*, with the table winning where they differ — and gave the configuration stage a derivation from the former to the latter.

That derivation currently consumes prose. The default and the instance already diverged once before anyone looked, which is the divergence ADR 0054 was written about.

## Outcome

Every shipped skill that names guides declares them under `metadata.policies`. The `Policies:` body line is gone. The configuration stage derives the router's stage table from that field plus whatever is local to the repository, exactly as ADR 0054 assigns it — the input changes form, the ownership does not.

The table remains a committed artefact. Nothing about this makes a repository without the plugin unable to answer what a stage reads, which is the ground ADR 0054 rejected the read-time-derivation option on.

Templates first, per ADR 0025.

## Acceptance

- No file under `skills/` contains a `Policies:` body line, and the suite fails if one returns.
- Each skill that reads guides declares them under `metadata.policies` as a YAML list.
- The suite's existing check — a guide named by a skill's default and missing from that stage's row is a build failure unless the row records the omission deliberately — still holds, reading the field.
- The router's stage table is still committed and still authored by derivation; no ticket in this effort makes it generated at read time.
- The guard is confirmed to fail against a deliberate reintroduction of the old prose line.
