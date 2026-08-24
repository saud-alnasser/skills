---
status: resolved
---

# feat(policies): what the human reads becomes governance

## Outcome

`policies/reporting.md` stops governing only the turn report and starts governing
every text an agent writes for a human. It carries the reader test, the worked
lists on both sides of it, the four prohibitions a script can check, and a link
to the catalogue skill. Its title and `use-when` widen; the file name does not
change.

## Acceptance Criteria

- [ ] The heading and `use-when` name every human-read text rather than the turn
      report, and `node .aep/scripts/index.mjs` shows the new trigger in the
      policies table (criterion 1).
- [ ] The reader test is stated in one sentence, with the governed and exempt
      cases as worked examples beneath it rather than as the definition
      (criterion 2).
- [ ] Two cases on neither list resolve from the test alone: an inline review
      comment the agent posts to a pull request resolves to **governed**, and a
      `position/marker.json` written for a later run resolves to **exempt**
      (criterion 2).
- [ ] The exemption for normative protocol text names that it applies wherever
      such a document lives, including a repository root (criterion 2).
- [ ] The policy links `skills/prose` for the catalogue and states that the
      prohibitions are its own (criterion 3).
- [ ] All four prohibitions appear by name: em dashes, curly quotes, decorative
      emoji, title-case headings (criterion 4).
- [ ] The em dash prohibition says that parentheses, en dashes, and a hyphen do
      not satisfy it (criterion 4).
- [ ] Every existing assertion in `verify.mjs`'s `reporting` section still passes.
      The seven slots, their order, the one-home check, and the rendering word
      list are unchanged by this widening.

## Relevant areas

`src/policies/reporting.md`. `src/scripts/verify.mjs`'s `reporting` section is
what judges it, and it is not edited here.

## Constraints

- **The policy may not name a rendering.** `verify.mjs` fails this file on a word
  list covering `terminal`, `colour`, `ANSI`, and four runtime names. The widened
  prose stays clear of all of them.
- **Exactly one shipped artifact may state the whole slot set.** That artifact is
  this one, and it stays that way.
- The prohibitions live here and the craft lives in the skill. Do not restate a
  catalogue pattern as a rule.

## Notes

**Criterion 1's second half belongs to ticket 10.** `.aep/index.md` reads the
installed copy of this policy, and `.aep/` is output. The widened `use-when`
appears there only after the reinstall, so the `src/` half is checked here and the
index half is checked at the release. Raised at review rather than discovered
later.

The policy's link to the skill is a real double-bracketed link and will not resolve
until ticket 03 lands. Write it anyway: the policy is where it belongs, and
`validate.mjs` reports the dangling target rather than the missing one. This
ticket writes it as a link; these tickets name it in backticks so the validator
does not report the same gap ten times.
