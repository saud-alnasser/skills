---
owner: repository
status: accepted
load-when: drift is found that cannot be healed on the spot
sources: [.claude/evidence/drift/]
supersedes: []
superseded-by: []
---

# A drift finding is evidence, indexed on the live map

With protocol-only tracker items banned (ADR 0038), knowledge drift found in passing lost its escape hatch — the field had filed a falsified ADR as an issue, precisely because folding the correction into an unrelated diff makes that diff unreviewable and correcting frozen reasoning is design's. We decided: a **drift finding** is a fifth evidence kind, in its own directory, written by whoever finds the drift on whatever branch they stand on — what was checked, against which commit, what it falsifies. When a live effort owns the area, the map carries one task-list line linking to the finding, checked off when the healing lands; with no live effort the finding waits, and design's discovery reads the directory so it surfaces on the next plan over that ground. A falsified Decision is the one drift never healed inline.

## Considered Options

- **A comment on the effort's root issue** — rejected: comments are a separate paginated fetch every session must remember; the body is one call and, on GitHub, already *is* the map.
- **A standalone drift issue when no effort is live** — rejected: "no live effort" is easy to satisfy and hard to police, and it reopens the channel ADR 0038 closes.
- **Healing ADRs inline wherever found** — rejected: an implement session rewriting a Decision mid-build skips the grill that froze it.

## Consequences

Amends the specification's evidence enumeration (§17) and layout (§21) in the same change, per ADR 0029. A finding can sit unread until a design run touches its area — accepted, because Context drift still heals inline and only frozen-ADR drift waits.
