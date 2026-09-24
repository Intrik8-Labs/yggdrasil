# Mímir Notes — MVP Contract

> Status: approved working MVP specification. Notes provide lightweight contextual capture inside Mímir without replacing full document or knowledge-management capabilities.

## 1. Purpose

A Note is a lightweight piece of contextual information associated with work.

Notes are intended for:

- meeting notes
- implementation context
- reminders
- decisions
- troubleshooting details
- temporary planning
- lightweight checklists

Notes should be easy to create and should not require the ceremony of creating a formal document.

A core rule is:

> **Notes capture context. Documents preserve structured knowledge.**

Mímir Notes should remain intentionally simpler than the future document/knowledge system.

## 2. Default Visibility

Notes are **personal by default**.

A newly created Note belongs to its creator unless the user explicitly shares it or attaches it to shared work.

Visibility states for MVP:

- **Personal**
- **Shared**

Future versions may support more granular visibility such as team, role, or explicit-user access.

## 3. Primary Context

A Note may exist independently or have **zero or one primary context**.

MVP primary context targets:

- Task
- Project
- Ticket

Future targets may include:

- Program
- Portfolio
- Customer
- Asset
- other module resources through public contracts

A Note must not have multiple primary contexts in MVP.

If a Note later needs relationships to additional work, those should be modeled as secondary links rather than additional primary attachments.

This rule keeps:

- permissions
- visibility
- ownership
- lifecycle
- search
- UI placement
- audit behavior

predictable and understandable.

## 4. Domain Note Record

| Field | Type | Required | Default | Mutable | Notes |
| --- | --- | ---: | --- | ---: | --- |
| `Id` | UUIDv7 | Yes | System | No | Canonical identity |
| `Title` | String | No | null | Yes | Optional short label |
| `Body` | Text/Markdown | Yes | — | Yes | Main note content |
| `Visibility` | NoteVisibility | Yes | Personal | Yes | Personal or Shared |
| `OwnerId` | Actor/User ID | Yes | Creator | Limited | Primary owner |
| `ContextType` | Enum | No | null | Yes | Task, Project, Ticket |
| `ContextId` | UUIDv7 | No | null | Yes | Primary associated work resource |
| `CreatedAt` | Timestamp | Yes | System | No | Immutable |
| `CreatedBy` | Actor ID | Yes | System | No | Immutable |
| `UpdatedAt` | Timestamp | Yes | System | System | Last meaningful update |
| `UpdatedBy` | Actor ID | Yes | System | System | Last meaningful update |

A Note does not require a title.

This allows quick capture such as:

> Firewall change approved by infrastructure. Schedule deployment Thursday evening.

## 5. Content Format

For MVP, Note content should support **Markdown or Markdown-like rich text**.

Minimum useful formatting:

- paragraphs
- headings
- bullets
- numbered lists
- checklists
- links
- inline code
- code blocks
- emphasis

Avoid building a complex collaborative editor initially.

The stored format should remain portable and exportable.

## 6. Personal Notes

A personal Note:

- is visible to its owner
- may exist without being attached to work
- may later be shared
- may later be attached to a Task, Project, or Ticket

Personal Notes should make quick capture inexpensive.

Example:

```text
Call vendor tomorrow about API rate limits.
```

No Project or Task should be required.

## 7. Shared Notes

A Shared Note is visible according to the associated work context and authorization rules.

For MVP:

- sharing is explicit
- a personal Note should never silently become shared
- attaching a personal Note to shared work should require confirmation if doing so changes visibility
- visibility changes are audited

A user should understand when information becomes visible to others.

## 8. Notes Attached to Tasks

Task Notes provide contextual information accumulated over time.

Examples:

- implementation discoveries
- external conversations
- temporary decisions
- troubleshooting information

Task Notes are distinct from the Task Description.

### Description

Represents the current definition of the Task.

### Notes

Represent accumulated context.

Changing the Task Description should not overwrite historical Notes.

## 9. Notes Attached to Projects

Project Notes may capture:

- planning discussions
- meeting notes
- technical decisions
- coordination details
- status context

They should remain lightweight.

If a Project Note becomes long-lived structured knowledge, users should eventually be able to promote or copy it into the document/knowledge system.

That capability is later scope.

## 10. Notes Attached to Tickets

Ticket Notes may capture:

- investigation details
- troubleshooting steps
- internal observations
- handoff context

