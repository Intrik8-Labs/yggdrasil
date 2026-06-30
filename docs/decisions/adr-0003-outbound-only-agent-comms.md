# ADR-0003 — Outbound-Only Agent Communication, Identity Deferred

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

The original plan had the Smidr agent connect outbound only — it never
listens on a port, and the server never opens a connection to it.
Combined with that, each agent was to receive a unique certificate-based
identity for authentication and precise revocation.

The reasoning behind outbound-only connectivity (no firewall exceptions
needed, no inbound attack surface, works through whatever NAT/firewall
the network already has) is sound regardless of who's running the agent
or how many agents there are — it's a property of the connection model,
not of scale or multi-tenancy. The reasoning behind per-agent
certificate identity, on the other hand, is specifically about
defending against a compromised or untrusted agent/network — a problem
that doesn't exist yet when the only network involved is the author's
own.

## Decision Drivers

- The outbound-only connection model has no real downside even at solo
  scale — it's free to keep
- Per-agent certificate issuance, rotation, and revocation is real
  implementation work whose entire purpose is defending against a
  scenario (an agent on a network the author doesn't fully control, or a
  compromised agent) that doesn't apply during Phase 1
  (`docs/planning/ROADMAP.md`)
- Building real agent security later, once it's actually needed, is
  preferable to building a simplified version now and trusting it to be
  "good enough" later — security mechanisms that were never seriously
  threat-modeled tend to give false confidence

## Decision

Keep the outbound-only pull model: the agent always initiates the
connection; the server never connects to the agent.

Defer per-agent certificate identity (mTLS, CA, enrollment tokens,
revocation) entirely for this phase. The simplest authentication
sufficient for a single agent on the author's own trusted network is
acceptable for now.

This is a hard line, not a soft one: **per-agent certificate identity
must be designed and built for real before any agent runs on a network
the author does not fully control, and before any non-solo beta.** That
trigger is recorded in `adr-0005-deferred-decisions-log.md`.

## Consequences

**Positive:**

- Removes certificate issuance, rotation, revocation, and enrollment-token
  bootstrap entirely from the MVP's scope
- Keeps the one architectural property worth keeping for free (outbound-
  only) without paying for the property that isn't needed yet
  (per-agent identity)

**Accepted tradeoffs:**

- The MVP's agent authentication is intentionally weaker than the
  long-term design. This is acceptable only because the deployment
  surface is the author's own trusted network — it would not be
  acceptable in any other context, which is exactly why the trigger
  condition above exists

**Negative:**

- None identified, given the trigger condition is honored

**Neutral / follow-up:**

- When the trigger condition is met, design real per-agent certificate
  identity from scratch — the reasoning summarized in this ADR's Context
  section is a starting point, not a design to copy verbatim

---

## Alternatives Considered

**Build full per-agent mTLS identity now**

This is the right long-term answer and was the original plan. Rejected
for this phase specifically because it defends against a threat model
(an untrusted network, a compromised agent, multiple distinct
deployments) that doesn't exist yet, and building it now spends scarce
time on a problem that isn't real today.

**Drop the outbound-only model too, for simplicity**

Considered, but rejected — unlike per-agent identity, outbound-only
connectivity has no cost to keep even at solo scale, and abandoning it
now would mean redesigning the connection model later for no benefit
gained in the meantime.

---

## Related

- `docs/decisions/adr-0005-deferred-decisions-log.md`
- `docs/planning/ROADMAP.md`
