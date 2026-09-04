# Yggdrasil Security Architecture

## Purpose

Security is a core architectural requirement for Intrik8 Yggdrasil, not a later hardening phase.

Yggdrasil is intended to support a broad deployment spectrum:

- small businesses and internal teams
- MSPs and service organizations
- self-hosted deployments
- SaaS deployments
- air-gapped environments
- higher-assurance environments, including organizations with government-contractor or similarly strict security requirements

The architecture should allow these environments to share one codebase without forcing every deployment into the most complex possible configuration.

The goal is a secure-by-default platform with progressively stronger deployment profiles where stricter controls are required.

## Security Principles

Yggdrasil should follow these baseline principles:

- deny by default
- least privilege
- explicit tenant isolation
- strong identity boundaries
- server-side authorization
- secure defaults
- no hidden cloud dependency
- customer data remains customer-owned
- secrets are minimized and protected
- privileged operations are auditable
- external inputs are untrusted
- module boundaries are security boundaries as well as architecture boundaries
- public contracts are versioned and validated
- cryptography uses established libraries and primitives
- security-critical behavior is tested negatively, not only for happy paths
- high-risk actions should be easy to attribute and difficult to perform accidentally

## Deployment Security Profiles

Yggdrasil should support distinct security profiles rather than one giant configuration matrix.

### Standard Self-Hosted

Intended for:

- small businesses
- internal engineering/IT teams
- homelabs
- smaller service organizations

Expected baseline:

- TLS
- local authentication and/or external identity provider
- strong password policy where local auth is used
- multi-tenant authorization
- encrypted secrets at rest where applicable
- audit history
- least-privilege service accounts
- secure defaults
- backups and export capability

### Managed SaaS

Adds requirements around:

- strong tenant isolation
- centralized secret management
- infrastructure identity
- per-environment separation
- hardened administrative access
- observability without leaking tenant-sensitive data
- abuse/rate limiting
- secure deployment pipelines
- incident-response readiness
- customer data export/deletion processes

### Air-Gapped / Disconnected

Must not require Internet access for runtime operation.

Requirements include:

- no cloud-only authentication dependency
- no external CDN requirement
- no online license validation requirement
- no mandatory hosted telemetry
- locally available update/install bundles
- offline identity options
- offline audit retention
- offline backup/restore
- integrity-verifiable release artifacts

External integrations should fail closed or degrade gracefully when unavailable.

### High-Assurance / Government-Contractor-Oriented

This profile should be designed to support stricter customer policies without claiming automatic compliance with any framework.

Potential controls include:

- mandatory MFA
- restricted/federated identity providers
- short session lifetimes
- reauthentication for sensitive actions
- stronger separation of administrative duties
- dedicated tenant/database/deployment isolation
- restricted plugin/extension capability
- signed artifacts
- strong audit integrity/tamper evidence
- configurable data-retention policies
- SIEM integration
- hardened agent enrollment and command authorization
- certificate-based machine/service identity
- stricter secret-management requirements
- restricted outbound networking
- additional approval requirements for destructive or privileged actions

Yggdrasil should provide architectural hooks for these controls, but the product must not claim compliance certifications without formal evaluation.

## Trust Boundaries

Important trust boundaries include:

```text
Browser / Client
      ↓
Web/API Host
      ↓
Application Use Cases
      ↓
Domain Modules
      ↓
Persistence / Infrastructure
```

Additional boundaries include:

```text
Yggdrasil Server ↔ Smidr Agent
Yggdrasil ↔ Plugin/Extension
Yggdrasil ↔ External Integration
Tenant A ↔ Tenant B
User ↔ Service Identity
Operator/Admin ↔ Customer Tenant
```

Each boundary should use explicit authentication, authorization, validation, and auditing appropriate to its risk.

## Identity and Authentication

Týr owns the identity/authentication foundation.

Baseline requirements:

- secure local authentication where enabled
- passwords stored only using established password-hashing mechanisms
- secure session/token expiration
- revocation support
- rate limiting on authentication endpoints
- no account-secret leakage through errors
- future support for OIDC/federated identity
- MFA support for stronger deployment profiles
- distinct human and service identities

