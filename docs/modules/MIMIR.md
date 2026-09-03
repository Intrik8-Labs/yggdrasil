# Mímir — Work Management

## Purpose

Mímir is the Yggdrasil module responsible for work management.

It owns the concepts required to create, organize, assign, track, relate, and complete work across the platform. Mímir should be useful for ordinary task and project management while also supporting service-management concepts such as tickets, incidents, requests, and problems.

The initial objective is intentionally smaller: Mímir must become useful enough to manage Yggdrasil's own development work.

## Responsibilities

Mímir owns:

- work items
- tasks
- tickets
- incidents
- requests
- problems
- stories
- epics
- projects
- assignment
- priority
- work-item relationships
- work-item lifecycle/status
- comments and work-related discussion metadata
- time entries and basic time tracking

Mímir does not own:

- users, authentication, memberships, or permissions — Týr
- organizations or tenant administration — Valhalla
- SLA policy and escalation — Gjallarhorn
- asset lifecycle — Freyja
- audit history — Urd
- contracts, rates, invoicing, or payments — Forseti
- notifications — Verdandi
- cross-module automation — Loki
- knowledge/document management — Odin
- reporting/analytics — Skald

Mímir may reference external concepts only through stable identifiers and public contracts. It must not reference another module's Core, UseCases, or Infrastructure assemblies.

## Product Principles

Mímir should combine:

- fast, low-friction everyday interaction
- opinionated defaults that work without configuration
- configurable workflows and fields when organizations need them
- service-management concepts without forcing every user into ITSM terminology
- enough hierarchy for real projects without turning ordinary tasks into configuration exercises

A task should be creatable with little more than a title.

Configuration should increase capability, not become a prerequisite for basic work.

## Core Concepts

### WorkItem

`WorkItem` is the central concept representing a unit of trackable work.

Initial work-item kinds may include:

- Task
- Ticket
- Incident
- Request
- Problem
- Story
- Epic

These kinds may share common behavior, but the implementation should not prematurely force them into a rigid inheritance hierarchy. Prefer explicit type/kind behavior and domain rules that can evolve as the model becomes better understood.

Common concepts are expected to include:

- WorkItemId
- TenantId
- Kind
- Title
- Description
- Status
- Priority
- Assignee
- Reporter/Creator
- ProjectId where applicable
- CreatedAt
- UpdatedAt
- DueAt where applicable
- relationships to other work items

The exact entity shape should be driven by behavior rather than by database design.

### Project

A Project represents a coordinated body of work.

Projects are separate from WorkItems rather than merely another WorkItem type.

A project may contain:

- work items
- milestones
- iterations/sprints
- project-level metadata
- eventually budgets, resources, and reporting references

The initial implementation should keep Project deliberately small.

### WorkItemRelationship

Mímir should support relationships between work items without requiring one universal parent/child hierarchy.

Examples may include:

- Epic → Story
- Epic → Task
- Story → Task
- Incident → Task
- Ticket → Task
- Problem → Incident

Relationship types should be explicit and validated by domain rules.

The model should eventually support relationships such as:

- parent/child
- blocks/blocked-by
- duplicates/duplicated-by
- relates-to
- caused-by

Only relationships required by real use cases should be implemented initially.

### Assignment

Work items may be assigned to a user or, later, an appropriate team/group concept.

Mímir owns the assignment state but does not own user identity. Assignee identifiers refer to identities exposed through Týr contracts.

Authorization to assign work is determined outside the Mímir domain implementation through the appropriate application/security boundary.

### Comments

Work items need discussion and contextual updates.

Initial comments should support:

- author identity
- timestamp
- body
- edit metadata if editing is supported
- visibility classification when customer-facing functionality is introduced

Customer-visible comments and internal notes must eventually be distinguishable for Bifröst/customer-portal scenarios.

## Work Item Lifecycle

Mímir owns the normal lifecycle of its work items.

A useful default lifecycle is:

```text
New
↓
Triaged
↓
In Progress
↓
Pending / On Hold
↓
Resolved
↓
Closed
```

Additional terminal states may include:

- Cancelled
- Rejected

The initial task workflow can be substantially simpler, for example:

```text
Backlog
Ready
In Progress
Blocked
Review
Done
```

Lifecycle configuration should eventually support organization-specific workflows, but ordinary status transitions must not depend on the Loki automation module.

Mímir owns work-item state transitions. Loki may react to those transitions or orchestrate cross-module automation around them.

## Time Tracking

Time tracking initially belongs to Mímir because time is recorded against work managed by Mímir.

### TimeEntry

Expected concepts include:

- TimeEntryId
- TenantId
- UserId
- WorkItemId
- StartedAt
- EndedAt or Duration
- Description
- Billable flag
- Source

Initial capabilities should include:

- manual time entry
- editing a time entry
- basic duration validation
- associating time with a work item

Later capabilities may include:

- start/stop timers
- timesheet views
- approvals
- utilization reporting
- billing integration

