# Týr — Identity, Authentication, and Access Control

## Purpose

Týr is the Yggdrasil module responsible for identity, authentication, organization membership, and access-control foundations.

Týr answers two different questions:

1. **Who is this actor?**
2. **What is this actor allowed to do in the active tenant?**

Those concerns are related, but they should remain conceptually distinct. Authentication proves identity. Authorization evaluates access in context.

The initial objective is to provide a secure multi-tenant identity foundation that supports Yggdrasil's first dogfood deployment without prematurely building every enterprise identity feature.

## Responsibilities

Týr owns:

- user identity
- authentication
- credentials and authentication methods
- organization memberships
- active membership/tenant context
- roles
- permissions
- role assignments
- service identities when introduced
- API credentials when introduced
- account status and access-related lifecycle state
- authentication/session policy

Týr does not own:

- organization business/profile configuration — Valhalla
- work items/projects — Mímir
- durable compliance/audit history — Urd
- customer portal behavior — Bifröst
- agent orchestration — Smidr
- workflow automation — Loki
- contracts/billing — Forseti

Týr may expose stable contracts for identity and authorization information, but other modules must not reference Týr Core, UseCases, or Infrastructure assemblies.

## Core Model

### User

A User represents a human identity known to Yggdrasil.

Expected concepts include:

- UserId
- login identifiers
- display/profile information required by the platform
- account state
- authentication-method references
- creation/update timestamps

A User is not itself a tenant.

A single user may belong to multiple organizations.

```text
User
├── Membership → Organization A
├── Membership → Organization B
└── Membership → Organization C
```

Tenant-specific roles and permissions belong to the membership/access context rather than being treated as global user properties.

### Membership

Membership links a user to an organization/tenant.

Expected concepts include:

- MembershipId
- UserId
- TenantId / OrganizationId
- membership status
- role assignments
- invitation/activation metadata where appropriate
- created/updated timestamps

Membership is the primary boundary for answering whether a user belongs to a tenant.

A disabled or revoked membership must not grant tenant access even if the underlying User remains active.

### Role

A Role is a named collection of permissions scoped to an organization or platform context.

The design should eventually support:

- built-in roles
- organization-defined roles
- role versioning
- explicit permission grants
- explicit deny where justified

Role names must not become authorization logic.

Code should evaluate permissions/capabilities, not strings such as `Admin` scattered throughout the application.

### Permission

Permissions describe allowed actions against platform capabilities/resources.

An eventual convention may resemble:

```text
mimir.task.read
mimir.task.create
mimir.task.assign
mimir.task.change-status
valhalla.organization.manage
urd.audit.read
```

Exact naming should be defined in a dedicated authorization convention before broad implementation.

The default authorization posture should be deny unless access is explicitly granted by policy.

## Authentication

Týr should support multiple authentication mechanisms over time without forcing domain modules to understand how authentication occurred.

### Initial Authentication

The initial release should support a secure local authentication mechanism sufficient for dogfooding.

Implementation choices should use established ASP.NET Core/.NET security facilities where they meet requirements rather than inventing custom cryptography or password protocols.

At minimum, local authentication should account for:

- secure password hashing using established platform/library mechanisms
- account lockout/rate limiting where appropriate
- session/token expiration
- credential revocation
- secure password reset when introduced
- no plaintext or reversibly encrypted passwords

### Future Authentication Methods

Potential future capabilities include:

- OpenID Connect
- SAML where customer demand justifies it
- passkeys/WebAuthn
- MFA
- organization-specific identity providers
- certificate-backed/service authentication

These should be introduced behind Týr's public identity/authentication boundary rather than leaking provider-specific concepts into business modules.

## Session and Token Context

Authenticated requests need enough context to identify the actor and active tenant safely.

A conceptual request context may include:

```text
ActorId
UserId
TenantId
MembershipId
AuthenticationMethod
Permissions / authorization context
```

Tokens should remain small enough to manage securely and should not become an indefinitely stale copy of the full authorization database.

Whether permissions are embedded directly in tokens, resolved per request, cached, or represented through role/version references is an implementation decision that should consider revocation latency and operational complexity.

## Tenant Selection and Switching

Users belonging to multiple organizations should be able to switch active organization through the application.

The normal UX may use an organization selector/dropdown.

High-security deployments should be able to require stronger switching policy, including reauthentication when moving between tenant contexts.

Conceptually:

```text
RequireReauthenticationOnTenantSwitch = false
```

may be the general default, while security-sensitive environments can enable:

```text
RequireReauthenticationOnTenantSwitch = true
```

Changing tenant context must always cause authorization to be recalculated for the selected membership.

A user must never retain permissions from the previously active tenant.

## Authorization

