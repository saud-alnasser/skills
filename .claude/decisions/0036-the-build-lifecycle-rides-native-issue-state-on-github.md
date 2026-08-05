---
status: accepted
load-when: a ticket's state has to be expressed on GitHub
sources: [.claude/tools/github.md]
supersedes: []
superseded-by: []
---

# The build lifecycle rides native issue state on GitHub, not labels

The tickets policy claimed the build-lifecycle states are labels on GitHub while no file defined any, leaving `open`/`blocked`/`resolved`/`obsolete` with no derivable representation — the field run improvised one. We decided the lifecycle rides GitHub's native issue state: open is open; blocked stays open with its reason in the body, beside the edges that already live there; resolved is closed as completed, by the merge; obsolete is closed as not-planned with a mandatory reason comment. Zero new labels.

## Considered Options

An explicit four-label vocabulary, created by `/configure`, was rejected: it mutates every configured repository's shared label set — the invention the triage-role table exists to avoid — and closed-as-not-planned exists natively regardless, leaving two homes for one state that can disagree. A hybrid (native state plus a single `blocked` label) was rejected for the same drift, but is the recorded fallback if re-planning is ever observed missing body-only blocked tickets.
