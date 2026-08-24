// What a release installs, and what it moved to get there, declared once.
//
// Both the installer and the verification suite read this, so "what ships" has a
// single home. A file that is neither payload, nor seed, nor listed as
// build-only is a verification failure rather than a silent omission. The
// failure this manifest exists to remove is a new protocol artifact that nobody
// installs because nobody remembered to add it to a copy list.
//
// `MOVES` is the exception to the file's title and sits here deliberately: a
// move is not a thing a release installs, it is an instruction about a tree that
// already exists. It belongs beside the payload because it is read by the same
// two callers and describes the same release, and giving it its own module would
// buy separation nobody needs at the cost of a second import for one array.

/** Protocol-owned files installed at the root of `.aep/`. */
export const PAYLOAD_FILES = ['protocol.md'];

/** Protocol-owned directories copied wholesale into `.aep/`. */
export const PAYLOAD_DIRS = ['policies', 'skills', 'agents', 'templates'];

/**
 * Protocol-owned files a release moved, and where their content now ships.
 *
 * A move is not a retirement. `copyDir` reports a protocol-owned file the
 * release no longer ships and never deletes it, because deciding a file is
 * obsolete is a human's call: right for a concept that was dropped, and wrong
 * for one that only changed address. Left in place, the old file keeps
 * resolving, and the tree is governed by two copies of one text.
 *
 * So the release declares its moves and the installer applies them under
 * `--update`: it removes the protocol-owned source, repairs the links that
 * pointed at it, and reports both. One declaration drives the removal, the
 * rewrite, and the verification, so the three cannot disagree.
 *
 * `since` is the release that made the move. An entry may be dropped once no
 * supported tree predates it. A manifest that only grows is one nobody prunes.
 *
 * `was` is what the protocol's version of that file hashed to when it moved,
 * under the same content hash a release stamps with. Ownership is otherwise a
 * fact about location, and a move source is the one path location cannot answer
 * for: the file is gone from the payload, so the manifest does not name it, and
 * a repository is entitled to write its own file under a name the protocol
 * vacated. Content answers what location cannot. A match is the protocol's
 * leftover and is removed; anything else is somebody's work and is reported and
 * left alone.
 *
 * The nine here were recovered from the commit that removed them. **A new move
 * without a `was` is a defect**, and the suite says so: without it the installer
 * is back to deleting a file it cannot identify.
 */
export const MOVES = [
  { from: 'rules/precedence.md', to: 'policies/authority.md', since: '2.2.0', was: 'ed2d2ab2056a234382967bceb28e2140665a0c3f967af2f421bfe23d7cfcb140' },
  { from: 'rules/boundary.md', to: 'policies/authority.md', since: '2.2.0', was: 'e7b2521f8ab240c3bf1da89722444bba87cfcd6595bb3a81a1338cb0ca252d5f' },
  { from: 'rules/engineering.md', to: 'policies/engineering.md', since: '2.2.0', was: '184a48399e02cf56ec3c29d6b1845a71d3411013dd52523600b4de71a01ef3c9' },
  { from: 'rules/evidence.md', to: 'policies/engineering.md', since: '2.2.0', was: 'ca94f29efe6c786b0824de4e36e8d7e57e0442381d43a8ded46f60cd17d767bd' },
  { from: 'rules/change-control.md', to: 'policies/execution.md', since: '2.2.0', was: '95c012cdec66b27ab025c591659a880484895cc9e4ff5864d07fe5412beb872d' },
  { from: 'rules/sub-agents.md', to: 'policies/execution.md', since: '2.2.0', was: 'e144175d0c08a0694dc6a15e997edd45646b031151f301fe31f2997bf9098e62' },
  { from: 'rules/artifacts.md', to: 'policies/artifacts.md', since: '2.2.0', was: '84c08a0cd9ee9473f8c18e475c6617757ad9f0a5b7c32b767fda3bc7953be6fa' },
  { from: 'rules/ownership.md', to: 'policies/artifacts.md', since: '2.2.0', was: 'fd91ca623bbd60c9fa990cbf996dd940fc5ad6bd952baea3fbd2417be59d8753' },
  { from: 'rules/placement.md', to: 'policies/artifacts.md', since: '2.2.0', was: 'd2bc66fbd7e39479ac52b18e64c2a3459bc8a1a871e946f915ce2f00d0bf905b' },
];

/**
 * What a release asks of the **reader**, where moving files is not enough.
 *
 * `MOVES` covers everything a release does to a tree. Some releases also require
 * something a release cannot do for itself, most often because the thing to
 * change is repository-owned, and an upgrade correctly refuses to touch it. That
 * knowledge exists at release time and has nowhere to go: `CHANGELOG.md` is not
 * payload, so a repository running an upgrade has never received it.
 *
 * A notice is that knowledge, declared, and filtered by exactly the predicate
 * `MOVES` uses, so the two cannot disagree about which releases a tree is
 * crossing. A tree already at or past `since` is shown nothing.
 *
 * `check` is an instruction, not a changelog entry. It says what to look at and
 * why it matters. **A release with nothing to ask of the reader declares no
 * notice**, and most releases will not.
 */
