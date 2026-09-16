# Dependency Rules

These rules keep the Rails monolith understandable as the product grows. They should be enforced by tests or static checks where doing so provides useful feedback.

## 1. Business Namespaces

Each business area owns its models, policies, workflows, and public interfaces. Initial namespaces include `Tyr`, `Valhalla`, `Mimir`, and `Urd`.

Code in one namespace must not reach into private constants or persistence details owned by another. Cross-module calls go through a deliberately public method, query object, service, or event.

## 2. Rails Layers

Controllers own HTTP concerns: authentication handoff, parameter handling, response selection, and calling application behavior. They do not own business rules.

Models own state, relationships, invariants, and behavior closely tied to that state. Focused service objects may coordinate a use case that spans models or external systems.

Views and presenters format output. They do not query unrelated business areas or perform mutations.

Jobs provide an asynchronous execution boundary. Moving code into a job does not make an invalid dependency valid.

## 3. Cross-Module Communication

Prefer a direct, explicit call when the caller needs an immediate result. Use an event when something has already happened and consumers can react independently.

Do not publish every model callback as an event. Events represent meaningful business facts and must carry stable identifiers rather than live Active Record objects.

## 4. Persistence

Use Active Record directly for the MVP. Do not introduce generic repositories or persistence wrappers that merely rename CRUD operations.

All tenant-owned records and queries must be scoped to the active tenant. Security must not depend on a caller remembering an optional scope. Important uniqueness and referential-integrity rules should also be enforced by PostgreSQL constraints.

Schema migrations are part of the application and must preserve supported data or explicitly document a destructive change.

## 5. External Contracts

REST resources, webhooks, Protocol Buffer messages, and import/export formats are explicit boundaries. Do not serialize Active Record models as an accidental public contract.

Long-lived contracts must be versioned and tested for compatibility. Removed Protocol Buffer field numbers are never reused.

## 6. Dependencies

Prefer capabilities already provided by Rails, Ruby, PostgreSQL, and the browser. Add a gem or JavaScript package only for a concrete need with a clear maintenance benefit.

Business code must not depend directly on an external vendor SDK when a small application-owned boundary would make failure behavior testable and replacement practical.

## 7. Verification

Automated checks should eventually verify at least:

- tenant-owned access cannot escape the active tenant
- namespace boundaries do not drift through private constant references
- controllers remain orchestration-focused
- public contracts do not expose internal model representations
- database constraints reinforce critical invariants

Violations require refactoring or an ADR that deliberately changes these rules.
