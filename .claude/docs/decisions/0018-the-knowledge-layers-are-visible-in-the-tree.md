# The knowledge layers are visible in the tree

Supersedes the layout stated in `0006`, which grouped decisions, designs, research, and prototype write-ups under `.claude/docs/`. Only its layout is superseded — `0006`'s ruling that everything lives under `.claude/` with the root `CLAUDE.md` as the sole entrypoint stands.

`docs/` dissolves. Decisions and designs move up to sit beside Context, and research and prototype write-ups group under `evidence/`. The reason is that `CLAUDE.md` presents Codebase, Context, and Decisions as three peer Knowledge Layers on the first page a reader sees, and the tree then buried the third one a directory below the second — so the filesystem contradicted the model at the point of first contact. `evidence/` survives as a grouping directory because Evidence is a defined term that means something specific here: material that records what was verified and when, which nothing validates afterwards. It groups things that share a property, which is what `docs/` never did.

## Considered Options

Flattening all four kinds to the top was rejected: it collides with the throwaway-code directory, forcing that to be renamed, and produces four siblings with nothing stating how they relate. Moving only decisions up was rejected as relocating the inconsistency rather than resolving it. Leaving `docs/` alone was defensible on the grounds that the level stops looking redundant once all four are populated — but that argues the redundancy is temporary, not that the depth is correct, and the depth is the actual complaint.

## Consequences

Throwaway prototype code and prototype write-ups stop being distinguished by a level whose name says nothing about the difference. The write-up now sits under `evidence/`, which is precisely what distinguishes it from the code, and the two are no longer one word apart at the same depth with opposite gitignore status.

Every repository already running Tenure needs migrating, and `/configure` carries it. ADR numbers and slugs are preserved across the move — inbound references to `0007` keep resolving — which is the same rule that governed migrating ADRs in from another layout.
