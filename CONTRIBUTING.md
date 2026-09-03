# Contributing to Yggdrasil

Yggdrasil is currently a solo, dogfood-stage project and is not accepting unsolicited external contributions. This guide documents the development workflow for current maintainers and establishes expectations for future contributors.

## Prerequisites

- The .NET SDK selected by `global.json`
- GNU Make for repository shortcuts
- Docker when building or running container images
- `pre-commit` and the tools required by `.pre-commit-config.yaml`

JetBrains Rider is the preferred IDE for C#/.NET development, but the repository must remain fully usable from the command line on Linux, macOS, and Windows.

No runtime feature may require Internet, CDN, or cloud access. Dependencies needed for builds and container images must be obtainable ahead of an air-gapped deployment.

## Install Git Hooks

Install both normal pre-commit hooks and the Conventional Commits message hook:

```shell
pre-commit install
pre-commit install --hook-type commit-msg
```

Commit messages must follow the policy documented in [`docs/development/WORKFLOW.md`](docs/development/WORKFLOW.md).

## Local Workflow

Run the complete local verification sequence before submitting a change:

```shell
make check
```

Individual commands are also available:

```shell
make restore
make build
make format
make test
make run
make docker-build
```

Use `make help` to see the current command list. Do not commit generated `bin/` or `obj/` directories.

## Development Process

The active Agile/SDLC workflow is documented in:

- [`docs/development/WORKFLOW.md`](docs/development/WORKFLOW.md)
- [`docs/development/TESTING.md`](docs/development/TESTING.md)
- [`docs/development/RELEASES.md`](docs/development/RELEASES.md)
- [`docs/development/AI_USAGE.md`](docs/development/AI_USAGE.md)

## Architecture

- Keep Core projects independent of infrastructure frameworks.
- Keep the SharedKernel small and framework-free. Add only concepts that have the same meaning across bounded contexts.
- Do not reference another module's Core, UseCases, or Infrastructure project.
- Communicate across module boundaries through explicit public contracts and events.
- Put business behavior in Core and UseCases, not controllers or persistence models.
- Do not add NuGet packages without a concrete need.
- Do not introduce generic repositories or abstractions that merely wrap CRUD.
- Add tests for behavioral changes.

Architecture decisions that affect long-term direction belong in `docs/decisions/`. Use the existing ADR template and explain changes to project boundaries, public contracts, or dependencies.

## Changes

Keep changes focused and reviewable. Include a concise description of the problem, the chosen approach, relevant design decisions, and verification commands that were run. Report failing checks rather than suppressing warnings or changing tests merely to make a build pass.
