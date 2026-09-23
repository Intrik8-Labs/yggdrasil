# Yggdrasil Architecture Overview

**Status:** Draft
**Version:** 0.2

## Purpose

Yggdrasil is a modular business-operations platform combining work management, documentation, monitoring, automation, asset management, and endpoint-agent capabilities.

The platform must support self-hosted and air-gapped deployments, strong tenant isolation, long-term data portability, and incremental growth from a small dogfood deployment.

## Architectural Style

The MVP is a modular Ruby on Rails monolith. Rails owns the web application, background jobs, and relational persistence. PostgreSQL is the system of record.

Business areas use explicit Ruby namespaces such as `Tyr`, `Valhalla`, `Mimir`, and `Urd`. Namespaces communicate through small public interfaces and domain events rather than reaching into one another's private implementation. This is a code-ownership boundary inside one deployable application, not a reason to build internal services prematurely.

Prefer Rails conventions for ordinary application behavior:

- server-rendered HTML and Hotwire for the first web interface
- Active Record models, validations, associations, scopes, and transactions
- Active Job for work that belongs outside the request cycle
- focused service objects for multi-model orchestration
- PostgreSQL constraints for invariants the database can enforce

## Primary Technology Direction

- **Application:** Ruby on Rails
- **Web UI:** server-rendered HTML with Hotwire by default
- **Database:** PostgreSQL through Active Record
- **External API:** REST/JSON when an external consumer requires it
- **Agent contracts:** gRPC and Protocol Buffers where a long-lived language-neutral boundary is justified
- **Observability:** OpenTelemetry when operational needs justify it
- **Deployment:** OCI containers

The exact Ruby and Rails versions will be recorded by the generated application rather than prescribed before it exists.

## Target Repository Shape

```text
yggdrasil/
├── app/
│   ├── controllers/
│   ├── jobs/
│   ├── models/
│   ├── services/
│   └── views/
├── config/
├── db/
├── test/
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

The Rails application's internal Ruby APIs may evolve with the MVP. Long-lived external contracts require explicit versioning.

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

Prefer Rails, Ruby, and PostgreSQL capabilities before adding another dependency. A new gem or JavaScript package needs a concrete use case, a clear maintenance benefit, and an understood security and upgrade cost.

## Development Process

Development uses lightweight weekly iterations with one goal, a small set of concrete tasks, explicit work states, and a short review. The process should remain practical for a solo developer.
