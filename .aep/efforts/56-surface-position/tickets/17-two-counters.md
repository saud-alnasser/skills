---
status: resolved
blocked-by: [16]
---

# fix(protocol): the specification's marker rule fits a run that stamps nothing, and the two counters are told about each other

## Where this came from

Review round one. Two findings, one from each axis, both about a rule stated in
isolation from the thing it interacts with.

## Outcome

Section 20's MUST binds what it meant to bind, and `/specify` conforms to it
rather than contradicting it. Converge's cap and the review bound stop being two
counters that can deadlock each other.

## Acceptance Criteria

- [x] Requirement 4 and criterion 11. Section 20's MUST now reads that an
      invocation which does **both** must do both against the surface it works in,
      and that one which **stamps nothing** cannot violate it and reads the surface
      it stands in. `/specify` is named as the worked example, since at the moment
      it orients it has neither an effort nor a surface to check.
- [x] An assertion pins the narrowed form and names `/specify` as conforming
      rather than merely invoking the script. Perturbed to "An invocation always
      violates that", it goes red.
- [x] The exemption is stated in **both** `policies/execution` and
      `skills/implement`, with the reason: the cap counts rounds that went looking
      for a gap between the spec and the work, and a review finding is not one,
      because converge has already agreed the spec is met.
- [x] The assertion fails if **either** file states the cap without the exemption,
      and names which. Perturbed in the policy alone it printed `the policy states
      the cap without the exemption`.

**What this fixes is a deadlock, not a wording.** Counted against the converge
cap, the second review round is unreachable on the ordinary path: converge finds
a gap, builds it, finds none, review runs, a finding becomes a ticket, and the
run needs a converge round it no longer has. It would have ended not ready with
no gap it could name, which reads like a clean stop and is not one.

## Relevant areas

`specs.md` section 20, the check-and-stamp MUST.
`src/policies/execution.md` and `src/skills/implement.md`, where converge's
"at most twice" is stated. `src/skills/specify.md`, if the narrowed rule needs it
to say which surface its read is against. `src/scripts/verify.mjs`.

## Constraints

- **Narrow the rule; do not weaken the guarantee.** What section 20 protects is
  that a drift answer describes the tree it was computed for. A run that stamps
  nothing cannot violate that, which is why the narrowing is safe and why it must
  be written as a narrowing rather than an exception.
- The two-round review bound itself does not change. What changes is that
  reaching round two is possible.
- `specs.md` may cite its own sections. Shipped text may not. No em dash.
- Seen to fail first, and confirm each perturbation removed only its subject.
