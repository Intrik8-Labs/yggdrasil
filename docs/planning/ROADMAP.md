# Yggdrasil — Roadmap

This roadmap assumes solo work at roughly 5-10 hours/week. Phases are
sequential by design — each one is meant to produce evidence that justifies
moving to the next, rather than scope being committed up front.

## Phase 0 — Planning (current)

- Restate vision and problem statement around actual lived experience
  (`docs/planning/CHARTER.md`)
- Re-scope the module catalog down to an MVP slice (`docs/modules/MODULES.md`)
- Record the architecture concepts being carried forward, and which ones
  are explicitly deferred (`docs/decisions/`)

**Exit condition:** A scoped MVP definition exists that fits in the
3-month / 5-10 hr-per-week budget.

## Phase 1 — Dogfood MVP

Build the smallest end-to-end loop across three modules:

- **Smidr** (agent) — runs on at least one of the author's own machines,
  connects outbound, reports basic health/inventory. No per-agent
  certificate identity yet (see ADR-0003); the network is trusted because
  it's the author's own.
- **Heimdallr** (monitoring) — receives and displays what Smidr reports.
  Enough to answer "is this machine okay" at a glance.
- **Mimir** (tasks/tickets) — tracks the author's own tasks/projects, with
  a visible link to the machine(s) they relate to.
- **Tyr** (minimal auth) — single-user login only. Not the full identity
  module from the old catalog — just enough to gate access.

Single-tenant throughout (ADR-0002). No plugin system (ADR-0005).

**Exit condition:** The author is using this instead of whatever
combination of tools they used before, for at least a few real weeks.

## Phase 2 — Build in Public + Dogfood

Runs partly in parallel with Phase 1, conditions allowing (the author is
setting up a dedicated workspace that should help this along):

- Share progress periodically (devlog/repo updates) in homelab/sysadmin
  spaces
- Show the MVP directly to IT colleagues/contacts the author already has
  access to and ask directly whether it solves something for them
- Treat this as listening, not marketing — the goal is evidence, not an
  audience

**Exit condition:** Some signal — positive or negative — about whether
this is wanted beyond the author. Either outcome is useful; "nobody else
needs this" is a valid result that keeps the project scoped to personal
use.

## Phase 3 — Conditional Expansion

Only enter this phase based on what Phase 1/2 actually showed, and only
for the specific items that have a real trigger (see
`docs/decisions/adr-0005-deferred-decisions-log.md`):

- Multi-tenancy, if a second real user/org shows up
- Agent mTLS/per-agent identity, if an agent needs to run somewhere outside
  the author's own trusted network, or before any non-solo beta
- Plugin system, if a concrete plugin use case shows up
- Licensing model decision, before any public sharing of source or
  accepting outside contributions
- Additional modules from the original 23-module catalog, picked up one
  at a time and re-justified against current evidence, not pre-committed

There is no fixed timeline for Phase 3 — it starts when its trigger
conditions are met, not on a calendar date.
