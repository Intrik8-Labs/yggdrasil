# Yggdrasil — Module Catalog

The original plan defined 23 Norse-named modules for a full
MSP/PSA/RMM/CRM/ERP platform. This restart keeps the catalog as
reference and keeps the naming, but only a small slice is actually in
scope right now (`docs/planning/CHARTER.md`,
`docs/planning/ROADMAP.md`). Everything else is deferred and will be
re-justified individually, against real usage evidence, when it's
actually reached — not pre-committed as a batch (see
`docs/decisions/adr-0005-deferred-decisions-log.md`).

## In Scope — Phase 1 MVP

**Smidr — Agent**
Runs on the author's own machines, connects outbound only (never
listens), and reports basic health/inventory. No per-agent certificate
identity yet — see `docs/decisions/adr-0003-outbound-only-agent-comms.md`.
Scaled down from the original orchestration-layer vision (enrollment,
boot triggers, build coordination) to just: connect, report, receive
simple commands.

**Heimdallr — Monitoring**
Receives what Smidr reports and displays fleet/machine health at a
glance. Scaled down from the original (time-series storage, anomaly
feeds to Völva, SLO management) to: collect, store, display.

**Mimir — Tasks/Tickets**
Tracks the author's own tasks and projects, linked to the machine(s) they
relate to. Scaled down from the original (full epics/sprints, commit/PR
linking, CI/CD timeline integration) to: create, track, and link tasks
to machines.

**Tyr — Minimal Auth**
Single-user login only, just enough to gate access to the instance. This
is not the identity module from the original catalog (no OIDC
federation, no per-permission JWT claims, no certificate issuance for
agents) — those are deferred along with multi-tenancy and agent identity.

## Future Catalog (Reference Only — Not In Scope)

Kept here as the re-justification checklist for Phase 3
(`docs/planning/ROADMAP.md`). One-line summaries carried forward from
the original plan; each needs to be re-justified against real evidence
before being picked up, not assumed.

| Module | Original purpose |
| --- | --- |
| Valhalla | Tenant/admin management — moot until there's more than one tenant |
| Urd | Immutable audit trail and compliance logging |
| Gjallarhorn | SLA enforcement and escalation on top of Mimir's work items |
| Bragi | Internal notes and contextual team communication |
| Saga | Scheduling/calendar coordination for technician availability |
| Odin | Internal/external knowledge base and runbooks |
| Ymir | CI/CD visibility, build/release tracking |
| Eir | Remote diagnostics and remediation via Smidr |
| Ran | Backup job monitoring (not performing backups itself) |
| Vedfolnir | CVE/security posture tracking, patch compliance |
| Volva | ML-based predictive intelligence on top of Heimdallr telemetry |
| Skald | Reporting/analytics across platform data; doc validation tooling |
| Freyja | Hardware/software asset lifecycle registry |
| Forseti | Contracts, billing, renewal workflows |
| Sigrun | Automated client onboarding/provisioning |
| Verdandi | Notification delivery fabric (email, webhook, push) |
| Hermod | External integrations and API gateway |
| Loki | Automation/workflow builder across modules |
| Bifrost | Customer-facing self-service portal |

## Related

- `docs/planning/CHARTER.md`
- `docs/planning/ROADMAP.md`
- `docs/decisions/adr-0002-mvp-single-tenant-scope.md`
- `docs/decisions/adr-0003-outbound-only-agent-comms.md`
- `docs/decisions/adr-0004-modular-boundaries-event-driven-comms.md`
- `docs/decisions/adr-0005-deferred-decisions-log.md`
