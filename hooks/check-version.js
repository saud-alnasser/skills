// Tells the session when this repository was written by an older AEP than the
// one now running, and says which command repairs it. Two subjects, one
// question: the protocol file, and the scripts copied beside it.
//
// This is a hook rather than a step in a stage because of where the two facts
// live. The running version is only reachable from something the plugin ships —
// `CLAUDE_PLUGIN_ROOT` is exported to a spawned hook process and is absent from
// the agent's own shell — so a repository file cannot resolve it by pointing at
// the plugin. A stage-level check would therefore need the same sentence in
// every stage that should warn, which is the single-home failure the framework
// exists to prevent. One hook, fired once per session, is the only home.
//
// **It is also the only surface that can see both sides of a copied script**,
// which is why the scripts are checked here and not by the repository's own
// build: a build cannot find what it would compare against. What that buys is a
// stale copy reported once. What it does not buy is a copy somebody edited — a
// hand-edited copy still declaring the current release passes, because this runs
// once per session and is not a diffing tool. The limit is stated on the page
// that documents the scripts, and is not a gap somebody should close here.
//
// Exec form with `node` deliberately: the documented pattern that spawns without
// a shell on every platform, where shell form resolves to `sh -c` on Unix and to
// Git Bash *or* PowerShell on Windows and could not carry one script.
//
// Silence is the normal outcome. It says nothing when the versions match, when
// the repository does not run AEP, and when nothing declares a version — an
// undeclared version is unknown, never stale.

'use strict';

const fs = require('fs');
const path = require('path');

/**
 * The release a copied script declares, as its first line.
 *
 * The form is documented beside the scripts themselves, because a configuring
 * stage writes it and this reads it — two ends of one format, and the page they
 * both point at is what keeps them from drifting apart.
 */
const SCRIPT_STAMP = /^\/\/ aep-release:[ \t]*(\S+)[ \t]*$/m;

/** Reads a JSON file, returning null rather than throwing on any failure. */
function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch {
    return null;
  }
}

/** Reads a file, returning null rather than throwing on any failure. */
function readText(file) {
  try {
    return fs.readFileSync(file, 'utf8');
  } catch {
    return null;
  }
}

/**
 * The value of a scalar field in a markdown file's leading `---` block.
 * Returns null when the file is unreadable, carries no frontmatter, or does not
 * declare the field — three different facts that all mean "do not warn".
 */
function frontmatterField(file, field) {
  const text = readText(file);
  if (text === null) return null;
  const block = /^---\r?\n([\s\S]*?)\r?\n---/.exec(text);
  if (!block) return null;
  const line = new RegExp('^' + field + ':[ \\t]*(\\S+)[ \\t]*$', 'm').exec(block[1]);
  return line ? line[1] : null;
}

/**
 * Whether the repository's protocol file was written by an older release.
 *
 * The entry's `version` is the release that stamped it, and every release stamps
 * the entry — which is what lets one field speak for the whole installation.
 * `aep-version` is the field's retired predecessor: a repository configured
 * before the stamps existed declares only it, and reading it keeps that
 * repository's warning alive until its first audit replaces the file. A file
 * declaring neither field is unknown, never stale.
 *
 * @returns {string|null} the release that wrote it, or null where it matches or
 *   is not knowable
 */
function staleProtocol(projectDir, running) {
  const protocol = path.join(projectDir, '.claude', 'protocol.md');
  const configured =
    frontmatterField(protocol, 'version') ?? frontmatterField(protocol, 'aep-version');
  if (!configured || configured === running) return null;
  return configured;
}

/**
 * The copied scripts whose declared release is not the running one.
 *
 * A script declaring nothing is skipped rather than reported: absence is
 * unknown, never stale, which is the same rule the protocol file answers to. A
 * directory that is not there is the same fact one level up — a repository that
 * copied no scripts has nothing that could be behind.
 *
 * @returns {Array<{name: string, release: string}>} sorted by name, so the line
 *   this produces is the same line on every machine
 */
function staleScripts(projectDir, running) {
  const directory = path.join(projectDir, '.claude', 'scripts');
  let entries;
  try {
    entries = fs.readdirSync(directory, { withFileTypes: true });
  } catch {
    return [];
  }
  const stale = [];
  for (const entry of entries) {
    if (!entry.isFile() || !entry.name.endsWith('.js')) continue;
    const text = readText(path.join(directory, entry.name));
    if (text === null) continue;
    const declared = SCRIPT_STAMP.exec(text);
    if (!declared || declared[1] === running) continue;
    stale.push({ name: entry.name, release: declared[1] });
  }
  return stale.sort((one, other) => (one.name < other.name ? -1 : one.name > other.name ? 1 : 0));
}

function main() {
  const pluginRoot = process.env.CLAUDE_PLUGIN_ROOT;
  const projectDir = process.env.CLAUDE_PROJECT_DIR;
  if (!pluginRoot || !projectDir) return;

  const manifest = readJson(path.join(pluginRoot, '.claude-plugin', 'plugin.json'));
  // No explicit version means the harness derived one from a commit SHA or a
  // digest, which is not a number this can be compared against meaningfully.
  const running = manifest && typeof manifest.version === 'string' ? manifest.version : null;
  if (!running) return;

  // Two subjects, one line each, so a repository behind on both learns both --
  // and a repository behind on one is never told about the other.
  const lines = [];

  const protocol = staleProtocol(projectDir, running);
  if (protocol) {
    lines.push(
      `AEP ${running} is running; this repository's protocol was written by ${protocol}. ` +
        'Its rules and templates may predate the current release.',
    );
  }

  const scripts = staleScripts(projectDir, running);
  if (scripts.length > 0) {
    const named = scripts.map((script) => `${script.name} (${script.release})`).join(', ');
    lines.push(
      `AEP ${running} is running; ${scripts.length} copied script(s) came from an earlier release: ${named}. ` +
        'A stale copy runs and produces confident output that nothing else marks as wrong.',
    );
  }

  if (lines.length === 0) return;

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'SessionStart',
        additionalContext:
          `${lines.join('\n')}\n` +
          'Tell the user once, in one line, that `/aep:configure` audits and updates them — ' +
          'then carry on with whatever they asked for. Do not run it unprompted.',
      },
    }),
  );
}

main();
