# Yggdrasil — Project Charter

## Status

This charter reflects a deliberate restart. The original plan scoped
Yggdrasil as a 23-module MSP/gov-contractor platform before any of it had
been used by a real person for a real day. This
version scopes down to what one person, working 5-10 hours a week, can
actually build and use — with the larger platform as a direction to grow
into, not a day-one requirement.

## Origin

This isn't a market-sized opportunity in search of a product. It comes
from lived frustration: a government IT department that's disorganized
in the specific, familiar ways most IT shops are; a broader trend of
organizations stretching hardware lifespans further than they used to,
which makes fleet visibility matter more, not less; and the daily
annoyance of stitching together multiple disconnected tools just to get
one coherent view of what's going on.

The author has eight years of hands-on IT experience, is now working as
a software engineer, and runs a homelab. That combination — having lived
the problem, and now having the skills to build a real solution to it —
is the actual reason this project exists.

## Vision

**Near-term:** A self-hosted tool the author actually uses to track tasks
and monitor the health of their own homelab machines, end to end —
proving the core loop (agent reports in, work gets tracked, both are
visible in one place) before anything else is built.

**Long-term direction (not a current commitment):** A unified,
self-hosted operations platform — monitoring, ticketing, and the rest of
the old module catalog — for people and organizations who are tired of
stitching together separate RMM, PSA, CRM, and billing tools. Air-gapped
and source-visible deployment remain part of the long-term identity
because they matter to the author personally (privacy, self-hosting,
auditability), not because a specific paying segment has confirmed they
need it yet.

## Problem Statement

**What's confirmed (the author's own experience):**

- IT operations data is scattered across disconnected tools with no
  unified view, even at small scale
- Hardware is being kept in service longer, which raises the cost of not
  having good fleet/health visibility
- Switching between separate ticketing, monitoring, and asset tools to
  understand "what's actually going on" is a real, recurring cost

**What's not yet confirmed:** Whether MSPs, government contractors, or
anyone other than the author feel this strongly enough to adopt or pay
for a tool that solves it. That's an open question this phase is designed
to start answering, not an assumption to build 23 modules on top of.

## Who This Is For Right Now

The author, as a homelab user and practitioner — full stop. Every
decision in this phase is judged by "does this make my own setup better"
first. MSP and government/defense personas from the old charter are
retained as the long-term direction (see Non-Goals and the Roadmap), not
as current target users.

## Success Criteria

**For this phase (next ~3 months, ~5-10 hrs/week):**

- A self-hosted instance is running on the author's own network
- A lightweight agent reports health/inventory from at least one real
  homelab machine
- Tasks/tickets for the author's own projects are tracked in the same
  system, visibly connected to the machines they relate to
- The author is actually using it instead of whatever they used before

**Long term (unscoped, revisited as the roadmap progresses):**

- Evidence — not assumption — that people outside the author want this
- A sustainable path (commercial, open-source, or otherwise) that hasn't
  been decided yet — see `docs/decisions/adr-0005-deferred-decisions-log.md`

## Non-Goals (for this phase)

- Not building multi-tenant/multi-organization support
- Not building production-grade agent identity (per-agent certs,
  revocation) — the agent only runs on the author's own trusted network
  for now
- Not building a plugin system — there's no plugin yet that needs one
- Not deciding the long-term licensing model yet
- Not building out the full 23-module catalog — see
  `docs/modules/MODULES.md` for what's in scope now vs. deferred

## Guiding Principles

- Build for yourself first; let outside validation follow real usage,
  not precede it
- Practical architecture over hype — premature complexity gets
  challenged, especially given the solo/part-time reality of this project
- Every significant decision still gets an ADR, even at this scale —
  small projects lose context just as easily as big ones
- Honest tradeoff assessment over optimistic framing, including about
  scope and pace
- A deferred decision is not a forgotten one — see the deferred decisions
  log and revisit it as conditions change

## Deployment Model (this phase)

Single self-hosted instance, on the author's own home network. No SaaS,
no multi-tenant hosting, no air-gapped deployment target yet — those
remain long-term direction, not near-term work.

## License

Currently Business Source License 1.1 (see `LICENSE`), inherited from the
original plan. This is explicitly under reconsideration — see
`docs/decisions/adr-0005-deferred-decisions-log.md` — and should be
treated as provisional until revisited, particularly before any public
build-in-public sharing or outside contribution.
