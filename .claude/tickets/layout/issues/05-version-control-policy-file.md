# feat(configure): give version control its own policy file

Status: ready-for-agent
Blocked by: 03

## Problem

Nothing answers "how does work move from a ticket to a merged change here". Whether the repository uses plain git or stacked changes is probed by `/implement` at build time; branch naming sits in the tracker configuration, a file named for the ticket tracker and described by its own header as being about the tracker. The answer is split across a skill, a probe, and a file whose name does not suggest it — and the always-on entrypoint names none of them, so a teammate without the plugin cannot reach the tracker configuration at all despite every skill reading it.

## Outcome

`/configure` writes a version-control policy file stating which model the repository uses, its branch convention, its commit discipline, and the never-push rule. The tracker configuration keeps what it is named for. The always-on entrypoint names both policy files. `/implement` reads the stated model and verifies it at use rather than probing for it.

## Acceptance

- A configured repository has a version-control policy file stating which model applies, the branch convention, the commit discipline, and the never-push rule.
- The tracker template states none of those, and the constraint that a branch must encode the ticket id travels with the branch convention to its new home.
- The always-on entrypoint names both policy files and stays under 200 lines, asserted rather than assumed.
- `/implement` learns which model applies by reading the file and verifying the statement at use; no build-time probe remains as the source of the answer.
- A repository whose stated model no longer matches reality is caught by verification at use and healed in place, not deferred.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
