# Yggdrasil

A self-hosted tool for tracking what's running and what's left to do
across the author's own homelab — built solo, dogfooded first. The
longer-term direction is a unified, self-hosted operations platform (RMM,
PSA, CRM, ERP) for people and organizations tired of stitching together
separate tools, but that's a direction to grow into, not the current
scope. See [`docs/planning/CHARTER.md`](docs/planning/CHARTER.md) and
[`docs/planning/ROADMAP.md`](docs/planning/ROADMAP.md).

## Status

Planning restart, scoped down from an earlier, much larger plan. Current
phase: a minimal single-user loop across three modules — agent,
monitoring, tasks. Scope and architecture decisions are tracked as
Architecture Decision Records — see [`docs/decisions/`](docs/decisions/).

## In Scope Right Now

- **Smidr** — agent, connects outbound only, reports basic health/inventory
- **Heimdallr** — monitoring, displays what Smidr reports
- **Mimir** — task/ticket tracking, linked to the machines it relates to
- **Tyr** — minimal single-user login

The full original module catalog is kept as reference, not commitment —
see [`docs/modules/MODULES.md`](docs/modules/MODULES.md).

## License

Currently licensed under the [Business Source License 1.1](LICENSE)
(BUSL), inherited from the earlier, larger-scoped plan. This is being
reconsidered for the current solo/dogfood scope — see
[`docs/decisions/adr-0005-deferred-decisions-log.md`](docs/decisions/adr-0005-deferred-decisions-log.md) —
and should be treated as provisional. [LICENSE](LICENSE) remains the
binding text until that's revisited.

## Contributing

Not open to outside contributions yet — this is solo, dogfood-stage work.
The development workflow and architectural expectations are documented in
[`CONTRIBUTING.md`](CONTRIBUTING.md) for the project's current maintainers and
future contributors.
