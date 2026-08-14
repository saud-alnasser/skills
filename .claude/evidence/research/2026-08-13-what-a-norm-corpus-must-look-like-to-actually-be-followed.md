---
owner: repository
kind: research
falsifies: []
---

# What does the measured evidence say a norm corpus must look like for a model to actually follow it?

Verified against: Chroma's *Context Rot* technical report (Hong, Troynikov, Huber, July
2025) as published; *How Many Instructions Can LLMs Follow at Once?* (Jaroslawicz et al.,
arXiv 2507.11538) via its project page and a paper-summary site; a 2026 format benchmark
summarised in search results; and direct measurement of this repository on 2026-08-13.
Status: answered, and it surfaces one failure mode AEP has no machinery for. Open: the
IFScale per-density figures could not be read at source.

The five prior store findings all asked *where norms live and how they are fetched*. None
asked the question on the other side of the delivery: **given the norms arrive, what makes
a model comply with them, and what does carrying them cost?** That is the half of the
user's goal — "major improvement on context-window utilization and avoid mis-loads" —
that no research has touched. This finding is about the consuming end.

## Answer

**Three effects are measured, and AEP is currently on the wrong side of all three at the
margin. Two are already answered by ADR 0089. The third is a failure mode AEP has no
detector for, and it changes what a stage row's bound should be measuring.**

### 1 — Instruction-following degrades with instruction *count*, and the dominant error is silent omission

The IFScale benchmark scales a task from 10 to 500 simultaneous instructions across 20
models from seven providers. **"Even the best frontier models only achieve 68% accuracy at
the max density of 500 instructions."** Three degradation shapes appear — threshold decay
for reasoning models (stable, then a steep fall past a critical density), linear decay
(gpt-4.1, claude-sonnet-4), and exponential decay for smaller models.

Two secondary findings matter more to AEP than the headline:

- **"Models overwhelmingly err toward omission errors as instruction density increases."**
  Not misapplication — *omission*. The instruction is in context, and the output proceeds
  as though it were not.
- **"Primacy effects, where earlier instructions are better satisfied, peak around 150-200
  instructions before diminishing at extreme densities."** Order in the payload is not
  neutral.

**Measured against this repository on 2026-08-13:**

| Tier | Files | Chars | Norm-shaped imperatives |
| --- | --- | --- | --- |
| Boot (`CLAUDE.md` + `.claude/rules/`) | 6 | 15,887 | 26 |
| Protocol corpus (`.claude/`, less knowledge dirs) | 28 | 132,172 | 222 |
| Shipped (`skills/` + `agents/`) | 63 | 399,849 | 366 |

The protocol corpus runs ~595 characters per imperative. **A stage row at the current
`/review` bound of 68,000 characters therefore carries on the order of 100–115
simultaneous instructions** — computed from that ratio, not counted. That is not near 500,
and it is not in the safe zone either: it sits inside the band where IFScale observes
primacy effects operating and omission errors rising, and it is on the wrong side of the
curve from where the boot tier's 26 sit.

**This reframes the row bound.** The suite bounds a row in *characters*, which is a proxy
for tokens, which is a proxy for cost. The measured degradation is against *instruction
count*. Those two diverge exactly where AEP is heading: ADR 0089's filter removes prose a
stage cannot use, which cuts characters hard while cutting instructions much less. **A row
could pass a tightened character bound while its instruction density is unchanged, and the
compliance risk would be untouched.** Neither the current bound nor anything in the effort
so far measures the number that the evidence says predicts omission.

### 2 — Length hurts even when the task does not, and coherent irrelevance is the worst kind

Chroma's *Context Rot* holds the needle–question pair fixed and grows only the surrounding
context across 18 models and 194,480 calls. **"Model performance varies significantly as
input length changes, even on simple tasks"**, and **"performance consistently degrades
with increasing input length."** It reproduces on pure text replication: **"as context
length increases, performance consistently degrades across all models"**, with models
**"more likely to place the unique word correctly when it appears early in the input"** —
primacy again, on a task with no reasoning in it at all.

Two findings sharpen this into an argument about *what* fills a row:

- **"Even a single distractor reduces performance relative to the baseline (needle only),
  and adding four distractors compounds this degradation further."**
- Counterintuitively: **"models perform worse when the haystack preserves a logical flow of
  ideas. Shuffling the haystack and removing local coherence consistently improves
  performance."**

**Read against AEP that is close to indicting the current row.** The 34% of `tickets.md`
that `/implement` loads and cannot use — the measurement that drove ADR 0089's amendment —
is not inert ballast. It is *coherent, topically adjacent prose about tickets*, which is
precisely the distractor class Chroma measures as most harmful. The amendment was argued
as a token saving; **this is independent evidence that it is also an accuracy saving, and
that the two are not the same argument.**

