# AI Usage in Yggdrasil Development

## Purpose

Yggdrasil uses AI as an engineering aid, not as a replacement for understanding or ownership of the codebase.

The project is intended to remain maintainable by its human developers over a long lifespan. Production code should therefore be understood, reviewed, and deliberately authored rather than accepted as opaque generated output.

## Preferred Uses

AI is encouraged for:

- documentation drafting and maintenance
- architecture discussion and tradeoff analysis
- research and summarization
- code review assistance
- test-case and edge-case discovery
- threat-model brainstorming
- API and framework explanation
- migration planning
- issue refinement and backlog organization
- identifying missing documentation or contradictory design decisions

## Production Code

Production application and domain code should primarily be written by the maintainer.

AI may help explain a problem, discuss approaches, review an implementation, or provide small illustrative examples. Large generated implementations should not be copied into the codebase without the same level of understanding and scrutiny expected of manually written code.

A useful standard is:

> Do not merge code that the maintainer cannot explain, debug, and maintain without the AI tool that produced it.

## Tests

AI can be particularly useful for identifying:

- boundary conditions
- failure paths
- security cases
- tenant-isolation cases
- concurrency cases
- malformed input
- state-transition edge cases

AI-generated test ideas are suggestions. Tests remain first-class engineering artifacts and should be reviewed for correctness, value, and coupling to implementation details.

## Documentation

Documentation is the primary area where AI assistance is expected to provide significant leverage.

AI may help keep:

- architecture documentation
- ADRs
- module documentation
- weekly project reviews
- issue descriptions
- release notes
- operational runbooks

consistent with the decisions made by the project maintainer.

AI-written documentation must still accurately reflect the implementation and current project decisions.

## IDE and Tooling

JetBrains Rider is the preferred IDE for C#/.NET development.

The repository must remain independent of Rider and buildable/testable from standard command-line tooling on Linux, macOS, and Windows.

AI-specific IDE integrations are optional and should not become required development infrastructure.
