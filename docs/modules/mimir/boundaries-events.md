# Mímir Module Boundaries & Events

> Status: approved working specification. This document defines Mímir's ownership boundaries, public contracts, events, and cross-module interaction rules.

## Purpose

Mímir owns work-management behavior inside Yggdrasil while keeping its implementation private.

Other modules may interact with Mímir through:

- explicit public contracts
- stable identifiers
- supported commands/APIs
- published integration events

Other modules must not depend directly on Mímir's private models, services, or persistence details.

> **Mímir owns work. Other modules may reference or react to work without taking ownership of its lifecycle.**

## Mímir Owns

Mímir owns the authoritative lifecycle and state for:

- Tasks
- Projects and sub-projects
- Notes associated with work
- Time Entries
- Project Activities
- Task -> Project promotion
- Task assignment
- Task priority/status
- Project status/health
- work hierarchy
- source work-time records

Future Mímir-owned concepts may include:

- Programs
- Portfolios
- Milestones
- work templates

## Ticket Ownership Is Deferred

Ticket ownership is intentionally **not locked to Mímir**.

Mímir may:

- reference Tickets
- display Ticket links
- create Tasks from Tickets
- link multiple Tasks to one Ticket
- consume or publish stable Ticket-related contracts where appropriate

However, Ticket lifecycle ownership may:

- remain in Mímir initially, or
- move to a dedicated module/service later if the domain becomes large enough

Therefore:

- Mímir must not depend on Ticket implementation internals
- Ticket relationships should use stable identifiers/contracts
- Task and Ticket identities/lifecycles remain distinct
- the architecture must preserve the ability to move Ticket ownership without rewriting Task/Project internals

This reversibility is intentional.

## Other Module Ownership

### Týr

Týr owns:

- user identity
- authentication
- organization membership
- roles/permissions
- service accounts

Mímir stores only stable actor/user identifiers required for work ownership and history.

### Valhalla

Valhalla owns:

- organizations
- tenant administration
- tenant lifecycle/settings

Mímir references tenant identity through stable contracts.

### Urd

Urd owns:

- durable audit persistence
- compliance-oriented audit history
- retention/signing/query behavior

Mímir determines which actions are auditable and emits the required context.

### Loki

Loki eventually owns broader automation and cross-module workflows.

It may invoke supported Mímir operations but cannot bypass Mímir invariants.

### Forseti

Forseti may consume approved Time Entry contracts for billing/invoicing.

Mímir remains authoritative for source Time Entries.

### Skald

Skald may consume reporting contracts/events but does not own operational Mímir state.

## Actor References

Mímir stores stable actor identifiers such as:

- `CreatedBy`
- `UpdatedBy`
- `AssigneeId`
- `OwnerId`
- `UserId`

Display information should be obtained through Týr public contracts/queries rather than direct persistence coupling.

## Tenant Context

Every tenant-owned Mímir resource must have unambiguous tenant context.

UUID knowledge alone never grants access.

Every resource operation must validate:

- tenant
- actor
- permission
- resource access

## Internal vs Public Types

Internal domain types remain private.

Examples:

- `Task`
- `Project`
- `TimeEntry`
- `Note`
- `ProjectActivity`

Public contracts should be purpose-specific representations, not exposed internal entities.

Examples:

- `TaskReference`
- `ProjectReference`
- `TimeEntryRecordedEvent`
- `TaskStatusChangedEvent`

## Commands vs Events

### Commands

A command requests that Mímir perform an action.

Examples:

- CreateTask
- AssignTask
- CompleteTask
- PromoteTaskToProject
- RecordTimeEntry

Commands may fail due to authorization, validation, missing resources, or domain invariants.

### Events

An event states that something already happened.

Examples:

- TaskCreated
- TaskStatusChanged
- ProjectCreated
- TimeEntryRecorded

Events are not requests to mutate originating state.

## Domain Events vs Integration Events

### Domain Events

Internal to Mímir and free to reflect domain implementation semantics.

Examples:

- TaskCompleted
- TaskReopened
- TaskPromotedToProject
- ProjectCompleted
- TimeEntryStarted

### Integration Events

Cross-module contracts that must be:

- intentional
- stable
- versioned
- minimal
- language-neutral where appropriate

Example event name:

`mimir.task.status-changed.v1`

## Initial Integration Event Set

Start small.

### TaskCreated

Potential fields:

- EventId
- OccurredAt
- TenantId
- TaskId
- TaskKey
- ActorId
- ProjectId?

### TaskStatusChanged

Potential fields:

- EventId
- TenantId
- TaskId
- PreviousStatus
- NewStatus
- ActorId
- OccurredAt

### TaskAssigned

Potential fields:

- EventId
- TenantId
- TaskId
- PreviousAssigneeId?
- AssigneeId?
- ActorId
- OccurredAt

