# feat(knowledge): state this repository's version-control policy

Status: ready-for-agent
Blocked by: 04, 05

## Problem

This repository's branch convention and commit discipline are not written down anywhere a reader can find them, and its tracker configuration carries the branch naming section ticket 05 moves out of the template.

## Outcome

This repository states its own version-control policy in the new file, its tracker configuration is about the tracker again, and its always-on entrypoint names both.

## Acceptance

- This repository's version-control policy file states that it uses plain git, its branch convention, its commit discipline, and the never-push rule.
- The tracker configuration no longer carries branch naming.
- The root always-on file names both policy files and is under 200 lines.
- A reader with no plugin installed can reach every instruction this repository depends on starting from the root always-on file.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
