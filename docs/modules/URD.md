# Urd — Audit Trail and Compliance Logging

## Purpose

Urd is the Yggdrasil module responsible for durable audit history, compliance-oriented event recording, and trustworthy reconstruction of important platform actions.

Urd answers questions such as:

- who performed an action?
- against which tenant and resource?
- what changed?
- when did it happen?
- which system or service performed it?
- was the action privileged or automatic?

The initial objective is not to build a full compliance platform. It is to ensure that security-sensitive and business-significant changes made by Týr, Valhalla, Mímir, and later modules are recorded consistently from the beginning.

## Responsibilities

Urd owns:

- durable audit records
- append-oriented audit persistence
- normalized actor/tenant/resource context
- audit event metadata
- audit query/read models
- integrity mechanisms introduced later
- retention policy execution where it applies specifically to audit data
- export of audit history
- eventual SIEM/event streaming integration for audit data

Urd does not own:

- business actions being audited
- domain state for other modules
- authentication/authorization policy — Týr
- organization lifecycle — Valhalla
- work-item history as business state — Mímir
- general application logging
- metrics/traces
- notification delivery

Business modules are responsible for emitting meaningful audit-worthy facts/context. Urd owns the durable audit record.

## Audit vs Logging

Audit data is not the same as ordinary application logging.

Application logs answer operational questions such as:

```text
Why did this request fail?
What exception occurred?
How long did this operation take?
```

Audit records answer accountability questions such as:

```text
Who changed this user's role?
Who closed this ticket?
Which agent executed this privileged command?
What did the previous value contain?
```

Audit records should therefore be:

- structured
- intentional
- queryable
- durable
- tenant-aware
- actor-aware
- stable enough for long-term retention

Do not treat raw application logs as the audit system.

## Core Concepts

### AuditRecord

An AuditRecord represents one significant auditable fact.

Expected concepts include:

- AuditRecordId
- TenantId where applicable
- ActorId
- ActorType
- Action
- ResourceType
- ResourceId
- Timestamp
- SourceModule
- CorrelationId / RequestId where available
- Result/Outcome where appropriate
- change metadata
- privileged/system-generated indicators
- optional reason/context

Audit records should favor structured fields over unstructured prose.

### Actor

The actor identifies who or what performed the action.

Potential actor types include:

- User
- ServiceIdentity
- Agent
- System
- Plugin
- Automation

Actor identity should be stable and traceable through public identifiers/contracts without requiring Urd to reference another module's internal entities.

### Action

Actions should use stable names that describe meaningful behavior.

Examples:

```text
tyr.membership.revoked
valhalla.organization.suspended
mimir.work-item.assigned
mimir.work-item.status-changed
mimir.time-entry.updated
smidr.command.executed
```

Avoid logging low-value implementation details as audit actions.

### Resource

Each record should identify the affected resource where applicable.

Examples:

- UserId
- MembershipId
- OrganizationId
- WorkItemId
- TimeEntryId
- AgentId
- ContractId

ResourceType and ResourceId should be explicit and stable.

## Change Data

Where practical, Urd should record enough information to understand what changed.

Potential forms include:

```json
{
  "field": "status",
  "before": "InProgress",
  "after": "Resolved"
}
```

For more complex actions, a structured change set may be used.

Sensitive information must not be copied into audit data merely because it changed.

Examples of values that should generally not appear in audit payloads:

- passwords
- password hashes
- API secrets
- private keys
- session tokens
- authentication codes
- sensitive document contents unless explicitly required

Where a sensitive field changes, record the fact that it changed rather than the secret value.

## Append-Oriented Model

Audit history should be append-oriented.

Normal application behavior should not edit or delete prior audit records.

Corrections should generally create a new audit record explaining the correction rather than rewriting history.

The first implementation may use ordinary PostgreSQL persistence while enforcing append-only behavior in the application and database permissions where practical.

Longer-term integrity mechanisms may include:

- cryptographic chaining/hashing
- signed audit batches
- immutable storage targets
- WORM-compatible exports
- independent verification tooling

These should be introduced when actual compliance/security requirements justify them.

## Event Ingestion

Modules should not write directly into Urd's tables.

Preferred flow:

```text
Business action succeeds
        ↓
Module publishes audit/integration fact
        ↓
Urd records normalized AuditRecord
```

For operations requiring strong audit guarantees, the system must eventually address the failure mode where business state commits but audit recording fails.

Potential mechanisms include:

- transactional outbox
- same-database transactional staging
- durable message processing

Do not add a distributed broker solely for this initial need. The transactional consistency strategy should be documented once persistence/event infrastructure is implemented.

## Synchronous vs Asynchronous Audit

Most audit persistence may be asynchronous if delivery is durable and reliable.

Some security-critical operations may require stronger guarantees before reporting success.

Examples might include:

- privileged role/permission changes
- tenant deletion/destructive administrative action
- privileged remote agent commands

The exact guarantee should be defined per risk rather than assuming all events need identical delivery semantics.

## Tenancy

Audit records must preserve tenant boundaries.

Tenant-scoped audit queries must never expose another tenant's history.

Platform-level audit records may exist outside one tenant for operations such as deployment administration or platform bootstrap.

Those records must be explicitly distinguished rather than represented with ambiguous/null tenant context.

## Correlation

Audit records should support correlation with surrounding activity.

Useful identifiers include:

- CorrelationId
- RequestId
- TraceId where appropriate
- CommandId
- JobId

This allows operators to connect:

```text
API request
→ business action
→ integration event
→ agent command
→ audit records
```

Correlation identifiers are diagnostic/contextual data; they should not replace stable resource identifiers.

## Audit Event Contract

A common audit envelope may eventually resemble:

```text
AuditEvent
├── EventId
├── OccurredAt
├── TenantId
├── Actor
├── Action
├── Resource
├── SourceModule
├── CorrelationId
├── Changes
├── Metadata
└── SecurityClassification
```

The exact contract should remain small enough that modules can emit it consistently.

Avoid a generic metadata bag becoming the only meaningful structure.

## Important Initial Audit Events

### Týr

- user bootstrap/creation
- login failures where retention policy permits
- account disable/enable
- membership creation
- membership revocation
- role assignment/removal
- credential revocation
- privileged authorization changes

### Valhalla

- organization creation
- organization profile changes
- organization status changes
- tenant configuration changes

### Mímir

- work-item creation
- assignment changes
- status transitions
- priority changes
- project changes
- time-entry creation/update/removal
- privileged workflow overrides

## Read Access

Audit history is sensitive.

Read access should require explicit permission, potentially with multiple scopes such as:

```text
urd.audit.read
urd.audit.export
urd.audit.read-security
```

High-security deployments may separate ordinary operational audit access from security-administration audit access.

Audit visibility should never be implied simply because a user can view the underlying business resource.

## Retention

Audit retention should eventually be configurable per organization/deployment subject to platform minimums and legal/compliance requirements.

Potential concepts include:

- retention duration
- protected minimum retention
- archival target
- export-before-purge policy
- legal/compliance hold

Deletion/expiration of audit records must itself be controlled and auditable.

Initial implementation can use a conservative no-automatic-deletion policy until requirements are clearer.

## Data Export

Audit history is part of customer data portability, but exports require careful authorization because audit data may expose sensitive operational/security context.

An export should preserve:

- stable record IDs
- timestamps
- actors
- actions
- resources
- structured changes
- integrity metadata when introduced

Potential format:

```text
audit/
└── records.jsonl
```

JSONL is attractive for large append-oriented datasets and streaming imports/exports.

## Integrity and Tamper Evidence

Urd should eventually support evidence that audit history has not been silently modified.

Possible design:

```text
Record N hash includes Record N-1 hash
```

or periodically signed batches/checkpoints.

Important distinction:

- **append-only application behavior** reduces accidental modification
- **tamper evidence** helps detect unauthorized modification
- **immutable storage** can make modification materially harder

These are different controls and should not be conflated.

Cryptographic signing is a long-term requirement already anticipated for higher-security deployments, but it does not need to block the initial MVP.

## Security Considerations

Urd is a security-sensitive module.

At minimum:

- audit records cannot contain authentication secrets
- audit APIs enforce tenant isolation
- audit write paths validate/normalize actor and tenant context
- ordinary users cannot mutate audit records
- timestamps use a consistent authoritative clock abstraction
- security-relevant failures are not silently discarded
- export operations are privileged and audited
- retention/purge operations are privileged and audited

