// Tells the session when this repository's protocol was written by an older AEP
// than the one now running, and says which command repairs it.
//
// This is a hook rather than a step in a stage because of where the two facts
// live. The running version is only reachable from something the plugin ships —
// `CLAUDE_PLUGIN_ROOT` is exported to a spawned hook process and is absent from
// the agent's own shell — and ADR 0060 forbids `.claude/protocol.md` pointing
// into the plugin. A stage-level check would therefore need the same sentence in
// every stage that should warn, which is the single-home failure the framework
// exists to prevent. One hook, fired once per session, is the only home.
//
// Exec form with `node` deliberately: the documented pattern that spawns without
// a shell on every platform, where shell form resolves to `sh -c` on Unix and to
// Git Bash *or* PowerShell on Windows and could not carry one script.
//
// Silence is the normal outcome. It says nothing when the versions match, when
// the repository does not run AEP, and when the protocol declares no version —
// an undeclared version is unknown, never stale.

'use strict';

const fs = require('fs');
const path = require('path');

/** Reads a JSON file, returning null rather than throwing on any failure. */
function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
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
  let text;
  try {
    text = fs.readFileSync(file, 'utf8');
  } catch {
    return null;
  }
  const block = /^---\r?\n([\s\S]*?)\r?\n---/.exec(text);
  if (!block) return null;
  const line = new RegExp('^' + field + ':[ \\t]*(\\S+)[ \\t]*$', 'm').exec(block[1]);
  return line ? line[1] : null;
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

  // The entry's `version` is the release that stamped it, and every release
  // stamps the entry — which is what lets one field speak for the whole
  // installation. `aep-version` is the field's retired predecessor: a
  // repository configured before the stamps existed declares only it, and
  // reading it keeps that repository's warning alive until its first audit
  // replaces the file. A file declaring neither field is unknown, never stale.
  const protocol = path.join(projectDir, '.claude', 'protocol.md');
  const configured =
    frontmatterField(protocol, 'version') ??
    frontmatterField(protocol, 'aep-version');
  if (!configured || configured === running) return;

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'SessionStart',
        additionalContext:
          `AEP ${running} is running; this repository's protocol was written by ${configured}. ` +
          'Its policies, rules and templates may predate the current release. ' +
          'Tell the user once, in one line, that `/aep:configure` audits and updates them — ' +
          'then carry on with whatever they asked for. Do not run it unprompted.',
      },
    })
  );
}

main();
