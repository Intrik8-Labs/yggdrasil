# Yggdrasil UI Component Architecture

**Status:** Draft
**Version:** 0.1
**Reference:** Approved Yggdrasil master application design
**Frontend:** React + TypeScript
**Scope:** Application shell, reusable components, interaction patterns, module extension points

## 1. Design Philosophy

Yggdrasil is a desktop-class business application delivered primarily through the browser.

The interface should prioritize:

- information density without visual clutter
- fast keyboard and pointer operation
- predictable interaction patterns
- strong accessibility
- reusable components
- module consistency
- progressive disclosure
- clear status and hierarchy
- responsive layouts without becoming mobile-first
- user customization where it improves productivity

Modules should compose Yggdrasil components rather than invent independent application experiences.

## Styling Foundation

Tailwind CSS is the preferred styling foundation for the Yggdrasil frontend.

Tailwind is responsible for implementing:

- spacing and layout
- typography
- responsive behavior
- light and dark themes
- borders, radii, and elevation
- component interaction states
- semantic design tokens

Tailwind utility classes should normally be encapsulated inside reusable Yggdrasil React components. Feature screens should prefer:

```tsx
<Button variant="primary">Save</Button>
<StatusBadge status="in-progress" />
```

over repeatedly reconstructing the same visual rules with large inline class lists.

The Yggdrasil design system owns the component API and visual semantics. Tailwind is an implementation tool beneath that system.

Accessibility-focused unstyled primitives such as Radix UI or React Aria should be evaluated for menus, dialogs, popovers, selection controls, and related interaction-heavy foundations.

TanStack Table should be evaluated for complex table behavior such as sorting, selection, resizing, virtualization, and configurable columns while allowing Yggdrasil to retain full visual control.

TanStack Query should be evaluated for remote/server-state behavior independently from presentation styling.

A source-owned component approach similar to shadcn/ui may be used selectively as a starting point, but third-party component defaults must not define the Yggdrasil design system.

## 2. Component Ownership

Components are divided into four levels.

### 2.1 Foundation

Low-level visual primitives.

Examples:

- Button
- IconButton
- TextInput
- Select
- Checkbox
- Radio
- Switch
- Badge
- Avatar
- Tooltip
- Menu
- Popover
- Dialog
- Divider

These should contain accessibility behavior by default.

### 2.2 Application Components

Reusable Yggdrasil-specific components.

Examples:

- EntityHeader
- EntityInspector
- DataTable
- ActivityTimeline
- PropertyGrid
- StatusPicker
- UserPicker
- OrganizationPicker
- CommandPalette
- SearchBar
- EmptyState
- ErrorState

Modules should use these wherever possible.

### 2.3 Shell Components

Owned exclusively by the application shell.

Examples:

- AppShell
- GlobalHeader
- PrimaryNavigation
- ModuleNavigation
- InspectorHost
- CommandHost
- NotificationCenter
- AccountMenu
- OrganizationSwitcher

Modules may register content with these components but must not replace them.

### 2.4 Module Components

Domain-specific components owned by a particular module.

Examples:

```text
Mímir
  TaskStatus
  ProjectHealth
  TaskRelations
  TimeEntry

Týr
  PermissionMatrix
  RoleSelector
  MembershipList

Urd
  AuditEvent
  AuditDiff
```

If a module component becomes generally useful, it may be promoted into the shared application component library.

## 3. Application Shell

The master shell consists of:

```text
┌──────────────────────────────────────────────────────────────┐
│ Brand       Global Search / Commands           Alerts  User │
├─────────────┬──────────────────────────────┬─────────────────┤
│             │                              │                 │
│ Primary     │                              │                 │
│ Navigation  │        Main Workspace        │    Inspector    │
│             │                              │                 │
│             │                              │                 │
└─────────────┴──────────────────────────────┴─────────────────┘
```

The three primary regions are:

1. Navigation
2. Workspace
3. Inspector

The workspace receives the majority of available width.

## 4. Global Header

The global header contains application-wide controls.

Initial contents:

