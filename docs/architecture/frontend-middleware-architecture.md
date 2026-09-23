# Yggdrasil Frontend & Middleware Architecture

**Status:** Draft
**Version:** 0.1
**Current backend:** Ruby on Rails MVP
**Frontend direction:** React + TypeScript + Vite
**Desktop direction:** Web-first, with Tauri considered for desktop packaging later

## 1. Purpose

Yggdrasil's frontend should behave as a desktop-class business application while remaining usable through a normal browser.

The frontend must remain sufficiently independent from the backend implementation that replacing Ruby on Rails with another backend technology should not require rewriting the user interface.

The frontend should support:

- Rich interactive workflows
- Browser-based operation
- Responsive layouts
- Future desktop packaging
- Controlled plugin/module extension
- Keyboard-first operation
- Explicit editing and concurrency handling
- Future offline capabilities
- Strong accessibility
- Deep-linkable application state

## 2. Architectural Principles

### 2.1 The frontend is an independent application

The frontend must not depend on Rails implementation details.

It should communicate with the backend through explicit contracts.

```text
Frontend
   |
   v
Yggdrasil Client API
   |
   v
Versioned HTTP/Event Contract
   |
   v
Rails MVP
```

A future backend should be able to replace Rails without major changes to UI code.

### 2.2 Backend implementation objects must not leak into the UI

Frontend models should not directly represent:

- ActiveRecord models
- Rails controllers
- Rails serialization conventions
- Database schemas
- Rails routes

Backend DTOs should be translated through the frontend data layer.

```text
Task API DTO
    |
    v
Task Mapper
    |
    v
Frontend Task Model
```

## 3. Initial Technology Direction

Primary stack:

- React
- TypeScript
- Vite

Likely supporting technologies:

- React Router
- Tailwind CSS as the styling foundation
- Yggdrasil-owned reusable React components
- Radix UI primitives or React Aria as accessibility-focused primitive candidates
- TanStack Query for remote/server state
- TanStack Table for data-grid/table behavior
- IndexedDB abstraction for future persistent/offline data
- OpenAPI for HTTP contracts
- WebSocket and/or Server-Sent Events for real-time events
- Tauri for a possible desktop distribution

Tailwind should provide styling utilities and design-token implementation, but it should not become the component architecture. Screens should compose reusable Yggdrasil components rather than repeat large utility-class strings throughout feature code.

Radix UI, React Aria, TanStack Query, and TanStack Table are preferred implementation candidates, not irreversible framework dependencies. The Yggdrasil component and application contracts should remain the stable boundary.

These dependencies should remain replaceable where practical.

## 4. Application Shell

Yggdrasil should have one consistent application shell.

```text
+--------------------------------------------------------------+
| Organization        Search / Commands                  User |
+-------------+------------------------------+-----------------+
| Navigation  |                              | Inspector       |
|             |                              |                 |
| Dashboard   |       Active Route           | Contextual      |
| My Work     |                              | information     |
| Mimir       |                              |                 |
| Tyr         |                              |                 |
| Urd         |                              |                 |
|             |                              |                 |
+-------------+------------------------------+-----------------+
```

The shell owns:

- Global navigation
- Organization/workspace selection
- Routing
- Command palette
- Keyboard shortcuts
- Inspector panel
- Notifications
- Global search
- User menu
- Layout state
- Module registration
- Plugin extension points

Modules must not replace or manipulate the application shell directly.

## 5. Navigation

Navigation should be module-oriented.

Example:

```text
Dashboard

My Work

Mimir
  Tasks
  Projects
  Programs

Tyr
  Users
  Access

Urd
  Audit

Administration
```

Modules register navigation entries through a controlled API.

```ts
registerNavigation({
  id: "mimir.tasks",
  module: "mimir",
  title: "Tasks",
  route: "/mimir/tasks"
});
```

Modules must not modify navigation DOM directly.

## 6. Routing

Every significant entity or application view should have a stable URL.

Examples:

```text
/mimir/tasks
/mimir/tasks/TASK-184
/mimir/projects/phoenix
/tyr/users/{id}
/settings/keyboard
```

URLs should be:

- bookmarkable
- shareable
- openable in separate browser tabs
- restorable
- permission-aware

The browser remains the primary mechanism for opening several independent entities simultaneously.

Internal application tabs are not required for the browser application. A future desktop version may introduce internal tabs if that proves useful.

## 7. Entity Interaction Model

Yggdrasil will use a hybrid navigation model.

### Quick inspection

Selecting an entity may open it in the Inspector.

### Full workspace

Opening the entity navigates to its canonical route.

```text
/mimir/tasks/TASK-103
```

The full view is used for substantial work.

## 8. Inspector Panel

The application has one shared Inspector system.

Modules provide inspector content but do not implement their own independent panel systems.

The user may configure the Inspector position as left or right. Width, collapsed state, and default open/closed behavior may also become user preferences.

The shell owns positioning and resizing.

Modules register inspectors through an explicit extension point.

Nested inspector stacks should be avoided initially. One contextual inspector should normally be active at a time.

