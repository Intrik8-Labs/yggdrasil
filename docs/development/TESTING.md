# Yggdrasil Testing Strategy

## Purpose

Tests protect business behavior, security assumptions, data integrity, and maintainability. The goal is confidence, not an arbitrary coverage percentage.

## Testing Principles

- Test behavior and invariants rather than implementation details.
- Prefer fast model and service tests for business rules.
- Add request and integration tests where routing, authentication, persistence, or contracts matter.
- Keep system tests focused on critical user journeys.
- Use the same PostgreSQL behavior in integration tests that production relies on.
- Add explicit negative tests for authorization and tenant isolation.

## Test Layers

### Model Tests

Model tests cover validations, relationships, state transitions, scopes, and business behavior. Examples include rejecting invalid task transitions, preventing negative time entries, and preserving tenant ownership.

### Service and Job Tests

Focused service tests cover multi-model use cases and transaction behavior. Job tests cover enqueueing, retries, idempotency, and observable outcomes rather than framework internals.

### Request Tests

Request tests cover routes, authentication, authorization, tenant selection, parameter handling, and response contracts.

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

The Rails app has not been generated yet. Once it exists, document one canonical command that runs the application test, lint, security, and boundary checks required before merge.

## AI and Tests

AI may suggest test cases or review test plans, but generated tests must be understood and reviewed. Every test should have a clear reason to exist and should prove an observable behavior or risk control.
