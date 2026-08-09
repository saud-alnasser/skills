# Decision map

| ADR | Load when | Status | Sources |
| --- | --- | --- | --- |
| [0001](0001-vendor-mattpocock-skills-rather-than-rewrite.md) | a shipped skill's derivation or attribution is in question | superseded | `skills/` |
| [0002](0002-routing-table-not-tags-for-context-loading.md) | context loading is being changed, or frontmatter is proposed for routing | accepted | `.claude/contexts/` |
| [0003](0003-knowledge-at-root-machinery-in-dot-claude.md) | the placement of knowledge at the repository root is argued from history | superseded | `.claude/` |
| [0004](0004-drift-model.md) | drift is being detected, or its scope decided | accepted | `.claude/protocol.md` |
| [0005](0005-sync-moves-to-the-front-knowledge-owned-by-type.md) | which stage may write which knowledge layer is being changed | superseded | `.claude/policies/knowledge.md` |
| [0006](0006-everything-under-dot-claude-root-claude-md-is-the-entrypoint.md) | something is proposed at the repository root rather than under .claude/ | accepted | `CLAUDE.md`, `.claude/` |
| [0007](0007-tenure-owns-the-engineering-rules.md) | a rule is being placed | accepted | `.claude/rules/` |
| [0008](0008-repo-conventions-outrank-tenure-defaults.md) | an AEP default conflicts with what this repository already does | accepted | `.claude/policies/` |
| [0009](0009-prototype-code-is-always-deleted.md) | prototype code is about to be kept | accepted | `skills/prototype/` |
| [0010](0010-sync-dissolves-into-verification-at-use.md) | a synchronisation or reconciliation pass is proposed | accepted | `.claude/protocol.md` |
| [0011](0011-design-is-the-whole-planning-surface.md) | planning work is proposed outside /design | accepted | `skills/design/` |
| [0012](0012-position-and-the-shared-local-line.md) | a file under .claude/ is about to be committed or ignored | accepted | `.claude/.gitignore`, `.claude/position/` |
| [0013](0013-assignment-and-claim-the-branch-is-the-lock.md) | who is building a ticket right now has to be recorded somewhere | accepted | `skills/implement/` |
| [0014](0014-the-shared-trackers-contract.md) | something is about to be written to a tracker other people read | accepted | `.claude/policies/tracker.md` |
| [0015](0015-tenure-ships-as-a-plugin.md) | how AEP is installed or distributed is in question | accepted | `.claude-plugin/` |
| [0016](0016-on-a-stack-blocked-means-stacked.md) | a blocked ticket is being scheduled on a stacking repository | accepted | `.claude/policies/version-control.md` |
| [0017](0017-phase-2-closes-by-adoption-not-execution.md) | an effort is being closed while its obligations are unfinished | accepted | `.claude/tickets/` |
| [0018](0018-the-knowledge-layers-are-visible-in-the-tree.md) | the directory layout under .claude/ is being changed | accepted | `.claude/` |
| [0019](0019-tool-references-are-derived-per-repository.md) | a tool reference is being written, or a tools skill is proposed | accepted | `.claude/tools/` |
| [0020](0020-policy-and-invocation-are-separate-files.md) | a policy and the invocations that serve it are being put in one file | accepted | `.claude/policies/`, `.claude/tools/` |
| [0021](0021-instructions-load-in-three-tiers-selected-by-mechanism.md) | an instruction is being placed, or its per-turn cost is in question | accepted | `.claude/rules/`, `.claude/policies/` |
| [0022](0022-claude-md-is-a-pointer-and-plugin-independence-is-about-readability.md) | the entrypoint is being added to, or plugin independence is in question | accepted | `CLAUDE.md` |
| [0023](0023-compression-keeps-the-surprising-why-and-verify-is-the-fidelity-floor.md) | text is being compressed, or a claim is about to be dropped for brevity | accepted | `scripts/verify.ps1` |
| [0024](0024-implement-commits-after-review-without-asking.md) | whether a stage should prompt before committing is in question | accepted | `skills/implement/` |
| [0025](0025-the-templates-change-before-the-repository-adopts-them.md) | a shipped template and its installed copy are both about to change | accepted | `skills/configure/` |
| [0026](0026-a-fixture-tests-the-migration-and-the-revert-is-dropped.md) | the migration's own test strategy is in question | accepted | `skills/configure/MIGRATION.md` |
| [0027](0027-a-discussion-is-a-fourth-kind-of-evidence.md) | a grill ends without reaching a decision | accepted | `.claude/evidence/` |
| [0028](0028-a-stages-posture-ships-with-the-stage.md) | a reasoning posture is proposed as derived per repository | accepted | `.claude/modes/` |
| [0029](0029-specs-md-is-the-normative-specification.md) | the specification and what ships disagree | accepted | `specs.md` |
| [0030](0030-streamline-is-superseded-by-the-aep-effort.md) | an effort's open obligations have to move to another effort | accepted | `.claude/tickets/` |
| [0031](0031-spec-21-gains-designs-and-the-ignore-file.md) | the specification's layout section is being amended | accepted | `specs.md` |
| [0032](0032-modes-live-in-their-own-directory.md) | where a mode's text lives is in question | accepted | `.claude/modes/` |
| [0033](0033-configure-writes-the-formatter-exclusion-outside-dot-claude.md) | a formatter's reach includes .claude/ | accepted | `skills/configure/SKILL.md` |
| [0034](0034-the-rename-to-agentic-stops-at-frozen-records.md) | a rename would touch a Decision or a resolved ticket | accepted | `.claude/decisions/` |
| [0035](0035-what-a-ticket-is-is-a-declared-tracker-fact.md) | the tracker's declaration of what a ticket is has to be read or changed | accepted | `.claude/policies/tracker.md` |
| [0036](0036-the-build-lifecycle-rides-native-issue-state-on-github.md) | a ticket's state has to be expressed on GitHub | accepted | `.claude/tools/github.md` |
| [0037](0037-a-build-ticket-may-declare-a-design-increment.md) | a plan meets a decision only partial code can answer | accepted | `.claude/policies/tickets.md` |
| [0038](0038-protocol-scaffolding-is-never-its-own-unit-of-work.md) | work whose whole effect sits under .claude/ is about to be ticketed | accepted | `.claude/policies/tickets.md` |
| [0039](0039-a-drift-finding-is-evidence-indexed-on-the-live-map.md) | drift is found that cannot be healed on the spot | accepted | `.claude/evidence/drift/` |
| [0040](0040-orchestration-is-a-system-and-the-subagent-contract-is-a-policy.md) | where the sub-agent contract belongs is in question | accepted | `.claude/policies/sub-agents.md` |
| [0041](0041-a-child-that-reaches-a-decision-stops.md) | a dispatched child meets a decision it cannot make | accepted | `.claude/policies/sub-agents.md` |
| [0042](0042-the-brief-is-a-template-and-the-return-is-a-change-record.md) | what passes between an orchestrator and a child is being changed | accepted | `.claude/policies/sub-agents.md` |
| [0043](0043-roles-ship-by-name-the-ticket-declares-the-fan-out.md) | a fan-out is being declared on a ticket | accepted | `agents/` |
| [0044](0044-a-child-branches-from-the-claim-and-the-record-drives-integration.md) | a child's worktree base is in question | accepted | `.claude/settings.json` |
| [0045](0045-spec-21-gains-the-harness-settings-file.md) | the specification's layout section is being amended | accepted | `specs.md` |
| [0046](0046-ticket-orchestration-is-a-second-axis-and-its-failure-rule-inverts.md) | several tickets are to be built at once | accepted | `skills/implement/` |
| [0047](0047-the-parent-holds-every-claim-in-a-dispatched-set.md) | the branches for a dispatched set are being created | accepted | `skills/implement/` |
| [0048](0048-collisions-are-resolved-by-the-orchestrator-informed-by-both-records.md) | two children wrote the same path | accepted | `skills/implement/` |
| [0049](0049-the-orchestrator-brokers-what-a-child-may-not-do-itself.md) | a child needs something it is not permitted to do itself | accepted | `.claude/policies/sub-agents.md` |
| [0050](0050-spec-21-names-the-harness-worktree-directory.md) | the ignore file or the layout omits a directory something writes | accepted | `.claude/.gitignore` |
| [0051](0051-the-commit-unit-here-is-the-effort.md) | a branch or a commit is about to be created for a ticket | accepted | `.claude/policies/version-control.md` |
| [0052](0052-the-marker-records-the-tree-and-claims-only-that-drift-was-read.md) | the Marker's contents, or what a match licenses, is in question | accepted | `.claude/protocol.md` |
| [0053](0053-a-routing-table-is-generated-from-fields-the-routed-file-declares.md) | a routing table or a declared field is being changed | accepted | `.claude/policies/context.md` |
| [0054](0054-the-stage-dependency-set-has-two-homes-and-the-protocol-table-wins.md) | a stage's dependencies are stated in more than one place | accepted | `.claude/protocol.md` |
| [0055](0055-aep-fields-ride-the-harness-metadata-map.md) | AEP needs a field of its own on something it ships, or a shipped fact is stated as a body line | accepted | `skills/`, `agents/`, `.claude/evidence/research/2026-08-05-frontmatter-extension-points-for-skills-and-agents.md` |
| [0056](0056-one-generated-index-per-family-not-per-directory.md) | an index is being added for a directory, or a declared field looks like it restates a path | accepted | `.claude/evidence/`, `.claude/policies/evidence.md` |
| [0057](0057-one-regenerator-enforced-by-comparison.md) | a generated index needs to be produced, or something proposes to maintain one | accepted | `.claude/scripts/`, `.claude/policies/context.md` |
| [0058](0058-a-local-ticket-declares-its-facts-a-forge-issue-does-not.md) | a ticket's lifecycle facts are being read or written, or the two tracker forms look inconsistent | accepted | `.claude/policies/tickets.md`, `.claude/tickets/` |
| [0059](0059-a-per-effort-map-lives-in-its-effort-directory.md) | a generated index or a fog map needs a path, or `.claude/tickets/map.md` is in question | accepted | `.claude/policies/maps.md`, `specs.md`, `.claude/tickets/` |
| [0060](0060-the-regenerator-is-derived-from-a-behavioural-specification.md) | something AEP ships needs to exist as code in a configured repository, or the regenerator's source of truth is in question | accepted | `skills/configure/`, `.claude/decisions/0057-one-regenerator-enforced-by-comparison.md` |
| [0061](0061-unplanned-work-enters-the-spine-from-the-boot-tier.md) | a request has to reach a stage without the user naming it, or which invocation axis a skill sits on is in question | accepted | `CLAUDE.md`, `skills/configure/CLAUDE.template.md`, `skills/design/SKILL.md`, `scripts/verify.ps1` |
| [0062](0062-continuation-is-bounded-by-the-plans-declared-increments.md) | a build run has to decide whether to take another ticket, or how far autonomous work may go before stopping | accepted | `skills/implement/SKILL.md`, `specs.md`, `.claude/policies/tickets.md` |
| [0063](0063-two-on-ramps-cross-to-selection-and-the-exemption-is-one-test.md) | which invocation axis a skill sits on is in question, or a skill is proposed as exempt from selection | accepted | `skills/triage/SKILL.md`, `skills/survey/SKILL.md`, `.claude/protocol.md`, `.claude/tickets/entry/spec.md`, `scripts/verify.ps1` |
| [0064](0064-the-release-check-is-a-hook-because-only-shipped-content-knows-the-release.md) | something needs a fact only the running framework holds, or a new plugin component is proposed | accepted | `hooks/hooks.json`, `hooks/check-version.js`, `.claude/protocol.md`, `.claude/evidence/research/2026-08-09-reading-the-plugin-version-from-a-running-stage.md`, `.claude/decisions/0060-the-regenerator-is-derived-from-a-behavioural-specification.md` |
| [0065](0065-the-audit-is-bounded-by-a-version-cursor.md) | a repair is being added to the configuration stage, or which repairs an audit should run is in question | accepted | `skills/configure/migration-changelog.md`, `skills/configure/SKILL.md`, `skills/configure/MIGRATION.md`, `.claude/decisions/0064-the-release-check-is-a-hook-because-only-shipped-content-knows-the-release.md` |
| [0066](0066-attribution-rides-vendored-material-not-derived-structure.md) | attribution to the upstream project is being added, removed, or questioned | accepted | `NOTICE`, `skills/`, `agents/`, `.claude/rules/skills.md` |
