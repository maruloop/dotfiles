@./project-overview.md

## Architecture Pattern

Feature-based organization: Each skill and agent is self-contained in its own directory with all necessary resources (prompts, scripts, templates, wrappers).

## Design Decisions

### Skills vs Agents Separation
Skills are user-invoked commands (execution context: main conversation).
Agents run in subprocesses (execution context: background tasks).

This separation reflects different execution lifecycles and resource needs.

### Script-Based vs Prompt-Based Skills
Skills use different implementation approaches based on automation needs:
- efm-bootstrap: Heavy shell scripting for system integration (LSP server provisioning)
- initex: AI-driven prompting for interactive documentation generation
- fetch-review-comments: Shell/API calls for data retrieval
- pr-inline-comment: Prompt-based AI review generation

### Self-Contained Features
Each skill/agent directory contains:
- SKILL.md or agent.md (prompt definition)
- scripts/ (if needed for automation)
- templates/ (if needed for config generation)
- wrappers/ (if needed for output normalization)

No shared utility layer - features are independent and portable.

## Why This Structure

The flat, feature-based organization makes:
- Skills easy to add/remove without affecting others
- Each feature's dependencies clear and isolated
- Plugin marketplace distribution straightforward (single directory per feature)

Skills that need system integration (efm-bootstrap) use shell scripts.
Skills that need AI reasoning (initex, pr-inline-comment) use prompt engineering.
