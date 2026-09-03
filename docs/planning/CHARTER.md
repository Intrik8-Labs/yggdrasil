# Yggdrasil — Project Charter

## Status

Yggdrasil is in an architecture-foundation and early dogfood phase. The project has a broad long-term platform vision, but implementation proceeds through small vertical slices and weekly iterations.

## Vision

Yggdrasil is intended to become a unified operations platform for organizations that currently rely on disconnected CRM, ERP, MSP/RMM, project-management, service-management, documentation, and automation tools.

The system should be capable of running:

- self-hosted
- in air-gapped environments
- as a cloud-hosted service

The architecture must support security-sensitive organizations, including environments with government-contractor requirements, without making enterprise-scale infrastructure a requirement for small deployments.

## Initial Audience

Early development is dogfooded first, while the long-term audience includes:

- managed service providers
- software companies
- small businesses
- home businesses
- security-sensitive organizations

Dogfooding is the primary mechanism for validating the first workflows before broader product assumptions are made.

## Initial Product Goal

The first useful version should allow Yggdrasil to manage its own development work.

The initial vertical slice includes:

- **Týr** — identity, authentication, organization memberships, and access control foundations
- **Valhalla** — organization and tenant administration
- **Mímir** — projects, tasks, basic workflow, comments, and time tracking
- **Urd** — audit of important application changes

Smidr/Heimdallr endpoint capabilities remain important, but follow the core work-management and tenant foundation so that the platform has a secure domain model to attach them to.

## Architectural Identity

Yggdrasil is built as a modular monolith using Clean Architecture.

Guiding rules include:

- module implementation assemblies are private
- modules integrate primarily through explicit public contracts and events
- long-lived agent/plugin/extension boundaries use versioned language-neutral contracts where appropriate
- the SharedKernel remains small and framework-free
- dependencies are minimized and .NET platform capabilities are preferred
- customer data must be portable through supported APIs and export/import formats
- runtime features must not inherently require public Internet or cloud services

See `docs/architecture/overview.md` and `docs/architecture/dependency-rules.md`.

## Technology Direction

- C# / .NET 10 / ASP.NET Core
- PostgreSQL with EF Core/Npgsql
- React + TypeScript
- gRPC + Protocol Buffers for agent and other long-lived external contracts
- OpenTelemetry
- OCI containers

The primary application language is C#, but contracts should permit agents, plugins, and extensions to use other suitable languages.

## Success Criteria for the Foundation

- repository structure reflects the agreed Clean Architecture module model
- architecture rules are covered by automated tests
- the application builds consistently on Linux, macOS, and Windows
- initial Týr, Valhalla, Mímir, and Urd boundaries exist
- a first task/project workflow can be dogfooded
- important changes are auditable
- weekly project reviews can be driven from the task backlog

## Guiding Principles

- Build in small vertical slices.
- Prefer understandable code over abstraction-heavy framework patterns.
- Record meaningful architecture decisions as ADRs.
- Do not add dependencies without a concrete need.
- Do not break module boundaries for short-term convenience.
- Treat air-gap compatibility, tenant isolation, security, and data portability as architectural constraints from the start.
- Use lightweight weekly Agile planning rather than process-heavy ceremony.

## License

Yggdrasil is currently licensed under the Business Source License 1.1. The repository `LICENSE` file is authoritative.