Authorization is a first-class architectural requirement.

Every protected operation should evaluate access based on the active actor and tenant context.

Important principles:

- deny by default
- permissions are explicit
- authorization is enforced server-side
- UI visibility is not a security boundary
- tenant membership is verified independently of resource identifiers
- privileged overrides are explicit and auditable
- service accounts do not bypass domain/workflow rules by default

### Resource Authorization

Permission to perform an action may depend on more than a global permission.

For example:

```text
Can user edit this task?

Membership active?
+ task belongs to active tenant?
+ user has task.edit permission?
+ field/status-specific rule allows change?
```

Týr owns identity/access policy foundations, while resource-owning modules may provide resource-specific authorization facts/rules through clear application boundaries.

## Roles and Permission Evolution

Permissions and roles will evolve as modules grow.

Avoid storing authorization semantics only in mutable role names.

Long-term role versioning may be useful so audit records can answer what a role meant at a historical point in time.

Potential concepts:

- RoleId
- RoleVersion
- PermissionSet
- EffectiveFrom
- SupersededBy

Do not implement role versioning until the audit/compliance use case requires it, but avoid architecture choices that make it impossible.

## Explicit Allow and Deny

The long-term access model may support both ALLOW and DENY rules.

General evaluation should remain predictable:

```text
default = DENY
explicit DENY overrides ALLOW where policy requires it
```

Because explicit-deny systems can become difficult to reason about, introduce them only with clear precedence rules and tests.

## Service Identities

Yggdrasil will eventually require non-human actors such as:

- Smidr agents
- integrations
- automation workers
- plugins/extensions
- deployment tooling

These should use explicit service identities rather than impersonating normal users.

A service identity should have:

- unique ActorId/ServiceIdentityId
- tenant/platform scope
- explicit capabilities/permissions
- credential lifecycle
- revocation capability
- audit attribution

Service identities should follow least privilege.

They must not receive unrestricted platform access merely because they are machine actors.

## API Keys and Credentials

When API keys are introduced:

- secrets should be shown only at creation where practical
- stored values should not permit recovery of the original key
- credentials must be revocable
- credentials need scopes/permissions
- expiration should be supported
- usage should be auditable
- key identifiers should distinguish credentials without exposing secrets

Prefer short-lived credentials where the integration model permits them.

## Agent Identity Boundary

Týr may participate in identity/trust concepts used by Smidr, but Smidr agent security is sufficiently specialized that its enrollment and command-trust model should be designed jointly with the Smidr security architecture.

Agent authentication must eventually account for:

- per-agent identity
- enrollment
- credential/certificate rotation
- revocation
- compromised-agent handling
- signed/authorized commands

Do not reuse ordinary interactive-user credentials for agents.

## Contracts and Events

Other modules consume identity information through stable public contracts/events.

Potential public contracts include queries/results such as:

- ResolveActor
- ResolveMembership
- GetActiveMembership
- CheckPermission
- GetUserSummary

Potential integration events include:

- UserCreated
- UserDisabled
- MembershipCreated
- MembershipActivated
- MembershipRevoked
- RoleAssigned
- RoleRemoved
- CredentialRevoked

Events describe facts that already occurred and should contain only stable information required by consumers.

Example:

```text
MembershipRevoked
├── Urd records audit context
├── Verdandi may notify administrators
└── active sessions may need invalidation/re-evaluation
```

Authorization should not rely on asynchronous integration events for decisions that require immediate consistency.

## Multi-Tenancy Requirements

Týr is a critical component of tenant isolation.

It must be impossible for a user to gain access to Tenant B simply by presenting an identifier from Tenant B while authenticated in Tenant A.

Every tenant-scoped request should establish:

1. authenticated actor
2. active tenant
3. valid active membership or service authorization
4. required permission
5. resource belongs to the active tenant

These checks should be consistently enforced through reusable application/security mechanisms rather than duplicated ad hoc in controllers.

## Personal Workspace

The architecture may eventually support a Personal Workspace represented as a single-principal tenant.

A personal workspace would:

- have one implicit owner
- not require ordinary role/invitation management
- still participate in workflows, audit, time tracking, and other tenant-scoped capabilities
- provide a future promotion/copy path into a normal organization

Do not let Personal Workspace support weaken normal tenant-isolation guarantees.

## Audit Requirements

Security-relevant identity changes must be auditable through Urd.

Examples include:

- login successes/failures where appropriate
- credential changes
- membership creation/revocation
- role/permission changes
- tenant switching in high-security modes
- service-credential creation/revocation
- privileged overrides
- account disable/enable actions

Týr emits meaningful security events/context. Urd owns durable audit storage and integrity guarantees.

Sensitive authentication secrets must never be written into audit logs.

