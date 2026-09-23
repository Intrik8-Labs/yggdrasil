# Yggdrasil Architecture Overview

**Status:** Draft
**Version:** 0.2

## Purpose

Yggdrasil is a modular business-operations platform combining work management, documentation, monitoring, automation, asset management, and endpoint-agent capabilities.

The platform must support self-hosted and air-gapped deployments, strong tenant isolation, long-term data portability, and incremental growth from a small dogfood deployment.

## Architectural Style

Yggdrasil is a C# and .NET 10 modular monolith. ASP.NET Core hosts HTTP APIs and composes application services. Background processing uses .NET hosted services where appropriate. PostgreSQL is the planned system of record, accessed through EF Core/Npgsql infrastructure adapters.

Business areas use explicit C# namespaces and assemblies such as `Yggdrasil.Tyr`, `Yggdrasil.Valhalla`, `Yggdrasil.Mimir`, and `Yggdrasil.Urd`. Each module separates Core, UseCases, Infrastructure, and Contracts. Modules communicate through public contracts and events; implementation assemblies remain private. Hosts compose modules within one deployment.

Use focused .NET components for application behavior:

- ASP.NET Core endpoints for HTTP concerns
- framework-independent domain entities and value objects for business invariants
- explicit command/query use cases for orchestration
- EF Core configurations and transactions within persistence infrastructure
- hosted services for background execution, with explicit retry and durability requirements
- PostgreSQL constraints for invariants the database can enforce

## Primary Technology Direction

- **Application:** C# and .NET 10 with ASP.NET Core
- **Web UI:** React + TypeScript + Vite, with the component architecture documented separately
- **Database:** PostgreSQL through EF Core/Npgsql
- **External API:** REST/JSON when an external consumer requires it
- **Agent contracts:** gRPC and Protocol Buffers where a long-lived language-neutral boundary is justified
- **Observability:** OpenTelemetry when operational needs justify it
- **Deployment:** OCI containers

The SDK major version is selected in `mise.toml`; the API project targets `net10.0`. The current implementation is an API scaffold. Persistence, module assemblies, and the frontend below describe the target architecture.

## Target Repository Shape

```text
yggdrasil/
├── yggdrasil.slnx
├── mise.toml
├── src/
│   ├── hosts/
│   │   └── Yggdrasil.Api/
│   ├── modules/
│   │   └── <Module>/
│   │       ├── Yggdrasil.<Module>.Core/
│   │       ├── Yggdrasil.<Module>.UseCases/
│   │       ├── Yggdrasil.<Module>.Infrastructure/
│   │       └── Yggdrasil.<Module>.Contracts/
│   └── shared/
│       └── Yggdrasil.SharedKernel/
├── tests/
├── docs/
└── contracts/
    ├── proto/
    └── schemas/
```

Do not create every directory in advance. Let real features establish the structure they need.

## Module Boundaries

The initial business namespaces are:

- **Týr** — identity, authentication, organization memberships, and access control
- **Valhalla** — organization and tenant administration
- **Mímir** — projects, tasks, workflow basics, and time tracking
- **Urd** — audit of important application changes

Shared code must represent a genuinely shared concept. A general-purpose dumping ground for helpers is not a module boundary.

## External Contracts

Internal C# interfaces may evolve with the product. Long-lived external contracts require explicit versioning.

Protocol Buffers are reserved primarily for boundaries such as Smidr agents, plugins, and future service-to-service APIs. Internal model objects must not be exposed as external contracts.

## Tenancy

A user may belong to multiple organizations through memberships. Authentication establishes identity; membership and the active organization establish authorization.

Every tenant-owned query and mutation must be scoped to the active organization. Database constraints should reinforce application checks where practical. The design must leave room for stronger isolation models if real deployments require them.

## Data Portability

Customer data belongs to the customer. Supported portability should grow to include REST APIs, JSON/JSONL, CSV where useful, Markdown documents, original uploaded files, and versioned bulk import/export formats.

The relational schema is an implementation detail, not the official long-term integration contract.

## Security Principles

- enforce tenant isolation and least privilege
- require explicit authorization for sensitive actions
- audit important state changes
- keep secrets out of source control
- avoid runtime dependencies on public Internet services
- use signed, expiring, replay-resistant commands for future endpoint agents

## Dependency Policy

Prefer .NET, ASP.NET Core, and PostgreSQL capabilities before adding another dependency. A new NuGet or JavaScript package needs a concrete use case, a clear maintenance benefit, and an understood security and upgrade cost.

## Development Process

Development uses lightweight weekly iterations with one goal, a small set of concrete tasks, explicit work states, and a short review. The process should remain practical for a solo developer.
