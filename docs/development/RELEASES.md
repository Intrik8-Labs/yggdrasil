# Yggdrasil Release Process

## Purpose

Yggdrasil uses a lightweight release process suitable for an early-stage solo project while preserving practices that can scale to future Intrik8 Labs products.

Releases should be reproducible, documented, and easy to deploy in self-hosted and eventually air-gapped environments.

## Versioning

Yggdrasil uses Semantic Versioning.

Early development may use prerelease versions such as:

```text
0.1.0-alpha.1
0.1.0-alpha.2
0.1.0-beta.1
```

Normal versions follow:

```text
MAJOR.MINOR.PATCH
```

- `MAJOR` — incompatible public API or product behavior changes once compatibility guarantees apply
- `MINOR` — backward-compatible features
- `PATCH` — backward-compatible fixes

During `0.x`, breaking changes are still possible, but public contracts should still be versioned deliberately rather than changed casually.

## Branches

Current release flow:

```text
feature/fix branches
        ↓
     develop
        ↓
 release validation
        ↓
      main
        ↓
       tag
```

`develop` is the integration branch.

`main` represents stable release history.

Short-lived release branches may be used when needed for stabilization, but they are not required for every early development release.

## Release Readiness

Before creating a release:

- the intended scope is complete
- acceptance criteria are satisfied
- `make check` passes
- architecture tests pass
- relevant integration/end-to-end tests pass
- database migrations are reviewed and tested
- public contract compatibility is reviewed
- security-sensitive changes have received explicit review
- release notes are prepared
- known issues are documented
- deployment/upgrade instructions are current

## Release Notes

Each meaningful release should summarize changes using categories such as:

```text
Added
Changed
Fixed
Security
Deprecated
Known Issues
```

Release notes should describe user- or operator-relevant outcomes rather than merely listing commit messages.

Conventional Commits may later be used to assist changelog generation, but generated text must still be reviewed.

## Tags

Release tags should match the version:

```text
v0.1.0-alpha.1
v0.1.0
v0.2.0
```

Tags should point to the exact commit used to build the release artifacts.

## Build Artifacts

The long-term release set may include:

- OCI container images
- server binaries/packages
- Smidr agent binaries for supported platforms
- database migration artifacts
- versioned Protobuf/contracts or SDK packages
- air-gap deployment bundles
- checksums/signatures

Only artifacts actually required by the current phase should be produced.

## Environments

The intended lifecycle is:

```text
Local
↓
Development
↓
Test / Release Candidate
↓
Production
```

Early dogfood deployments may use simplified infrastructure, but configuration and data should remain separated by environment.

A future CI/CD flow may map approximately to:

```text
push to develop
→ build + test
→ deploy development

prerelease/release-candidate tag
→ validate + deploy test

stable release tag
→ build signed release artifacts
→ production deployment eligibility
```

## Database Changes

A release containing schema changes must include migrations that are safe to apply from the previously supported release.

Before release, verify:

- migration succeeds against representative data
- expected data is preserved
- indexes and constraints are correct
- application and migration ordering is understood
- recovery/backup implications are documented for risky changes

Destructive migrations require additional review and should not be hidden inside unrelated releases.

## Contract Changes

Contracts include REST APIs, Protobuf definitions, integration events, export formats, and plugin/extension boundaries.

Before release:

- backward compatibility must be considered
- Protobuf field numbers must not be reused
- breaking contracts should receive a new version where appropriate
- deprecated behavior should have a migration path when practical

## Security Releases

Security issues should be handled with priority appropriate to impact.

A security release should avoid disclosing exploit details prematurely when doing so would materially increase risk for deployed users.

Security-sensitive release notes should clearly identify required operator actions, such as credential rotation or immediate upgrades.

## Air-Gapped Releases

Air-gap support is a core product requirement.

As that deployment model is implemented, release bundles should be independently transferable without requiring runtime access to:

- external package registries
- cloud identity systems
- external CDNs
- hosted telemetry services
- online license validation

Air-gap bundles should eventually contain everything required to install or upgrade the supported deployment, with integrity verification.

## Rollback and Recovery

Rollback strategy depends on the type of change.

Application-only changes may allow a simple previous-version deployment.

Database migrations and external contract changes may make rollback more complicated. Releases should prefer forward-compatible migrations and explicit recovery procedures over assuming binary rollback is always safe.

## Release Approval

During solo development, the maintainer acts as release owner.

The release checkpoint should still be deliberate: review the diff/scope, validation results, migrations, security implications, release notes, and deployment plan before tagging.

As Intrik8 Labs grows, this process can add independent approval without changing the underlying lifecycle.