## Security Requirements

Týr is security-critical and should receive deeper testing/review than ordinary feature code.

At minimum:

- TLS is required for deployed authentication flows
- secrets are never logged
- passwords are never stored reversibly
- token/session expiry is enforced
- revoked access stops authorizing new protected operations
- tenant switching clears/replaces tenant-specific authorization context
- authentication endpoints are rate-limited appropriately
- authorization decisions are server-side
- sensitive errors do not disclose unnecessary account information
- cryptographic implementation uses established primitives/libraries

Future high-security requirements may include:

- mandatory MFA
- hardware-backed credentials
- client certificates
- session reauthentication requirements
- configurable idle/session lifetimes
- restricted authentication providers
- stronger administrative separation of duties

## Initial MVP

The first Týr slice should provide only what is necessary to securely support the initial Yggdrasil vertical slice.

### Required

- create/bootstrap initial user
- secure local authentication
- user identity
- organization membership
- user may belong to multiple organizations
- select active organization
- resolve active tenant/membership context
- basic role/permission model
- authorization support consumed by initial modules
- account disable/revocation basics
- audit significant identity/access changes

### Not Required Initially

- SAML
- organization-specific OIDC providers
- complex MFA policy
- SCIM provisioning
- passkeys
- advanced delegated administration
- full service-account UI
- API-key management UI
- role version history
- explicit DENY policy editor
- impersonation

These are valid future capabilities but should not block the first dogfood deployment.

## Initial Use Cases

Likely first UseCases include:

```text
Users/
├── BootstrapAdmin/
├── Authenticate/
├── GetCurrentUser/
└── DisableUser/

Memberships/
├── Create/
├── ListForUser/
├── SelectActive/
└── Revoke/

Authorization/
├── CheckPermission/
└── GetEffectivePermissions/
```

The specific authentication plumbing may live partly in Infrastructure/host integration, but business access rules and membership behavior should remain testable outside ASP.NET controllers.

## Initial Aggregate Candidates

### User Aggregate

Likely owns:

- user identity lifecycle
- account state
- authentication-method association at an appropriate abstraction level

### Membership Aggregate

Likely owns:

- relationship between User and Tenant
- membership lifecycle
- tenant-scoped role assignment

### Role Aggregate

May own:

- role identity
- permission definitions/assignments
- organization ownership where custom roles exist

The final transactional boundaries should be validated during implementation rather than treating this document as a permanent ORM schema.

## Testing Priorities

Týr requires substantial negative testing.

Examples:

- invalid password rejected
- disabled user cannot authenticate
- revoked membership cannot access tenant
- Tenant A membership cannot access Tenant B resources
- switching tenants does not preserve prior tenant permissions
- user without permission receives denial
- role removal takes effect within the defined consistency window
- API/service credentials cannot exceed configured scope
- authentication secrets never appear in returned error payloads/logging paths

See `docs/development/TESTING.md`.

## Data Portability and Privacy

Customer-owned identity/membership data should be exportable where appropriate, but security-sensitive credential material must not be exported in reusable form.

Portable data may include:

- user profile/account metadata
- organization memberships
- role definitions
- permission assignments

Exports must exclude or safely transform:

- password hashes where portability would create security risk
- session tokens
- API secret values
- private keys
- temporary/reset credentials

Import behavior must not allow privileged access to be silently created without validation.

## Open Design Questions

Resolve incrementally:

1. Which ASP.NET Core authentication/session model best fits local auth plus future federation?
2. Should authorization permissions be claims-based, policy-resolved, database-resolved, or hybrid?
3. What is the required permission-revocation latency?
4. How are built-in versus organization-defined roles represented?
5. When should explicit DENY be introduced?
6. How should Personal Workspace identities/memberships be represented?
7. Which tenant switches require reauthentication?
8. What credential model should service identities use?
9. How should Smidr enrollment/trust responsibilities be divided between Týr and Smidr?
10. What password/MFA policies should be platform defaults versus tenant-configurable?
11. Which security events should cause immediate session invalidation?
12. How much authentication event detail should be retained for privacy/security balance?

## Success Criteria

The initial Týr milestone is successful when:

- one user can securely authenticate
- that user can belong to multiple organizations
- active tenant selection is reliable
- all initial module operations are authorized against the correct membership and tenant
- unauthorized cross-tenant access fails consistently
- access changes are auditable
- business modules do not need to understand the authentication provider or Týr's internal persistence model

## Related Documentation

- `docs/architecture/overview.md`
- `docs/architecture/dependency-rules.md`
- `docs/development/WORKFLOW.md`
- `docs/development/TESTING.md`
- `docs/modules/MODULES.md`
- `docs/modules/MIMIR.md`