Mímir owns the source time record. Forseti may later consume time through contracts/events to calculate billable amounts. Skald may consume time data for analytics.

Whether TimeEntry becomes a fully independent aggregate should be decided based on the concurrency, lifecycle, and approval rules that emerge during implementation. Do not force it into the WorkItem aggregate solely because it references a work item.

## Events and Contracts

Mímir implementation assemblies are private.

Other modules interact with Mímir through public contracts and events.

Potential integration events include:

- WorkItemCreated
- WorkItemAssigned
- WorkItemStatusChanged
- WorkItemResolved
- WorkItemClosed
- ProjectCreated
- TimeEntryRecorded

Events should describe facts that have already occurred.

They should contain stable identifiers and only the information consumers reasonably require. Other modules should not depend on Mímir persistence models.

Example uses:

```text
WorkItemCreated
├── Urd records audit context
├── Gjallarhorn evaluates SLA applicability
├── Verdandi may notify interested users
└── Loki may trigger configured automation
```

Not every internal domain event needs to become a public integration event.

## Tenancy

Every tenant-owned Mímir aggregate must belong to exactly one tenant/organization context.

Tenant isolation is mandatory.

A request operating in Tenant A must not be capable of reading or modifying Tenant B's work through identifier manipulation or missing filters.

Tenant ownership should be explicit in the domain/data model and reinforced by authorization and persistence-level safeguards.

## Audit Requirements

Important changes should produce sufficient information for Urd to maintain an audit history.

Examples include:

- work-item creation
- assignment changes
- priority changes
- status transitions
- project association changes
- time-entry creation/editing/deletion
- privileged overrides

Mímir should expose meaningful events/context; Urd owns the durable audit record.

## Initial MVP

The first Mímir slice should remain deliberately small.

### Required

- create a task
- view a task
- list tasks
- edit basic task information
- assign a task
- change task status
- set priority
- associate a task with a project
- create/view a basic project
- record a manual time entry against a task
- emit/audit important changes

### Not Required Initially

- advanced sprint planning
- configurable custom fields
- arbitrary workflow designers
- customer portal comments
- SLA enforcement
- billing
- resource planning
- advanced reporting
- full ITIL semantics
- complex dependency graphs
- collaborative editing

These remain valid future capabilities but should not block dogfooding.

## Initial Use Cases

The first UseCases may include:

```text
Tasks/
├── Create/
├── Get/
├── List/
├── Update/
├── Assign/
└── ChangeStatus/

Projects/
├── Create/
├── Get/
└── List/

Time/
├── AddTimeEntry/
├── UpdateTimeEntry/
└── GetTimeEntries/
```

Use cases should remain explicit and small. Avoid generic CRUD service abstractions that hide business intent.

## Initial Aggregate Candidates

The likely starting aggregate boundaries are:

### WorkItem Aggregate

Responsible for:

- core work-item invariants
- status transitions
- assignment state
- priority
- basic relationships controlled by the work item

### Project Aggregate

Responsible for:

- project identity and lifecycle
- project-level invariants
- project metadata

### TimeEntry

Treat TimeEntry as a likely independent aggregate/entity whose final boundary will be validated during implementation.

The aggregate model is not considered permanently fixed by this document. Aggregate boundaries should change when actual transactional and concurrency requirements demonstrate a better model.

## Security Considerations

Mímir must assume all external identifiers are untrusted.

Authorization should consider at least:

- active tenant membership
- permission to view the work item/project
- permission to modify the requested field or state
- assignment permissions
- privileged workflow overrides
- future field-level permissions

Authorization checks must not rely solely on UI behavior.

## Data Portability

Mímir data must eventually be available through supported export/import mechanisms.

Expected portable entities include:

- projects
- work items
- relationships
- comments
- time entries

Exports should use stable versioned formats rather than exposing the internal database schema as the product contract.

## Open Design Questions

The following should be resolved incrementally rather than prematurely:

1. Should WorkItem kinds use a single aggregate model, composition, or specialized domain types?
2. What is the minimum useful project lifecycle?
3. Which relationship types are needed for the first dogfood release?
4. Is TimeEntry an independent aggregate from its first implementation?
5. How should work-item numbering/display IDs work within a tenant?
6. When should custom fields enter the product?
7. How should configurable workflows be represented and versioned?
8. When are comments editable, and how should edit history be preserved?
9. Which status transitions require explicit permissions or override auditing?

## Success Criteria

The first Mímir milestone is successful when Intrik8 Yggdrasil's own development can be managed comfortably inside Mímir for several consecutive weekly iterations.

That means Mímir should become preferable to maintaining the project's active task list manually elsewhere, while remaining understandable and fast enough that dogfooding exposes product weaknesses rather than being avoided because of them.

## Related Documentation

- `docs/architecture/overview.md`
- `docs/architecture/dependency-rules.md`
- `docs/development/WORKFLOW.md`
- `docs/development/TESTING.md`
- `docs/modules/MODULES.md`
