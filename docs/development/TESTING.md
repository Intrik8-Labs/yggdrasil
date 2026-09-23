# Yggdrasil Testing Strategy

## Purpose

Tests protect business behavior, security assumptions, data integrity, and maintainability. The goal is confidence, not an arbitrary coverage percentage.

## Testing Principles

- Test behavior and invariants rather than implementation details.
- Prefer fast domain and use-case unit tests for business rules.
- Add request and integration tests where routing, authentication, persistence, or contracts matter.
- Keep system tests focused on critical user journeys.
- Use the same PostgreSQL behavior in integration tests that production relies on.
- Add explicit negative tests for authorization and tenant isolation.

## Test Layers

### Domain Tests

Domain tests cover invariants, value objects, state transitions, and business behavior without requiring ASP.NET Core or EF Core. Examples include rejecting invalid task transitions, preventing negative time entries, and preserving tenant ownership.

### Use-Case and Background-Service Tests

Use-case tests cover orchestration through application-owned interfaces. Infrastructure integration tests cover EF Core mappings and transaction behavior against PostgreSQL. Background-service tests cover retries, idempotency, cancellation, and observable outcomes.

### HTTP Integration Tests

ASP.NET Core integration tests cover routes, authentication, authorization, tenant selection, parameter handling, and response contracts.

### System Tests

System tests should be few and focus on critical workflows, for example:

```text
create organization
→ authenticate user
→ select organization
→ create task
→ record time
→ verify audit entry
```

### Boundary and Contract Tests

Tests should enforce important namespace boundaries and validate any long-lived REST, webhook, import/export, or Protocol Buffer contracts. Breaking external contract changes require explicit review and versioning.

## Security Testing

Security-sensitive behavior requires negative cases, including cross-tenant identifiers, missing permissions, replayed or expired agent commands, and malformed inputs. Particularly sensitive subsystems should have a threat model.

## Database Testing

Schema changes should verify migrations, constraints, indexes, tenant-isolation assumptions, important query behavior, and data preservation. Production data must never be required for automated tests.

## Local Verification

Run `mise run check` for restore, build, formatting verification, and `dotnet test`. Use `mise run ci` for Release configuration and `pre-commit run --all-files` for repository hygiene and secret checks.

The solution currently contains an ASP.NET Core API scaffold with no application test projects. Add .NET test projects to `yggdrasil.slnx` alongside behavioral implementation; a successful test command with no tests does not establish coverage. Tenant-isolation, security, and architecture tests must be added as the corresponding components are implemented.

The Python commit-message hook tests run separately with `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -v`.

## AI and Tests

AI may suggest test cases or review test plans, but generated tests must be understood and reviewed. Every test should have a clear reason to exist and should prove an observable behavior or risk control.
