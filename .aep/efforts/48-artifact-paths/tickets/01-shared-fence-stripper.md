---
status: resolved
---

# refactor(scripts): the fence stripper becomes shared

## Outcome

`outsideFences(body)` is exported from `scripts/contract.mjs` and `wikiLinks` calls it instead of carrying the regex inline. Behaviour is unchanged: the same bodies produce the same links, over the whole corpus. Two later tickets need the same stripping and none of them writes its own copy.

## Acceptance Criteria

- [x] Requirement 5: `outsideFences` is exported from `contract.mjs`, strips fenced blocks, and leaves inline code spans alone. The guard that requirement 5 asks for consumes it rather than restating the regex. — verified by review: a direct probe of the export returned the body with the fenced content gone and an inline code span holding link syntax untouched; `grep -rn '\^```' src/scripts/*.mjs` leaves `contract.mjs:405` as the only stripper. The consuming guard is ticket 04's and is out of this ticket's range.
- [x] Requirement 8: the retired-field scan consumes the same export, so a fenced example naming a retired field is not a finding in either check. — verified by review only as far as this ticket reaches: the shared export exists and is the corpus's single fence stripper, so ticket 07's scan has one to consume. The scan itself is ticket 07 and was not reviewed here.
- [x] `wikiLinks` produces an identical result before and after. Checked by running the existing link section of the suite, which resolves every link in the installed fixture, and seeing the same pass count. — verified by review beyond the pass count: the pre-extraction `wikiLinks` from `d88a17a` was run beside the current one over every Markdown file in the worktree — 330 files, 1293 links extracted, 0 differing.
- [x] The comment explaining why inline code spans are deliberately not stripped moves with the code rather than being left behind on `wikiLinks`. It is the reason the extraction is safe to reuse, and it is invisible from the call site. — verified by review: the paragraph now sits on `outsideFences` at `contract.mjs:397-403`, and `wikiLinks` keeps only a two-line doc that defers to it.

## Relevant areas

`src/scripts/contract.mjs`. `wikiLinks` is the only current caller.

## Constraints

Pure extraction. No change to what is stripped, no new parameters, no widening to inline spans. A behaviour change smuggled into a refactor is invisible in the diff of the tickets that then depend on it.

## Notes

This lands alone rather than inside the ticket that first needs it, so the link checker running green over the whole corpus is unambiguous evidence the extraction was faithful. Folded into a larger ticket, the same green run would also be covering new assertions, and would no longer be evidence of anything.