The authentication mechanism should not leak into business modules.

## Authorization

Authorization must be enforced server-side for every protected operation.

The basic decision context includes:

- authenticated actor
- active tenant
- valid membership/service identity
- required permission
- resource belongs to active tenant
- operation-specific rules

Conceptually:

```text
Authenticated?
  ↓
Active tenant valid?
  ↓
Membership/service authorization valid?
  ↓
Permission granted?
  ↓
Resource belongs to tenant?
  ↓
Domain-specific rule permits action?
```

Failure at any stage results in denial.

The UI may hide unavailable actions for usability, but UI state is never the security control.

## Tenant Isolation

Tenant isolation is mandatory from the first multi-tenant implementation.

Security must not depend on developers remembering to add `TenantId` filters manually in every query.

The design should use layered safeguards such as:

- trusted tenant context established per request
- explicit tenant identity on tenant-owned entities
- centralized persistence/query conventions
- authorization validation
- architecture/integration tests
- database-level safeguards where practical

High-assurance deployments may require stronger isolation models:

- schema-per-tenant
- database-per-tenant
- dedicated deployment

The application architecture should not make those future options impossible.

## Administrative and Operator Access

SaaS/platform operators require special treatment.

Platform administration must not implicitly grant unrestricted access to customer business data.

Potential long-term principles:

- operator permissions are explicit
- tenant support access is separately granted
- impersonation is disabled by default and deferred until securely designed
- sensitive support access requires reason/context
- support/privileged access is audited
- higher-security customers may prohibit operator data access entirely

Dedicated/self-hosted deployments naturally reduce operator-access concerns but should still preserve internal administrative separation.

## Secrets Management

Secrets include:

- database credentials
- signing keys
- API credentials
- OAuth/OIDC secrets
- SMTP credentials
- integration credentials
- agent enrollment secrets
- private keys

Rules:

- secrets must not live in source control
- secrets must not appear in logs/audit records
- production secrets should not be committed to configuration files
- secrets should be rotatable
- credentials should be scoped and least-privileged
- different environments should use different secrets

Deployment options may include environment variables, mounted secret files, OS secret stores, Vault-like systems, or cloud secret managers.

Yggdrasil should not force a cloud secret-management provider so air-gapped/self-hosted deployments remain viable.

## Data Protection

### In Transit

TLS should be required for deployed communication.

Higher-assurance internal/service communication may use mTLS where justified, especially for:

- Smidr agents
- machine-to-machine services
- external trusted integrations

### At Rest

Baseline expectations:

- rely on secure database/storage encryption capabilities at the deployment layer
- encrypt especially sensitive application fields when justified
- secrets receive stronger protection than normal business data

Per-record/field encryption may be introduced for high-security data but should be deliberate because it affects indexing, searching, key rotation, backup, and recovery.

## Data Classification

A simple classification model should eventually distinguish at least:

- Public
- Internal
- Confidential
- Sensitive/Security-Critical

Examples:

- task title: typically internal
- customer contact information: confidential
- password/token/private key: security-critical
- agent execution output: potentially sensitive
- audit security records: sensitive

Classification should guide logging, export, retention, and access rules.

Do not build an elaborate classification framework before it is needed, but avoid designs that assume all fields have equal sensitivity.

## Logging and Observability

Observability is required, but sensitive data must not leak through it.

Rules:

- structured logging preferred
- no passwords/tokens/API secrets
- avoid full request/response body logging by default
- tenant/user identifiers may be included where appropriate
- correlation/trace IDs should be propagated
- customer-content logging should be minimized
- OpenTelemetry should remain vendor-neutral

Air-gapped deployments must be able to keep telemetry fully local.

## Audit Security

Urd provides durable accountability.

Important privileged/security events must be auditable, including:

- authentication/access changes
- organization administration
- role/permission changes
- tenant status changes
- privileged work-item overrides
- credential creation/revocation
- data export
- remote agent commands
- plugin capability changes

Audit records should eventually support tamper-evidence for higher-security deployments.

## Smidr and Remote Execution

