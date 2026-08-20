# Contributing to Yggdrasil

Yggdrasil is currently a solo, dogfood-stage project and is not accepting
unsolicited external contributions. This guide documents the development
workflow for current maintainers and establishes expectations for future
contributors.

## Prerequisites

- The .NET SDK selected by `global.json`
- GNU Make for the repository shortcuts
- Docker when building or running the container image
- pre-commit and the tools required by `.pre-commit-config.yaml` when running
  repository hooks

No runtime feature may require Internet, CDN, or cloud access. Dependencies
needed for builds and container images must be obtainable ahead of an
air-gapped deployment.

## Local workflow

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

Use `make help` to see the current command list. Do not commit generated `bin/`
or `obj/` directories.

## Architecture

- Keep domain projects independent of infrastructure frameworks.
- Keep the shared kernel small and framework-free. Add only concepts that have
  the same meaning across bounded contexts.
- Do not reference another module's Domain or Infrastructure project.
- Communicate across module boundaries through explicit contracts, events, or
  interfaces as those integration points are introduced.
- Put business behavior in domain and application code, not controllers or
  persistence models.
- Do not add NuGet packages without explicit approval and a concrete need.
- Do not introduce generic repositories or abstractions that only wrap CRUD.
- Add tests for every behavioral change.

Architecture decisions that affect long-term direction belong in
`docs/decisions/`. Use the existing ADR template and explain changes to project
boundaries or dependencies.

## Changes

Keep changes focused and reviewable. Include a concise description of the
problem, the chosen approach, relevant design decisions, and the verification
commands that were run. Report failing checks rather than suppressing warnings
or changing tests merely to make a build pass.
