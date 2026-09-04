# Valhalla — Organization and Tenant Administration

## Purpose

Valhalla is the Yggdrasil module responsible for organization and tenant administration.

It owns the administrative lifecycle and configuration of a tenant as a business boundary, while Týr owns the identities and memberships that act within that tenant.

The distinction is intentional:

- **Týr** answers who an actor is and whether they may act in a tenant.
- **Valhalla** defines and manages the tenant itself.

The initial objective is to provide a secure, minimal organization-management foundation for Yggdrasil's first multi-tenant dogfood deployment.

## Responsibilities

Valhalla owns:

- organization/tenant identity
- organization lifecycle
- organization profile and administrative metadata
- organization status
- tenant-level configuration
- organization creation/bootstrap
- organization administrative settings
- business-hour configuration when introduced
- feature/configuration flags that are truly tenant administrative concerns
- tenant-level deployment/configuration metadata where appropriate
- tenant archival/deactivation rules

Valhalla does not own:

- user identity, credentials, memberships, roles, or permissions — Týr
- work items and projects — Mímir
- audit-history persistence — Urd
- SLA policy execution — Gjallarhorn
- billing/contracts/payments — Forseti
- notifications — Verdandi
- documents/knowledge — Odin
- automation — Loki
- assets — Freyja

Other modules must consume Valhalla through stable public contracts/events rather than referencing its Core, UseCases, or Infrastructure assemblies.

## Core Concepts

### Organization

An Organization represents the principal multi-tenant business boundary in Yggdrasil.

Expected concepts include:

- OrganizationId / TenantId
- Name
- Slug or stable display identifier where useful
- Status
- CreatedAt
- UpdatedAt
- administrative/profile metadata
- default settings

Organization and Tenant may be represented by the same underlying domain identity initially.

Avoid creating separate concepts merely for terminology unless their behavior diverges.

### Tenant Identity

Every tenant-owned resource in Yggdrasil must ultimately resolve to a stable tenant identifier.

Valhalla is the source of truth for the tenant's administrative existence and status.

A tenant identifier must be:

- globally unique within the deployment
- immutable once assigned
- safe to use across module contracts
- independent of organization display name

Display names and slugs may change without changing tenant identity.

### Organization Status

An organization may eventually have lifecycle states such as:

```text
Active
Suspended
Archived
Disabled
```

The initial implementation should keep this small and explicit.

Possible meanings:

- **Active** — normal operation
- **Suspended** — temporarily prevents ordinary tenant activity while preserving data
- **Archived** — retained for historical/read-only purposes
- **Disabled** — administrative shutdown state

Exact semantics need to be defined before these states are implemented.

Changing organization status is security-sensitive and must be auditable.

## Organization Creation

The first deployment needs a deliberate bootstrap path.

Initial creation flows may include:

### Self-Hosted Bootstrap

```text
first application startup
→ bootstrap platform/admin identity
→ create first organization
→ create owner/admin membership through Týr
```

### SaaS Signup (Future)

```text
user signup
→ personal workspace or organization creation
→ owner membership
→ tenant initialization
```

Organization creation should coordinate with Týr through contracts/use-case orchestration without either module reaching into the other's implementation.

Creation should be atomic enough that partially initialized tenants cannot accidentally become usable.

If cross-module initialization cannot share a transaction, failure/recovery behavior must be explicit.

## Tenant Context

Valhalla provides the administrative source of truth for whether a tenant exists and is operational.

A typical protected request should conceptually establish:

```text
Actor authenticated by Týr
        ↓
Membership valid in Tenant X
        ↓
Tenant X exists and is operational in Valhalla
        ↓
Resource authorization proceeds
```

Valhalla should not itself own per-user authorization decisions.

Týr determines whether an actor may operate in the tenant; Valhalla determines administrative tenant state.

## Tenant Configuration

Valhalla is the natural owner for settings that apply across the organization rather than to one business module.

Potential examples include:

- organization locale
- timezone
- business-hours defaults
- date/time display preferences
- security-mode switches that are tenant-level administrative choices
- reauthentication-on-tenant-switch policy if ownership is determined to be administrative rather than identity-specific
- tenant branding/profile settings
- enabled platform capabilities

Avoid turning Valhalla into a generic key/value dumping ground.

Configuration that belongs to a specific domain should stay in that domain.

