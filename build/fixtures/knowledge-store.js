// The knowledge store builder's fixture harness.
//
// Every fixture builds a throwaway repository under the operating system's
// temporary directory and runs the shipped script against it. That is why this
// module exists as a file of its own rather than as helpers inside the build:
// the build's resolver refuses any path outside the repository, so a fixture
// that needs a scratch tree cannot go through it, and the exception is easier
// to review quarantined here than buried among assertions.
//
// **Nothing here reads the repository the build is running in.** The one
// repository path a fixture needs is the script under test, and its caller
// resolves that through the build's own resolver before handing it over.

'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

/**
 * The prefix every fixture root carries, and the thing `discard` checks for.
 *
 * A directory name is not much of a guard on its own; combined with the parent
 * test below it is what makes the recursive delete structural rather than a
 * promise about how this module is called.
 */
const PREFIX = 'aep-knowledge-store-';

/**
 * A throwaway repository root, empty.
 *
 * @returns {string} an absolute path under the operating system's temp directory
 */
function createRoot() {
  return fs.mkdtempSync(path.join(os.tmpdir(), PREFIX));
}

/**
 * Write a file into a fixture root, creating the directories above it.
 *
 * @param {string} root a root from `createRoot`
 * @param {string} relative path from that root, with forward slashes
 * @param {string} content written whole, with no trailing newline added
 */
function write(root, relative, content) {
  const target = path.join(root, ...relative.split('/'));
  fs.mkdirSync(path.dirname(target), { recursive: true });
  fs.writeFileSync(target, content);
}

/** Read a file from a fixture root, or `null` where it does not exist. */
function read(root, relative) {
  const target = path.join(root, ...relative.split('/'));
  return fs.existsSync(target) ? fs.readFileSync(target, 'utf8') : null;
}

/** Remove a file from a fixture root. */
function remove(root, relative) {
  fs.rmSync(path.join(root, ...relative.split('/')), { force: true });
}

/** Whether a fixture root holds this path. */
function exists(root, relative) {
  return fs.existsSync(path.join(root, ...relative.split('/')));
}

/**
 * Run the shipped script against a fixture root.
 *
 * @param {string} script absolute path to the script under test
 * @param {string} root a root from `createRoot`
 * @param {string[]} [extra] further arguments
 * @returns {{status: number, stdout: string, stderr: string, output: string}}
 *   `output` is both streams joined, because a fixture asserting that a refusal
 *   names a place should not also be asserting which stream carried it.
 */
function run(script, root, extra = []) {
  const result = spawnSync(process.execPath, [script, '--root', root, ...extra], {
    encoding: 'utf8',
  });
  if (result.error) throw result.error;
  return {
    status: result.status,
    stdout: result.stdout,
    stderr: result.stderr,
    output: `${result.stdout}${result.stderr}`,
  };
}

/**
 * Discard a fixture root and everything under it.
 *
 * The recursive delete is confined to a directory this module created: the path
 * must sit directly under the operating system's temp directory and carry the
 * prefix `createRoot` gives it. A recursive delete reached by an argument is
 * one bad caller away from being a recursive delete of something else, so the
 * bound is checked here rather than promised in a comment — and this function
 * is not exported, so `withStore` is the only thing that can reach it.
 *
 * @throws {Error} when the path is not one `createRoot` could have produced
 */
function discard(root) {
  const resolved = path.resolve(root);
  const parent = path.dirname(resolved);
  if (parent !== path.resolve(os.tmpdir()) || !path.basename(resolved).startsWith(PREFIX)) {
    throw new Error(`refusing to delete a path this module did not create: ${resolved}`);
  }
  fs.rmSync(resolved, { recursive: true, force: true });
}

/**
 * Build a fixture root, hand it to `body`, and discard it however that ends.
 *
 * @param {Object<string, string>} files path from the root to its content
 * @param {(root: string) => string[]} body returns the offending entries it found
 * @returns {string[]} what `body` returned
 */
function withStore(files, body) {
  const root = createRoot();
  try {
    for (const [relative, content] of Object.entries(files)) write(root, relative, content);
    return body(root);
  } finally {
    discard(root);
  }
}

// `createRoot` and `discard` are deliberately absent: `withStore` is the only
// caller either has, and exporting the second would put a recursive delete on
// the module's surface for nobody.
module.exports = { exists, read, remove, run, withStore, write };
