## WHAT: Project Overview

Claude Code plugin providing AI-powered skills and agents for development workflow automation. Includes documentation generation, PR review tools, and LSP integration.

### Tech Stack
- Bash shell scripts for system automation
- Markdown prompts for AI skill definitions
- JSON/YAML for configuration
- Claude Code Plugin API (skills, agents, hooks)

### Directory Structure
- `skills/` - User-invocable commands (/initex, /efm-bootstrap, /fetch-review-comments, /pr-inline-comment)
- `agents/` - Background workers (prompt-simplifier)
- `hooks/` - Lifecycle event handlers (context drift detection)
- `.claude-plugin/` - Plugin metadata

## WHY: Design Philosophy

### Architecture Pattern
Feature-based organization: Each skill/agent is self-contained in its own directory

### Key Design Decisions
- Skills vs Agents: Different execution contexts (user-invoked vs subprocess)
- Script-based vs Prompt-based: System integration uses shell, AI reasoning uses prompts
- Self-contained features: No shared utilities, each feature is independent

## HOW: Development Workflow

### Development Commands
- `git add . && git commit` - Version control with conventional commit format
- Load plugin in Claude Code CLI - Test skills
- Edit `skills/*/SKILL.md` - Modify skill prompts

### Validation
1. Load plugin in Claude Code
2. Run modified skill (e.g., `/initex`)
3. Test on sample repositories
4. Review prompt logic

### Testing Strategy
Manual end-to-end testing in Claude Code CLI with real conversation contexts

## Detailed Documentation

### Core Documentation
- @./rules/project-overview.md
- @./rules/design-philosophy.md
- @./rules/development-workflow.md

### Additional Rules
- @./rules/git-workflow.md

### Configuration References
- @.claude-plugin/plugin.json
- @hooks/hooks.json
- @README.md
