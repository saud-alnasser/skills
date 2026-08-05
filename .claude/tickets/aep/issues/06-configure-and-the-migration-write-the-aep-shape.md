---
title: feat(configure): the templates generate the AEP shape, and the migration converts onto it
status: resolved
blocked-by: [05]
part-of: aep
---

## Problem

A repository configured today is born onto the streamline layout under the Tenure name. The templates now need to emit the specification's layout (spec §21), and the migration — which already converts foreign workflows, Tenure's earliest shape, and the streamline predecessor — needs one more conversion: a streamline-shaped repository onto the AEP shape.

## Outcome

**Shipped behaviour changes; this repository's own configuration does not.**

A freshly configured repository matches spec §21 exactly. The migration converts every layout it already recognized plus the streamline shape, listed in the move plan before anything is touched, and re-running it on a converted repository reports what exists rather than duplicating it.

## Acceptance

- The generated layout matches spec §21 file for file, asserted against the template set.
- The migration converts a streamline-shaped repository, repoints every reference into moved files, and recognition is by content rather than presence.
- The conversion is demonstrated against a fixture carrying every shape the migration claims to handle, and a second run against the converted fixture changes nothing.
- Nothing shipped names a pre-migration path except the files whose job is detecting and converting them.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

Absorbs the follow-through of streamline 08, which built the previous conversion and the fixture technique this ticket reuses. The fixture reasoning is ADR 0026 and carries over unchanged.

Demonstrated at close: a scratchpad fixture carrying a Tenure-named, pre-modes tree fired both content detections, converted to the current template shape with its rows preserved, and a second run found nothing to convert — re-applying the conversion produced a byte-identical file, and the frozen decision kept the old name. The earlier layouts' conversions were demonstrated when streamline 08 landed and were not re-run here; this ticket added no step to them.

Found while asserting: spec §21 omitted `designs/` and the ignore file the templates have always generated — amended in the same change, ADR 0031.
