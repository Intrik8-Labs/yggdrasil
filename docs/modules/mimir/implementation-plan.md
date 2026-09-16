# Mímir MVP Implementation Plan

> Status: working implementation checklist derived from the approved Mímir MVP specifications. This document is intended to guide implementation order, GitHub issues, review, and AI-assisted development without allowing scope drift.

## Purpose

The Mímir MVP should be implemented in small, reviewable slices.

The implementation order should preserve these principles:

- domain rules before transport/UI
- stable identity before persistence convenience
- explicit use cases before generic CRUD
- tests around behavior before broad feature expansion
- module boundaries before cross-module integrations
- dogfood core work management before advanced configuration

The initial goal is not to implement all of Mímir. It is to reach a useful **Tasks + Projects + Notes + Time** vertical slice that Yggdrasil can use to manage its own development.

## Source Specifications

Implementation work must remain aligned with:

- [Tasks](tasks.md)
- [Projects](projects.md)
- [Notes](notes.md)
- [Time Entries](time-entries.md)
- [Module Boundaries & Events](boundaries-events.md)
- [Dependency Rules](../../architecture/dependency-rules.md)
- [Development Workflow](../../development/WORKFLOW.md)

When implementation behavior conflicts with these documents, update the specification intentionally rather than silently diverging.

---

# Phase 0 — Module Foundation

## MIMIR-001 — Establish the Mímir namespace boundary

**Outcome:** Mímir has a clear Rails namespace and ownership boundary.

Check:

- `Mimir` namespacing for owned models and services
- routes and controllers that delegate business behavior
- tenant scoping for all owned records
- a deliberate public interface for cross-module queries
- boundary-check coverage for forbidden private references

**Acceptance criteria**

- Mímir does not reach into another module's private constants or persistence details
- other modules do not query Mímir tables directly
- public interfaces return stable values or identifiers rather than internal models
- controllers and views contain no business rules
- tenant-owned queries cannot escape the active tenant

---

## MIMIR-002 — Establish UUIDv7 identity primitives

**Outcome:** Mímir entities use UUIDv7 canonical identity.

Implement/confirm:

- UUIDv7 generation approach
- strongly typed IDs if consistent with project conventions
- no database auto-increment key as canonical identity
- tests proving identity immutability

**Applies to**

- Task
- Project
- Note
- TimeEntry
- integration EventId

---

## MIMIR-003 — Establish human-readable key generation

**Outcome:** Tasks and Projects receive immutable human-facing keys.

Initial defaults:

- Task: `TASK-<number>`
- Project: `PRJ-<number>`

Requirements:

- tenant-scoped sequence
- prefix captured/stable for existing keys
- future tenant prefix customization remains possible
- sequence is never canonical entity identity
- keys are searchable

**Tests**

- unique sequence per tenant
- different tenants may reuse sequence values safely
- key does not change after creation
- future prefix changes do not rewrite existing keys

---

# Phase 1 — Task Domain Foundation

## MIMIR-010 — Add Task status and priority types

**Status values**

- ToDo
- InProgress
- Done
- Cancelled

**Priority values**

- Low
- Normal
- High
- Urgent

**Acceptance criteria**

- constrained types
- Normal is default priority
- ToDo is default status
- no Blocked lifecycle status

---

## MIMIR-011 — Implement Task aggregate/entity

Implement the Task model from `tasks.md`.

Minimum fields:

- Id
- Number/key data
- Title
- Description
- Status
- Priority
- AssigneeId
- DueDate
- ParentTaskId
- ProjectId
- CompletedAt
- CreatedAt/CreatedBy
- UpdatedAt/UpdatedBy

**Acceptance criteria**

- only Title is required from the user for quick creation
- Created metadata is immutable
- Updated metadata changes on meaningful modification
- invalid state cannot be created through public domain methods

---

## MIMIR-012 — Implement Task lifecycle behavior

Implement explicit domain operations for:

- start work
- complete
- reopen/reset
- cancel
- restore

**Acceptance criteria**

- allowed transitions match `tasks.md`
- completion sets CompletedAt
- reopening clears current CompletedAt
- history/audit intent is emitted for meaningful transitions
- no generic status setter bypasses lifecycle rules

---

## MIMIR-013 — Implement Task assignment and due-date behavior

Implement:

