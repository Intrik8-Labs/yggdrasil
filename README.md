# Yggdrasil

**Yggdrasil by Intrik8 Labs**

Yggdrasil is a modular operations and business platform being developed to help individuals and teams manage their systems, assets, and related work.

## Purpose

Bring asset information, operational observations, changes, follow-up work, and history into one application. The first use case is managing personal computers and a homelab. The platform should grow to support small teams and organizations.

## Current status

The project is in its planning and documentation stage. Application implementation has not started.

## Initial operations goal

The first usable operations slice should let a person:

- Sign in and enter a Personal Workspace.
- Register computers and assign them to locations.
- Collect inventory and basic health information.
- Inspect changes and findings with understandable evidence.
- Track follow-up tasks and inspect the history of changes.

These capabilities will be built incrementally.

## Technical direction

- **Server:** .NET and ASP.NET Core, organized as a modular monolith.
- **Endpoint agent:** Go, under the Smidr name.
- **Module boundaries:** explicit public contracts, with implementation details kept within each module.

Self-hosted, SaaS, and air-gapped deployments are planned. The [Twelve-Factor App](https://12factor.net/) principles will guide application configuration, builds, releases, and operation.

## Working approach

Work proceeds one document or capability at a time. Each step explains its purpose and the changes being proposed.

Changes are checked and reviewed by the project owner before they are committed. Work uses focused branches from `dev`, with approved changes integrated through pull requests. `main` is reserved for accepted releases.

Documentation is developed alongside the application so that its behavior, decisions, and development process remain understandable.
