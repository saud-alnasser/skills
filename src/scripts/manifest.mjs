// Regenerates the shipped-path manifest inside `contract.mjs`.
//
// Ownership is a fact about location rather than a field on every artifact. The
// directory table in `contract.mjs` answers it for a file the payload has never
// heard of, which is the case that matters most: a repository file standing
// inside a protocol directory is a defect, and the table is what makes it
// visible. What the table cannot answer is whether a file at a path the payload
// also ships is the shipped one, so the exact list is carried beside it.
//
// The list is generated because a hand-maintained copy of what a directory
// contains disagrees with the directory on the first change, and the copy is
// the one nothing checks. `verify.mjs` fails when this file's output is stale,
// which is the same contract `index.mjs` and `adapters.mjs` already run under.
//
//   node src/scripts/manifest.mjs           rewrite the block
//   node src/scripts/manifest.mjs --check   exit 1 when it is stale

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { walk } from './contract.mjs';
import {
  PAYLOAD_FILES,
  PAYLOAD_DIRS,
  PAYLOAD_SCRIPTS,
  GITIGNORE_SOURCE,
} from './payload.mjs';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const SRC = path.dirname(HERE);
const CONTRACT = path.join(HERE, 'contract.mjs');

export const BEGIN = '// generated:protocol-files. Run `node src/scripts/manifest.mjs`';
export const END = '// end generated:protocol-files';

/**
 * Every path the payload writes into `.aep/`, POSIX-relative to it, sorted.
 *
 * The mapping mirrors `install.mjs`'s copy loops exactly, because a manifest
 * derived from a second reading of the payload is a second answer to the same
 * question. `.gitignore` is included: it is written into the tree like anything
 * else, and a manifest that omits it makes the installer's own output look like
 * a stray.
 */
export function shippedPaths(from = SRC) {
  const paths = [...PAYLOAD_FILES];

  for (const dir of PAYLOAD_DIRS) {
    const source = path.join(from, dir);
    if (!fs.existsSync(source)) continue;
    for (const file of walk(source)) {
      paths.push(`${dir}/${path.relative(source, file).split(path.sep).join('/')}`);
    }
  }

  for (const script of PAYLOAD_SCRIPTS) paths.push(`scripts/${script}`);
  paths.push('.gitignore');

  return paths.sort();
}

/** The `contract.mjs` text with its generated block replaced. */
export function render(text, paths) {
  const begin = text.indexOf(BEGIN);
  const end = text.indexOf(END);
  if (begin === -1 || end === -1) {
    throw new Error(`contract.mjs has no generated:protocol-files block. Restore ${BEGIN}`);
  }
  const block = [
    BEGIN,
    'export const PROTOCOL_FILES = [',
    ...paths.map((entry) => `  '${entry}',`),
    '];',
    END,
  ].join('\n');
  return text.slice(0, begin) + block + text.slice(end + END.length);
}

function main() {
  const check = process.argv.includes('--check');
  const current = fs.readFileSync(CONTRACT, 'utf8');
  const next = render(current, shippedPaths());

  if (current === next) {
    process.stdout.write('the manifest is current\n');
    return;
  }
  if (check) {
    process.stderr.write(
      'the manifest is stale. Run: node src/scripts/manifest.mjs\n',
    );
    process.exit(1);
  }

  fs.writeFileSync(CONTRACT, next);
  process.stdout.write(`wrote ${shippedPaths().length} paths into scripts/contract.mjs\n`);
}

if (process.argv[1] && path.resolve(process.argv[1]) === path.resolve(fileURLToPath(import.meta.url))) {
  main();
}