Smidr/Eir represent one of Yggdrasil's highest-risk attack surfaces because remote command execution can become equivalent to remote system control.

Agent design should follow these principles:

- outbound-only connection where practical
- unique per-agent identity
- mutually authenticated secure transport
- enrollment and revocation
- commands include unique IDs
- commands have expiration
- replay protection
- explicit required privilege/capability
- signed/authorized command envelope for higher assurance
- restricted execution environment
- default non-root/non-administrator operation
- privileged elevation only for explicit approved actions
- command and result audit trail

Potential command classification:

```text
READ
DIAGNOSTIC
MODIFY
PRIVILEGED
DESTRUCTIVE
```

Higher-risk classes may require additional permissions, approval, or reauthentication.

Stale commands must not automatically execute after an agent reconnects unless policy explicitly permits them.

## Plugins and Extensions

Plugins/extensions are untrusted relative to the platform core unless explicitly trusted.

They must not reference internal module assemblies.

Public contracts should define capabilities.

Potential controls include:

- capability registration
- explicit permissions
- scoped tenant access
- version compatibility
- code/package signing
- execution isolation
- timeout/resource limits
- network/filesystem restrictions
- audit of privileged plugin actions

A disclaimer is not a sandbox.

User-authored automation/scripts should be treated as executable code and require concrete technical controls.

## API Security

Public/internal APIs should follow consistent rules:

- authentication required unless explicitly public
- authorization per operation
- tenant context validated
- input validation
- bounded pagination
- rate limiting where abuse is possible
- idempotency for appropriate write operations
- safe error responses
- request/correlation IDs
- explicit versioning for long-lived contracts

Mass assignment/overposting risks should be avoided by using request-specific contracts rather than binding persistence entities directly.

## Input Validation

All external data is untrusted, including:

- browser/API requests
- agent data
- uploaded documents
- imported tenant exports
- webhook payloads
- plugin messages
- Protobuf messages

Validation should occur at the boundary and domain invariants should still be enforced inside the domain.

Validation must not rely solely on frontend behavior.

## File and Attachment Security

When attachments/documents are implemented:

- validate size/type
- sanitize filenames
- prevent path traversal
- store outside executable application paths
- do not trust MIME type supplied by clients
- apply access control at download time
- consider malware scanning where required
- preserve tenant ownership

Air-gapped deployments must not depend on cloud scanning services.

## Import and Export Security

Data portability is a product requirement but import/export is security-sensitive.

Exports require:

- explicit permission
- tenant scoping
- audit event
- exclusion of reusable secrets
- integrity metadata for archive formats where appropriate

Imports require:

- strict format/version validation
- size/resource controls
- tenant ownership enforcement
- prevention of privilege escalation through imported identities/roles
- safe handling of attachments/files

## Database Security

Baseline requirements:

- least-privileged database accounts
- migrations separated from normal runtime privileges where practical
- TLS to remote databases
- no database passwords in source control
- tenant identifiers/indexes/constraints designed deliberately
- backups protected similarly to production data

Avoid exposing database access as a supported integration contract.

## Supply Chain Security

Yggdrasil intentionally minimizes third-party dependencies.

Supply-chain practices should include:

- centrally managed package versions
- dependency review before introduction
- reproducible builds where practical
- vulnerability scanning in CI
- secret scanning
- pinned action/tool versions
- release checksums/signatures when releases mature
- SBOM generation when useful for customer/security requirements

High-assurance customers may require offline dependency/artifact review.

## CI/CD Security

CI/CD should follow least privilege.

Principles:

- pull requests do not automatically receive production secrets
- deployment credentials are environment-specific
- production deployment requires explicit release/tag conditions
- branch protection/rules should prevent bypassing required checks once workflows mature
- generated artifacts should be traceable to source commit
- release artifacts should be immutable after publication

The pipeline should be designed so self-hosted deployment does not require Intrik8 Labs to retain customer environment credentials.

## Secure Development Lifecycle

Security should be part of ordinary SDLC.

For each significant feature consider:

- authentication impact
- authorization impact
- tenant-isolation impact
- sensitive data
- audit requirements
- secrets
- external inputs
- abuse cases
- backward compatibility/security downgrade risk

