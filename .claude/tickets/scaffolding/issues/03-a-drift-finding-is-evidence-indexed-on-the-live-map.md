# 03 — feat(configure): a drift finding is evidence, indexed on the live map

Status: resolved
Blocked by: —
Part of: scaffolding

## Problem

Knowledge drift found in passing has no home once protocol-only tracker items are banned. A falsified Decision is the sharp case: Context drift heals inline where found, but an ADR's reasoning is frozen and correcting it is design's — so today the finder either files a tracker item (the noise the ban closes), folds an unrelated correction into their diff (making it unreviewable), or drops the finding.

## Outcome

Shipped behaviour. The evidence policy carries a fifth kind — **drift findings**, in their own directory, produced by whoever finds the drift, on whatever branch they stand on: what was checked, against which commit, what it falsifies. The maps policy indexes a finding on the live effort that owns the area: one task-list line in the map linking to the evidence file, checked off when the healing lands — the map body, never a comment, because the body is one fetch. With no live effort the finding waits in evidence for the next design run. The knowledge policy points implementation at this path for a falsified Decision, so a build session knows the one drift it never heals inline.

## Acceptance

- The shipped evidence policy lists drift findings as a kind, with its directory, its producer, and what one holds.
- The shipped maps policy states the index line: task-list form, linking to the evidence file, checked when healed, on the map body.
- The shipped knowledge policy points a falsified Decision at the drift-finding path and states it is never healed inline.
- The specification's layout (§21) gains the drift directory in the same change, so the suite's spec-to-policy conformance guard sees both sides move at once — §17 already carries the kind from design capture.
- The suite asserts the kind exists in the evidence template and that the knowledge template points rather than restates, with each guard confirmed to fail against a reintroduction.
- The suite passes.

Spec: ADR 0039 records the decision and why the body beats a comment.