- zero or one assignee
- assign
- unassign
- optional due date
- overdue calculation/query behavior

**Acceptance criteria**

- unassigned Task is valid
- Done/Cancelled tasks are not presented as actively overdue
- reopening an overdue Task restores overdue condition

---

## MIMIR-014 — Implement child Task hierarchy

Implement:

- ParentTaskId
- parent/child validation
- maximum nesting depth
- Project-context inheritance on child creation

**Acceptance criteria**

- no self-parenting
- no cycles
- maximum two descendant levels below root
- deeper nesting rejected with domain result suitable for UI suggestion
- child remains a full Task with independent lifecycle

---

## MIMIR-015 — Implement Task kind / Project Activity distinction

Introduce a semantic distinction such as:

- Work
- ProjectActivity

Project Activity Tasks must remain normal Tasks for identity/time/audit behavior but follow special invariants.

**Acceptance criteria**

- normal Task behavior remains default
- Project Activity cannot be promoted
- Project Activity cannot move to another Project
- Project Activity is excluded from normal completion calculations

---

# Phase 2 — Task Application Layer

## MIMIR-020 — Create Task use case

Input should remain minimal.

Required:

- Title

Optional:

- Description
- Assignee
- DueDate
- ParentTask
- Project
- Priority

**Acceptance criteria**

- UUIDv7 generated
- human key generated
- defaults applied
- authorization hook exists
- domain result returned without leaking persistence model

---

## MIMIR-021 — Get Task / Task details query

Return the information needed for Task detail UI without exposing internal entities.

Include:

- core Task data
- human key
- parent/project references
- child summary
- relevant timestamps

Keep Notes/Time/Audit as separately loadable concerns where appropriate.

---

## MIMIR-022 — Edit Task use case

Support deliberate edits:

- title
- description
- priority
- assignee
- due date

Do not implement unrestricted generic patch behavior.

---

## MIMIR-023 — Task lifecycle use cases

Explicit commands/endpoints for:

- start
- complete
- reopen/reset
- cancel
- restore

Keep lifecycle operations distinct from generic editing.

---

## MIMIR-024 — Task search/list query

Initial capabilities:

- search by title/key
- filter by status
- filter by priority
- filter by assignee
- filter by Project
- sort by updated/due/priority/key as needed

Avoid saved views until later.

---

# Phase 3 — Project Foundation

## MIMIR-030 — Add Project status and health types

**Status**

- Planned
- Active
- Completed
- Cancelled

**Health**

- OnTrack
- AtRisk
- OffTrack

Health and status remain separate.

---

## MIMIR-031 — Implement Project aggregate/entity

Minimum model from `projects.md`.

Include:

- UUIDv7 Id
- human key sequence
- title/description
- status
- owner
- dates
- ParentProjectId
- OriginTaskId
- completion/update metadata

---

## MIMIR-032 — Implement Project creation with default Project Activities

Creating a Project automatically creates:

- Planning
- Meetings
- Administration

Each is a real ProjectActivity Task.

**Acceptance criteria**

- each receives UUIDv7 and Task key
- each belongs to the Project
- each has immutable activity semantic type
- display title may be changed
- activity Tasks do not appear in default execution-task collections
- no custom activity categories in MVP

---

## MIMIR-033 — Implement Project lifecycle

Operations:

- activate
- complete
- reopen
- cancel
- restore

**Acceptance criteria**

- open Tasks/sub-projects cause warning/result on completion
- explicit override permits completion
- child work is never silently completed
- transitions are auditable

---

## MIMIR-034 — Implement sub-project hierarchy

Rules:

- a sub-project is a Project with ParentProjectId
- no cycles
- limited depth
- deeper hierarchy should produce a result suitable for suggesting Program use later

---

## MIMIR-035 — Implement Project progress calculation

Initial calculation:

- normal execution Tasks only
- Project Activity Tasks excluded

Prefer transparent counts over artificial precision.

---

# Phase 4 — Task -> Project Promotion

## MIMIR-040 — Implement Task promotion domain/application operation

Promotion creates a new Project.

Preserve:

- source Task identity/key
- source Task history
- title/description
- relevant owner/date context
- child Tasks
- Notes
- Time Entries
- Ticket links where applicable

Create:

- new Project UUIDv7
- new Project key
- standard Project Activity Tasks
- explicit source/target relationship

