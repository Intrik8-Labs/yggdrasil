# Yggdrasil — Module Catalog

Yggdrasil uses Norse-named modules as explicit bounded contexts inside a modular monolith. The catalog describes long-term domain ownership; it is not a commitment to build every module immediately.

## Initial Development Scope

### Týr
Authentication, identity, memberships, and access control.

Initial responsibilities:

- user identity
- authentication
- organization membership
- roles/permissions foundation
- active tenant context

### Valhalla
Administration and tenant management.

Initial responsibilities:

- organization creation
- tenant administration
- organization switching
- tenant-level settings

### Mímir
Work management.

Long-term responsibilities include tasks, tickets, projects, epics, sprints, incidents, requests, and related workflows.

Initial responsibilities:

- projects
- tasks
- assignment
- status/workflow basics
- comments/notes needed for work tracking
- time tracking

### Urd
Audit trail and compliance logging.

Initial responsibilities:

- audit significant changes in Týr, Valhalla, and Mímir
- preserve actor, tenant, time, action, and affected resource context
- establish an append-oriented audit model

## Extended Module Catalog

| Module | Responsibility |
| --- | --- |
| **Týr** | Authentication, identity, membership, and access control |
| **Mímir** | Work, tickets, tasks, projects, epics, sprints, incidents, and time tracking |
| **Valhalla** | Administration and tenant management |
| **Bifröst** | Customer-facing portal |
| **Gjallarhorn** | SLAs, escalation, and issue/service-management policy |
| **Verdandi** | Notifications and real-time alerts |
| **Heimdallr** | Fleet monitoring and health |
| **Urd** | Audit trail and compliance logging |
| **Eir** | Remote diagnostics and remediation |
| **Smidr** | Edge computing and agent orchestration |
| **Freyja** | Asset lifecycle management |
| **Loki** | Automation and cross-module workflow engine |
| **Hermod** | Integrations and API gateway capabilities |
| **Forseti** | Contracts, service tracking, and later billing/invoicing |
| **Odin** | Knowledge base and document management |
| **Rán** | Backup and recovery monitoring |
| **Bragi** | Communications and contextual notes |
| **Saga** | Scheduling and calendar |
| **Veðrfölnir** | Vulnerability and security posture |
| **Skald** | Reporting and analytics |
| **Sigrun** | Onboarding and provisioning |
| **Völva** | Predictive and ML-assisted intelligence |
| **Ymir** | Build, deployment, and release management |

## Ownership Rules

A module owns its business model. Other modules do not reach into its implementation projects.

Examples:

- Týr owns identity and membership; Mímir references identity through stable contracts/identifiers rather than Týr internals.
- Mímir owns work and source time entries; Forseti may later consume billable-time contracts for billing logic.
- Mímir owns work-item lifecycle; Loki owns broader cross-module automation.
- Freyja owns assets; Mímir may link work to assets through contracts/identifiers.
- Urd owns audit persistence; other modules emit auditable events/contracts.

See `docs/architecture/dependency-rules.md` for the binding dependency rules.

## Mímir Design Direction

Mímir should combine:

- Linear-like interaction speed
- Jira-like flexibility where it provides real value
- ServiceNow-like maturity around service-management concepts

The goal is not to clone any of those products. Common operations should remain fast while advanced configuration stays available without dominating everyday use.

Potential work types include:

- Task
- Ticket
- Incident
- Request
- Problem
- Story
- Epic

Projects remain a separate concept rather than inheriting from WorkItem.

## Time Tracking

Time tracking initially belongs to Mímir because time is recorded against work.

A time entry is expected to include concepts such as:

- tenant
- user
- work item
- start/end or duration
- description
- billable/non-billable classification
- source

Forseti may later consume time-entry contracts for billing; Skald may consume them for reporting.

## Extensibility

Future plugins and extensions integrate through versioned public contracts rather than implementation assemblies.

Protocol Buffers are expected for long-lived language-neutral plugin, extension, and agent contracts where appropriate.