export const NOTICES = [
  {
    since: '3.0.0',
    check:
      'modes/ is gone. A mode existed to state a posture, its mindset and what that ' +
      'mindset gives up, and every one of those now sits inside the skill that used to ' +
      'enter it, where it is read at the moment it applies rather than fetched. Delete ' +
      '.aep/modes/: validate.mjs now fails a tree that still has one, because a ' +
      'directory nothing ships and nothing links to is a second copy of text the skills ' +
      'now carry. If you wrote a mode of your own, its content belongs in your own skill ' +
      'or rule. Nothing under modes/ is preserved by the upgrade, and nothing there is ' +
      'deleted for you either.',
  },
  {
    since: '2.7.0',
    check:
      'Text an agent writes for you is now governed. policies/reporting covered the turn ' +
      'report and now covers everything a human reads: session output, commit messages, pull ' +
      'request titles and bodies, comments in source, and your own documentation. It fixes ' +
      'four things a script can check, no em dashes among them, and the new skills/prose ' +
      'carries the rest as craft rather than law. If your own rules say anything about how ' +
      'prose reads here, reconcile them now: a rule may tighten a policy and never soften ' +
      'one, so a rule permitting what the policy prohibits is the thing to look for. No file ' +
      'you own changes, and nothing starts failing validation.',
  },
  {
    since: '2.5.0',
    check:
      'A context now sits at contexts/<area>.md or contexts/<project>/<area>.md, one project ' +
      'directory deep, and no more. The nested form is for a monorepo, where two projects would ' +
      'otherwise fight over the same area name; the directory holds the name, while paths: still ' +
      'decides when the context loads. If you have a context nested deeper than that, ' +
      'validate.mjs now fails it: move it up to contexts/<project>/<area>.md, or flatten it. ' +
      'The upgrade will not move it for you, since contexts/ is yours, and an upgrade never edits a ' +
      'file you own. A flat tree needs no change at all.',
  },
  {
    since: '2.4.0',
    check:
      'Skills you wrote yourself now need one more frontmatter field: report: full, or ' +
      'report: short, if the skill neither writes to the repository, dispatches a sub-agent, ' +
      'nor decides anything on your behalf. It says which form that skill\'s turn report takes, ' +
      'and validate.mjs fails a skill without one, because a skill with no declared form has no ' +
      'defined shape to report in. Shipped skills already carry it; an upgrade never edits a ' +
      'file you own, so yours are yours to add.',
  },
  {
    since: '2.3.0',
    check:
      'Tasks in an external tracker: your reference for that tracker, references/github.md, ' +
      'references/gitlab.md, or your own, now records what carries an effort and the query ' +
      'that finds its open work. An upgrade never re-seeds a reference you have corrected, so ' +
      'this release cannot add that section for you. The next /tasks run in a tracker-backed ' +
      'repository writes it; add it by hand if you would rather not wait.',
  },
];

/** Scripts installed to `.aep/scripts/`, available to every configured repository. */
export const PAYLOAD_SCRIPTS = [
  'contract.mjs',
  'frontier.mjs',
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
  'manifest.mjs',
  'release.mjs',
  'verify.mjs',
];

/**
 * The release script's baseline, at the distribution root rather than beside the
 * scripts because everything in `scripts/` is `.mjs`, so a consuming
 * `package.json` cannot then change how any of it parses.
 *
 * Build-time only. It records what each shipped artifact hashed to when it was
 * last stamped, which is how a release knows what actually moved. An installed
 * tree has no use for it and never receives it.
 */
export const STAMPS_SOURCE = 'stamps.json';

/** Source of `.aep/.gitignore`. Kept undotted in the distribution so it governs nothing here. */
export const GITIGNORE_SOURCE = 'gitignore';

/**
 * Directories a repository owns. Created so there is somewhere to put things.
 *
 * `rules/` is one of them: governance the protocol defines ships as policies,
 * and `rules/` holds what this repository decides for itself. It arrives empty
 * apart from the version-control seed.
 *
 * Re-exported from `contract.mjs` rather than restated. The same list decides
 * what an upgrade preserves and what the validator will not police, and two
 * copies of it would disagree on the first directory either version gains.
 */
export { REPOSITORY_DIRS } from './contract.mjs';

/** Directories that are per-clone and gitignored. */
export const PER_CLONE_DIRS = ['position', 'worktrees'];

/**
 * A detected reference seed. Every reference is named for its tool, lands at
 * `references/<tool>.md`, and installs only where `paths`, or for a forge a git
 * remote, shows the repository actually uses it.
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
 * touched again by any upgrade, which is what makes shipping a starting point
 * safe. Each is a draft to be corrected, not a description that is already true;
 * they say so in their own first paragraph, because a seeded file that reads as
 * authoritative is worse than no file at all.
 *
 * `detect` gates installation on evidence in the repository. A seed with no
 * `detect` always installs. `paths` matches if any listed path exists; `remote`
 * matches if any git remote URL contains the string.
 *
 * `root: true` targets the repository root rather than `.aep/`. Exactly one seed
 * needs it: the entrypoint, which the harness loads by name and therefore
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

  // Agent runtimes and the harnesses that drive them. Detected by the config a
  // human writes, never by a directory an adapter creates: `.opencode/` is
  // written by AEP's own OpenCode adapter, so detecting on it would make this
  // installation the evidence that the repository uses OpenCode.
  reference('opencode', ['opencode.json', 'opencode.jsonc']),
  reference('t3code', ['t3.json']),
];
