---
use-when: "a repository has no .aep/ directory and should start running AEP"
---

# /install — join a repository to AEP

Creates `.aep/`, installs the protocol-owned payload, seeds the repository-owned
starting points this repository calls for, and writes the runtime adapters it
asks for.

## Before anything

Check whether AEP is already installed, **under either layout**:

- `.aep/protocol.md` exists: this is `[[skills/update]]`'s job.
- A **1.x layout** (a protocol file, `policies/`, `decisions/`, or `designs/`
  under a runtime's own directory): also `[[skills/update]]`, which converts
  it. A fresh install there would orphan every context, spec, ticket, and
  decision the repository had; the installer refuses it.

## Procedure

1. **Install the payload and the seeds**, from the AEP distribution:

   ```
   node <distribution>/scripts/install.mjs --into <repository>
   ```

   It writes `protocol.md`, `policies/`, `skills/`, `agents/`, `templates/`,
   `scripts/`, and `.aep/.gitignore` verbatim, by exact path, and **nothing
   outside that set**. It reports anything of yours standing where the protocol
   ships. It then seeds, **each only where the evidence is there**:

   | Seeded | On detecting |
   | --- | --- |
   | `.aep/rules/version-control.md`, `.aep/contexts/repository.md` | always |
   | one reference per tool, at `.aep/references/<tool>.md` | that tool's own evidence: a lockfile, a configuration file, a remote host |

   The catalogue is wide (version control and forges, package managers,
   linters, test runners, bundlers, frameworks, databases, containers,
   deployment, release automation, task runners, hooks). **Read the installer's
   report** for which seeds arrived and which were skipped; never assume. A seed
   already present is left alone: **seeds are written once and never
   revisited.**

2. **Correct the seeds: this is the real work.** Each arrives as a draft saying
   so. Replace what was assumed with what is true: the actual scripts from
   `package.json` and CI, the test invocation, the branch convention, how work
   reaches the default branch. **A seeded command this repository does not have
   is worse than none**, because it will be trusted: delete what you cannot
   confirm. **Delete a reference outright where the tool is configured but not
   used.**

3. **Set the settings** in `.aep/rules/version-control.md`'s frontmatter:
   - `tracker:` stays `none` unless the human asks for issues, pull requests,
     and labels on a forge; then `github` or `gitlab`.
   - `setup:` takes the command that readies a fresh worktree (`pnpm install
     --frozen-lockfile`, `cargo fetch`), or stays empty.
   - `stack: true` where a stacking tool submits changes.

4. **Fill in `.aep/contexts/repository.md`**: what this repository is, its
   shape, its vocabulary. Keep it small; areas earn their own context later.

5. **Initialize position**: `node .aep/scripts/position.mjs stamp`.

6. **Generate the index**: `node .aep/scripts/index.mjs`.

7. **Check the entrypoints.** The installer writes two kinds, and overwrites
   neither:

   | | Written | Where one already exists |
   | --- | --- | --- |
   | **`AGENTS.md`**, the canonical entry | from the entrypoint seed, only where there is none | left exactly as it is |
   | **one per targeted runtime** that reads something else (`CLAUDE.md` for Claude Code) | as a pointer to `AGENTS.md`, and nothing else | the pointer is appended; the rest is untouched |

   **Which file a runtime reads is the installer's to know**, from its target
   table; a runtime that reads `AGENTS.md` gets no second file. **Left for you:**
   `AGENTS.md`'s first line, which says what this repository is. **A pointer
   names `AGENTS.md` and nothing under `.aep/`; never restate `protocol.md` in
   any entrypoint.**

8. **Offer a runtime adapter.** Ask first: files outside `.aep/` belong to the
   repository. `--adapters <names>` takes a comma-separated list and writes
   wrappers pointing at `.aep/`:

   | Name | Writes | Read by |
   | --- | --- | --- |
   | `claude` | `.claude/skills/`, `.claude/agents/`, and `.claude/settings.json` guardrails | Claude Code |
   | `opencode` | `.opencode/skills/` and `.opencode/agents/` | OpenCode |
   | `agents` | `.agents/skills/` | OpenCode, and harnesses driving some other runtime |

   **`opencode` and `agents` are alternatives**: OpenCode reads both, so both
   registers every skill twice. Offer `agents` under a harness whose provider is
   not OpenCode, `opencode` otherwise; never both by default. **Offer nothing for
   a runtime whose plugin already publishes the skills**: the plugin travels with
   the user, the adapter with the repository. Pick by which the repository
   needs, and say which.

   The `claude` guardrails deny edits to places that never hold a project and
   turn on the runtime's sandbox where the platform supports it. They back up the
   protocol's write boundary; they never replace it. A `.claude/settings.json`
   that exists is merged into, never replaced.

9. **Tracker steps: only where `tracker:` is on.** With `tracker: none`, skip
   both and say they were skipped.

   **a. The label vocabulary.** Read the forge's labels first (`[[references]]`):

   | The tracker carries | Do |
   | --- | --- |
   | only its own defaults | offer the seeded set, saying that accepting it **removes the defaults** |
   | labels of its own | create **only what is missing**, in that repository's naming style |

   **Show the exact names and descriptions before creating anything**, and
   create nothing on a refusal. A description states the trigger that puts the
   label on; a `size:` label carries its thresholds. **Nothing created names
   AEP.**

   **b. The merge-time job**, which moves the label when a human merges.
   **Read `[[rules/version-control]]` first**: where it records the job as
   declined, say so and **do not offer again**. Otherwise show the offer:

   ```
   node <distribution>/scripts/install.mjs --into <repository> --update --automation <forge> --dry-run
   ```

   It prints what the forge needs provisioned first (GitLab: a project access
   token with `api` scope, which is the human's to create; GitHub: nothing),
   then where the job lands, then the text. Where a workflow already assigns
   labels, the offer is **an addition to that file**, quoted exactly; where that
   file's shape cannot take it, the installer names the obstacle and proposes
   nothing, and that file is the human's judgement. The offer adds a job and
   changes nothing else.

   Ask. **On acceptance**, re-run without `--dry-run` for a new file, or make
   the quoted addition yourself; the installer never edits a file the
   repository owns. **On a refusal**, write nothing, and record it in
   `[[rules/version-control]]`, in the repository's words, naming the forge and
   the date, beginning with this sentence exactly:

   ```
   The merge-time status job is declined.
   ```

   It is a recorded decision, not a deviation.

10. **Validate**, and report the output: `node .aep/scripts/validate.mjs`.

11. **Name what still needs a human**: the seeds installed and unverified,
    `AGENTS.md`'s first line, what `contexts/` lacks, and the rules this
    repository will want that AEP cannot know.

## Constraints

- **MUST preserve everything the repository owns**: `rules/`, `contexts/`,
  `references/`, `efforts/` (`[[policies/artifacts]]`). If any holds anything,
  this is an update.
- **Do not commit.** Show the human what was written.
- **Never invent a reference** for a tool this repository does not use.

## Done when

`validate.mjs` passes, the index is generated, the entrypoint points at
`protocol.md`, every seed is corrected or deleted, and the human has seen what
was assumed on their behalf.