- Yggdrasil identity
- global search / command entry
- connection/offline state
- notifications
- help when implemented
- user/account menu

The header should remain visually restrained.

It should not become a second navigation bar.

## 5. Global Search / Command Entry

The central search field doubles as the entry point for the command system.

Example:

```text
[ 🔍 Search or run a command...                  Ctrl + K ]
```

Activation opens the Command Palette.

Search eventually includes:

- commands
- tasks
- projects
- users
- programs
- navigation destinations
- recently viewed entities

The search field itself should not attempt to display complex result sets.

Results belong in the Command Palette.

## 6. Primary Navigation

The primary navigation is persistent on desktop layouts.

It includes:

- Dashboard
- My Work
- registered modules
- Settings
- user identity

Example:

```text
Dashboard
My Work

Mímir
  Tasks
  Projects
  Programs

Týr
  Users
  Access
  Organizations

Valhalla

Urd

────────────

Settings
```

Modules provide navigation registrations.

The shell controls rendering and hierarchy.

## 7. Navigation States

Each navigation item supports:

- normal
- hover
- focus
- selected
- disabled
- notification/count indicator

Expandable module groups support:

- expanded
- collapsed

Navigation state must be usable entirely by keyboard.

## 8. Navigation Resizing

The navigation panel may be user-resizable within defined limits.

It should also support a collapsed mode.

Example:

```text
Expanded:

[Mímir]
  Tasks
  Projects

Collapsed:

[M]
[T]
[P]
```

Collapsed navigation must retain accessible labels through tooltips and screen-reader text.

## 9. Page Header

Most workspace routes should use a standard PageHeader.

Structure:

```text
Breadcrumb / context

Tasks                                      [+ New Task]
Plan, track, and complete work.

[View controls / tabs / filters]
```

The component supports:

- title
- optional description
- breadcrumbs
- primary action
- secondary actions
- contextual commands

Modules should not create arbitrary heading layouts for normal pages.

## 10. Entity Header

Entity detail screens use EntityHeader.

Example:

```text
Tasks / TASK-284

TASK-284

Finalize API specification        [In Progress]

                              [Edit] [More ▾]
```

Supported content:

- entity type
- human-readable identifier
- title
- status
- breadcrumbs
- major actions

The header should remain visually consistent across entity types.

## 11. Data Table

DataTable will be one of the most important components in Yggdrasil.

Required capabilities should eventually include:

- sortable columns
- filtering
- column resizing
- selectable rows
- keyboard navigation
- pagination or virtualization
- configurable columns
- row actions
- context menus
- status indicators
- empty state
- loading state
- error state

Initial MVP does not need every capability.

The component architecture should allow them.

## 12. Data Table Selection

Single selection may populate the Inspector.

Example:

```text
TASK-281
TASK-282
TASK-283  ← selected
TASK-284
```

Selection must not automatically mean navigation.

Suggested behavior:

```text
Single click    Select + Inspector
Enter           Open entity
Double click    Open entity
Middle click    Browser-native new tab where supported
Context menu    Open / Open New Tab / Actions
```

Keyboard equivalents must exist.

## 13. Inspector

Inspector is a single shell-controlled contextual panel.

Typical structure:

```text
TASK-284                         ×

Details   Activity   Relations

Status
[ In Progress ▼ ]

Priority
[ High ▼ ]

Assignee
[ Erik ▼ ]

Due Date
[ Nov 20 ]

Description
...

────────────────────────────

[Edit]              [More ▾]
```

The shell controls:

- placement
- width
- open/closed state
- resizing
- animation
- focus handling

Modules control:

- content
- contextual tabs
- entity actions

## 14. Inspector Position

User preference:

```text
Inspector Position

○ Left
● Right
```

The setting applies globally.

Individual modules should not relocate the Inspector themselves.

## 15. Inspector Behavior

Inspector should be used for:

- quick review
- simple property changes
- activity review
- related entities
- lightweight actions

Inspector should not become a substitute for complex full-screen workflows.

Complex work should use the canonical entity route.

## 16. Property Grid