## 9. Layout

Initially supported resizing:

- Main navigation width
- Inspector width
- Data table columns
- Selected dashboard widgets where appropriate

Do not initially implement:

- arbitrary docking
- floating panels
- IDE-style window management

Layout preferences should be stored per user.

## 10. Command System

Commands are a first-class frontend architectural concept.

A command represents an application action independently of how it is invoked.

```ts
interface Command {
  id: string;
  title: string;
  category: string;

  canExecute(context: CommandContext): boolean;

  execute(context: CommandContext): Promise<void>;
}
```

Examples:

```text
mimir.task.create
mimir.task.complete
mimir.task.assign-to-me
mimir.task.change-status

workspace.toggle-inspector
workspace.open-settings

navigation.open-tasks
navigation.open-projects
```

Commands may be invoked by:

- buttons
- menus
- context menus
- keyboard shortcuts
- command palette
- plugins

UI components should prefer executing commands rather than duplicating application logic.

## 11. Keyboard Architecture

Keyboard operation should be considered a primary interaction method.

Shortcuts map to commands.

Examples:

```text
Ctrl/Cmd + K       Command Palette
G then T           Tasks
G then P           Projects
C                  Create
```

Users should eventually be able to customize shortcuts.

The shortcut system must support:

- defaults
- user overrides
- conflicts
- clearing shortcuts
- restoring defaults
- platform-specific shortcuts

Modules and plugins should register commands, not global keyboard event listeners.

The shell owns keyboard dispatch.

## 12. Editing Model

Business records should not use aggressive autosave by default.

Editing follows:

```text
Load entity
   |
   v
Begin local edit
   |
   v
User modifies fields
   |
   v
Dirty state
   |
   v
Explicit Save
   |
   v
Backend validation/concurrency check
```

Autosave is appropriate for application preferences such as:

- panel width
- filters
- sort order
- view preferences
- keyboard settings
- local drafts

Autosaving committed business records should require explicit justification.

## 13. Optimistic Concurrency

All mutable business entities should eventually support version-aware updates.

Example entity:

```json
{
  "id": "TASK-123",
  "version": 17
}
```

Update:

```json
{
  "expectedVersion": 17,
  "changes": {
    "status": "in_progress"
  }
}
```

If the server has a newer version, the API should return an explicit conflict response.

The frontend should notify the user that the item changed while they were editing it and offer review/reload behavior.

Users must not unknowingly overwrite newer data.

## 14. Frontend Data Architecture

Components should not communicate directly with HTTP APIs.

Preferred flow:

```text
React Component
      |
      v
Application Service
      |
      v
Repository
      |
      v
Data Provider
     / \
    /   \
 Local  Remote
          |
          v
       Backend
```

Example:

```ts
interface TaskRepository {
  get(id: TaskId): Promise<Task>;
  search(query: TaskQuery): Promise<Task[]>;
  create(input: CreateTask): Promise<Task>;
  update(id: TaskId, input: UpdateTask): Promise<Task>;
}
```

UI code should call repository/application interfaces rather than arbitrary `fetch()` calls.

## 15. Remote Data

TanStack Query should be evaluated as the primary remote/server-state mechanism.

It should handle concerns such as:

- caching
- refetching
- invalidation
- loading states
- stale data
- retry behavior

It should not become the domain model itself.

## 16. Local State

Frontend state should be separated by purpose.

### Component state

Examples:

- dropdown open
- current form field
- selected row
- temporary dialog state

Use React local state where possible.

### Remote/server state

Examples:

- tasks
- projects
- users
- organizations

Managed through the query/data layer.

### Persistent local state

Examples:

- layout preferences
- keyboard mappings
- drafts
- offline cache
- pending operations

Stored through an explicit persistence abstraction.

Do not place everything in one global state store.

## 17. Offline Architecture

Offline support should be designed in stages.

### Phase 1 — Resilience

Cache previously retrieved information.

Users can view recently loaded information during temporary connectivity failures.

Business modifications require connectivity.

### Phase 2 — Local operations

Selected operations may be queued locally.

```text
User Action
   |
   v
Local Update
   |
   v
Pending Operation
   |
   v
Connectivity Restored
   |
   v
Server Sync
```

### Phase 3 — Conflict Resolution

Queued changes must include the entity version they were based upon.

Conflicting changes must not silently overwrite server state.

Complex distributed synchronization is explicitly out of MVP scope.

## 18. Plugin Architecture

Initial plugins are:

- trusted
- compiled
- bundled with Yggdrasil
- installed/deployed with the application

Runtime installation of arbitrary frontend code is not initially supported.

Plugins integrate through defined extension points.

Supported concepts may include:

- Navigation entries
- Routes
- Commands
- Dashboard widgets
- Entity tabs/sections
- Inspector sections
- Settings pages
- Context actions

Example:

```ts
interface YggdrasilPlugin {
  id: string;

  navigation?: NavigationRegistration[];
  routes?: RouteRegistration[];
  commands?: CommandRegistration[];
  widgets?: WidgetRegistration[];
  inspectors?: InspectorRegistration[];
  settings?: SettingsRegistration[];
}
```

