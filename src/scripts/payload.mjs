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
 * A detected reference seed. Every reference is named for its tool, lands at
 * `references/<tool>.md`, and installs only where `paths` — or, for a forge, a
 * git remote — shows the repository actually uses it.
 *
 * `paths` are matched by existence, not by glob, so each variant a tool is
 * commonly configured under is listed explicitly. A detector that guesses wider
 * than that installs a reference for a tool the repository does not have, which
 * is the one failure a seed must not have.
 */
const reference = (tool, paths, remote) => ({
  source: `seed/references/${tool}.md`,
  target: `references/${tool}.md`,
  detect: remote ? { paths, remote } : { paths },
});

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
 *
 * The catalogue below is wide on purpose: a repository that runs a tool gets a
 * starting point for it, and one that does not gets nothing. Breadth costs the
 * installing repository nothing, because the detector decides.
 */
export const SEEDS = [
  { source: 'seed/AGENTS.md', target: 'AGENTS.md', root: true },
  { source: 'seed/contexts/repository.md', target: 'contexts/repository.md' },
  { source: 'seed/rules/version-control.md', target: 'rules/version-control.md' },

  // Version control and forges.
  reference('git', ['.git']),
  reference('github', ['.github'], 'github.com'),
  reference('gitlab', ['.gitlab-ci.yml'], 'gitlab'),
  reference('graphite', ['.graphite_repo_config', '.graphite']),

  // JavaScript package managers and runtimes.
  reference('pnpm', ['pnpm-lock.yaml']),
  reference('npm', ['package-lock.json']),
  reference('yarn', ['yarn.lock']),
  reference('bun', ['bun.lockb', 'bun.lock']),
  reference('deno', ['deno.json', 'deno.jsonc', 'deno.lock']),
  reference('node', ['.nvmrc', '.node-version']),

  // JavaScript and TypeScript quality tooling.
  reference('typescript', ['tsconfig.json', 'tsconfig.base.json']),
  reference('eslint', [
    'eslint.config.js', 'eslint.config.mjs', 'eslint.config.cjs', 'eslint.config.ts',
    '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.json', '.eslintrc.yml', '.eslintrc.yaml',
  ]),
  reference('prettier', [
    '.prettierrc', '.prettierrc.json', '.prettierrc.json5', '.prettierrc.yml',
    '.prettierrc.yaml', '.prettierrc.js', '.prettierrc.mjs', '.prettierrc.cjs',
    'prettier.config.js', 'prettier.config.mjs', 'prettier.config.cjs', 'prettier.config.ts',
  ]),
  reference('biome', ['biome.json', 'biome.jsonc']),

  // Test runners.
  reference('vitest', [
    'vitest.config.ts', 'vitest.config.js', 'vitest.config.mts', 'vitest.config.mjs',
    'vitest.workspace.ts', 'vitest.workspace.js',
  ]),
  reference('jest', [
    'jest.config.js', 'jest.config.ts', 'jest.config.mjs', 'jest.config.cjs',
    'jest.config.mts', 'jest.config.json',
  ]),
  reference('playwright', ['playwright.config.ts', 'playwright.config.js', 'playwright.config.mts']),
  reference('cypress', ['cypress.config.ts', 'cypress.config.js', 'cypress.config.mjs']),
  reference('pytest', ['pytest.ini', 'conftest.py', 'tox.ini']),

  // Bundlers, monorepo orchestration, and application frameworks.
  reference('vite', ['vite.config.ts', 'vite.config.js', 'vite.config.mts', 'vite.config.mjs']),
  reference('webpack', [
    'webpack.config.js', 'webpack.config.ts', 'webpack.config.mjs', 'webpack.config.cjs',
  ]),
  reference('turborepo', ['turbo.json', 'turbo.jsonc']),
  reference('nx', ['nx.json']),
  reference('next', ['next.config.js', 'next.config.mjs', 'next.config.ts', 'next.config.cjs']),
  reference('astro', ['astro.config.mjs', 'astro.config.ts', 'astro.config.js']),
  reference('svelte', ['svelte.config.js', 'svelte.config.ts']),
  reference('nuxt', ['nuxt.config.ts', 'nuxt.config.js', 'nuxt.config.mjs']),
  reference('tailwind', [
    'tailwind.config.js', 'tailwind.config.ts', 'tailwind.config.cjs', 'tailwind.config.mjs',
  ]),
  reference('storybook', ['.storybook']),

  // Desktop and mobile shells.
  reference('tauri', ['src-tauri/tauri.conf.json', 'tauri.conf.json', 'src-tauri/Cargo.toml']),
  reference('electron', [
    'electron-builder.yml', 'electron-builder.yaml', 'electron-builder.json',
    'electron.vite.config.ts', 'forge.config.js', 'forge.config.ts', 'forge.config.cjs',
  ]),
  reference('expo', ['app.config.ts', 'app.config.js', 'app.config.json', 'eas.json']),

  // Other language toolchains.
  reference('cargo', ['Cargo.toml']),
  reference('go', ['go.mod']),
  reference('uv', ['uv.lock']),
  reference('poetry', ['poetry.lock']),
  reference('pip', ['requirements.txt', 'requirements.in', 'requirements-dev.txt']),
  reference('ruff', ['ruff.toml', '.ruff.toml']),
  reference('bundler', ['Gemfile', 'Gemfile.lock']),
  reference('composer', ['composer.json', 'composer.lock']),
  reference('gradle', [
    'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', 'gradlew',
  ]),
  reference('maven', ['pom.xml', 'mvnw']),
  reference('dotnet', [
    'global.json', 'Directory.Build.props', 'Directory.Packages.props',
    'NuGet.config', 'nuget.config',
  ]),
  reference('nix', ['flake.nix', 'shell.nix', 'default.nix']),

  // Databases and schema tooling.
  reference('drizzle-kit', [
    'drizzle.config.ts', 'drizzle.config.js', 'drizzle.config.mts', 'drizzle.config.json',
  ]),
  reference('prisma', ['prisma/schema.prisma', 'schema.prisma']),
  reference('supabase', ['supabase/config.toml']),

  // Containers, infrastructure, and deployment targets.
  reference('docker', [
    'Dockerfile', 'docker-compose.yml', 'docker-compose.yaml', 'compose.yml', 'compose.yaml',
  ]),
  reference('kubernetes', [
    'Chart.yaml', 'kustomization.yaml', 'helmfile.yaml', 'skaffold.yaml',
  ]),
  reference('terraform', [
    '.terraform.lock.hcl', 'main.tf', 'versions.tf', 'terraform.tf', 'providers.tf',
  ]),
  reference('wrangler', ['wrangler.toml', 'wrangler.json', 'wrangler.jsonc']),
  reference('vercel', ['vercel.json', '.vercel']),
  reference('fly', ['fly.toml']),

  // Release automation.
  reference('changesets', ['.changeset']),
  reference('semantic-release', [
    '.releaserc', '.releaserc.json', '.releaserc.yaml', '.releaserc.yml', '.releaserc.js',
    'release.config.js', 'release.config.cjs', 'release.config.mjs',
  ]),

  // Task runners, environments, and git hooks.
  reference('make', ['Makefile', 'makefile', 'GNUmakefile']),
  reference('just', ['justfile', 'Justfile', '.justfile']),
  reference('task', ['Taskfile.yml', 'Taskfile.yaml', 'taskfile.yml', 'taskfile.yaml']),
  reference('mise', ['mise.toml', '.mise.toml', '.config/mise.toml', '.tool-versions']),
  reference('devcontainer', ['.devcontainer', '.devcontainer.json']),
  reference('pre-commit', ['.pre-commit-config.yaml', '.pre-commit-config.yml']),
  reference('husky', ['.husky']),
  reference('lefthook', [
    'lefthook.yml', 'lefthook.yaml', 'lefthook.toml', 'lefthook.json', '.lefthook.yml',
  ]),
];
