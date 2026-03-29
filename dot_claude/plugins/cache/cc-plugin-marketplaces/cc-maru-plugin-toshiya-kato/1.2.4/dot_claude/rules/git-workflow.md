@./project-overview.md

## Commit Message Format

Conventional commits format:
- `feat: description` - New features
- `fix: description` - Bug fixes
- `docs: description` - Documentation changes
- `refactor: description` - Code refactoring
- `test: description` - Test additions/changes
- `chore: description` - Maintenance tasks

Examples from history:
- `feat: add pr-inline-comment skill for automated PR review comments`
- `NO-ISSUE Fix hooks.json schema structure and bump version to 1.2.1`
- `NO-ISSUE Add context-refresh hook for documentation drift reminders`

Use NO-ISSUE prefix when there's no associated JIRA task.

## Branch Strategy

Work directly on main branch (simple plugin development flow).

## PR Process

Push to plugin marketplace repositories:
- https://git.linecorp.com/nomura-yuta/cc-plugin-marketplace
- https://ghe.corp.yahoo.co.jp:myamate/cc-plugin-marketplace

## Version Bumping

Update `.claude-plugin/plugin.json` version field when releasing changes.
