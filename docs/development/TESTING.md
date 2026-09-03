# Yggdrasil Testing Strategy

## Purpose

Yggdrasil uses tests to protect business behavior, architecture boundaries, security assumptions, and long-term maintainability. The goal is confidence, not an arbitrary coverage percentage.

## Testing Principles

- Test behavior and invariants rather than implementation details.
- Prefer fast tests close to the domain for business rules.
- Add integration tests where persistence, authentication, contracts, or infrastructure behavior matters.
- Keep architecture tests mandatory from the beginning.
- Use end-to-end tests only for critical user journeys.
- Do not add test dependencies unless they provide clear value.
- Tests are production engineering artifacts and must be understandable and maintainable.

## Test Layers

### Domain Tests

Domain tests validate entities, value objects, aggregates, domain services, and business invariants.

Examples:

- invalid work-item state transitions are rejected
- time entries cannot have negative duration
- tenant-owned entities preserve tenant identity
- project rules are enforced without infrastructure dependencies

These tests should be fast and should not require databases, networking, ASP.NET Core, or external processes.

### Use Case Tests

Use-case tests validate command/query orchestration and application behavior.

Examples:

- `CreateTaskCommand` creates the expected domain object
- unauthorized tenant context is rejected
- completing a task emits the expected domain/integration event
- time-entry creation applies appropriate rules

Prefer explicit fakes or small test doubles over large mocking frameworks unless a clear need emerges.

### Integration Tests

Integration tests validate infrastructure boundaries and interactions.

Examples:

- EF Core mappings and PostgreSQL persistence
- database migrations
- API endpoint behavior
- authentication and tenant-context resolution
- serialization and versioned contracts
- transactional outbox/event behavior when introduced

Where practical, integration tests should run against the same PostgreSQL technology used in production rather than relying on an in-memory database with different behavior.

### Architecture Tests

Architecture tests enforce the dependency rules defined in `docs/architecture/dependency-rules.md`.

At minimum they should prevent:

- SharedKernel referencing modules or infrastructure frameworks
- Core referencing Infrastructure, EF Core, ASP.NET Core, or another module implementation
- UseCases referencing another module implementation
- Contracts referencing implementation assemblies
- one module referencing another module's Core, UseCases, or Infrastructure
- host projects becoming owners of domain behavior

These tests are part of the project's architecture enforcement and should run in normal CI.

### End-to-End Tests

End-to-end tests should be few and focused on critical workflows.

An early example might be:

```text
create organization
→ authenticate user
→ select organization
→ create task
→ retrieve task
→ record time
→ verify audit entry
```

Do not duplicate every lower-level test as an end-to-end test.

## Coverage

Yggdrasil does not initially require a fixed global line-coverage target.

Coverage may be measured as a diagnostic signal, but acceptance should focus on whether important behavior, failure modes, and boundaries are adequately tested.

High-risk areas should naturally receive deeper coverage, especially:

- authentication and authorization
- tenant isolation
- agent command authorization
- remote execution
- contract compatibility
- audit integrity
- workflow/state transitions
- data import/export

A coverage threshold may be introduced later if it solves a demonstrated quality problem.

## Security Testing

Security-sensitive features require explicit negative test cases.

Examples:

- a user cannot access another tenant's resource
- expired agent commands cannot execute
- unauthorized users cannot elevate privileges
- malformed or replayed commands are rejected
- cross-tenant identifiers do not bypass authorization
- plugin/extension boundaries reject unsupported capabilities

Threat models should be created for particularly sensitive subsystems such as Smidr and Eir.

## Contract Testing

Public contracts are long-lived platform boundaries.

Tests should validate:

- serialization/deserialization
- required-field behavior
- backward compatibility where required
- Protobuf field-number stability
- versioned package/namespace conventions
- handling of unknown fields/messages

Breaking public contract changes require explicit review and versioning.

## Database Testing

Schema changes should include tests or verification for:

- migration from the previous supported schema
- expected constraints and indexes
- tenant isolation assumptions
- important query behavior
- data preservation

Production data should never be required for automated testing.

## AI and Tests

AI may be used to suggest test cases, identify missing edge cases, review test plans, or explain unfamiliar testing APIs.

AI-generated test code should not be accepted without review. The maintainer must understand what each test proves and why it is valuable.

## Local Verification

Before significant changes are merged, run:

```shell
make check
```

The expected verification pipeline includes formatting, compilation, tests, and architecture checks as those facilities are implemented.

## Test Organization

Tests should mirror production ownership where practical:

```text
tests/
├── architecture/
├── integration/
└── modules/
    ├── tyr/
    ├── valhalla/
    ├── mimir/
    └── urd/
```

Within module tests, organize primarily by behavior or use case rather than creating large generic folders of unrelated tests.
