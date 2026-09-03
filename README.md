# Yggdrasil

Yggdrasil is a modular operations platform by Intrik8 Labs for managing work, customers, assets, documentation, automation, monitoring, and endpoint agents from one system.

The long-term target is a CRM/ERP/MSP-style platform that can run as self-hosted software, in air-gapped environments, or as a cloud-hosted service. Development begins with a small dogfoodable foundation and grows module-by-module.

## Architecture

Yggdrasil is being built as a **modular monolith using Clean Architecture**.

Each module owns its domain and exposes stable contracts rather than allowing other modules to reference its implementation. Cross-module interaction should primarily use explicit contracts and events. This same boundary will support future plugins, extensions, agents, and potential service extraction.

The primary application stack is:

- C# / .NET 10 / ASP.NET Core
- PostgreSQL with EF Core and Npgsql
- React + TypeScript for the web client
- gRPC + Protocol Buffers for long-lived agent/plugin contracts where appropriate
- OpenTelemetry for vendor-neutral observability
- OCI containers for portable deployment

Yggdrasil intentionally minimizes third-party dependencies. Platform functionality is preferred when it adequately solves the problem.

See [`docs/architecture/overview.md`](docs/architecture/overview.md) and [`docs/architecture/dependency-rules.md`](docs/architecture/dependency-rules.md).

## Initial Development Scope

The first useful vertical slice focuses on four modules:

- **Týr** — authentication, identity, memberships, and access control
- **Valhalla** — organization and tenant administration
- **Mímir** — tasks, tickets, projects, work tracking, and time tracking
- **Urd** — audit trail and compliance logging

The goal is to make Yggdrasil useful enough to manage its own development before expanding into the broader module catalog.

Future modules include Smidr agent orchestration, Heimdallr monitoring, Odin knowledge/document management, Freyja asset lifecycle management, Loki automation, Gjallarhorn SLA/escalation, and other platform capabilities. See [`docs/modules/MODULES.md`](docs/modules/MODULES.md).

## Design Principles

- Customer data belongs to the customer and must be easy to export and import.
- Core functionality must work without Internet or cloud dependencies.
- Security and tenant isolation are architectural requirements, not later add-ons.
- Module implementation assemblies are private; contracts and events are public boundaries.
- Prefer understandable code over abstraction-heavy enterprise patterns.
- Significant long-term decisions are recorded as ADRs.
- Development follows lightweight weekly Agile iterations suitable for a solo project.

## Development

Prerequisites and repository commands are documented in [`CONTRIBUTING.md`](CONTRIBUTING.md).

The repository is currently in an architecture-foundation phase. Existing code and issues from earlier experiments are being reconciled with the current .NET modular-monolith direction.

## License

Yggdrasil is licensed under the [Business Source License 1.1](LICENSE). The `LICENSE` file is the authoritative license text.
