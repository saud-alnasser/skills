---
owner: repository
status: accepted
load-when: text is being compressed, or a claim is about to be dropped for brevity
sources: [scripts/verify.ps1]
supersedes: []
superseded-by: []
---

# Compression keeps the surprising why, and `verify.ps1` is the fidelity floor

Rhetorical amplification is removed from everything shipped and from this repository's own knowledge files. One clause of rationale survives only where the rule would read as arbitrary without it. Readability for a human maintainer is explicitly traded away; unambiguity for the model is not.

The reason the rationale is not cut uniformly is that a defended rule and an undefended one cost different amounts to *follow*. An arbitrary-looking rule gets re-evaluated on every encounter — is this my case, does it still apply — which is the tangled, over-considered thinking this whole effort exists to remove. Cutting the why is cheap in tokens and expensive in thought, so it is cut only where the rule stands up on its own.

`scripts/verify.ps1` is what turns this from taste into a test. Its assertions are concept-anchored with alternations rather than literal-phrase matches, so a green suite after a rewrite is mechanical evidence that no load-bearing claim was lost.

## Considered Options

**Uniform caveman compression**, including the rationale, would cut roughly 60–65% rather than 40–45%. Rejected for the reason above: the extra saving is paid back with interest every time an unexplained rule is encountered.

**Compressing only `skills/`** and leaving `.claude/` prose intact was rejected because the always-on files are where the reported problem actually comes from — leaving them untouched fixes the measurement and not the symptom.

## Consequences

`verify.ps1` only covers claims someone chose to assert, so prose no assertion reaches can be compressed away silently. Assertion coverage is therefore audited and closed per file *before* any compression lands, rather than trusted because the suite is green.

The suite stops being only a build guard and becomes the specification of what the prose must keep. That raises the cost of adding an unasserted claim to a skill: it is now not merely untested, it is deletable by the next compression pass without anyone noticing.

These files get harder for a human to read. That is the accepted trade, bounded by keeping the surprising why so they stay auditable.