High-risk work should include explicit threat modeling.

Good candidates include:

- Týr authentication/authorization
- tenant isolation
- Smidr enrollment/commands
- Eir remediation
- plugin execution
- data import/export
- customer portal exposure

## Security Testing

Testing should include negative cases such as:

- cross-tenant resource access denied
- unauthorized role assignment denied
- expired/revoked credentials denied
- invalid/replayed agent commands denied
- tenant switch does not retain prior permissions
- malformed imports rejected
- secrets do not appear in logs/audit output
- disabled organization cannot perform prohibited actions

Security-sensitive code requires deeper review than ordinary feature code.

## Vulnerability Management

A mature Yggdrasil release process should eventually include:

- dependency vulnerability scanning
- container/image scanning
- security advisories
- supported-version policy
- severity-based remediation timelines
- responsible disclosure process

Do not promise timelines or compliance processes publicly until Intrik8 Labs has the operational capability to meet them.

## Backup and Recovery Security

Backups contain customer data and must receive equivalent protection.

Requirements include:

- access control
- encryption where appropriate
- integrity verification
- tested restore procedures
- retention management
- secure deletion where required

High-security deployments may require customer-managed backup keys or isolated backup infrastructure.

## Security Configuration

Security-sensitive defaults should prefer safety.

Examples:

- TLS required
- anonymous access off unless explicitly enabled
- local password auth configurable, not mandatory
- external telemetry optional
- plugin execution disabled until configured
- remote privileged commands require explicit permissions
- audit enabled

Configuration changes that weaken security should be visible and auditable where practical.

## Compliance Positioning

Yggdrasil may be designed to help customers satisfy security/compliance requirements, but architecture documentation must distinguish capability from certification.

Examples of potential future alignment areas:

- NIST guidance
- CMMC-related customer controls
- SOC 2 operational controls
- ISO 27001-oriented environments
- customer-defined security baselines

Intrik8 Labs should not claim Yggdrasil is compliant/certified with these frameworks without the appropriate formal assessment and operational controls.

The product should instead provide capabilities that make secure deployment and evidence collection practical.

## Initial Security Baseline

Before the first meaningful dogfood release, aim for:

- secure local authentication
- active tenant/membership context
- permission checks
- cross-tenant negative tests
- TLS-capable deployment
- secrets excluded from repo/logs
- basic audit trail
- dependency/secret scanning
- secure configuration defaults

Before use by external customers, additionally require:

- documented backup/restore
- secure update process
- rate limiting/abuse protections
- hardened production configuration
- more complete auth lifecycle
- explicit security review
- vulnerability handling process

Before high-assurance customer positioning, additionally require:

- formal threat models for high-risk subsystems
- stronger agent identity/command controls
- stronger audit integrity
- MFA/federated identity capability
- hardened deployment profile
- signed/reproducible release artifacts where practical
- documented security operations and incident response

## Open Security Questions

Resolve as implementation progresses:

1. What local authentication/session mechanism will be used initially?
2. What is the minimum MFA support required before external beta?
3. Which tenant isolation safeguards should be enforced at EF Core/database level?
4. What deployment profile first requires database-per-tenant?
5. What secret-store abstractions are worth supporting directly?
6. Which operations require reauthentication?
7. Which operations require approval/separation of duties?
8. How will Smidr enrollment and per-agent identity work?
9. What command-signing/replay-prevention model should Smidr use?
10. What plugin execution/sandbox model is practical across self-hosted platforms?
11. When should Urd add cryptographic tamper evidence?
12. What security controls belong in the core product versus deployment documentation?
13. What data-classification model is minimal but useful?
14. Which external security frameworks should be used as design references without making compliance claims?
15. What security guarantees can be consistently maintained across SaaS, self-hosted, and fully offline installations?

## Related Documentation

- `docs/architecture/overview.md`
- `docs/architecture/dependency-rules.md`
- `docs/development/TESTING.md`
- `docs/development/RELEASES.md`
- `docs/modules/TYR.md`
- `docs/modules/VALHALLA.md`
- `docs/modules/URD.md`
- `docs/modules/MIMIR.md`
