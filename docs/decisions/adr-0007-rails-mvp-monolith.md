# ADR-0007 — Ruby on Rails MVP Monolith

| Field | Value |
| --- | --- |
| Status | ACCEPTED |
| Date | 2026-09-15 |
| Deciders | Intrik8 Labs |
| Supersedes | ADR-0006 |

## Context

Yggdrasil needs to reach a dogfoodable work-management workflow quickly. The previous .NET skeleton established many projects and architecture rules before delivering a product slice. That structure increases the amount of application plumbing the solo MVP must build and maintain.

The product still needs clear business ownership, tenant isolation, PostgreSQL persistence, data portability, and a path to language-neutral agent contracts. Those needs do not require separate internal projects or distributed services during the MVP.

## Decision

The MVP will use:

- Ruby on Rails as the application framework
- a single deployable Rails monolith
- PostgreSQL through Active Record
- server-rendered HTML and Hotwire by default
- Ruby namespaces for business ownership boundaries
- focused service objects for orchestration that does not belong to one model
- explicit public interfaces or events for cross-module behavior
- Protocol Buffers only for justified long-lived external boundaries such as endpoint agents

Rails conventions are the default. New abstractions and dependencies require a demonstrated need from a real feature.

## Consequences

### Positive

- Less setup and plumbing before the first useful workflow
- One conventional development and deployment unit
- Integrated support for web UI, persistence, migrations, jobs, mail, and security controls
- Faster iteration for a solo-maintained MVP
- PostgreSQL and external contract goals remain intact

### Tradeoffs

- Namespace boundaries inside one Rails application require discipline and targeted checks
- Active Record couples the domain model more closely to persistence than the previous design intended
- Future extraction will require deliberate contract design rather than relying on project boundaries
- Ruby's runtime checks place more weight on tests and review

## Alternatives Considered

### Continue the .NET modular skeleton

Rejected for the MVP because the structure front-loads architectural work before proving the first product workflow. It may remain a future option if measured needs justify another service or implementation language.

### Rails API with a separate React application

Deferred. A separate frontend creates another build, state-management, authentication, and deployment surface. Hotwire and server-rendered HTML are sufficient until product evidence requires a richer client boundary.

### Microservices

Rejected for the MVP because they add operational and integration costs without a demonstrated scaling or team-ownership need.

## Related

- `docs/architecture/overview.md`
- `docs/architecture/dependency-rules.md`
- `docs/decisions/adr-0004-modular-boundaries-event-driven-comms.md`
- `docs/decisions/adr-0006-dotnet-modular-clean-architecture.md`
