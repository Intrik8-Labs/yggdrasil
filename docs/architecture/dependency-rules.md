# Dependency Rules

These rules are architectural constraints for Yggdrasil and should eventually be enforced by automated architecture tests.

## 1. Shared Kernel

`Yggdrasil.SharedKernel` may depend only on the .NET base class library and similarly fundamental platform abstractions.

It must not depend on:

- ASP.NET Core
- EF Core
- PostgreSQL/Npgsql
- any Yggdrasil business module
- transport or serialization frameworks

The Shared Kernel must not become a general-purpose utilities project.

## 2. Module Core

A module Core project contains its domain model and business rules.

A Core project may reference:

- `Yggdrasil.SharedKernel`
- the .NET base class library

A Core project must not reference:

- its own Infrastructure project
- its own UseCases project
- ASP.NET Core
- EF Core
- another module's Core, UseCases, or Infrastructure project

## 3. Module UseCases

A module UseCases project owns application orchestration, commands, queries, and use-case-specific abstractions.

It may reference:

- its module Core
- `Yggdrasil.SharedKernel`
- stable Contracts assemblies when consuming another module's public contract is required

It must not reference another module's Core, UseCases, or Infrastructure project.

Commands and queries should be explicit. Small project-owned command/query abstractions are preferred over a mediator dependency until a concrete need justifies one.

## 4. Module Infrastructure

A module Infrastructure project implements persistence and external-system details required by the module.

It may reference:

- its module Core
- its module UseCases
- `Yggdrasil.SharedKernel`
- required framework or provider packages

Infrastructure must not become a route for bypassing module boundaries.

## 5. Module Contracts

A module Contracts project is the stable public boundary for other modules and external consumers where appropriate.

Contracts may contain:

- integration events
- stable public DTOs
- versioned messages
- deliberately public interfaces

Contracts must not reference:

- Core
- UseCases
- Infrastructure
- persistence models

A contract must represent meaning at the boundary, not expose an internal implementation type.

## 6. Cross-Module Communication

**Module implementation assemblies are private.**

The primary rule is:

> Cross-module communication occurs through explicit contracts and events, not implementation references.

Allowed examples:

```text
Mimir.UseCases -> Tyr.Contracts
Urd consumes Mimir.WorkItemCreated
Gjallarhorn consumes Mimir.IncidentCreated
Plugin -> versioned Yggdrasil plugin contract
```

Disallowed examples:

```text
Mimir.UseCases -> Tyr.UseCases
Mimir.Core -> Valhalla.Core
Gjallarhorn.Infrastructure -> Mimir.Infrastructure
Plugin -> Yggdrasil.Mimir.Core
```

Prefer asynchronous events when the interaction represents something that has already happened and the consuming module can react independently.

Use synchronous contracts only when the caller genuinely needs an immediate answer to complete the current operation. Synchronous contracts must still avoid exposing the implementation assembly of the owning module.

## 7. Domain Events vs Integration Events

Domain events are internal to the owning module and represent domain behavior.

Integration events are explicit public contracts intended for consumption outside the owning module.

Do not automatically publish every domain event as an integration event.

## 8. Web / Host Projects

Host projects compose the application and expose transport concerns.

Hosts may reference module UseCases, Contracts, and Infrastructure composition entry points as required for dependency injection and startup.

Hosts must not contain business rules that belong in a module.

Controllers/endpoints should translate transport input into a use case and translate the result back into a transport response.

## 9. Protobuf Boundaries

Protocol Buffers are used for long-lived language-neutral boundaries, especially:

- Smidr agents
- plugins/extensions
- external service contracts

Proto contracts must be versioned and follow backward-compatible evolution rules. Field numbers are never reused after removal.

Internal C# domain types must not leak directly into proto contracts.

## 10. Persistence

Persistence models and database concerns belong in Infrastructure.

Domain models must not depend on EF Core attributes or provider-specific concepts.

Database schemas are implementation details and are not the official customer integration contract.

## 11. Dependency Policy

Prefer .NET platform capabilities before adding a third-party package.

A new dependency should have:

- a concrete use case
- a clear maintenance benefit
- an understood upgrade/security cost
- no simpler existing platform solution that adequately meets the need

Avoid abstraction libraries that merely replace small amounts of clear project-owned code.

## 12. Architecture Tests

Automated architecture tests should eventually verify at least:

- SharedKernel does not reference modules or infrastructure frameworks
- Core projects do not reference Infrastructure, UseCases, ASP.NET, or EF Core
- module implementations do not reference another module's implementation assemblies
- Contracts do not reference implementation assemblies
- host projects do not become domain owners

Violations require either refactoring or an explicit ADR that changes these rules.
