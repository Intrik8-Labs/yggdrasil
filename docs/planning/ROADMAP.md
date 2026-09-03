# Yggdrasil — Roadmap

Yggdrasil is developed incrementally with lightweight weekly iterations. The roadmap defines direction and exit conditions rather than fixed delivery dates.

## Phase 0 — Architecture Foundation (current)

Establish the long-lived project foundation before feature expansion.

- confirm .NET 10 / ASP.NET Core as the primary platform
- adopt modular monolith + Clean Architecture
- define strict module dependency rules
- establish `SharedKernel` boundaries
- establish Core / UseCases / Infrastructure / Contracts per module
- define command/query conventions
- establish architecture tests
- define versioned contract conventions for events and Protobuf
- clean legacy issues and documentation from previous implementation experiments

**Exit condition:** the repository builds with the agreed target structure and architecture rules are executable/testable rather than merely documented.

## Phase 1 — Dogfood Work Management

Build the smallest useful platform slice around Yggdrasil managing its own development.

### Týr

- local identity/authentication baseline
- user model
- organization membership model
- active tenant context

### Valhalla

- organization creation
- basic tenant administration
- organization switching

### Mímir

- projects
- tasks
- task status workflow
- assignment
- comments/notes sufficient for project work
- manual time entries
- basic start/stop timer

### Urd

- audit important identity, tenant, and work-item changes
- establish an append-oriented audit model

### Web

- login
- organization selector
- task/project views
- create/update work
- basic time tracking

**Exit condition:** Yggdrasil is useful enough to manage Yggdrasil's own weekly planning and development work.

## Phase 2 — Knowledge, Assets, and Service Management

Expand based on dogfood experience rather than implementing the entire catalog at once.

Likely candidates:

- **Odin** — template-driven Markdown documentation, versions, knowledge base
- **Freyja** — asset lifecycle and inventory
- **Gjallarhorn** — SLA/escalation concepts
- richer Mímir ticket/incident/request workflows
- customer-facing interaction groundwork for Bifröst

**Exit condition:** the platform supports a practical small-business/MSP work-management loop beyond project tasks alone.

## Phase 3 — Endpoint and Operations Loop

Introduce managed endpoint capabilities while preserving a contract-first security model.

- **Smidr** — agent enrollment, heartbeat, inventory, command channel, reconnect/reconciliation
- **Heimdallr** — endpoint health and monitoring
- **Eir** — controlled diagnostics/remediation
- **Urd** audit coverage for remote actions
- gRPC/Protobuf agent contracts
- privilege/elevation policy
- signed/expiring commands and replay protection

Windows and Linux are primary agent targets; macOS remains supported with potentially reduced capability depth.

**Exit condition:** at least one real endpoint can securely report state and execute an explicitly authorized operation through Yggdrasil.

## Phase 4 — Automation, Integrations, and Extensibility

- **Loki** workflow/automation across modules
- **Hermod** integrations/API gateway capabilities
- plugin/extension SDK and versioned Protobuf contracts
- external event subscriptions and webhooks
- user-provided script execution policies

Extensibility must use public contracts and must not grant plugins direct dependencies on module implementation assemblies.

## Phase 5 — Business and Platform Expansion

Candidates include:

- Forseti contracts/service tracking and later billing
- Saga scheduling/calendar
- Verdandi notifications
- Bifröst customer portal
- Rán backup/recovery monitoring
- Veðrfölnir security posture
- Skald reporting/analytics
- Sigrun onboarding/provisioning
- Ymir build/deploy/release management
- Völva predictive intelligence

Each module is justified and planned independently.

## Cross-Cutting Roadmap

The following evolve continuously rather than belonging to one phase:

- tenant isolation and database-per-tenant options
- air-gapped installation and upgrades
- data export/import and customer portability
- security hardening
- architecture tests
- observability
- documentation and ADRs
- weekly project review and backlog hygiene