Examples:

- Mímir workflow settings belong to Mímir
- Gjallarhorn SLA settings belong to Gjallarhorn
- Forseti billing configuration belongs to Forseti

## Business Hours

Business hours are broadly useful across the platform and may reasonably be an organization-level administrative concept.

Potential model:

- timezone
- weekly schedule
- holiday/exception dates
- closed/open overrides

Consumers may include:

- Gjallarhorn for SLA timing
- Verdandi for notification timing
- Saga for scheduling
- Mímir for due-date/business-time calculations where required

Whether Valhalla or Saga ultimately owns the authoritative business calendar should be revisited once Saga is implemented.

For the initial release, do not implement this unless a concrete use case requires it.

## Personal Workspace

Yggdrasil may support a Personal Workspace as a single-principal tenant.

From Valhalla's perspective, a personal workspace should still behave as a tenant boundary even if its administrative UX is simplified.

Potential tenant types:

```text
Organization
Personal
```

A Personal Workspace may:

- have one implicit owner
- hide organization administration features
- not support normal membership invitation initially
- still own Mímir work, time, documents, audit data, workflows, and other tenant-scoped resources

The tenant type should be explicit if behavior differs meaningfully.

Promotion from Personal Workspace to Organization should likely be implemented as a deliberate copy/migration process rather than mutating every assumption in place, but that decision remains open.

## Tenant Isolation

Valhalla is part of the tenant isolation boundary.

Every tenant-scoped operation must operate against the active tenant identifier established by trusted application context.

Do not accept arbitrary tenant IDs from request bodies as sufficient proof of scope.

At minimum:

- tenant existence must be validated
- tenant status must permit the requested operation
- actor membership/authorization must be validated by Týr
- resource ownership must match tenant context

Tenant isolation should be reinforced at multiple layers where practical.

## Database Isolation Strategy

Yggdrasil should not permanently assume one physical isolation model.

The architecture should remain compatible with possible deployment strategies such as:

- shared database with TenantId
- schema-per-tenant
- database-per-tenant
- dedicated deployment per customer

The first implementation may use a shared PostgreSQL database for simplicity.

Application/domain code should not assume that this is the only possible model.

A future abstraction such as:

```text
ITenantDatabaseResolver
```

may become useful, but should not be introduced until a second storage/isolation strategy is actually needed.

## Tenant Features and Capabilities

Valhalla may eventually expose tenant-level feature/capability configuration.

Examples:

- whether a module is enabled
- whether a deployment allows external integrations
- security/compliance tier
- customer-portal availability
- permitted authentication modes

This is distinct from licensing/entitlement, which may involve a separate platform concern.

Avoid making every code path depend on arbitrary flags.

Capabilities should represent meaningful product configuration, not temporary implementation switches.

## Contracts and Events

Valhalla's implementation is private.

Potential public contracts include:

- GetOrganizationSummary
- ResolveTenant
- GetTenantStatus
- GetTenantConfiguration
- CheckTenantCapability

Potential integration events include:

- OrganizationCreated
- OrganizationUpdated
- OrganizationSuspended
- OrganizationReactivated
- OrganizationArchived
- TenantConfigurationChanged

Events describe facts that already occurred.

Example:

```text
OrganizationSuspended
├── Týr may prevent new tenant-scoped sessions/actions
├── Verdandi may notify administrators
├── Urd records audit context
└── other modules may stop tenant-specific processing
```

Immediate access-control decisions should not depend solely on eventually delivered events.

## Audit Requirements

Administrative changes require strong auditability.

Examples include:

- organization creation
- name/profile changes
- status changes
- tenant configuration changes
- business-hours changes
- security-mode configuration
- tenant archival/deactivation

Valhalla emits meaningful administrative events/context; Urd owns the durable audit history.

## Security Requirements

Organization administration is privileged functionality.

At minimum:

- organization management endpoints require explicit permissions
- tenant IDs are immutable
- cross-tenant updates are rejected
- organization status changes are privileged and auditable
- sensitive configuration is not exposed to unauthorized actors
- tenant switching does not implicitly grant access
- disabled/suspended tenants cannot continue normal write operations unless specifically allowed

High-security deployments may require additional controls such as:

- separation of administrative duties
- approval for destructive tenant actions
- stronger reauthentication for high-risk administrative changes
- restricted tenant-export actions