**Acceptance criteria**

- source Task is not renamed or destroyed
- source remains searchable
- Project records OriginTaskId
- Task records promoted Project reference
- audit/integration event emitted
- operation is transactionally safe

---

# Phase 5 — Notes

## MIMIR-050 — Implement Note entity

Fields from `notes.md`:

- UUIDv7 Id
- optional title
- Markdown body
- visibility
- owner
- zero or one primary context
- created/updated metadata

Visibility:

- Personal
- Shared

---

## MIMIR-051 — Implement Note visibility/context rules

**Acceptance criteria**

- Personal by default
- Personal does not become Shared implicitly
- zero or one primary context
- attaching to shared work requires explicit visibility handling
- authorization is enforced on every read/write

---

## MIMIR-052 — Create/edit/archive Note use cases

Keep Note creation lightweight.

Required:

- body

Optional:

- title
- visibility
- primary context

---

## MIMIR-053 — Convert checklist item to Task

P1 capability.

**Acceptance criteria**

- new Task receives UUIDv7/key
- checklist text becomes Task title
- source Note relationship preserved
- source checklist item remains visible
- work context may be inherited where valid

---

# Phase 6 — Time Entries

## MIMIR-060 — Implement TimeEntry entity

Fields:

- UUIDv7
- TaskId
- UserId
- StartedAt
- EndedAt
- DurationSeconds
- Description
- optional Billable
- Source
- created/updated metadata

Direct context is Task only.

---

## MIMIR-061 — Implement manual Time Entry

Minimum input:

- Task
- duration

Optional:

- timestamps/date
- description
- billable classification

---

## MIMIR-062 — Implement timer start/stop

Allow multiple active timers per user.

**Acceptance criteria**

- running entry has StartedAt and no EndedAt
- stopping derives duration
- UI/query can retrieve all active timers
- no silent restriction to one active timer

---

## MIMIR-063 — Implement overlap detection

Detect overlapping entries for the same user.

**Acceptance criteria**

- overlap does not invalidate source records
- overlap amount can be reported
- no silent truncation/normalization
- later policy enforcement remains possible

---

## MIMIR-064 — Implement Project time rollup

Aggregate from:

- execution Tasks
- Project Activity Tasks
- child Projects where appropriate

No direct Project TimeEntry records.

Support reporting by:

- Task
- Project
- Project Activity category
- User
- period

---

# Phase 7 — Audit & Integration Contracts

## MIMIR-070 — Define Mímir public contracts

Add only deliberately public contracts.

Initial candidates:

- TaskReference
- ProjectReference
- integration event envelope/contracts

Do not expose internal entities.

---

## MIMIR-071 — Implement initial integration events

Initial public set:

- TaskCreated
- TaskStatusChanged
- TaskAssigned
- TaskPromotedToProject
- ProjectCreated
- ProjectStatusChanged
- TimeEntryRecorded

All include versioned contract metadata.

---

## MIMIR-072 — Establish event identity/versioning

Every public integration event includes:

- EventId UUIDv7
- EventType
- EventVersion
- OccurredAt
- TenantId
- ActorId where applicable

Consumers must be able to process duplicate events idempotently.

---

## MIMIR-073 — Integrate Urd audit boundary

Mímir emits auditable context; Urd owns durable audit persistence.

Do not couple Mímir Core to Urd implementation.

---

# Phase 8 — Persistence

## MIMIR-080 — Add persistence mappings

Infrastructure mappings for:

- Tasks
- Projects
- Notes
- Time Entries
- Project Activity semantics
- promotion references

Domain types remain free of EF/provider attributes.

---

## MIMIR-081 — Add tenant-safe sequence persistence

Implement safe per-tenant human-key number allocation.

Requirements:

- concurrency-safe
- transactionally correct
- independent of UUID identity
- supports future custom prefixes

---

## MIMIR-082 — Add database migration

Migration must:

- create required schema
- create appropriate indexes
- include unique constraints
- account for tenant isolation
- include upgrade/recovery consideration

---

# Phase 9 — Presentation/API

## MIMIR-090 — Task endpoints

Initial explicit endpoints/use-case bindings:

- create
- get
- list/search
- edit
- lifecycle actions
- promotion
- Note access where appropriate
- Time Entry access

Avoid domain-bypassing generic CRUD.

