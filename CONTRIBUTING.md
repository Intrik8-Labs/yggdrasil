# Contributing to Yggdrasil

Yggdrasil is currently a solo, dogfood-stage project and is not accepting unsolicited external contributions. This guide documents the development workflow for current maintainers and establishes expectations for future contributors.

## Prerequisites

- mise and the .NET 10 SDK selected by `mise.toml`
- Python 3 for the commit-message hook and its tests
- PostgreSQL when implementing or running database-backed features
- GNU Make for repository workflow shortcuts
- `pre-commit` and the tools required by `.pre-commit-config.yaml`

The repository must remain usable from standard command-line tooling. No editor or IDE is required.

No runtime feature may require Internet, CDN, or cloud access. Dependencies needed for builds and container images must be obtainable ahead of an air-gapped deployment.

## Install Git Hooks

Install both normal pre-commit hooks and the Conventional Commits message hook:

```shell
pre-commit install
```

The configuration installs both hook stages by default. File checks include YAML/TOML validation, secret detection, and .NET formatting through `mise run lint` when C# or project files change. Install mise and run `mise install` before committing .NET changes; formatting requires a root project or solution.

Run all file checks with `pre-commit run --all-files`. Run commit-message regression tests with `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -v`.

Commit messages must follow the policy documented in [`docs/development/WORKFLOW.md`](docs/development/WORKFLOW.md).

## Local Workflow

The solution is `yggdrasil.slnx`; the ASP.NET Core API host is `src/hosts/Yggdrasil.Api`.

```shell
mise install
mise run setup
mise run build
mise exec -- dotnet run --project src/hosts/Yggdrasil.Api
```

Run `mise run check` for restore, build, formatting verification, and tests. Use `mise run ci` for the Release configuration, `mise run lint:fix` to apply formatting, and `mise tasks ls` to list all tasks.

The current solution contains an API scaffold. Business modules, EF Core persistence, the React frontend, and application test projects are still to be implemented. A successful `dotnet test` without test projects is not evidence of application test coverage.

Use `make help` to see the current repository workflow commands.

## Development Process

The active Agile/SDLC workflow is documented in:

- [`docs/development/WORKFLOW.md`](docs/development/WORKFLOW.md)
- [`docs/development/TESTING.md`](docs/development/TESTING.md)
- [`docs/development/RELEASES.md`](docs/development/RELEASES.md)
- [`docs/development/AI_USAGE.md`](docs/development/AI_USAGE.md)

## Architecture

- Organize business areas with explicit C# namespaces and assemblies and ownership boundaries.
- Keep controllers focused on HTTP concerns and orchestration.
- Put business invariants in module Core projects and use-case orchestration in UseCases; keep infrastructure adapters outside the domain.
- Communicate across module boundaries through explicit public interfaces and events where asynchronous behavior is justified.
- Do not add NuGet or JavaScript packages without a concrete need.
- Use EF Core/Npgsql for PostgreSQL persistence in Infrastructure. Expose only the application-owned interfaces needed by use cases; avoid generic wrappers that merely rename CRUD operations.
- Add tests for behavioral changes.

Architecture decisions that affect long-term direction belong in `docs/decisions/`. Use the existing ADR template and explain changes to module boundaries, public contracts, or dependencies.

## Changes

Keep changes focused and reviewable. Include a concise description of the problem, the chosen approach, relevant design decisions, and verification commands that were run. Report failing checks rather than suppressing warnings or changing tests merely to make a build pass.