Do not trust caller-provided actor identity when trusted request/system context can provide it.

For example, an API request body should not be allowed to claim another UserId as the auditing actor.

## Privacy Considerations

Audit history can become a large store of personal/activity data.

Record only what is required for accountability, security, compliance, and useful reconstruction.

Avoid recording complete request bodies by default.

Retention design should account for privacy requirements while preserving legitimate security/compliance history.

## Initial MVP

The first Urd slice should be deliberately small.

### Required

- append audit records
- capture TenantId
- capture ActorId/ActorType
- capture action
- capture resource type/id
- timestamp records
- source module
- correlation ID when available
- structured basic change metadata
- query audit records for an authorized tenant/admin
- receive audit-worthy facts from Týr, Valhalla, and Mímir

### Not Required Initially

- cryptographic signatures
- hash chaining
- external SIEM streaming
- WORM storage
- complex retention policies
- compliance-report generation
- legal holds
- cross-region archive storage
- user-facing audit analytics

These can be added when real deployment/compliance requirements justify them.

## Initial Use Cases

Likely first UseCases include:

```text
Audit/
├── Record/
├── GetById/
├── List/
└── Export/
```

`Export` may be deferred until after the first dogfood slice if necessary.

The normal application should not expose arbitrary record mutation use cases.

## Initial Aggregate / Model Candidates

Urd may not require a rich aggregate model in the same way Mímir does.

The central model may simply be an immutable/append-only `AuditRecord` with value objects for:

- Actor
- ResourceReference
- AuditAction
- ChangeSet

Do not manufacture domain complexity merely to conform to an aggregate pattern.

Clean Architecture does not require every module to have equally complex domain behavior.

## Testing Priorities

Important tests include:

- records preserve tenant identity
- actor context cannot be spoofed through normal request input
- audit records cannot be updated through application use cases
- unauthorized tenant cannot query another tenant's audit records
- sensitive fields are redacted/not captured
- important Týr/Valhalla/Mímir actions result in expected audit facts
- correlation identifiers are preserved
- serialization/export round-trips when export is introduced

Future integrity tests should verify hash/signature chains and tamper detection.

## Observability Relationship

Urd should integrate with but remain distinct from OpenTelemetry/application logging.

Where useful, audit records may store TraceId/CorrelationId so operators can connect an audited action to operational traces.

Do not send all audit payload contents automatically to telemetry vendors because deployments may have privacy, compliance, or air-gap restrictions.

## Air-Gapped Deployments

Urd must work fully offline.

No audit functionality should depend on an external SaaS logging/SIEM provider.

External streaming integrations can be optional consumers.

Self-hosted/air-gapped users should retain complete local access to their audit history and exports.

## Open Design Questions

Resolve incrementally:

1. Which initial audit events require synchronous/durable-before-success guarantees?
2. What transactional outbox design should be used once EF Core persistence is established?
3. Should Urd share the primary database initially or have a separate schema/database?
4. What audit action naming/versioning convention should be standardized?
5. How much before/after change data is appropriate by default?
6. How should sensitive-field redaction/classification be declared?
7. What is the minimum initial retention policy?
8. When should cryptographic hash chaining/signatures be introduced?
9. Which records are platform-level rather than tenant-level?
10. How should audit records reference deleted/archived actors and resources?
11. Should audit event contracts be internal C# contracts first or standardized external schemas from the start?
12. Which authentication events are useful enough to retain without creating excessive privacy/noise concerns?

## Success Criteria

The initial Urd milestone is successful when:

- important actions in Týr, Valhalla, and Mímir produce durable structured audit records
- every record reliably identifies tenant, actor, action, resource, and time
- authorized administrators can review relevant history
- cross-tenant audit access is prevented
- business modules do not write directly to Urd persistence
- secrets do not leak into audit records
- the architecture leaves room for stronger tamper-evidence and compliance features later

## Related Documentation

- `docs/architecture/overview.md`
- `docs/architecture/dependency-rules.md`
- `docs/development/WORKFLOW.md`
- `docs/development/TESTING.md`
- `docs/modules/TYR.md`
- `docs/modules/VALHALLA.md`
- `docs/modules/MIMIR.md`
