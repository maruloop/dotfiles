@./design-philosophy.md

## Tech Stack

Bash: Shell scripts for automation and system integration
Markdown: Skill and agent prompt definitions
JSON/YAML: Configuration and metadata files
Claude Code Plugin API: Skills, agents, and hooks framework

## Project Structure

- `skills/` - User-invocable commands (slash commands like /initex, /fetch-review-comments)
- `agents/` - Background workers for prompt simplification and code review
- `hooks/` - Lifecycle event handlers (context drift reminders)
- `.claude-plugin/` - Plugin metadata and version information

## Key Components

### Skills
- `initex/` - Interactive documentation generator using AI prompting
- `efm-bootstrap/` - EFM language server provisioning with shell automation
- `fetch-review-comments/` - PR review comment fetching
- `pr-inline-comment/` - Automated PR review comment generation

### Agents
- `prompt-simplifier/` - Refines and clarifies skill/agent prompts

### Hooks
- Context drift detection on session stop

## Key Files

- `.claude-plugin/plugin.json` - Plugin name, version, author
- `skills/*/SKILL.md` - Skill prompt definitions
- `agents/*/[name].md` - Agent prompt definitions with YAML frontmatter
- `hooks/hooks.json` - Hook configuration for lifecycle events
