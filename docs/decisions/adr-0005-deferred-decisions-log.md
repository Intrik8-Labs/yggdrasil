# ADR-0005 — Deferred Decisions Log

| Field         | Value         |
| ------------- | ------------- |
| Status        | ACCEPTED      |
| Date          | 2026-06-28    |
| Deciders      | Jason Scherer |
| Superseded By |               |

## Revision History

| Version | Date       | Author        | Notes   |
| ------- | ---------- | ------------- | ------- |
| 1.0     | 2026-06-28 | Jason Scherer | Initial |

---

## Context

This restart deliberately scoped down a much larger original plan (see
`docs/planning/CHARTER.md`). Scoping down means a number of real
decisions are being postponed rather than made. Postponed decisions that
aren't written down tend to either get forgotten or get quietly
re-decided by default (i.e., never revisited, which is itself a decision
nobody chose deliberately).

This is not a typical single-decision ADR. It's a living register of
decisions intentionally not made yet, each with the specific condition
that should trigger revisiting it. It should be updated in place as items
are resolved or new deferrals are identified, rather than superseded by a
new numbered ADR each time.

## Decision Drivers

- A solo, part-time project needs an honest, low-overhead way to track
  "not deciding this yet" without it turning into "never deciding this"
- Each deferral needs a concrete trigger condition, not a vague "later",
  so it's actually possible to know when to revisit it
- This register should be checked before starting Phase 3 work
  (`docs/planning/ROADMAP.md`)

## Decision

Maintain this table as the single source of truth for deferred
decisions:

| Item | Deferred by | Why deferred | Revisit when |
| --- | --- | --- | --- |
| Three-tier tenancy (Platform Owner / Tenant / SubTenant) | ADR-0002 | Single user, no second organization exists yet | A real second user/organization needs to use the platform |
| Per-agent mTLS identity (certificates, CA, revocation, enrollment tokens) | ADR-0003 | Agent only runs on the author's own trusted network | An agent needs to run on a network the author doesn't fully control, or before any non-solo beta |
| WASM plugin sandbox / plugin system | This ADR | No concrete plugin use case exists yet | A real, specific plugin need shows up from actual usage |
| Licensing model (currently BUSL 1.1, inherited from the original plan) | This ADR | Inherited default, not yet re-evaluated against the smaller/solo scope or the build-in-public plan | Before any public sharing of source, before accepting outside contributions, or before Phase 2 build-in-public activity scales up |
| Remaining ~19-20 modules from the original 23-module catalog | `docs/modules/MODULES.md` | Out of scope for the dogfood MVP | One at a time, re-justified against real usage evidence, per the roadmap — not pre-committed as a batch |
| Split-service deployment (modules as separate processes) | ADR-0004 | No operational reason for it yet; single self-hosted instance | A concrete operational reason appears (independent scaling, different deployment target for one module) |

## Consequences

**Positive:**

- Deferred work is visible and intentional, not silently dropped
- Each item has a clear, checkable trigger instead of a vague "someday"
- Future-self (or anyone else looking at this project) can tell the
  difference between "decided against" and "not decided yet"

**Accepted tradeoffs:**

- This table needs upkeep — it's only useful if it's actually consulted
  and updated, which is itself an ongoing cost on a project with very
  little spare time

**Negative:**

- A trigger condition being met doesn't get enforced automatically; it
  relies on the author noticing and checking this file

**Neutral / follow-up:**

- Review this table at the start of any Phase 3 work
  (`docs/planning/ROADMAP.md`)
- Add new rows as new deferrals are identified during Phase 1/2

---

## Alternatives Considered

**Don't track deferred decisions explicitly; handle each as it comes up**

Simpler in the moment. Rejected because the gaps between work sessions on
a 5-10 hr/week solo project make it likely that an undocumented deferral
gets forgotten entirely, or re-litigated from scratch each time it
resurfaces.

**Write a separate full ADR for each deferral instead of one shared table**

More in line with normal ADR practice. Rejected for the deferrals
specifically (as opposed to the decisions that caused them, which do
have their own ADRs — 0002, 0003, 0004) because a single table is easier
to scan and keep current than several small files that would mostly
just restate "not decided yet."

---

## Related

- `docs/planning/CHARTER.md`
- `docs/planning/ROADMAP.md`
- `docs/decisions/adr-0002-mvp-single-tenant-scope.md`
- `docs/decisions/adr-0003-outbound-only-agent-comms.md`
- `docs/decisions/adr-0004-modular-boundaries-event-driven-comms.md`
