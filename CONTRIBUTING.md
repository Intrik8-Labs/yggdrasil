# Contributing to Yggdrasil

Yggdrasil is currently a solo, dogfood-stage project and is not accepting unsolicited external contributions. This guide documents the development workflow for current maintainers and establishes expectations for future contributors.

## Prerequisites

- Ruby and Rails versions selected by the application once it is generated
- PostgreSQL
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

The Rails application has not been generated yet, so application-specific setup and verification commands are intentionally not documented. Once the app exists, keep the canonical setup, test, lint, and run commands here and expose stable shortcuts where useful.

Use `make help` to see the current repository workflow commands.

## Development Process

The active Agile/SDLC workflow is documented in:

- [`docs/development/WORKFLOW.md`](docs/development/WORKFLOW.md)
- [`docs/development/TESTING.md`](docs/development/TESTING.md)
- [`docs/development/RELEASES.md`](docs/development/RELEASES.md)
- [`docs/development/AI_USAGE.md`](docs/development/AI_USAGE.md)

## Architecture

- Organize business areas with explicit Ruby namespaces and ownership boundaries.
- Keep controllers focused on HTTP concerns and orchestration.
- Put business behavior near the models it governs or in focused service objects when orchestration spans models.
- Communicate across module boundaries through explicit public interfaces and events where asynchronous behavior is justified.
- Do not add gems or JavaScript packages without a concrete need.
- Use Active Record directly unless a demonstrated need justifies another persistence abstraction.
- Add tests for behavioral changes.

Architecture decisions that affect long-term direction belong in `docs/decisions/`. Use the existing ADR template and explain changes to module boundaries, public contracts, or dependencies.

## Changes

Keep changes focused and reviewable. Include a concise description of the problem, the chosen approach, relevant design decisions, and verification commands that were run. Report failing checks rather than suppressing warnings or changing tests merely to make a build pass.
