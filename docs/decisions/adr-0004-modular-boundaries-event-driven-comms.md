# ADR-0004 — Modular Boundaries and Explicit Communication

| Field | Value |
| --- | --- |
| Status | ACCEPTED |
| Date | 2026-06-28 |
| Deciders | Jason Scherer |

## Context

Yggdrasil is a .NET modular monolith with a broad domain catalog and a focused first product slice. Týr, Valhalla, Mímir, and Urd need clear ownership without requiring separate deployments or a distributed message broker.

## Decision Drivers

- Business rules and tenant isolation must remain testable within each module.
- Cross-module dependencies must be visible and deliberate.
- A solo development workflow needs understandable, lightweight integration.
- Deployment must remain practical for self-hosted and air-gapped environments.

## Decision

Modules communicate through public Contracts interfaces and integration events. They must not reference another module's Domain, Application, or Infrastructure implementation assemblies.

Use explicit synchronous interfaces when a caller requires an immediate result. Publish events for completed business facts when consumers can react independently. Event contracts carry stable identifiers and data, not tracked persistence entities.

In-process communication is sufficient for the initial deployment. Durable delivery, retries, and transaction boundaries must be designed when a workflow requires them; an in-memory event dispatcher does not guarantee delivery after a process failure. A specific messaging library is not required by this decision.

The platform and project dependency direction are defined in ADR-0006. Modules remain within one deployment unless a demonstrated operational need justifies service extraction.

## Consequences

### Positive

- Module ownership is explicit without distributed-system overhead.
- Public contracts make dependencies reviewable and testable.
- Event consumers can evolve independently of the initiating use case.

### Tradeoffs

- Contracts and integration tests require deliberate maintenance.
- Event-driven workflows need explicit failure and consistency behavior.
- Shared contracts must remain small to avoid coupling unrelated modules.

## Alternatives Considered

### Direct access to other modules' implementation details

Rejected because it undermines ownership, tenant-isolation guarantees, and independent testing.

### Events for every interaction

Rejected because immediate queries and commands are clearer through explicit public interfaces. Events describe facts; they are not a substitute for all application calls.

### Separate deployable services for every module

Rejected for the initial deployment because networking, deployment coordination, and distributed debugging add operational cost without a demonstrated requirement.

## Related

- `docs/decisions/adr-0006-dotnet-modular-clean-architecture.md`
- `docs/architecture/dependency-rules.md`
- `docs/modules/MODULES.md`
- `docs/planning/CHARTER.md`
