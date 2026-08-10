---
title: 'fix(verify): assertions stop depending on the checkout''s line endings'
status: open
blocked-by: []
part-of: line-endings
---

## Problem

An assertion that reads a frontmatter field and anchors to the end of the line
with a class matching only spaces and tabs cannot match where the checkout holds
a carriage return. It reads the field as absent.

The release assertion does exactly this and fails now: three sources state the
same version, and the suite reports them as disagreeing because it read one of
them as empty. A reader following that failure is sent to a file that is
correct.

This is the class, not the instance. The next assertion written in the same
style has the same defect, and it will pass on whichever tree its author
happened to have.

## Outcome

The suite gives the same verdict whatever line ending the tree it read holds, and
a failure it reports is a fact about content rather than about how the tree was
checked out.

Every assertion that reads a field out of a file is indifferent to the ending,
and a new one written in the fragile form is caught by the suite rather than by
whoever next runs it on a tree that differs.

This lands first and alone, because it is what makes the tree green before the
change that touches every file is judged, and because every other ticket in every
other effort ends its acceptance with the suite passing.

## Acceptance

- The suite gives the same verdict on a tree holding either ending.
- No assertion reports a disagreement between sources whose content agrees.
- The assertion failing today passes, and passes for the right reason — the three
  sources it compares are read correctly rather than compared more loosely.
- Every assertion that reads a field is covered, not only the one that fails
  today.
- The suite fails when an assertion reading a field is written in the fragile
  form, confirmed against a deliberate reintroduction and then restored. The
  guard is anchored to the subject rather than to the corrected wording.
- No file's contents change beyond the suite itself.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