## Data Portability

Customer data portability is a core Yggdrasil principle.

Valhalla should provide the administrative metadata required for a complete tenant export.

A tenant export manifest may include:

- OrganizationId
- tenant type
- organization profile
- configuration version
- export format version
- created timestamp

Example:

```json
{
  "format": "yggdrasil-export",
  "version": 1,
  "tenant_id": "...",
  "tenant_type": "organization",
  "created_at": "..."
}
```

Valhalla coordinates tenant-level metadata; individual modules remain responsible for exporting their own domain data through the common export process.

## Tenant Deletion and Retention

Hard deletion of a tenant is high risk and should not be part of the initial implementation.

Prefer lifecycle concepts such as disable/archive while retention, export, audit, and legal requirements are still being designed.

Before permanent deletion is introduced, define:

- authorization requirements
- export requirements
- retention rules
- audit retention
- backup/recovery interaction
- attachment/object-storage cleanup
- delayed deletion/grace period
- confirmation/approval requirements

## Initial MVP

The first Valhalla slice should be small.

### Required

- create first organization during bootstrap
- create additional organization through an authorized administrative use case
- get organization summary
- list organizations available through the appropriate actor context
- basic organization profile/name
- organization active/inactive status foundation
- tenant-resolution contract for other modules
- audit important administrative changes

### Not Required Initially

- business hours
- holiday calendars
- organization branding
- module feature toggles
- tenant deletion
- dedicated database assignment UI
- compliance tiers
- complex tenant templates
- SaaS subscription/entitlement management
- full Personal Workspace promotion flow

These can be added when real requirements justify them.

## Initial Use Cases

Likely first UseCases include:

```text
Organizations/
├── Create/
├── Get/
├── List/
├── UpdateProfile/
└── ChangeStatus/

Tenancy/
├── ResolveTenant/
└── GetTenantConfiguration/
```

Tenant membership use cases remain in Týr.

## Initial Aggregate Candidates

### Organization Aggregate

Likely responsible for:

- tenant identity
- organization lifecycle/status
- core profile
- tenant-wide administrative invariants

### TenantConfiguration

May initially be part of Organization if configuration remains small.

If configuration becomes large, independently versioned, or operationally separate, it may deserve its own aggregate later.

Do not split it prematurely.

## Testing Priorities

Important tests include:

- tenant identity cannot change
- organization creation requires valid administrative flow
- duplicate/conflicting identifiers are rejected
- unauthorized actors cannot modify organization data
- Tenant A cannot modify Tenant B
- suspended/disabled tenant behavior matches defined policy
- tenant resolution returns correct administrative status
- export metadata belongs to the correct tenant

Integration tests should validate tenant persistence and any database-level isolation safeguards introduced later.

## Open Design Questions

Resolve incrementally:

1. Is `OrganizationId` exactly the same type/concept as `TenantId`, or do we need a distinction?
2. What organization lifecycle states are actually necessary?
3. Which tenant-level settings belong in Valhalla versus specific modules?
4. Should business hours ultimately belong to Valhalla or Saga?
5. How should initial organization bootstrap coordinate atomically with Týr membership creation?
6. What tenant status should block reads versus writes?
7. How is Personal Workspace represented in the tenant model?
8. Should Personal Workspace promotion copy data into a new organization or mutate tenant type?
9. When should alternate database-isolation modes be implemented?
10. What administrative actions require reauthentication or approval?
11. Where should product licensing/entitlement responsibilities live relative to Valhalla?
12. What tenant deletion/retention model is appropriate for self-hosted and SaaS deployments?

## Success Criteria

The initial Valhalla milestone is successful when:

- Yggdrasil can bootstrap an organization cleanly
- a user can belong to and select among multiple valid organizations through Týr
- every initial business operation resolves a stable active tenant
- organization administrative changes are authorized and auditable
- business modules do not need to know how tenant administration is persisted
- the design does not prevent future shared-schema, database-per-tenant, or dedicated-deployment strategies

## Related Documentation

- `docs/architecture/overview.md`
- `docs/architecture/dependency-rules.md`
- `docs/development/WORKFLOW.md`
- `docs/development/TESTING.md`
- `docs/modules/MODULES.md`
- `docs/modules/TYR.md`
- `docs/modules/MIMIR.md`