A third finding bears on norm *wording*: **"as needle-question similarity decreases, model
performance degrades more significantly with increasing input length."** A norm phrased in
vocabulary distant from the work it governs gets harder to retrieve as the row grows.
ADR 0074's norm form — a checkable imperative in the domain's own words — is the right
shape for this, and it is now supported by a measurement rather than only by taste.

### 3 — Format is settled, and the settlement is "don't change it"

A 2026 benchmark of 9,649 prompt–completion trials across 11 models and four formats
(YAML, Markdown, JSON, TOON) found **format does not significantly affect aggregate
accuracy (χ² = 2.45, p = 0.484)** for frontier models, with per-model swings from −7.7% to
+2.7%; model capability dominated, a 21-point gap between frontier and open-source tiers.
On cost, Markdown runs **30–40% fewer tokens than JSON** and roughly 15% fewer than XML.

**So: markdown with YAML frontmatter is already the cheapest format that loses nothing.**
Any 2.0 proposal to serve norms as JSON or XML for machine-friendliness would pay 30–80%
more tokens for no measured accuracy gain. The user's standing instruction — *metadata for
md files is always in frontmatter* — is on the right side of this. Worth recording only so
the question is not reopened on intuition.

## What this changes

**Nothing decided is overturned. Two things gain independent support, and one new question
opens.**

- **ADR 0089's filter gains a second, stronger justification.** It was amended on a token
  argument. Chroma's distractor and coherence results say the excluded prose was actively
  degrading accuracy, not merely being paid for. These are different claims and the second
  is the more important one.
- **ADR 0074's norm form gains a measurement.** Short, checkable, in the domain's
  vocabulary is the shape that survives both the similarity effect and the density curve.
- **New, and not covered anywhere in the effort:** *a stage row's bound should constrain
  instruction count, not only characters.* Both proxies are wanted — characters for cost,
  count for compliance — and only one is asserted today. This is the first thing found in
  six rounds of research that the design does not already have an answer for, so it is
  added to the map's *Not yet specified* rather than being decided here.

**And one thing to hold onto that is easy to lose**: every prior finding treated the
failure as a **mis-load** — the right norm not arriving. IFScale says the more likely
failure at AEP's density is a **mis-follow** — the norm arriving and being omitted anyway,
with no signal that it was. AEP's whole verification apparatus (the Marker, verification
at use, drift findings) is built to catch knowledge that is *wrong*. Nothing in it catches
a norm that was correct, present, loaded, and silently not applied. Filtering the row is
the only lever the current design has against that, which raises what ADR 0089 is worth
and lowers the appeal of anything that grows a row back.

## Limitations

- **The 100–115 instruction estimate for a stage row is derived, not counted.** It comes
  from dividing the protocol corpus's 132,172 characters by its 222 norm-shaped
  imperatives and applying that density to the 68,000-character row bound. Rows are not
  composed of protocol-corpus files in that proportion, so the true figure could differ
  substantially. **It establishes the order of magnitude, not the number.** Counting
  imperatives per actual row is a cheap follow-up and has not been done.
- **The imperative counts are a regex proxy** — lines beginning with `-` or `|` followed by
  `**`. That matches AEP's norm form and its tables, but it will miss imperatives written
  as plain prose and will over-count bolded non-normative bullets. It was not
  hand-validated against any file.
- **IFScale's per-density numbers could not be read at source.** The arXiv PDF returned
  unparseable content and the project page's leaderboard did not populate. The 68% figure,
  the three decay patterns, the 150–200 primacy peak, and the omission-error finding are
  quoted from the project page and a paper-summary site, not from the paper. **No accuracy
  figure at 100 instructions — the density that matters most here — was obtained**, which
  is the largest gap in this finding.
- **IFScale's task is keyword inclusion in a business report.** Whether that transfers to
  behavioural norms governing code changes is an assumption, not a demonstration. It is a
  reasonable one — both are "satisfy N simultaneous constraints in one output" — but the
  instruction *kind* is different.
- **The format benchmark is a search-result summary of a study I did not read.** The χ²
  statistic, trial count, and token ratios are quoted as reported; no methodology was
  checked, and the token-ratio figures come from a different source than the accuracy
  figures.
- **Context Rot is dated July 2025** and tests models of that period (GPT-4.1, Claude 4,
  Gemini 2.5, Qwen3). Its direction has been widely reproduced since, but the magnitudes
  are not current-generation.
- **No measurement was taken of AEP's own compliance.** Nothing here observes a stage
  omitting a norm. The entire argument is that published curves place AEP's corpus in a
  region where omission is expected — which a prototype could test directly, and `08` is
  where that would happen.
