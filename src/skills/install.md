---
use-when: "a repository has no .aep/ directory and should start running AEP"
---

# /install — join a repository to AEP

Creates `.aep/`, installs the protocol-owned payload, seeds the repository-owned
starting points that this repository's setup calls for, and optionally writes
whichever runtime adapters the repository asks for.

## Before anything

**Check whether AEP is already installed — under either layout.**

- `.aep/protocol.md` exists → this is `[[skills/update]]`'s job. Running install
  over a live installation risks exactly the repository-owned artifacts
  `[[policies/artifacts]]` requires be preserved.
- A **1.x layout** — a protocol file, `policies/`, `decisions/`, or `designs/`
  under a runtime's own directory — → also `[[skills/update]]`, which converts
  it. 1.x has no `.aep/`, so the first check answers *not installed* and is
  wrong; a fresh install here would leave a 2.0 tree beside a live 1.x one and
  **orphan every context, spec, ticket, and decision the repository had.** The
  installer refuses this, so the check below will stop you — but knowing why
  costs less than reading the error.

## Procedure

1. **Install the payload and the seeds** — one command, from the AEP
   distribution:

   ```
   node <distribution>/scripts/install.mjs --into <repository>
   ```

   It writes `protocol.md`, `policies/`, `skills/`, `agents/`, `templates/`,
   `scripts/`, and `.aep/.gitignore` verbatim — everything the release ships,
   which it knows by exact path. It **writes nothing outside that set**, so
   `rules/`, `contexts/`, `references/`, and `efforts/` are yours and stay
   untouched, and it reports anything of yours found standing where the protocol
   ships.

   It then seeds the repository-owned starting points, **each only where the
   evidence is there**:

   | Seeded | On detecting |
   | --- | --- |
   | `rules/version-control.md`, `contexts/repository.md` | always |
   | one reference per tool, under `references/` | that tool's own evidence — a lockfile, a configuration file, a remote host |

   The reference catalogue is wide: version control and forges, package managers
   and runtimes, linters and formatters, test runners, bundlers and monorepo
   orchestration, application frameworks, desktop and mobile shells, the other
   language toolchains, database and schema tooling, containers, infrastructure
   and deployment targets, release automation, task runners and git hooks.

   **Read the installer's report rather than assuming which arrived** — it names
   every seed it wrote and every one it skipped, and a wide catalogue makes
   guessing worse, not better.

   A seed already present is left alone. **Seeds are written once and never
   revisited** — that is what makes shipping them safe.

2. **Correct the seeds — this is the real work.** Each one arrives as a draft
   that says so in its first paragraph. Go through every seeded file and replace
   what was assumed with what is true: the actual scripts from `package.json` and
   CI, the actual test invocation, the actual branch convention, how work
   actually reaches the default branch.

   **A seeded command that this repository does not have is worse than no
   reference**, because it will be trusted (`[[policies/engineering]]`). Delete what
   you cannot confirm.

   **Delete a reference outright where the tool is configured but not used.** A
   detector fires on a configuration file, and an abandoned one is evidence
   enough for the installer and not enough for a reference.

3. **Fill in `contexts/repository.md`** — what this repository is, its shape, its
   vocabulary. Keep it small; areas earn their own context later.

4. **Initialize position**: `node .aep/scripts/position.mjs stamp`.

5. **Generate the index**: `node .aep/scripts/index.mjs`.

6. **Check the entrypoint.** The installer writes `AGENTS.md` at the repository
   root from the entrypoint seed **only where there is none** — an entrypoint
   that already exists is the repository's, and may carry instructions predating
   AEP.

   - **Written fresh:** replace its first line with what this repository actually
     is. The rest already points where it should.
   - **Already there:** add a *Start here* section pointing at
     `.aep/protocol.md`, and change nothing else. `[[templates/agents.template]]`
     has the shape, and the same shape covers a second runtime's entrypoint —
     `CLAUDE.md` or its equivalent — which is one line pointing at `AGENTS.md`.

   **Never restate protocol.md's content there.** A summary in the entrypoint is
   a second home, and it is the copy that drifts (`[[policies/artifacts]]`).

7. **Offer a runtime adapter.** Ask first — files outside `.aep/` belong to the
   repository. `--adapters <names>` takes a comma-separated list and writes
   wrappers that point at `.aep/`, so the skills are reachable with nothing else
   installed:

   | Name | Writes | Read by |
   | --- | --- | --- |
   | `claude` | `.claude/skills/` and `.claude/agents/` | Claude Code |
   | `opencode` | `.opencode/skills/` and `.opencode/agents/` | OpenCode |
   | `agents` | `.agents/skills/` | OpenCode, and harnesses that drive some other runtime |

   **`opencode` and `agents` are alternatives rather than a pair.** OpenCode
   reads both locations, so asking for both registers every skill twice under one
   name and the runtime picks between them without saying which. Offer `agents`
   where the repository is driven through a harness whose provider is not
   OpenCode, and `opencode` otherwise. The installer warns rather than refusing,
   because a repository can genuinely need both — but it is not the default and
   it is never offered as one.

   **Offer nothing for a runtime whose plugin already publishes the skills.**
   Both routes register the same eighteen, with the same doubling. The plugin
   travels with the user across repositories; the committed adapter travels with
   the repository across users. Pick by which of those the repository needs, and
   say which was picked.

8. **Validate**, and report the output:

   ```
   node .aep/scripts/validate.mjs
   ```

9. **Name what still needs a human**: which seeds were installed and remain
   unverified, what `contexts/` lacks, and which rules this repository will want
   to add that AEP cannot know about.

## Constraints

- **MUST preserve every existing `owner: repository` artifact.** If any exist,
  this is an update.
- **Do not commit.** Show the human what was written and let them.
- **Do not invent a reference** for a tool this repository does not use. An empty
  `references/` is honest; a speculative one is a trap.

## Done when

`validate.mjs` passes, the index is generated, the entrypoint points at
`protocol.md`, every seed has been corrected or deleted, and the human has seen
what was assumed on their behalf.
