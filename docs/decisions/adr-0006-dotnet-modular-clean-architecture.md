# ADR-0006 — .NET Modular Monolith with Clean Architecture

| Field | Value |
| --- | --- |
| Status | ACCEPTED |
| Date | 2026-09-03 |
| Deciders | Intrik8 Labs |

## Context

Yggdrasil is intended to grow into a long-lived CRM/ERP/MSP-style operations platform while remaining deployable in self-hosted, air-gapped, and cloud environments. The project needs strong domain boundaries without taking on the operational cost of microservices during early development.

Earlier experiments used or considered multiple language and infrastructure stacks. The current design needs a stable implementation direction that supports rich business-domain modeling, strong typing, command/query use cases, gRPC/Protobuf contracts, cross-platform development, and deliberate dependency boundaries.

## Decision

Yggdrasil will use:

- C# and .NET 10+ as the primary application platform
- ASP.NET Core for application hosts and HTTP APIs
- a modular monolith as the initial deployment architecture
- Clean Architecture boundaries within each business module
- an Ardalis-inspired module shape of Core, UseCases, Infrastructure, and Contracts
- a small framework-free `Yggdrasil.SharedKernel`
- PostgreSQL with EF Core/Npgsql for primary relational persistence
- explicit commands and queries using small project-owned abstractions initially
- public contracts and events as the primary cross-module boundary
- Protocol Buffers for long-lived language-neutral agent/plugin/extension contracts

Module implementation assemblies are private. A module must not directly reference another module's Core, UseCases, or Infrastructure implementation.

## Consequences

### Positive

- Strong, testable module boundaries without distributed-system overhead
- Clean path for future plugins, extensions, agents, or selective service extraction
- Good fit for complex business-domain modeling
- Cross-platform development on Linux, macOS, and Windows
- Mature support for ASP.NET Core, gRPC, PostgreSQL, background workers, and observability
- Keeps external contracts independent from the implementation language

### Tradeoffs

- More projects and explicit boundaries than a minimal layered application
- Architecture discipline must be enforced to prevent contract and SharedKernel sprawl
- Some common mediator/mapping/validation conveniences will initially be implemented explicitly instead of added as third-party dependencies

## Alternatives Considered

### Go as the primary platform

Go remains a strong candidate for lightweight endpoint agents such as Smidr, but C# is preferred for the primary business platform because Yggdrasil is expected to contain rich domains such as work management, permissions, contracts, workflows, documents, SLAs, time tracking, and tenant administration.

### Microservices

Rejected for the initial platform. They add deployment, networking, debugging, observability, and air-gap complexity without a demonstrated scaling or organizational need.

### Traditional layered monolith

Rejected because Yggdrasil's long-term module catalog benefits from explicit bounded contexts and stable public integration contracts.

## Related

- `docs/architecture/overview.md`
- `docs/architecture/dependency-rules.md`
- `docs/decisions/adr-0004-modular-boundaries-event-driven-comms.md`
