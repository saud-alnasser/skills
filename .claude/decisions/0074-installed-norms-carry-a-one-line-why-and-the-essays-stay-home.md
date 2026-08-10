---
owner: repository
status: accepted
load-when: a file AEP ships or installs is about to be written or converted
sources: [specs.md, .claude/policies/, .claude/rules/, skills/]
supersedes: []
superseded-by: []
---

# Installed norms carry a one-line why, and the essays stay home

Installed files interleaved each norm with its mechanism and a long rationale —
60–70% of volume — and the token cost and the read-past-the-imperative failure
shared that root. Decided: a framework-owned normative file states each norm as
a checkable imperative or table carrying a one-sentence reason; the full
rationale — history, what-it-does-not-mean, failure stories — lives in the
framework repository's spec and ADRs and is not installed. The one-line why is
the compression floor: a reasoned rule resists lawyering at edges a bare rule
loses, and a norm whose why cannot fit a line is not yet understood well enough
to ship. Clarity outranks compression: the audience is the model alone, so
human-comfortable prose may go, but a norm stays unambiguous and complete at
any density — density is bought with redundancy, never with precision.

## Considered Options

- **Pure norms, why elsewhere** — maximum compression, rejected: unreasoned
  rules get misapplied at exactly the edges the reason would have caught.
- **Keep the essays** — rejected: no token win, and the re-asking fix would rest
  entirely on tiering.
