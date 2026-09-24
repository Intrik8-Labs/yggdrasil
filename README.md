# Intrik8 Yggdrasil

> **Work in progress:** Yggdrasil is an early-stage project being built from the ground up. The architecture, domain model, APIs, user experience, and deployment model are actively evolving. It is not production-ready and should not yet be treated as a finished platform.

**Intrik8 Yggdrasil** — also described as **Yggdrasil by Intrik8 Labs** — is a modular operations platform for managing work, customers, assets, documentation, automation, monitoring, and endpoint agents from one system.

The long-term target is a CRM/ERP/MSP-style platform that can run as self-hosted software, in air-gapped environments, or as a cloud-hosted service. Development begins with a small dogfoodable foundation and grows module-by-module.

## Architecture

Yggdrasil is built on **C# and .NET 10**, using ASP.NET Core and a modular monolith architecture. Development proceeds in small vertical slices with explicit domain, use-case, infrastructure, and contract boundaries.

Each module owns its domain and exposes clear boundaries rather than allowing unrelated features to reach into its implementation. Long-lived external boundaries remain versioned so future plugins, agents, and selective service extraction are possible without making the MVP distributed.

The primary application stack is:

- C# and .NET 10 with ASP.NET Core
- PostgreSQL with EF Core/Npgsql
- React + TypeScript + Vite for the planned web frontend
- gRPC + Protocol Buffers for long-lived agent/plugin contracts where appropriate
- OpenTelemetry for vendor-neutral observability
- OCI containers for portable deployment

Yggdrasil intentionally minimizes third-party dependencies. .NET and ASP.NET Core functionality is preferred when it adequately solves the problem.

See [`docs/architecture/overview.md`](docs/architecture/overview.md) and [`docs/architecture/dependency-rules.md`](docs/architecture/dependency-rules.md).

## Initial Development Scope

The first useful vertical slice focuses on four modules:

- **Týr** — authentication, identity, memberships, and access control
- **Valhalla** — organization and tenant administration
- **Mímir** — tasks, tickets, projects, work tracking, and time tracking
- **Urd** — audit trail and compliance logging

The goal is to make Yggdrasil useful enough to manage its own development before expanding into the broader module catalog.

Future modules include Smidr agent orchestration, Heimdallr monitoring, Odin knowledge/document management, Freyja asset lifecycle management, Loki automation, Gjallarhorn SLA/escalation, and other platform capabilities. See [`docs/modules/MODULES.md`](docs/modules/MODULES.md).

## Development Philosophy

Yggdrasil is intentionally being developed as a long-term engineering project rather than as an AI-generated application.

- **Tool independence:** the repository must remain usable from standard command-line tooling; no particular editor or IDE is required.
- **Human-authored production code:** application and domain code should primarily be designed and written by the maintainer rather than generated wholesale by AI.
- **AI as an engineering aid:** AI may be used for documentation, research, architecture discussion, code review, test-case discovery, edge-case analysis, and explaining unfamiliar APIs or concepts.
- **Tests remain engineering artifacts:** AI can suggest test scenarios and help identify missing cases, but tests should be reviewed, understood, and owned by the maintainer.
- **No opaque generated code:** code should not be accepted merely because an AI tool produced it. The maintainer should be able to explain and maintain the resulting implementation.

The objective is to use AI to improve reasoning and documentation without outsourcing understanding of the codebase.

## Design Principles

- Customer data belongs to the customer and must be easy to export and import.
- Core functionality must work without Internet or cloud dependencies.
- Security and tenant isolation are architectural requirements, not later add-ons.
- Internal module implementation details remain private; contracts and events define public boundaries.
- Prefer understandable code over abstraction-heavy enterprise patterns.
- Significant long-term decisions are recorded as ADRs.
- Development follows lightweight weekly Agile iterations suitable for a solo project.

## Brand and Naming

The formal product name is **Intrik8 Yggdrasil**.

**Yggdrasil by Intrik8 Labs** may be used as a descriptive marketing form, while **Yggdrasil** remains the short internal and conversational name.

The intended hierarchy is:

```text
Intrik8 Labs
└── Intrik8 Yggdrasil
    ├── Týr
    ├── Mímir
    ├── Urd
    ├── Smidr
    └── other platform modules
```

The Intrik8 name should remain prominent in public branding to distinguish the product from other technology products using the Yggdrasil name.

## Development

Prerequisites and repository commands are documented in [`CONTRIBUTING.md`](CONTRIBUTING.md).

The repository contains `yggdrasil.slnx` and an ASP.NET Core API scaffold at `src/hosts/Yggdrasil.Api`. Module scaffolding lives under `src/modules`, with shared domain concepts under `src/shared`. Business workflows, database persistence, and the web frontend are developed through focused vertical slices. Use `mise install` to install the .NET 10 SDK and `mise run check` to run the current solution checks.

## License

Yggdrasil is licensed under the [Business Source License 1.1](LICENSE). The `LICENSE` file is the authoritative license text.
