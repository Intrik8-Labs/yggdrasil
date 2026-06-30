# ADR-0002 — Single-User, Single-Tenant Scope for the MVP

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

The original plan designed a three-tier tenancy model: Platform Owner →
Tenant (MSP) → SubTenant (MSP's client), with structural data isolation
enforced at the query layer. That model exists to let an MSP manage
multiple clients in aggregate while keeping different MSPs' data strictly
separated from each other.

Right now there is exactly one user of this platform: the author, running
it for their own homelab and personal task tracking. There is no second
organization, no client, and no near-term plan to onboard one inside this
phase's scope (`docs/planning/CHARTER.md`, Phase 1 of
`docs/planning/ROADMAP.md`).

## Decision Drivers

- Solo project at 5-10 hrs/week — every piece of machinery built has to
  earn its cost against real, current usage
- Tenant isolation logic (scoping every query, structural enforcement,
  admin tooling for cross-tenant visibility) is real engineering effort
  with zero current beneficiary
- The three-tier model is still the right answer if/when a second
  organization shows up — the concept isn't being rejected, just deferred
- Retrofitting tenancy later is a real cost, but is one this project is
  explicitly willing to pay in exchange for not carrying unused isolation
  machinery through the entire dogfood phase

## Decision

The MVP and Phase 1 build will be single-user, single-tenant. No
Platform Owner / Tenant / SubTenant hierarchy, no per-tenant data
isolation enforcement, no admin tooling for managing other
tenants/organizations.

This is recorded in the deferred decisions log
(`adr-0005-deferred-decisions-log.md`) with its trigger: revisit the
three-tier model when a real second user or organization needs to use
the platform — not before.

## Consequences

**Positive:**

- Removes a substantial, currently-unneeded category of work from the
  MVP
- Keeps the data model and access logic simple while there's only one
  real user to validate against

**Accepted tradeoffs:**

- If/when a second tenant does show up, introducing tenancy retroactively
  will cost more than building it in from the start would have
- This is accepted deliberately — see Decision Drivers — because the
  alternative is paying that cost now, with certainty, for a benefit that
  is not yet certain to materialize

**Negative:**

- None identified beyond the accepted tradeoff above, given current scope

**Neutral / follow-up:**

- When Phase 3 conditions are met (see `docs/planning/ROADMAP.md`),
  revisit the original three-tier model design as a starting point rather
  than redesigning from zero — it was reasoned through once already

---

## Alternatives Considered

**Build the three-tier model now, even for one user**

This was the original plan's approach and is the safer long-term choice
if multi-tenancy is a near-certainty. It was rejected for this phase
because multi-tenancy is not a near-certainty yet — it's a long-term
direction (see CHARTER.md) without confirmed demand, and building it now
would spend a meaningful share of a very limited weekly time budget on
isolation machinery nobody is currently being isolated from.

**Design the seam without building the tiers (e.g., a `tenant_id` field everywhere, unused)**

Considered as a middle ground. Rejected for now specifically because
there's no concrete schema or implementation yet to add the field to —
this is a planning-phase ADR, not a data-modeling one. This option should
be re-evaluated at the point actual data models are designed in Phase 1,
since it's cheap to do then and the tradeoff calculus may differ once
there's real schema to look at.

---

## Related

- `docs/planning/CHARTER.md`
- `docs/planning/ROADMAP.md`
- `docs/decisions/adr-0005-deferred-decisions-log.md`