Entity metadata should use a reusable PropertyGrid.

Example:

```text
Assignee       Erik Thorvaldsson
Project        Yggdrasil Core
Priority       High
Due Date       Nov 20, 2026
Created        Nov 10, 2026
Updated        Nov 18, 2026
```

PropertyGrid should support:

- read-only values
- editable values
- status selectors
- users
- dates
- links
- custom fields later

## 17. Status

Status should always use both:

- text
- visual treatment

Color alone must never communicate state.

Example:

```text
[ In Progress ]
[ Completed ]
[ Blocked ]
```

Status colors must remain consistent across modules where semantics are equivalent.

## 18. Priority

Initial Mímir priority states:

- Low
- Normal
- High
- Urgent

Priority should have:

- textual label
- optional icon
- visual emphasis

Urgent must not rely solely on red color.

## 19. Command Palette

CommandPalette is a first-class component.

Example:

```text
┌──────────────────────────────────────────────┐
│ 🔍 Type a command or search...      Ctrl+K │
├──────────────────────────────────────────────┤
│ Recent                                       │
│   Open Tasks                        G T       │
│   Create Task                       C         │
│                                              │
│ Navigation                                   │
│   Go to Dashboard                   G D       │
│   Go to My Work                     G W       │
│   Go to Projects                    G P       │
│                                              │
│ Actions                                      │
│   Create Task                       C         │
│   Create Project                    P         │
│   Toggle Inspector                  Alt+I     │
└──────────────────────────────────────────────┘
```

The command palette should support:

- fuzzy searching
- command categories
- recent commands
- keyboard-only execution
- contextual commands
- disabled commands with explanations
- entity search integration later

## 20. Command Registration

Commands are registered centrally.

```ts
registerCommand({
  id: "mimir.task.create",
  title: "Create Task",
  category: "Mímir",
  defaultShortcut: "C",
  execute: ...
});
```

The same command may power:

- toolbar button
- context menu
- command palette
- keyboard shortcut

Application logic should not be duplicated for each invocation method.

## 21. Keyboard Shortcut Editor

Settings should contain a dedicated Keyboard Shortcuts screen.

Example:

```text
Command                         Shortcut

Open Command Palette            Ctrl + K
Go to Dashboard                 G D
Go to Tasks                     G T
Go to Projects                  G P
Create Task                     C
Toggle Inspector                Alt + I
```

Users may:

- search commands
- replace shortcut
- remove shortcut
- reset shortcut
- reset all defaults

Shortcut conflicts must be detected before saving.

## 22. Buttons

Initial variants:

```text
Primary
Secondary
Quiet
Danger
Icon-only
```

Rules:

- one dominant primary action per local context
- destructive actions require appropriate visual treatment
- icon-only buttons require accessible labels
- avoid excessive button styling
- actions available through keyboard must still remain discoverable

## 23. Forms

Forms should use consistent:

- field labels
- help text
- validation
- required-state indicators
- spacing
- error placement

Validation errors should appear adjacent to the relevant field.

A form must not rely only on a toast to report validation failure.

## 24. Explicit Save Model

Business forms should normally use:

```text
[Cancel] [Save]
```

Dirty forms should visibly indicate unsaved changes.

Navigation away from significant unsaved changes should request confirmation.

Local interface preferences may save automatically.

## 25. Concurrent Edit Warning

If an entity changes while being edited:

```text
┌──────────────────────────────────────────────┐
│ This task changed while you were editing it. │
│                                              │
│ [Review Changes]              [Reload]       │
└──────────────────────────────────────────────┘
```

The user's current local changes must not be silently discarded.

The other user's update must not be silently overwritten.

## 26. Activity Timeline

ActivityTimeline is reusable across entities.

Example:

```text
Today

10:41  Sarah changed status
       To Do → In Progress

09:17  Erik updated due date
       Nov 18 → Nov 20

Yesterday

16:32  Comment added
```

The timeline can eventually display:

- edits
- comments
- workflow transitions
- automated actions
- audit events
- system-generated changes

## 27. Dashboard Cards

