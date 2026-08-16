---
aep: 2.1.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, review]
use-when: "a change to a published package needs a version note, or a release is being prepared"
---

# Reference — Changesets

**This file is yours.** Installed because a `.changeset` directory was detected.
Record which packages are published and which are private — only the published
ones need a changeset.

## Commands

```sh
npx changeset                    # interactive; writes a markdown file under .changeset/
npx changeset status             # what is pending, and what version it implies
npx changeset version            # consumes the pending changesets: bumps versions, writes changelogs
npx changeset publish            # PUBLISHES to the registry
```

| Purpose | Command |
| --- | --- |
| add a changeset | `npx changeset` |
| what is pending | `npx changeset status` |

## What to write, and when

A change to a published package usually needs a changeset, and CI often fails
without one. The interactive command is awkward in an automated run — **writing
the file directly is fine**, and it is the ordinary way to do it here:

```markdown
---
"<package-name>": patch
---

One sentence, in the voice of the changelog, describing what changed for
someone consuming the package.
```

Pick the bump from the effect on consumers, not from the size of the diff: a
one-line change that alters a signature is `major`; a large internal refactor
that changes nothing observable is `patch`.

## Never run

**`changeset version` and `changeset publish` are release operations.**
`version` rewrites every affected `package.json` and changelog; `publish` reaches
the registry and cannot be undone. Both belong to the human or to CI
(`[[rules/version-control]]`).
