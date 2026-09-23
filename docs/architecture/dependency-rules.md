# Dependency Rules

These rules keep the .NET modular monolith understandable as the product grows. They should be enforced by tests or static checks where doing so provides useful feedback.

## 1. Business Namespaces

Each business area owns its models, policies, workflows, and public interfaces. Initial module namespaces include `Yggdrasil.Tyr`, `Yggdrasil.Valhalla`, `Yggdrasil.Mimir`, and `Yggdrasil.Urd`.

A module must not reference another module’s Core, UseCases, or Infrastructure assembly. Cross-module calls use deliberately public Contracts interfaces, DTOs, and events.

## 2. Project Dependencies

- **Core** owns domain entities, value objects, invariants, and domain events. It has no ASP.NET Core, EF Core, or vendor SDK dependency.
- **UseCases** owns command/query orchestration and application interfaces. It depends on Core and required public Contracts.
- **Infrastructure** implements persistence and external adapters. It depends inward on Core and UseCases.
- **Contracts** exposes stable DTOs, interfaces, and integration events without exposing domain or persistence objects.
- **Hosts** compose services through dependency injection. HTTP endpoints and controllers own transport concerns and call use cases.
- **SharedKernel** contains only small, framework-free concepts genuinely shared by multiple modules.

Background services invoke use cases through the same boundaries. Moving work outside the request cycle does not permit bypassing authorization or tenant context.

## 3. Cross-Module Communication

Prefer a direct, explicit call when the caller needs an immediate result. Use an event when something has already happened and consumers can react independently.

Do not publish every model callback as an event. Events represent meaningful business facts and must carry stable identifiers rather than tracked EF Core entities.

## 4. Persistence

Use EF Core/Npgsql inside Infrastructure for PostgreSQL persistence. Keep EF Core types out of Core and public Contracts. Application-owned persistence interfaces should express use-case needs rather than merely rename generic CRUD operations.

All tenant-owned records and queries must be scoped to the active tenant. Security must not depend on a caller remembering an optional scope. Important uniqueness and referential-integrity rules should also be enforced by PostgreSQL constraints.

Schema migrations are part of the application and must preserve supported data or explicitly document a destructive change.

## 5. External Contracts

REST resources, webhooks, Protocol Buffer messages, and import/export formats are explicit boundaries. Do not serialize EF Core entities as an accidental public contract.

Long-lived contracts must be versioned and tested for compatibility. Removed Protocol Buffer field numbers are never reused.

## 6. Dependencies

Prefer capabilities already provided by .NET, ASP.NET Core, PostgreSQL, and the browser. Add a NuGet or JavaScript package only for a concrete need with a clear maintenance benefit.

Business code must not depend directly on an external vendor SDK when a small application-owned boundary would make failure behavior testable and replacement practical.

## 7. Verification

Automated checks should eventually verify at least:

- tenant-owned access cannot escape the active tenant
- assembly references follow the Core, UseCases, Infrastructure, and Contracts dependency rules
- controllers remain orchestration-focused
- public contracts do not expose internal model representations
- database constraints reinforce critical invariants

Violations require refactoring or an ADR that deliberately changes these rules.
