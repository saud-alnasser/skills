---
status: accepted
load-when: an effort is being closed while its obligations are unfinished
sources: [.claude/tickets/]
supersedes: []
superseded-by: []
---

# Phase 2's checkpoint closes by adoption, not by execution

The build order put a **dogfood checkpoint** between `/design` and the fifteen skills that followed it: run `/design` on real work in this repository, watch what breaks, and fix it before writing anything else. It never ran. Every skill after ticket 03 was built by hand, and phase 2 sat in `STATUS.md` as the one item outstanding after all twenty tickets resolved.

It is closed now by **adopting the workflow for all subsequent work here**, rather than by executing it as a gate.

The gate's economics were "a red loop on day one beats a red loop after eighteen skills" — and they stopped holding once the eighteen were written. The checkpoint can no longer protect the work it existed to protect, and holding the effort open for a session that has not happened across twenty tickets buys a report nobody reads. Continuous use surfaces the same failures against work that has to be done regardless.

## Consequences

**The first real tickets pay for whatever breaks.** The gate would have concentrated that cost into one deliberate session with nothing else at stake. Adoption spreads it across the first few pieces of genuine work, at whatever moment those happen to be urgent. That is the trade being accepted, and it is the reason the gate was worth planning in the first place.

**`/implement` and `/review` have never run as skills.** They were executed by hand for every ticket in this build. They are therefore the least-exercised part of the framework and the most likely to fail first — treat a failure in either as a framework bug before treating it as a mistake in the work being attempted, and fix it in `skills/` rather than working around it.

**Nothing validates the skills except use.** `scripts/verify.ps1` asserts what is mechanically checkable — that a rule is stated, and stated where it belongs. Whether the grill actually grills is outside its scope by construction, and phase 2 was the plan for that. There is no replacement for it, only exposure over time.
