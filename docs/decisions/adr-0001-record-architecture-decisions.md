# ADR-0001 — Record Architecture Decisions

| Field         | Value         |
| ------------- | ------------- |
| Status        | ACCEPTED      |
| Date          | 2026-06-28    |
| Deciders      | Jason Scherer |
| Superseded By |               |

## Revision History

| Version | Date       | Author        | Notes                                             |
| ------- | ---------- | ------------- | -------------------------------------------------- |
| 1.0     | 2026-06-28 | Jason Scherer | Restart of ADR-0001, rescoped for solo/MVP phase   |

---

## Context

Yggdrasil is restarting from a from-scratch planning pass after an earlier
attempt scoped a 23-module platform and went through three language
migrations before anything was dogfooded. This restart is
deliberately smaller in scope (see `docs/planning/CHARTER.md`) and solo,
at roughly 5-10 hours/week.

Even at this scale, decisions will be made about architecture, scope, and
what to defer — and a solo, part-time project loses context just as
easily as a larger one, maybe more so, since weeks can pass between
sessions of work.

## Decision Drivers

- Decisions need to be discoverable after gaps of weeks between work
  sessions, without relying on memory
- The record format needs to be lightweight enough to actually get used
  under a tight time budget, not skipped
- Scope decisions and deferrals matter as much as technical ones at this
  stage — both need a permanent record
- The format should stay readable without requiring any specific tooling

## Decision

Yggdrasil will use Architecture Decision Records, stored in
`docs/decisions/`, to document significant scope, product, and technical
decisions — including explicit decisions to defer something.

ADR files use this naming convention:

- `adr-0001-record-architecture-decisions.md`
- `adr-0002-mvp-single-tenant-scope.md`
- `adr-0003-outbound-only-agent-comms.md`

Each ADR includes:

- Document metadata table
- Revision history
- Context
- Decision Drivers
- Decision
- Consequences
- Alternatives considered
- Related links, when useful

The ADR template lives at `docs/decisions/adr-template.md`.

Status values use uppercase names: `PROPOSED`, `ACCEPTED`, `SUPERSEDED`,
`DEPRECATED`, `REJECTED`.

A special case of this is the deferred decisions log
(`adr-0005-deferred-decisions-log.md`), which records decisions
deliberately *not* made yet, along with the condition that would trigger
revisiting each one. This exists specifically because this project is
solo and scope-constrained — deferring honestly, with a written trigger,
is preferable to either pretending the decision is made or letting it
quietly disappear.

---

## Consequences

**Positive:**

- Scope and architecture decisions have a permanent home, recoverable
  across multi-week gaps in work
- Deferred decisions are tracked deliberately instead of forgotten
- Direction can change without losing the history of why

**Accepted tradeoffs:**

- Adds documentation overhead on a project with very little spare time
- Requires discipline to write an ADR instead of just coding

**Negative:**

- ADRs can go stale if not updated when a decision changes
- Too many ADRs for minor implementation details would create noise —
  this is being avoided by reserving ADRs for scope/architecture-level
  decisions, not implementation choices

**Neutral / follow-up:**

- Initial ADRs cover MVP scope, agent communication, module/communication
  boundaries, and the deferred decisions log

---

## Alternatives Considered

**Do not record architecture decisions**

Simpler short term, but given how little time is available per week,
context would be lost between sessions even faster than on a
fully-staffed project. Rejected.

**Use only GitHub issues or informal notes**

Faster to write, but not durable or structured enough to serve as the
record of *why* something was decided or deferred, especially across
long gaps. Rejected as the primary mechanism.

---

## Related

- `docs/decisions/adr-template.md`
- `docs/decisions/adr-0005-deferred-decisions-log.md`
- `docs/planning/CHARTER.md`