Plugins must not receive unrestricted control of the application shell.

## 19. Frontend Modules

Frontend modules should correspond conceptually to Yggdrasil backend modules.

Example:

```text
modules/
  mimir/
  tyr/
  valhalla/
  urd/
```

Frontend modules must not mirror backend implementation internals.

Mimir remains Mimir regardless of whether the backend implementation is Ruby, C#, Go, or another language.

## 20. Suggested Project Structure

```text
src/
|-- app/
|   |-- shell/
|   |-- routing/
|   |-- commands/
|   |-- keyboard/
|   |-- navigation/
|   `-- inspector/
|
|-- platform/
|   |-- api/
|   |-- storage/
|   |-- events/
|   |-- sync/
|   `-- desktop/
|
|-- modules/
|   |-- mimir/
|   |   |-- domain/
|   |   |-- application/
|   |   |-- data/
|   |   |-- components/
|   |   |-- pages/
|   |   `-- registration.ts
|   |-- tyr/
|   |-- valhalla/
|   `-- urd/
|
|-- design-system/
|-- plugins/
`-- shared/
```

`shared/` should remain small.

Code should preferably belong to the application shell, platform layer, design system, or a specific domain module rather than accumulating in a generic shared directory.

## 21. Middleware / Client API Layer

The frontend should have an explicit integration boundary.

```text
Frontend Domain
      |
      v
Client API / Repository
      |
      v
Transport Adapter
      |
      v
HTTP / Events
      |
      v
Rails
```

Transport concerns belong below the application/domain layer.

Examples:

- authentication headers/cookies
- JSON serialization
- error translation
- request correlation
- API versioning
- retry policy
- network status

A React page should never need to know how Rails handles these concerns.

## 22. API Errors

Backend errors should be translated into normalized frontend errors.

```ts
type ApplicationError =
  | ValidationError
  | AuthorizationError
  | NotFoundError
  | ConflictError
  | NetworkError
  | UnexpectedError;
```

Components should respond to application-level errors rather than Rails-specific HTTP implementation details.

## 23. Real-Time Events

Real-time updates should eventually flow through a centralized event system.

```text
Backend event
    |
    v
WebSocket / SSE
    |
    v
Frontend Event Adapter
    |
    v
Application Event
    |
    v
Relevant module/cache
```

Components should not independently create WebSocket connections.

This system can notify a user when another user updates an entity they currently have open.

## 24. Desktop Platform

Desktop-specific functionality should be hidden behind platform interfaces.

```ts
interface PlatformServices {
  notify(...): Promise<void>;
  openFile(...): Promise<void>;
  saveFile(...): Promise<void>;
}
```

Possible implementations:

```text
WebPlatformServices
TauriPlatformServices
```

React components should not generally call Tauri APIs directly.

## 25. Accessibility

Accessibility is a core design requirement.

At minimum:

- complete keyboard navigation
- visible focus indicators
- semantic controls
- screen-reader labeling
- sufficient contrast
- scalable text
- reduced-motion support
- no interaction requiring precise pointer use
- keyboard-accessible context menus
- accessible tables and forms

Accessibility should be implemented in the design system rather than repeatedly recreated by modules.

## 26. Design System Ownership

Common interface patterns belong to the Yggdrasil design system.

Examples:

- EntityHeader
- EntityInspector
- DataTable
- PropertyEditor
- ActivityTimeline
- StatusBadge
- UserPicker
- CommandMenu
- EmptyState
- ErrorState
- ConfirmDialog

Modules compose standard components rather than creating incompatible versions of common interactions.

## 27. Architecture Rules

The following should be considered initial frontend rules.

1. UI components must not directly depend on Rails.
2. UI components should not directly perform arbitrary HTTP requests.
3. Backend DTOs must not become frontend domain models by default.
4. Backend APIs must be accessed through explicit adapters/repositories.
5. Significant views must have stable routes.
6. Browser tabs remain supported through normal URLs.
7. Business entities should use explicit save semantics by default.
8. Concurrent edits must be detected rather than silently overwritten.
9. Modules integrate with the shell through explicit registrations.
10. Plugins initially consist only of trusted bundled code.
11. Plugins may only use approved extension points.
12. Keyboard actions operate through the command system.
13. User keyboard mappings should eventually be customizable.
14. The Inspector is shell-owned and consistent across modules.
15. Module implementation details should remain private to each module.
16. Desktop-specific APIs must be abstracted from general UI components.
17. Offline support must never silently discard or overwrite conflicting work.
18. Accessibility is a design-system requirement, not an optional module feature.

## 28. Deferred Decisions

The following remain intentionally unresolved:

- Exact React component/design library
- IndexedDB implementation
- Full offline synchronization behavior
- Desktop internal tabs
- Dynamic third-party plugins
- Plugin sandboxing
- Collaborative real-time editing
- Mobile-native application
- Arbitrary panel docking
- Exact WebSocket vs SSE strategy
- Exact API generation strategy

These should be decided when actual requirements justify them rather than being over-designed during the MVP.
