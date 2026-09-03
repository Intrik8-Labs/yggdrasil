# Yggdrasil Architecture Overview

**Status:** Draft  
**Version:** 0.1

## Purpose

Yggdrasil is a modular business operations platform combining CRM, ERP, MSP, project/service management, documentation, monitoring, automation, asset management, and endpoint-agent capabilities.

The platform must support:

- self-hosted deployments
- air-gapped environments
- cloud-hosted deployments
- mobile-responsive use
- strong tenant isolation
- long-term data portability
- incremental growth from a small dogfood deployment

## Architectural Style

Yggdrasil uses a **modular monolith with Clean Architecture**.

Each business module is a bounded context with its own:

- Core
- UseCases
- Infrastructure
- Contracts

The application initially ships as a small number of deployable processes. Module boundaries are preserved so individual capabilities can later be extracted only when there is a concrete operational reason.

### Dependency direction

```text
Infrastructure -----> UseCases -----> Core
Web ----------------> UseCases
Core ----------------> SharedKernel
```

Module implementation assemblies are private. Other modules must not reference another module's Core, UseCases, or Infrastructure projects.

Cross-module interaction should primarily use:

- public contracts
- domain/integration events
- explicit versioned messages

This same contract-first approach is intended to support plugins, extensions, agents, and future service extraction.

## Primary Technology Direction

- **Backend:** C# / .NET 10 / ASP.NET Core
- **Frontend:** React + TypeScript
- **Database:** PostgreSQL
- **Persistence:** EF Core + Npgsql
- **External API:** REST/JSON
- **Agent/long-lived contracts:** gRPC + Protocol Buffers
- **Real-time UI:** SignalR/WebSockets where needed
- **Observability:** OpenTelemetry
- **Deployment:** OCI containers

The project intentionally minimizes dependencies and prefers .NET platform capabilities before adding third-party libraries.

## Target Repository Shape

```text
yggdrasil/
├── src/
│   ├── Yggdrasil.SharedKernel/
│   ├── Modules/
│   │   ├── Tyr/
│   │   │   ├── Yggdrasil.Tyr.Core/
│   │   │   ├── Yggdrasil.Tyr.UseCases/
│   │   │   ├── Yggdrasil.Tyr.Infrastructure/
│   │   │   └── Yggdrasil.Tyr.Contracts/
│   │   ├── Valhalla/
│   │   ├── Mimir/
│   │   └── Urd/
│   └── Hosts/
│       ├── Yggdrasil.Web/
│       └── Yggdrasil.Worker/
├── contracts/
│   ├── proto/
│   └── schemas/
├── web/
├── tests/
├── docs/
└── deploy/
```

The current repository structure predates this target and will be migrated deliberately rather than through partial ad-hoc moves.

## Shared Kernel

`Yggdrasil.SharedKernel` must remain small and framework-free.

Appropriate concepts may include:

- Entity and AggregateRoot primitives
- ValueObject primitives
- DomainEvent
- Result/Error
- TenantId and similarly universal identifiers
- small infrastructure-independent abstractions such as IClock when justified

Business concepts such as Ticket, Task, Customer, Asset, Document, Permission, Workflow, and Contract belong to their owning modules.

## Use-Case Organization

UseCases are organized by business operation rather than by technical type.

Example:

```text
Yggdrasil.Mimir.UseCases/
├── Tasks/
│   ├── Create/
│   ├── Assign/
│   ├── Complete/
│   └── Get/
├── Projects/
└── Time/
    ├── StartTimer/
    ├── StopTimer/
    └── AddTimeEntry/
```

Commands and queries use small project-owned abstractions rather than introducing a mediator package before one is justified.

## Contracts and Protobuf

Each module may expose a small Contracts assembly containing stable public integration contracts and events.

Protocol Buffers are reserved primarily for long-lived, language-neutral boundaries such as:

- Smidr agent communication
- plugin and extension contracts
- external service contracts
- future service-to-service APIs

Proto packages are explicitly versioned, for example:

```text
yggdrasil.agent.v1
yggdrasil.plugin.v1
```

## Tenancy

A user may belong to multiple organizations through memberships.

Authentication establishes identity; membership establishes authorization inside the active tenant.

The design must leave room for increasing isolation levels:

1. shared database with enforced TenantId isolation
2. schema-per-tenant
3. database-per-tenant
4. dedicated deployment

High-security deployments must not require shared infrastructure.

## Data Portability

Customer data belongs to the customer.

Supported portability should grow to include:

- REST APIs
- JSON/JSONL exports
- CSV exports where useful
- Markdown for documents
- original uploaded files
- versioned bulk import/export formats

The relational database schema is an implementation detail, not the official long-term integration contract.

## Initial Scope

The first useful vertical slice is:

- **Týr** — identity, authentication, organization memberships
- **Valhalla** — organization/tenant administration
- **Mímir** — tasks, projects, workflow basics, time tracking
- **Urd** — audit of important application changes

The first dogfood milestone is reached when Yggdrasil can manage its own development work reliably.

## Security Principles

Security-sensitive and government-contractor use is a target constraint.

Architectural concerns include:

- tenant isolation
- least privilege
- TLS
- explicit authorization
- auditable commands and changes
- signed agent commands and updates
- replay protection and expiration
- secure secret management
- air-gapped operation without external identity or telemetry dependencies

## Dependency Policy

Initial expected third-party dependencies should remain narrow, primarily:

- EF Core
- Npgsql
- gRPC / Protocol Buffers
- OpenTelemetry

Packages such as MediatR, AutoMapper, FluentValidation, MassTransit, Hangfire, Quartz, Redis clients, Kafka clients, and RabbitMQ clients are not adopted until a demonstrated need justifies them.

## Development Process

Development uses lightweight weekly Agile iterations:

- one weekly goal
- a small set of concrete tasks
- explicit backlog/ready/in-progress/blocked/review/done states
- weekly review of completed work, blockers, architecture decisions, and the next three priorities

The process should remain practical for a solo developer rather than ceremony-heavy.