Dashboard should use a limited component vocabulary rather than arbitrary cards.

Initial types:

### Metric Card

```text
My Tasks
12
6 due this week
```

### Health Card

```text
Project Health

Yggdrasil Core       On Track
Infrastructure       At Risk
Documentation        On Track
```

### Work List

```text
My Work
...
```

### Activity Feed

```text
Recent Activity
...
```

Widgets should have clearly defined loading, empty, error, and permission states.

## 28. Notifications

Notifications should be separated into:

### Toasts

Temporary confirmation.

Examples:

```text
Task saved.
Shortcut updated.
```

### Alerts

Persistent contextual information.

Examples:

```text
Connection lost.
This item has changed.
You no longer have permission to edit this task.
```

### Notification Center

Persistent user-directed events.

Examples:

```text
Task assigned
Mention received
Approval required
SLA warning
```

These should not be treated as one component.

## 29. Loading States

Avoid blank application areas.

Preferred loading states:

- skeleton for structured content
- inline spinner for localized actions
- progress indicator for meaningful long-running operations

Avoid full-screen spinners for normal navigation.

## 30. Empty States

Empty state should explain:

1. what is empty
2. why the user might care
3. what they can do next

Example:

```text
No tasks yet.

Tasks help track individual pieces of work.

[Create Task]
```

If the user cannot create tasks, the action should not be displayed.

## 31. Error States

Errors must identify whether they are:

- temporary
- permission-related
- validation-related
- not found
- offline
- unexpected

Avoid generic:

```text
Something went wrong.
```

when the application has better information.

## 32. Context Menus

Entity rows and relevant components may provide context menus.

Example:

```text
Open
Open in New Tab
────────────
Assign to Me
Change Status
────────────
Copy Link
────────────
Delete
```

Every context-menu action must also be reachable by another accessible mechanism.

Context menus are accelerators, not the exclusive interface.

## 33. Responsive Behavior

Yggdrasil is desktop-first but responsive.

### Large

```text
Navigation | Workspace | Inspector
```

### Medium

```text
Navigation | Workspace
                Inspector overlay/drawer
```

### Small

```text
Workspace

Navigation → drawer
Inspector → drawer
```

Functionality must remain available at smaller sizes even if layout changes.

## 34. Accessibility Rules

Every shared component must document:

- keyboard operation
- focus behavior
- screen-reader semantics
- disabled behavior
- error behavior
- reduced-motion behavior

Accessibility belongs inside the component implementation.

Modules should not need to reconstruct basic accessibility behavior.

## 35. Module Extension Rules

Modules may register:

- routes
- navigation items
- commands
- inspector content
- entity actions
- dashboard widgets
- settings sections

Modules may not:

- replace global navigation
- capture arbitrary global keyboard events
- manipulate shell DOM
- create independent notification systems
- implement conflicting inspector behavior
- bypass permission-aware command execution

## 36. Initial Component Implementation Priority

### P0 — Shell

- AppShell
- GlobalHeader
- PrimaryNavigation
- PageHeader
- InspectorHost
- CommandPalette

### P0 — Foundations

- Button
- IconButton
- Input
- Select
- Checkbox
- Menu
- Popover
- Dialog
- Badge
- Avatar
- Tooltip

### P0 — Application

- DataTable
- EntityHeader
- PropertyGrid
- StatusBadge
- UserPicker
- EmptyState
- ErrorState
- LoadingState

### P1

- ActivityTimeline
- ContextMenu
- NotificationCenter
- DashboardWidget
- KeyboardShortcutEditor
- FilterBar
- SearchInput

### P2

- Custom-field components
- Dashboard layout editor
- Offline/conflict UI
- Advanced data-grid configuration
- Plugin-provided widget containers

## 37. Component Documentation Standard

Every major reusable component should eventually document:

```text
Purpose
Anatomy
Variants
Properties
States
Keyboard behavior
Accessibility
Responsive behavior
Permissions
Extension points
Examples
Anti-patterns
```

This documentation becomes part of the design contract, not merely frontend implementation notes.
