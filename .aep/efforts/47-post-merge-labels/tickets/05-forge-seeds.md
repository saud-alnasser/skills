---
status: resolved
---

# feat(seed): a tracker reference cannot ship without its merge-time job

## Outcome

The two merge-time jobs exist as seed files, and a `forge()` helper declares a
tracker reference together with its automation. A tracker reference added later
without one fails the suite, so requirement 5 is a mechanism rather than a list
somebody keeps up to date.

## Acceptance Criteria

- [x] Criterion 4: the GitHub file fires on the pull request closing, guards on
      the merge actually having happened, and moves `status:` on both the change
      request and the issue it closes. It parses as YAML and needs nothing
      provisioned: the built-in token with `pull-requests: write` and
      `issues: write` carries it.

      Verified by five assertions in the `seeds` section, each reading the parsed
      document rather than the file's text: `fires when a change request closes`,
      `guards on the merge actually having happened`, `moves the change request
      and the issue it closes`, `asks for the two scopes that carry it`, and
      `needs no secret created before it runs`, which fails on any `secrets.`
      reference and requires `github.token`. Fire-checked by deleting the
      unmerged branch, which printed `guards on the merge actually having
      happened: nothing separates a change request closed without merging`.

- [x] Criterion 4: the GitLab counterpart exists, and its own text names the
      `api`-scoped project access token it requires before it says anything else.
      Its job token cannot write to a merge request and no pipeline fires at
      merge, so a reader who skips the first line is a reader whose job fails
      mysteriously.

      Verified by `names its api-scoped token before anything else`, which reads
      the file's leading comment block, takes its first paragraph, and requires
      the scope, the word token, and the variable name to be in it. Fire-checked
      by moving that paragraph down one: `the opening does not name the scope:
      What it does: moves the status label to its terminal value.`

- [x] Criterion 3: both files reach the terminal value for a change request
      closed without merging, not only for one merged.

      GitHub, structurally: `moves the label whether or not the merge happened`
      requires every step running `--add-label` to carry no `if` at all, so the
      merged branch and the abandoned branch reach the same label. Fire-checked
      by guarding one of them on `merged == true`, which printed `a labelling
      step is conditional on the merge: Move the change request`. GitLab:
      `reaches the terminal value for a close without a merge` requires both a
      rule that fires without a push, since GitLab emits no event when a merge
      request is closed, and a terminal-state test that accepts closed. Each half
      was fire-checked on its own and printed its own message.

- [x] Criterion 5: a reference added under `src/seed/references/` that carries the
      tracker section, and is declared without an automation file, fails
      `verify.mjs`. Fire-checked by adding a third such reference with no
      automation and watching the named assertion go red.

      Fire-checked with `src/seed/references/bitbucket.md`, confirmed first to
      carry `## AEP in this tracker` and confirmed that `src/seed/automation/`
      held only the two existing files. One failure, and it named the right
      assertion rather than the orphan check: `every tracker reference declares a
      merge-time automation that ships: carries "## AEP in this tracker" with no
      automation beside it, so it was declared with reference() rather than
      forge(): seed/references/bitbucket.md`. Removed, and the section returned to
      `303 passed, 0 failed`. The set the check runs over is computed from the
      references themselves, and a companion assertion fails if that set is ever
      empty, so rewording the heading cannot leave the check passing on nothing.

- [x] Requirement 5: the rule tying the two together is written where the next
      person adding a forge actually reads it — the comment beside `reference()`
      in `payload.mjs`, which is already where a seed's contract is explained.

      The `reference()` docblock now ends by sending a tracker reference to
      `forge()` and saying why the pair is inseparable. `forge()` carries its own
      docblock immediately below it.

- [x] Requirement 5: the `every file under seed/ is declared in SEEDS` assertion
      covers `seed/automation/`, so an automation file nothing declares fails the
      way an undeclared reference already does. The existing assertion that every
      seed targets a repository-owned directory is scoped rather than widened —
      an automation file does not land in one.

      Observed before the declaration was written: the two new files failed that
      assertion by name, `declared by nothing: seed/automation/github.yml,
      seed/automation/gitlab.yml`. The target assertion is untouched and stays
      correctly scoped: an automation file is a field on a seed rather than a
      seed, so it has no target for that assertion to reach.

- [x] Requirement 10: nothing here installs by itself. An automation file is a
      candidate the next ticket offers, and the installer writes none of it by
      default.

      Two assertions. `an automation file is declared beside a seed and never as
      one` keeps the path out of every `source` and every `target`, and
      `installing writes no automation file` walks the install fixture looking
      for it. Fire-checked by promoting `seed/automation/github.yml` to a seed of
      its own, which printed both: `the installer would write:
      seed/automation/github.yml` and `written on install:
      .aep/references/github.yml`.

## Relevant areas

`src/seed/automation/`, new, holding one file per forge that seeds a reference.
`src/scripts/payload.mjs`, the `reference()` helper and the `SEEDS` catalogue.
`src/scripts/verify.mjs`, the `seeds` section.

## Constraints

**No label the job sets names AEP**, and the names it writes match the vocabulary
already in that repository: its separator, its casing, its prefixing. A tracker is
read by people who never installed AEP.

**The GitLab half ships from documentation, not from a passing run.** Nothing here
runs on GitLab. The token line is what makes a first failure legible rather than
mysterious, which is why its position in the file is an acceptance criterion
rather than a preference.

**The offer is a separate ticket.** This one ships the text and the declaration;
nothing in it writes into a repository, and no skill changes here.

## Notes

The discriminator for *is this reference a tracker* already exists and is already
asserted: `## AEP in this tracker` appears in exactly `github.md` and `gitlab.md`
and in no other seeded reference. A hand-maintained list of forges is the thing
requirement 5 exists to remove, so it is not the answer.

Independent of the three normative and script tickets, which is why it carries no
edge to them.

**How "parses as YAML" is answered with no parser available.** There is no
package manager here, so the suite gained a reader for the subset of block YAML
the two files are written in: block mappings, block sequences, plain and quoted
scalars, `|` and `>` block scalars, and comments. It catches a tab in the
indentation, a key indented under no parent, a duplicate key, and a line that is
neither a mapping entry nor a sequence item. Every structural assertion reads the
tree it returns rather than grepping the text, so a step that drifted out of its
job fails instead of matching somewhere else in the file. It implements no
anchors, aliases, flow collections, tags, multiple documents, or complex keys,
all of which are legal YAML and all of which it rejects: it is stricter than the
format rather than looser, which is the safe direction for a checker, but it
means a seed written with one of those fails this suite rather than the forge. It
also reads `on:` as the string `on` where YAML 1.1 reads the boolean true, which
is why the assertions look that key up by name. What it cannot tell anyone is
whether a forge accepts the file. Only the forge can, and for GitLab nothing in
this repository ever will.

**Raised, not taken.** `shippedArtifacts()` in `release.mjs` collects payload
markdown and every seed `source`, so it never sees an automation file and a
release will not stamp one. Releasing and `src/stamps.json` are outside this
ticket, so it is left for the release ticket rather than fixed here.
