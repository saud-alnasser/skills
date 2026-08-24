// Computes an effort's frontier: what can start now, and what is waiting on what.
//
// The bootstrap says that where a script can compute an answer, the answer is
// computed and the output quoted. This is that for scheduling. An orchestrator
// that reads every ticket and judges independence is inferring a graph that was
// already declared, in its own context, differently each time; and the cheapest
// way to satisfy a rule against inferring independence is to work serially and
// say nothing about why.
//
// It computes and prints. It never writes, never claims a ticket, and never
// decides that a ticket is parked. Parking is run state: the runner holds it,
// passes it in, and gets it echoed back so the ledger and the frontier agree.
//
//   node frontier.mjs <effort> [--root <path-to-.aep>] [--parked 03,07]
//
//   ready    <id> <slug>              open, unclaimed, nothing gating it
//   blocked  <id> <slug> by <ids>     open, and what it waits on
//   parked   <id> <slug>              excluded by the caller for this run
//
//   exit 0  work remains
//   exit 1  nothing unresolved
//   exit 2  the effort or its tickets could not be read

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { readArtifact, resolveAepRoot, TICKET_STATUSES } from './contract.mjs';

/** A ticket's id is the numeric prefix of its filename, which is what edges name. */
function ticketId(file) {
  const match = /^(\d+)-/.exec(path.basename(file));
  return match ? match[1] : null;
}

function slugOf(file) {
  return path.basename(file, '.md').replace(/^\d+-/, '');
}

/**
 * Reads an effort's tickets into `{ id, slug, status, blockedBy }`.
 *
 * A ticket that cannot be parsed is an error rather than a skip: a frontier
 * computed from most of the graph is worse than none, because it looks complete.
 */
export function readTickets(root, effort) {
  const dir = path.join(root, 'efforts', effort, 'tickets');
  if (!fs.existsSync(dir)) throw new Error(`no tickets directory at efforts/${effort}/tickets`);

  const tickets = [];
  for (const name of fs.readdirSync(dir).sort()) {
    if (!name.endsWith('.md')) continue;
    const file = path.join(dir, name);
    const id = ticketId(file);
    if (!id) throw new Error(`${name} has no numeric id, and an edge cannot name it`);

    const artifact = readArtifact(file);
    if (artifact.errors.length > 0) throw new Error(`${name}: ${artifact.errors.join('; ')}`);

    const status = artifact.fields.status;
    if (!TICKET_STATUSES.includes(status)) {
      throw new Error(`${name} declares status "${status}", not one of: ${TICKET_STATUSES.join(', ')}`);
    }

    const blockedBy = artifact.fields['blocked-by'] ?? [];
    if (!Array.isArray(blockedBy)) throw new Error(`${name}: blocked-by must be a YAML array`);

    tickets.push({ id, slug: slugOf(file), status, blockedBy: blockedBy.map(String) });
  }
  return tickets;
}

/**
 * Splits the tickets into ready, blocked, and parked.
 *
 * A blocker is satisfied when the ticket it names is resolved or obsolete.
 * `obsolete` counts because a task nobody is going to do gates nothing, and
 * leaving it as a gate is how an effort stalls on work it already decided
 * against.
 *
 * An edge naming a ticket that does not exist is reported rather than ignored.
 * Silently treating it as satisfied would release work whose dependency nobody
 * ever wrote.
 */
export function frontier(tickets, parked = []) {
  const byId = new Map(tickets.map((ticket) => [ticket.id, ticket]));
  const done = (id) => {
    const ticket = byId.get(id);
    if (!ticket) throw new Error(`blocked-by names ${id}, and no ticket has that id`);
    return ticket.status === 'resolved' || ticket.status === 'obsolete';
  };

  const open = tickets.filter((ticket) => ticket.status === 'open');
  const result = { ready: [], blocked: [], parked: [] };

  for (const ticket of open) {
    if (parked.includes(ticket.id)) {
      result.parked.push(ticket);
      continue;
    }
    const waiting = ticket.blockedBy.filter((id) => !done(id));
    if (waiting.length > 0) result.blocked.push({ ...ticket, waiting });
    else result.ready.push(ticket);
  }
  return result;
}

function main() {
  const args = process.argv.slice(2);
  const value = (flag) => (args.includes(flag) ? args[args.indexOf(flag) + 1] : null);
  const effort = args.find((arg) => !arg.startsWith('--') && args[args.indexOf(arg) - 1] !== '--root'
    && args[args.indexOf(arg) - 1] !== '--parked');

  if (!effort) {
    process.stderr.write('usage: node frontier.mjs <effort> [--root <path>] [--parked 03,07]\n');
    process.exit(2);
  }

  const root = resolveAepRoot(value('--root'), import.meta.url);
  if (!root) {
    process.stderr.write('no .aep/ found. Pass --root, or run from a repository that has one\n');
    process.exit(2);
  }

  const parked = (value('--parked') ?? '').split(',').map((id) => id.trim()).filter(Boolean);

  let result;
  try {
    result = frontier(readTickets(root, effort), parked);
  } catch (error) {
    process.stderr.write(`${error.message}\n`);
    process.exit(2);
  }

  for (const ticket of result.ready) {
    process.stdout.write(`ready    ${ticket.id} ${ticket.slug}\n`);
  }
  for (const ticket of result.blocked) {
    process.stdout.write(`blocked  ${ticket.id} ${ticket.slug} by ${ticket.waiting.join(',')}\n`);
  }
  for (const ticket of result.parked) {
    process.stdout.write(`parked   ${ticket.id} ${ticket.slug}\n`);
  }

  const remaining = result.ready.length + result.blocked.length + result.parked.length;
  process.exit(remaining > 0 ? 0 : 1);
}

if (process.argv[1] && fileURLToPath(import.meta.url) === path.resolve(process.argv[1])) main();
