// The session hook's fixture: a throwaway project, a throwaway plugin beside
// it, and what the shipped hook says about each pairing.
//
// This module builds directories and spawns the hook with an environment of its
// own, which is why it is here rather than in `verify.js`. That file resolves
// every path it touches through a resolver refusing the protocol directory and
// anything outside this repository, and this fixture's whole subject is a
// protocol directory in a repository that is not this one. Keeping the two apart
// is what leaves that resolver with no exemption in it: the only shipped path
// this module receives is the hook's, and `verify.js` resolves that before
// handing it over.
//
// Nothing here asserts. It reports what the hook emitted, and `verify.js` states
// what should have been emitted and compares.

'use strict';

const { spawnSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

/**
 * The prefix every fixture root carries, and the thing `discard` checks for.
 *
 * A directory name is not much of a guard on its own; combined with the parent
 * test below it is what makes the recursive delete structural rather than a
 * promise about how this module is called.
 */
const PREFIX = 'aep-session-hook-';

/**
 * The two variables the harness exports to a hook process.
 *
 * Named here so a case asking for one to be absent can remove whatever the
 * machine running the build happens to have set: a build that passed because the
 * developer's own session exported one is a build that says nothing.
 */
const PLUGIN_ROOT = 'CLAUDE_PLUGIN_ROOT';
const PROJECT_DIR = 'CLAUDE_PROJECT_DIR';

function write(root, relative, content) {
  const target = path.join(root, ...relative.split('/'));
  fs.mkdirSync(path.dirname(target), { recursive: true });
  fs.writeFileSync(target, content);
}

/**
 * Discard a fixture root and everything under it.
 *
 * The recursive delete is confined to a directory this module created: the path
 * must sit directly under the operating system's temp directory and carry the
 * prefix given below. A recursive delete reached by an argument is one bad
 * caller away from being a recursive delete of something else, so the bound is
 * checked here rather than promised in a comment.
 *
 * @throws {Error} when the path is not one this module could have produced
 */
function discard(root) {
  const resolved = path.resolve(root);
  if (
    path.dirname(resolved) !== path.resolve(os.tmpdir()) ||
    !path.basename(resolved).startsWith(PREFIX)
  ) {
    throw new Error(`refusing to delete a path this module did not create: ${resolved}`);
  }
  fs.rmSync(resolved, { recursive: true, force: true });
}

/**
 * Run the hook against one scenario.
 *
 * @param {string} script absolute path to the hook, resolved by the caller
 * @param {object} scenario what the world looks like
 * @param {string|null} [scenario.running] the plugin manifest's version. `null`
 *   writes a manifest declaring none, which is what a harness-derived version
 *   looks like from here.
 * @param {string|null} [scenario.protocol] the protocol file's `version`, or
 *   `null` for a protocol file that declares none. Omit the key entirely for a
 *   repository with no protocol file at all.
 * @param {Object<string, string|null>} [scenario.scripts] each copied script's
 *   declared release, `null` for one carrying no declaration. Omit the key for a
 *   repository that copied none.
 * @param {boolean} [scenario.unset] run with neither harness variable set, which
 *   is what a hook fired outside a project looks like.
 * @returns {{status: number, stdout: string, context: string|null}} `context` is
 *   the `additionalContext` the hook emitted, or null where it emitted nothing
 */
function observe(script, scenario) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), PREFIX));
  try {
    const project = path.join(root, 'project');
    const plugin = path.join(root, 'plugin');
    fs.mkdirSync(project, { recursive: true });

    const manifest = scenario.running === null ? {} : { version: scenario.running || '2.0.0' };
    write(plugin, '.claude-plugin/plugin.json', JSON.stringify(manifest));

    if ('protocol' in scenario) {
      const declared = scenario.protocol === null ? '' : `version: ${scenario.protocol}\n`;
      write(project, '.claude/protocol.md', `---\nowner: framework\n${declared}---\n\n# Workflow protocol\n`);
    }

    if ('scripts' in scenario) {
      for (const [name, release] of Object.entries(scenario.scripts)) {
        const stamp = release === null ? '' : `// aep-release: ${release}\n`;
        write(project, `.claude/scripts/${name}`, `${stamp}'use strict';\n\n// A copied script.\n`);
      }
    }

    // A first line given verbatim, for the case whose subject is the *form* of
    // the declaration rather than its value. Writing it from a template here
    // would make this module a third home for a format that has one.
    if ('rawScripts' in scenario) {
      for (const [name, firstLine] of Object.entries(scenario.rawScripts)) {
        write(project, `.claude/scripts/${name}`, `${firstLine}\n'use strict';\n\n// A copied script.\n`);
      }
    }

    const env = { ...process.env };
    delete env[PLUGIN_ROOT];
    delete env[PROJECT_DIR];
    if (!scenario.unset) {
      env[PLUGIN_ROOT] = plugin;
      env[PROJECT_DIR] = project;
    }

    const result = spawnSync(process.execPath, [script], { encoding: 'utf8', env });
    if (result.error) throw result.error;

    let context = null;
    if (result.stdout.trim() !== '') {
      const emitted = JSON.parse(result.stdout);
      context = emitted.hookSpecificOutput.additionalContext;
    }
    return { status: result.status, stdout: result.stdout, context };
  } finally {
    discard(root);
  }
}

module.exports = { observe };
