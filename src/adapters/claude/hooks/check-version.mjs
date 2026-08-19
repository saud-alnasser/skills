// Says one line when this repository's AEP was installed by an older release
// than the one now running, and nothing when they match.
//
// This is a hook rather than a step in a skill because of where the two facts
// live. The running release is only reachable from something the plugin ships:
// `CLAUDE_PLUGIN_ROOT` is exported to a spawned hook process and is absent from
// the agent's own shell. And `.aep/protocol.md` may not point into a plugin,
// since the protocol is agent-agnostic and the plugin may not be installed at
// all. A skill-level check would need the same sentence in every skill that
// should warn, which is the second home the protocol exists to prevent.
//
// Silence is the normal outcome: nothing is said when the versions match, when
// the repository does not run AEP, and when `protocol.md` declares no release.
// An undeclared release is unknown, never stale.

import fs from 'node:fs';
import path from 'node:path';

/** Reads a JSON file, returning null rather than throwing on any failure. */
function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch {
    return null;
  }
}

/**
 * The value of a scalar field in a Markdown file's leading `---` block.
 * Returns null when the file is unreadable, carries no frontmatter, or does not
 * declare the field, three different facts that all mean "do not warn".
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
  const line = new RegExp(`^${field}:[ \\t]*(\\S+)[ \\t]*$`, 'm').exec(block[1]);
  return line ? line[1] : null;
}

const pluginRoot = process.env.CLAUDE_PLUGIN_ROOT;
const projectDir = process.env.CLAUDE_PROJECT_DIR;

if (pluginRoot && projectDir) {
  const manifest = readJson(path.join(pluginRoot, '.claude-plugin', 'plugin.json'));
  // No explicit version means the harness derived one from a commit or a digest,
  // which is not a value that can be compared meaningfully.
  const running = typeof manifest?.version === 'string' ? manifest.version : null;
  const installed = frontmatterField(path.join(projectDir, '.aep', 'protocol.md'), 'aep');

  if (running && installed && running !== installed) {
    process.stdout.write(
      JSON.stringify({
        hookSpecificOutput: {
          hookEventName: 'SessionStart',
          additionalContext:
            `AEP ${running} is running; this repository's .aep/ was installed by ${installed}. ` +
            'Its protocol-owned rules, modes, skills and templates may predate the current release. ' +
            'Tell the user once, in one line, that `/aep:update` migrates them, ' +
            'then carry on with whatever they asked for. Do not run it unprompted.',
        },
      }),
    );
  }
}
