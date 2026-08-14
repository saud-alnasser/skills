---
owner: repository
kind: drift
falsifies: [.claude/decisions/0089-the-row-is-delivered-the-query-is-filters-and-a-miss-is-a-fact.md]
---

# ADR 0089's measured saving needs a per-span label the record format does not carry

Checked 2026-08-15 against `5aa5da4`, while building `conversion/10` — the ticket
whose last acceptance criterion is *"a stage's row measured against the file-list
row it replaces has its dropped set inspected rather than trusted"*. The dropped
set is empty, and that is the finding.

ADR 0089 records the filter's value as a measurement: *"`/implement`'s row is
69,563 characters over 69 spans, of which **only 48.5% is labelled for the stage
that loads it**; filtering drops **34.7%**"*. Both figures are per **span** — a
file loaded whole carries spans some other stage wanted, and the filter's saving
is exactly those.

**What shipped labels per file.** `fires-when` and `stages` are top-level
frontmatter, read by the builder with `scalar` and `list` over the file's fields,
and there is no per-record override — `span-sources` exists for pointers and has
no counterpart here. Every one of the fifteen files in the shipped framework store
declares exactly one `stages` line, so every record in a file carries its file's
stages and no record carries anything else.

So the four framework files the router's stage table names for `/implement` come
to 29,213 characters over 95 records, and **100% of them are labelled for
`implement`. The filter drops nothing.** It cannot: a filter whose granularity is
the file, applied to a row that was already a list of files, selects the same
files. What it drops is other stages' files, which the 1.x row was not loading
either.

**The filter is doing real work at the store level and none at the file level.**
Of 53,393 characters of framework norms, `/implement` receives 55.2% and
`/prototype` 10.6% — so a stage does pay for less than the corpus. That is the
saving of *not loading other stages' guides*, which the 1.x stage table already
bought by naming files. The 34.7% ADR 0089 measured is the saving on top of that,
and it is currently zero.

**The reasoning is sound and the mechanism is unbuilt, which is why this is a
finding rather than a supersession.** Nothing here argues against per-span
labelling; the corpus simply has none. Two ways to reach the measured figure, and
they are not equivalent: split each guide into per-stage files, which the flat
store makes cheap and which changes no format; or give `stages` a per-record
override on the pattern `span-sources` already sets, which changes the format and
gives the build a new refusal to carry. The first needs no decision and the second
does.

Re-run the check by counting the `stages:` lines in the shipped store against its
file count — fifteen and fifteen — or by assembling `/implement`'s row and
comparing its size against the sum of its files' sizes.

Consumed: ADR 0089 declares `falsified-by` naming this finding — corrections/01 — and the
saving it measured is collected by cutting each guide to the stages that read it —
corrections/02 (ADR 0104, which chose the cut over a per-record `stages` override).
**The figure is not reached and that is deliberate**: the split takes 22.1% off
`/implement`'s row where this ADR measured 34.7%, because every arguable record was
assigned to both stages rather than to one. The remaining gap is assignment conservatism,
not a missing mechanism, and tightening it is a judgement somebody should review before
making.
