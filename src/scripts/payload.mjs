// What a release installs, declared once.
//
// Both the installer and the verification suite read this, so "what ships" has a
// single home. A file that is neither payload, nor seed, nor listed as
// build-only is a verification failure rather than a silent omission — the
// failure this manifest exists to remove is a new protocol artifact that nobody
// installs because nobody remembered to add it to a copy list.

/** Protocol-owned files installed at the root of `.aep/`. */
export const PAYLOAD_FILES = ['protocol.md'];

/** Protocol-owned directories copied wholesale into `.aep/`. */
export const PAYLOAD_DIRS = ['rules', 'modes', 'skills', 'agents', 'templates'];

/** Scripts installed to `.aep/scripts/`, available to every configured repository. */
export const PAYLOAD_SCRIPTS = [
  'contract.mjs',
  'index.mjs',
  'validate.mjs',
  'position.mjs',
];

/**
 * Scripts that build or check the distribution and are never installed.
 * They run from a checkout of the protocol repository, not from `.aep/`.
 */
export const BUILD_ONLY_SCRIPTS = [
  'payload.mjs',
  'adapters.mjs',
  'install.mjs',
  'verify.mjs',
];

/** Source of `.aep/.gitignore`. Kept undotted in the distribution so it governs nothing here. */
export const GITIGNORE_SOURCE = 'gitignore';

/** Directories a repository owns. Created so there is somewhere to put things. */
export const REPOSITORY_DIRS = ['contexts', 'references', 'efforts'];

/** Directories that are per-clone and gitignored. */
export const PER_CLONE_DIRS = ['position', 'worktrees'];

/**
 * Repository-owned starting points.
 *
 * Every one installs as `owner: repository`, is written **once**, and is never
 * touched again by any upgrade — which is what makes shipping a starting point
 * safe. Each is a draft to be corrected, not a description that is already true;
 * they say so in their own first paragraph, because a seeded file that reads as
 * authoritative is worse than no file at all.
 *
 * `detect` gates installation on evidence in the repository. A seed with no
 * `detect` always installs. `paths` matches if any listed path exists; `remote`
 * matches if any git remote URL contains the string.
 *
 * `root: true` targets the repository root rather than `.aep/`. Exactly one seed
 * needs it — the entrypoint, which the harness loads by name and therefore
 * cannot live inside `.aep/`. Being outside the tree, it carries no AEP
 * frontmatter: it is the repository's own file from the moment it is written.
 */
export const SEEDS = [
  { source: 'seed/AGENTS.md', target: 'AGENTS.md', root: true },
  { source: 'seed/contexts/repository.md', target: 'contexts/repository.md' },
  { source: 'seed/rules/version-control.md', target: 'rules/version-control.md' },

  { source: 'seed/references/git.md', target: 'references/git.md', detect: { paths: ['.git'] } },
  {
    source: 'seed/references/github.md',
    target: 'references/github.md',
    detect: { paths: ['.github'], remote: 'github.com' },
  },
  {
    source: 'seed/references/gitlab.md',
    target: 'references/gitlab.md',
    detect: { paths: ['.gitlab-ci.yml'], remote: 'gitlab' },
  },
  {
    source: 'seed/references/graphite.md',
    target: 'references/graphite.md',
    detect: { paths: ['.graphite_repo_config', '.graphite'] },
  },
  {
    source: 'seed/references/pnpm.md',
    target: 'references/pnpm.md',
    detect: { paths: ['pnpm-lock.yaml'] },
  },
  {
    source: 'seed/references/npm.md',
    target: 'references/npm.md',
    detect: { paths: ['package-lock.json'] },
  },
  {
    source: 'seed/references/yarn.md',
    target: 'references/yarn.md',
    detect: { paths: ['yarn.lock'] },
  },
  {
    source: 'seed/references/bun.md',
    target: 'references/bun.md',
    detect: { paths: ['bun.lockb', 'bun.lock'] },
  },
  {
    source: 'seed/references/docker.md',
    target: 'references/docker.md',
    detect: {
      paths: [
        'Dockerfile',
        'docker-compose.yml',
        'docker-compose.yaml',
        'compose.yml',
        'compose.yaml',
      ],
    },
  },
  {
    source: 'seed/references/make.md',
    target: 'references/make.md',
    detect: { paths: ['Makefile', 'makefile', 'GNUmakefile'] },
  },
];
