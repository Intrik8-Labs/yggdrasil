# ADR-0004 — Modular Boundaries with Event-Driven Internal Communication, Scaled Down

| Field         | Value         |
| ------------- | ------------- |
| Status        | ACCEPTED      |
| Date          | 2026-06-28    |
| Deciders      | Jason Scherer |
| Superseded By |               |

## Revision History

| Version | Date       | Author        | Notes   |
| ------- | ---------- | ------------- | ------- |
| 1.0     | 2026-06-28 | Jason Scherer | Initial |

---

## Context

The original plan called for a modular monolith: a single deployable unit
made of cleanly bounded modules that communicate only through a shared
message bus, never by calling each other's internals directly — so any
module could later be split into its own service without changing the
contract. That reasoning was built around 23 modules and an eventual
MSP-scale deployment.

This phase has three to four modules (`docs/modules/MODULES.md`) and one
user. The question this ADR answers: does the *concept* of bounded
modules talking through events, rather than direct calls, still earn its
keep at this much smaller scale — or is it premature structure for a
project this size?

## Decision Drivers

- Even with three modules, "agent reports health" → "monitoring displays
  it" → "a task gets linked to a machine" are naturally separate
  concerns, and keeping them decoupled costs little extra at this scale
- Retrofitting clean boundaries after code has been written with direct,
  tangled calls between concerns is a real, well-known cost — cheaper to
  keep the boundary from the start than to impose it later
- Splitting into separate deployable services is explicitly *not* a goal
  for this phase (over-engineering for a single self-hosted instance) —
  the value being kept here is the boundary discipline, not the
  deployment flexibility
- Limited time means any pattern adopted needs to be simple to actually
  follow at 5-10 hrs/week, not theoretically clean but tedious in
  practice

## Decision

Keep the concept: Yggdrasil ships as a single deployable unit (a modular
monolith), and the in-scope modules (Smidr, Heimdallr, Mimir, Tyr)
communicate through events/messages rather than reaching into each
other's internals directly.

Scale down what that means in practice for this phase:

- Three to four modules, not 23
- No requirement that this be split into separate services, ever — that
  motivation from the original plan is explicitly not a goal right now
- The specific message bus technology is an implementation decision, not
  an architecture decision, and is out of scope for this ADR (see
  `docs/planning/CHARTER.md` — programming language and stack choices are
  being deferred past this planning phase)

## Consequences

**Positive:**

- Keeps modules honest about what they depend on, even with only one
  developer who could otherwise take shortcuts under time pressure
- Avoids a rewrite if/when more modules get added in Phase 3, since the
  communication pattern won't need to change, only grow

**Accepted tradeoffs:**

- Slightly more structure up front than the absolute fastest path to a
  working prototype would have
- This is accepted because the original plan's own experience already
  showed what happens when structure is skipped early and time is spent
  retrofitting it later (the project went through three separate language
  migrations before anything was dogfooded)

**Negative:**

- None identified at this scale

**Neutral / follow-up:**

- Revisit whether services should actually be split out only if a
  concrete operational reason appears (e.g., one module needs independent
  scaling or a different deployment target) — not preemptively

---

## Alternatives Considered

**Drop module boundaries entirely for the MVP; one monolithic blob of code**

Fastest to a working prototype. Rejected because the original plan's own
history (three language migrations, a 23-module redesign) is direct
evidence that skipping structure early on this project specifically tends
to cost more later than it saves now.

**Build for eventual service splitting now (separate deployable processes per module)**

This was closer to the original plan's ambition. Rejected for this phase
— there is one user and one deployment target; the operational cost of
multiple processes (deployment, networking, debugging across process
boundaries) has no current benefit.

---

## Related

- `docs/modules/MODULES.md`
- `docs/planning/CHARTER.md`
