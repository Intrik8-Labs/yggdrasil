# Yggdrasil Development Workflow

## Purpose

Yggdrasil uses a lightweight Agile development process designed for a solo maintainer while preserving habits that will scale to a larger Intrik8 Labs engineering team later.

The process favors short feedback loops, explicit architecture decisions, small reviewable changes, continuous dogfooding, and minimal ceremony.

## Work Hierarchy

Use the following hierarchy when planning work:

```text
Initiative
└── Epic
    └── Feature
        └── Task
            └── Subtask (rare)
```

Avoid unnecessary hierarchy. A task should represent a concrete engineering outcome that can normally be completed within one iteration.

## Issue Types

Recommended issue labels:

- `type:epic` — large outcome spanning multiple tasks
- `type:feature` — user-visible capability
- `type:task` — concrete engineering work
- `type:bug` — incorrect behavior
- `type:adr` — architecture decision
- `type:research` — spike or investigation
- `type:debt` — technical debt

Recommended area labels should stay limited and reflect stable ownership boundaries such as platform, identity, Mímir, Urd, frontend, security, documentation, and DevOps.

## Weekly Iterations

Yggdrasil uses one-week iterations.

At the beginning of each iteration:

1. Define one primary weekly goal.
2. Select approximately 3–6 concrete tasks that support that goal.
3. Identify known blockers, dependencies, and risks.
4. Leave capacity for investigation and unexpected work.

Do not attempt to fully schedule every available hour.

### Work States

The preferred workflow is:

```text
Backlog
↓
Ready
↓
In Progress
↓
Review
↓
Done
```

Use `Blocked` when work cannot reasonably proceed.

Keep work in progress low. One active task is preferred; two is acceptable when one is waiting on an external dependency.

## Definition of Ready

Before moving an item into an iteration, it should normally have:

- a clear outcome
- enough context to begin
- concise acceptance criteria
- known dependencies where applicable
- an appropriate module or area
- scope small enough for the current iteration

Research items may intentionally have exploratory acceptance criteria.

## Definition of Done

A development task is done when applicable criteria are satisfied:

- implementation is complete
- acceptance criteria are satisfied
- relevant tests are added or updated
- all automated tests pass
- architecture rules pass
- formatting and static checks pass
- no new unexplained warnings are introduced
- security and tenant-isolation implications were considered
- relevant documentation was updated
- the change has been reviewed before merge

Contract changes additionally require compatibility and versioning consideration.

Database changes require a tested migration and consideration of upgrade/recovery implications.

## Branching

Yggdrasil currently uses:

- `main` — stable/release history
- `develop` — integration branch for active development
- short-lived branches for features, bugs, documentation, and refactors

Examples:

```text
feature/17-clean-architecture-structure
feature/19-command-query-abstractions
fix/42-tenant-context-validation
docs/testing-strategy
```

Long-running feature branches should be avoided.

## Pull Requests

Significant changes should use a pull request even during solo development.

The pull request is a deliberate review checkpoint, not merely an approval mechanism.

Before merge:

- read the complete diff
- remove accidental complexity and unrelated changes
- verify architecture boundaries
- inspect security-sensitive changes carefully
- verify schema migrations where applicable
- verify tests and acceptance criteria
- link the related issue

AI tools may assist with review and identifying edge cases, but the maintainer owns the final implementation and must understand the merged code.

## Conventional Commits

Yggdrasil uses Conventional Commits.

Format:

```text
<type>(optional-scope): <description>
```

Examples:

```text
feat(mimir): add task creation use case
fix(tyr): enforce active tenant membership
docs(architecture): define module dependency rules
test(mimir): add task lifecycle cases
refactor(platform): reorganize module projects
```

Supported types include:

- `feat`
- `fix`
- `docs`
- `style`
- `refactor`
- `perf`
- `test`
- `build`
- `ci`
- `chore`
- `revert`

Breaking changes may use `!` before the colon and should explain the break in the commit body when additional context is required.

Commit messages are validated by the repository `commit-msg` pre-commit hook.

Install all hooks with:

```shell
pre-commit install
pre-commit install --hook-type commit-msg
```

## Weekly Review

At the end of each iteration, complete `docs/planning/WEEKLY_REVIEW_TEMPLATE.md`.

The review should capture:

- completed work
- work still in progress
- blockers
- important architecture or product decisions
- lessons learned
- changes to scope or assumptions
- the next three highest-priority actions

The goal is to build a useful historical engineering record without creating unnecessary ceremony.

## GitHub Projects

GitHub Projects should be used as the primary visual planning board for Yggdrasil.

Keep the configuration intentionally simple.

Recommended fields:

- Status
- Priority
- Iteration
- Area/Module
- Type

Recommended views:

1. **Current Iteration** — board grouped by Status and filtered to the active iteration
2. **Backlog** — prioritized table of future work
3. **Roadmap** — higher-level epics/features grouped by target iteration or milestone

GitHub Issues remain the source of truth for individual work items. The Project provides prioritization, iteration planning, and visibility rather than duplicating issue content.

Avoid adding fields or automation until a real workflow problem justifies them.

## Architecture Decisions

Create an ADR when a decision is difficult to reverse, affects multiple modules, changes architecture rules, introduces significant infrastructure, establishes a public contract, or introduces a major dependency.

Small implementation details do not require ADRs.

## AI Usage

See `AI_USAGE.md`.

AI is primarily an aid for documentation, research, architecture discussion, review, test-case discovery, and edge-case analysis. Production code remains principally human-authored and understood by the maintainer.