---

## MIMIR-091 — Project endpoints

Support:

- create
- get
- list
- edit
- lifecycle
- sub-project relationship
- Project Activities
- progress/time summary

---

## MIMIR-092 — Notes endpoints

Support:

- create
- get/list by context/owner
- edit
- visibility/context change
- archive

---

## MIMIR-093 — Time endpoints

Support:

- manual entry
- timer start
- timer stop
- active timers
- list/filter
- overlap/reporting data

---

# Phase 10 — MVP UI

## MIMIR-100 — Task list view

Use the approved design system.

Initial capabilities:

- search
- status/priority filters
- assignee
- Project
- sorting
- quick create

Project Activity Tasks are hidden from the normal Task list by default.

---

## MIMIR-101 — Task detail view

Include:

- key/title
- status
- priority
- assignee
- due date
- description
- child Tasks
- Project
- Notes
- Time
- history/audit summary
- promote-to-Project action

---

## MIMIR-102 — Project detail view

Separate:

### Work
Normal execution Tasks.

### Project Activities
- Planning
- Meetings
- Administration

Also show:

- status/health
- owner/dates
- sub-projects
- Notes
- progress
- time rollup

---

## MIMIR-103 — Time UI

Support:

- one-click timer start from Task
- multiple visible running timers
- manual entry
- overlap indication
- Project time report with Project Activity breakdown

---

# Phase 11 — Tests & Dogfooding

## MIMIR-110 — Task domain tests

Cover:

- defaults
- lifecycle transitions
- completion/reopen
- cancellation/restore
- hierarchy depth
- cycles
- Project Activity restrictions
- promotion prerequisites

---

## MIMIR-111 — Project domain tests

Cover:

- lifecycle
- hierarchy
- Project Activities
- progress exclusion rules
- promotion origin
- completion with open work

---

## MIMIR-112 — Notes tests

Cover:

- Personal default
- one primary context
- visibility changes
- access boundaries
- checklist promotion

---

## MIMIR-113 — Time tests

Cover:

- manual entry
- timers
- multiple active timers
- overlap detection
- Project rollup
- Project Activity reporting

---

## MIMIR-114 — Tenant isolation tests

Attempt cross-tenant access to every Mímir aggregate/use case.

UUID possession must never bypass tenant authorization.

---

## MIMIR-115 — Architecture and boundary checks

Enforce:

- no cross-module access to private implementation details
- external contract independence from Active Record models
- enforced tenant scoping
- controllers and views without business logic

---

## MIMIR-116 — Dogfood Mímir for Yggdrasil development

Before expanding scope, use Mímir itself to manage a meaningful portion of Yggdrasil work.

Capture observations about:

- Task creation friction
- hierarchy usefulness
- Project Activities
- time tracking
- Notes
- promotion
- missing workflow concepts

Use dogfooding evidence to decide P2/Later priorities.

---

# Explicitly Deferred

Do not include these in the first implementation wave unless the specification is intentionally revised:

- custom workflows
- custom fields
- custom Project Activity categories
- formal Ticket lifecycle ownership
- Programs/Portfolios
- recurring Tasks
- advanced dependencies
- Gantt/resource planning
- billing/invoicing
- approval chains
- arbitrary relationship graphs
- AI-generated workflow behavior

---

# Suggested First Iteration

The first implementation iteration should remain small.

Recommended first goal:

> **Create and retrieve a valid Mímir Task using UUIDv7 and immutable human-readable identity.**

Suggested issues:

1. MIMIR-001 — verify module project boundaries
2. MIMIR-002 — establish UUIDv7 identity
3. MIMIR-003 — human-readable key generation
4. MIMIR-010 — Task status/priority types
5. MIMIR-011 — Task aggregate
6. MIMIR-020 — Create Task use case

Do not start Project/Notes/Time implementation until this vertical slice is reviewed and understood.

## AI-Assisted Implementation Rule

When using AI for implementation, provide the relevant specification and one checklist item at a time.

Example:

> Implement MIMIR-011 according to `docs/modules/mimir/tasks.md` and `docs/modules/mimir/implementation-plan.md`. Preserve `docs/architecture/dependency-rules.md`. Do not implement later checklist items or add new dependencies without justification.

This keeps generated work narrow, reviewable, and aligned with the documented domain.