### TaskPromotedToProject

Potential fields:

- EventId
- TenantId
- TaskId
- TaskKey
- ProjectId
- ProjectKey
- ActorId
- OccurredAt

### ProjectCreated

Potential fields:

- EventId
- TenantId
- ProjectId
- ProjectKey
- ActorId
- OriginTaskId?
- OccurredAt

### ProjectStatusChanged

Potential fields:

- EventId
- TenantId
- ProjectId
- PreviousStatus
- NewStatus
- ActorId
- OccurredAt

### TimeEntryRecorded

Potential fields:

- EventId
- TenantId
- TimeEntryId
- TaskId
- UserId
- DurationSeconds
- Source
- OccurredAt

Add semantic events such as TaskCompleted or ProjectCompleted only when a real downstream consumer benefits from them.

## Notes Events

Routine Note content editing should remain internal.

Potential cross-module events should be limited to structural actions such as:

- NoteShared
- NoteAttachedToWork
- NotePromotedToTask

## Urd Audit Integration

Significant Mímir actions must emit auditable context including:

- tenant
- actor
- action
- resource identity
- resource type
- timestamp
- meaningful before/after context where needed

Urd owns durable audit storage and compliance behavior.

## Notification Integration

Mímir does not own notification delivery.

Mímir may publish events such as:

- TaskAssigned
- TaskDueSoon
- ProjectAtRisk

A notification module decides channels, delivery, batching, retries, and user preferences.

## Authorization

Mímir decides which permissions are required for each domain operation while Týr provides identity/permission capability.

Conceptual permissions may include:

- Task.Create
- Task.Read
- Task.Edit
- Task.Assign
- Task.Complete
- Task.Cancel
- Task.Promote
- Project.Create
- Project.Edit
- Project.Complete
- Time.RecordOwn
- Time.EditOwn
- Time.EditOthers
- Note.Share

Exact names may evolve.

## Cross-Module Relationships

Mímir may reference external resources by stable identifiers.

Examples:

- Task -> CustomerId
- Task -> AssetId
- Task -> TicketId

Use validated public queries/contracts/events where consistency is needed.

Do not introduce direct implementation coupling across module persistence boundaries.

## Event Versioning

All public integration events are versioned.

Examples:

- `mimir.task.created.v1`
- `mimir.task.status-changed.v1`
- `mimir.project.created.v1`

Rules:

- incompatible schema changes require a new version
- existing fields are not silently repurposed
- consumers should tolerate additive unknown fields where serialization permits

## Event Identity

Each integration event should contain:

- `EventId` (UUIDv7)
- `EventType`
- `EventVersion`
- `OccurredAt`
- `TenantId`
- `ActorId?`

This supports replay, deduplication, diagnostics, and audit correlation.

## Delivery Semantics

Consumers must assume duplicate delivery is possible.

> **Integration event consumers should be idempotent.**

Mímir should not require exactly-once transport guarantees.

Reliable publishing should eventually use an outbox-style mechanism or equivalent.

## Ordering

Do not assume global event ordering.

Where ordering matters, use resource identity plus timestamps and, if later required, resource version/sequence metadata.

## Public APIs

Mímir APIs should expose use cases rather than persistence tables.

Preferred style:

- `POST /tasks`
- `POST /tasks/{id}/complete`
- `POST /tasks/{id}/promote`
- `POST /tasks/{id}/time`

Avoid unrestricted persistence-style updates that bypass domain rules.

## Protocol Buffers

Protocol Buffers are appropriate for long-lived language-neutral boundaries where justified, especially plugins, agents, extensions, external integrations, and stable event schemas.

Internal in-process C# interfaces do not require Protobuf by default.

## Failure Boundaries

Downstream integration failure must not invalidate committed Mímir work.

Example:

```text
Task completed successfully
↓
notification delivery fails
```

The Task remains completed; notification handling retries independently.

## Business Invariants

1. Mímir owns Task/Project/Note/Time lifecycle state.
2. Mímir implementation details remain private.
3. Cross-module access uses public contracts/events.
4. External identities are stable identifiers, not foreign internal entities.
5. UUID knowledge never bypasses tenant authorization.
6. Commands request change; events describe completed change.
7. Domain Events and Integration Events are separate concepts.
8. Public integration events are versioned.
9. Consumers tolerate duplicate delivery.
10. Downstream integration failure does not invalidate committed Mímir state.
11. Urd owns durable compliance audit storage.
12. Týr owns identity and authorization primitives.
13. Forseti may consume Time Entries but does not own source work time.
14. Loki may automate Mímir only through supported operations.
15. Ticket ownership remains intentionally deferred and reversible.

## Design Principle

> **Internal models may evolve quickly. Public contracts should evolve deliberately.**
