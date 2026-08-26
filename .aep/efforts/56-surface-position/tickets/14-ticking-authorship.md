---
status: resolved
---

# fix(protocol): the ticking rule's authorship claim reaches every file that states it

## Where this came from

Review round one, found independently by **both** axes. Ticket 13 swept for the
*exclusivity* phrasing and these two files carry the *authorship* phrasing, which
falls outside all four of its declared shapes. Ticket 13 recorded that limit in
its own notes and then ticked its criterion against prose the sweep cannot see.

## Outcome

`policies/execution` says a wave of one is built inline and "that tick is the
author's own, and it is the whole of what this section gives up". Two shipped
files assert the opposite as a universal. They are corrected, and the sweep is
widened so the authorship phrasing cannot survive either.

## Acceptance Criteria

- [x] Requirement 12 and criterion 13, extended: the resuming section now says a
      tick records that a criterion was verified and carries inline what verified
      it, so a resumed run reads the evidence rather than the claim.
- [x] `agents/reviewer-correctness.md` now tells the reviewer that where a wave
      of one was built by the orchestrator the tick is its author's, and that **it
      is the one who judges that work**, so it reads what the tick carries rather
      than reading the box as somebody else's check.
- [x] Two authorship shapes added to the sweep, written **before** the prose was
      touched. Their first run fired on the real tree naming both files and which
      shape each matched: `agents/reviewer-correctness.md (a ticked box is claimed
      to have been checked by a non-author), skills/implement.md (a tick is
      claimed never to come from its author)`. The red was the defect itself, not
      a simulation of it.
- [x] The guarantee is restated rather than dropped. What a resumed run may trust
      is the evidence carried inline, and the inline-built case is covered by the
      review over the whole effort branch, which runs before anything is handed
      over. That is the compensation requirement 12 promised, now pointed at
      rather than contradicted.

## Relevant areas

`src/skills/implement.md`, `## Resuming after losing context`.
`src/agents/reviewer-correctness.md`, the paragraph about a box already ticked.
`src/scripts/verify.mjs`, the sweep ticket 13 added.

## Constraints

- **The compensation must survive.** Requirement 12's whole argument is that the
  effort review judges inline-built work. Two sentences currently tell that
  reviewer the box was checked by a non-author, which instructs it to skip
  exactly what it exists to do. Say instead what the reviewer should do with a
  tick it cannot attribute.
- Shipped text may not cite `specs.md`. No em dash.
- Seen to fail first, against the current tree, before correcting the prose.