Ticket Notes are not necessarily the same as customer-visible Ticket comments.

A future Ticket specification should explicitly distinguish:

- internal Note
- public/customer comment
- system/audit event

Do not expose internal Notes externally by default.

## 11. Checklist Items

Notes may contain checklist items.

Example:

```text
- [ ] Verify firewall rules
- [ ] Test staging login
- [ ] Notify customer
```

For MVP, checklist state may remain part of Note content.

P1 behavior:

> **Convert checklist item to Task**

The created Task should:

- receive a new UUIDv7
- receive a human-readable Task key
- copy the checklist text into the Task title
- link back to the source Note
- optionally inherit the Note's work context

The checklist item should then indicate that it was promoted/converted.

Do not silently remove the original checklist item.

## 12. Note → Task Promotion

A full Note may eventually be promoted into a Task where appropriate.

This is optional P1/later behavior.

Example:

```text
Note:
Investigate repeated authentication timeout reports.
```

could become:

```text
TASK-248
Investigate repeated authentication timeout reports
```

The Note remains preserved and records the relationship.

Promotion creates a new entity; it does not mutate the Note into a Task.

## 13. Editing

Notes are editable.

When edited:

- update `UpdatedAt`
- update `UpdatedBy`
- preserve Created metadata
- emit audit events for significant visibility/context changes

MVP does not need full content-version history unless required by compliance or dogfooding.

However, the architecture should not make future version history impossible.

## 14. Audit Behavior

At minimum, audit:

- Note created
- visibility changed
- owner changed
- attached to work
- detached from work
- checklist item promoted to Task
- Note promoted/copied to another entity type
- Note archived/deleted where applicable

Ordinary text edits do not need a full audit snapshot for MVP.

If Note content becomes compliance-sensitive later, version history can be added separately.

## 15. Ownership

A Note has one primary owner.

By default:

`OwnerId = CreatedBy`

Ownership may be transferable if permissions allow.

Ownership affects:

- personal visibility
- edit rights
- archive/delete rights

Ownership should not replace work-context permissions for Shared Notes.

## 16. Archive and Delete

Notes should support Archive.

Archived Notes:

- remain recoverable/searchable where appropriate
- retain identity
- retain audit history
- are removed from normal active views

Hard deletion should be limited.

A Shared Note associated with meaningful work should normally be archived rather than permanently deleted.

Personal scratch Notes may have more permissive deletion rules, but destructive behavior should still respect retention/compliance policy.

## 17. Search

MVP Notes should be searchable by:

- body text
- title
- owner
- visibility
- associated Task/Project/Ticket
- created/updated date

Search scope must respect permissions and visibility.

Personal Notes must not leak into organization-wide search results for other users.

## 18. Permissions

MVP behavior should conceptually distinguish:

- read
- edit
- share
- attach/detach
- archive/delete
- transfer ownership

Exact role mappings belong to the authorization design.

A user must never gain access to a Shared Note merely because they know its UUID.

All Note access requires tenant/context authorization.

## 19. Export

Notes should remain portable.

MVP export should preserve at least:

- UUID
- title
- body
- owner
- visibility
- context reference
- created/updated metadata

Markdown is preferred because it supports straightforward export and long-term portability.

## 20. Business Invariants

1. Note ID is immutable UUIDv7.
2. CreatedAt and CreatedBy never change.
3. A Note has exactly one owner.
4. Visibility defaults to Personal.
5. Personal Notes must not become Shared implicitly.
6. Shared Note access is authorization-controlled.
7. A Note may exist without a work context.
8. MVP supports at most one primary work context.
9. Promotion creates a new entity and preserves the source Note.
10. Checklist-to-Task conversion preserves the original checklist item and source relationship.
11. Notes are not a replacement for formal document management.
12. Search must respect visibility and tenant boundaries.

## 21. MVP Exclusions

The initial Notes MVP does not require:

- real-time collaborative editing
- complex document templates
- formal approval workflows
- knowledge-base publishing
- full revision/version history
- document signing
- comments inside Notes
- nested Notes
- arbitrary multi-resource primary attachment graphs
- external/customer-visible publishing

Those belong to later Mímir capabilities or the future knowledge/document system.

## 22. Design Principle

The primary UX rule should be:

> **Creating a Note should feel easier than creating almost anything else in Mímir.**

A user should be able to capture context quickly, then decide later whether that Note needs to become shared, attached, promoted, or formalized.
