# Mímir Time Entries — MVP Contract

> Status: approved working MVP specification. Time Entries record effort spent on Tasks and provide the source of truth for Project time rollups and future reporting/billing capabilities.

## Purpose

A Time Entry represents a discrete amount of recorded effort.

> **Time is recorded against actionable work and aggregated upward.**

Mímir owns source work-time records. Other modules may consume them but should not redefine or rewrite their meaning.

## MVP Scope

### P0
- manual Time Entry
- start/stop timer
- Task association
- actor/user
- duration
- optional description
- created/updated metadata
- multiple active timers permitted
- overlap detection
- basic filtering
- audit meaningful changes

### P1
- Project rollup/reporting
- billable/non-billable classification
- source/origin metadata
- correction workflow

### Later
- billing rates
- labor cost
- invoicing
- approval workflows
- payroll integration
- capacity/resource planning
- organization policy for overlapping timers

## Primary Context

For MVP, a Time Entry has exactly one direct work context: **Task**.

Projects, Programs, and Portfolios do not accept direct Time Entries.

Their time is aggregated from underlying Tasks.

Tickets that require tracked work should create/link Tasks rather than receiving direct Time Entries.

## Core Time Entry Record

| Field | Type | Required | Default | Mutable | Notes |
| --- | --- | ---: | --- | ---: | --- |
| `Id` | UUIDv7 | Yes | System | No | Canonical identity |
| `TaskId` | UUIDv7 | Yes | — | Limited | Direct work context |
| `UserId` | Actor/User ID | Yes | Current actor | Limited | Person whose work is recorded |
| `StartedAt` | Timestamp | No | null | Yes | Timer/manual optional |
| `EndedAt` | Timestamp | No | null | Yes | Null while timer runs |
| `DurationSeconds` | Integer | Yes* | Derived/manual | Limited | Canonical duration |
| `Description` | Text | No | null | Yes | Optional work note |
| `Billable` | Boolean | No | false | Yes | P1/optional |
| `Source` | TimeEntrySource | Yes | Manual | No/System | Manual, Timer, Import, System |
| `CreatedAt` | Timestamp | Yes | System | No | Immutable |
| `CreatedBy` | Actor ID | Yes | System | No | Immutable |
| `UpdatedAt` | Timestamp | Yes | System | System | Last meaningful update |
| `UpdatedBy` | Actor ID | Yes | System | System | Last meaningful update |

## Identity

Time Entries use immutable UUIDv7 identity. A human-readable key is not required for MVP.

## Manual Entry

Minimum input:
- Task
- duration

Optional:
- start/end or date
- description
- billable classification

Exact clock timestamps are not required when only duration is known.

## Timer Entry

Timer flow:
1. choose a Task
2. start timer
3. record `StartedAt`
4. timer remains active
5. stop timer
6. record `EndedAt`
7. derive `DurationSeconds`

## Multiple Active Timers

Mímir permits multiple active timers for the same user.

This supports legitimate concurrent work such as working across related subtasks or monitoring a long-running task while actively working on another.

Mímir must not hide overlap.

```text
TASK-101  10:00-11:00
TASK-102  10:30-11:30

Recorded Task time: 2h
Elapsed wall-clock span: 1.5h
Overlap: 30m
```

Rules:
- overlapping records remain valid source records
- overlap must be detectable and reportable
- the UI should indicate when multiple timers are running
- later organization policy may allow, warn, prohibit, or require review for overlap, especially for billable time
- MVP should not silently truncate or normalize overlapping entries

## Duration

`DurationSeconds` is canonical for reporting.

Rules:
- positive only
- timer duration derives from start/end
- manual duration may be entered directly
- formatted values are presentation only

## Time Zones

Persist timestamps in an absolute representation such as UTC. Display in the user's configured/local timezone. Duration must remain timezone-independent.

## Editing and Corrections

Users may correct duration, start/end, Task, description, and billable flag.

Meaningful corrections are audited. Created metadata remains immutable.

Future accounting/billing features may introduce locked/posted periods and adjustment records; MVP does not.

## Project Rollup

Projects aggregate Time Entries from Tasks, including execution Tasks and Project Activity Tasks.

```text
PRJ-42 Phoenix Migration        220h

Execution work                 186h
Project Activities              34h
  Planning                      14h
  Meetings                      12h
  Administration                 8h
```

No duplicate Project-level Time Entries are created.

## Project Activities

Project-level planning/meeting/administrative time is recorded using system-managed Project Activity Tasks.

MVP categories:
- Planning
- Meetings
- Administration

This keeps reporting detailed without introducing a second time-entry model.

Later, organizations may configure additional Project Activity categories at the organization level.

## Task Promotion

When a Task is promoted to a Project:
- existing Time Entries remain attached to the source Task
- no duplicate entries are created
- the resulting Project may roll those historical entries upward through the preserved source relationship
- the new Project receives its standard Project Activity Tasks

## Billable Classification

Optional P1 capability.

If enabled:
- default may later be organization-configurable
- billable status does not imply a rate
- Mímir records classification only
- billing modules determine pricing

## Source

Recommended values:
- Manual
- Timer
- Import
- System

Source is system-controlled and immutable.

## Audit Requirements

Audit at least Time Entry creation, timer start/stop, duration correction, Task change, User change where permitted, billable flag change, void/archive/restore, import, and future overlap-policy actions.

## Permissions

Conceptually distinguish:
- record own time
- view own time
- edit own time
- view team/Project time
- edit another user's time
- void/archive entry

Viewing a Task does not automatically grant permission to rewrite another user's time.

## Reporting

Useful aggregates:
- total duration
- duration by Task
- duration by Project
- duration by Project Activity category
- duration by user
- duration by day/week
- overlapping duration

## Export

Preserve UUID, User ID, Task ID, start/end where available, duration, description, billable flag, source, and created/updated metadata.

## Business Invariants

1. Time Entry ID is immutable UUIDv7.
2. CreatedAt/CreatedBy are immutable.
3. Duration must be positive.
4. Timer end cannot precede start.
5. A Time Entry belongs directly to exactly one Task.
6. Multiple active timers per user are permitted.
7. Overlap is preserved and detectable.
8. Projects do not accept direct Time Entries in MVP.
9. Project totals are derived from Task Time Entries.
10. Project Activity Tasks provide Project-level overhead categories.
11. Task -> Project promotion preserves historical Time Entries.
12. Source is system-controlled and immutable.
13. Meaningful corrections are audited.
14. Mímir owns source work-time data.

## MVP Exclusions

The initial MVP does not require direct Project/Program/Portfolio Time Entries, billing rates, invoicing, payroll, labor-cost accounting, automatic desktop tracking, screenshots/employee surveillance, utilization targets, approval workflows, timesheet locking, accounting-period close, or complex adjustment journals.

## Design Principle

> **Recording time should be easier than reconstructing it later.**

Manual entry requires only Task + duration. Timer entry should be one action from a Task.
