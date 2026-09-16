# Týr MVP Design

**Status:** Draft for the Rails MVP

## Purpose

Týr owns human identity, authentication, organization membership, and the authorization foundation. It does not own organization details or business workflows belonging to other modules.

## Rails Direction

Týr is implemented inside the Rails monolith under an explicit `Tyr` namespace. Authentication may use a focused, well-maintained Rails solution once the application is generated, but the domain concepts must not be collapsed into framework session details.

Initial concepts are:

- `User` — a human identity and lifecycle
- `Membership` — a user's role and status in an organization
- `Session` — an authenticated browser session
- `Current` context — the authenticated user and active organization for one request or job

Valhalla owns organizations. Týr may reference an organization by stable identifier and query a deliberately public Valhalla interface; it must not own organization settings.

## Authentication

The MVP should support local authentication without requiring an external identity provider. Password storage must use Rails-supported secure password hashing, secrets must stay out of source control, and session cookies must use secure production settings.

Authentication establishes who the user is. It does not by itself grant access to an organization's data.

## Membership and Tenant Context

A membership connects a user to an organization and carries its status and role. Selecting an active organization requires an active membership.

Every request and background job that touches tenant-owned data must establish tenant context explicitly. A raw tenant identifier from request parameters is never sufficient authorization.

## Authorization

Authorization rules should be expressed through a consistent policy boundary and tested independently of controllers. Controllers ask whether an action is allowed; they do not implement role matrices inline.

The first role model should remain small. Add permissions because a real workflow needs them, not to anticipate every future module.

## Events and Audit

Meaningful identity events may include:

- user registered or activated
- authentication succeeded or failed
- membership created, changed, suspended, or removed
- active organization changed

Urd consumes the events that require an audit record. Events carry stable identifiers and relevant metadata, not live Active Record instances or password/session secrets.

## Security Requirements

- avoid account-enumeration leaks
- rate-limit sensitive authentication endpoints when exposed
- rotate the session identifier after authentication
- invalidate sessions when required by password or account-state changes
- require authorization and tenant scoping for every membership mutation
- audit security-sensitive changes without recording secrets

## Initial Delivery Sequence

1. User model and local authentication
2. Organization membership model
3. request-scoped current user and organization
4. authorization policy boundary
5. login, logout, and organization selection
6. audit events for sensitive identity and membership changes
7. request and system tests for cross-tenant and unauthorized paths

Implementation details should be refined against the generated Rails application and recorded in an ADR when they create a long-lived constraint.
