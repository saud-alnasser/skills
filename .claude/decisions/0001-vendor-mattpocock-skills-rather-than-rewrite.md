---
status: superseded
load-when: a shipped skill's derivation or attribution is in question
sources: [skills/]
supersedes: []
superseded-by: [0066]
---

# Vendor mattpocock's skills rather than rewrite them

Tenure re-specifies several capabilities that mattpocock/skills already implements more thoroughly (grilling, tdd, code-review, prototype, research, domain-modeling). Rather than write thinner versions from scratch, we copy those skills into this repo and alter them to fit Tenure's vocabulary and layout, then uninstall the originals.

## Considered Options

- **Write all eight commands from scratch.** Coherent voice, but discards mature, battle-tested content and loses depth we would not recover.
- **Keep the originals installed alongside Tenure.** Least work, but two vocabularies compete for the same jobs and the user wants a single owned set.

## Consequences

Upstream is **MIT** (Copyright (c) 2026 Matt Pocock), which permits modification and redistribution under different terms provided the original copyright and permission notice are retained. Tenure is therefore released under **Apache 2.0**, Copyright 2026 Saud Alnasser, with matt's MIT notice reproduced in full in `NOTICE`.

Upstream improvements no longer arrive automatically — divergence is permanent and intentional.
