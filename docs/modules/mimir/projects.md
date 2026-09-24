# Mímir Projects — MVP Specification

> Status: approved working MVP specification. This document defines the minimum Project behavior required to support structured work, sub-projects, Task promotion, and Project-level reporting.

## Purpose

A Project represents **structured work that coordinates multiple Tasks, people, dates, and outcomes**.

A Project should be created when work has outgrown a single Task or requires coordination beyond lightweight task decomposition.

> **A Task is work. A Project is structured work.**

Projects add structure such as multiple Tasks, milestones, sub-projects, ownership, project-level status, Notes, aggregated time, progress, health, and relationships.

## MVP Scope

### P0
- create/view/edit/complete/cancel Project
- UUIDv7 identity
- human-readable Project key
- title/description
- status
- owner
- start/target dates
- created/updated metadata
- Project Tasks
- Project Activities
- basic list/search/filter
- audit significant changes

### P1
- sub-projects
- Project Notes
- time rollup
- milestones
- Task -> Project promotion
- progress summary
- health indicator
- Ticket relationships

### Later
- budgets and resource planning
- advanced dependencies/scheduling
- baselines/forecasting
- custom workflows/fields
- Program/Portfolio analytics
- approval chains
- configurable Project Activity catalog

## Identity

Projects use immutable UUIDv7 system identity plus a tenant-scoped sequence and human-readable key such as `PRJ-42`.

Human keys are immutable after creation and are not canonical persistence/API identity.

## Domain Project Record

| Field | Type | Required | Default | Mutable | Notes |
| --- | --- | ---: | --- | ---: | --- |
| `Id` | UUIDv7 | Yes | System | No | Canonical identity |
| `Number` | Sequence | Yes | System | No | Tenant-scoped |
| `Title` | String | Yes | — | Yes | Project name |
| `Description` | Text | No | null | Yes | Current Project context |
| `Status` | ProjectStatus | Yes | Planned | Yes | MVP lifecycle |
| `OwnerId` | Actor/User ID | No | null | Yes | One primary owner |
| `StartDate` | Date | No | null | Yes | Optional |
| `TargetDate` | Date | No | null | Yes | Optional |
| `ParentProjectId` | UUIDv7 | No | null | Yes* | Sub-project hierarchy |
| `OriginTaskId` | UUIDv7 | No | null | No/System | Set when promoted from Task |
| `CompletedAt` | Timestamp | No | null | System | Set when completed |
| `CreatedAt` | Timestamp | Yes | System | No | Immutable |
| `CreatedBy` | Actor ID | Yes | System | No | Immutable |
| `UpdatedAt` | Timestamp | Yes | System | System | Last meaningful update |
| `UpdatedBy` | Actor ID | Yes | System | System | Last meaningful update |

## Status

MVP statuses: Planned, Active, Completed, Cancelled.

Projects may be reopened/restored through audited transitions.

## Ownership

A Project has zero or one primary owner in MVP. Project Tasks retain independent assignees.

## Tasks Within Projects

A Project may contain zero or more Tasks.

Rules:
- Tasks remain first-class entities
- a Task belongs to at most one primary Project in MVP
- moving a Task between Projects is explicit and audited
- removing a Task from a Project does not delete it
- Tasks may exist without a Project
- completing a Project does not silently complete child Tasks

If open Tasks remain when completing a Project, warn and require explicit confirmation.

## Project Activities

Every Project receives a small set of **system-managed Project Activity Tasks**.

MVP defaults:
- Planning
- Meetings
- Administration

These exist so Project-level effort is still recorded through the normal Task -> Time Entry model while remaining distinct from execution work.

### Behavior

Project Activity Tasks:
- are real Tasks with UUIDv7 identity and normal Time Entries
- belong permanently to their Project
- are created automatically with the Project
- are shown in a dedicated **Project Activities** area
- are excluded from the normal Task backlog by default
- are excluded from ordinary Kanban/board views by default
- do not count toward normal Task completion percentages
- do not create overdue noise merely because they remain active
- remain available for the lifetime of the Project
- may contain Notes
- may be renamed for display without changing their semantic activity type
- cannot be moved to another Project
- cannot be promoted into a Project
- should not be permanently deleted while the Project exists

```text
PRJ-42 Phoenix Migration

Work
├── TASK-104 Network migration
├── TASK-105 Identity migration
└── TASK-106 Validation testing

Project Activities
├── Planning
├── Meetings
└── Administration
```

### Future configuration

Later, organizations may define additional reusable Project Activity categories, such as Architecture, Research, Client Communication, Documentation, Travel, Change Management, or Training.

These categories are defined at the **organization level**, not ad hoc per Project.

The semantic concept of a Project Activity remains controlled by Yggdrasil even when organizations configure the catalog.

MVP uses only the fixed defaults: Planning, Meetings, Administration.

## Sub-Projects

A sub-project is a normal Project with `ParentProjectId`.

For MVP, support:

```text
Parent Project
└── Sub-project
    └── Sub-project
```

If deeper structure is needed, suggest a Program.

## Task -> Project Promotion

Promotion creates a new Project identity while preserving the source Task.

The Project receives a new UUIDv7, new Project key, title/description/context, relevant owner/dates, and source Task relationship.

Child Tasks become Tasks within the resulting Project.

The promoted Project also receives the standard Project Activity Tasks.

The source Task remains searchable and auditable.

## Completion and Cancellation

Completion sets `CompletedAt`, emits audit history, retains Tasks/Notes/time/relationships, and warns on open Tasks/sub-projects.

Cancellation preserves identity/history, does not delete Tasks, may be restored, and is audited.

## Progress

Initial progress should use execution work, not Project Activity Tasks.

Suggested baseline: **Completed normal Tasks / Total active normal Tasks**.

## Health

Project Health is separate from Status.

Initial values:
- On Track
- At Risk
- Off Track

For MVP this may be manually set.

## Milestones

P1 milestone concept:
- UUIDv7
- title
- target date
- completed date
- status
- Project ID

## Notes

Projects may have lightweight Notes. See `notes.md`.

## Time

Projects do not accept direct Time Entries in MVP.

All recorded work time belongs to Tasks.

Project totals are aggregated from:
- normal execution Tasks
- Project Activity Tasks
- child Project rollups where appropriate

## Audit Requirements

Audit at least Project creation, title/status/owner/date changes, parent Project changes, Task movement, sub-project changes, completion/reopening, cancellation/restoration, promotion origin, and Project Activity configuration changes where applicable.

## Business Invariants

1. Project ID is immutable UUIDv7.
2. Human-readable Project key is immutable.
3. Project hierarchy cannot contain cycles.
4. Project hierarchy depth is limited.
5. A Task belongs to at most one primary Project in MVP.
6. Tasks and Projects may exist independently.
7. Status and Health are separate concepts.
8. Completion does not silently complete child work.
9. Task -> Project promotion preserves source Task identity/history.
10. Project Activity Tasks do not affect normal work completion percentage.
11. Project Activity Tasks cannot be moved to another Project.
12. Project Activity Tasks remain semantically distinct from normal Tasks.
13. Domain Project semantics are not tenant-configurable.
14. Future custom Project Activity categories are organization-level configuration, not arbitrary per-Project types.

## MVP Exclusions

The first Project MVP does not require Programs, Portfolios, budgets, resource planning, dependency graphs, Gantt scheduling, advanced forecasting, custom Project workflows, arbitrary hierarchy depth, multiple primary owners, sophisticated automated health scoring, or custom Project Activity categories.

## Hierarchy

```text
Task       = actionable work
Project    = structured execution
Program    = coordinated outcomes
Portfolio  = strategic organization
```
